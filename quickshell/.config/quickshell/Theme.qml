pragma Singleton
import QtQuick
import Quickshell

// Palette matches kitty / old waybar (bg #2b302b, fg #c2c4c2)
Singleton {
    readonly property color bg: Qt.rgba(43 / 255, 48 / 255, 43 / 255, 0.92)
    readonly property color fg: "#c2c4c2"
    readonly property color dim: "#7d837d"
    readonly property color accent: "#8fb573"
    readonly property color warn: "#e0b45c"
    readonly property color crit: "#e06c5c"
    readonly property color hover: Qt.rgba(1, 1, 1, 0.06)

    readonly property string fontFamily: "JetBrainsMono NFM"
    readonly property int fontSize: 13
    readonly property int barHeight: 26
    readonly property int barTop: 10

    readonly property string wallpaper: Quickshell.env("HOME") + "/Pictures/Wallpapers/current"
    // Shown full-screen while screen sharing (see ScreenShare.qml).
    readonly property string shareWallpaper: Quickshell.env("HOME") + "/Pictures/Wallpapers/big-brother.jpg"
}
