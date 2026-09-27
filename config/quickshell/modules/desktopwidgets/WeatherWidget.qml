pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// El tiempo (wttr.in, ubicación por IP) con previsión de 3 días, en el look
// del tema de escritorio. Datos: services/DesktopWidgets (weather*).
WidgetFrame {
    id: root

    readonly property var w: Services.DesktopWidgets.weather
    readonly property var dayNames: ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"]

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("weather", themeId) + (w ? " · " + w.area.toLowerCase() : "")
    seal: "天"

    // Códigos WWO de wttr.in -> Material Symbols
    function icon(code) {
        const c = parseInt(code);
        if (c === 113) return "sunny";
        if (c === 116) return "partly_cloudy_day";
        if (c === 119 || c === 122) return "cloud";
        if ([143, 248, 260].includes(c)) return "foggy";
        if ([200, 386, 389, 392, 395].includes(c)) return "thunderstorm";
        if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(c)) return "weather_snowy";
        return "rainy";
    }

    Row {
        spacing: 16

        Glyph {
            text: root.w ? root.icon(root.w.code) : "cloud_off"
            font.pixelSize: 52
            weight: 300
            color: Colors[root.st.accentRole]
        }

        Column {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.w ? root.w.temp + "°" : "--°"
                font.family: root.st.display || root.st.font
                font.pixelSize: 40
                font.weight: root.st.weight
                color: Colors.on_surface
            }

            Text {
                width: 180
                text: root.w ? root.w.desc.toLowerCase() : "sin conexión"
                elide: Text.ElideRight
                font.family: root.st.font
                font.pixelSize: 13
                color: Colors.withAlpha(Colors.on_surface, 0.78)
            }
        }
    }

    Text {
        visible: !!root.w
        text: root.w ? "sensación " + root.w.feels + "°  ·  humedad " + root.w.humidity + "%  ·  viento " + root.w.wind + " km/h" : ""
        font.family: root.st.mono
        font.pixelSize: 11
        color: Colors.withAlpha(Colors.on_surface, 0.6)
    }

    Row {
        visible: !!root.w
        spacing: 22

        Repeater {
            model: root.w ? root.w.days : []

            Column {
                id: day
                required property var modelData
                spacing: 3

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.dayNames[new Date(day.modelData.date + "T12:00").getDay()]
                    font.family: root.st.font
                    font.pixelSize: 12
                    color: Colors.withAlpha(Colors.on_surface, 0.7)
                }

                Glyph {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.icon(day.modelData.code)
                    font.pixelSize: 22
                    color: Colors.on_surface
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: day.modelData.max + "° / " + day.modelData.min + "°"
                    font.family: root.st.mono
                    font.pixelSize: 11
                    color: Colors.withAlpha(Colors.on_surface, 0.8)
                }
            }
        }
    }
}
