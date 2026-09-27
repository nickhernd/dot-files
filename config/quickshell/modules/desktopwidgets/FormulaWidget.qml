pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Fórmula del día (quotes/formulas.json), renderizada con Typst si está
// instalado; si no, en Unicode. La flecha pasa a la siguiente.
WidgetFrame {
    id: root

    readonly property var f: Services.Productivity.formula

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("formula", themeId) + (f ? "  ·  " + f.name.toLowerCase() : "")
    seal: "式"

    Image {
        visible: !!root.f && root.f.img !== "" && status === Image.Ready
        source: root.f && root.f.img ? "file://" + root.f.img : ""
        cache: false
        fillMode: Image.PreserveAspectFit
        width: Math.min(420, implicitWidth * 0.75)
        height: visible ? implicitHeight * (width / Math.max(1, implicitWidth)) : 0
        smooth: true
    }

    Text {
        visible: !!root.f && (root.f.img === "")
        text: root.f ? root.f.text : "…"
        font.family: "Noto Serif"
        font.pixelSize: 26
        font.italic: true
        color: Colors.on_surface
    }

    Item {
        width: 420
        height: desc.implicitHeight

        Text {
            id: desc
            width: 390
            text: root.f ? root.f.desc : ""
            wrapMode: Text.WordWrap
            font.family: root.st.font
            font.pixelSize: 13
            font.italic: root.st.frame === "bare"
            color: Colors.withAlpha(Colors.on_surface, 0.75)
        }

        Glyph {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: "arrow_forward"
            font.pixelSize: 17
            color: nx.containsMouse ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.45)

            MouseArea {
                id: nx
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.Productivity.nextFormula()
            }
        }
    }
}
