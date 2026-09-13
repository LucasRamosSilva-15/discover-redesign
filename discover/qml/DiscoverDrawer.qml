/*
 *   SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.discover as Discover
import org.kde.kirigami as Kirigami

Kirigami.GlobalDrawer {
    id: drawer

    property bool wideScreen: false
    property string currentSearchText

    function suggestSearchText(text) {
        if (searchField.visible) {
            searchField.text = text
            forceSearchFieldFocus()
        }
    }

    function forceSearchFieldFocus() {
        if (searchField.visible && wideScreen) {
            searchField.forceActiveFocus();
        }
    }

    function createCategoryActions(categories /*list<Discover.Category>*/) /*list<Kirigami.Action>*/ {
        const ret = []
        for (const c of categories) {
            const category = Discover.CategoryModel.get(c)
            const categoryAction = categoryActionComponent.createObject(drawer, { category: category, categoryPtr: c })
            categoryAction.children = createCategoryActions(category.subcategories)
            ret.push(categoryAction)
        }
        return ret;
    }
    actions: createCategoryActions(Discover.CategoryModel.rootCategories)

    interactiveResizeEnabled: true
    Component.onCompleted: {
        if (app.sidebarWidth > 0) {
            preferredSize = app.sidebarWidth
        } else {
            preferredSize =  Kirigami.Units.gridUnit * 14
        }
    }

    onPreferredSizeChanged: app.sidebarWidth = preferredSize

    padding: 0
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined
    verticalPadding: undefined
    horizontalPadding: undefined

    resetMenuOnTriggered: false
    modal: !drawer.wideScreen

    onCurrentSubMenuChanged: {
        if (currentSubMenu) {
            currentSubMenu.trigger()
        } else if (currentSearchText.length > 0) {
            window.leftPage.category = null
        }
    }

    topContent: [
        Kirigami.ListSectionHeader {
            text: i18nc("@title:group", "NAVEGAÇÃO")
            Layout.fillWidth: true
        },
        ActionListItem {
            id: featuredActionListItem
            action: featuredAction
            visible: enabled && drawer.wideScreen
        },
        ActionListItem {
            action: installedAction
            visible: enabled && drawer.wideScreen
        },
        ActionListItem {
            objectName: "updateButton"
            action: updateAction
            visible: enabled && drawer.wideScreen

            stateObject: Discover.ResourcesModel.fetchingUpdatesProgress < 100 ? updatesIcon : updatesCountLabel

            Component {
                id: updatesIcon

                Kirigami.Icon {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    source: "view-refresh"
                    implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
                    implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
                }
            }

            Component {
                id: updatesCountLabel

                Kirigami.Badge {
                    visible: Discover.ResourcesModel.updatesCount > 0

                    type: Discover.ResourcesModel.hasSecurityUpdates
                        ? Kirigami.Badge.Type.Warning
                        : Kirigami.Badge.Type.Information

                    text: Discover.ResourcesModel.updatesCount

                    QQC2.ToolTip.text: Discover.ResourcesModel.hasSecurityUpdates
                        ? i18n("Security updates available")
                        : i18n("Updates available")
                    QQC2.ToolTip.visible: activeFocus || hovered
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

                }
            }
        },
        ActionListItem {
            action: sourcesAction
        },
        ActionListItem {
            action: aboutAction
        },
        Kirigami.ListSectionHeader {
            text: i18nc("@title:group", "CATEGORIAS")
            Layout.fillWidth: true
        }
    ]

    footer: QQC2.Control {
        visible: true // Always visible to show the application version
        padding: 0

        contentItem: ColumnLayout {
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.topMargin: -10 // Subir um pouquinho para encostar na barra de rolagem
                height: 1

                Rectangle {
                    width: drawer.width
                    height: 1
                    color: Kirigami.Theme.textColor
                    opacity: 0.15
                    anchors.centerIn: parent
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.largeSpacing

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18nc("@info", "KDE Plasma 6")
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                }

                Rectangle {
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                    radius: Kirigami.Units.smallSpacing
                    implicitWidth: versionLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
                    implicitHeight: versionLabel.implicitHeight + Kirigami.Units.smallSpacing

                    QQC2.Label {
                        id: versionLabel
                        anchors.centerIn: parent
                        text: "v" + Qt.application.version
                        font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize * 0.9)
                        font.family: "monospace"
                        color: Kirigami.Theme.disabledTextColor
                    }
                }
            }
        }

        states: [
            State {
                name: "full"
                when: drawer.wideScreen
                PropertyChanges { drawer.drawerOpen: true }
            },
            State {
                name: "compact"
                when: !drawer.wideScreen
                PropertyChanges { drawer.drawerOpen: false }
            }
        ]
    }

    Component {
        id: categoryActionComponent
        Kirigami.Action {
            required property Discover.Category category
            required property var categoryPtr
            readonly property var windowCategory: window?.leftPage?.category
            readonly property bool itsMe: (windowCategory && category) ? category.contains(windowCategory) : false

            text: category?.name ?? ""
            icon.name: category?.icon + "-symbolic" ?? ""
            checked: itsMe
            enabled: (currentSearchText.length === 0
                      || (category?.contains(window?.leftPage?.model?.subcategories ?? []) ?? false))

            visible: category?.visible
            onTriggered: {
                if (!window.leftPage.canNavigate) {
                    Navigation.openCategory(categoryPtr, currentSearchText)
                } else {
                    if (pageStack.depth > 1) {
                        pageStack.pop()
                    }
                    pageStack.currentIndex = 0
                    window.leftPage.category = categoryPtr
                }

                if (!drawer.wideScreen && category.subcategories.length === 0) {
                    drawer.close();
                }
            }
        }
    }
}
