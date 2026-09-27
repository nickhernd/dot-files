pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Tiempo activo hoy por tipo de ventana (sin contar inactividad) y los
// últimos 7 días. Datos: services/Productivity.
WidgetFrame {
    id: root

    readonly property var p: Services.Productivity
    readonly property var cats: [
        { key: "code", label: "programando", role: "primary" },
        { key: "terminal", label: "terminal", role: "secondary" },
        { key: "browser", label: "navegador", role: "tertiary" },
        { key: "docs", label: "documentos", role: "on_surface_variant" },
        { key: "other", label: "otros", role: "outline" }
    ]

    function hm(s) {
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60);
        return h > 0 ? h + "h " + String(m).padStart(2, "0") + "m" : m + "m";
    }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("coding", themeId)
    seal: "功"

    Row {
        spacing: 10

        Text {
            text: root.hm(root.p.usage.code + root.p.usage.terminal)
            font.family: root.st.display || root.st.font
            font.pixelSize: 34
            font.weight: Font.Light
            color: Colors.on_surface
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            text: "de código · " + root.hm(root.p.activeToday) + " activo"
            font.family: root.st.font
            font.pixelSize: 12
            color: Colors.withAlpha(Colors.on_surface, 0.65)
        }
    }

    // Barra apilada por categoría (sobre una pista tenue)
    Item {
        width: 280
        height: 6

        Rectangle {
            anchors.fill: parent
            radius: 3
            color: Colors.withAlpha(Colors.on_surface, 0.12)
        }

    Row {
        width: 280
        height: 6

        Repeater {
            model: root.cats

            Rectangle {
                required property var modelData
                height: 6
                width: root.p.activeToday > 0 ? 280 * root.p.usage[modelData.key] / root.p.activeToday : 0
                color: Colors[modelData.role]
            }
        }
    }
    }

    Grid {
        columns: 2
        columnSpacing: 18
        rowSpacing: 4

        Repeater {
            model: root.cats

            Row {
                id: cat
                required property var modelData
                spacing: 6
                width: 131

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 7
                    height: 7
                    radius: 2
                    color: Colors[cat.modelData.role]
                }

                Text {
                    text: cat.modelData.label + "  " + root.hm(root.p.usage[cat.modelData.key])
                    font.family: root.st.font
                    font.pixelSize: 11
                    color: Colors.withAlpha(Colors.on_surface, 0.78)
                }
            }
        }
    }

    // Últimos 7 días
    Row {
        spacing: 8
        height: 46

        Repeater {
            model: root.p.week

            Column {
                id: day
                required property var modelData
                readonly property real maxv: Math.max(3600, ...root.p.week.map(w => w.active))
                anchors.bottom: parent.bottom
                spacing: 3

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 26
                    height: Math.max(2, 30 * day.modelData.active / day.maxv)
                    radius: 3
                    color: day.modelData.date === Services.Productivity.today() ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.3)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ["D", "L", "M", "X", "J", "V", "S"][new Date(day.modelData.date + "T12:00").getDay()]
                    font.family: root.st.font
                    font.pixelSize: 10
                    color: Colors.withAlpha(Colors.on_surface, 0.6)
                }
            }
        }
    }
}
