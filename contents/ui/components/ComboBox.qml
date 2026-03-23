import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: comboRoot
    property var model: []
    property int currentIndex: 0
    property string displayText: model[currentIndex] || ""
    property Item edgeSafeContainer: null
    signal activated(int index)

    implicitWidth: 200
    implicitHeight: 34

    function openPopup() {
        if (!edgeSafeContainer) return;
        let pos = comboRoot.mapToItem(edgeSafeContainer, 0, 0);
        popupLoader.popupX = pos.x;
        popupLoader.popupY = pos.y + comboRoot.height + 4;
        popupLoader.popupWidth = comboRoot.width;

        // check if dropdown would overflow bottom
        let dropH = Math.min(comboRoot.model.length * 32 + 8, 260);
        if (popupLoader.popupY + dropH > edgeSafeContainer.height - 8)
            popupLoader.popupY = pos.y - dropH - 4;

        popupLoader.active = true;
    }

    function closePopup() {
        popupLoader.active = false;
    }

    readonly property bool popupVisible: popupLoader.active

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: comboMA.containsMouse ? Theme.controlHover : Theme.controlBg
        border.color: comboRoot.popupVisible ? Theme.accentCol : Theme.controlBorder
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 10
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: comboRoot.displayText
                color: Theme.textPrimary
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            Text {
                text: "\u25BE"
                color: Theme.textSecondary
                font.pixelSize: 12
            }
        }
    }

    MouseArea {
        id: comboMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (comboRoot.popupVisible)
                comboRoot.closePopup();
            else
                comboRoot.openPopup();
        }
    }

    // popup is loaded inside edgeSafeContainer so it renders above everything
    Loader {
        id: popupLoader
        active: false

        property real popupX: 0
        property real popupY: 0
        property real popupWidth: 200

        sourceComponent: popupComponent
        onLoaded: {
            item.parent = comboRoot.edgeSafeContainer;
        }
    }

    Component {
        id: popupComponent

        Item {
            id: popupOverlay
            anchors.fill: parent
            z: 9999

            // click-outside-to-close
            MouseArea {
                anchors.fill: parent
                onClicked: comboRoot.closePopup()
            }

            Rectangle {
                id: comboPopup
                x: popupLoader.popupX
                y: popupLoader.popupY
                width: popupLoader.popupWidth
                radius: 10
                color: Qt.rgba(0.08, 0.08, 0.12, 1)
                border.color: Theme.borderCol
                border.width: 1

                readonly property real maxHeight: 260
                height: Math.min(popupCol.implicitHeight + 8, maxHeight)
                clip: true

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#60000000"
                    shadowBlur: 0.6
                    shadowVerticalOffset: 4
                }

                Flickable {
                    id: popupFlick
                    anchors.fill: parent
                    anchors.margins: 4
                    contentHeight: popupCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    QQC2.ScrollBar.vertical: QQC2.ScrollBar {
                        policy: popupFlick.contentHeight > popupFlick.height ? QQC2.ScrollBar.AsNeeded : QQC2.ScrollBar.AlwaysOff
                    }

                    Column {
                        id: popupCol
                        width: popupFlick.width
                        spacing: 0

                        Repeater {
                            model: comboRoot.model
                            delegate: Rectangle {
                                width: popupCol.width
                                height: 32
                                radius: 6
                                color: optMA.containsMouse ? Theme.controlHover : (comboRoot.currentIndex === index ? Theme.activeBg : "transparent")

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData
                                    color: comboRoot.currentIndex === index ? Theme.accentCol : Theme.textPrimary
                                    font.pixelSize: 12
                                    font.weight: comboRoot.currentIndex === index ? Font.Medium : Font.Normal
                                }

                                MouseArea {
                                    id: optMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        comboRoot.currentIndex = index;
                                        comboRoot.activated(index);
                                        comboRoot.closePopup();
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
