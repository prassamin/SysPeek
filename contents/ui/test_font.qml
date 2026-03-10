import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 200
    height: 200
    visible: true

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Testing empty string font"
            font.family: ""
        }
    }
}
