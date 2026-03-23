pragma Singleton
import QtQuick

QtObject {
    readonly property color bgBase: Qt.rgba(0.11, 0.11, 0.14, 1)
    readonly property color surfaceColor: Qt.rgba(1, 1, 1, 0.055)
    readonly property color borderCol: Qt.rgba(1, 1, 1, 0.12)
    readonly property color accentCol: "#8b7cf6"
    readonly property color accentDim: Qt.rgba(0.55, 0.49, 0.96, 0.2)
    readonly property color textPrimary: Qt.rgba(1, 1, 1, 0.92)
    readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.55)
    readonly property color textTertiary: Qt.rgba(1, 1, 1, 0.3)
    readonly property color controlBg: Qt.rgba(1, 1, 1, 0.07)
    readonly property color controlBorder: Qt.rgba(1, 1, 1, 0.12)
    readonly property color controlHover: Qt.rgba(1, 1, 1, 0.12)
    readonly property color hoverBg: Qt.rgba(1, 1, 1, 0.06)
    readonly property color activeBg: Qt.rgba(1, 1, 1, 0.1)
    readonly property color dangerCol: "#ff6b6b"
    readonly property color successCol: "#34d399"
}
