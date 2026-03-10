import QtQuick 6.5
import QtQuick.Controls 2.5
import QtQuick.Layouts 6.5
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root

    property int forcedWidth: Plasmoid.configuration.widgetWidth

    function percent(val, total) {
        return total > 0 ? Math.round(val / total * 100) + "%" : "N/A";
    }

    function formatBytes(bytes) {
        if (bytes < 1024)
            return (bytes / 1024).toFixed(1) + " KB";

        if (bytes < 1.04858e+06)
            return (bytes / 1024).toFixed(1) + " KB";

        if (bytes < 1.07374e+09)
            return (bytes / 1.04858e+06).toFixed(1) + " MB";

        return (bytes / 1.07374e+09).toFixed(1) + " GB";
    }

    function percentColor(val, baseColor) {
        if (!Plasmoid.configuration.useDynamicColors)
            return baseColor;

        const v = Math.trunc(val);
        if (v >= Plasmoid.configuration.percentCriticalThreshold)
            return Plasmoid.configuration.percentCriticalColor;

        if (v >= Plasmoid.configuration.percentWarningThreshold)
            return Plasmoid.configuration.percentWarningColor;

        return baseColor;
    }

    function speedColor(speed, baseColor) {
        if (!Plasmoid.configuration.useDynamicColors)
            return baseColor;

        if (speed >= Plasmoid.configuration.speedCriticalThreshold * 1024 * 1024)
            return Plasmoid.configuration.speedCriticalColor;

        if (speed >= Plasmoid.configuration.speedWarningThreshold * 1024 * 1024)
            return Plasmoid.configuration.speedWarningColor;

        return baseColor;
    }

    width: forcedWidth
    Layout.preferredWidth: forcedWidth
    Layout.minimumWidth: forcedWidth
    Layout.maximumWidth: forcedWidth
    implicitHeight: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

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

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        anchors.leftMargin: Plasmoid.configuration.horizontalPadding
        anchors.rightMargin: Plasmoid.configuration.horizontalPadding
        anchors.topMargin: Plasmoid.configuration.verticalPadding
        anchors.bottomMargin: Plasmoid.configuration.verticalPadding
        spacing: Plasmoid.configuration.itemSpacing

        MonitorItem {
            visible: Plasmoid.configuration.showCpu
            icon: Qt.resolvedUrl("../icons/cpu.svg")
            label: cpu.value !== undefined ? Math.round(cpu.value) + "%" : "N/A"
            color: percentColor(cpu.value, Plasmoid.configuration.useCustomColors ? Plasmoid.configuration.cpuColor : Kirigami.Theme.textColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showRam
            icon: Qt.resolvedUrl("../icons/memory.svg")
            label: (ramUsed.value !== undefined && ramTotal.value !== undefined) ? percent(ramUsed.value, ramTotal.value) : "N/A"
            color: percentColor((ramUsed.value / ramTotal.value * 100), Plasmoid.configuration.useCustomColors ? Plasmoid.configuration.ramColor : Kirigami.Theme.textColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showSwap
            icon: Qt.resolvedUrl("../icons/swap.svg")
            label: (swapUsed.value !== undefined && swapTotal.value !== undefined) ? percent(swapUsed.value, swapTotal.value) : "N/A"
            color: percentColor((swapUsed.value / swapTotal.value * 100), Plasmoid.configuration.useCustomColors ? Plasmoid.configuration.swapColor : Kirigami.Theme.textColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showUpload
            icon: Qt.resolvedUrl("../icons/up.svg")
            label: netUp.value !== undefined && formatBytes(netUp.value || 0)
            color: speedColor(netUp.value, Plasmoid.configuration.useCustomColors ? Plasmoid.configuration.uploadColor : Kirigami.Theme.textColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

        MonitorItem {
            visible: Plasmoid.configuration.showDownload
            icon: Qt.resolvedUrl("../icons/down.svg")
            label: netDown.value !== undefined && formatBytes(netDown.value || 0)
            color: speedColor(netDown.value, Plasmoid.configuration.useCustomColors ? Plasmoid.configuration.downloadColor : Kirigami.Theme.textColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
        }

    }

    MouseArea {
        anchors.fill: root
        anchors.margins: -10
        onClicked: {
            executable.exec(plasmoid.configuration.launchCommand ?? "plasma-systemmonitor");
        }
    }

}
