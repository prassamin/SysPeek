import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import "../components" as Components

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null

    contentHeight: alertsCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }

    ColorDialog { id: pwcDlg; title: "Warning";  selectedColor: cfg.percentWarningColor;  onAccepted: cfg.percentWarningColor = selectedColor }
    ColorDialog { id: pccDlg; title: "Critical"; selectedColor: cfg.percentCriticalColor; onAccepted: cfg.percentCriticalColor = selectedColor }
    ColorDialog { id: swcDlg; title: "Warning";  selectedColor: cfg.speedWarningColor;    onAccepted: cfg.speedWarningColor = selectedColor }
    ColorDialog { id: sccDlg; title: "Critical"; selectedColor: cfg.speedCriticalColor;   onAccepted: cfg.speedCriticalColor = selectedColor }

    ColumnLayout {
        id: alertsCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 18

        Components.SectionLabel { text: "USAGE THRESHOLDS (%)" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow {
                label: "Warning Above"
                Components.SpinBox { from: 1; to: 100; value: cfg.percentWarningThreshold; onValueModified: cfg.percentWarningThreshold = value }
                Components.ColorSwatch { colorValue: cfg.percentWarningColor; onClicked: pwcDlg.open() }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Critical Above"
                Components.SpinBox { from: 1; to: 100; value: cfg.percentCriticalThreshold; onValueModified: cfg.percentCriticalThreshold = value }
                Components.ColorSwatch { colorValue: cfg.percentCriticalColor; onClicked: pccDlg.open() }
            }
        }

        Components.SectionLabel { text: "NETWORK THRESHOLDS (MB/s)" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow {
                label: "Warning Above"
                Components.SpinBox { from: 1; to: 1000; value: cfg.speedWarningThreshold; onValueModified: cfg.speedWarningThreshold = value }
                Components.ColorSwatch { colorValue: cfg.speedWarningColor; onClicked: swcDlg.open() }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Critical Above"
                Components.SpinBox { from: 1; to: 1000; value: cfg.speedCriticalThreshold; onValueModified: cfg.speedCriticalThreshold = value }
                Components.ColorSwatch { colorValue: cfg.speedCriticalColor; onClicked: sccDlg.open() }
            }
        }
    }
}
