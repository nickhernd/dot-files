pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.colors
import qs.modules.lock
import qs.services as Services

// Palabra del día (~/.local/bin/palabra-del-dia, del Wikcionario) y titulares de
// Ciencia de El País (~/.local/bin/news-top) con sección y hora. Clic en la palabra
// o en un titular lo abre en el navegador.
WidgetFrame {
    id: root

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("news", themeId)
    seal: "學"

    // ── Palabra del día ──
    Item {
        id: wotd
        readonly property var w: Services.DeviceInfo.word
        visible: !!w.word
        width: 560
        height: visible ? wordCol.implicitHeight + 8 : 0

        Column {
            id: wordCol
            width: parent.width
            spacing: 3

            Row {
                spacing: 10

                Text {
                    text: wotd.w.word ?? ""
                    font.family: root.st.font
                    font.pixelSize: 26
                    font.italic: true
                    font.underline: wma.containsMouse
                    color: Colors[root.st.accentRole]
                }

                Text {
                    anchors.baseline: parent.children[0].baseline
                    text: "palabra del día" + (wotd.w.pos ? "  ·  " + wotd.w.pos : "")
                    font.family: root.st.mono
                    font.pixelSize: 12
                    color: Colors.withAlpha(Colors.on_surface, 0.55)
                }
            }

            Text {
                width: parent.width
                text: wotd.w.def ?? ""
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                font.family: root.st.font
                font.pixelSize: 15
                color: Colors.withAlpha(Colors.on_surface, 0.85)
            }
        }

        MouseArea {
            id: wma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["xdg-open", wotd.w.url])
        }
    }

    Text {
        visible: Services.DeviceInfo.news.length === 0
        text: "cargando…"
        font.family: root.st.font
        font.pixelSize: 12
        color: Colors.withAlpha(Colors.on_surface, 0.6)
    }

    Repeater {
        model: Services.DeviceInfo.news

        Item {
            id: item
            required property var modelData
            required property int index
            width: 560
            height: 46

            Text {
                id: num
                anchors.top: parent.top
                text: String(item.index + 1).padStart(2, "0")
                font.family: root.st.mono
                font.pixelSize: 15
                color: Colors[root.st.accentRole]
            }

            Text {
                id: ttl
                anchors.left: num.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.top: parent.top
                text: item.modelData.title
                elide: Text.ElideRight
                font.family: root.st.font
                font.pixelSize: 17
                font.underline: ma.containsMouse
                color: ma.containsMouse ? Colors[root.st.accentRole] : Colors.on_surface
            }

            Text {
                anchors.left: ttl.left
                anchors.top: ttl.bottom
                anchors.topMargin: 2
                text: item.modelData.section.toLowerCase() + (item.modelData.ago ? "  ·  " + item.modelData.ago : "")
                font.family: root.st.mono
                font.pixelSize: 12
                color: Colors.withAlpha(Colors.on_surface, 0.55)
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["xdg-open", item.modelData.url])
            }
        }
    }
}
