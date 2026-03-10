import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_launchCommand: launchCommand.text
    property alias cfg_itemSpacing: itemSpacing.value
    property alias cfg_iconTextSpacing: iconTextSpacing.value
    property alias cfg_horizontalPadding: horizontalPadding.value
    property alias cfg_verticalPadding: verticalPadding.value
    property int cfg_fontSize: 10
    property string cfg_fontFamily: ""
    property alias cfg_showCpu: showCpu.checked
    property alias cfg_showRam: showRam.checked
    property alias cfg_showSwap: showSwap.checked
    property alias cfg_showUpload: showUpload.checked
    property alias cfg_showDownload: showDownload.checked
    property alias cfg_widgetWidth: widgetWidth.value
    property string cfg_cpuColor: "#ffffff"
    property string cfg_ramColor: "#ffffff"
    property string cfg_swapColor: "#ffffff"
    property string cfg_uploadColor: "#ffffff"
    property string cfg_downloadColor: "#ffffff"
    property alias cfg_percentWarningThreshold: percentWarningThreshold.value
    property string cfg_percentWarningColor: "#ffa500"
    property alias cfg_percentCriticalThreshold: percentCriticalThreshold.value
    property string cfg_percentCriticalColor: "#ff0000"
    property alias cfg_speedWarningThreshold: speedWarningThreshold.value
    property string cfg_speedWarningColor: "#00ffff"
    property alias cfg_speedCriticalThreshold: speedCriticalThreshold.value
    property string cfg_speedCriticalColor: "#00ff00"

    Kirigami.FormLayout {
        id: configItem

        QQC2.TextField {
            id: launchCommand

            Kirigami.FormData.label: i18n("Launch Command")
            placeholderText: i18n("Enter your launch command")
            Layout.fillWidth: true
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Visibility")
        }

        QQC2.CheckBox {
            id: showCpu

            Kirigami.FormData.label: i18n("Show CPU")
        }

        QQC2.CheckBox {
            id: showRam

            Kirigami.FormData.label: i18n("Show RAM")
        }

        QQC2.CheckBox {
            id: showSwap

            Kirigami.FormData.label: i18n("Show Swap")
        }

        QQC2.CheckBox {
            id: showUpload

            Kirigami.FormData.label: i18n("Show Upload Speed")
        }

        QQC2.CheckBox {
            id: showDownload

            Kirigami.FormData.label: i18n("Show Download Speed")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Dimensions")
        }

        QQC2.SpinBox {
            id: widgetWidth

            Kirigami.FormData.label: i18n("Widget Width")
            from: 100
            to: 800
            stepSize: 10
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Spacing & Padding")
        }

        QQC2.SpinBox {
            id: itemSpacing

            Kirigami.FormData.label: i18n("Item Spacing")
            from: 0
            to: 50
            stepSize: 1
        }

        QQC2.SpinBox {
            id: iconTextSpacing

            Kirigami.FormData.label: i18n("Icon-Label Spacing")
            from: 0
            to: 20
            stepSize: 1
        }

        QQC2.SpinBox {
            id: horizontalPadding

            Kirigami.FormData.label: i18n("Horizontal Padding")
            from: 0
            to: 50
            stepSize: 1
        }

        QQC2.SpinBox {
            id: verticalPadding

            Kirigami.FormData.label: i18n("Vertical Padding")
            from: 0
            to: 50
            stepSize: 1
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Typography")
        }

        QQC2.SpinBox {
            id: fontSize

            Kirigami.FormData.label: i18n("Font Size")
            from: 6
            to: 48
            stepSize: 1
            value: cfg_fontSize
            onValueModified: cfg_fontSize = value
        }

        QQC2.ComboBox {
            id: fontFamily

            Kirigami.FormData.label: i18n("Font Family")
            Layout.fillWidth: true
            model: {
                let fonts = Qt.fontFamilies();
                fonts.unshift(i18n("System Default"));
                return fonts;
            }
            currentIndex: cfg_fontFamily === "" ? 0 : Math.max(0, model.indexOf(cfg_fontFamily))
            onActivated: cfg_fontFamily = (currentIndex === 0) ? "" : currentText
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Colors")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("CPU Color")

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_cpuColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: cpuColorDialog.open()
                }

            }

            ColorDialog {
                id: cpuColorDialog

                title: i18n("Select CPU Color")
                selectedColor: cfg_cpuColor
                onAccepted: cfg_cpuColor = selectedColor
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("RAM Color")

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_ramColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: ramColorDialog.open()
                }

            }

            ColorDialog {
                id: ramColorDialog

                title: i18n("Select RAM Color")
                selectedColor: cfg_ramColor
                onAccepted: cfg_ramColor = selectedColor
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Swap Color")

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_swapColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: swapColorDialog.open()
                }

            }

            ColorDialog {
                id: swapColorDialog

                title: i18n("Select Swap Color")
                selectedColor: cfg_swapColor
                onAccepted: cfg_swapColor = selectedColor
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Upload Color")

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_uploadColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: uploadColorDialog.open()
                }

            }

            ColorDialog {
                id: uploadColorDialog

                title: i18n("Select Upload Color")
                selectedColor: cfg_uploadColor
                onAccepted: cfg_uploadColor = selectedColor
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Download Color")

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_downloadColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: downloadColorDialog.open()
                }

            }

            ColorDialog {
                id: downloadColorDialog

                title: i18n("Select Download Color")
                selectedColor: cfg_downloadColor
                onAccepted: cfg_downloadColor = selectedColor
            }

        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("System Usage Thresholds (%)")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Usage Above")

            QQC2.SpinBox {
                id: percentWarningThreshold

                from: 1
                to: 100
            }

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_percentWarningColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: percentWarningColorDialog.open()
                }

            }

            ColorDialog {
                id: percentWarningColorDialog

                title: i18n("Select Usage Color")
                selectedColor: cfg_percentWarningColor
                onAccepted: cfg_percentWarningColor = selectedColor
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Usage Above")

            QQC2.SpinBox {
                id: percentCriticalThreshold

                from: 1
                to: 100
            }

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_percentCriticalColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: percentCriticalColorDialog.open()
                }

            }

            ColorDialog {
                id: percentCriticalColorDialog

                title: i18n("Select Usage Color")
                selectedColor: cfg_percentCriticalColor
                onAccepted: cfg_percentCriticalColor = selectedColor
            }

        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Network Speed Thresholds (MB/s)")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Speed Above")

            QQC2.SpinBox {
                id: speedWarningThreshold

                from: 1
                to: 1000
            }

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_speedWarningColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: speedWarningColorDialog.open()
                }

            }

            ColorDialog {
                id: speedWarningColorDialog

                title: i18n("Select Speed Color")
                selectedColor: cfg_speedWarningColor
                onAccepted: cfg_speedWarningColor = selectedColor
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Speed Above")

            QQC2.SpinBox {
                id: speedCriticalThreshold

                from: 1
                to: 1000
            }

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: cfg_speedCriticalColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: speedCriticalColorDialog.open()
                }

            }

            ColorDialog {
                id: speedCriticalColorDialog

                title: i18n("Select Speed Color")
                selectedColor: cfg_speedCriticalColor
                onAccepted: cfg_speedCriticalColor = selectedColor
            }

        }

    }

}
