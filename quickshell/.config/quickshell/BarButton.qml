import QtQuick

// A text label with padding, optional hover highlight, click and scroll signals.
Rectangle {
    id: root

    property alias text: label.text
    property alias textColor: label.color
    property alias bold: label.font.bold
    property alias italic: label.font.italic
    property int padding: 9
    property int maxTextWidth: -1
    property bool hoverable: true
    readonly property alias hovered: area.containsMouse

    signal clicked(var mouse)
    signal scrolled(int delta)

    implicitWidth: label.width + padding * 2
    implicitHeight: Theme.barHeight
    color: "transparent"

    // Hover highlight: rounded pill inset from the bar edges, so it doesn't poke
    // square corners out of the bar's rounded ends.
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        radius: 6
        color: root.hoverable && area.containsMouse ? Theme.hover : "transparent"
    }

    Text {
        id: label
        anchors.centerIn: parent
        width: root.maxTextWidth > 0 ? Math.min(implicitWidth, root.maxTextWidth) : implicitWidth
        elide: Text.ElideRight
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
        // Undo touchpad natural scrolling (hyprland.lua: input.touchpad.natural_scroll = true):
        // these are knobs (volume, month), not content, so finger-up should mean "up/more".
        // Hyprland doesn't set wheel.inverted, and high-res mouse wheels send pixel deltas too,
        // so detect the touchpad by its scroll phases (begin/update/end); mouse wheels always
        // report Qt.NoScrollPhase. Drop the flip if natural scroll is turned off.
        onWheel: wheel => {
            const touchpad = wheel.inverted || wheel.phase !== Qt.NoScrollPhase;
            root.scrolled(touchpad ? -wheel.angleDelta.y : wheel.angleDelta.y);
        }
    }
}
