pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Últimas notificaciones (services/Notification): app, título, texto y hace
// cuánto. Clic en una: descartarla. "limpiar": descartarlas todas.
WidgetFrame {
    id: root

    readonly property var items: Services.Notification.history.slice().reverse().slice(0, 5)

    function ago(n) {
        const t = n.timeStr;
        return t === "now" ? "ahora" : "hace " + t;
    }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("notifications", themeId) + (Services.Notification.history.length ? "  ·  " + Services.Notification.history.length : "")
    seal: "知"

    Text {
        visible: root.items.length === 0
        text: "sin notificaciones"
        font.family: root.st.font
        font.pixelSize: 13
        font.italic: true
        color: Colors.withAlpha(Colors.on_surface, 0.5)
    }

    Repeater {
        model: root.items

        Item {
            id: n
            required property var modelData
            width: 320
            height: Math.max(38, col.implicitHeight + 4)

            Rectangle {
                id: bar
                width: 2
                height: parent.height - 6
                anchors.verticalCenter: parent.verticalCenter
                radius: 1
                color: n.modelData.urgency === 2 ? Colors.error : Colors[root.st.accentRole]
            }

            Column {
                id: col
                anchors.left: bar.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Item {
                    width: parent.width
                    height: head.implicitHeight

                    Text {
                        id: head
                        anchors.left: parent.left
                        anchors.right: when.left
                        anchors.rightMargin: 8
                        text: (n.modelData.appName ? n.modelData.appName.toLowerCase() + "  ·  " : "") + n.modelData.summary
                        elide: Text.ElideRight
                        font.family: root.st.font
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.strikeout: ma.containsMouse
                        color: Colors.on_surface
                    }

                    Text {
                        id: when
                        anchors.right: parent.right
                        text: root.ago(n.modelData)
                        font.family: root.st.mono
                        font.pixelSize: 10
                        color: Colors.withAlpha(Colors.on_surface, 0.5)
                    }
                }

                Text {
                    width: parent.width
                    visible: text.length > 0
                    text: n.modelData.body.replace(/<[^>]*>/g, "").replace(/\n/g, " ")
                    elide: Text.ElideRight
                    font.family: root.st.font
                    font.pixelSize: 12
                    color: Colors.withAlpha(Colors.on_surface, 0.65)
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: n.modelData.notification.dismiss()
            }
        }
    }

    Text {
        visible: Services.Notification.history.length > 0
        text: "limpiar"
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, cl.containsMouse ? 0.9 : 0.45)

        MouseArea {
            id: cl
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.Notification.history.slice().forEach(x => x.notification.dismiss())
        }
    }
}
