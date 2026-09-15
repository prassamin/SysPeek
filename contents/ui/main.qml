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

    // whether we are on the desktop or in a panel
    readonly property bool isPlanar: Plasmoid.formFactor === PlasmaCore.Types.Planar
    // content based dimensions
    readonly property real contentWidth: rowLayout.implicitWidth + Plasmoid.configuration.horizontalPadding * 2
    readonly property real contentHeight: rowLayout.implicitHeight + Plasmoid.configuration.verticalPadding * 2

    function percent(val, total) {
        return total > 0 ? Math.round(val / total * 100) + "%" : "N/A";
    }

    function formatRichValue(valueString) {
        if (!valueString)
            return "";

        let parts = valueString.trim().split(/\s+/);
        if (parts.length === 2)
            return `
                <b>${parts[0]}</b>
                <span style='color: ${Kirigami.Theme.disabledTextColor}; font-size: 9px; font-weight: normal;'>
                    ${parts[1]}
                </span>
            `.trim();

        return `<b>${valueString}</b>`;
    }

    function makeTooltipHtml(title, color, rows) {
        let font = (Plasmoid.configuration.fontFamily !== "") ? Plasmoid.configuration.fontFamily : "sans-serif";
        let accent = String(resolveModuleColor(color));
        let tableRows = "";
        for (let i = 0; i < rows.length; i++) {
            tableRows += `<tr><td style='color:${Kirigami.Theme.disabledTextColor}; font-size:11px; padding:3px 20px 3px 0;'>${rows[i][0]}</td><td style='padding:3px 0; font-size:11px;'>${formatRichValue(rows[i][1])}</td></tr>`;
        }
        return `
            <div style='font-family: "${font}", sans-serif; min-width: 150px;'>
                <table border='0' cellspacing='0' cellpadding='0'>
                    <tr>
                        <!-- Left Accent Bar Pill -->
                        <td style='width: 3px; background-color: ${accent};'></td>

                        <!-- Right Content Cell -->
                        <td style='padding-left: 12px; vertical-align: top;'>
                            <!-- Dynamic Accent Header Title -->
                            <div style='font-size: 10px; font-weight: 800; color: ${accent}; letter-spacing: 1.2px;'>${title}</div>

                            <!-- Key-Value Grid -->
                            <table border='0' cellspacing='0' cellpadding='0'>
                                ${tableRows}
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
        `;
    }

    function formatBytes(bytes, overrideFmt) {
        let fmt = (overrideFmt !== undefined && overrideFmt !== -1) ? overrideFmt : Plasmoid.configuration.netSpeedFormat;
        let isBits = (fmt === 2 || fmt === 3);
        let val = isBits ? (bytes * 8) : bytes;
        let unitB = isBits ? "bps" : "B";
        let unitK = isBits ? "Kbps" : "KB";
        let unitM = isBits ? "Mbps" : "MB";
        let unitG = isBits ? "Gbps" : "GB";
        let unitT = isBits ? "Tbps" : "TB";
        let limits = [1024, 1.04858e+06, 1.07374e+09, 1.09951e+12];
        if (fmt === 1 || fmt === 3) {
            if (val < limits[0])
                return val.toFixed(0) + " " + unitB;

            if (val < limits[1])
                return (val / limits[0]).toFixed(1) + " " + unitK;

            if (val < limits[2])
                return (val / limits[1]).toFixed(1) + " " + unitM;

            if (val < limits[3])
                return (val / limits[2]).toFixed(1) + " " + unitG;

            return (val / limits[3]).toFixed(1) + " " + unitT;
        } else {
            if (val < limits[1])
                return (val / limits[0]).toFixed(1) + " " + unitK;

            if (val < limits[2])
                return (val / limits[1]).toFixed(1) + " " + unitM;

            if (val < limits[3])
                return (val / limits[2]).toFixed(1) + " " + unitG;

            return (val / limits[3]).toFixed(1) + " " + unitT;
        }
    }

    // Widest formatted byte value is the configured total (used <= total).
    function bytesWidthHint(totalBytes) {
        if (!(totalBytes > 0))
            return "999.9 GB";

        return formatBytes(totalBytes);
    }

    function netSpeedWidthHint(overrideFmt) {
        let fmt = (overrideFmt !== undefined && overrideFmt !== -1) ? overrideFmt : Plasmoid.configuration.netSpeedFormat;
        let isBits = (fmt === 2 || fmt === 3);
        return isBits ? "99.9 Mbps" : "99.9 MB";
    }

    function formatUptime(seconds) {
        if (!seconds)
            return "0s";

        var d = Math.floor(seconds / 86400);
        var h = Math.floor((seconds % 86400) / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var res = "";
        if (d > 0)
            res += d + "d ";

        if (h > 0)
            res += h + "h ";

        res += m + "m";
        return res;
    }

    // Reserve at least 3 day digits so 99d → 100d does not expand the panel.
    function uptimeWidthHint(seconds) {
        var d = Math.floor((seconds || 0) / 86400);
        var dayDigits = Math.max(3, String(Math.max(0, d)).length);
        return "9".repeat(dayDigits) + "d 23h 59m";
    }

    function cToF(c) {
        return Math.round((c * 9 / 5) + 32);
    }

    function getCustomSensorData(idStr) {
        for (var i = 0; i < customSensorsContainer.children.length; i++) {
            var child = customSensorsContainer.children[i];
            if (child && child.customId === idStr)
                return child;

        }
        return null;
    }

    // "system" (and the legacy default white) follows the color scheme so labels
    // and icons stay legible on light desktop themes.
    function resolveModuleColor(color) {
        let c = String(color || "").trim().toLowerCase();
        return (c === "" || c === "system" || c === "#ffffff" || c === "#fff") ? Kirigami.Theme.textColor : color;
    }

    function evaluateModuleColor(customData, rawValue, fallbackColor) {
        if (!customData || !customData.conditions || customData.conditions.length === 0)
            return fallbackColor;

        var val = parseFloat(rawValue);
        if (isNaN(val))
            return fallbackColor;

        for (var i = 0; i < customData.conditions.length; i++) {
            var c = customData.conditions[i];
            var thresh = parseFloat(c.threshold);
            if (isNaN(thresh))
                continue;

            var matched = false;
            if (c.operator === "==" && val === thresh)
                matched = true;
            else if (c.operator === ">" && val > thresh)
                matched = true;
            else if (c.operator === "<" && val < thresh)
                matched = true;
            else if (c.operator === ">=" && val >= thresh)
                matched = true;
            else if (c.operator === "<=" && val <= thresh)
                matched = true;
            if (matched)
                return c.color;

        }
        return fallbackColor;
    }

    // Same as evaluateModuleColor, but resolves the default white to the current
    // color scheme so widget labels/icons stay legible on light desktop themes.
    function widgetColor(customData, rawValue, fallbackColor) {
        return resolveModuleColor(evaluateModuleColor(customData, rawValue, fallbackColor));
    }

    // action types: 0 = Launch App, 1 = Open URL, 2 = Run Command, 3 = Do Nothing
    function performClickAction() {
        var action = Plasmoid.configuration.leftClickAction;
        if (action === 3)
            return ;

        var value = action === 0 ? Plasmoid.configuration.leftClickAppValue : action === 1 ? Plasmoid.configuration.leftClickUrlValue : Plasmoid.configuration.leftClickCmdValue;
        if (!value)
            return ;

        if (action === 1)
            Qt.openUrlExternally(value);
        else
            executable.exec(value);
    }

    Component.onCompleted: {
        Plasmoid.setInternalAction("configure", configureAction);
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

    // override the default "Configure..." action to open our custom window
    PlasmaCore.Action {
        id: configureAction

        text: i18n("SysPeek Settings")
        icon.name: "configure"
        onTriggered: {
            settingsWindow.show();
            settingsWindow.raise();
            settingsWindow.requestActivate();
        }
    }

    Settings {
        id: settingsWindow

        cfg: Plasmoid.configuration
        meta: Plasmoid.metaData
    }

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

    readonly property var activeModuleSet: {
        let layoutString = Plasmoid.configuration.panelLayout || "cpu|gpu|ram|swap|upload|download";
        let tokens = layoutString.split(/[|,]/);
        let set = {};
        for (let i = 0; i < tokens.length; i++) {
            let t = tokens[i].trim();
            if (t !== "") {
                set[t] = true;
            }
        }
        return set;
    }

    function isModuleActive(id) {
        return !!activeModuleSet[id];
    }

    property var gpuTempCandidates: [
        "gpu/gpu0/temperature",
        "gpu/gpu1/temperature",
        "gpu/gpu2/temperature"
    ]
    property string autoResolvedGpuTempSensorId: ""
    property bool gpuTempResolved: false

    Item {
        id: gpuTempResolver
        visible: false

        Repeater {
            model: root.gpuTempCandidates
            delegate: Item {
                property string candId: modelData
                Sensors.Sensor {
                    sensorId: (isModuleActive("gpu_temp") && !root.autoResolvedGpuTempSensorId) ? candId : ""
                    updateRateLimit: 1000
                    onStatusChanged: {
                        if (status === Sensors.Sensor.Ready && !root.autoResolvedGpuTempSensorId) {
                            root.autoResolvedGpuTempSensorId = candId;
                            root.gpuTempResolved = true;
                        }
                    }
                }
            }
        }

        Timer {
            interval: 1500
            running: isModuleActive("gpu_temp") && !root.gpuTempResolved
            onTriggered: {
                root.gpuTempResolved = true;
            }
        }
    }

    Sensors.Sensor {
        id: cpu

        sensorId: {
            if (!isModuleActive("cpu")) return "";
            let customData = getCustomSensorData("cpu");
            if (customData && customData.sensorId) return customData.sensorId;
            return "cpu/all/usage";
        }
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: gpu

        sensorId: {
            if (!isModuleActive("gpu")) return "";
            let customData = getCustomSensorData("gpu");
            if (customData && customData.sensorId) return customData.sensorId;
            return "gpu/all/usage";
        }
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: ramUsed

        sensorId: isModuleActive("ram") ? "memory/physical/used" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: ramTotal

        sensorId: isModuleActive("ram") ? "memory/physical/total" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: swapUsed

        sensorId: isModuleActive("swap") ? "memory/swap/used" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: swapTotal

        sensorId: isModuleActive("swap") ? "memory/swap/total" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: netUp

        sensorId: isModuleActive("upload") ? "network/all/upload" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: netDown

        sensorId: isModuleActive("download") ? "network/all/download" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: totalUploadedBytes

        sensorId: isModuleActive("upload") ? "network/all/totalUpload" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: totalDownloadedBytes

        sensorId: isModuleActive("download") ? "network/all/totalDownload" : ""
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: cpuTemp

        sensorId: {
            if (!isModuleActive("cpu_temp")) return "";
            let customData = getCustomSensorData("cpu_temp");
            if (customData && customData.sensorId) return customData.sensorId;
            return "cpu/all/averageTemperature";
        }
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: gpuTemp

        sensorId: {
            if (!isModuleActive("gpu_temp")) return "";
            let customData = getCustomSensorData("gpu_temp");
            if (customData && customData.sensorId) return customData.sensorId;
            return root.autoResolvedGpuTempSensorId;
        }
        updateRateLimit: 1000
    }

    Sensors.Sensor {
        id: uptime

        sensorId: isModuleActive("uptime") ? "os/system/uptime" : ""
        updateRateLimit: 1000
    }

    Item {
        id: customSensorsContainer

        Repeater {
            model: {
                try {
                    return JSON.parse(Plasmoid.configuration.customModules || "[]");
                } catch (e) {
                    return [];
                }
            }

            delegate: Item {
                property alias value: sensor.value
                property alias formattedValue: sensor.formattedValue
                property string sensorId: modelData.sensorId || ""
                property string customId: modelData.id
                property string label: modelData.label || ""
                property string icon: modelData.icon || ""
                property string customColor: modelData.color || "#ffffff"
                property int displayMode: modelData.displayMode !== undefined ? modelData.displayMode : 0
                property int speedFormat: modelData.speedFormat !== undefined ? modelData.speedFormat : -1
                property int tempUnit: modelData.tempUnit !== undefined ? modelData.tempUnit : 0
                property var conditions: modelData.conditions || []

                objectName: "customSensorItem_" + modelData.id

                Sensors.Sensor {
                    id: sensor

                    sensorId: (isModuleActive(modelData.id) && modelData.sensorId && modelData.id.startsWith("custom_")) ? modelData.sensorId : ""
                    updateRateLimit: 1000
                }

            }

        }

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

    Component {
        id: compCpu

        MonitorItem {
            property var customData: getCustomSensorData("cpu")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/cpu.svg")
            label: cpu.value !== undefined ? Math.round(cpu.value) + "%" : "N/A"
            labelWidthHint: "100%"
            color: widgetColor(customData, cpu.value, (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.cpuColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                let rows = [];
                if (cpu.value !== undefined)
                    rows.push(["Usage:", Math.round(cpu.value) + " %"]);

                if (cpuTemp.value !== undefined && cpuTemp.value > 0)
                    rows.push(["Temp:", Math.round(cpuTemp.value) + " °C"]);

                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.cpuColor;
                let c = evaluateModuleColor(customData, cpu.value, baseCol);
                return makeTooltipHtml("CPU MONITOR", c, rows);
            }
        }

    }

    Component {
        id: compGpu

        MonitorItem {
            property var customData: getCustomSensorData("gpu")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/gpu.svg")
            label: gpu.value !== undefined ? Math.round(gpu.value) + "%" : "N/A"
            labelWidthHint: "100%"
            color: widgetColor(customData, gpu.value, (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.gpuColor)
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                let rows = [];
                if (gpu.value !== undefined)
                    rows.push(["Usage:", Math.round(gpu.value) + " %"]);

                if (gpuTemp.value !== undefined && gpuTemp.value > 0)
                    rows.push(["Temp:", Math.round(gpuTemp.value) + " °C"]);

                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.gpuColor;
                let c = evaluateModuleColor(customData, gpu.value, baseCol);
                return makeTooltipHtml("GPU MONITOR", c, rows);
            }
        }

    }

    Component {
        id: compRam

        MonitorItem {
            property var customData: getCustomSensorData("ram")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/memory.svg")
            label: {
                if (ramUsed.value === undefined || ramTotal.value === undefined)
                    return "N/A";

                let mode = (customData && customData.displayMode !== undefined) ? customData.displayMode : 0;
                return mode === 0 ? percent(ramUsed.value, ramTotal.value) : formatBytes(ramUsed.value);
            }
            labelWidthHint: {
                let mode = (customData && customData.displayMode !== undefined) ? customData.displayMode : 0;
                return mode === 0 ? "100%" : bytesWidthHint(ramTotal.value);
            }
            color: {
                let p = (ramUsed.value / ramTotal.value * 100);
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.ramColor;
                return widgetColor(customData, p, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                if (ramUsed.value === undefined || ramTotal.value === undefined)
                    return "";

                let rows = [["Usage:", percent(ramUsed.value, ramTotal.value).replace("%", " %")], ["Used:", formatBytes(ramUsed.value)], ["Available:", formatBytes(ramTotal.value - ramUsed.value)], ["Total:", formatBytes(ramTotal.value)]];
                let p = (ramUsed.value / ramTotal.value * 100);
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.ramColor;
                let c = evaluateModuleColor(customData, p, baseCol);
                return makeTooltipHtml("RAM MONITOR", c, rows);
            }
        }

    }

    Component {
        id: compSwap

        MonitorItem {
            property var customData: getCustomSensorData("swap")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/swap.svg")
            label: {
                if (swapUsed.value === undefined || swapTotal.value === undefined)
                    return "N/A";

                let mode = (customData && customData.displayMode !== undefined) ? customData.displayMode : 0;
                return mode === 0 ? percent(swapUsed.value, swapTotal.value) : formatBytes(swapUsed.value);
            }
            labelWidthHint: {
                let mode = (customData && customData.displayMode !== undefined) ? customData.displayMode : 0;
                return mode === 0 ? "100%" : bytesWidthHint(swapTotal.value);
            }
            color: {
                let p = (swapUsed.value / swapTotal.value * 100);
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.swapColor;
                return widgetColor(customData, p, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                if (swapUsed.value === undefined || swapTotal.value === undefined)
                    return "";

                let rows = [["Usage:", percent(swapUsed.value, swapTotal.value).replace("%", " %")], ["Used:", formatBytes(swapUsed.value)], ["Available:", formatBytes(swapTotal.value - swapUsed.value)], ["Total:", formatBytes(swapTotal.value)]];
                let p = (swapUsed.value / swapTotal.value * 100);
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.swapColor;
                let c = evaluateModuleColor(customData, p, baseCol);
                return makeTooltipHtml("SWAP MONITOR", c, rows);
            }
        }

    }

    Component {
        id: compUpload

        MonitorItem {
            property var customData: getCustomSensorData("upload")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/up.svg")
            label: netUp.value !== undefined && formatBytes(netUp.value || 0, customData ? customData.speedFormat : -1)
            labelWidthHint: netSpeedWidthHint(customData ? customData.speedFormat : -1)
            color: {
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.uploadColor;
                return widgetColor(customData, netUp.value, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                let rows = [];
                if (netUp.value !== undefined)
                    rows.push(["Current:", formatBytes(netUp.value, customData ? customData.speedFormat : -1) + "/s"]);

                if (totalUploadedBytes.value !== undefined)
                    rows.push(["Total Up:", formatBytes(totalUploadedBytes.value, customData ? customData.speedFormat : -1)]);

                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.uploadColor;
                let c = evaluateModuleColor(customData, netUp.value, baseCol);
                return makeTooltipHtml("UPLOAD SPEED", c, rows);
            }
        }

    }

    Component {
        id: compDownload

        MonitorItem {
            property var customData: getCustomSensorData("download")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/down.svg")
            label: netDown.value !== undefined && formatBytes(netDown.value || 0, customData ? customData.speedFormat : -1)
            labelWidthHint: netSpeedWidthHint(customData ? customData.speedFormat : -1)
            color: {
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.downloadColor;
                return widgetColor(customData, netDown.value, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                let rows = [];
                if (netDown.value !== undefined)
                    rows.push(["Current:", formatBytes(netDown.value, customData ? customData.speedFormat : -1) + "/s"]);

                if (totalDownloadedBytes.value !== undefined)
                    rows.push(["Total Down:", formatBytes(totalDownloadedBytes.value, customData ? customData.speedFormat : -1)]);

                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.downloadColor;
                let c = evaluateModuleColor(customData, netDown.value, baseCol);
                return makeTooltipHtml("DOWNLOAD SPEED", c, rows);
            }
        }

    }

    Component {
        id: compCpuTemp

        MonitorItem {
            property var customData: getCustomSensorData("cpu_temp")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/temp.svg")
            label: {
                if (cpuTemp.value === undefined)
                    return "N/A";

                let val = Math.round(cpuTemp.value || 0);
                if (customData && customData.tempUnit === 1)
                    return cToF(val) + "°F";

                return val + "°C";
            }
            labelWidthHint: (customData && customData.tempUnit === 1) ? "212°F" : "100°C"
            color: {
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.cpuTempColor;
                return widgetColor(customData, cpuTemp.value, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.cpuTempColor;
                let c = evaluateModuleColor(customData, cpuTemp.value, baseCol);
                return makeTooltipHtml("CPU TEMP", c, []);
            }
        }

    }

    Component {
        id: compGpuTemp

        MonitorItem {
            property var customData: getCustomSensorData("gpu_temp")
            readonly property bool isSensorFailed: {
                if (customData && customData.sensorId) {
                    return gpuTemp.status === Sensors.Sensor.Error;
                }
                return root.gpuTempResolved && root.autoResolvedGpuTempSensorId === "";
            }

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/temp.svg")
            label: {
                if (gpuTemp.value === undefined)
                    return "N/A";

                let val = Math.round(gpuTemp.value || 0);
                if (customData && customData.tempUnit === 1)
                    return cToF(val) + "°F";

                return val + "°C";
            }
            labelWidthHint: (customData && customData.tempUnit === 1) ? "212°F" : "100°C"
            color: {
                if (isSensorFailed)
                    return Kirigami.Theme.negativeTextColor;

                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.gpuTempColor;
                return widgetColor(customData, gpuTemp.value, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                if (isSensorFailed)
                    return makeTooltipHtml("GPU TEMP", Kirigami.Theme.negativeTextColor, [["Error:", "Sensor not found. Select sensor in Modules settings."]]);

                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.gpuTempColor;
                let c = evaluateModuleColor(customData, gpuTemp.value, baseCol);
                return makeTooltipHtml("GPU TEMP", c, []);
            }
        }

    }

    Component {
        id: compUptime

        MonitorItem {
            property var customData: getCustomSensorData("uptime")

            icon: customData && customData.icon ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : Qt.resolvedUrl("../icons/uptime.svg")
            label: uptime.value !== undefined ? formatUptime(uptime.value || 0) : "0s"
            labelWidthHint: uptimeWidthHint(uptime.value)
            color: {
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.uptimeColor;
                return widgetColor(customData, uptime.value, baseCol);
            }
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: Plasmoid.configuration.showTooltips
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: {
                let baseCol = (customData && customData.customColor) ? customData.customColor : Plasmoid.configuration.uptimeColor;
                let c = evaluateModuleColor(customData, uptime.value, baseCol);
                return makeTooltipHtml("UPTIME", c, []);
            }
        }

    }

    Component {
        id: compCustomModule

        MonitorItem {
            property var customData: getCustomSensorData(parent.customModuleId)

            icon: customData ? (customData.icon.indexOf("/") !== -1 ? "file://" + customData.icon : Qt.resolvedUrl("../icons/" + customData.icon)) : ""
            label: customData ? (customData.formattedValue || (customData.value !== undefined ? (typeof customData.value === "number" ? Math.round(customData.value * 100) / 100 : customData.value) : "N/A")) : "N/A"
            labelWidthHint: "100%"
            color: customData ? widgetColor(customData, customData.value, customData.customColor) : resolveModuleColor("#ffffff")
            iconTextSpacing: Plasmoid.configuration.iconTextSpacing
            fontSize: Plasmoid.configuration.fontSize
            fontFamily: Plasmoid.configuration.fontFamily
            showIcon: Plasmoid.configuration.showIcons
            showTooltips: false
            fixedLabelWidth: Plasmoid.configuration.fixedLabelWidth
            labelTextAlignment: Plasmoid.configuration.labelTextAlignment
            fixedLabelWidthExtra: Plasmoid.configuration.fixedLabelWidthExtra
            tooltipText: customData ? makeTooltipHtml(customData.label.toUpperCase(), evaluateModuleColor(customData, customData.value, customData.customColor), []) : ""
        }

    }

    RowLayout {
        id: rowLayout

        property var layoutModel: {
            var layoutString = Plasmoid.configuration.panelLayout || "cpu|gpu|ram|swap|upload|download";
            var columns = layoutString.split('|');
            var result = [];
            for (var i = 0; i < columns.length; i++) {
                if (columns[i].trim() !== "")
                    result.push(columns[i].split(','));

            }
            return result;
        }

        anchors.centerIn: parent
        spacing: Plasmoid.configuration.itemSpacing

        Repeater {
            model: rowLayout.layoutModel

            delegate: GridLayout {
                columns: 1
                rowSpacing: 2
                columnSpacing: 0

                Repeater {
                    model: modelData

                    delegate: Loader {
                        property string customModuleId: modelData

                        sourceComponent: {
                            switch (modelData) {
                            case "cpu":
                                return compCpu;
                            case "gpu":
                                return compGpu;
                            case "ram":
                                return compRam;
                            case "swap":
                                return compSwap;
                            case "upload":
                                return compUpload;
                            case "download":
                                return compDownload;
                            case "cpu_temp":
                                return compCpuTemp;
                            case "gpu_temp":
                                return compGpuTemp;
                            case "uptime":
                                return compUptime;
                            default:
                                if (modelData.startsWith("custom_"))
                                    return compCustomModule;

                                return null;
                            }
                        }
                    }

                }

            }

        }

    }

    MouseArea {
        anchors.fill: isPlanar ? desktopBackground : parent
        acceptedButtons: Qt.LeftButton
        onClicked: performClickAction()
    }

}
