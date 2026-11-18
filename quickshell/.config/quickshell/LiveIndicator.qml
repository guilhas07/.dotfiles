import QtQuick

// Replaces the media module in the bar center while the screen is shared.
Row {
    id: root

    visible: ScreenShare.active
    height: Theme.barHeight
    spacing: 7
    leftPadding: 10
    rightPadding: 10

    Rectangle {
        id: dot
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: Theme.crit

        SequentialAnimation on opacity {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "<b>LIVE</b> · sharing screen"
        textFormat: Text.StyledText
        color: Theme.crit
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
