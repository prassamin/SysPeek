import ".." as Base
import "../components" as Components
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksysguard.sensors 1.0 as Sensors

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null
    property var customModulesArr: []
    property var allModulesArr: []

    function percent(val, total) {
        return total > 0 ? Math.round(val / total * 100) + "%" : "N/A";
    }

    function refreshModules() {
        var customMods = [];
        try {
            customMods = JSON.parse(cfg.customModules || "[]");
        } catch (e) {
            customMods = [];
        }
        var result = [];
        var builtIn = [{
            "id": "cpu",
            "label": "CPU",
            "icon": "cpu.svg",
            "sensorId": "cpu/all/usage",
            "color": String(cfg.cpuColor),
            "isBuiltIn": true
        }, {
            "id": "gpu",
            "label": "GPU",
            "icon": "gpu.svg",
            "sensorId": "gpu/all/usage",
            "color": String(cfg.gpuColor),
            "isBuiltIn": true
        }, {
            "id": "ram",
            "label": "RAM",
            "icon": "memory.svg",
            "sensorId": "memory/physical/used",
            "color": String(cfg.ramColor),
            "isBuiltIn": true
        }, {
            "id": "swap",
            "label": "SWAP",
            "icon": "swap.svg",
            "sensorId": "memory/swap/used",
            "color": String(cfg.swapColor),
            "isBuiltIn": true
        }, {
            "id": "upload",
            "label": "UPLOAD",
            "icon": "up.svg",
            "sensorId": "network/all/upload",
            "color": String(cfg.uploadColor),
            "isBuiltIn": true
        }, {
            "id": "download",
            "label": "DOWNLOAD",
            "icon": "down.svg",
            "sensorId": "network/all/download",
            "color": String(cfg.downloadColor),
            "isBuiltIn": true
        }, {
            "id": "cpu_temp",
            "label": "CPU TEMP",
            "icon": "temp.svg",
            "sensorId": "cpu/all/averageTemperature",
            "color": String(cfg.cpuTempColor),
            "isBuiltIn": true
        }, {
            "id": "gpu_temp",
            "label": "GPU TEMP",
            "icon": "temp.svg",
            "sensorId": "gpu/all/temperature",
            "color": String(cfg.gpuTempColor),
            "isBuiltIn": true
        }, {
            "id": "vram",
            "label": "VRAM",
            "icon": "gpu.svg",
            "sensorId": "gpu/all/usedVram",
            "color": String(cfg.vramColor),
            "isBuiltIn": true
        }, {
            "id": "uptime",
            "label": "UPTIME",
            "icon": "uptime.svg",
            "sensorId": "os/system/uptime",
            "color": String(cfg.uptimeColor),
            "isBuiltIn": true
        }];
        for (var i = 0; i < builtIn.length; i++) {
            var found = false;
            for (var j = 0; j < customMods.length; j++) {
                if (customMods[j].id === builtIn[i].id) {
                    var merged = JSON.parse(JSON.stringify(builtIn[i])); // start with defaults
                    var userMod = customMods[j];
                    if (userMod.icon)
                        merged.icon = userMod.icon;

                    if (userMod.color)
                        merged.color = userMod.color;

                    if (userMod.displayMode !== undefined)
                        merged.displayMode = userMod.displayMode;

                    if (userMod.speedFormat !== undefined)
                        merged.speedFormat = userMod.speedFormat;

                    if (userMod.tempUnit !== undefined)
                        merged.tempUnit = userMod.tempUnit;

                    if (userMod.conditions)
                        merged.conditions = userMod.conditions;

                    result.push(merged);
                    found = true;
                    break;
                }
            }
            if (!found)
                result.push(builtIn[i]);

        }
        for (var k = 0; k < customMods.length; k++) {
            var isBI = false;
            for (var l = 0; l < builtIn.length; l++) {
                if (customMods[k].id === builtIn[l].id) {
                    isBI = true;
                    break;
                }
            }
            if (!isBI) {
                var m = customMods[k];
                m.isBuiltIn = false;
                result.push(m);
            }
        }
        allModulesArr = result;
        customModulesArr = customMods;
    }

    Component.onCompleted: refreshModules()
    contentHeight: modulesCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColorDialog {
        id: masterColorDialog

        property var targetObject: null
        property string targetProperty: ""
        property int targetIndex: -1

        title: "Select Color"
        onAccepted: {
            if (targetObject) {
                if (targetIndex !== -1) {
                    // It's a condition in tempConditionsModel
                    if (targetIndex >= 0 && targetIndex < targetObject.count)
                        targetObject.setProperty(targetIndex, targetProperty, String(selectedColor));

                } else {
                    // It's a direct property (like colorField.text)
                    targetObject[targetProperty] = String(selectedColor);
                }
            }
        }
    }

    Sensors.SensorTreeModel {
        id: sensorTree
    }

    Sensors.Sensor {
        id: ramTotal

        sensorId: "memory/physical/total"
    }

    Sensors.Sensor {
        id: swapTotal

        sensorId: "memory/swap/total"
    }

    Connections {
        function onCustomModulesChanged() {
            page.refreshModules();
        }

        function onCpuColorChanged() {
            page.refreshModules();
        }

        function onGpuColorChanged() {
            page.refreshModules();
        }

        function onRamColorChanged() {
            page.refreshModules();
        }

        function onSwapColorChanged() {
            page.refreshModules();
        }

        function onUploadColorChanged() {
            page.refreshModules();
        }

        function onDownloadColorChanged() {
            page.refreshModules();
        }

        function onCpuTempColorChanged() {
            page.refreshModules();
        }

        function onGpuTempColorChanged() {
            page.refreshModules();
        }

        function onVramColorChanged() {
            page.refreshModules();
        }

        function onBatteryColorChanged() {
            page.refreshModules();
        }

        function onUptimeColorChanged() {
            page.refreshModules();
        }

        target: cfg
    }

    ColumnLayout {
        id: modulesCol

        spacing: 18

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 24
        }

        RowLayout {
            Layout.fillWidth: true

            Components.SectionLabel {
                text: "ALL MODULES"
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 36
                color: createHover.containsMouse ? Qt.lighter(Components.Theme.accentCol, 1.1) : Components.Theme.accentCol
                radius: 6

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Kirigami.Icon {
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                        source: "list-add-symbolic"
                        color: "white"
                    }

                    Text {
                        text: "Create New Module"
                        color: "white"
                        font.pixelSize: 11
                        font.bold: true
                    }

                }

                MouseArea {
                    id: createHover

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        addDialog.editingModuleId = "";
                        addDialog.isEditingBuiltIn = false;
                        addDialog.open();
                    }
                }

            }

        }

        Flow {
            Layout.fillWidth: true
            spacing: 16

            Repeater {
                model: page.allModulesArr

                delegate: Components.Card {
                    width: 250
                    height: 120

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 12
                        Layout.bottomMargin: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                width: 36
                                height: 36
                                radius: 6
                                color: Components.Theme.controlBg
                                border.color: Components.Theme.controlBorder

                                Image {
                                    anchors.centerIn: parent
                                    width: 18
                                    height: 18
                                    source: modelData.icon.indexOf("/") !== -1 ? "file://" + modelData.icon : Qt.resolvedUrl("../../icons/" + modelData.icon)
                                    sourceSize: Qt.size(18, 18)
                                    smooth: true
                                    mipmap: true
                                }

                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    spacing: 4

                                    Text {
                                        text: modelData.label
                                        color: Components.Theme.textPrimary
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        visible: modelData.isBuiltIn
                                        width: 50
                                        height: 16
                                        radius: 4
                                        color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.1)
                                        border.color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.3)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "BUILT-IN"
                                            color: Components.Theme.accentCol
                                            font.pixelSize: 8
                                            font.bold: true
                                        }

                                    }

                                }

                                Text {
                                    text: modelData.sensorId
                                    color: Components.Theme.textSecondary
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                            }

                        }

                        // spacer
                        Item {
                            Layout.fillHeight: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: modelData.color
                            }

                            Text {
                                text: modelData.conditions ? modelData.conditions.length + " Conditions" : "0 Conditions"
                                color: Components.Theme.textTertiary
                                font.pixelSize: 11
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 32
                                height: 28
                                radius: 6
                                color: editHover.containsMouse ? Components.Theme.hoverBg : "transparent"

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 14
                                    height: 14
                                    source: "edit-entry"
                                    color: Components.Theme.textSecondary
                                }

                                MouseArea {
                                    id: editHover

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        addDialog.editingModuleId = modelData.id;
                                        addDialog.isEditingBuiltIn = modelData.isBuiltIn;
                                        addDialog.openForEdit(modelData);
                                    }
                                }

                            }

                            Rectangle {
                                visible: !modelData.isBuiltIn
                                width: 32
                                height: 28
                                radius: 6
                                color: delMouse.containsMouse ? Qt.rgba(Components.Theme.dangerCol.r, Components.Theme.dangerCol.g, Components.Theme.dangerCol.b, 0.2) : "transparent"

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 14
                                    height: 14
                                    source: "delete"
                                    color: Components.Theme.dangerCol
                                }

                                MouseArea {
                                    id: delMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var mods = JSON.parse(cfg.customModules || "[]");
                                        var newMods = [];
                                        for (var i = 0; i < mods.length; i++) {
                                            if (mods[i].id !== modelData.id)
                                                newMods.push(mods[i]);

                                        }
                                        cfg.customModules = JSON.stringify(newMods);
                                    }
                                }

                            }

                        }

                    }

                }

            }

        }

        // Empty State
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            visible: page.allModulesArr.length === 0

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(1, 1, 1, 0.03)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
                radius: 10

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "📦"
                        font.pixelSize: 28
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "No custom modules yet"
                        color: Components.Theme.textSecondary
                        font.pixelSize: 13
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Click \"Create New Module\" to get started"
                        color: Components.Theme.textTertiary
                        font.pixelSize: 11
                        Layout.alignment: Qt.AlignHCenter
                    }

                }

            }

        }

    }

    QQC2.Popup {
        // Subtle Drop Shadow (optional)

        id: addDialog

        property string selectedIcon: "cpu.svg"
        property bool userEditedLabel: false
        property string editingModuleId: ""
        property bool isEditingBuiltIn: false
        // Data Format properties
        property int currentDisplayMode: 0
        property int currentSpeedFormat: -1 // -1 means "Use Global"
        property int currentTempUnit: 0 // 0: Celsius, 1: Fahrenheit

        function openForEdit(moduleData) {
            addDialog.editingModuleId = moduleData.id;
            addDialog.selectedIcon = String(moduleData.icon || "");
            addDialog.userEditedLabel = true;
            idField.text = String(moduleData.sensorId || "");
            labelField.text = String(moduleData.label || "");
            colorField.text = String(moduleData.color || "#ffffff");
            addDialog.currentDisplayMode = moduleData.displayMode !== undefined ? moduleData.displayMode : 0;
            addDialog.currentSpeedFormat = moduleData.speedFormat !== undefined ? moduleData.speedFormat : -1;
            addDialog.currentTempUnit = moduleData.tempUnit !== undefined ? moduleData.tempUnit : 0;
            tempConditionsModel.clear();
            if (moduleData.conditions) {
                for (var i = 0; i < moduleData.conditions.length; i++) {
                    tempConditionsModel.append(moduleData.conditions[i]);
                }
            }
            addDialog.open();
        }

        function saveModule() {
            if (idField.text.trim() === "" || labelField.text.trim() === "")
                return ;

            var mods = JSON.parse(cfg.customModules || "[]");
            var newId = addDialog.editingModuleId !== "" ? addDialog.editingModuleId : "custom_" + Math.random().toString(36).substr(2, 5);
            var filtered = [];
            for (var j = 0; j < mods.length; j++) {
                if (mods[j].id !== newId)
                    filtered.push(mods[j]);

            }
            mods = filtered;
            var conds = [];
            for (var i = 0; i < tempConditionsModel.count; i++) {
                var c = tempConditionsModel.get(i);
                conds.push({
                    "operator": c.operator,
                    "threshold": c.threshold,
                    "color": c.color
                });
            }
            var modData = {
                "id": newId,
                "label": labelField.text.trim(),
                "icon": addDialog.selectedIcon,
                "color": colorField.text.trim() || "#ffffff",
                "displayMode": addDialog.currentDisplayMode,
                "speedFormat": addDialog.currentSpeedFormat,
                "tempUnit": addDialog.currentTempUnit,
                "conditions": conds
            };
            // Only add sensorId for truly custom modules (built-ins have it hardcoded)
            if (!addDialog.isEditingBuiltIn)
                modData.sensorId = idField.text.trim();

            mods.push(modData);
            cfg.customModules = JSON.stringify(mods);
            idField.text = "";
            labelField.text = "";
            addDialog.close();
        }

        parent: edgeSafeContainer || page
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 550)
        height: Math.min(parent.height - 40, 700)
        modal: true
        dim: true
        onOpened: {
            // Only reset fields when creating a NEW module
            if (addDialog.editingModuleId === "") {
                tempConditionsModel.clear();
                addDialog.selectedIcon = "cpu.svg";
                addDialog.userEditedLabel = false;
                idField.text = "";
                labelField.text = "";
                colorField.text = "#ffffff";
            }
        }

        ListModel {
            id: tempConditionsModel
        }

        ListModel {
            id: iconListModel

            ListElement {
                icon: "cpu.svg"
                name: "CPU"
            }

            ListElement {
                icon: "gpu.svg"
                name: "GPU"
            }

            ListElement {
                icon: "temp.svg"
                name: "Temp"
            }

            ListElement {
                icon: "battery.svg"
                name: "Battery"
            }

            ListElement {
                icon: "uptime.svg"
                name: "Clock"
            }

            ListElement {
                icon: "memory.svg"
                name: "Memory"
            }

            ListElement {
                icon: "swap.svg"
                name: "Swap"
            }

            ListElement {
                icon: "up.svg"
                name: "Net Up"
            }

            ListElement {
                icon: "down.svg"
                name: "Net Down"
            }

        }

        QQC2.Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.75)

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        background: Rectangle {
            color: Qt.rgba(Components.Theme.bgBase.r, Components.Theme.bgBase.g, Components.Theme.bgBase.b, 0.95)
            border.color: Components.Theme.borderCol
            border.width: 1
            radius: 12
        }

        contentItem: ColumnLayout {
            spacing: 0

            // CUSTOM HEADER
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    text: addDialog.isEditingBuiltIn ? "EDIT BUILT-IN MODULE" : (addDialog.editingModuleId !== "" ? "EDIT MODULE" : "CREATE CUSTOM MODULE")
                    color: Components.Theme.textPrimary
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    width: 28
                    height: 28
                    radius: 14
                    color: closeHover.containsMouse ? Components.Theme.dangerCol : Components.Theme.controlBg
                    border.color: Components.Theme.controlBorder

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: "window-close-symbolic"
                        color: "white"
                    }

                    MouseArea {
                        id: closeHover

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addDialog.close()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Components.Theme.borderCol
                }

            }

            // SCROLLABLE CONTENT
            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width - 24
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16

                    // top padding
                    Item {
                        Layout.preferredHeight: 8
                    }

                    // 1. SENSOR EXPLORER CARD
                    Rectangle {
                        visible: !addDialog.isEditingBuiltIn
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        color: Components.Theme.controlBg
                        border.color: Components.Theme.controlBorder
                        border.width: 1
                        radius: 8
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                color: Qt.rgba(1, 1, 1, 0.05)

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    text: "SENSOR EXPLORER"
                                    color: Components.Theme.textSecondary
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                            }

                            QQC2.ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                TreeView {
                                    id: tview

                                    model: sensorTree
                                    clip: true
                                    boundsBehavior: Flickable.StopAtBounds

                                    delegate: QQC2.TreeViewDelegate {
                                        id: currentItemDelegate

                                        width: tview.width
                                        height: 50
                                        onClicked: {
                                            if (currentItemDelegate.hasChildren) {
                                                if (tview.isExpanded(row))
                                                    tview.collapse(row);
                                                else
                                                    tview.expand(row);
                                            } else {
                                                idField.text = model.SensorId || model.display || ("sensor_row_" + row);
                                                if (!addDialog.userEditedLabel)
                                                    labelField.text = (model.display || "").toUpperCase();

                                            }
                                        }

                                        background: Rectangle {
                                            color: (idField.text === model.SensorId && model.SensorId) ? Components.Theme.accentGlow : (currentItemDelegate.hovered ? Components.Theme.hoverBg : "transparent")
                                        }

                                        contentItem: RowLayout {
                                            spacing: 8

                                            Kirigami.Icon {
                                                Layout.preferredWidth: 14
                                                Layout.preferredHeight: 14
                                                source: currentItemDelegate.hasChildren ? "folder-symbolic" : "sensor-symbolic"
                                                opacity: 0.7
                                                color: Components.Theme.textPrimary
                                            }

                                            Text {
                                                text: model.display || ""
                                                color: (idField.text === model.SensorId && model.SensorId) ? Components.Theme.accentCol : Components.Theme.textPrimary
                                                font.bold: (idField.text === model.SensorId && model.SensorId)
                                                Layout.fillWidth: true
                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                    // 2. CONFIGURATION CARD
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: configCol.implicitHeight + 24
                        color: Components.Theme.controlBg
                        border.color: Components.Theme.controlBorder
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            id: configCol

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "MODULE CONFIGURATION"
                                color: Components.Theme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    color: Qt.rgba(0, 0, 0, 0.2)
                                    border.color: Components.Theme.controlBorder
                                    radius: 6

                                    TextInput {
                                        id: idField

                                        anchors.fill: parent
                                        anchors.margins: 12
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Components.Theme.textTertiary
                                        font.pixelSize: 12
                                        readOnly: true

                                        Text {
                                            text: "Select a sensor above..."
                                            color: Components.Theme.textTertiary
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: !parent.text
                                        }

                                    }

                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    color: labelField.activeFocus ? Components.Theme.activeBg : Qt.rgba(0, 0, 0, 0.1)
                                    border.color: labelField.activeFocus ? Components.Theme.accentCol : Components.Theme.controlBorder
                                    radius: 6

                                    TextInput {
                                        id: labelField

                                        anchors.fill: parent
                                        anchors.margins: 12
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: addDialog.isEditingBuiltIn ? Components.Theme.textTertiary : Components.Theme.textPrimary
                                        font.pixelSize: 12
                                        readOnly: addDialog.isEditingBuiltIn
                                        onTextEdited: addDialog.userEditedLabel = true

                                        Text {
                                            text: "Label (e.g. CPU)"
                                            color: Components.Theme.textTertiary
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: !parent.text
                                        }

                                    }

                                    Behavior on border.color {
                                        ColorAnimation {
                                            duration: 150
                                        }

                                    }

                                }

                            }

                            Text {
                                text: "ICON"
                                color: Components.Theme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                                Layout.topMargin: 8
                            }

                            Flow {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    model: iconListModel

                                    delegate: Rectangle {
                                        width: 36
                                        height: 36
                                        radius: 6
                                        color: addDialog.selectedIcon === model.icon ? Components.Theme.accentCol : Components.Theme.controlHover
                                        border.color: addDialog.selectedIcon === model.icon ? Qt.lighter(Components.Theme.accentCol, 1.2) : Components.Theme.controlBorder
                                        QQC2.ToolTip.text: model.name
                                        QQC2.ToolTip.visible: iconMouseArea.containsMouse

                                        Image {
                                            anchors.centerIn: parent
                                            width: 18
                                            height: 18
                                            source: model.icon.indexOf("/") !== -1 ? "file://" + model.icon : "../../icons/" + model.icon
                                            sourceSize: Qt.size(18, 18)
                                            smooth: true
                                            mipmap: true
                                        }

                                        MouseArea {
                                            id: iconMouseArea

                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: addDialog.selectedIcon = model.icon
                                            hoverEnabled: true
                                        }

                                    }

                                }

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 6
                                    color: Components.Theme.controlHover
                                    border.color: Components.Theme.controlBorder
                                    QQC2.ToolTip.text: "Browse Custom SVG"
                                    QQC2.ToolTip.visible: browseMouseArea.containsMouse

                                    Kirigami.Icon {
                                        anchors.centerIn: parent
                                        width: 18
                                        height: 18
                                        source: "folder-open-symbolic"
                                        color: Components.Theme.textPrimary
                                    }

                                    MouseArea {
                                        id: browseMouseArea

                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: iconDialog.open()
                                        hoverEnabled: true
                                    }

                                }

                            }

                            Text {
                                text: "DEFAULT COLOR"
                                color: Components.Theme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                                Layout.topMargin: 8
                            }

                            Flow {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    model: ["#ffffff", Components.Theme.accentCol, Components.Theme.successCol, Components.Theme.warningCol, Components.Theme.dangerCol, "#0ea5e9", "#a855f7"]

                                    delegate: Components.ColorSwatch {
                                        width: 24
                                        height: 24
                                        colorValue: modelData
                                        border.color: String(colorField.text).toLowerCase() === String(modelData).toLowerCase() ? "white" : Qt.rgba(1, 1, 1, 0.15)
                                        border.width: String(colorField.text).toLowerCase() === String(modelData).toLowerCase() ? 2 : 1
                                        scale: String(colorField.text).toLowerCase() === String(modelData).toLowerCase() ? 1.15 : 1
                                        onClicked: colorField.text = String(modelData)
                                    }

                                }

                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Components.ColorSwatch {
                                    colorValue: colorField.text
                                    width: 36
                                    height: 36
                                    onClicked: {
                                        masterColorDialog.targetObject = colorField;
                                        masterColorDialog.targetProperty = "text";
                                        masterColorDialog.targetIndex = -1;
                                        masterColorDialog.selectedColor = colorField.text;
                                        masterColorDialog.open();
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    color: colorField.activeFocus ? Components.Theme.activeBg : Qt.rgba(0, 0, 0, 0.1)
                                    border.color: colorField.activeFocus ? Components.Theme.accentCol : Components.Theme.controlBorder
                                    radius: 6

                                    TextInput {
                                        id: colorField

                                        anchors.fill: parent
                                        anchors.margins: 12
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Components.Theme.textPrimary
                                        font.pixelSize: 12
                                        text: "#ffffff"
                                    }

                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                            }

                        }

                    }

                    // 3. DATA FORMAT CARD
                    Rectangle {
                        visible: ["ram", "swap", "upload", "download", "cpu_temp", "gpu_temp"].indexOf(addDialog.editingModuleId) !== -1
                        Layout.fillWidth: true
                        Layout.preferredHeight: formatCol.implicitHeight + 24
                        color: Components.Theme.controlBg
                        border.color: Components.Theme.controlBorder
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            id: formatCol

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "DATA FORMAT"
                                color: Components.Theme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            ColumnLayout {
                                visible: ["ram", "swap"].indexOf(addDialog.editingModuleId) !== -1
                                spacing: 8

                                Text {
                                    text: "Display Mode"
                                    color: Components.Theme.textSecondary
                                    font.pixelSize: 11
                                }

                                RowLayout {
                                    spacing: 4

                                    Repeater {
                                        model: ["Percentage", "Value"]

                                        delegate: Rectangle {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 30
                                            radius: 6
                                            color: index === addDialog.currentDisplayMode ? Components.Theme.accentCol : (ma.containsMouse ? Components.Theme.controlHover : Components.Theme.controlBg)
                                            border.color: index === addDialog.currentDisplayMode ? Qt.lighter(Components.Theme.accentCol, 1.2) : Components.Theme.controlBorder
                                            border.width: index === addDialog.currentDisplayMode ? 2 : 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: index === addDialog.currentDisplayMode ? "white" : Components.Theme.textSecondary
                                                font.pixelSize: 11
                                                font.bold: index === addDialog.currentDisplayMode
                                            }

                                            MouseArea {
                                                id: ma

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: addDialog.currentDisplayMode = index
                                            }

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 150
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                            ColumnLayout {
                                visible: ["cpu_temp", "gpu_temp"].indexOf(addDialog.editingModuleId) !== -1
                                spacing: 8

                                Text {
                                    text: "Temperature Unit"
                                    color: Components.Theme.textSecondary
                                    font.pixelSize: 11
                                }

                                RowLayout {
                                    spacing: 4

                                    Repeater {
                                        model: ["Celsius (°C)", "Fahrenheit (°F)"]

                                        delegate: Rectangle {
                                            Layout.preferredWidth: 120
                                            Layout.preferredHeight: 30
                                            radius: 6
                                            color: index === addDialog.currentTempUnit ? Components.Theme.accentCol : (maT.containsMouse ? Components.Theme.controlHover : Components.Theme.controlBg)
                                            border.color: index === addDialog.currentTempUnit ? Qt.lighter(Components.Theme.accentCol, 1.2) : Components.Theme.controlBorder
                                            border.width: index === addDialog.currentTempUnit ? 2 : 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: index === addDialog.currentTempUnit ? "white" : Components.Theme.textSecondary
                                                font.pixelSize: 11
                                                font.bold: index === addDialog.currentTempUnit
                                            }

                                            MouseArea {
                                                id: maT

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: addDialog.currentTempUnit = index
                                            }

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 150
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                            ColumnLayout {
                                visible: ["upload", "download"].indexOf(addDialog.editingModuleId) !== -1
                                spacing: 8

                                Text {
                                    text: "Speed Format"
                                    color: Components.Theme.textSecondary
                                    font.pixelSize: 11
                                }

                                Flow {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Repeater {
                                        model: ["Use Global", "KB, MB, GB, TB", "B, KB, MB, GB, TB", "Kbps, Mbps, Gbps, Tbps", "bps, Kbps, Mbps, Gbps, Tbps"]

                                        delegate: Rectangle {
                                            width: 140
                                            height: 30
                                            radius: 6
                                            color: (index - 1) === addDialog.currentSpeedFormat ? Components.Theme.accentCol : (ma2.containsMouse ? Components.Theme.controlHover : Components.Theme.controlBg)
                                            border.color: (index - 1) === addDialog.currentSpeedFormat ? Qt.lighter(Components.Theme.accentCol, 1.2) : Components.Theme.controlBorder
                                            border.width: (index - 1) === addDialog.currentSpeedFormat ? 2 : 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: (index - 1) === addDialog.currentSpeedFormat ? "white" : Components.Theme.textSecondary
                                                font.pixelSize: 10
                                                font.bold: (index - 1) === addDialog.currentSpeedFormat
                                            }

                                            MouseArea {
                                                id: ma2

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: addDialog.currentSpeedFormat = index - 1
                                            }

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 150
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                    // 4. CONDITIONS CARD
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: condCol.implicitHeight + 24
                        color: Components.Theme.controlBg
                        border.color: Components.Theme.controlBorder
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            id: condCol

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "DYNAMIC CONDITIONS"
                                color: Components.Theme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    model: tempConditionsModel

                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        color: Qt.rgba(1, 1, 1, 0.03)
                                        border.color: Components.Theme.controlBorder
                                        border.width: 1
                                        radius: 6

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            spacing: 4

                                            Text {
                                                text: "If val"
                                                color: Components.Theme.textSecondary
                                                font.pixelSize: 11
                                                Layout.leftMargin: 8
                                            }

                                            QQC2.ComboBox {
                                                id: editOpCombo

                                                property var ops: ["==", ">", "<", ">=", "<="]

                                                model: ops
                                                Layout.preferredWidth: 60
                                                Layout.preferredHeight: 28
                                                font.pixelSize: 12
                                                currentIndex: {
                                                    var data = tempConditionsModel.get(index);
                                                    return data ? ops.indexOf(data.operator) : 0;
                                                }
                                                onActivated: (idx) => {
                                                    if (index >= 0 && index < tempConditionsModel.count)
                                                        tempConditionsModel.setProperty(index, "operator", ops[idx]);

                                                }
                                            }

                                            TextInput {
                                                Layout.preferredWidth: 40
                                                Layout.fillHeight: true
                                                color: Components.Theme.textPrimary
                                                font.pixelSize: 12
                                                verticalAlignment: TextInput.AlignVCenter
                                                text: model.threshold
                                                onTextEdited: {
                                                    if (index >= 0 && index < tempConditionsModel.count)
                                                        tempConditionsModel.setProperty(index, "threshold", text.trim());

                                                }
                                            }

                                            Text {
                                                text: "then"
                                                color: Components.Theme.textSecondary
                                                font.pixelSize: 11
                                            }

                                            TextInput {
                                                Layout.preferredWidth: 60
                                                Layout.fillHeight: true
                                                color: Components.Theme.textPrimary
                                                font.pixelSize: 12
                                                verticalAlignment: TextInput.AlignVCenter
                                                text: model.color
                                                onTextEdited: {
                                                    if (index >= 0 && index < tempConditionsModel.count)
                                                        tempConditionsModel.setProperty(index, "color", text.trim());

                                                }
                                            }

                                            Components.ColorSwatch {
                                                colorValue: model.color
                                                width: 24
                                                height: 24
                                                onClicked: {
                                                    masterColorDialog.targetObject = tempConditionsModel;
                                                    masterColorDialog.targetProperty = "color";
                                                    masterColorDialog.targetIndex = index;
                                                    masterColorDialog.selectedColor = model.color;
                                                    masterColorDialog.open();
                                                }
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 32
                                                Layout.fillHeight: true
                                                color: "transparent"

                                                Kirigami.Icon {
                                                    anchors.centerIn: parent
                                                    width: 14
                                                    height: 14
                                                    source: "delete"
                                                    color: Components.Theme.dangerCol
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: tempConditionsModel.remove(index)
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                color: Qt.rgba(0, 0, 0, 0.15)
                                border.color: Components.Theme.controlBorder
                                border.width: 1
                                radius: 6

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 4

                                    Text {
                                        text: "If val"
                                        color: Components.Theme.textSecondary
                                        font.pixelSize: 11
                                        Layout.leftMargin: 8
                                    }

                                    QQC2.ComboBox {
                                        id: condOp

                                        model: ["==", ">", "<", ">=", "<="]
                                        Layout.preferredWidth: 60
                                        Layout.preferredHeight: 28
                                        font.pixelSize: 12
                                    }

                                    TextInput {
                                        id: condThresh

                                        Layout.preferredWidth: 40
                                        Layout.fillHeight: true
                                        color: Components.Theme.textPrimary
                                        font.pixelSize: 12
                                        verticalAlignment: TextInput.AlignVCenter

                                        Text {
                                            text: "80"
                                            color: Components.Theme.textTertiary
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: !parent.text
                                        }

                                    }

                                    Text {
                                        text: "then"
                                        color: Components.Theme.textSecondary
                                        font.pixelSize: 11
                                    }

                                    TextInput {
                                        id: condColor

                                        Layout.preferredWidth: 60
                                        Layout.fillHeight: true
                                        color: Components.Theme.textPrimary
                                        font.pixelSize: 12
                                        verticalAlignment: TextInput.AlignVCenter

                                        Text {
                                            text: "#ff0000"
                                            color: Components.Theme.textTertiary
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: !parent.text
                                        }

                                    }

                                    Components.ColorSwatch {
                                        colorValue: condColor.text
                                        width: 24
                                        height: 24
                                        onClicked: {
                                            masterColorDialog.targetObject = condColor;
                                            masterColorDialog.targetProperty = "text";
                                            masterColorDialog.targetIndex = -1;
                                            masterColorDialog.selectedColor = condColor.text;
                                            masterColorDialog.open();
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 48
                                        Layout.fillHeight: true
                                        color: Components.Theme.accentCol
                                        radius: 4

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Add"
                                            color: "white"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (condThresh.text.trim() === "" || condColor.text.trim() === "")
                                                    return ;

                                                tempConditionsModel.append({
                                                    "operator": condOp.currentText,
                                                    "threshold": condThresh.text.trim(),
                                                    "color": condColor.text.trim()
                                                });
                                                condThresh.text = "";
                                                condColor.text = "";
                                            }
                                        }

                                    }

                                }

                            }

                        }

                    }

                    // 0. LIVE PREVIEW CARD (Moved to bottom and scale set to normal)
                    Rectangle {
                        function cToF(c) {
                            return Math.round((c * 9 / 5) + 32);
                        }

                        function formatBytes(bytes, overrideFmt) {
                            var fmt = (overrideFmt !== undefined && overrideFmt !== -1) ? overrideFmt : cfg.netSpeedFormat;
                            var isBits = (fmt === 2 || fmt === 3);
                            var val = isBits ? (bytes * 8) : bytes;
                            var unitB = isBits ? "bps" : "B";
                            var unitK = isBits ? "Kbps" : "KB";
                            var unitM = isBits ? "Mbps" : "MB";
                            var unitG = isBits ? "Gbps" : "GB";
                            var unitT = isBits ? "Tbps" : "TB";
                            var limits = [1024, 1.04858e+06, 1.07374e+09, 1.09951e+12];
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

                        function evaluatePreviewColor(val, baseCol, condCount) {
                            var v = parseFloat(val);
                            if (isNaN(v))
                                return baseCol;

                            for (var i = 0; i < condCount; i++) {
                                var c = tempConditionsModel.get(i);
                                if (!c)
                                    continue;

                                var thresh = parseFloat(c.threshold);
                                if (isNaN(thresh))
                                    continue;

                                var matched = false;
                                if (c.operator === "==" && v === thresh)
                                    matched = true;
                                else if (c.operator === ">" && v > thresh)
                                    matched = true;
                                else if (c.operator === "<" && v < thresh)
                                    matched = true;
                                else if (c.operator === ">=" && v >= thresh)
                                    matched = true;
                                else if (c.operator === "<=" && v <= thresh)
                                    matched = true;
                                if (matched)
                                    return c.color;

                            }
                            return baseCol;
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        color: Qt.rgba(0, 0, 0, 0.25)
                        border.color: Components.Theme.borderCol
                        border.width: 1
                        radius: 12
                        clip: true

                        Sensors.Sensor {
                            id: previewSensor

                            sensorId: idField.text
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "LIVE PREVIEW"
                                color: Components.Theme.accentCol
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 2
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Base.MonitorItem {
                                id: previewMonitorItem

                                Layout.alignment: Qt.AlignHCenter
                                icon: addDialog.selectedIcon.indexOf("/") !== -1 ? "file://" + addDialog.selectedIcon : Qt.resolvedUrl("../../icons/" + addDialog.selectedIcon)
                                label: {
                                    if (!idField.text || (previewSensor.status === Sensors.Sensor.Error && !previewSensor.formattedValue))
                                        return "75%"; // demo value

                                    // RAM Display Mode
                                    if (addDialog.editingModuleId === "ram") {
                                        if (addDialog.currentDisplayMode === 0)
                                            // Percentage
                                            return page.percent(previewSensor.value || 0, ramTotal.value || 1);
                                        else
                                            return parent.parent.formatBytes(previewSensor.value || 0, -1);
                                    }
                                    // Swap Display Mode
                                    if (addDialog.editingModuleId === "swap") {
                                        if (addDialog.currentDisplayMode === 0)
                                            // Percentage
                                            return page.percent(previewSensor.value || 0, swapTotal.value || 1);
                                        else
                                            return parent.parent.formatBytes(previewSensor.value || 0, -1);
                                    }
                                    // Temperature Unit
                                    if (["cpu_temp", "gpu_temp"].indexOf(addDialog.editingModuleId) !== -1) {
                                        var val = previewSensor.value !== undefined ? Math.round(previewSensor.value) : 0;
                                        if (addDialog.currentTempUnit === 1)
                                            // Fahrenheit
                                            return parent.parent.cToF(val) + "°F";
                                        else
                                            return val + "°C";
                                    }
                                    // Network Speed Format Override
                                    if (["upload", "download"].indexOf(addDialog.editingModuleId) !== -1)
                                        return parent.parent.formatBytes(previewSensor.value || 0, addDialog.currentSpeedFormat);

                                    return previewSensor.formattedValue || (previewSensor.value !== undefined ? Math.round(previewSensor.value) : "N/A");
                                }
                                color: parent.parent.evaluatePreviewColor((previewSensor.value !== undefined ? previewSensor.value : 75), colorField.text, tempConditionsModel.count)
                                fontSize: cfg.fontSize || 10
                                fontFamily: cfg.fontFamily || ""
                                showIcon: true
                                showTooltips: false
                                // Reset to normal scale
                                scale: 1
                            }

                            Text {
                                text: idField.text ? "Source: " + idField.text : "Select a sensor to see live data"
                                color: Components.Theme.textTertiary
                                font.pixelSize: 10
                                font.italic: true
                                Layout.alignment: Qt.AlignHCenter
                                elide: Text.ElideMiddle
                                Layout.preferredWidth: parent.width - 40
                                horizontalAlignment: Text.AlignHCenter
                            }

                        }

                    }

                    // bottom padding
                    Item {
                        Layout.preferredHeight: 8
                    }

                }

            }

            // CUSTOM FOOTER
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: Components.Theme.borderCol
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // push buttons to right
                    Item {
                        Layout.fillWidth: true
                    }

                    // Cancel Button
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.fillHeight: true
                        color: cancelHover.containsMouse ? Components.Theme.hoverBg : "transparent"
                        border.color: Components.Theme.controlBorder
                        radius: 6

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Components.Theme.textPrimary
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: cancelHover

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: addDialog.close()
                        }

                    }

                    // Save Button
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.fillHeight: true
                        color: saveHover.containsMouse ? Qt.lighter(Components.Theme.accentCol, 1.1) : Components.Theme.accentCol
                        radius: 6

                        Text {
                            anchors.centerIn: parent
                            text: "Save Module"
                            color: "white"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: saveHover

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: addDialog.saveModule()
                        }

                    }

                }

            }

        }

    }

    FileDialog {
        id: iconDialog

        title: "Select Custom SVG Icon"
        nameFilters: ["SVG Files (*.svg)"]
        onAccepted: {
            var path = selectedFile.toString();
            // Remove file:// prefix if present
            if (path.startsWith("file://"))
                path = path.substring(7);

            // Check if it exists
            var exists = false;
            for (var i = 0; i < iconListModel.count; i++) {
                if (iconListModel.get(i).icon === path) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                var newName = path.substring(path.lastIndexOf("/") + 1);
                iconListModel.append({
                    "icon": path,
                    "name": newName
                });
            }
            addDialog.selectedIcon = path;
        }
    }

    QQC2.ScrollBar.vertical: QQC2.ScrollBar {
        policy: QQC2.ScrollBar.AsNeeded
    }

}
