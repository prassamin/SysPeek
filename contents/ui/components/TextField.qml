import QtQuick
import QtQuick.Layouts

Item {
    id: tfRoot
    property alias text: innerField.text
    property string placeholderText: ""

    implicitWidth: 200
    implicitHeight: 36
    Layout.fillWidth: true

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.controlBg
        border.color: innerField.activeFocus ? Theme.accentCol : Theme.controlBorder
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 200 } }

        // focus glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 10
            color: "transparent"
            border.color: innerField.activeFocus ? Theme.accentDim : "transparent"
            border.width: 2
            Behavior on border.color { ColorAnimation { duration: 250 } }
        }
    }

    TextInput {
        id: innerField
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.textPrimary
        selectionColor: Theme.accentCol
        selectedTextColor: "white"
        font.pixelSize: 13
        HoverHandler { cursorShape: Qt.IBeamCursor }
        clip: true

        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            text: tfRoot.placeholderText
            color: Theme.textTertiary
            font.pixelSize: 13
            visible: !innerField.text && !innerField.activeFocus
        }
    }
}
