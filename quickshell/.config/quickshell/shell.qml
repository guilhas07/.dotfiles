import QtQuick
import Quickshell

// Bar replacing waybar, plus wallpaper (replacing hyprpaper). One of each per monitor.
ShellRoot {
    Lock {}

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property ShellScreen modelData

            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            // Side gap matches Hyprland's single-window gaps_out (6), radius matches window rounding (10).
            margins {
                top: Theme.barTop
                left: 6
                right: 6
            }
            implicitHeight: Theme.barHeight
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Theme.bg

                Workspaces {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                }

                Media {
                    anchors.centerIn: parent
                }

                LiveIndicator {
                    anchors.centerIn: parent
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Audio {}
                    SysStats {}
                    Battery {}
                    Clock {}
                    Network {}
                    Tray {}
                    PowerMenu {
                        padding: 12
                    }
                }
            }
        }
    }
}
