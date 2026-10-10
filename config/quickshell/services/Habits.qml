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
        { id: "nofap", name: "Sin fap", icon: "self_improvement", type: "streak", cat: "Salud" },
        { id: "nomonster", name: "Sin Monster", icon: "no_drinks", type: "streak", cat: "Salud" },
        { id: "noalcohol", name: "Sin alcohol", icon: "no_bar", type: "streak", cat: "Salud" },
        { id: "nosocial", name: "Sin redes", icon: "phonelink_erase", type: "check", cat: "Salud" },
        { id: "water", name: "Hidratación", icon: "water_drop", type: "count", goal: 8, step: 1, unit: "vasos", cat: "Salud" },
        { id: "sleep", name: "Dormir 7 h", icon: "bedtime", type: "check", cat: "Salud" },
        { id: "sport", name: "Deporte", icon: "fitness_center", type: "check", cat: "Salud" },
        { id: "swim", name: "Natación", icon: "pool", type: "check", cat: "Salud" },
        { id: "reading", name: "Lectura", icon: "menu_book", type: "count", goal: 30, step: 5, unit: "min", cat: "Mente" },
        { id: "study", name: "Estudio", icon: "school", type: "count", goal: 4, step: 1, unit: "pomodoros", auto: "pomodoros", cat: "Mente" },
        { id: "rae", name: "RAE", icon: "spellcheck", type: "check", cat: "Mente", open: "xdg-open https://dle.rae.es" },
        { id: "wotd", name: "Palabra del día", icon: "match_word", type: "check", cat: "Mente", open: "xdg-open https://www.rae.es/palabra-del-dia" },
        { id: "wikipedia", name: "Wikipedia diaria", icon: "travel_explore", type: "check", cat: "Mente", open: "xdg-open https://es.wikipedia.org/wiki/Especial:Aleatoria" },
        { id: "knowledge", name: "Conocimiento diario", icon: "lightbulb", type: "check", cat: "Mente" },
        { id: "journal", name: "Escribir diario", icon: "edit_note", type: "check", cat: "Mente" },
        { id: "gmail", name: "Mirar Gmail", icon: "mail", type: "check", cat: "Comunicación", open: "omarchy-launch-webapp https://mail.google.com" },
        { id: "whatsapp", name: "Mirar WhatsApp", icon: "chat", type: "check", cat: "Comunicación", open: "omarchy-launch-or-focus '^com.rtosta.zapzap$' 'uwsm-app -- zapzap'" },
        { id: "discord", name: "Mirar Discord", icon: "forum", type: "check", cat: "Comunicación", open: "omarchy-launch-or-focus-webapp Discord https://discord.com/channels/@me" },
        { id: "telegram", name: "Mirar Telegram", icon: "send", type: "check", cat: "Comunicación", open: "omarchy-launch-or-focus '^(TelegramDesktop|org.telegram.desktop)$' 'uwsm-app -- Telegram'" },
        { id: "meals", name: "Preparar comidas", icon: "skillet", type: "check", cat: "Organización" },
        { id: "agenda", name: "Agenda: escribir, mirar y organizar", icon: "event_note", type: "check", cat: "Organización" },
        { id: "nextweek", name: "Preparar la semana siguiente", icon: "date_range", type: "check", freq: "weekly", day: 0, cat: "Cada domingo" },
        { id: "pc_laptop", name: "Limpiar y actualizar el portátil", icon: "laptop", type: "check", freq: "weekly", day: 0, cat: "Cada domingo" },
        { id: "pc_desktop", name: "Limpiar y actualizar el sobremesa", icon: "desktop_windows", type: "check", freq: "weekly", day: 0, cat: "Cada domingo" },
        { id: "expenses", name: "Revisar gastos de la semana", icon: "account_balance_wallet", type: "check", freq: "weekly", day: 0, cat: "Cada domingo" },
        { id: "media", name: "Organizar series, películas, libros y teatro", icon: "theaters", type: "check", freq: "monthly", day: 1, cat: "Cada día 1 del mes" },
        { id: "github", name: "Proyectos de GitHub", icon: "code", type: "check", freq: "monthly", day: 1, cat: "Cada día 1 del mes", open: "xdg-open https://github.com/nickhernd?tab=repositories" },
        { id: "bookclubs", name: "Clubes de lectura", icon: "groups", type: "check", freq: "monthly", day: 1, cat: "Cada día 1 del mes" },
        { id: "subscriptions", name: "Revisar suscripciones", icon: "subscriptions", type: "check", freq: "monthly", day: 1, cat: "Cada día 1 del mes" },
        { id: "shave", name: "Depilación", icon: "content_cut", type: "check", cat: "Cuidado personal" },
        { id: "skincare", name: "Skin care", icon: "face", type: "check", cat: "Cuidado personal" },
        { id: "haircare", name: "Hair care", icon: "face_retouching_natural", type: "check", cat: "Cuidado personal" }
    ]
    // Hábitos ordenados por categoría, marcando el primero de cada una (para el título)
    readonly property var grouped: {
        const out = [];
        categories.forEach(c => habits.filter(h => (h.cat || "Otros") === c).forEach((h, i) => out.push(Object.assign({ _first: i === 0, _cat: c }, h))));
        return out;
    }
    readonly property var categories: {
        const out = [];
        habits.forEach(h => { const c = h.cat || "Otros"; if (out.indexOf(c) < 0) out.push(c); });
        return out;
    }

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

    // Semanas de sábado a viernes
    function weekStart(day) {
        const d = new Date(day + "T12:00");
        d.setDate(d.getDate() - (d.getDay() + 1) % 7);
        return Qt.formatDate(d, "yyyy-MM-dd");
    }

    function periodStart(h, day) {
        return h.freq === "weekly" ? weekStart(day) : h.freq === "monthly" ? day.slice(0, 8) + "01" : day;
    }

    function periodEnd(h, day) {
        const s = new Date(periodStart(h, day) + "T12:00");
        if (h.freq === "weekly") s.setDate(s.getDate() + 6);
        else if (h.freq === "monthly") { s.setMonth(s.getMonth() + 1); s.setDate(0); }
        return Qt.formatDate(s, "yyyy-MM-dd");
    }

    // Fecha que cae dentro del periodo i-ésimo hacia atrás (para los puntitos)
    function periodOffset(h, i) {
        const d = new Date();
        if (h.freq === "weekly") d.setDate(d.getDate() - 7 * i);
        else if (h.freq === "monthly") { d.setDate(1); d.setMonth(d.getMonth() - i); }
        else d.setDate(d.getDate() - i);
        return Qt.formatDate(d, "yyyy-MM-dd");
    }

    function doneInPeriod(h, day) {
        const a = periodStart(h, day), b = periodEnd(h, day);
        return Object.keys(data.log).some(k => k >= a && k <= b && !!data.log[k][h.id]);
    }

    // ¿Le toca hoy y no está hecha? (tareas de domingo / día 1)
    function dueToday(h) {
        const now = new Date();
        if (h.freq === "weekly") return now.getDay() === (h.day || 0) && !doneInPeriod(h, today());
        if (h.freq === "monthly") return now.getDate() === (h.day || 1) && !doneInPeriod(h, today());
        return false;
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
        if (h.freq === "weekly" || h.freq === "monthly")
            return doneInPeriod(h, day);
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
            if (!done(h, periodOffset(h, i)))
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
        if (h.freq === "weekly" || h.freq === "monthly") {
            // Tarea periódica: marcar hoy, o desmarcar todo el periodo
            const was = doneInPeriod(h, today());
            const a = periodStart(h, today()), b = periodEnd(h, today());
            mutate(d => {
                if (was)
                    Object.keys(d.log).forEach(k => { if (k >= a && k <= b && d.log[k][h.id]) d.log[k][h.id] = false; });
                else {
                    d.log[today()] = d.log[today()] || {};
                    d.log[today()][h.id] = true;
                }
            });
            return;
        }
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

    // Añade los hábitos por defecto que falten (sin tocar los tuyos), completa
    // categorías/acciones y fija el inicio de las rachas nuevas.
    function ensureStreaks() {
        const ids = (data.habits || []).map(h => h.id);
        const newHabits = defaultHabits.filter(h => ids.indexOf(h.id) < 0);
        const needCat = (data.habits || []).some(h => !h.cat && defaultHabits.find(x => x.id === h.id));
        const missing = habits.concat(newHabits).filter(h => h.type === "streak" && !data.streaks[h.id]);
        if (!newHabits.length && !needCat && !missing.length)
            return;
        mutate(d => {
            d.habits = (d.habits || []).map(h => {
                const def = defaultHabits.find(x => x.id === h.id);
                return def ? Object.assign({}, def, h, { cat: h.cat || def.cat, open: h.open || def.open }) : h;
            });
            // Insertar los nuevos en el orden de los valores por defecto
            newHabits.forEach(h => {
                const idx = defaultHabits.indexOf(h);
                const after = defaultHabits.slice(0, idx).reverse().find(x => d.habits.some(y => y.id === x.id));
                const pos = after ? d.habits.findIndex(y => y.id === after.id) + 1 : d.habits.length;
                d.habits.splice(pos, 0, h);
            });
            d.habits.forEach(h => {
                if (h.type === "streak" && !d.streaks[h.id])
                    d.streaks[h.id] = { start: today(), best: 0, relapses: [] };
            });
        });
    }

    function open(h) {
        if (h.open)
            Quickshell.execDetached(["sh", "-c", h.open]);
        if (h.type === "check" && !value(h.id))
            setValue(h.id, true);
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
