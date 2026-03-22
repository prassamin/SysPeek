import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../components" as Components

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null

    contentHeight: layoutCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }

    ColumnLayout {
        id: layoutCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 18

        Components.SectionLabel { text: "DIMENSIONS" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow {
                label: "Fixed Width"
                Components.Toggle { id: fwToggle; checked: cfg.useFixedWidth; onToggled: cfg.useFixedWidth = checked }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Widget Width"
                opacity: fwToggle.checked ? 1.0 : 0.3
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Components.SpinBox { from: 100; to: 800; stepSize: 10; value: cfg.widgetWidth; enabled: fwToggle.checked; onValueModified: cfg.widgetWidth = value }
            }
        }

        Components.SectionLabel { text: "SPACING" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow { label: "Item Spacing";      Components.SpinBox { from: 0; to: 50; value: cfg.itemSpacing;     onValueModified: cfg.itemSpacing = value } }
            Components.Divider {}
            Components.SettingRow { label: "Icon-Label Spacing"; Components.SpinBox { from: 0; to: 20; value: cfg.iconTextSpacing; onValueModified: cfg.iconTextSpacing = value } }
        }

        Components.SectionLabel { text: "PADDING" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow { label: "Horizontal"; Components.SpinBox { from: 0; to: 50; value: cfg.horizontalPadding; onValueModified: cfg.horizontalPadding = value } }
            Components.Divider {}
            Components.SettingRow { label: "Vertical";   Components.SpinBox { from: 0; to: 50; value: cfg.verticalPadding;   onValueModified: cfg.verticalPadding = value } }
        }

        Components.SectionLabel { text: "BACKGROUND" }

        Components.Card {
            Layout.fillWidth: true

            Text {
                text: "Desktop Opacity"
                color: Components.Theme.textPrimary
                font.pixelSize: 13
                Layout.fillWidth: true
                Layout.bottomMargin: 10
                HoverHandler { cursorShape: Qt.IBeamCursor }
            }

            Components.Slider {
                Layout.fillWidth: true
                from: 0; to: 100; stepSize: 5
                value: cfg.bgOpacity
                onMoved: cfg.bgOpacity = value
            }
        }
    }
}
