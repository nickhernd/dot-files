pragma Singleton
import QtQuick
import Quickshell

// How desktop widgets look under each desktop theme ("" = no theme). Widgets
// read a token set with `of(themeId)` and draw their frame, type, labels,
// meters and artwork from it; per-widget wording lives in `words`.
//   frame: card | chamfer | console | glass | bare | scroll
//   bar:   line | segments | ascii | orbit | hairline | brush
//   art:   rounded | chamfer | square | circle | soft | seal
Singleton {
    readonly property var styles: ({
        "": { frame: "card", font: "", display: "", mono: "JetBrainsMono Nerd Font", weight: Font.Normal, labelCase: "none", labelSpacing: 0.4, labelRole: "on_surface_variant", accentRole: "primary", bar: "line", art: "rounded", pad: 18 },
        hud: { frame: "chamfer", font: "JetBrainsMono Nerd Font", display: "Orbitron", mono: "JetBrainsMono Nerd Font", weight: Font.Medium, labelCase: "upper", labelSpacing: 3.5, labelRole: "primary", accentRole: "primary", bar: "segments", art: "chamfer", pad: 18 },
        terminal: { frame: "console", font: "Iosevka Nerd Font", display: "Iosevka Nerd Font", mono: "Iosevka Nerd Font", weight: Font.Normal, labelCase: "lower", labelSpacing: 0.5, labelRole: "primary", accentRole: "primary", bar: "ascii", art: "square", pad: 16 },
        cosmos: { frame: "glass", font: "Adwaita Sans", display: "ESPACION", mono: "JetBrainsMono Nerd Font", weight: Font.Normal, labelCase: "upper", labelSpacing: 3, labelRole: "on_surface_variant", accentRole: "primary", bar: "orbit", art: "circle", pad: 20 },
        zen: { frame: "bare", font: "Adwaita Sans", display: "Adwaita Sans", mono: "Adwaita Sans", weight: Font.Light, labelCase: "lower", labelSpacing: 0.6, labelRole: "on_surface_variant", accentRole: "primary", bar: "hairline", art: "soft", pad: 8 },
        xianxia: { frame: "scroll", font: "Noto Serif", display: "Noto Serif", mono: "Noto Serif", cjk: "Noto Serif CJK SC", weight: Font.Normal, labelCase: "none", labelSpacing: 1, labelRole: "tertiary", accentRole: "tertiary", bar: "brush", art: "seal", pad: 18 }
    })

    function of(themeId) {
        return styles[themeId] ?? styles[""];
    }

    // Per theme wording: words[widget][theme] (falls back to "").
    readonly property var words: ({
        music: { "": "Now playing", hud: "Now playing", terminal: "~/music $ playerctl status", cosmos: "Transmission", zen: "sonando", xianxia: "琴音 · Qin melody" },
        musicIdle: { "": "Nothing playing", hud: "No signal", terminal: "no players found", cosmos: "Silence between stars", zen: "en silencio", xianxia: "琴弦静 · The strings are still" },
        sysmon: { "": "System", hud: "System status", terminal: "~ $ top -b -n1", cosmos: "Ship systems", zen: "", xianxia: "气海 · Sea of Qi" },
        quote: { "": "Dad joke", hud: "Side quest", terminal: "~ $ fortune", cosmos: "Incoming signal", zen: "una idea", xianxia: "箴言 · Proverb" },
        cpu: { "": "CPU", hud: "CPU", terminal: "cpu", cosmos: "Reactor", zen: "cpu", xianxia: "灵力 Spirit" },
        ram: { "": "Memory", hud: "MEM", terminal: "mem", cosmos: "Memory core", zen: "memoria", xianxia: "神识 Sense" },
        temp: { "": "Temperature", hud: "TEMP", terminal: "tmp", cosmos: "Hull temp", zen: "temperatura", xianxia: "丹火 Pill fire" },
        disk: { "": "Disk", hud: "DISK", terminal: "dsk", cosmos: "Cargo", zen: "disco", xianxia: "储物 Storage" },
        weather: { "": "Tiempo", hud: "Weather", terminal: "~ $ curl wttr.in", cosmos: "Atmosphere", zen: "el tiempo", xianxia: "天象 · Heavens" },
        dev: { "": "Dev", hud: "Dev ops", terminal: "~ $ dev-status", cosmos: "Engineering", zen: "desarrollo", xianxia: "工坊 · Workshop" },
        todo: { "": "Tareas", hud: "Quests", terminal: "~ $ cat todo.md", cosmos: "Mission log", zen: "tareas", xianxia: "任务 · Tasks" },
        formula: { "": "Fórmula del día", hud: "Formula", terminal: "~ $ formula", cosmos: "Equation", zen: "fórmula del día", xianxia: "式 · Formula" },
        deadlines: { "": "Entregas", hud: "Deadlines", terminal: "~ $ cat deadlines.md", cosmos: "Countdown", zen: "entregas", xianxia: "期 · Deadlines" },
        coding: { "": "Tiempo programando", hud: "Focus time", terminal: "~ $ uptime --code", cosmos: "Flight hours", zen: "tiempo de hoy", xianxia: "修炼 · Practice" },
        pomodoro: { "": "Pomodoro", hud: "Pomodoro", terminal: "~ $ pomodoro", cosmos: "Burn timer", zen: "pomodoro", xianxia: "時 · Hour" },
        battery: { "": "Batería", hud: "Power", terminal: "~ $ upower", cosmos: "Power cells", zen: "batería", xianxia: "電 · Power" },
        network: { "": "Red", hud: "Network", terminal: "~ $ ip a", cosmos: "Comms", zen: "red", xianxia: "網 · Net" },
        security: { "": "Seguridad", hud: "Defense", terminal: "~ $ sec-status", cosmos: "Shields", zen: "seguridad", xianxia: "盾 · Shield" },
        news: { "": "Noticias", hud: "Intel", terminal: "~ $ curl hn", cosmos: "Transmissions", zen: "noticias · el país", xianxia: "報 · News" },
        notifications: { "": "Notificaciones", hud: "Alerts", terminal: "~ $ journalctl -f", cosmos: "Incoming", zen: "notificaciones", xianxia: "知 · Messages" },
        processes: { "": "Procesos", hud: "Processes", terminal: "~ $ ps aux", cosmos: "Crew", zen: "procesos", xianxia: "程 · Processes" },
        maintenance: { "": "Mantenimiento", hud: "Maintenance", terminal: "~ $ du -sh", cosmos: "Maintenance", zen: "mantenimiento", xianxia: "掃 · Cleaning" },
        uptime: { "": "Up", hud: "UPTIME", terminal: "up", cosmos: "Mission time", zen: "encendido", xianxia: "闭关 Seclusion" }
    })

    function word(key, themeId) {
        const w = words[key];
        return w ? (w[themeId] ?? w[""]) : "";
    }

    function label(text, style) {
        return style.labelCase === "upper" ? text.toUpperCase() : style.labelCase === "lower" ? text.toLowerCase() : text;
    }
}
