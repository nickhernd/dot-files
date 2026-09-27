pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.colors
import qs.modules.lock
import qs.services as Services

// Resumen de desarrollo (~/.local/bin/dev-status): Docker, repos git y GitHub.
// Clic en una fila abre la TUI correspondiente.
WidgetFrame {
    id: root

    readonly property var d: Services.DesktopWidgets.dev
    function n(v) { return v === null || v === undefined ? "—" : String(v) }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("dev", themeId)
    seal: "工"

    Repeater {
        model: [
            { icon: "deployed_code", label: "contenedores docker", value: root.d ? root.n(root.d.docker) : "—", warn: false, cmd: "omarchy-launch-tui lazydocker" },
            { icon: "commit", label: "repos con cambios", value: root.d ? root.d.repos.dirty + " / " + root.d.repos.total : "—", warn: root.d && root.d.repos.dirty > 0, cmd: "omarchy-launch-tui lazygit" },
            { icon: "upload", label: "commits sin subir", value: root.d ? String(root.d.repos.ahead) : "—", warn: root.d && root.d.repos.ahead > 0, cmd: "omarchy-launch-tui lazygit" },
            { icon: "adjust", label: "issues abiertas", value: root.d ? root.n(root.d.gh.issues) : "—", warn: false, cmd: "omarchy-launch-tui gh dash" },
            { icon: "merge", label: "PRs · reviews", value: root.d ? root.n(root.d.gh.prs) + " · " + root.n(root.d.gh.reviews) : "—", warn: root.d && root.d.gh.reviews > 0, cmd: "omarchy-launch-tui gh dash" },
            { icon: "notifications", label: "notificaciones github", value: root.d ? root.n(root.d.gh.notifs) : "—", warn: root.d && root.d.gh.notifs > 0, cmd: "omarchy-launch-tui gh dash" }
        ]

        Item {
            id: row
            required property var modelData
            width: 260
            height: 22

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
                text: WidgetStyle.label(row.modelData.label, root.st)
                font.family: root.st.font
                font.pixelSize: 12
                color: Colors.withAlpha(Colors.on_surface, hover.containsMouse ? 1 : 0.78)
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

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["sh", "-c", row.modelData.cmd])
            }
        }
    }

    Text {
        visible: !!root.d && root.d.repos.names.length > 0
        width: 260
        elide: Text.ElideRight
        text: root.d ? "pendiente: " + root.d.repos.names.join(", ") : ""
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, 0.6)
    }
}
