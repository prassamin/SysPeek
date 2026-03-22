import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../components" as Components

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null

    contentHeight: generalCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }

    ColumnLayout {
        id: generalCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 18

        Components.SectionLabel { text: "LAUNCH" }

        Components.Card {
            Layout.fillWidth: true
            Components.TextField {
                Layout.fillWidth: true
                text: cfg.launchCommand
                placeholderText: "e.g. plasma-systemmonitor"
                onTextChanged: cfg.launchCommand = text
            }
        }

        Components.SectionLabel { text: "VISIBLE MONITORS" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow { label: "CPU";            Components.Toggle { checked: cfg.showCpu;      onToggled: cfg.showCpu = checked } }
            Components.Divider {}
            Components.SettingRow { label: "RAM";            Components.Toggle { checked: cfg.showRam;      onToggled: cfg.showRam = checked } }
            Components.Divider {}
            Components.SettingRow { label: "Swap";           Components.Toggle { checked: cfg.showSwap;     onToggled: cfg.showSwap = checked } }
            Components.Divider {}
            Components.SettingRow { label: "Upload Speed";   Components.Toggle { checked: cfg.showUpload;   onToggled: cfg.showUpload = checked } }
            Components.Divider {}
            Components.SettingRow { label: "Download Speed"; Components.Toggle { checked: cfg.showDownload; onToggled: cfg.showDownload = checked } }
        }

        Components.SectionLabel { text: "DATA FORMAT" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow {
                label: "Network Speed"
                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    model: ["KB, MB, GB, TB", "B, KB, MB, GB, TB", "Kbps, Mbps, Gbps, Tbps", "bps, Kbps, Mbps, Gbps, Tbps"]
                    currentIndex: cfg.netSpeedFormat
                    onActivated: function(i) { cfg.netSpeedFormat = i }
                }
            }
        }
    }
}
