pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Stream mode: on while the screen is being shared. xdg-desktop-portal-hyprland creates a
// PipeWire Video/Source node (media.name "xdph-streaming-<n>") for each screencast
// session and removes it when the share stops. Works for any app (Zoom, Discord, browsers).
Singleton {
    id: root

    readonly property bool sharing: Pipewire.nodes.values
        .some(n => n.name === "xdg-desktop-portal-hyprland")
    // Turned off by hand for the current share; reset when the share ends.
    property bool suppressed: false
    readonly property bool active: sharing && !suppressed

    onSharingChanged: if (!sharing) suppressed = false

    // Super+Shift+L in hyprland.lua: `qs ipc call screenshare toggle`
    IpcHandler {
        target: "screenshare"

        function toggle(): void {
            if (root.sharing) root.suppressed = !root.suppressed;
        }
    }
}
