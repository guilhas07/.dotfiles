import QtQuick
import Quickshell

// HH:mm, click for the long date. Hover: month calendar (scroll on the clock to change month).
BarButton {
    id: root

    property bool alt: false
    property int monthOffset: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, alt ? "ddd dd MMM  HH:mm" : "HH:mm")
    bold: true
    onClicked: alt = !alt
    onScrolled: delta => monthOffset += delta > 0 ? -1 : 1

    // --- Hover open/close with small delays so it doesn't flicker ---
    readonly property bool wantOpen: root.hovered || cardHover.hovered
    onWantOpenChanged: {
        if (wantOpen) {
            hideTimer.stop();
            if (!popup.visible) showTimer.start();
        } else {
            showTimer.stop();
            hideTimer.start();
        }
    }
    Timer { id: showTimer; interval: 250; onTriggered: popup.visible = true }
    Timer { id: hideTimer; interval: 200; onTriggered: popup.visible = false }

    // --- Calendar data ---
    readonly property date today: clock.date
    readonly property date view: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)
    readonly property int firstDow: (view.getDay() + 6) % 7 // Monday first
    readonly property int daysInMonth: new Date(view.getFullYear(), view.getMonth() + 1, 0).getDate()
    readonly property int cells: Math.ceil((firstDow + daysInMonth) / 7) * 7

    PopupWindow {
        id: popup
        visible: false
        onVisibleChanged: if (!visible) root.monthOffset = 0
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        color: "transparent"
        implicitWidth: card.width
        implicitHeight: card.height + card.y

        Rectangle {
            id: card
            y: 6
            width: content.implicitWidth
            height: content.implicitHeight
            radius: 10
            color: Theme.bg
            border.width: 1
            border.color: Theme.dim

            HoverHandler {
                id: cardHover
            }

            Column {
                id: content
                padding: 12
                spacing: 6

                Text {
                    width: grid.width
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(root.view, "MMMM yyyy")
                    color: root.monthOffset === 0 ? Theme.fg : Theme.warn
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }

                Grid {
                    id: grid
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 2

                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                        Text {
                            required property string modelData
                            required property int index
                            width: 28
                            height: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            color: index >= 5 ? Theme.accent : Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                        }
                    }

                    Repeater {
                        model: root.cells

                        Rectangle {
                            required property int index
                            readonly property int day: index - root.firstDow + 1
                            readonly property bool valid: day >= 1 && day <= root.daysInMonth
                            readonly property bool isToday: valid && root.monthOffset === 0
                                && day === root.today.getDate()

                            width: 28
                            height: 22
                            radius: 6
                            color: isToday ? Theme.accent : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: parent.valid ? parent.day : ""
                                color: parent.isToday ? Theme.bg : (parent.index % 7 >= 5 ? Theme.dim : Theme.fg)
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.bold: parent.isToday
                            }
                        }
                    }
                }
            }
        }
    }
}
