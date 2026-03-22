import QtQuick

Rectangle {
    id: swatchRoot
    property color colorValue
    signal clicked()

    width: 30
    height: 30
    radius: 8
    color: colorValue
    border.color: Qt.rgba(1, 1, 1, 0.15)
    border.width: 1
    scale: swatchMA.containsMouse ? 1.08 : 1.0

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    // inner highlight
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.25) }
            GradientStop { position: 0.5; color: "transparent" }
        }
    }

    MouseArea {
        id: swatchMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: swatchRoot.clicked()
    }
}
