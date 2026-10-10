import QtQuick
import Quickshell
import qs.components
import Quickshell.Io
import qs.services as Services

PanelWindow {
    id: clockWindow
    screen: Services.Screens.primary

    visible: false
    color: "transparent"

    anchors.top: true
    anchors.right: true
    margins.top: 20
    margins.right: 20

    implicitWidth: 200
    implicitHeight: 200

    Clock {
        anchors.fill: parent
    }

    IpcHandler {
        target: "clockWindow"
        function toggle(): void {
            clockWindow.visible = !clockWindow.visible
        }

    }

}
