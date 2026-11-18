import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery via UPower. Left click: KDE power profiles.
BarButton {
    id: root

    readonly property var dev: UPower.displayDevice
    // percentage is 0-1 in recent Quickshell, 0-100 in older ones
    readonly property real pct: (dev?.percentage ?? 0) <= 1 ? (dev?.percentage ?? 0) * 100 : dev.percentage
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging
    readonly property bool plugged: !UPower.onBattery && !charging
    readonly property bool warning: !charging && !plugged && pct <= 30
    readonly property bool critical: !charging && !plugged && pct <= 15
    readonly property var icons: ["󰁺", "󰁼", "󰁾", "󰂀", "󰁹"]
    property bool blink: false

    visible: dev?.isLaptopBattery ?? false

    text: {
        const p = Math.round(pct) + "%";
        if (charging) return "󰂄 " + p;
        if (plugged) return "󰚥 " + p;
        return icons[Math.min(4, Math.floor(pct / 20))] + " " + p;
    }
    textColor: {
        if (charging || plugged) return Theme.accent;
        if (critical) return blink ? Theme.fg : Theme.crit;
        if (warning) return Theme.warn;
        return Theme.fg;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.critical
        onTriggered: root.blink = !root.blink
    }

    onClicked: Quickshell.execDetached(["kcmshell6", "kcm_powerdevilprofilesconfig"])
}
