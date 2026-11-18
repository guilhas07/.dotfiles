import QtQuick
import Quickshell
import Quickshell.Hyprland

// ⏻ button with a dropdown: suspend / hibernate / reboot / shutdown.
BarButton {
    id: root

    text: "⏻"
    padding: 9
    onClicked: popup.visible = !popup.visible

    PopupWindow {
        id: popup
        visible: false
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        implicitWidth: menu.implicitWidth
        implicitHeight: menu.implicitHeight
        color: Theme.bg

        HyprlandFocusGrab {
            windows: [popup]
            active: popup.visible
            onCleared: popup.visible = false
        }

        Column {
            id: menu
            width: 130

            Repeater {
                model: [
                    { label: "Suspend", cmd: ["systemctl", "suspend"] },
                    { label: "Hibernate", cmd: ["systemctl", "hibernate"] },
                    { label: "Reboot", cmd: ["systemctl", "reboot"] },
                    { label: "Shutdown", cmd: ["systemctl", "poweroff"] }
                ]

                BarButton {
                    required property var modelData
                    width: menu.width
                    padding: 12
                    text: modelData.label
                    onClicked: {
                        popup.visible = false;
                        Quickshell.execDetached(modelData.cmd);
                    }
                }
            }
        }
    }
}
