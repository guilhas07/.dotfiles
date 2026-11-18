import QtQuick
import Quickshell.Hyprland

// Persistent workspaces 1-10 on every monitor, plus the active submap.
Row {
    id: root

    property string submap: ""

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap")
                root.submap = event.data;
        }
    }

    Repeater {
        model: 10

        BarButton {
            id: ws
            required property int index
            readonly property int wsId: index + 1
            readonly property var workspace: Hyprland.workspaces.values.find(w => w.id === wsId) ?? null
            readonly property bool active: Hyprland.focusedWorkspace?.id === wsId

            text: wsId
            padding: 7
            textColor: active ? Theme.fg : (workspace?.urgent ? Theme.crit : Theme.dim)
            // Lua config: dispatch args are Lua, same as the SUPER+N binds in hyprland.lua
            onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsId}" })`)

            Rectangle {
                visible: ws.active
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 8
                height: 2
                radius: 1
                color: Theme.accent
            }
        }
    }

    BarButton {
        visible: root.submap !== ""
        text: root.submap
        italic: true
        hoverable: false
        padding: 8
        textColor: Theme.warn
    }
}
