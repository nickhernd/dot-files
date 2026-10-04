pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Espacio recuperable (~/.local/bin/maint-status) y botón de limpieza guiada
// (~/.local/bin/maint-clean, pregunta antes de cada paso).
WidgetFrame {
    id: root

    readonly property var m: Services.DeviceInfo.maint

    function size(kb) {
        if (kb >= 1048576) return (kb / 1048576).toFixed(1) + " GB";
        if (kb >= 1024) return Math.round(kb / 1024) + " MB";
        return kb + " KB";
    }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("maintenance", themeId)
    seal: "掃"

    Repeater {
        model: !root.m ? [] : [
            { icon: "inventory_2", label: "caché de pacman", value: root.size(root.m.pacmanCacheKB), warn: root.m.pacmanCacheKB > 3145728 },
            { icon: "build", label: "caché de yay (AUR)", value: root.size(root.m.yayCacheKB), warn: root.m.yayCacheKB > 2097152 },
            { icon: "link_off", label: "paquetes huérfanos", value: String(root.m.orphans), warn: root.m.orphans > 0 },
            { icon: "delete", label: "papelera", value: root.size(root.m.trashKB), warn: root.m.trashKB > 1048576 },
            { icon: "description", label: "logs del sistema", value: root.m.journal, warn: false },
            { icon: "deployed_code", label: "docker recuperable", value: root.m.docker ? root.m.docker.join(" · ") : "—", warn: false }
        ]

        Item {
            id: row
            required property var modelData
            width: 320
            height: 21

            Glyph {
                id: ic
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.icon
                font.pixelSize: 16
                color: row.modelData.warn ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.6)
            }

            Text {
                anchors.left: ic.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.label
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
                color: row.modelData.warn ? Colors[root.st.accentRole] : Colors.on_surface
            }
        }
    }

    Row {
        spacing: 16

        Text {
            text: "limpiar…"
            font.family: root.st.mono
            font.pixelSize: 12
            font.weight: Font.Medium
            color: cm.containsMouse ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.7)

            MouseArea {
                id: cm
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.DeviceInfo.cleanUp()
            }
        }

        Text {
            text: "actualizar"
            font.family: root.st.mono
            font.pixelSize: 12
            color: Colors.withAlpha(Colors.on_surface, rm.containsMouse ? 0.9 : 0.45)

            MouseArea {
                id: rm
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.DeviceInfo.refreshMaint()
            }
        }
    }
}
