pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.colors
import qs.services as Services

// Contribuciones de GitHub del último año (~/.local/bin/gh-contrib, cada hora):
// la cuadrícula de días de tu perfil, en el color del tema. Clic: abre el perfil.
WidgetFrame {
    id: root

    property var data: ({})
    readonly property var weeks: data.weeks ?? []
    // Umbrales de intensidad: cuartiles de los días con alguna contribución
    readonly property var levels: {
        const v = [].concat(...weeks).filter(n => n > 0).sort((a, b) => a - b);
        if (!v.length)
            return [1, 1, 1];
        const q = p => v[Math.min(v.length - 1, Math.floor(p * v.length))];
        return [q(0.25), q(0.5), q(0.75)];
    }
    readonly property int cell: 9
    readonly property int gap: 2

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("github", themeId)
    seal: "迹"

    function shade(n) {
        if (n <= 0)
            return Colors.withAlpha(Colors.on_surface, 0.08);
        const a = n <= levels[0] ? 0.3 : n <= levels[1] ? 0.5 : n <= levels[2] ? 0.75 : 1;
        return Colors.withAlpha(Colors[st.accentRole], a);
    }

    Timer {
        interval: 60 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", "$HOME/.local/bin/gh-contrib"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    if (d.weeks)
                        root.data = d;
                } catch (e) {}
            }
        }
    }

    Text {
        text: root.data.total !== undefined ? root.data.total + " contribuciones en el último año" : "cargando…"
        font.family: root.st.mono
        font.pixelSize: 12
        color: Colors.withAlpha(Colors.on_surface, 0.7)
    }

    Item {
        width: Math.max(1, root.weeks.length * (root.cell + root.gap) - root.gap)
        height: 7 * (root.cell + root.gap) - root.gap

        Row {
            spacing: root.gap

            Repeater {
                model: root.weeks

                Column {
                    id: week
                    required property var modelData
                    spacing: root.gap

                    Repeater {
                        model: week.modelData

                        Rectangle {
                            required property var modelData
                            width: root.cell
                            height: root.cell
                            radius: 2
                            color: root.shade(modelData)
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["xdg-open", "https://github.com/" + (root.data.user ?? "")])
        }
    }
}
