import "../components" as Components
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null
    // action type labels
    readonly property var actionTypes: ["Launch Application", "Open URL", "Run Command", "Do Nothing"]

    contentHeight: generalCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: generalCol

        spacing: 18

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 24
        }

        Components.SectionLabel {
            text: "CLICK ACTIONS"
        }

        // ── left click ──
        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Left Click"

                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    model: page.actionTypes
                    currentIndex: cfg.leftClickAction
                    onActivated: function(i) {
                        cfg.leftClickAction = i;
                    }
                }

            }

            Components.Divider {
                visible: cfg.leftClickAction !== 3
            }
            // ── Launch Application ──

            ColumnLayout {
                Layout.fillWidth: true
                visible: cfg.leftClickAction === 0
                spacing: 4

                Text {
                    text: "Command"
                    color: Components.Theme.textSecondary
                    font.pixelSize: 11
                    Layout.leftMargin: 2
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Components.TextField {
                        Layout.fillWidth: true
                        text: cfg.leftClickAppValue
                        placeholderText: "e.g. plasma-systemmonitor"
                        onTextChanged: cfg.leftClickAppValue = text
                    }

                    Components.AppChooser {
                        edgeSafeContainer: page.edgeSafeContainer
                        onAppSelected: function(cmd) {
                            cfg.leftClickAppValue = cmd;
                        }
                    }

                }

            }

            // ── Open URL ──
            ColumnLayout {
                Layout.fillWidth: true
                visible: cfg.leftClickAction === 1
                spacing: 4

                Text {
                    text: "URL"
                    color: Components.Theme.textSecondary
                    font.pixelSize: 11
                    Layout.leftMargin: 2
                }

                Components.TextField {
                    Layout.fillWidth: true
                    text: cfg.leftClickUrlValue
                    placeholderText: "e.g. https://example.com"
                    onTextChanged: cfg.leftClickUrlValue = text
                }

            }

            // ── Run Command ──
            ColumnLayout {
                Layout.fillWidth: true
                visible: cfg.leftClickAction === 2
                spacing: 4

                Text {
                    text: "Command"
                    color: Components.Theme.textSecondary
                    font.pixelSize: 11
                    Layout.leftMargin: 2
                }

                Components.TextField {
                    Layout.fillWidth: true
                    text: cfg.leftClickCmdValue
                    placeholderText: "e.g. notify-send 'Hello'"
                    onTextChanged: cfg.leftClickCmdValue = text
                }

            }

        }

        Components.SectionLabel {
            text: "DATA FORMAT"
        }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Network Speed (Global)"

                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    model: ["KB, MB, GB, TB", "B, KB, MB, GB, TB", "Kbps, Mbps, Gbps, Tbps", "bps, Kbps, Mbps, Gbps, Tbps"]
                    currentIndex: cfg.netSpeedFormat
                    onActivated: function(i) {
                        cfg.netSpeedFormat = i;
                    }
                }

            }

        }

        Components.SectionLabel {
            text: "BEHAVIOR"
        }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Show Tooltips"

                Components.Toggle {
                    checked: cfg.showTooltips
                    onToggled: cfg.showTooltips = checked
                }

            }

        }

    }

    QQC2.ScrollBar.vertical: QQC2.ScrollBar {
        policy: QQC2.ScrollBar.AsNeeded
    }

}
