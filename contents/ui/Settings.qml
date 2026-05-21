import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import "components" as Components
import org.kde.kirigami as Kirigami
import "pages"

Window {
    // ═══════════════════════════════════════════════
    //  WINDOW CHROME
    // ═══════════════════════════════════════════════
    // ═══════════════════════════════════════════════
    //  EDGE RESIZE HANDLES
    // ═══════════════════════════════════════════════

    id: root

    property var cfg
    property var meta
    property int currentPage: 0
    readonly property var pages: [{
        "title": "General",
        "icon": "preferences-system"
    }, {
        "title": "Layout",
        "icon": "distribute-horizontal"
    }, {
        "title": "Placement",
        "icon": "view-grid"
    }, {
        "title": "Modules",
        "icon": "application-x-addon"
    }, {
        "title": "Typography",
        "icon": "preferences-desktop-font"
    }, {
        "title": "About",
        "icon": "help-about"
    }]
    readonly property int _edge: 6

    title: "SysPeek"
    width: 720
    height: 560
    minimumWidth: 580
    minimumHeight: 420
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Dialog

    Shortcut {
        sequence: "Escape"
        onActivated: root.close()
    }

    FocusScope {
        id: bg

        objectName: "bg"
        anchors.fill: parent
        focus: true

        Rectangle {
            // ═══════════════════════════════════════════════
            //  BODY
            // ═══════════════════════════════════════════════

            anchors.fill: parent
            radius: 12
            color: Components.Theme.bgBase
            border.color: Components.Theme.borderCol
            border.width: 1
            layer.enabled: true

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: function(mouse) {
                    bg.forceActiveFocus();
                    mouse.accepted = false;
                }
            }

            // ── title bar ──
            Rectangle {
                id: titleBar

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onPressed: function(mouse) {
                        bg.forceActiveFocus();
                        mouse.accepted = false;
                    }
                }

                DragHandler {
                    target: null
                    onActiveChanged: {
                        if (active) {
                            root.startSystemMove();
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "SysPeek"
                    color: Components.Theme.textSecondary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.letterSpacing: 0.3
                }

                // ── window controls (right side) ──
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    // minimize
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 999
                        color: minimizeMA.pressed ? Components.Theme.activeBg : minimizeMA.containsMouse ? Components.Theme.hoverBg : "transparent"

                        // dash icon
                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 1.5
                            radius: 1
                            color: minimizeMA.containsMouse ? Components.Theme.textPrimary : Components.Theme.textTertiary

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                        MouseArea {
                            id: minimizeMA

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showMinimized()
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                    // maximize / restore
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 999
                        color: maximizeMA.pressed ? Components.Theme.activeBg : maximizeMA.containsMouse ? Components.Theme.hoverBg : "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 9
                            height: 9
                            radius: 1.5
                            color: "transparent"
                            border.color: maximizeMA.containsMouse ? Components.Theme.textPrimary : Components.Theme.textTertiary
                            border.width: 1.5

                            // filled corner indicator when maximized
                            Rectangle {
                                visible: root.visibility === Window.Maximized
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: -3
                                anchors.rightMargin: -3
                                width: 5
                                height: 5
                                radius: 1
                                color: "transparent"
                                border.color: maximizeMA.containsMouse ? Components.Theme.textPrimary : Components.Theme.textTertiary
                                border.width: 1.5
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                        MouseArea {
                            id: maximizeMA

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.visibility === Window.Maximized)
                                    root.showNormal();
                                else
                                    root.showMaximized();
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                    // close
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 999
                        color: closeMA.pressed ? Qt.rgba(Components.Theme.dangerCol.r, Components.Theme.dangerCol.g, Components.Theme.dangerCol.b, 0.25) : closeMA.containsMouse ? Qt.rgba(Components.Theme.dangerCol.r, Components.Theme.dangerCol.g, Components.Theme.dangerCol.b, 0.12) : "transparent"

                        // X icon drawn with two thin rotated bars
                        Item {
                            anchors.centerIn: parent
                            width: 10
                            height: 10

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 1.5
                                radius: 1
                                rotation: 45
                                color: closeMA.containsMouse ? Components.Theme.dangerCol : Components.Theme.textTertiary

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }

                                }

                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 1.5
                                radius: 1
                                rotation: -45
                                color: closeMA.containsMouse ? Components.Theme.dangerCol : Components.Theme.textTertiary

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }

                                }

                            }

                        }

                        MouseArea {
                            id: closeMA

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                }

            }

            Rectangle {
                id: titleSep

                anchors.top: titleBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Components.Theme.borderCol
            }

            RowLayout {
                // ═══════════════════════════════════════════════
                //  PAGES
                // ═══════════════════════════════════════════════

                anchors.top: titleSep.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 0

                // ── sidebar ──
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 170
                    color: Qt.rgba(1, 1, 1, 0.02)

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onPressed: function(mouse) {
                            bg.forceActiveFocus();
                            mouse.accepted = false;
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 30

                        gradient: Gradient {
                            orientation: Gradient.Horizontal

                            GradientStop {
                                position: 0
                                color: "transparent"
                            }

                            GradientStop {
                                position: 1
                                color: Qt.rgba(0, 0, 0, 0.05)
                            }

                        }

                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2

                        Repeater {
                            model: root.pages

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                radius: 10
                                color: root.currentPage === index ? Components.Theme.activeBg : sidebarMA.containsMouse ? Components.Theme.hoverBg : "transparent"

                                Rectangle {
                                    visible: root.currentPage === index
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 3
                                    height: 20
                                    radius: 2
                                    color: Components.Theme.accentCol

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 7
                                        height: 24
                                        radius: 4
                                        color: Components.Theme.accentDim
                                        z: -1
                                    }

                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 8
                                    spacing: 10

                                    Kirigami.Icon {
                                        source: modelData.icon
                                        Layout.preferredWidth: 18
                                        Layout.preferredHeight: 18
                                        color: root.currentPage === index ? Components.Theme.accentCol : Components.Theme.textSecondary
                                        isMask: true

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                            }

                                        }

                                    }

                                    Text {
                                        text: modelData.title
                                        color: root.currentPage === index ? Components.Theme.textPrimary : Components.Theme.textSecondary
                                        font.pixelSize: 13
                                        font.weight: root.currentPage === index ? Font.Medium : Font.Normal
                                        Layout.fillWidth: true

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                            }

                                        }

                                    }

                                }

                                MouseArea {
                                    id: sidebarMA

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentPage = index
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }

                                }

                            }

                        }

                        Item {
                            Layout.fillHeight: true
                        }

                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: Components.Theme.borderCol
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: root.currentPage

                    GeneralPage {
                        cfg: root.cfg
                        edgeSafeContainer: bg
                    }

                    LayoutPage {
                        cfg: root.cfg
                        edgeSafeContainer: bg
                    }

                    PlacementPage {
                        cfg: root.cfg
                        edgeSafeContainer: bg
                    }

                    ModulesPage {
                        cfg: root.cfg
                        edgeSafeContainer: bg
                    }

                    TypographyPage {
                        cfg: root.cfg
                        edgeSafeContainer: bg
                    }

                    AboutPage {
                        cfg: root.cfg
                        edgeSafeContainer: bg
                        meta: root.meta
                    }

                }

            }

        }

    }

    // edges
    MouseArea {
        z: 999
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root._edge
        cursorShape: Qt.SizeVerCursor
        onPressed: root.startSystemResize(Qt.TopEdge)
    }

    MouseArea {
        z: 999
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root._edge
        cursorShape: Qt.SizeVerCursor
        onPressed: root.startSystemResize(Qt.BottomEdge)
    }

    MouseArea {
        z: 999
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root._edge
        cursorShape: Qt.SizeHorCursor
        onPressed: root.startSystemResize(Qt.LeftEdge)
    }

    MouseArea {
        z: 999
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root._edge
        cursorShape: Qt.SizeHorCursor
        onPressed: root.startSystemResize(Qt.RightEdge)
    }

    // corners (on top of edges)
    MouseArea {
        z: 1000
        anchors.top: parent.top
        anchors.left: parent.left
        width: root._edge * 2
        height: root._edge * 2
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.startSystemResize(Qt.TopEdge | Qt.LeftEdge)
    }

    MouseArea {
        z: 1000
        anchors.top: parent.top
        anchors.right: parent.right
        width: root._edge * 2
        height: root._edge * 2
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.startSystemResize(Qt.TopEdge | Qt.RightEdge)
    }

    MouseArea {
        z: 1000
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root._edge * 2
        height: root._edge * 2
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.startSystemResize(Qt.BottomEdge | Qt.LeftEdge)
    }

    MouseArea {
        z: 1000
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root._edge * 2
        height: root._edge * 2
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
    }

}
