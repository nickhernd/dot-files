pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.colors
import qs.modules.lock
import qs.services as Services

// Entregas y exámenes de ~/deadlines.md con cuenta atrás. ≤3 días en color.
WidgetFrame {
    id: root

    readonly property var items: Services.Productivity.deadlines
    readonly property var months: ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]

    function when(d) {
        return d === 0 ? "hoy" : d === 1 ? "mañana" : d === -1 ? "ayer" : "en " + d + " días";
    }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("deadlines", themeId)
    seal: "期"

    Text {
        visible: root.items.length === 0
        text: "nada pendiente · añade líneas a ~/deadlines.md"
        font.family: root.st.font
        font.pixelSize: 12
        color: Colors.withAlpha(Colors.on_surface, 0.6)
    }

    Repeater {
        model: root.items.slice(0, 6)

        Item {
            id: dl
            required property var modelData
            readonly property bool urgent: modelData.days <= 3
            width: 320
            height: 34

            Column {
                id: dateCol
                width: 38
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dl.modelData.date.getDate()
                    font.family: root.st.display || root.st.font
                    font.pixelSize: 18
                    font.weight: Font.Light
                    color: dl.urgent ? Colors[root.st.accentRole] : Colors.on_surface
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.months[dl.modelData.date.getMonth()]
                    font.family: root.st.font
                    font.pixelSize: 10
                    color: Colors.withAlpha(Colors.on_surface, 0.6)
                }
            }

            Text {
                anchors.left: dateCol.right
                anchors.leftMargin: 12
                anchors.right: badge.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: dl.modelData.text + (dl.modelData.time ? "  ·  " + dl.modelData.time : "")
                elide: Text.ElideRight
                font.family: root.st.font
                font.pixelSize: 13
                color: Colors.withAlpha(Colors.on_surface, 0.9)
            }

            Text {
                id: badge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.when(dl.modelData.days)
                font.family: root.st.mono
                font.pixelSize: 11
                font.weight: dl.urgent ? Font.DemiBold : Font.Normal
                color: dl.urgent ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.6)
            }
        }
    }

    Text {
        text: "editar ~/deadlines.md"
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, ed.containsMouse ? 0.9 : 0.5)

        MouseArea {
            id: ed
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["sh", "-c", "omarchy-launch-tui nvim ~/deadlines.md"])
        }
    }
}
