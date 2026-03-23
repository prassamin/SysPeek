import QtQuick 6.5
import QtQuick.Layouts 6.5
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg as KSvg
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root

    // override the default "Configure..." action to open our custom window
    PlasmaCore.Action {
        id: configureAction

        text: i18n("SysPeek Settings")
        icon.name: "configure"
        onTriggered: { settingsWindow.show(); settingsWindow.raise(); settingsWindow.requestActivate() }
    }

    Component.onCompleted: {
        Plasmoid.setInternalAction("configure", configureAction);
    }

    Settings {
        id: settingsWindow

        cfg: Plasmoid.configuration
        meta: Plasmoid.metaData
    }

    // whether we are on the desktop or in a panel
    readonly property bool isPlanar: Plasmoid.formFactor === PlasmaCore.Types.Planar
    // content based dimensions
    readonly property real contentWidth: rowLayout.implicitWidth + Plasmoid.configuration.horizontalPadding * 2
    readonly property real contentHeight: rowLayout.implicitHeight + Plasmoid.configuration.verticalPadding * 2

    function percent(val, total) {
        return total > 0 ? Math.round(val / total * 100) + "%" : "N/A";
    }

    function formatBytes(bytes) {
        let fmt = Plasmoid.configuration.netSpeedFormat;
        
        let unitB = (fmt === 2 || fmt === 3) ? "bps" : "B";
        let unitK = (fmt === 2 || fmt === 3) ? "Kbps" : "KB";
        let unitM = (fmt === 2 || fmt === 3) ? "Mbps" : "MB";
        let unitG = (fmt === 2 || fmt === 3) ? "Gbps" : "GB";
        let unitT = (fmt === 2 || fmt === 3) ? "Tbps" : "TB";
        
        let limits = [1024, 1.04858e+06, 1.07374e+09, 1.09951e+12];
        
        if (fmt === 1 || fmt === 3) {
            if (bytes < limits[0]) return bytes.toFixed(0) + " " + unitB;
            if (bytes < limits[1]) return (bytes / limits[0]).toFixed(1) + " " + unitK;
            if (bytes < limits[2]) return (bytes / limits[1]).toFixed(1) + " " + unitM;
            if (bytes < limits[3]) return (bytes / limits[2]).toFixed(1) + " " + unitG;
            return (bytes / limits[3]).toFixed(1) + " " + unitT;
        } else {
            if (bytes < limits[1]) return (bytes / limits[0]).toFixed(1) + " " + unitK;
            if (bytes < limits[2]) return (bytes / limits[1]).toFixed(1) + " " + unitM;
            if (bytes < limits[3]) return (bytes / limits[2]).toFixed(1) + " " + unitG;
            return (bytes / limits[3]).toFixed(1) + " " + unitT;
        }
    }

    function percentColor(val, baseColor) {
        const v = Math.trunc(val);
        if (v >= Plasmoid.configuration.percentCriticalThreshold)
            return Plasmoid.configuration.percentCriticalColor;

        if (v >= Plasmoid.configuration.percentWarningThreshold)
            return Plasmoid.configuration.percentWarningColor;

        return baseColor;
    }

    function speedColor(speed, baseColor) {
        if (speed >= Plasmoid.configuration.speedCriticalThreshold * 1024 * 1024)
            return Plasmoid.configuration.speedCriticalColor;

        if (speed >= Plasmoid.configuration.speedWarningThreshold * 1024 * 1024)
            return Plasmoid.configuration.speedWarningColor;

        return baseColor;
    }

    // on panel plasma draws background on desktop draw using Ksvg background
    Plasmoid.backgroundHints: isPlanar ? PlasmaCore.Types.NoBackground : (PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground)
    Layout.minimumWidth: isPlanar ? desktopBackground.width : (Plasmoid.configuration.useFixedWidth ? Plasmoid.configuration.widgetWidth : contentWidth)
    Layout.preferredWidth: isPlanar ? desktopBackground.width : (Plasmoid.configuration.useFixedWidth ? Plasmoid.configuration.widgetWidth : contentWidth)
    Layout.maximumWidth: isPlanar ? desktopBackground.width : (Plasmoid.configuration.useFixedWidth ? Plasmoid.configuration.widgetWidth : contentWidth)
    implicitWidth: isPlanar ? desktopBackground.width : (Plasmoid.configuration.useFixedWidth ? Plasmoid.configuration.widgetWidth : contentWidth)
    Layout.minimumHeight: isPlanar ? desktopBackground.height : contentHeight
    Layout.preferredHeight: isPlanar ? desktopBackground.height : contentHeight
    implicitHeight: isPlanar ? desktopBackground.height : contentHeight

    Plasma5Support.DataSource {
        id: executable

        function exec(cmd) {
            disconnectSource(cmd);
            connectSource(cmd);
        }

        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source);
        }
    }

    Sensors.Sensor {
        id: cpu

        sensorId: "cpu/all/usage"
    }

    Sensors.Sensor {
        id: ramUsed

        sensorId: "memory/physical/used"
    }

    Sensors.Sensor {
        id: ramTotal

        sensorId: "memory/physical/total"
    }

    Sensors.Sensor {
        id: swapUsed

        sensorId: "memory/swap/used"
    }

    Sensors.Sensor {
        id: swapTotal

        sensorId: "memory/swap/total"
    }

    Sensors.Sensor {
        id: netUp

        sensorId: "network/all/upload"
    }

    Sensors.Sensor {
        id: netDown

        sensorId: "network/all/download"
    }

    // desktop only background that sizes to content
    KSvg.FrameSvgItem {
        id: desktopBackground

        property int baseWidth: Plasmoid.configuration.useFixedWidth ? Plasmoid.configuration.widgetWidth : rowLayout.implicitWidth + Plasmoid.configuration.horizontalPadding * 2
        property int baseHeight: rowLayout.implicitHeight + Plasmoid.configuration.verticalPadding * 2

        visible: isPlanar
        imagePath: "widgets/background"
        anchors.centerIn: parent
        opacity: Plasmoid.configuration.bgOpacity / 100
        width: baseWidth + margins.left + margins.right
        height: baseHeight + margins.top + margins.bottom
    }

    RowLayout {
        id: rowLayout

        anchors.centerIn: parent
        spacing: Plasmoid.configuration.itemSpacing

        MonitorItem {
            visible: Plasmoid.configuration.showCpu
            icon: Qt.resolvedUrl("../icons/cpu.svg")
            label: cpu.value !== undefined ? Math.round(cpu.value) + "%" : "N/A"
            color: percentColor(cpu.value, Plasmoid.configuration.cpuColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showRam
            icon: Qt.resolvedUrl("../icons/memory.svg")
            label: (ramUsed.value !== undefined && ramTotal.value !== undefined) ? percent(ramUsed.value, ramTotal.value) : "N/A"
            color: percentColor((ramUsed.value / ramTotal.value * 100), Plasmoid.configuration.ramColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showSwap
            icon: Qt.resolvedUrl("../icons/swap.svg")
            label: (swapUsed.value !== undefined && swapTotal.value !== undefined) ? percent(swapUsed.value, swapTotal.value) : "N/A"
            color: percentColor((swapUsed.value / swapTotal.value * 100), Plasmoid.configuration.swapColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showUpload
            icon: Qt.resolvedUrl("../icons/up.svg")
            label: netUp.value !== undefined && formatBytes(netUp.value || 0)
            color: speedColor(netUp.value, Plasmoid.configuration.uploadColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showDownload
            icon: Qt.resolvedUrl("../icons/down.svg")
            label: netDown.value !== undefined && formatBytes(netDown.value || 0)
            color: speedColor(netDown.value, Plasmoid.configuration.downloadColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

    }

    // action types: 0 = Launch App, 1 = Open URL, 2 = Run Command, 3 = Do Nothing
    function performClickAction() {
        var action = Plasmoid.configuration.leftClickAction;
        if (action === 3) return;
        var value = action === 0 ? Plasmoid.configuration.leftClickAppValue
                  : action === 1 ? Plasmoid.configuration.leftClickUrlValue
                  : Plasmoid.configuration.leftClickCmdValue;
        if (!value) return;
        if (action === 1) Qt.openUrlExternally(value);
        else executable.exec(value);
    }

    MouseArea {
        anchors.fill: isPlanar ? desktopBackground : parent
        acceptedButtons: Qt.LeftButton
        onClicked: performClickAction()
    }

}
