pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Batería: carga, consumo en W, tiempo restante, salud, ciclos y perfil de
// energía (clic para cambiarlo).
WidgetFrame {
    id: root

    readonly property var b: Services.DeviceInfo.battery
    readonly property bool low: !!b && b.capacity <= 20 && b.status !== "Charging"
    readonly property var profiles: [
        { id: "power-saver", label: "ahorro" },
        { id: "balanced", label: "equilibrado" },
        { id: "performance", label: "rendimiento" }
    ]

    function remaining() {
        if (!b)
            return "";
        if (b.status === "Full" || (b.ac && b.status !== "Charging"))
            return "enchufado";
        if (b.minutes === null)
            return b.status === "Charging" ? "cargando" : "calculando…";
        const t = Math.floor(b.minutes / 60) + "h " + String(b.minutes % 60).padStart(2, "0") + "m";
        return b.status === "Charging" ? "llena en " + t : "quedan " + t;
    }

    visible: !b || b.present
    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("battery", themeId)
    seal: "電"

    Row {
        spacing: 14

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            text: !root.b ? "battery_unknown" : root.b.status === "Charging" ? "battery_charging_full" : root.b.capacity > 85 ? "battery_full" : root.b.capacity > 55 ? "battery_5_bar" : root.b.capacity > 30 ? "battery_3_bar" : "battery_1_bar"
            font.pixelSize: 38
            weight: 300
            color: root.low ? Colors.error : Colors[root.st.accentRole]
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.b ? root.b.capacity + "%" : "--%"
                font.family: root.st.display || root.st.font
                font.pixelSize: 32
                font.weight: Font.Light
                color: root.low ? Colors.error : Colors.on_surface
            }

            Text {
                text: root.remaining() + (root.b && root.b.watts > 0 ? "  ·  " + root.b.watts + " W" : "")
                font.family: root.st.font
                font.pixelSize: 12
                color: Colors.withAlpha(Colors.on_surface, 0.7)
            }
        }
    }

    Text {
        text: root.b ? "salud " + Math.min(100, root.b.health) + "%  ·  " + root.b.cycles + " ciclos" : ""
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, 0.6)
    }

    Row {
        spacing: 12

        Repeater {
            model: root.profiles

            Text {
                id: prof
                required property var modelData
                readonly property bool on: root.b && root.b.profile === modelData.id
                text: modelData.label
                font.family: root.st.font
                font.pixelSize: 12
                font.underline: on
                color: on ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, pm.containsMouse ? 0.9 : 0.5)

                MouseArea {
                    id: pm
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.DeviceInfo.setProfile(prof.modelData.id)
                }
            }
        }
    }
}
