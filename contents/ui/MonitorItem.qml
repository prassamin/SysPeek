import QtQuick 6.5
import QtQuick.Effects
import QtQuick.Layouts 6.5
import org.kde.kirigami 2.20 as Kirigami
import QtQuick.Controls as QQC2
import org.kde.plasma.core as PlasmaCore
import "components" as Components

RowLayout {
    id: itemRoot

    property alias icon: iconImage.source
    property alias label: labelText.text
    property color color: Kirigami.Theme.textColor
    property int iconTextSpacing: Kirigami.Units.smallSpacing
    property int fontSize: 10
    property string fontFamily: ""
    property bool showIcon: true
    property string tooltipText: ""
    property bool showTooltips: true

    spacing: showIcon ? iconTextSpacing : 0
    Layout.fillHeight: true

    HoverHandler {
        id: hoverHandler
    }

    Loader {
        id: tooltipLoader
        active: hoverHandler.hovered && itemRoot.tooltipText !== "" && itemRoot.showTooltips
        sourceComponent: (typeof root !== "undefined" && root.isPlanar)
                         ? desktopTooltipComponent
                         : panelTooltipComponent
    }

    Component {
        id: desktopTooltipComponent

        QQC2.ToolTip {
            parent: itemRoot
            visible: true
            delay: 500
            timeout: -1
            padding: 12
            z: 99999

            contentItem: Text {
                text: itemRoot.tooltipText
                color: Components.Theme.textPrimary
                font.pixelSize: 11
                font.family: itemRoot.fontFamily
                textFormat: Text.RichText
                lineHeight: 1.25
            }

            background: Rectangle {
                color: Components.Theme.bgBase
                border.color: Components.Theme.borderCol
                border.width: 1
                radius: 8

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.08)
                    radius: 8
                }
            }
        }
    }

    Component {
        id: panelTooltipComponent

        PlasmaCore.Dialog {
            visible: true
            visualParent: itemRoot
            location: (typeof Plasmoid !== "undefined") ? Plasmoid.location : PlasmaCore.Types.Floating
            backgroundHints: PlasmaCore.Types.NoBackground

            mainItem: Item {
                implicitWidth: tooltipCard.width
                implicitHeight: tooltipCard.height + 16
                z: 1000

                Rectangle {
                    id: tooltipCard
                    x: 0
                    y: 12
                    width: tooltipText.implicitWidth + 24
                    height: tooltipText.implicitHeight + 18
                    color: Components.Theme.bgBase
                    border.color: Components.Theme.borderCol
                    border.width: 1
                    radius: 8
                    z: 99999

                    Text {
                        id: tooltipText
                        x: 12
                        y: 12
                        text: itemRoot.tooltipText
                        color: Components.Theme.textPrimary
                        font.pixelSize: 11
                        font.family: itemRoot.fontFamily
                        textFormat: Text.RichText
                        lineHeight: 1.25
                    }
                }
            }
        }
    }

    Item {
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.small * (itemRoot.fontSize / 10))
        Layout.preferredHeight: Layout.preferredWidth
        Layout.alignment: Qt.AlignVCenter
        visible: itemRoot.showIcon

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
            colorizationColor: itemRoot.color
        }

    }

    Text {
        id: labelText

        Layout.alignment: Qt.AlignVCenter
        verticalAlignment: Text.AlignVCenter
        color: itemRoot.color
        font.pointSize: itemRoot.fontSize
        font.family: itemRoot.fontFamily !== "" ? itemRoot.fontFamily : Kirigami.Theme.defaultFont.family
        font.bold: true
    }

}
