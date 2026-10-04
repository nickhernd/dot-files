pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

// Batería (~/.local/bin/battery-status) y red (~/.local/bin/net-info +
// velocidad en vivo desde /proc/net/dev) para los widgets del escritorio.
Singleton {
    id: root

    // ── Batería ──
    property var battery: null

    Timer {
        interval: 15000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: batProc.running = true
    }

    Process {
        id: batProc
        command: ["sh", "-c", "$HOME/.local/bin/battery-status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.battery = JSON.parse(text); } catch (e) {}
            }
        }
    }

    function setProfile(p) {
        Quickshell.execDetached(["powerprofilesctl", "set", p]);
        batProc.running = true;
    }

    // ── Red ──
    property var net: null
    property real rxRate: 0                 // bytes/s
    property real txRate: 0
    property var rxHistory: []              // últimos 40 valores (bytes/s)
    property var txHistory: []
    property real _rx: -1
    property real _tx: -1
    property real _t: 0

    Timer {
        interval: 30000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        command: ["sh", "-c", "$HOME/.local/bin/net-info"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.net = JSON.parse(text); } catch (e) {}
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: devProc.running = true
    }

    Process {
        id: devProc
        command: ["cat", "/proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: root.parseDev(text)
        }
    }

    function parseDev(t) {
        {
            const iface = root.net ? root.net.iface : "";
            let rx = 0, tx = 0;
            t.split("\n").forEach(l => {
                const m = l.trim().match(/^([^:]+):\s*(.*)$/);
                if (!m || m[1] === "lo")
                    return;
                if (iface && m[1] !== iface)
                    return;
                const f = m[2].split(/\s+/).map(Number);
                rx += f[0];
                tx += f[8];
            });
            const now = Date.now() / 1000;
            if (root._rx >= 0 && now > root._t) {
                const dt = now - root._t;
                root.rxRate = Math.max(0, (rx - root._rx) / dt);
                root.txRate = Math.max(0, (tx - root._tx) / dt);
                root.rxHistory = root.rxHistory.slice(-39).concat([root.rxRate]);
                root.txHistory = root.txHistory.slice(-39).concat([root.txRate]);
            }
            root._rx = rx;
            root._tx = tx;
            root._t = now;
        }
    }

    function human(bps) {
        if (bps >= 1048576)
            return (bps / 1048576).toFixed(1) + " MB/s";
        if (bps >= 1024)
            return Math.round(bps / 1024) + " KB/s";
        return Math.round(bps) + " B/s";
    }

    // ── Seguridad (~/.local/bin/sec-status), cada 10 min ──
    property var security: null

    Timer {
        interval: 10 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: secProc.running = true
    }

    Process {
        id: secProc
        command: ["sh", "-c", "$HOME/.local/bin/sec-status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.security = JSON.parse(text); } catch (e) {}
            }
        }
    }

    function refreshSecurity() {
        secProc.running = true;
    }

    // ── Noticias: portada de El País, cada 15 min ──
    property var news: []

    Timer {
        interval: 15 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: newsProc.running = true
    }

    Process {
        id: newsProc
        command: ["sh", "-c", "$HOME/.local/bin/news-top 6"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const n = JSON.parse(text);
                    if (n.length)
                        root.news = n;
                } catch (e) {}
            }
        }
    }

    // ── Procesos: top 6 por CPU o RAM, cada 3 s ──
    property var procs: []
    property string procSort: "cpu"         // cpu | mem

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: procProc.running = true
    }

    Process {
        id: procProc
        command: ["sh", "-c", "ps -eo pid=,pcpu=,pmem=,comm= --sort=-" + (root.procSort === "mem" ? "pmem" : "pcpu") + " | head -5"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.procs = text.trim().split("\n").filter(l => l.trim()).map(l => {
                    const f = l.trim().split(/\s+/);
                    return { pid: +f[0], cpu: +f[1], mem: +f[2], name: f.slice(3).join(" ") };
                });
            }
        }
    }

    function setProcSort(k) {
        procSort = k;
        procProc.running = true;
    }

    function killProc(pid) {
        Quickshell.execDetached(["kill", "-TERM", String(pid)]);
        procProc.running = true;
    }

    // ── Mantenimiento (~/.local/bin/maint-status), cada 30 min ──
    property var maint: null

    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: maintProc.running = true
    }

    Process {
        id: maintProc
        command: ["sh", "-c", "$HOME/.local/bin/maint-status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.maint = JSON.parse(text); } catch (e) {}
            }
        }
    }

    function refreshMaint() {
        maintProc.running = true;
    }

    function cleanUp() {
        Quickshell.execDetached(["sh", "-c", "uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.maint -e $HOME/.local/bin/maint-clean"]);
    }

    // ── Papers de arXiv (~/.local/bin/arxiv-top), cada hora ──
    property var papers: []
    property string arxivCat: "todo"        // seguridad | sistemas | mates | todo

    Timer {
        interval: 60 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: arxivProc.running = true
    }

    Process {
        id: arxivProc
        command: ["sh", "-c", "$HOME/.local/bin/arxiv-top " + root.arxivCat + " 5"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const p = JSON.parse(text);
                    if (p.length)
                        root.papers = p;
                } catch (e) {}
            }
        }
    }

    function setArxivCat(c) {
        arxivCat = c;
        arxivProc.running = true;
    }
}
