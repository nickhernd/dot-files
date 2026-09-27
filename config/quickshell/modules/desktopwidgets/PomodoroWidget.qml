pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Pomodoro 25/5 (largo de 15 cada 4). Clic en el anillo: iniciar/pausar.
WidgetFrame {
    id: root

    readonly property var p: Services.Productivity

    function mmss(s) {
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("pomodoro", themeId) + "  ·  " + p.sessionsToday + " hoy"
    seal: "時"

    Row {
        spacing: 18

        Item {
            width: 96
            height: 96

            Canvas {
                id: ring
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const c = width / 2, r = c - 4;
                    ctx.lineWidth = 3;
                    ctx.strokeStyle = Colors.withAlpha(Colors.on_surface, 0.15);
                    ctx.beginPath();
                    ctx.arc(c, c, r, 0, 2 * Math.PI);
                    ctx.stroke();
                    ctx.strokeStyle = root.p.phase === "focus" ? Colors[root.st.accentRole] : Colors.tertiary;
                    ctx.beginPath();
                    ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * root.p.progress);
                    ctx.stroke();
                }

                Connections {
                    target: root.p
                    function onRemainingChanged() { ring.requestPaint(); }
                    function onPhaseChanged() { ring.requestPaint(); }
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.mmss(root.p.remaining)
                font.family: root.st.display || root.st.font
                font.pixelSize: 22
                font.weight: Font.Light
                color: Colors.on_surface
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.p.toggle()
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: root.p.phase === "focus" ? (root.p.running ? "concentrado" : "listo para empezar") : "descanso"
                font.family: root.st.font
                font.pixelSize: 14
                color: Colors.withAlpha(Colors.on_surface, 0.85)
            }

            Row {
                spacing: 14

                Repeater {
                    model: [
                        { icon: root.p.running ? "pause" : "play_arrow", act: () => root.p.toggle() },
                        { icon: "skip_next", act: () => root.p.skip() },
                        { icon: "restart_alt", act: () => root.p.reset() }
                    ]

                    Glyph {
                        id: btn
                        required property var modelData
                        text: modelData.icon
                        font.pixelSize: 20
                        color: ma.containsMouse ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.7)

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btn.modelData.act()
                        }
                    }
                }
            }

            Row {
                spacing: 5
                Repeater {
                    model: 4
                    Rectangle {
                        required property int index
                        width: 8
                        height: 8
                        radius: 4
                        color: index < (root.p.sessionsToday % 4 || (root.p.sessionsToday > 0 ? 4 : 0)) ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, 0.2)
                    }
                }
            }
        }
    }
}
