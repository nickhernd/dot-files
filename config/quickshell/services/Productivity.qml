pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Datos de los widgets de productividad: pomodoro, tiempo programando,
// entregas (~/deadlines.md) y fórmula del día.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: home + "/.local/state/quickshell"

    function today() {
        return Qt.formatDate(new Date(), "yyyy-MM-dd");
    }

    function notify(title, body) {
        Quickshell.execDetached(["notify-send", "-a", "Pomodoro", title, body]);
    }

    // ── Pomodoro ────────────────────────────────────────────────────────────
    property int focusMinutes: 25
    property int breakMinutes: 5
    property int longBreakMinutes: 15
    property string phase: "focus"          // focus | break
    property bool running: false
    property int remaining: focusMinutes * 60
    property int sessionsToday: 0

    readonly property int phaseTotal: (phase === "focus" ? focusMinutes : (sessionsToday % 4 === 0 && sessionsToday > 0 ? longBreakMinutes : breakMinutes)) * 60
    readonly property real progress: 1 - remaining / Math.max(1, phaseTotal)

    function toggle() {
        running = !running;
    }

    function reset() {
        running = false;
        phase = "focus";
        remaining = focusMinutes * 60;
    }

    function skip() {
        remaining = 0;
        tick.triggered();
    }

    Timer {
        id: tick
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.remaining > 0) {
                root.remaining -= 1;
                return;
            }
            if (root.phase === "focus") {
                root.sessionsToday += 1;
                root.savePomodoro();
                root.phase = "break";
                root.remaining = root.phaseTotal;
                root.notify("🍅 Sesión completada", "Toca descanso de " + Math.round(root.phaseTotal / 60) + " min. Llevas " + root.sessionsToday + " hoy.");
            } else {
                root.phase = "focus";
                root.remaining = root.focusMinutes * 60;
                root.running = false;
                root.notify("A trabajar", "Descanso terminado. Pulsa para empezar otro pomodoro.");
            }
        }
    }

    FileView {
        id: pomodoroFile
        path: root.stateDir + "/pomodoro.json"
        onLoaded: {
            try {
                const j = JSON.parse(text());
                root.sessionsToday = j.date === root.today() ? j.sessions : 0;
            } catch (e) {}
        }
    }

    function savePomodoro() {
        pomodoroFile.setText(JSON.stringify({ date: today(), sessions: sessionsToday }));
    }

    IpcHandler {
        target: "pomodoro"
        function toggle(): void { root.toggle(); }
        function reset(): void { root.reset(); }
        function skip(): void { root.skip(); }
    }

    // ── Tiempo programando (por ventana activa, sin contar inactividad) ─────
    // Categorías: code (nvim/editores), terminal, browser, docs, other. Segundos.
    property var usage: ({ code: 0, terminal: 0, browser: 0, docs: 0, other: 0 })
    property var week: []                   // [{date, active}] últimos 7 días
    readonly property int activeToday: usage.code + usage.terminal + usage.browser + usage.docs + usage.other
    property string usageDate: today()

    IdleMonitor {
        id: idle
        timeout: 120
        respectInhibitors: false
    }

    function categorize(cls, title) {
        cls = (cls || "").toLowerCase();
        title = (title || "").toLowerCase();
        if (/code|zed|jetbrains|idea|pycharm|clion|texstudio/.test(cls) || /n?vim\b|nvim/.test(title))
            return "code";
        if (/kitty|foot|alacritty|ghostty|terminal|wezterm/.test(cls))
            return "terminal";
        if (/chrom|brave|firefox|zen|edge|vivaldi|librewolf/.test(cls))
            return "browser";
        if (/zathura|okular|evince|sioyek|zotero|typora|xournal|libreoffice|papers/.test(cls))
            return "docs";
        return "other";
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            if (root.usageDate !== root.today()) {
                root.usageDate = root.today();
                root.usage = { code: 0, terminal: 0, browser: 0, docs: 0, other: 0 };
                root.loadWeek();
            }
            if (!idle.isIdle)
                activeProc.running = true;
        }
    }

    Process {
        id: activeProc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const w = JSON.parse(text);
                    if (!w.class)
                        return;
                    const c = root.categorize(w.class, w.title);
                    const u = Object.assign({}, root.usage);
                    u[c] += 10;
                    root.usage = u;
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.saveUsage()
    }

    FileView {
        id: usageFile
        path: root.stateDir + "/usage-" + root.usageDate + ".json"
        onLoaded: {
            try {
                root.usage = Object.assign({ code: 0, terminal: 0, browser: 0, docs: 0, other: 0 }, JSON.parse(text()));
            } catch (e) {}
        }
    }

    function saveUsage() {
        usageFile.setText(JSON.stringify(usage));
        loadWeek();
    }

    function loadWeek() {
        weekProc.running = true;
    }

    Process {
        id: weekProc
        command: ["sh", "-c", "cd \"$HOME/.local/state/quickshell\" 2>/dev/null && for i in 6 5 4 3 2 1 0; do d=$(date -d \"-$i day\" +%F); f=usage-$d.json; if [ -s $f ]; then jq -c --arg d $d '{date:$d, active:([.[]]|add)}' $f; else echo \"{\\\"date\\\":\\\"$d\\\",\\\"active\\\":0}\"; fi; done | jq -sc ."]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.week = JSON.parse(text); } catch (e) {}
            }
        }
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", stateDir]);
        loadWeek();
    }

    // ── Entregas / exámenes (~/deadlines.md) ────────────────────────────────
    // Líneas "- 2026-10-05 Análisis II: parcial" (también dd/mm/aaaa).
    property var deadlines: []

    FileView {
        id: deadlinesFile
        path: root.home + "/deadlines.md"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parseDeadlines(text())
    }

    Timer {
        // Recalcular "faltan N días" al cambiar de día
        interval: 30 * 60 * 1000
        repeat: true
        running: true
        onTriggered: root.parseDeadlines(deadlinesFile.text())
    }

    function parseDeadlines(t) {
        const out = [];
        const now = new Date();
        now.setHours(0, 0, 0, 0);
        (t || "").split("\n").forEach(l => {
            let m = l.match(/^\s*[-*]\s*(?:\[[ xX]\]\s*)?(\d{4})-(\d{2})-(\d{2})(?:\s+(\d{1,2}:\d{2}))?\s+(.+)$/);
            let d = null, time = "", text = "";
            if (m) {
                d = new Date(+m[1], +m[2] - 1, +m[3]);
                time = m[4] || "";
                text = m[5];
            } else {
                m = l.match(/^\s*[-*]\s*(?:\[[ xX]\]\s*)?(\d{1,2})\/(\d{1,2})\/(\d{4})(?:\s+(\d{1,2}:\d{2}))?\s+(.+)$/);
                if (!m)
                    return;
                d = new Date(+m[3], +m[2] - 1, +m[1]);
                time = m[4] || "";
                text = m[5];
            }
            const done = /\[[xX]\]/.test(l);
            const days = Math.round((d - now) / 86400000);
            if (days < -1 || done)
                return;
            out.push({ date: d, time: time, text: text, days: days });
        });
        out.sort((a, b) => a.date - b.date);
        deadlines = out;
    }

    // ── Fórmula del día ─────────────────────────────────────────────────────
    property var formula: null

    function nextFormula() {
        formulaProc.command = ["sh", "-c", "$HOME/.local/bin/formula-of-day --next"];
        formulaProc.running = true;
    }

    Timer {
        interval: 60 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            formulaProc.command = ["sh", "-c", "$HOME/.local/bin/formula-of-day"];
            formulaProc.running = true;
        }
    }

    Process {
        id: formulaProc
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.formula = JSON.parse(text); } catch (e) {}
            }
        }
    }
}
