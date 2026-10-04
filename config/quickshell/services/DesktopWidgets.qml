pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

// Desktop widgets (modules/desktopwidgets): which are on and where they sit.
// A position is stored as a fraction of the free space on the screen
// (0 = left/top edge, 1 = right/bottom edge), so widgets stay on screen and
// keep their place across resolutions. The visualizer keeps its own settings
// (services/CavaWidget.qml); here it is only listed and switched.
//
// Settings: ~/.config/quickshell/desktopwidgets.json.
Singleton {
    id: root

    readonly property var widgets: [
        { id: "clock", name: "Clock", icon: "schedule", description: "The theme's own clock face", x: 0.02, y: 0.03 },
        { id: "weather", name: "Tiempo", icon: "partly_cloudy_day", description: "El tiempo y previsión de 3 días", x: 0.02, y: 0.36 },
        { id: "security", name: "Seguridad", icon: "shield", description: "Cortafuegos, puertos, CVEs y actualizaciones", x: 0.02, y: 0.71 },
        { id: "todo", name: "Tareas", icon: "checklist", description: "Tareas de ~/todo.md", x: 0.02, y: 0.60 },
        { id: "formula", name: "Fórmula del día", icon: "function", description: "Una fórmula o teorema cada día", x: 0.035, y: 0.955 },
        { id: "news", name: "Noticias", icon: "newspaper", description: "Portada de El País", x: 0.5, y: 0.04 },
        { id: "deadlines", name: "Entregas", icon: "event", description: "Entregas y exámenes de ~/deadlines.md", x: 0.5, y: 0.04 },
        { id: "coding", name: "Tiempo programando", icon: "code", description: "Tiempo activo hoy y últimos 7 días", x: 0.5, y: 0.48 },
        { id: "pomodoro", name: "Pomodoro", icon: "timer", description: "Temporizador de foco 25/5", x: 0.5, y: 0.97 },
        { id: "notifications", name: "Notificaciones", icon: "notifications", description: "Últimas notificaciones", x: 0.79, y: 0.04 },
        { id: "processes", name: "Procesos", icon: "memory", description: "Procesos que más consumen", x: 0.215, y: 0.33 },
        { id: "maintenance", name: "Mantenimiento", icon: "cleaning_services", description: "Espacio recuperable y limpieza", x: 0.215, y: 0.74 },
        { id: "music", name: "Music player", icon: "music_note", description: "Now playing, with controls", x: 0.98, y: 0.03 },
        { id: "sysmon", name: "System monitor", icon: "monitoring", description: "CPU, memory, temperature and disk", x: 0.98, y: 0.22 },
        { id: "battery", name: "Batería", icon: "battery_full", description: "Carga, consumo, salud y perfil", x: 0.98, y: 0.44 },
        { id: "network", name: "Red", icon: "network_check", description: "Velocidad, IPs y VPN", x: 0.98, y: 0.68 },
        { id: "dev", name: "Dev", icon: "terminal", description: "Docker, repos git y GitHub", x: 0.98, y: 0.995 },
        { id: "quote", name: "Frase", icon: "format_quote", description: "Una frase nueva cada diez minutos", x: 0.02, y: 0.98 },
        { id: "cava", name: "Visualizer", icon: "graphic_eq", description: "Cava spectrum of what's playing" }
    ]

    readonly property var defaults: ({ clock: true, music: true, sysmon: true, weather: true, dev: true, formula: true, deadlines: false, todo: false, security: true, news: true, notifications: true, processes: true, maintenance: true, coding: true, pomodoro: true, battery: true, network: true })

    function info(id) {
        return widgets.find(w => w.id === id);
    }

    function enabled(id) {
        if (id === "cava")
            return CavaWidget.enabled;
        const v = adapter.on[id];
        return v === undefined ? (defaults[id] ?? false) : v;
    }

    function setEnabled(id, on) {
        if (id === "cava") {
            CavaWidget.enabled = on;
            CavaWidget.save();
            return;
        }
        const next = Object.assign({}, adapter.on);
        next[id] = on;
        adapter.on = next;
    }

    function toggle(id) {
        setEnabled(id, !enabled(id));
    }

    // { x, y } fractions.
    function pos(id) {
        const p = adapter.positions[id];
        const w = info(id);
        return p ? p : { x: w ? w.x : 0, y: w ? w.y : 0 };
    }

    function setPos(id, x, y) {
        const next = Object.assign({}, adapter.positions);
        next[id] = { x: Math.max(0, Math.min(1, x)), y: Math.max(0, Math.min(1, y)) };
        adapter.positions = next;
    }

    function resetPositions() {
        adapter.positions = ({});
        CavaWidget.posX = 40;
        CavaWidget.posY = 880;
        CavaWidget.save();
    }

    // ── Dad jokes (the quote widget), fetched only while it's on ────────────
    property string joke: ""

    function refreshJoke() {
        jokeProc.running = true;
    }

    Timer {
        interval: 10 * 60 * 1000
        running: root.enabled("quote")
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshJoke()
    }

    Process {
        id: jokeProc
        // Frases en español (una por línea) en quotes/frases.txt
        command: ["shuf", "-n", "1", Quickshell.shellDir + "/quotes/frases.txt"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                if (t)
                    root.joke = t;
            }
        }
    }

    // ── El tiempo (wttr.in), refrescado cada 20 min mientras el widget está on ──
    property var weather: null

    Timer {
        interval: 20 * 60 * 1000
        running: root.enabled("weather")
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    Process {
        id: weatherProc
        command: ["curl", "-s", "-m", "15", "https://wttr.in/?format=j1&lang=es"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    const c = j.current_condition[0];
                    root.weather = {
                        area: j.nearest_area[0].areaName[0].value,
                        temp: c.temp_C,
                        feels: c.FeelsLikeC,
                        humidity: c.humidity,
                        wind: c.windspeedKmph,
                        code: c.weatherCode,
                        desc: (c.lang_es && c.lang_es[0].value) || c.weatherDesc[0].value,
                        days: j.weather.map(d => ({ date: d.date, max: d.maxtempC, min: d.mintempC, code: d.hourly[4].weatherCode }))
                    };
                } catch (e) {}
            }
        }
    }

    // ── Dev (~/.local/bin/dev-status), cada 2 min ──
    property var dev: null

    Timer {
        interval: 2 * 60 * 1000
        running: root.enabled("dev")
        repeat: true
        triggeredOnStart: true
        onTriggered: devProc.running = true
    }

    Process {
        id: devProc
        command: ["sh", "-c", "$HOME/.local/bin/dev-status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.dev = JSON.parse(text); } catch (e) {}
            }
        }
    }

    // ── Tareas (~/todo.md) ──
    property var todos: []

    FileView {
        id: todoFile
        path: Quickshell.env("HOME") + "/todo.md"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const out = [];
            text().split("\n").forEach((l, i) => {
                const m = l.match(/^\s*[-*] \[( |x|X)\] (.*)$/);
                if (m) out.push({ line: i + 1, done: m[1] !== " ", text: m[2] });
            });
            out.sort((a, b) => a.done - b.done);
            root.todos = out;
        }
    }

    function toggleTodo(line) {
        toggleProc.command = ["sed", "-i", "-E", line + "{s/\\[ \\]/[x]/;t;s/\\[[xX]\\]/[ ]/}", Quickshell.env("HOME") + "/todo.md"];
        toggleProc.running = true;
    }

    Process {
        id: toggleProc
    }

    // ── Settings ─────────────────────────────────────────────────────────────
    Timer {
        id: writeTimer
        interval: 150
        onTriggered: settingsFile.writeAdapter()
    }

    FileView {
        id: settingsFile
        path: Quickshell.env("HOME") + "/.config/quickshell/desktopwidgets.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeTimer.restart()

        adapter: JsonAdapter {
            id: adapter
            property var on: ({})
            property var positions: ({})
        }
    }
}
