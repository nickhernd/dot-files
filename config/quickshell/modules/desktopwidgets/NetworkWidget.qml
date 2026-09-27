pragma ComponentBehavior: Bound
import QtQuick
import qs.colors
import qs.modules.lock
import qs.services as Services

// Red: velocidad en vivo (gráfica bajada/subida), SSID y señal, IPs y VPN.
WidgetFrame {
    id: root

    readonly property var d: Services.DeviceInfo
    readonly property var n: d.net

    themeId: Services.DesktopTheme.enabled ? Services.DesktopTheme.theme : ""
    title: WidgetStyle.word("network", themeId) + (n && n.ssid ? "  ·  " + n.ssid.toLowerCase() : "")
    seal: "網"

    Row {
        spacing: 22

        Repeater {
            model: [
                { icon: "south", label: "bajada", value: root.d.human(root.d.rxRate), role: root.st.accentRole },
                { icon: "north", label: "subida", value: root.d.human(root.d.txRate), role: "tertiary" }
            ]

            Row {
                id: rate
                required property var modelData
                spacing: 6

                Glyph {
                    anchors.verticalCenter: parent.verticalCenter
                    text: rate.modelData.icon
                    font.pixelSize: 16
                    color: Colors[rate.modelData.role]
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: rate.modelData.value
                    font.family: root.st.mono
                    font.pixelSize: 14
                    color: Colors.on_surface
                }
            }
        }
    }

    Canvas {
        id: graph
        width: 260
        height: 36
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const all = root.d.rxHistory.concat(root.d.txHistory);
            const max = Math.max(1024 * 50, ...all);
            const step = width / 39;
            const draw = (h, color) => {
                if (h.length < 2)
                    return;
                const x0 = width - (h.length - 1) * step;
                ctx.beginPath();
                h.forEach((v, i) => {
                    const x = x0 + i * step, y = height - 2 - (height - 4) * v / max;
                    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
                });
                ctx.strokeStyle = color;
                ctx.lineWidth = 1.5;
                ctx.stroke();
            };
            draw(root.d.txHistory, Colors.tertiary);
            draw(root.d.rxHistory, Colors[root.st.accentRole]);
        }

        Connections {
            target: root.d
            function onRxHistoryChanged() { graph.requestPaint(); }
        }
    }

    Repeater {
        model: [
            { label: "señal", value: root.n && root.n.signal !== null ? root.n.signal + "%" : (root.n && root.n.online ? "cable" : "sin conexión") },
            { label: "ip local", value: root.n ? root.n.localIp || "—" : "—" },
            { label: "ip pública", value: root.n ? root.n.publicIp || "—" : "—" },
            { label: "vpn", value: root.n && root.n.vpn ? root.n.vpn : "no" }
        ]

        Item {
            id: kv
            required property var modelData
            width: 260
            height: 17

            Text {
                text: kv.modelData.label
                font.family: root.st.font
                font.pixelSize: 12
                color: Colors.withAlpha(Colors.on_surface, 0.7)
            }

            Text {
                anchors.right: parent.right
                text: kv.modelData.value
                font.family: root.st.mono
                font.pixelSize: 12
                color: Colors.on_surface
            }
        }
    }
}
