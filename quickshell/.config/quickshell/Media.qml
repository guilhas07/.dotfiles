import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Now playing: cava wave drawn behind the title; on hover the title fades into prev/play/next.
Item {
    id: root

    // Spotify only; browser tabs and other MPRIS players are ignored.
    readonly property MprisPlayer player: Mpris.players.values
        .find(p => p.dbusName === "org.mpris.MediaPlayer2.spotify") ?? null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property int barCount: 24

    // Scroll = Spotify's own volume (MPRIS), ±5% per wheel notch.
    // Touchpad deltas are accumulated so one swipe doesn't fire dozens of steps.
    property int scrollAccum: 0
    function scrollVolume(delta) {
        if (!player?.volumeSupported) return;
        scrollAccum += delta;
        while (Math.abs(scrollAccum) >= 120) {
            const step = scrollAccum > 0 ? 1 : -1;
            player.volume = Math.max(0, Math.min(1, player.volume + 0.05 * step));
            scrollAccum -= 120 * step;
        }
        volumeFlash.restart();
    }
    Timer {
        id: volumeFlash
        interval: 1200
    }
    readonly property bool showVolume: volumeFlash.running

    property var levels: []

    // Hidden while screen sharing; LiveIndicator takes the bar center instead.
    visible: !ScreenShare.active && player !== null && player.playbackState !== MprisPlaybackState.Stopped
    // Fixed to the wider of title/controls so hovering doesn't resize the module.
    implicitWidth: Math.max(title.implicitWidth, controls.implicitWidth)
    implicitHeight: Theme.barHeight

    HoverHandler {
        id: hover
    }

    // --- Wave (behind everything) ---
    Row {
        id: wave
        anchors.fill: parent
        spacing: 2
        opacity: root.playing ? 0.35 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Repeater {
            model: root.barCount

            Rectangle {
                required property int index
                anchors.bottom: parent.bottom
                width: (wave.width - wave.spacing * (root.barCount - 1)) / root.barCount
                height: Math.max(1, (root.levels[index] ?? 0) / 100 * wave.height)
                color: Theme.accent
                Behavior on height { NumberAnimation { duration: 50 } }
            }
        }
    }

    Process {
        running: root.playing
        command: ["cava", "-p", Quickshell.shellDir + "/cava.conf"]
        stdout: SplitParser {
            onRead: line => root.levels = line.split(";").filter(s => s.length > 0).map(Number)
        }
        onRunningChanged: if (!running) root.levels = []
    }

    // --- Title (idle) / controls (hover), crossfaded in the same spot ---
    BarButton {
        id: title
        readonly property string artist: root.player?.trackArtist ?? ""
        readonly property string trackTitle: root.player?.trackTitle ?? ""

        anchors.centerIn: parent
        opacity: hover.hovered || root.showVolume ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 150 } }

        text: artist ? `${artist} – ${trackTitle}` : trackTitle
        maxTextWidth: 400
        padding: 10
        hoverable: false
        italic: !root.playing
        textColor: root.playing ? Theme.fg : Theme.dim

        onClicked: mouse => {
            if (!root.player) return;
            if (mouse.button === Qt.LeftButton) root.player.togglePlaying();
            else if (mouse.button === Qt.RightButton) root.player.next();
            else root.player.previous();
        }
        onScrolled: delta => root.scrollVolume(delta)
    }

    Row {
        id: controls
        anchors.centerIn: parent
        opacity: hover.hovered && !root.showVolume ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        BarButton {
            text: "󰒮"
            padding: 6
            textColor: root.player?.canGoPrevious ? Theme.fg : Theme.dim
            onClicked: root.player?.previous()
            onScrolled: delta => root.scrollVolume(delta)
        }
        BarButton {
            text: root.playing ? "󰏤" : "󰐊"
            padding: 6
            onClicked: root.player?.togglePlaying()
            onScrolled: delta => root.scrollVolume(delta)
        }
        BarButton {
            text: "󰒭"
            padding: 6
            textColor: root.player?.canGoNext ? Theme.fg : Theme.dim
            onClicked: root.player?.next()
            onScrolled: delta => root.scrollVolume(delta)
        }
    }

    BarButton {
        id: volumeLabel
        readonly property real vol: root.player?.volume ?? 0

        anchors.centerIn: parent
        opacity: root.showVolume ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        text: `${String.fromCodePoint(vol === 0 ? 0xF075F : vol < 0.34 ? 0xF057F : vol < 0.67 ? 0xF0580 : 0xF057E)} ${Math.round(vol * 100)}%`
        hoverable: false
        onScrolled: delta => root.scrollVolume(delta)
    }
}
