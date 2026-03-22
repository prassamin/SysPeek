import QtQuick
import QtQuick.Effects

Item {
    id: toggleRoot
    property bool checked: false
    signal toggled()

    implicitWidth: 46
    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: 13
        color: toggleRoot.checked ? Theme.accentCol : Qt.rgba(1, 1, 1, 0.08)
        border.color: toggleRoot.checked ? Qt.lighter(Theme.accentCol, 1.3) : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        // glow behind when active
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 16
            color: "transparent"
            border.color: toggleRoot.checked ? Theme.accentDim : "transparent"
            border.width: 2
            Behavior on border.color { ColorAnimation { duration: 300 } }
        }

        // thumb
        Rectangle {
            id: thumb
            y: 3
            x: toggleRoot.checked ? parent.width - width - 3 : 3
            width: 20
            height: 20
            radius: 10
            color: "white"

            // subtle shadow
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 0.3
                shadowVerticalOffset: 1
            }

            Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { toggleRoot.checked = !toggleRoot.checked; toggleRoot.toggled() }
    }
}
