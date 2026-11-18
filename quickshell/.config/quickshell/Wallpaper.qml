import QtQuick
import Quickshell
import Quickshell.Wayland

// Wallpaper on the background layer. The image is scaled to fit *below* the bar
// (instead of cover-cropping under it), the area above is filled with black,
// and a short gradient hides the image's top edge.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property int topOffset: Theme.barTop + Theme.barHeight + 6

    screen: modelData
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "qs-wallpaper"
    exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "black"

    Image {
        id: img
        anchors.fill: parent
        anchors.topMargin: root.topOffset
        source: "file://" + Theme.wallpaper
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignTop
        asynchronous: true
        cache: false
        sourceSize.height: height
    }

    Rectangle {
        anchors.top: img.top
        width: parent.width
        height: 40
        gradient: Gradient {
            GradientStop { position: 0; color: "black" }
            GradientStop { position: 1; color: "transparent" }
        }
    }

    // Screen-share wallpaper: full screen (bar floats over it), crossfades in/out.
    Rectangle {
        anchors.fill: parent
        color: "#121512"
        opacity: ScreenShare.active ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }

        Image {
            anchors.fill: parent
            source: "file://" + Theme.shareWallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize.height: height
        }
    }
}
