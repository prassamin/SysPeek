import QtQuick
import QtQuick.Layouts

Rectangle {
    default property alias cardContent: container.data
    color: Theme.surfaceColor
    border.color: Theme.borderCol
    border.width: 1
    radius: 10
    implicitHeight: container.implicitHeight + 32

    // click on non-interactive areas defocuses text inputs
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: function(mouse) {
            forceActiveFocus()
            mouse.accepted = false
        }
    }

    ColumnLayout {
        id: container
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 0
    }
}
