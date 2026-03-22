import QtQuick
import QtQuick.Layouts
import "../components" as Components

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null

    contentHeight: typoCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: typoCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 18

        Components.SectionLabel { text: "FONT" }

        Components.Card {
            Layout.fillWidth: true
            Components.SettingRow { label: "Size"; Components.SpinBox { from: 6; to: 48; value: cfg.fontSize; onValueModified: cfg.fontSize = value } }
            Components.Divider {}
            Components.SettingRow {
                label: "Family"
                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    implicitWidth: 200
                    model: {
                        let f = Qt.fontFamilies();
                        f.unshift("System Default");
                        return f;
                    }
                    currentIndex: cfg.fontFamily === "" ? 0 : Math.max(0, model.indexOf(cfg.fontFamily))
                    onActivated: function(i) { cfg.fontFamily = (i === 0) ? "" : model[i] }
                }
            }
        }
    }
}
