import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Output volume + mic state. Scroll: volume. Left: KDE audio settings.
// Middle: mute output. Right: mute mic.
BarButton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property bool bluetooth: (sink?.name ?? "").startsWith("bluez")

    readonly property string icon: {
        if (muted) return "󰝟";
        if (volume < 0.34) return "󰕿";
        if (volume < 0.67) return "󰖀";
        return "󰕾";
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    text: `${icon}${bluetooth ? "󰂯" : ""} ${muted ? "muted" : Math.round(volume * 100) + "%"}  ${String.fromCodePoint(micMuted ? 0xF131 : 0xF130)}`
    textColor: muted ? Theme.dim : Theme.fg

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached(["kcmshell6", "kcm_pulseaudio"]);
        else if (mouse.button === Qt.MiddleButton && sink?.audio)
            sink.audio.muted = !sink.audio.muted;
        else if (mouse.button === Qt.RightButton && source?.audio)
            source.audio.muted = !source.audio.muted;
    }
    onScrolled: delta => {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, volume + (delta > 0 ? 0.05 : -0.05)));
    }
}
