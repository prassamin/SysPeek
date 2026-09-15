import QtQuick 6.5
import QtQuick.Controls as QQC2
import QtQuick.Effects
import QtQuick.Layouts 6.5
import "components" as Components
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore

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
    // Reserve label slot width so digit-count changes (e.g. 2% → 80%) do not resize the panel.
    property string labelWidthHint: "100%"
    property bool fixedLabelWidth: true
    property int labelTextAlignment: 0 // 0=Left, 1=Right, 2=Center
    property int fixedLabelWidthExtra: 0
    // Grows to the widest label seen so values wider than the hint never jitter the panel.
    property int widestSeenLabelWidth: 0
    readonly property int reservedLabelWidth: Math.max(Math.ceil(labelMetrics.advanceWidth), widestSeenLabelWidth) + Math.max(0, fixedLabelWidthExtra)
    onFontSizeChanged: widestSeenLabelWidth = 0
    onFontFamilyChanged: widestSeenLabelWidth = 0
    onLabelWidthHintChanged: widestSeenLabelWidth = 0
    readonly property int labelHAlign: {
        if (!fixedLabelWidth)
            return Text.AlignLeft;

        switch (Number(labelTextAlignment)) {
        case 0:
            return Text.AlignLeft;
        case 2:
            return Text.AlignHCenter;
        default:
            return Text.AlignRight;
        }
    }

    spacing: showIcon ? iconTextSpacing : 0
    Layout.fillHeight: true

    TextMetrics {
        id: labelMetrics

        font: labelText.font
        text: itemRoot.labelWidthHint
    }

    HoverHandler {
        id: hoverHandler
    }

    Loader {
        id: tooltipLoader

        active: hoverHandler.hovered && itemRoot.tooltipText !== "" && itemRoot.showTooltips
        sourceComponent: (typeof root !== "undefined" && root.isPlanar) ? desktopTooltipComponent : panelTooltipComponent
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
                color: Kirigami.Theme.textColor
                font.pixelSize: 11
                font.family: itemRoot.fontFamily
                textFormat: Text.RichText
                lineHeight: 1.25
            }

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
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
                    color: Kirigami.Theme.backgroundColor
                    border.color: Components.Theme.borderCol
                    border.width: 1
                    radius: 8
                    z: 99999

                    Text {
                        id: tooltipText

                        x: 12
                        y: 12
                        text: itemRoot.tooltipText
                        color: Kirigami.Theme.textColor
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
        Layout.preferredWidth: itemRoot.fixedLabelWidth ? Math.max(itemRoot.reservedLabelWidth, Math.ceil(implicitWidth)) : Math.ceil(implicitWidth)
        Layout.minimumWidth: Layout.preferredWidth
        horizontalAlignment: itemRoot.labelHAlign
        verticalAlignment: Text.AlignVCenter
        color: itemRoot.color
        font.pointSize: itemRoot.fontSize
        font.family: itemRoot.fontFamily !== "" ? itemRoot.fontFamily : Kirigami.Theme.defaultFont.family
        font.bold: true
        onImplicitWidthChanged: {
            if (itemRoot.fixedLabelWidth && implicitWidth > itemRoot.widestSeenLabelWidth)
                itemRoot.widestSeenLabelWidth = Math.ceil(implicitWidth);

        }
    }

}
