pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

// Tracker de hábitos: rachas (sin fap, sin Monster...), contadores diarios
// (agua, lectura...), casillas (deporte, dormir...), libros con marcapáginas
// y pomodoros por día. Datos: ~/.local/share/tracker/tracker.json
// Copia cifrada en ~/dot-files/data/tracker/ (~/.local/bin/tracker-backup).
Singleton {
    id: root

    readonly property string path: Quickshell.env("HOME") + "/.local/share/tracker/tracker.json"

    // Hábitos por defecto (se pueden editar en el JSON)
    readonly property var defaultHabits: [
        { id: "nofap", name: "Sin fap", icon: "self_improvement", type: "streak" },
        { id: "nomonster", name: "Sin Monster", icon: "no_drinks", type: "streak" },
        { id: "water", name: "Hidratación", icon: "water_drop", type: "count", goal: 8, step: 1, unit: "vasos" },
        { id: "reading", name: "Lectura", icon: "menu_book", type: "count", goal: 30, step: 5, unit: "min" },
        { id: "sport", name: "Deporte", icon: "fitness_center", type: "check" },
        { id: "sleep", name: "Dormir 7 h", icon: "bedtime", type: "check" },
        { id: "study", name: "Estudio", icon: "school", type: "count", goal: 4, step: 1, unit: "pomodoros", auto: "pomodoros" }
    ]

    property var data: ({ version: 1, habits: defaultHabits, streaks: {}, log: {}, books: [] })
    property bool loaded: false
    readonly property var habits: data.habits || defaultHabits

    function today() {
        return Qt.formatDate(new Date(), "yyyy-MM-dd");
    }

    function dayOffset(n) {
        const d = new Date();
        d.setDate(d.getDate() - n);
        return Qt.formatDate(d, "yyyy-MM-dd");
    }

    function daysBetween(a, b) {
        return Math.round((new Date(b + "T12:00") - new Date(a + "T12:00")) / 86400000);
    }

    // ── Lectura de valores ──
    function value(id, day) {
        const l = data.log[day || today()];
        if (!l)
            return 0;
        const h = habits.find(x => x.id === id);
        if (h && h.auto === "pomodoros")
            return l.pomodoros || 0;
        return l[id] || 0;
    }

    function done(h, day) {
        if (h.type === "check")
            return !!value(h.id, day);
        if (h.type === "count")
            return value(h.id, day) >= (h.goal || 1);
        if (h.type === "streak")
            return streakDays(h.id) >= daysBetween(day, today()) && !relapsedOn(h.id, day);
        return false;
    }

    function streak(id) {
        return data.streaks[id] || { start: today(), best: 0, relapses: [] };
    }

    function streakDays(id) {
        return Math.max(0, daysBetween(streak(id).start, today()));
    }

    function relapsedOn(id, day) {
        return (streak(id).relapses || []).indexOf(day) >= 0;
    }

    // Racha actual (días seguidos cumpliendo) para hábitos diarios
    function dailyStreak(h) {
        if (h.type === "streak")
            return streakDays(h.id);
        let n = 0;
        for (let i = done(h, today()) ? 0 : 1; i < 365; i++) {
            if (!done(h, dayOffset(i)))
                break;
            n++;
        }
        return n;
    }

    // ── Escritura ──
    function mutate(fn) {
        const d = JSON.parse(JSON.stringify(data));
        fn(d);
        data = d;
        saveTimer.restart();
    }

    function setValue(id, v) {
        mutate(d => {
            const t = today();
            d.log[t] = d.log[t] || {};
            d.log[t][id] = v;
        });
    }

    function increment(h, sign) {
        setValue(h.id, Math.max(0, value(h.id) + sign * (h.step || 1)));
    }

    function toggle(h) {
        setValue(h.id, !value(h.id));
    }

    function relapse(id) {
        mutate(d => {
            const s = d.streaks[id] || { start: today(), best: 0, relapses: [] };
            s.best = Math.max(s.best || 0, daysBetween(s.start, today()));
            s.relapses = (s.relapses || []).concat([today()]);
            s.start = today();
            d.streaks[id] = s;
        });
    }

    // Fija la fecha de inicio de las rachas nuevas (si no, contarían "desde hoy" cada día)
    function ensureStreaks() {
        const missing = habits.filter(h => h.type === "streak" && !data.streaks[h.id]);
        if (missing.length)
            mutate(d => missing.forEach(h => d.streaks[h.id] = { start: today(), best: 0, relapses: [] }));
    }

    function addPomodoro(minutes) {
        mutate(d => {
            const t = today();
            d.log[t] = d.log[t] || {};
            d.log[t].pomodoros = (d.log[t].pomodoros || 0) + 1;
            d.log[t].focusMinutes = (d.log[t].focusMinutes || 0) + minutes;
        });
    }

    // ── Libros (marcapáginas) ──
    function addBook(title, total) {
        if (!title.trim())
            return;
        mutate(d => {
            d.books = d.books || [];
            d.books.push({ title: title.trim(), page: 0, total: Math.max(1, total || 300), updated: today() });
        });
    }

    function setPage(i, page) {
        mutate(d => {
            const b = d.books[i];
            b.page = Math.max(0, Math.min(b.total, page));
            b.updated = today();
            if (b.page >= b.total && !b.finished)
                b.finished = today();
        });
    }

    function removeBook(i) {
        mutate(d => d.books.splice(i, 1));
    }

    // ── Persistencia ──
    FileView {
        id: file
        path: root.path
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const j = JSON.parse(text());
                j.habits = j.habits || root.defaultHabits;
                j.streaks = j.streaks || {};
                j.log = j.log || {};
                j.books = j.books || [];
                root.data = j;
                root.ensureStreaks();
            } catch (e) {}
            root.loaded = true;
        }
        onLoadFailed: {
            root.loaded = true;
            root.ensureStreaks();
            saveTimer.restart();
        }
    }

    Timer {
        id: saveTimer
        interval: 800
        onTriggered: {
            Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/share/tracker"]);
            file.setText(JSON.stringify(root.data, null, 1));
            backupTimer.restart();
        }
    }

    // Copia cifrada a los dot-files 2 min después del último cambio
    Timer {
        id: backupTimer
        interval: 2 * 60 * 1000
        onTriggered: Quickshell.execDetached(["sh", "-c", "$HOME/.local/bin/tracker-backup --quiet"])
    }

    IpcHandler {
        target: "tracker"
        function inc(id: string): void { const h = root.habits.find(x => x.id === id); if (h) root.increment(h, 1); }
        function dec(id: string): void { const h = root.habits.find(x => x.id === id); if (h) root.increment(h, -1); }
        function check(id: string): void { const h = root.habits.find(x => x.id === id); if (h) root.toggle(h); }
        function backup(): void { backupTimer.stop(); Quickshell.execDetached(["sh", "-c", "$HOME/.local/bin/tracker-backup"]); }
    }
}
