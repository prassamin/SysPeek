import "../components" as Components
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksysguard.sensors 1.0 as Sensors

Item {
    id: page

    property var cfg
    property Item edgeSafeContainer: null
    property var baseAvailableItems: ["cpu", "gpu", "ram", "swap", "upload", "download", "cpu_temp", "gpu_temp", "vram", "uptime"]
    property var availableItems: {
        var items = baseAvailableItems.slice();
        try {
            var mods = JSON.parse(cfg.customModules || "[]");
            for (var i = 0; i < mods.length; i++) {
                if (baseAvailableItems.indexOf(mods[i].id) === -1)
                    items.push(mods[i].id);

            }
        } catch (e) {
        }
        return items;
    }
    property var itemMetadata: {
        var meta = {
            "cpu": {
                "name": "CPU",
                "color": cfg.cpuColor || "#ffffff"
            },
            "gpu": {
                "name": "GPU",
                "color": cfg.gpuColor || "#ffffff"
            },
            "ram": {
                "name": "RAM",
                "color": cfg.ramColor || "#ffffff"
            },
            "swap": {
                "name": "SWAP",
                "color": cfg.swapColor || "#ffffff"
            },
            "upload": {
                "name": "UPLOAD",
                "color": cfg.uploadColor || "#ffffff"
            },
            "download": {
                "name": "DOWNLOAD",
                "color": cfg.downloadColor || "#ffffff"
            },
            "cpu_temp": {
                "name": "CPU TEMP",
                "color": cfg.cpuTempColor || "#ffffff"
            },
            "gpu_temp": {
                "name": "GPU TEMP",
                "color": cfg.gpuTempColor || "#ffffff"
            },
            "vram": {
                "name": "VRAM",
                "color": cfg.vramColor || "#ffffff"
            },
            "uptime": {
                "name": "UPTIME",
                "color": cfg.uptimeColor || "#ffffff"
            }
        };
        try {
            var mods = JSON.parse(cfg.customModules || "[]");
            for (var i = 0; i < mods.length; i++) {
                // Built-ins keep their hardcoded names in placement usually,
                // but if we want custom labels for them too, we'd add m.label here.

                var m = mods[i];
                if (!meta[m.id]) {
                    meta[m.id] = {
                        "name": (m.label || m.id).toUpperCase(),
                        "color": m.color || "#ffffff"
                    };
                } else {
                    // It's a built-in override, only update color if present
                    if (m.color)
                        meta[m.id].color = m.color;

                }
            }
        } catch (e) {
        }
        return meta;
    }
    // ── LIVE DISPLACEMENT STATE ──
    property var columnModels: []
    property var activeSpacerModel: null
    property int activeSpacerIndex: -1
    property string activeSpacerItemId: ""
    property bool isPaletteDrag: false

    function parseLayout() {
        for (var i = 0; i < columnModels.length; i++) {
            columnModels[i].destroy();
        }
        columnModels = [];
        var str = cfg.panelLayout || "";
        var cols = str.split('|');
        var newModels = [];
        for (var c = 0; c < cols.length; c++) {
            var model = Qt.createQmlObject('import QtQuick 2.15; ListModel {}', page);
            var items = cols[c].split(',');
            for (var j = 0; j < items.length; j++) {
                var it = items[j].trim();
                if (it !== "")
                    model.append({
                        "itemId": it,
                        "isSpacer": false,
                        "isDead": false
                    });

            }
            newModels.push(model);
        }
        columnModels = newModels;
        layoutRow.model = columnModels;
    }

    function saveLayout() {
        var colStrings = [];
        for (var i = 0; i < columnModels.length; i++) {
            var model = columnModels[i];
            var items = [];
            for (var j = 0; j < model.count; j++) {
                var element = model.get(j);
                if (!element.isSpacer && !element.isDead)
                    items.push(element.itemId);

            }
            colStrings.push(items.join(','));
        }
        cfg.panelLayout = colStrings.join('|');
    }

    function handleDropEntered(targetModel, targetIndex) {
        if (!activeSpacerModel) {
            if (isPaletteDrag) {
                targetModel.insert(targetIndex, {
                    "itemId": activeSpacerItemId,
                    "isSpacer": true
                });
                activeSpacerModel = targetModel;
                activeSpacerIndex = targetIndex;
            }
            return ;
        }
        if (targetIndex >= targetModel.count && activeSpacerModel !== targetModel)
            targetIndex = targetModel.count;
        else if (targetIndex >= targetModel.count && activeSpacerModel === targetModel)
            targetIndex = targetModel.count - 1;
        if (activeSpacerModel === targetModel) {
            if (activeSpacerIndex !== targetIndex) {
                targetModel.move(activeSpacerIndex, targetIndex, 1);
                activeSpacerIndex = targetIndex;
            }
        } else {
            // Soft delete the old delegate so it survives and retains the mouse grab!
            activeSpacerModel.setProperty(activeSpacerIndex, "isDead", true);
            targetModel.insert(targetIndex, {
                "itemId": activeSpacerItemId,
                "isSpacer": true,
                "isDead": false
            });
            activeSpacerModel = targetModel;
            activeSpacerIndex = targetIndex;
        }
    }

    function addColumn() {
        var model = Qt.createQmlObject('import QtQuick 2.15; ListModel {}', page);
        var newArray = columnModels.slice();
        newArray.push(model);
        columnModels = newArray;
        layoutRow.model = columnModels;
        saveLayout();
    }

    function removeColumn(colIndex) {
        columnModels[colIndex].destroy();
        var newArray = columnModels.slice();
        newArray.splice(colIndex, 1);
        columnModels = newArray;
        layoutRow.model = columnModels;
        saveLayout();
    }

    Component.onCompleted: parseLayout()

    Sensors.SensorTreeModel {
        id: sensorTree
    }

    Connections {
        function onPanelLayoutChanged() {
            // Avoid recursive updates if we just saved
            if (!activeSpacerModel)
                parseLayout();

        }

        target: cfg
    }

    // ── COMPONENTS ──
    Component {
        id: ghostComponent

        Rectangle {
            id: ghostItem

            property string itemId

            width: 116
            height: 36
            radius: 6
            color: Components.Theme.controlBg
            border.color: Components.Theme.accentCol
            border.width: 2
            z: 99999
            Drag.active: true
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            Drag.source: ghostItem
            Drag.keys: ["chip"]

            // Premium double-glow effect behind the dragging chip
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 16
                height: parent.height + 16
                radius: 14
                color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.15)
                z: -1

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 8
                    height: parent.height - 8
                    radius: 10
                    color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.3)
                }

            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Rectangle {
                    width: 4
                    height: 16
                    radius: 2
                    color: page.itemMetadata[itemId] ? page.itemMetadata[itemId].color : Components.Theme.textSecondary
                }

                Text {
                    text: page.itemMetadata[itemId] ? page.itemMetadata[itemId].name : itemId
                    color: Components.Theme.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

            }

        }

    }

    // ── UI ──
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        DropArea {
            id: paletteDropArea

            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(100, paletteFlow.implicitHeight + 56)
            keys: ["chip"]

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.15)
                border.color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.3)
                border.width: 1
                radius: 12

                // Palette Header
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 32
                    radius: 12
                    color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.1)
                    opacity: (page.activeSpacerModel !== null && !page.isPaletteDrag) ? 0 : 1

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 12
                        color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.1)
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.3)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "AVAILABLE MODULES"
                        color: Components.Theme.accentCol
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Qt.rgba(Components.Theme.dangerCol.r, Components.Theme.dangerCol.g, Components.Theme.dangerCol.b, paletteDropArea.containsDrag ? 0.15 : 0.05)
                    border.color: Components.Theme.dangerCol
                    border.width: 2
                    opacity: (page.activeSpacerModel !== null && !page.isPaletteDrag) ? (paletteDropArea.containsDrag ? 1 : 0.6) : 0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Kirigami.Icon {
                            width: 18
                            height: 18
                            source: "delete"
                            color: Components.Theme.dangerCol
                        }

                        Text {
                            text: paletteDropArea.containsDrag ? "Release to Delete!" : "Drag here to Delete"
                            color: Components.Theme.dangerCol
                            font.pixelSize: 14
                            font.bold: true
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Flow {
                    id: paletteFlow

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.bottomMargin: 12
                    anchors.topMargin: 44
                    spacing: 8
                    opacity: (page.activeSpacerModel !== null && !page.isPaletteDrag) ? 0 : 1

                    Repeater {
                        model: availableItems

                        delegate: Item {
                            width: 116
                            height: 36

                            ChipVisuals {
                                anchors.fill: parent
                                itemId: modelData
                            }

                            MouseArea {
                                id: mainMouseArea

                                property Item ghost: null

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                                preventStealing: true
                                onPressed: (mouse) => {
                                    var pos = mapToItem(page, mouse.x, mouse.y);
                                    ghost = ghostComponent.createObject(page, {
                                        "itemId": modelData,
                                        "x": pos.x - width / 2,
                                        "y": pos.y - height / 2
                                    });
                                    page.isPaletteDrag = true;
                                    page.activeSpacerModel = null;
                                    page.activeSpacerIndex = -1;
                                    page.activeSpacerItemId = modelData;
                                }
                                onPositionChanged: (mouse) => {
                                    if (ghost) {
                                        var pos = mapToItem(page, mouse.x, mouse.y);
                                        ghost.x = pos.x - ghost.width / 2;
                                        ghost.y = pos.y - ghost.height / 2;
                                    }
                                }
                                onReleased: (mouse) => {
                                    if (ghost) {
                                        if (ghost.Drag.target === paletteDropArea) {
                                            if (page.activeSpacerModel)
                                                page.activeSpacerModel.remove(page.activeSpacerIndex, 1);

                                        } else {
                                            if (page.activeSpacerModel)
                                                page.activeSpacerModel.setProperty(page.activeSpacerIndex, "isSpacer", false);

                                        }
                                        ghost.Drag.drop();
                                        ghost.Drag.active = false;
                                        ghost.destroy();
                                        ghost = null;
                                        page.activeSpacerModel = null;
                                        saveLayout();
                                    }
                                }
                                onCanceled: {
                                    if (ghost) {
                                        ghost.Drag.active = false;
                                        ghost.destroy();
                                    }
                                    ghost = null;
                                    if (page.activeSpacerModel) {
                                        page.activeSpacerModel.setProperty(page.activeSpacerIndex, "isSpacer", false);
                                        page.activeSpacerModel = null;
                                    }
                                }
                            }

                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

            }

        }

        Components.SectionLabel {
            text: "PANEL LAYOUT"
        }

        ListView {
            id: layoutRow

            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            model: columnModels

            MouseArea {
                anchors.fill: parent
                z: -1
                acceptedButtons: Qt.NoButton
                cursorShape: layoutRow.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                onWheel: (wheel) => {
                    var delta = Math.abs(wheel.angleDelta.x) > Math.abs(wheel.angleDelta.y) ? wheel.angleDelta.x : wheel.angleDelta.y;
                    var newX = layoutRow.contentX - delta;
                    layoutRow.contentX = Math.max(0, Math.min(newX, layoutRow.contentWidth - layoutRow.width));
                }
            }

            QQC2.ScrollBar.horizontal: QQC2.ScrollBar {
                policy: QQC2.ScrollBar.AsNeeded
            }

            delegate: Item {
                property int columnIndex: index
                property var currentModelData: modelData

                width: 140
                height: Math.max(200, page.height - 250)

                MouseArea {
                    anchors.fill: parent
                    z: 99
                    acceptedButtons: Qt.NoButton
                    cursorShape: layoutRow.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    onWheel: (wheel) => {
                        var isVerticalSwipe = Math.abs(wheel.angleDelta.y) > Math.abs(wheel.angleDelta.x);
                        var needsVerticalScroll = colListView.contentHeight > colListView.height;
                        if (isVerticalSwipe && needsVerticalScroll) {
                            wheel.accepted = false; // Let the colListView underneath scroll vertically
                            return ;
                        }
                        // Pan horizontally
                        var delta = isVerticalSwipe ? wheel.angleDelta.y : wheel.angleDelta.x;
                        var newX = layoutRow.contentX - delta;
                        layoutRow.contentX = Math.max(0, Math.min(newX, layoutRow.contentWidth - layoutRow.width));
                        wheel.accepted = true;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.15)
                    border.color: Components.Theme.borderCol
                    border.width: 1
                    radius: 12

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32
                        radius: 12
                        color: Qt.rgba(255, 255, 255, 0.03)

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 12
                            color: Qt.rgba(255, 255, 255, 0.03)
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Components.Theme.borderCol
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Group " + (index + 1)
                            color: Components.Theme.textSecondary
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.margins: 4
                            width: 24
                            height: 24
                            radius: 12
                            color: rmHover.containsMouse ? Components.Theme.dangerCol : "transparent"
                            visible: columnModels.length > 1

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                source: "window-close-symbolic"
                                color: rmHover.containsMouse ? "white" : Components.Theme.textTertiary
                            }

                            MouseArea {
                                id: rmHover

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: removeColumn(columnIndex)
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }

                            }

                        }

                    }

                    // Catch drops in empty space at the bottom of the column
                    DropArea {
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.topMargin: 44
                        keys: ["chip"]
                        onEntered: (drag) => {
                            page.handleDropEntered(currentModelData, currentModelData.count);
                        }
                    }

                    QQC2.ScrollView {
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.topMargin: 44

                        ListView {
                            id: colListView

                            model: currentModelData
                            spacing: 0 // Spacing is absorbed by delegate height
                            interactive: true
                            clip: true

                            move: Transition {
                                NumberAnimation {
                                    properties: "x,y"
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }

                            }

                            displaced: Transition {
                                NumberAnimation {
                                    properties: "x,y"
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }

                            }

                            delegate: Item {
                                id: delegateRoot

                                width: 116
                                height: model.isDead ? 0 : 44
                                opacity: model.isDead ? 0 : 1

                                DropArea {
                                    anchors.fill: parent
                                    keys: ["chip"]
                                    onEntered: (drag) => {
                                        if (model.isDead)
                                            return ;

                                        page.handleDropEntered(currentModelData, index);
                                        drag.accepted = true; // Stop propagation to background DropArea
                                    }
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: 116
                                    height: 36
                                    radius: 6
                                    color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.08)
                                    border.color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.4)
                                    border.width: 1
                                    opacity: model.isSpacer ? 1 : 0

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width - 8
                                        height: parent.height - 8
                                        radius: 4
                                        border.color: Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.2)
                                        border.width: 1
                                        color: "transparent"
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                        }

                                    }

                                }

                                ChipVisuals {
                                    id: visualChip

                                    anchors.bottom: parent.bottom
                                    width: 116
                                    height: 36
                                    itemId: model.itemId
                                    opacity: model.isSpacer ? 0 : 1

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                        }

                                    }

                                }

                                MouseArea {
                                    property Item ghost: null

                                    anchors.bottom: parent.bottom
                                    width: 116
                                    height: 36
                                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                                    preventStealing: true
                                    onPressed: (mouse) => {
                                        if (model.isSpacer)
                                            return ;

                                        var pos = mapToItem(page, mouse.x, mouse.y);
                                        ghost = ghostComponent.createObject(page, {
                                            "itemId": model.itemId,
                                            "x": pos.x - visualChip.width / 2,
                                            "y": pos.y - visualChip.height / 2
                                        });
                                        page.isPaletteDrag = false;
                                        page.activeSpacerModel = currentModelData;
                                        page.activeSpacerIndex = index;
                                        page.activeSpacerItemId = model.itemId;
                                        currentModelData.setProperty(index, "isSpacer", true);
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (ghost) {
                                            var pos = mapToItem(page, mouse.x, mouse.y);
                                            ghost.x = pos.x - ghost.width / 2;
                                            ghost.y = pos.y - ghost.height / 2;
                                        }
                                    }
                                    onReleased: (mouse) => {
                                        if (ghost) {
                                            if (ghost.Drag.target === paletteDropArea) {
                                                if (page.activeSpacerModel)
                                                    page.activeSpacerModel.remove(page.activeSpacerIndex, 1);

                                            } else {
                                                if (page.activeSpacerModel)
                                                    page.activeSpacerModel.setProperty(page.activeSpacerIndex, "isSpacer", false);

                                            }
                                            ghost.Drag.drop();
                                            ghost.Drag.active = false;
                                            ghost.destroy();
                                            ghost = null;
                                            page.activeSpacerModel = null;
                                            saveLayout();
                                        }
                                    }
                                    onCanceled: {
                                        if (ghost) {
                                            ghost.Drag.active = false;
                                            ghost.destroy();
                                        }
                                        ghost = null;
                                        if (page.activeSpacerModel) {
                                            page.activeSpacerModel.setProperty(page.activeSpacerIndex, "isSpacer", false);
                                            page.activeSpacerModel = null;
                                        }
                                    }
                                }

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }

                                }

                            }

                        }

                    }

                }
                // End of outer delegate Item

            }

            footer: Item {
                width: 140
                height: Math.max(200, page.height - 250)

                Rectangle {
                    anchors.fill: parent
                    color: addHover.containsMouse ? Qt.rgba(Components.Theme.accentCol.r, Components.Theme.accentCol.g, Components.Theme.accentCol.b, 0.05) : "transparent"
                    border.color: addHover.containsMouse ? Components.Theme.accentCol : Qt.rgba(Components.Theme.borderCol.r, Components.Theme.borderCol.g, Components.Theme.borderCol.b, 0.5)
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Kirigami.Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            source: "list-add-symbolic"
                            color: addHover.containsMouse ? Components.Theme.accentCol : Components.Theme.textSecondary

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                        Text {
                            text: "Add Group"
                            color: addHover.containsMouse ? Components.Theme.accentCol : Components.Theme.textSecondary
                            font.pixelSize: 13
                            anchors.horizontalCenter: parent.horizontalCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                    MouseArea {
                        id: addHover

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.addColumn()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

            }

        }

    }

    component ChipVisuals: Rectangle {
        property string itemId

        radius: 6
        color: Components.Theme.controlBg
        border.color: Components.Theme.controlBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Rectangle {
                width: 4
                height: 16
                radius: 2
                color: page.itemMetadata[itemId] ? page.itemMetadata[itemId].color : Components.Theme.textSecondary
            }

            Text {
                text: page.itemMetadata[itemId] ? page.itemMetadata[itemId].name : itemId
                color: Components.Theme.textPrimary
                font.pixelSize: 11
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

        }

    }

}
