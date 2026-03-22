pragma Singleton
import QtQuick

QtObject {
    readonly property color bgBase: Qt.rgba(0.05, 0.05, 0.08, 1)
    readonly property color surfaceColor: Qt.rgba(1, 1, 1, 0.045)
    readonly property color borderCol: Qt.rgba(1, 1, 1, 0.09)
    readonly property color accentCol: "#7c6aef"
    readonly property color accentDim: Qt.rgba(0.49, 0.42, 0.94, 0.25)
    readonly property color textPrimary: Qt.rgba(1, 1, 1, 0.88)
    readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.48)
    readonly property color textTertiary: Qt.rgba(1, 1, 1, 0.25)
    readonly property color controlBg: Qt.rgba(1, 1, 1, 0.06)
    readonly property color controlBorder: Qt.rgba(1, 1, 1, 0.10)
    readonly property color controlHover: Qt.rgba(1, 1, 1, 0.10)
    readonly property color hoverBg: Qt.rgba(1, 1, 1, 0.05)
    readonly property color activeBg: Qt.rgba(1, 1, 1, 0.08)
    readonly property color dangerCol: "#ff5f57"
    readonly property color successCol: "#2dd4a0"
}
