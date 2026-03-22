import QtQuick
import QtQuick.Layouts

Item {
    id: spinRoot
    property int value: 0
    property int from: 0
    property int to: 100
    property int stepSize: 1
    signal valueModified()

    implicitWidth: 116
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.controlBg
        border.color: Theme.controlBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // minus
            Item {
                Layout.preferredWidth: 32
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: "\u2212"
                    color: minusMA.containsMouse ? Theme.textPrimary : Theme.textSecondary
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: minusMA.pressed ? Theme.controlHover : "transparent"
                }

                MouseArea {
                    id: minusMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (spinRoot.value - spinRoot.stepSize >= spinRoot.from) {
                            spinRoot.value -= spinRoot.stepSize;
                            spinRoot.valueModified();
                            spinInput.text = spinRoot.value;
                        }
                    }
                }
            }

            // separator
            Rectangle { width: 1; Layout.fillHeight: true; Layout.topMargin: 6; Layout.bottomMargin: 6; color: Theme.borderCol }

            // editable value
            TextInput {
                id: spinInput
                Layout.fillWidth: true
                color: Theme.textPrimary
                font.pixelSize: 13
                font.weight: Font.Medium
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                cursorVisible: activeFocus
                selectByMouse: true
                HoverHandler { cursorShape: Qt.IBeamCursor }
                selectionColor: Theme.accentCol
                selectedTextColor: "white"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator { bottom: spinRoot.from; top: spinRoot.to }

                // sync display from value when not editing
                property bool editing: activeFocus
                text: spinRoot.value
                onEditingChanged: {
                    if (!editing) {
                        // commit on focus loss
                        _commitText();
                    }
                }
                onTextChanged: {
                    if (editing) {
                        let n = parseInt(text);
                        if (!isNaN(n) && n >= spinRoot.from && n <= spinRoot.to) {
                            spinRoot.value = n;
                            spinRoot.valueModified();
                        }
                    }
                }
                // also commit on Enter
                Keys.onReturnPressed: { _commitText(); focus = false; }
                Keys.onEnterPressed: { _commitText(); focus = false; }

                function _commitText() {
                    let n = parseInt(text);
                    if (isNaN(n)) n = spinRoot.from;
                    n = Math.max(spinRoot.from, Math.min(spinRoot.to, n));
                    spinRoot.value = n;
                    spinRoot.valueModified();
                    text = spinRoot.value;
                }

                Keys.onUpPressed: {
                    if (spinRoot.value + spinRoot.stepSize <= spinRoot.to) {
                        spinRoot.value += spinRoot.stepSize;
                        spinRoot.valueModified();
                        text = spinRoot.value;
                    }
                }
                Keys.onDownPressed: {
                    if (spinRoot.value - spinRoot.stepSize >= spinRoot.from) {
                        spinRoot.value -= spinRoot.stepSize;
                        spinRoot.valueModified();
                        text = spinRoot.value;
                    }
                }
            }

            // separator
            Rectangle { width: 1; Layout.fillHeight: true; Layout.topMargin: 6; Layout.bottomMargin: 6; color: Theme.borderCol }

            // plus
            Item {
                Layout.preferredWidth: 32
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: plusMA.containsMouse ? Theme.textPrimary : Theme.textSecondary
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: plusMA.pressed ? Theme.controlHover : "transparent"
                }

                MouseArea {
                    id: plusMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (spinRoot.value + spinRoot.stepSize <= spinRoot.to) {
                            spinRoot.value += spinRoot.stepSize;
                            spinRoot.valueModified();
                            spinInput.text = spinRoot.value;
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.IBeamCursor
        onWheel: function(event) {
            if (event.angleDelta.y > 0 && spinRoot.value + spinRoot.stepSize <= spinRoot.to) {
                spinRoot.value += spinRoot.stepSize;
                spinRoot.valueModified();
                spinInput.text = spinRoot.value;
            } else if (event.angleDelta.y < 0 && spinRoot.value - spinRoot.stepSize >= spinRoot.from) {
                spinRoot.value -= spinRoot.stepSize;
                spinRoot.valueModified();
                spinInput.text = spinRoot.value;
            }
        }
    }
}
