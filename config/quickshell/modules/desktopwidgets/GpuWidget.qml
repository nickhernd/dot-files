pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.colors
import qs.services as Services

// GPU NVIDIA (nvidia-smi cada 2 s mientras se ve): uso, VRAM, temperatura y consumo.
// Pensado para ver el entrenamiento de SAM/CNN en el sobremesa (RTX 4070).
WidgetFrame {
    id: root

    property var gpu: null          // {name, util, memUsed, memTotal, temp, power, powerMax}

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("gpu", themeId)
    seal: "炉"

    Timer {
        interval: 2000
        repeat: true
        running: root.visible && Services.DesktopWidgets.hasNvidia
        triggeredOnStart: true
        onTriggered: smi.running = true
    }

    Process {
        id: smi
        command: ["nvidia-smi", "--query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw,power.limit", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\n")[0].split(",").map(x => x.trim());
                if (f.length < 7) {
                    root.gpu = null;
                    return;
                }
                root.gpu = { name: f[0].replace("NVIDIA GeForce ", ""), util: +f[1], memUsed: +f[2], memTotal: +f[3], temp: +f[4], power: +f[5], powerMax: +f[6] };
            }
        }
    }

    Text {
        visible: !root.gpu
        text: "sin GPU NVIDIA"
        font.family: root.st.font
        font.pixelSize: 12
        color: Colors.withAlpha(Colors.on_surface, 0.6)
    }

    Text {
        visible: !!root.gpu
        text: root.gpu ? root.gpu.name : ""
        font.family: root.st.mono
        font.pixelSize: 12
        color: Colors[root.st.accentRole]
    }

    Repeater {
        model: root.gpu ? [
            { label: "uso", value: root.gpu.util / 100, text: root.gpu.util + "%" },
            { label: "vram", value: root.gpu.memUsed / root.gpu.memTotal, text: (root.gpu.memUsed / 1024).toFixed(1) + " / " + Math.round(root.gpu.memTotal / 1024) + " GB" },
            { label: "temperatura", value: root.gpu.temp / 90, text: root.gpu.temp + "°C" },
            { label: "consumo", value: root.gpu.power / root.gpu.powerMax, text: Math.round(root.gpu.power) + " / " + Math.round(root.gpu.powerMax) + " W" }
        ] : []

        Column {
            id: row
            required property var modelData
            width: 260
            spacing: 5

            Item {
                width: parent.width
                height: name.implicitHeight

                Text {
                    id: name
                    text: WidgetStyle.label(row.modelData.label, root.st)
                    font.family: root.st.cjk ?? (root.st.frame === "chamfer" ? root.st.mono : root.st.font)
                    font.pixelSize: 12
                    font.letterSpacing: root.st.labelCase === "upper" ? 2 : 0.3
                    color: Colors.withAlpha(Colors.on_surface, 0.78)
                }

                Text {
                    anchors.right: parent.right
                    text: row.modelData.text
                    font.family: root.st.frame === "glass" ? root.st.display : root.st.mono
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Colors.on_surface
                }
            }

            WidgetBar {
                width: parent.width
                themeId: root.themeId
                value: row.modelData.value
            }
        }
    }
}
