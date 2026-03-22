import QtQuick
import QtQuick.Layouts

RowLayout {
    default property alias controls: controlArea.data
    property string label

    Layout.fillWidth: true
    Layout.minimumHeight: 40

    Text {
        text: parent.label
        color: Theme.textPrimary
        font.pixelSize: 13
        Layout.fillWidth: true

        HoverHandler {
            cursorShape: Qt.IBeamCursor
        }
    }

    Row {
        id: controlArea
        spacing: 10
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    }
}
