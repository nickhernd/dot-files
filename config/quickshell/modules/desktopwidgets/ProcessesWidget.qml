pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Procesos que más CPU o RAM gastan. La × cierra el proceso (SIGTERM):
// primer clic pide confirmación, segundo clic lo cierra.
WidgetFrame {
    id: root

    readonly property var d: Services.DeviceInfo
    property int pending: -1

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("processes", themeId)
    seal: "程"

    Timer {
        id: confirmTimer
        interval: 3000
        onTriggered: root.pending = -1
    }

    Row {
        spacing: 12

        Repeater {
            model: [{ k: "cpu", l: "por cpu" }, { k: "mem", l: "por memoria" }]

            Text {
                id: srt
                required property var modelData
                readonly property bool on: root.d.procSort === modelData.k
                text: modelData.l
                font.family: root.st.font
                font.pixelSize: 12
                font.underline: on
                color: on ? Colors[root.st.accentRole] : Colors.withAlpha(Colors.on_surface, sm.containsMouse ? 0.9 : 0.5)

                MouseArea {
                    id: sm
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.d.setProcSort(srt.modelData.k)
                }
            }
        }
    }

    Repeater {
        model: root.d.procs

        Item {
            id: pr
            required property var modelData
            readonly property real value: root.d.procSort === "mem" ? modelData.mem : modelData.cpu
            width: 320
            height: 24

            Text {
                id: nm
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 150
                text: pr.modelData.name
                elide: Text.ElideRight
                font.family: root.st.mono
                font.pixelSize: 12
                color: Colors.on_surface
            }

            Rectangle {
                id: track
                anchors.left: nm.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 90
                height: 4
                radius: 2
                color: Colors.withAlpha(Colors.on_surface, 0.12)

                Rectangle {
                    width: Math.min(1, pr.value / 100) * parent.width
                    height: parent.height
                    radius: 2
                    color: pr.value > 50 ? Colors.error : Colors[root.st.accentRole]
                }
            }

            Text {
                anchors.left: track.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: pr.value.toFixed(1) + "%"
                font.family: root.st.mono
                font.pixelSize: 11
                color: Colors.withAlpha(Colors.on_surface, 0.75)
            }

            Glyph {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.pending === pr.modelData.pid ? "help" : "close"
                font.pixelSize: 15
                color: root.pending === pr.modelData.pid ? Colors.error : Colors.withAlpha(Colors.on_surface, km.containsMouse ? 0.9 : 0.35)

                MouseArea {
                    id: km
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.pending === pr.modelData.pid) {
                            root.d.killProc(pr.modelData.pid);
                            root.pending = -1;
                        } else {
                            root.pending = pr.modelData.pid;
                            confirmTimer.restart();
                        }
                    }
                }
            }
        }
    }
}
