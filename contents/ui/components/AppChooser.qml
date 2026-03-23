import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Effects
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: chooserRoot

    property Item edgeSafeContainer: null
    signal appSelected(string command)

    implicitWidth: 34
    implicitHeight: 34

    property var appList: []
    property bool scanned: false

    Plasma5Support.DataSource {
        id: scanner
        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source);
            var stdout = data["stdout"] || "";
            if (!stdout) { chooserRoot.scanned = true; return; }
            var lines = stdout.trim().split("\n");
            var apps = [];
            var seen = {};
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split("|||");
                if (parts.length >= 2) {
                    var name = parts[0].trim();
                    var exec = parts[1].trim();
                    var icon = parts.length >= 3 ? parts[2].trim() : "";
                    if (name && exec && !seen[exec]) {
                        seen[exec] = true;
                        apps.push({ name: name, exec: exec, icon: icon });
                    }
                }
            }
            chooserRoot.appList = apps;
            chooserRoot.scanned = true;
        }
    }

    Component.onCompleted: {
        var cmd = "find /usr/share/applications $HOME/.local/share/applications /var/lib/flatpak/exports/share/applications $HOME/.local/share/flatpak/exports/share/applications /var/lib/snapd/desktop/applications -maxdepth 3 -name '*.desktop' -type f 2>/dev/null | while IFS= read -r f; do grep -q '^NoDisplay=true' \"$f\" && continue; grep -q '^Hidden=true' \"$f\" && continue; grep -q '^Type=Application' \"$f\" || continue; n=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); e=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed 's/ %[fFuUdDnNickvm]//g; s/[[:space:]]*$//'); i=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); [ -n \"$n\" ] && [ -n \"$e\" ] && printf '%s|||%s|||%s\\n' \"$n\" \"$e\" \"$i\"; done | sort -f -u";
        scanner.connectSource(cmd);
    }

    function open() {
        if (!edgeSafeContainer) return;
        popupLoader.active = true;
    }

    function close() {
        popupLoader.active = false;
    }

    // browse button
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: btnMA.containsMouse ? Theme.controlHover : Theme.controlBg
        border.color: Theme.controlBorder
        border.width: 1
        Behavior on color { ColorAnimation { duration: 150 } }

        Kirigami.Icon {
            anchors.centerIn: parent
            width: 16; height: 16
            source: "view-list-details"
            color: Theme.textSecondary
            isMask: true
        }
    }

    MouseArea {
        id: btnMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chooserRoot.open()
    }

    // popup loaded into edgeSafeContainer
    Loader {
        id: popupLoader
        active: false
        sourceComponent: popupComponent
        onLoaded: item.parent = chooserRoot.edgeSafeContainer
    }

    Component {
        id: popupComponent

        Item {
            anchors.fill: parent
            z: 99999

            property string searchText: searchInput.text.toLowerCase()

            property var filteredApps: {
                var q = searchText;
                if (!q) return chooserRoot.appList;
                return chooserRoot.appList.filter(function(app) {
                    return app.name.toLowerCase().indexOf(q) !== -1 ||
                           app.exec.toLowerCase().indexOf(q) !== -1;
                });
            }

            // backdrop
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)

                MouseArea {
                    anchors.fill: parent
                    onClicked: chooserRoot.close()
                }
            }

            // dialog card
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width - 48, 440)
                height: Math.min(parent.height - 48, 500)
                radius: 14
                color: Theme.bgBase
                border.color: Theme.borderCol
                border.width: 1

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#80000000"
                    shadowBlur: 1.0
                    shadowVerticalOffset: 8
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // header
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Choose Application"
                            color: Theme.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 26; height: 26; radius: 999
                            color: dialogCloseMA.containsMouse ? Theme.hoverBg : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "\u2715"
                                color: Theme.textSecondary
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: dialogCloseMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: chooserRoot.close()
                            }
                        }
                    }

                    // search box
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 36

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: Theme.controlBg
                            border.color: searchInput.activeFocus ? Theme.accentCol : Theme.controlBorder
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 6

                            Kirigami.Icon {
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                                source: "search"
                                color: Theme.textTertiary
                                isMask: true
                            }

                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.textPrimary
                                selectionColor: Theme.accentCol
                                selectedTextColor: "white"
                                font.pixelSize: 13
                                clip: true
                                focus: true
                                HoverHandler { cursorShape: Qt.IBeamCursor }

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Search applications\u2026"
                                    color: Theme.textTertiary
                                    font.pixelSize: 13
                                    visible: !searchInput.text && !searchInput.activeFocus
                                }
                            }
                        }
                    }

                    // app list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: Theme.surfaceColor
                        border.color: Theme.borderCol
                        border.width: 1
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: !chooserRoot.scanned
                            text: "Loading applications\u2026"
                            color: Theme.textTertiary
                            font.pixelSize: 12
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: chooserRoot.scanned && filteredApps.length === 0
                            text: searchInput.text ? "No matching applications" : "No applications found"
                            color: Theme.textTertiary
                            font.pixelSize: 12
                        }

                        ListView {
                            id: appListView
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            model: filteredApps

                            QQC2.ScrollBar.vertical: QQC2.ScrollBar {
                                policy: appListView.contentHeight > appListView.height ? QQC2.ScrollBar.AsNeeded : QQC2.ScrollBar.AlwaysOff
                            }

                            delegate: Rectangle {
                                width: appListView.width
                                height: 44
                                radius: 8
                                color: appItemMA.containsMouse ? Theme.controlHover : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Kirigami.Icon {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        source: modelData.icon || "application-x-executable"
                                        fallback: "application-x-executable"
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: Theme.textPrimary
                                            font.pixelSize: 13
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.exec
                                            color: Theme.textTertiary
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                MouseArea {
                                    id: appItemMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        chooserRoot.appSelected(modelData.exec);
                                        chooserRoot.close();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
