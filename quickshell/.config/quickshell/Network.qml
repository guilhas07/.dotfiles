import QtQuick
import Quickshell
import Quickshell.Io

// Connection name via nmcli, polled every 5s. Left click: KDE network settings.
BarButton {
    id: root

    property string label: "offline"
    property bool online: false

    Process {
        id: nmcli
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                // lines look like: wifi:connected:MySSID  /  ethernet:connected:Wired connection 1
                const devs = text.trim().split("\n").map(l => {
                    const [type, state, ...rest] = l.split(":");
                    return { type, state, name: rest.join(":").replace(/\\/g, "") };
                });
                const up = devs.find(d => d.state === "connected" && (d.type === "ethernet" || d.type === "wifi"));
                const connecting = devs.find(d => d.state.startsWith("connecting"));
                root.online = !!up;
                if (up) root.label = up.type === "ethernet" ? "wired" : up.name;
                else if (connecting) root.label = "connecting…";
                else root.label = "offline";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: nmcli.running = true
    }

    text: label
    maxTextWidth: 180
    textColor: online ? Theme.fg : Theme.dim
    onClicked: Quickshell.execDetached(["kcmshell6", "kcm_networkmanagement"])
}
