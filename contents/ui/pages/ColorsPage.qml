import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import "../components" as Components

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null

    contentHeight: colorsCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }

    ColorDialog { id: cpuDlg;      title: "CPU";      selectedColor: cfg.cpuColor;      onAccepted: cfg.cpuColor = selectedColor }
    ColorDialog { id: ramDlg;      title: "RAM";      selectedColor: cfg.ramColor;      onAccepted: cfg.ramColor = selectedColor }
    ColorDialog { id: swapDlg;     title: "Swap";     selectedColor: cfg.swapColor;     onAccepted: cfg.swapColor = selectedColor }
    ColorDialog { id: uploadDlg;   title: "Upload";   selectedColor: cfg.uploadColor;   onAccepted: cfg.uploadColor = selectedColor }
    ColorDialog { id: downloadDlg; title: "Download"; selectedColor: cfg.downloadColor; onAccepted: cfg.downloadColor = selectedColor }

    ColumnLayout {
        id: colorsCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 18

        Components.SectionLabel { text: "MONITOR COLORS" }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "CPU"
                Components.ColorSwatch { colorValue: cfg.cpuColor; onClicked: cpuDlg.open() }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "RAM"
                Components.ColorSwatch { colorValue: cfg.ramColor; onClicked: ramDlg.open() }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Swap"
                Components.ColorSwatch { colorValue: cfg.swapColor; onClicked: swapDlg.open() }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Upload"
                Components.ColorSwatch { colorValue: cfg.uploadColor; onClicked: uploadDlg.open() }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Download"
                Components.ColorSwatch { colorValue: cfg.downloadColor; onClicked: downloadDlg.open() }
                
            }
        }
    }
}
