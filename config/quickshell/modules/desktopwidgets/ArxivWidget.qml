pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.colors
import qs.modules.lock
import qs.services as Services

// Últimos papers de arXiv por área (~/.local/bin/arxiv-top). Clic en uno lo
// abre en el navegador; las pestañas cambian de área.
WidgetFrame {
    id: root

    readonly property var d: Services.DeviceInfo

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("arxiv", themeId)
    seal: "論"

    Row {
        spacing: 12

        Repeater {
            model: ["todo", "seguridad", "sistemas", "mates"]

            Text {
                id: tab
                required property string modelData
                readonly property bool on: root.d.arxivCat === modelData
                text: modelData
                font.family: root.st.font
                font.pixelSize: 12
                font.underline: on
                color: on ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, tm.containsMouse ? 0.9 : 0.5)

                MouseArea {
                    id: tm
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.d.setArxivCat(tab.modelData)
                }
            }
        }
    }

    Repeater {
        model: root.d.papers

        Item {
            id: p
            required property var modelData
            width: 320
            height: ttl.implicitHeight + meta.implicitHeight + 6

            Text {
                id: ttl
                width: parent.width
                text: p.modelData.title
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.family: root.st.font
                font.pixelSize: 13
                font.underline: pm.containsMouse
                color: pm.containsMouse ? Colors[root.st.accentRole] : Colors.on_surface
            }

            Text {
                id: meta
                anchors.top: ttl.bottom
                anchors.topMargin: 2
                text: p.modelData.cat + "  ·  " + p.modelData.authors + "  ·  " + p.modelData.date
                font.family: root.st.mono
                font.pixelSize: 10
                color: Colors.withAlpha(Colors.on_surface, 0.5)
            }

            MouseArea {
                id: pm
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["xdg-open", p.modelData.url])
            }
        }
    }
}
