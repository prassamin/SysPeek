import QtQuick 6.5
import QtQuick.Controls 2.5
import QtQuick.Layouts 6.5
import QtQuick.Effects
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    property alias icon: iconImage.source
    property alias label: labelText.text
    property color color: Kirigami.Theme.textColor
    property int iconTextSpacing: Kirigami.Units.smallSpacing
    property int fontSize: 10
    property string fontFamily: ""

    implicitWidth: parent
    implicitHeight: parent

    Row {
        spacing: iconTextSpacing
        anchors.centerIn: parent

        Item {
            width: Math.round(Kirigami.Units.iconSizes.small * (fontSize / 10.0))
            height: Math.round(Kirigami.Units.iconSizes.small * (fontSize / 10.0))

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
                colorization: 1.0
                colorizationColor: root.color
            }
        }

        Text {
            id: labelText

            verticalAlignment: Text.AlignVCenter
            color: root.color
            font.pointSize: fontSize
            font.family: fontFamily !== "" ? fontFamily : Kirigami.Theme.defaultFont.family
            font.bold: true
        }

    }

}
