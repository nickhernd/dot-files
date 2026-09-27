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
}
