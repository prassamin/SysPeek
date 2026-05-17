pragma Singleton
import QtQuick

QtObject {
    // Premium Obsidian Glassmorphism Backgrounds
    readonly property color bgBase: Qt.rgba(0.14, 0.15, 0.19, 0.88)
    readonly property color surfaceColor: Qt.rgba(1, 1, 1, 0.045)
    
    // High-End Subtle Borders
    readonly property color borderCol: Qt.rgba(1, 1, 1, 0.08)
    
    // Vibrant Glowing Violet Accent System
    readonly property color accentCol: "#818cf8"
    readonly property color accentDim: Qt.rgba(0.50, 0.55, 0.97, 0.15)
    readonly property color accentGlow: Qt.rgba(0.50, 0.55, 0.97, 0.08)

    // Silk White & Warm Lavender-Slate Typography
    readonly property color textPrimary: Qt.rgba(0.98, 0.98, 1.0, 0.95)
    readonly property color textSecondary: Qt.rgba(0.74, 0.76, 0.89, 0.65)
    readonly property color textTertiary: Qt.rgba(0.74, 0.76, 0.89, 0.35)
    
    // Elegant Translucent Control Elements
    readonly property color controlBg: Qt.rgba(1, 1, 1, 0.04)
    readonly property color controlBorder: Qt.rgba(1, 1, 1, 0.06)
    readonly property color controlHover: Qt.rgba(1, 1, 1, 0.08)
    readonly property color hoverBg: Qt.rgba(1, 1, 1, 0.04)
    readonly property color activeBg: Qt.rgba(1, 1, 1, 0.07)
    
    // Harmonized State Colors
    readonly property color dangerCol: "#f43f5e"   // Premium Rose Red
    readonly property color successCol: "#10b981"  // Premium Emerald Green
    readonly property color warningCol: "#f59e0b"  // Premium Amber Yellow
}
