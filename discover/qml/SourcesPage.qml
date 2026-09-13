/*
 *   SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2026 Lucas Ramos <lucasramos@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.discover as Discover
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

DiscoverPage {
    id: page

    property string search
    readonly property string name: title

    clip: true
    title: i18n("Settings")

    Kirigami.Action {
        id: configureUpdatesAction
        text: i18n("Configure Updates…")
        displayHint: Kirigami.DisplayHint.AlwaysHide
        onTriggered: {
            KCMUtils.KCMLauncher.openSystemSettings("kcm_updates");
        }
    }

    actions: feedbackLoader.item?.actions ?? [configureUpdatesAction]

    header: Item {
        implicitWidth: page.width
        implicitHeight: inlineCol.implicitHeight > 0 ? inlineCol.implicitHeight + Kirigami.Units.largeSpacing : 0
        visible: inlineCol.implicitHeight > 0

        ColumnLayout {
            id: inlineCol
            width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, 1024)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: Discover.SourcesModel.sources

                delegate: Kirigami.InlineMessage {
                    id: inlineDelegate

                    required property Discover.AbstractSourcesBackend modelData

                    Layout.fillWidth: true
                    text: modelData.inlineAction?.toolTip ?? ""
                    visible: modelData.inlineAction?.visible ?? false
                    actions: Kirigami.Action {
                        icon.name: inlineDelegate.modelData.inlineAction?.iconName ?? ""
                        text: inlineDelegate.modelData.inlineAction?.text ?? ""
                        onTriggered: inlineDelegate.modelData.inlineAction?.trigger()
                    }
                }
            }
        }
    }

    ListView {
        id: sourcesView
        model: KItemModels.KSortFilterProxyModel {
            sourceModel: Discover.SourcesModel
            filterString: page.search
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        Component.onCompleted: Qt.callLater(Discover.SourcesModel.showingNow)
        currentIndex: -1
        pixelAligned: true
        section.property: "sourceName"

        // Hero Banner Header
        header: Item {
            width: sourcesView.width
            implicitHeight: heroContainer.height + Kirigami.Units.largeSpacing * 2

            Item {
                id: heroContainer
                width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, 1024)
                anchors.horizontalCenter: parent.horizontalCenter
                y: Kirigami.Units.largeSpacing
                height: heroCard.height

                Rectangle {
                    id: heroCard
                    width: parent.width
                    height: heroContent.implicitHeight + Kirigami.Units.largeSpacing * 3
                    radius: 16
                    clip: true

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#475569" }
                        GradientStop { position: 1.0; color: "#1e293b" }
                    }

                    Kirigami.Icon {
                        source: "settings-configure"
                        width: 180
                        height: 180
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -Kirigami.Units.largeSpacing
                        anchors.bottomMargin: -Kirigami.Units.largeSpacing * 2
                        opacity: 0.10
                        color: "white"
                    }

                    RowLayout {
                        id: heroContent
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing * 1.5
                        spacing: Kirigami.Units.largeSpacing * 1.5

                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            radius: 16
                            color: Qt.rgba(1, 1, 1, 0.12)
                            border.color: Qt.rgba(1, 1, 1, 0.25)
                            border.width: 1

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                source: "settings-configure"
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing / 2

                            Kirigami.Heading {
                                text: i18n("Software Sources")
                                level: 2
                                font.weight: Font.Bold
                                color: "white"
                            }

                            QQC2.Label {
                                text: i18n("Manage software repositories and services where applications are installed from.")
                                color: Qt.rgba(1, 1, 1, 0.85)
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        // Section delegate for each backend (Flatpak, Snap, Firmware, etc.)
        section.delegate: Item {
            id: backendItem

            required property string section

            width: sourcesView.width
            implicitHeight: sectionInner.implicitHeight + Kirigami.Units.largeSpacing * 1.5

            readonly property Discover.AbstractSourcesBackend backend: Discover.SourcesModel.sourcesBackendByName(section)
            readonly property Discover.AbstractResourcesBackend resourcesBackend: backend ? backend.resourcesBackend : null
            readonly property bool isDefault: resourcesBackend && Discover.ResourcesModel.currentApplicationBackend === resourcesBackend

            Connections {
                target: backendItem.backend
                function onPassiveMessage(message) {
                    window.showPassiveNotification(message)
                }
                function onProceedRequest(title, description) {
                    const dialog = sourceProceedDialog.createObject(window, {
                        sourcesBackend: backendItem.backend,
                        title,
                        description,
                    })
                    dialog.open()
                }
            }

            Component {
                id: dialogComponent
                AddSourceDialog {
                    source: backendItem.backend

                    onClosed: {
                        destroy();
                    }
                }
            }

            Item {
                id: sectionInner
                width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, 1024)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                implicitHeight: sectionRow.implicitHeight

                RowLayout {
                    id: sectionRow
                    anchors.fill: parent
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Heading {
                        text: backendItem.resourcesBackend ? backendItem.resourcesBackend.displayName : backendItem.section
                        level: 4
                        font.weight: Font.Bold
                        font.capitalization: Font.AllUppercase
                        color: Kirigami.Theme.disabledTextColor
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        visible: backendItem.isDefault
                        implicitWidth: defaultLabel.implicitWidth + Kirigami.Units.largeSpacing
                        implicitHeight: 24
                        radius: 6
                        color: "#fef3c7"
                        border.color: "#fde68a"
                        border.width: 1

                        QQC2.Label {
                            id: defaultLabel
                            anchors.centerIn: parent
                            text: i18n("Default Source")
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            font.weight: Font.Bold
                            color: "#b45309"
                        }
                    }

                    QQC2.Button {
                        visible: backendItem.resourcesBackend && backendItem.resourcesBackend.hasApplications && !backendItem.isDefault
                        text: i18n("Make Default")
                        icon.name: "favorite"
                        onClicked: Discover.ResourcesModel.currentApplicationBackend = backendItem.backend.resourcesBackend
                    }

                    QQC2.Button {
                        visible: backendItem.backend && backendItem.backend.supportsAdding
                        text: i18n("Add Source…")
                        icon.name: "list-add"
                        onClicked: {
                            const addSourceDialog = dialogComponent.createObject(window, {
                                displayName: backendItem.backend.resourcesBackend.displayName,
                            })
                            addSourceDialog.open()
                        }
                    }

                    Repeater {
                        model: backendItem.backend ? backendItem.backend.actions : []
                        delegate: QQC2.Button {
                            required property Discover.DiscoverAction modelData
                            text: modelData.text
                            icon.name: modelData.iconName
                            QQC2.ToolTip.text: modelData.toolTip
                            QQC2.ToolTip.visible: hovered && modelData.toolTip.length > 0
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            visible: modelData.visible
                            enabled: modelData.enabled
                            onClicked: modelData.trigger()
                        }
                    }
                }
            }
        }

        Component {
            id: sourceProceedDialog
            Kirigami.OverlaySheet {
                id: sheet

                property Discover.AbstractSourcesBackend sourcesBackend
                property alias description: descriptionLabel.text
                property bool acted: false

                parent: page.QQC2.Overlay.overlay
                showCloseButton: false

                implicitWidth: Kirigami.Units.gridUnit * 30

                Kirigami.SelectableLabel {
                    id: descriptionLabel
                    width: parent.width
                    textFormat: TextEdit.RichText
                    wrapMode: TextEdit.Wrap
                }

                footer: QQC2.DialogButtonBox {
                    QQC2.Button {
                        QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.AcceptRole
                        text: i18n("Proceed")
                        icon.name: "dialog-ok"
                    }

                    QQC2.Button {
                        QQC2.DialogButtonBox.buttonRole: QQC2.DialogButtonBox.RejectRole
                        text: i18n("Cancel")
                        icon.name: "dialog-cancel"
                    }

                    onAccepted: {
                        sheet.sourcesBackend.proceed()
                        sheet.acted = true
                        sheet.close()
                    }

                    onRejected: {
                        sheet.sourcesBackend.cancel()
                        sheet.acted = true
                        sheet.close()
                    }
                }

                onOpened: {
                    descriptionLabel.forceActiveFocus(Qt.PopupFocusReason);
                }

                onClosed: {
                    if (!acted) {
                        sourcesBackend.cancel()
                    }
                    destroy();
                }
            }
        }

        // Delegate for each repository source item
        delegate: Item {
            id: delegate

            required property int index
            required property var model

            readonly property bool isFirst: (ListView.previousSection !== ListView.section)
            readonly property bool isLast: (ListView.nextSection !== ListView.section)

            width: sourcesView.width
            implicitHeight: rowCard.implicitHeight + (isLast ? Kirigami.Units.largeSpacing : 0)

            enabled: model.display.length > 0 && model.enabled
            Keys.onReturnPressed: enabledBox.clicked()
            Keys.onSpacePressed: enabledBox.clicked()

            Rectangle {
                id: rowCard
                width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, 1024)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                implicitHeight: rowContent.implicitHeight + Kirigami.Units.largeSpacing * 1.5

                color: itemMouseArea.containsMouse
                    ? Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.04)
                    : Kirigami.Theme.backgroundColor

                border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
                border.width: 1

                topLeftRadius: delegate.isFirst ? 16 : 0
                topRightRadius: delegate.isFirst ? 16 : 0
                bottomLeftRadius: delegate.isLast ? 16 : 0
                bottomRightRadius: delegate.isLast ? 16 : 0

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                // Subtle divider between rows
                Rectangle {
                    visible: !delegate.isLast
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.08)
                }

                RowLayout {
                    id: rowContent
                    anchors.fill: parent
                    anchors.leftMargin: Kirigami.Units.largeSpacing * 1.2
                    anchors.rightMargin: Kirigami.Units.largeSpacing * 1.2
                    anchors.topMargin: Kirigami.Units.largeSpacing * 0.75
                    anchors.bottomMargin: Kirigami.Units.largeSpacing * 0.75
                    spacing: Kirigami.Units.largeSpacing

                    QQC2.CheckBox {
                        id: enabledBox
                        readonly property var idx: index !== -1 ? sourcesView.model.index(index, 0) : null
                        readonly property int modelChecked: delegate.model.checkState ?? Qt.Unchecked
                        checked: modelChecked !== Qt.Unchecked
                        enabled: Boolean(idx && sourcesView.model.flags(idx) & Qt.ItemIsUserCheckable)
                        onClicked: if (idx) {
                            sourcesView.model.setData(idx, checkState, Qt.CheckStateRole)
                            checked = Qt.binding(() => (modelChecked !== Qt.Unchecked))
                        }
                        QQC2.ToolTip.text: i18nc("@info:tooltip", "Enable this source")
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: Kirigami.Units.smallSpacing

                            QQC2.Label {
                                text: delegate.model.display ?? ""
                                font.weight: Font.DemiBold
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                color: Kirigami.Theme.textColor
                                elide: Text.ElideRight
                            }

                            // Flathub default badge
                            Rectangle {
                                visible: Boolean(delegate.model.disambiguatedSourceId === "flathub")
                                implicitWidth: flathubDefaultLabel.implicitWidth + 8
                                implicitHeight: 18
                                radius: 4
                                color: "#fef3c7"
                                border.color: "#fde68a"
                                border.width: 1

                                QQC2.Label {
                                    id: flathubDefaultLabel
                                    anchors.centerIn: parent
                                    text: i18n("Default")
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize - 2
                                    font.weight: Font.Bold
                                    color: "#b45309"
                                }
                            }
                        }

                        QQC2.Label {
                            visible: Boolean(delegate.model.toolTip && delegate.model.toolTip.length > 0)
                            text: delegate.model.toolTip ?? ""
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            font.family: "monospace"
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Action buttons
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.ToolButton {
                            icon.name: "go-up"
                            QQC2.ToolTip.text: i18n("Increase priority")
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            enabled: delegate.model.sourcesBackend.firstDisambiguatedSourceId !== delegate.model.disambiguatedSourceId
                            visible: delegate.model.sourcesBackend.canMoveSources
                            onClicked: {
                                const ret = delegate.model.sourcesBackend.moveSource(delegate.model.disambiguatedSourceId, -1)
                                if (!ret) {
                                    window.showPassiveNotification(i18n("Failed to increase “%1” preference", delegate.model.display))
                                }
                            }
                        }

                        QQC2.ToolButton {
                            icon.name: "go-down"
                            QQC2.ToolTip.text: i18n("Decrease priority")
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            enabled: delegate.model.sourcesBackend.lastDisambiguatedSourceId !== delegate.model.disambiguatedSourceId
                            visible: delegate.model.sourcesBackend.canMoveSources
                            onClicked: {
                                const ret = delegate.model.sourcesBackend.moveSource(delegate.model.disambiguatedSourceId, +1)
                                if (!ret) {
                                    window.showPassiveNotification(i18n("Failed to decrease “%1” preference", delegate.model.display))
                                }
                            }
                        }

                        QQC2.ToolButton {
                            icon.name: "edit-delete"
                            QQC2.ToolTip.text: i18n("Remove repository")
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            visible: delegate.model.sourcesBackend.supportsAdding
                            onClicked: {
                                const backend = delegate.model.sourcesBackend
                                if (!backend.removeSource(delegate.model.disambiguatedSourceId)) {
                                    console.warn("Failed to remove the source", delegate.model.display)
                                }
                            }
                        }

                        QQC2.ToolButton {
                            icon.name: page.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
                            QQC2.ToolTip.text: i18n("Show contents")
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                            visible: delegate.model.sourcesBackend.canFilterSources
                            onClicked: {
                                Navigation.openApplicationListSource(delegate.model.disambiguatedSourceId, delegate.model.display)
                            }
                        }
                    }
                }
            }
        }

        // Footer: Missing Backends (Infraestruturas Faltantes)
        footer: Item {
            width: sourcesView.width
            implicitHeight: footerInner.implicitHeight + Kirigami.Units.gridUnit * 3

            ColumnLayout {
                id: footerInner
                width: Math.min(parent.width - Kirigami.Units.largeSpacing * 2, 1024)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    visible: back.count > 0
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    text: i18n("Missing Backends")
                    level: 4
                    font.weight: Font.Bold
                    font.capitalization: Font.AllUppercase
                    color: Kirigami.Theme.disabledTextColor
                }

                Repeater {
                    id: back
                    model: Discover.ResourcesProxyModel {
                        extending: "org.kde.discover.desktop"
                        filterMinimumState: false
                        stateFilter: Discover.AbstractResource.None
                    }
                    delegate: Rectangle {
                        id: missingDelegate

                        required property int index
                        required property var model
                        required property string name

                        Layout.fillWidth: true
                        implicitHeight: missingContent.implicitHeight + Kirigami.Units.largeSpacing * 2
                        radius: 16
                        color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.06)
                        border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.22)
                        border.width: 1

                        RowLayout {
                            id: missingContent
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.largeSpacing
                            spacing: Kirigami.Units.largeSpacing

                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: 12
                                color: Kirigami.Theme.backgroundColor
                                border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
                                border.width: 1

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: missingDelegate.model.icon || "package-x-generic"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                QQC2.Label {
                                    text: missingDelegate.name
                                    font.weight: Font.Bold
                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                    color: Kirigami.Theme.textColor
                                    Layout.fillWidth: true
                                }

                                QQC2.Label {
                                    text: missingDelegate.model.comment
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    color: Kirigami.Theme.disabledTextColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            InstallApplicationButton {
                                application: missingDelegate.model.application
                            }
                        }
                    }
                }
            }
        }
    }
}
