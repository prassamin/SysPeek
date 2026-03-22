import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../components" as Components

Flickable {
    id: page

    property var cfg
    property var meta
    property Item edgeSafeContainer: null

    // extract metadata
    readonly property string appName: meta ? meta.name : "SysPeek"
    readonly property string appVersion: meta ? meta.version : ""
    readonly property string appDescription: meta ? meta.description : ""
    readonly property string appWebsite: meta ? meta.website : ""
    readonly property string appBugReport: meta ? meta.bugReportUrl : ""
    readonly property string appLicense: meta ? meta.license : ""
    readonly property string authorName: meta && meta.authors.length > 0 ? meta.authors[0].name : ""
    readonly property string authorEmail: meta && meta.authors.length > 0 ? meta.authors[0].emailAddress : ""

    contentHeight: aboutCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: aboutCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 20

        // ── hero section ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: heroCol.implicitHeight + 32
            Layout.topMargin: 8

            // subtle radial glow behind logo
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -20
                width: 180; height: 180; radius: 90
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.08) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            ColumnLayout {
                id: heroCol
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: 10

                // logo
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 72; Layout.preferredHeight: 72

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: Components.Theme.surfaceColor
                        border.color: Components.Theme.borderCol
                        border.width: 1

                        // top shimmer
                        Rectangle {
                            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                            height: parent.height * 0.5; radius: parent.radius
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.06) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "SP"
                            font.pixelSize: 26
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                            color: Components.Theme.accentCol
                        }
                    }
                }

                // name
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: page.appName
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    color: Components.Theme.textPrimary
                }

                // version badge
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: versionText.implicitWidth + 16
                    implicitHeight: 22
                    radius: 11
                    color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.12)
                    border.color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.25)
                    border.width: 1

                    Text {
                        id: versionText
                        anchors.centerIn: parent
                        text: "v" + page.appVersion
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        font.family: "monospace"
                        color: Components.Theme.accentCol
                    }
                }

                // description
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 2
                    text: page.appDescription
                    font.pixelSize: 12
                    color: Components.Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.5
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: 300
                }
            }
        }

        // ── author ──
        Components.SectionLabel { text: "AUTHOR" }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Developer"
                Text {
                    text: page.authorName
                    color: Components.Theme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
            Components.Divider {}
            Components.SettingRow {
                label: "Email"
                Text {
                    text: page.authorEmail
                    color: Components.Theme.accentCol
                    font.pixelSize: 13
                    font.family: "monospace"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("mailto:" + page.authorEmail)
                    }
                }
            }
        }

        // ── links ──
        Components.SectionLabel { text: "LINKS" }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Source Code"
                visible: page.appWebsite !== ""
                LinkButton {
                    text: "GitHub"
                    url: page.appWebsite
                }
            }
            Components.Divider { visible: page.appWebsite !== "" && page.appBugReport !== "" }
            Components.SettingRow {
                label: "Report Bug"
                visible: page.appBugReport !== ""
                LinkButton {
                    text: "Issues"
                    url: page.appBugReport
                }
            }
        }

        // ── license ──
        Components.SectionLabel { text: "LICENSE" }

        Components.Card {
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // license icon
                Rectangle {
                    Layout.preferredWidth: 32; Layout.preferredHeight: 32
                    radius: 8
                    color: Qt.rgba(Components.Theme.successCol.r, Components.Theme.successCol.g, Components.Theme.successCol.b, 0.1)

                    Text {
                        anchors.centerIn: parent
                        text: "\u2696"
                        font.pixelSize: 16
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: page.appLicense
                        color: Components.Theme.textPrimary
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    Text {
                        text: "Open source software"
                        color: Components.Theme.textTertiary
                        font.pixelSize: 11
                    }
                }
            }
        }

        // spacer
        Item { Layout.preferredHeight: 12 }
    }

    // ── inline link button ──
    component LinkButton: Rectangle {
        property string text
        property string url

        implicitWidth: linkRow.implicitWidth + 20
        implicitHeight: 28
        radius: 6
        color: linkMA.pressed ? Components.Theme.activeBg
             : linkMA.containsMouse ? Components.Theme.hoverBg : Components.Theme.controlBg
        border.color: linkMA.containsMouse ? Components.Theme.accentCol : Components.Theme.controlBorder
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Row {
            id: linkRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: parent.parent.text
                color: linkMA.containsMouse ? Components.Theme.accentCol : Components.Theme.textPrimary
                font.pixelSize: 12
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Text {
                text: "\u2197"
                color: linkMA.containsMouse ? Components.Theme.accentCol : Components.Theme.textTertiary
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        MouseArea {
            id: linkMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(parent.url)
        }
    }
}
