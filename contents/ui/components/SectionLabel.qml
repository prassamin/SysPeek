import QtQuick
import QtQuick.Layouts

Text {
    font.pixelSize: 11
    font.weight: Font.DemiBold
    font.letterSpacing: 1.2
    color: Theme.textTertiary

    HoverHandler {
        cursorShape: Qt.IBeamCursor
    }
}
