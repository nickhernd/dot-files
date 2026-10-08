import QtQuick
import QtQuick.Layouts
import qs.colors
import qs.components
import qs.modules.lock
import qs.services as Services

// Pomodoro en el panel izquierdo: anillo, controles, sesiones de hoy y de la
// semana (cada sesión completada se apunta en el tracker de hábitos).
ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.topMargin: 20
    spacing: 14

    readonly property var p: Services.Productivity
    readonly property var h: Services.Habits

    function mmss(s) {
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    SectionHeader {
        title: "Enfoque"
        icon: "󰔟"
    }

    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: focusRow.implicitHeight + 36

        RowLayout {
            id: focusRow
            anchors.fill: parent
            anchors.margins: 18
            spacing: 18

            Item {
                Layout.preferredWidth: 104
                Layout.preferredHeight: 104

                Canvas {
                    id: ring
                    anchors.fill: parent
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        const c = width / 2, r = c - 5;
                        ctx.lineWidth = 5;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = Colors.withAlpha(Colors.on_surface, 0.12);
                        ctx.beginPath();
                        ctx.arc(c, c, r, 0, 2 * Math.PI);
                        ctx.stroke();
                        ctx.strokeStyle = root.p.phase === "focus" ? Colors.primary : Colors.tertiary;
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

                Column {
                    anchors.centerIn: parent

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.mmss(root.p.remaining)
                        font.pixelSize: 24
                        font.weight: Font.Light
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.p.phase === "focus" ? "foco" : "descanso"
                        font.pixelSize: 11
                        color: Colors.withAlpha(Colors.on_surface, 0.6)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.p.toggle()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 16

                    Repeater {
                        model: [
                            { icon: root.p.running ? "pause" : "play_arrow", tip: root.p.running ? "pausar" : "empezar", act: () => root.p.toggle() },
                            { icon: "skip_next", tip: "saltar", act: () => root.p.skip() },
                            { icon: "restart_alt", tip: "reiniciar", act: () => root.p.reset() }
                        ]

                        Glyph {
                            id: btn
                            required property var modelData
                            text: modelData.icon
                            font.pixelSize: 24
                            color: bm.containsMouse ? Colors.primary : Colors.on_surface

                            MouseArea {
                                id: bm
                                anchors.fill: parent
                                anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: btn.modelData.act()
                            }
                        }
                    }
                }

                StyledText {
                    text: root.p.sessionsToday + " sesiones hoy  ·  " + ((root.h.data.log[root.h.today()] || {}).focusMinutes || 0) + " min de foco"
                    font.pixelSize: 12
                    color: Colors.withAlpha(Colors.on_surface, 0.75)
                }

                // Últimos 7 días
                Row {
                    spacing: 6

                    Repeater {
                        model: 7

                        Column {
                            id: day
                            required property int index
                            readonly property string date: root.h.dayOffset(6 - index)
                            readonly property int n: (root.h.data.log[date] || {}).pomodoros || 0
                            spacing: 3

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 18
                                height: 26
                                radius: 4
                                color: Colors.withAlpha(Colors.on_surface, 0.08)

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: Math.min(1, day.n / 8) * parent.height
                                    radius: 4
                                    color: day.index === 6 ? Colors.primary : Colors.withAlpha(Colors.primary, 0.55)
                                }
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: ["D", "L", "M", "X", "J", "V", "S"][new Date(day.date + "T12:00").getDay()]
                                font.pixelSize: 9
                                color: Colors.withAlpha(Colors.on_surface, 0.55)
                            }
                        }
                    }
                }
            }
        }
    }
}
