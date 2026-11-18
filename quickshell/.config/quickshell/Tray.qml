import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// StatusNotifier tray. Left: activate, middle: secondary, right: menu.
// Only items whose id is in `shown` appear (see ids: busctl --user ... StatusNotifierWatcher).
Row {
    readonly property var shown: ["nm-applet"]

    spacing: 8
    leftPadding: 9
    rightPadding: 9

    Repeater {
        model: SystemTray.items.values.filter(i => parent.shown.includes(i.id))

        MouseArea {
            id: item
            required property SystemTrayItem modelData

            width: 16
            height: Theme.barHeight
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            IconImage {
                anchors.centerIn: parent
                source: item.modelData.icon
                implicitSize: 16
            }

            QsMenuAnchor {
                id: menu
                menu: item.modelData.menu
                anchor.item: item
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton && !modelData.onlyMenu)
                    modelData.activate();
                else if (mouse.button === Qt.MiddleButton)
                    modelData.secondaryActivate();
                else if (modelData.hasMenu)
                    menu.open();
            }
        }
    }
}
