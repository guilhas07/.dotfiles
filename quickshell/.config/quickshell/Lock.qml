pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pam

// Lock screen (ext-session-lock). Triggered by hypridle (idle + before sleep):
// `qs ipc call lock lock`. Password checked through PAM ("login" stack, same as hyprlock).
// If qs dies while locked, Hyprland keeps the session locked; restart qs from a TTY
// (misc.allow_session_lock_restore = true in hyprland.lua lets it take the lock back).
Scope {
    id: root

    property string password: ""
    // HACK (2026-11-18, revisit): after idle lock -> unlock, keyboard input to windows was dead
    // until a workspace switch. Guess, unconfirmed (Hyprland log shows no focus/lock events):
    // Hyprland 0.56.2 doesn't restore keyboard focus on ext-session-lock unlock, and with
    // follow_mouse = 2 clicking the "already focused" window doesn't re-send it.
    // Workaround: remember the focused window at lock time, re-focus it 150ms after unlock
    // (refocusTimer below). Unknown whether lock, dpms off, or suspend is the real trigger.
    // Remove when Hyprland fixes it; test: `qs ipc call lock lock`, unlock, type immediately.
    property string lastWindow: ""
    property bool failed: false
    readonly property bool busy: pam.active

    function unlock(): void {
        if (root.busy || root.password === "") return;
        root.failed = false;
        pam.start();
    }

    PamContext {
        id: pam
        onResponseRequiredChanged: {
            if (!responseRequired) return;
            respond(root.password);
        }
        onCompleted: result => {
            root.password = "";
            if (result === PamResult.Success) {
                sessionLock.locked = false;
                refocusTimer.restart();
            } else {
                root.failed = true;
            }
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: false

        // One surface per screen.
        WlSessionLockSurface {
            id: surface
            color: "#121512"

            Image {
                anchors.fill: parent
                source: "file://" + Theme.wallpaper
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.height: height
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.07, 0.08, 0.07, 0.72)
            }

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Column {
                anchors.centerIn: parent
                spacing: 14

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 96
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "dddd, dd MMMM")
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                }

                Item { width: 1; height: 24 }

                // Discreet password indicator: no box, no label. A short line that grows a dot
                // per typed character; accent while typing, red + shake on a wrong password.
                Item {
                    id: field
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 220
                    height: 24

                    readonly property color tint: root.failed ? Theme.crit
                        : (root.password !== "" ? Theme.accent : Theme.dim)

                    // Invisible input; only drives root.password.
                    TextInput {
                        id: input
                        width: 0
                        height: 0
                        opacity: 0
                        focus: true
                        echoMode: TextInput.Password
                        enabled: !root.busy

                        // Shared across monitors; typing on any screen fills the same field.
                        text: root.password
                        onTextChanged: {
                            root.password = text;
                            if (text !== "") root.failed = false;
                        }
                        onAccepted: root.unlock()
                        Keys.onEscapePressed: root.password = ""
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: line.top
                        anchors.bottomMargin: 8
                        spacing: 6
                        opacity: root.busy ? 0.4 : 1

                        Repeater {
                            model: Math.min(root.password.length, 24)

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: field.tint
                            }
                        }
                    }

                    Rectangle {
                        id: line
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: root.password !== "" || root.failed ? 120 : 40
                        height: 2
                        radius: 1
                        color: field.tint
                        opacity: root.password !== "" || root.failed ? 0.9 : 0.5

                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }

                    SequentialAnimation {
                        id: shake
                        loops: 1
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -8; duration: 50 }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 8; duration: 70 }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -5; duration: 60 }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
                    }

                    Connections {
                        target: root
                        function onFailedChanged() {
                            if (root.failed) shake.restart();
                        }
                    }
                }
            }
        }
    }

    // Delay so Hyprland has processed the unlock (Wayland) before the dispatch (IPC socket).
    Timer {
        id: refocusTimer
        interval: 150
        onTriggered: {
            if (root.lastWindow === "") return;
            const addr = root.lastWindow.startsWith("0x") ? root.lastWindow : "0x" + root.lastWindow;
            Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr}" })`);
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            if (!sessionLock.locked) root.lastWindow = Hyprland.activeToplevel?.address ?? "";
            root.password = "";
            root.failed = false;
            sessionLock.locked = true;
        }
    }
}
