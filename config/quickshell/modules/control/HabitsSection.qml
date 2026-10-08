import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.colors
import qs.components
import qs.modules.lock
import qs.services as Services

// Tracker de hábitos en el panel izquierdo (services/Habits):
//  · racha: días seguidos (sin fap, sin Monster); "recaída" pide 2 clics
//  · contador: −/+ hasta el objetivo diario (agua, lectura)
//  · casilla: hecho / no hecho hoy (deporte, dormir)
// Cada fila muestra los últimos 7 días. Debajo, libros con marcapáginas.
ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.topMargin: 20
    spacing: 14

    readonly property var h: Services.Habits
    property string pending: ""

    function term(cmd) {
        Quickshell.execDetached(["sh", "-c", "uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.tracker -e " + cmd]);
    }

    Timer {
        id: confirmTimer
        interval: 3000
        onTriggered: root.pending = ""
    }

    SectionHeader {
        title: "Hábitos"
        icon: "󰄬"
    }

    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: habitsCol.implicitHeight + 32

        ColumnLayout {
            id: habitsCol
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Repeater {
                model: root.h.grouped

                ColumnLayout {
                    id: grp
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        visible: grp.modelData._first
                        Layout.topMargin: grp.modelData._cat === root.h.categories[0] ? 0 : 8
                        text: grp.modelData._cat.toUpperCase()
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        font.weight: Font.DemiBold
                        color: Colors.primary
                    }

                RowLayout {
                    id: row
                    readonly property var hb: grp.modelData
                    readonly property bool ok: root.h.done(hb, root.h.today())
                    Layout.fillWidth: true
                    spacing: 10

                    Glyph {
                        text: row.hb.icon || "radio_button_checked"
                        filled: row.ok
                        font.pixelSize: 20
                        color: row.ok ? Colors.primary : Colors.withAlpha(Colors.on_surface, ia.containsMouse && row.hb.open ? 0.95 : 0.55)

                        // Comunicación: el icono abre la app y marca el hábito
                        MouseArea {
                            id: ia
                            anchors.fill: parent
                            anchors.margins: -4
                            enabled: !!row.hb.open
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.h.open(row.hb)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: row.hb.name
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        StyledText {
                            text: row.hb.type === "streak"
                                ? root.h.streakDays(row.hb.id) + " días · mejor " + Math.max(root.h.streak(row.hb.id).best || 0, root.h.streakDays(row.hb.id))
                                : row.hb.type === "count"
                                    ? root.h.value(row.hb.id) + " / " + row.hb.goal + " " + (row.hb.unit || "") + "  ·  racha " + root.h.dailyStreak(row.hb)
                                    : (row.ok ? "hecho hoy" : "pendiente") + "  ·  racha " + root.h.dailyStreak(row.hb)
                            font.pixelSize: 11
                            color: Colors.withAlpha(Colors.on_surface, 0.6)
                        }

                        // Últimos 7 días
                        Row {
                            spacing: 4
                            Repeater {
                                model: 7
                                Rectangle {
                                    required property int index
                                    readonly property string d: root.h.dayOffset(6 - index)
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: root.h.done(row.hb, d) ? (index === 6 ? Colors.primary : Colors.withAlpha(Colors.primary, 0.6)) : Colors.withAlpha(Colors.on_surface, 0.15)
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Controles según el tipo
                    Row {
                        spacing: 10
                        visible: row.hb.type === "count" && !row.hb.auto

                        Repeater {
                            model: [-1, 1]
                            Glyph {
                                id: pm
                                required property int modelData
                                text: modelData < 0 ? "remove" : "add"
                                font.pixelSize: 20
                                color: pma.containsMouse ? Colors.primary : Colors.on_surface
                                MouseArea {
                                    id: pma
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.h.increment(row.hb, pm.modelData)
                                }
                            }
                        }
                    }

                    Glyph {
                        visible: row.hb.type === "check"
                        text: row.ok ? "check_box" : "check_box_outline_blank"
                        filled: row.ok
                        font.pixelSize: 22
                        color: row.ok ? Colors.primary : Colors.on_surface
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.h.toggle(row.hb)
                        }
                    }

                    StyledText {
                        visible: row.hb.type === "streak"
                        text: root.pending === row.hb.id ? "¿seguro?" : "recaída"
                        font.pixelSize: 11
                        color: root.pending === row.hb.id ? Colors.error : Colors.withAlpha(Colors.on_surface, rla.containsMouse ? 0.9 : 0.45)
                        MouseArea {
                            id: rla
                            anchors.fill: parent
                            anchors.margins: -4
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.pending === row.hb.id) {
                                    root.h.relapse(row.hb.id);
                                    root.pending = "";
                                } else {
                                    root.pending = row.hb.id;
                                    confirmTimer.restart();
                                }
                            }
                        }
                    }
                }
            }
            }
        }
    }

    // ── Libros con marcapáginas ──
    SectionHeader {
        title: "Libros"
        icon: "󰂺"
    }

    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: booksCol.implicitHeight + 32

        ColumnLayout {
            id: booksCol
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            StyledText {
                visible: root.h.data.books.length === 0
                text: "Sin libros todavía"
                font.pixelSize: 12
                font.italic: true
                color: Colors.withAlpha(Colors.on_surface, 0.5)
            }

            Repeater {
                model: root.h.data.books

                ColumnLayout {
                    id: book
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            Layout.fillWidth: true
                            text: book.modelData.title + (book.modelData.finished ? "  ✓" : "")
                            elide: Text.ElideRight
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        StyledText {
                            text: "pág. " + book.modelData.page + " / " + book.modelData.total
                            font.pixelSize: 11
                            color: Colors.withAlpha(Colors.on_surface, 0.65)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            height: 5
                            radius: 3
                            color: Colors.withAlpha(Colors.on_surface, 0.12)
                            Rectangle {
                                width: parent.width * book.modelData.page / book.modelData.total
                                height: parent.height
                                radius: 3
                                color: book.modelData.finished ? Colors.tertiary : Colors.primary
                            }
                        }

                        Repeater {
                            model: [{ l: "−10", d: -10 }, { l: "+1", d: 1 }, { l: "+10", d: 10 }]
                            StyledText {
                                id: pg
                                required property var modelData
                                text: modelData.l
                                font.pixelSize: 11
                                color: pga.containsMouse ? Colors.primary : Colors.withAlpha(Colors.on_surface, 0.7)
                                MouseArea {
                                    id: pga
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.h.setPage(book.index, book.modelData.page + pg.modelData.d)
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 18

                Repeater {
                    model: [
                        { l: "+ añadir libro", c: "$HOME/.local/bin/tracker add-book" },
                        { l: "ir a página…", c: "$HOME/.local/bin/tracker page" },
                        { l: "editar hábitos", c: "$HOME/.local/bin/tracker edit" }
                    ]
                    StyledText {
                        id: act
                        required property var modelData
                        text: modelData.l
                        font.pixelSize: 11
                        color: aa.containsMouse ? Colors.primary : Colors.withAlpha(Colors.on_surface, 0.6)
                        MouseArea {
                            id: aa
                            anchors.fill: parent
                            anchors.margins: -4
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.term(act.modelData.c)
                        }
                    }
                }
            }
        }
    }
}
