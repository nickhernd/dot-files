pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.colors
import qs.modules.lock
import qs.services as Services

// Tareas de ~/todo.md (líneas "- [ ]" / "- [x]"). Clic en una tarea la marca
// o desmarca; clic en el título abre el archivo en Neovim.
WidgetFrame {
    id: root

    readonly property var items: Services.DesktopWidgets.todos

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("todo", themeId) + "  ·  " + items.filter(t => !t.done).length + " pendientes"
    seal: "事"

    Repeater {
        model: root.items.slice(0, 8)

        Item {
            id: task
            required property var modelData
            width: 300
            height: Math.max(20, label.implicitHeight)

            Glyph {
                id: box
                anchors.top: parent.top
                text: task.modelData.done ? "check_box" : "check_box_outline_blank"
                filled: task.modelData.done
                font.pixelSize: 17
                color: task.modelData.done ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.7)
            }

            Text {
                id: label
                anchors.left: box.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: box.verticalCenter
                text: task.modelData.text
                wrapMode: Text.WordWrap
                font.family: root.st.font
                font.pixelSize: 13
                font.strikeout: task.modelData.done
                color: Colors.withAlpha(Colors.on_surface, task.modelData.done ? 0.45 : 0.9)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.DesktopWidgets.toggleTodo(task.modelData.line)
            }
        }
    }

    Text {
        text: "editar ~/todo.md"
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, edit.containsMouse ? 0.9 : 0.5)

        MouseArea {
            id: edit
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["sh", "-c", "omarchy-launch-tui nvim ~/todo.md"])
        }
    }
}
