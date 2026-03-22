import QtQuick 6.5
import QtQuick.Effects
import QtQuick.Layouts 6.5
import org.kde.kirigami 2.20 as Kirigami

RowLayout {
    id: root

    property alias icon: iconImage.source
    property alias label: labelText.text
    property color color: Kirigami.Theme.textColor
    property int iconTextSpacing: Kirigami.Units.smallSpacing
    property int fontSize: 10
    property string fontFamily: ""

    spacing: iconTextSpacing
    Layout.fillHeight: true

    Item {
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.small * (root.fontSize / 10))
        Layout.preferredHeight: Layout.preferredWidth
        Layout.alignment: Qt.AlignVCenter

        Image {
            id: iconImage

            anchors.fill: parent
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        MultiEffect {
            source: iconImage
            anchors.fill: iconImage
            colorization: 1
            colorizationColor: root.color
        }

    }

    Text {
        id: labelText

        Layout.alignment: Qt.AlignVCenter
        verticalAlignment: Text.AlignVCenter
        color: root.color
        font.pointSize: root.fontSize
        font.family: root.fontFamily !== "" ? root.fontFamily : Kirigami.Theme.defaultFont.family
        font.bold: true
    }

}
