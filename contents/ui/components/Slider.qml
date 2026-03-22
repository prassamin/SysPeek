import QtQuick

Item {
    id: sliderRoot
    property real value: 0
    property real from: 0
    property real to: 100
    property real stepSize: 1
    signal moved()

    implicitWidth: 200
    implicitHeight: 30

    readonly property real ratio: Math.max(0, Math.min(1, (value - from) / (to - from)))
    readonly property bool isActive: sliderMA.pressed
    readonly property bool isHovered: sliderMA.containsMouse
    readonly property real fillWidth: ratio * capsule.width

    // ── outer glow (visible on hover / drag) ──
    Rectangle {
        anchors.fill: capsule
        anchors.margins: -3
        radius: capsule.radius + 3
        color: "transparent"
        border.color: Theme.accentDim
        border.width: 2
        opacity: isActive ? 0.7 : isHovered ? 0.35 : 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    // ── capsule (the main bar) ──
    Rectangle {
        id: capsule
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.04)
        border.color: Qt.rgba(1, 1, 1, isHovered ? 0.12 : 0.07)
        border.width: 1
        clip: true

        Behavior on border.color { ColorAnimation { duration: 200 } }

        // ── filled portion ──
        Rectangle {
            id: fill
            width: sliderRoot.fillWidth
            height: parent.height
            radius: parent.radius
            color: Theme.accentCol

            Behavior on width { enabled: !isActive; NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            //  shimmer on fill
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.22) }
                    GradientStop { position: 0.45; color: Qt.rgba(1, 1, 1, 0.05) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // animated shimmer sweep
            Rectangle {
                id: shimmer
                width: parent.width * 0.3
                height: parent.height
                radius: parent.radius
                x: isHovered ? parent.width : -width
                opacity: 0.15
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "white" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                Behavior on x { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
            }
        }

        // ── blade edge (glowing vertical line at fill boundary) ──
        Rectangle {
            id: blade
            x: sliderRoot.fillWidth - 1
            width: 2
            height: parent.height
            visible: sliderRoot.ratio > 0.01 && sliderRoot.ratio < 0.99
            color: "white"
            opacity: isActive ? 0.9 : 0.5

            Behavior on opacity { NumberAnimation { duration: 150 } }

            // blade glow
            Rectangle {
                anchors.centerIn: parent
                width: isActive ? 12 : 6
                height: parent.height
                color: Theme.accentCol
                opacity: 0.4
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }
        }

        // ── scale marks (subtle dots along the bar) ──
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: parent.radius
            anchors.rightMargin: parent.radius

            Repeater {
                model: 9
                Item {
                    width: (capsule.width - capsule.radius * 2) / 9
                    height: capsule.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: 3
                        height: 3
                        radius: 1.5
                        color: {
                            let markRatio = (index + 1) / 10;
                            if (markRatio < sliderRoot.ratio)
                                return Qt.rgba(1, 1, 1, 0.3);
                            return Qt.rgba(1, 1, 1, 0.07);
                        }
                    }
                }
            }
        }

        // ── value text (floats inside the bar) ──
        Text {
            anchors.centerIn: parent
            text: Math.round(sliderRoot.value) + "%"
            font.pixelSize: 11
            font.weight: Font.Bold
            font.family: "monospace"
            font.letterSpacing: 0.5
            color: sliderRoot.ratio > 0.55
                   ? Qt.rgba(1, 1, 1, 0.9)
                   : sliderRoot.ratio > 0.35
                     ? Theme.accentCol
                     : Theme.textSecondary
            opacity: isActive || isHovered ? 1.0 : 0.7

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    MouseArea {
        id: sliderMA
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateValue(mouseX) {
            let r = Math.max(0, Math.min(1, mouseX / sliderRoot.width));
            let raw = sliderRoot.from + r * (sliderRoot.to - sliderRoot.from);
            let stepped = Math.round(raw / sliderRoot.stepSize) * sliderRoot.stepSize;
            sliderRoot.value = Math.max(sliderRoot.from, Math.min(sliderRoot.to, stepped));
            sliderRoot.moved();
        }

        onPressed: function(mouse) { updateValue(mouse.x) }
        onPositionChanged: function(mouse) { if (pressed) updateValue(mouse.x) }
        onWheel: function(event) {
            if (event.angleDelta.y > 0 && sliderRoot.value + sliderRoot.stepSize <= sliderRoot.to) {
                sliderRoot.value += sliderRoot.stepSize;
                sliderRoot.moved();
            } else if (event.angleDelta.y < 0 && sliderRoot.value - sliderRoot.stepSize >= sliderRoot.from) {
                sliderRoot.value -= sliderRoot.stepSize;
                sliderRoot.moved();
            }
        }
    }
}
