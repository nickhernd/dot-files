pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.colors
import qs.modules.lock
import qs.services as Services

// Estado de seguridad del sistema (~/.local/bin/sec-status): cortafuegos,
// puertos expuestos, CVEs (arch-audit), actualizaciones, sudo fallidos,
// cifrado y SSH. En color lo que conviene revisar. Clic: refrescar.
WidgetFrame {
    id: root

    readonly property var s: Services.DeviceInfo.security
    function n(v) { return v === null || v === undefined ? "—" : String(v) }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("security", themeId)
    seal: "盾"

    Repeater {
        model: !root.s ? [] : [
            { icon: "local_fire_department", label: "cortafuegos", value: root.s.firewall || "inactivo", bad: !root.s.firewall },
            { icon: "lan", label: "puertos expuestos", value: root.s.ports.exposed.length + " / " + root.s.ports.total, bad: root.s.ports.exposed.length > 4 },
            { icon: "bug_report", label: "paquetes con CVE", value: root.s.cves === null ? "instala arch-audit" : String(root.s.cves), bad: root.s.cves > 0 },
            { icon: "system_update", label: "actualizaciones", value: root.n(root.s.updates) + (root.s.daysSinceUpdate !== null ? "  ·  hace " + root.s.daysSinceUpdate + " d" : ""), bad: root.s.updates > 20 || root.s.daysSinceUpdate > 14 },
            { icon: "key_off", label: "sudo fallidos (24 h)", value: root.n(root.s.sudoFailures), bad: root.s.sudoFailures > 0 },
            { icon: "lock", label: "disco cifrado", value: root.s.encrypted ? "sí (LUKS)" : "no", bad: !root.s.encrypted },
            { icon: "terminal", label: "servidor ssh", value: root.s.sshd ? "activo" : "apagado", bad: false }
        ]

        Item {
            id: row
            required property var modelData
            width: 280
            height: 21

            Glyph {
                id: ic
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.icon
                font.pixelSize: 16
                color: row.modelData.bad ? Colors.error : Colors.withAlpha(Colors.on_surface, 0.6)
            }

            Text {
                anchors.left: ic.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: WidgetStyle.label(row.modelData.label, root.st)
                font.family: root.st.font
                font.pixelSize: 12
                color: Colors.withAlpha(Colors.on_surface, 0.78)
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.value
                font.family: root.st.mono
                font.pixelSize: 12
                font.weight: Font.Medium
                color: row.modelData.bad ? Colors.error : Colors.on_surface
            }
        }
    }

    Text {
        visible: !!root.s && root.s.ports.exposed.length > 0
        width: 280
        elide: Text.ElideRight
        text: root.s ? "escuchando: " + root.s.ports.exposed.join("  ") : ""
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, 0.55)
    }

    Text {
        text: "actualizar"
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, rf.containsMouse ? 0.9 : 0.45)

        MouseArea {
            id: rf
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.DeviceInfo.refreshSecurity()
        }
    }
}
