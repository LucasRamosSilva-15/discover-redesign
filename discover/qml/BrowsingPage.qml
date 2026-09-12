/*
 *   SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.discover as Discover
import org.kde.discover.app as DiscoverApp

DiscoverPage {
    id: page

    title: i18nc("@title:window the name of a top-level 'home' page", "Home")
    objectName: "featured"

    actions: window.wideScreen ? [ searchAction ] : []

    header: DiscoverInlineMessage {
        id: message

        inlineMessage: Discover.ResourcesModel.inlineMessage ? Discover.ResourcesModel.inlineMessage : app.homePageMessage
    }

    readonly property bool isHome: true

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    DiscoverApp.FeaturedModel {
        id: featuredModel
    }

    Kirigami.LoadingPlaceholder {
        visible: featuredModel.isFetching
        anchors.centerIn: parent
    }

    Loader {
        active: !featuredModel.isFetching && [featuredModel, popRep, recentlyUpdatedRepeater, gamesRep, devRep].every((model) => model.count === 0)

        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        sourceComponent: Kirigami.PlaceholderMessage {
            readonly property Discover.InlineMessage helpfulError: featuredModel.currentApplicationBackend?.explainDysfunction() ?? null

            icon.name: helpfulError?.iconName ?? ""
            text: i18n("Unable to load applications")
            explanation: helpfulError?.message ?? ""

            Repeater {
                model: helpfulError?.actions ?? null
                delegate: QQC2.Button {
                    id: delegate

                    required property Discover.DiscoverAction modelData

                    Layout.alignment: Qt.AlignHCenter

                    action: ConvertDiscoverAction {
                        action: delegate.modelData
                    }
                }
            }
        }
    }

    signal clearSearch()

    Kirigami.CardsLayout {
        id: apps

        maximumColumns: 2
        rowSpacing: Kirigami.Units.largeSpacing
        columnSpacing: Kirigami.Units.largeSpacing
        maximumColumnWidth: Kirigami.Units.gridUnit * 22

        Rectangle {
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            implicitHeight: bannerCol.implicitHeight + Kirigami.Units.largeSpacing * 4
            radius: 12 // Tailwind rounded-2xl
            visible: !featuredModel.isFetching
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Kirigami.Theme.highlightColor }
                GradientStop { position: 1.0; color: Qt.darker(Kirigami.Theme.highlightColor, 1.5) }
            }
            
            Kirigami.Icon {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: Kirigami.Units.largeSpacing * 4
                implicitWidth: parent.height * 0.8
                implicitHeight: parent.height * 0.8
                source: "media-playback-start"
                color: "white"
                opacity: 0.15
            }

            ColumnLayout {
                id: bannerCol
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Kirigami.Units.largeSpacing * 3
                }
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18nc("@info", "★ DESTAQUE DA SEMANA")
                    font.weight: Font.Bold
                    font.pixelSize: Math.round(Kirigami.Theme.defaultFont.pixelSize * 0.8)
                    color: "white"
                    opacity: 0.9
                }

                Kirigami.Heading {
                    Layout.fillWidth: true
                    text: i18nc("@title", "Descubra Aplicativos Livres")
                    level: 1
                    color: "white"
                    wrapMode: Text.WordWrap
                    font.weight: Font.Bold
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18nc("@info", "Explore milhares de ferramentas confiáveis, empacotadas nativamente ou via Flatpak & Snap para o seu desktop Linux.")
                    wrapMode: Text.WordWrap
                    color: "#e0f2fe" // blue-100
                    font.pixelSize: Math.round(Kirigami.Theme.defaultFont.pixelSize * 0.9)
                }
            }
        }

        Kirigami.Heading {
            id: popHeading
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Most Popular")
            wrapMode: Text.Wrap
            level: 2
            font.weight: Font.Bold
            visible: popRep.count > 0 && !featuredModel.isFetching
        }

        Repeater {
            id: popRep
            model: DiscoverApp.LimitedRowCountProxyModel {
                pageSize: apps.maximumColumns * 2
                sourceModel: DiscoverApp.OdrsAppsModel {
                    // filter: FOSS
                }
            }
            delegate: GridApplicationDelegate {
                visible: !featuredModel.isFetching
                count: popRep.count
                columns: apps.columns
                maxUp: 0
            }
            property int numberItemsOnLastRow: (count % apps.columns) || apps.columns
        }

        QQC2.Button {
            text: i18nc("@action:button", "See More")
            icon.name: Qt.application.layoutDirection === Qt.LeftToRight ? "go-next-symbolic" : "go-next-rtl-symbolic"
            Layout.columnSpan: apps.columns
            // Nicer to have the arrow on the side it's pointing to
            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.LeftToRight
            onClicked: Navigation.openCategory(Discover.CategoryModel.findCategoryByName("All Applications"))
            visible: popRep.count > 0 && !featuredModel.isFetching
            Keys.onUpPressed: {
                var target = this
                for (var i = 0; i<popRep.numberItemsOnLastRow; i++) {
                    target = target.nextItemInFocusChain(false)
                }
                target.forceActiveFocus(Qt.TabFocusReason)
            }
            onFocusChanged: {
                if (focus) {
                    page.ensureVisible(this)
                }
            }
        }

        Kirigami.Heading {
            id: featuredHeading
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Editor’s Choice")
            wrapMode: Text.Wrap
            level: 2
            font.weight: Font.Bold
            visible: featuredRep.count > 0 && !featuredModel.isFetching
        }

        Repeater {
            id: featuredRep
            model: featuredModel
            delegate: GridApplicationDelegate {
                numberItemsOnPreviousLastRow: ((popHeading.visible && popRep.numberItemsOnLastRow) || 0)
                count: featuredRep.count
                columns: apps.columns
                visible: !featuredModel.isFetching
            }
            property int numberItemsOnLastRow: (count % apps.columns) || apps.columns
        }

        Kirigami.Heading {
            id: recentlyUpdatedHeading
            Layout.topMargin: page.padding
            // Need to undo some the row spacing of the parent layout which looks bad here
            Layout.bottomMargin: -(apps.rowSpacing / 2)
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Newly Published & Recently Updated")
            wrapMode: Text.Wrap
            visible: recentlyUpdatedRepeater.count > 0 && !featuredModel.isFetching
        }

        Repeater {
            id: recentlyUpdatedRepeater
            model: recentlyUpdatedModelInstantiator.object
            delegate: GridApplicationDelegate {
                numberItemsOnPreviousLastRow: ((featuredHeading.visible && featuredRep.numberItemsOnLastRow) ||
                                              (popHeading.visible && popRep.numberItemsOnLastRow) || 0)
                visible: !featuredModel.isFetching
                count: recentlyUpdatedRepeater.count
                columns: apps.columns
            }
            property int numberItemsOnLastRow: (count % apps.columns) || apps.columns
        }

        Instantiator {
            id: recentlyUpdatedModelInstantiator

            active: {
                const backend = Discover.ResourcesModel.currentApplicationBackend;
                if (!backend) {
                    return [];
                }
                // TODO: Add packagekit-backend of rolling distros
                return [
                    "flatpak-backend",
                    "snap-backend",
                ].includes(backend.name);
            }

            DiscoverApp.LimitedRowCountProxyModel {
                pageSize: apps.maximumColumns * 2
                sourceModel: Discover.ResourcesProxyModel {
                    filteredCategoryName: "All Applications"
                    backendFilter: Discover.ResourcesModel.currentApplicationBackend
                    sortRole: Discover.ResourcesProxyModel.ReleaseDateRole
                    sortOrder: Qt.DescendingOrder
                }
            }
        }

        Kirigami.Heading {
            id: gamesHeading
            Layout.topMargin: page.padding
            // Need to undo some the row spacing of the parent layout which looks bad here
            Layout.bottomMargin: -(apps.rowSpacing / 2)
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Highest-Rated Games")
            wrapMode: Text.Wrap
            visible: gamesRep.count > 0 && !featuredModel.isFetching
        }

        Repeater {
            id: gamesRep
            model: DiscoverApp.LimitedRowCountProxyModel {
                pageSize: apps.maximumColumns
                sourceModel: Discover.ResourcesProxyModel {
                    filteredCategoryName: "Games"
                    backendFilter: Discover.ResourcesModel.currentApplicationBackend
                    sortRole: Discover.ResourcesProxyModel.SortableRatingRole
                    sortOrder: Qt.DescendingOrder
                }
            }
            delegate: GridApplicationDelegate {
                visible: !featuredModel.isFetching
                numberItemsOnPreviousLastRow: ((recentlyUpdatedHeading.visible && recentlyUpdatedRepeater.numberItemsOnLastRow ) ||
                                              (featuredHeading.visible && featuredRep.numberItemsOnLastRow) ||
                                              (popHeading.visible && popRep.numberItemsOnLastRow) || 0)
                count: gamesRep.count
                columns: apps.columns
                maxDown: 1
            }
            property int numberItemsOnLastRow: (count % apps.columns) || apps.columns
        }

        QQC2.Button {
            text: i18nc("@action:button", "See More")
            icon.name: Qt.application.layoutDirection === Qt.LeftToRight ? "go-next-symbolic" : "go-next-rtl-symbolic"
            Layout.columnSpan: apps.columns
            // Nicer to have the arrow on the side it's pointing to
            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.LeftToRight
            onClicked: Navigation.openCategory(Discover.CategoryModel.findCategoryByName("Games"))
            visible: gamesRep.count > 0 && !featuredModel.isFetching
            Keys.onUpPressed: {
                var target = this
                for (var i = 0; i<gamesRep.numberItemsOnLastRow; i++) {
                    target = target.nextItemInFocusChain(false)
                }
                target.forceActiveFocus(Qt.TabFocusReason)
            }
            Keys.onDownPressed: nextItemInFocusChain(true).forceActiveFocus(Qt.TabFocusReason)
            onFocusChanged: {
                if (focus) {
                    page.ensureVisible(this)
                }
            }
        }

        Kirigami.Heading {
            Layout.topMargin: page.padding
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Highest-Rated Developer Tools")
            wrapMode: Text.Wrap
            visible: devRep.count > 0 && !featuredModel.isFetching
        }

        Repeater {
            id: devRep
            model: DiscoverApp.LimitedRowCountProxyModel {
                pageSize: apps.maximumColumns
                sourceModel: Discover.ResourcesProxyModel {
                    filteredCategoryName: "Development"
                    backendFilter: Discover.ResourcesModel.currentApplicationBackend
                    sortRole: Discover.ResourcesProxyModel.SortableRatingRole
                    sortOrder: Qt.DescendingOrder
                }
            }
            delegate: GridApplicationDelegate {
                visible: !featuredModel.isFetching
                numberItemsOnPreviousLastRow: ((gamesHeading.visible && gamesRep.numberItemsOnLastRow) ||
                                              (recentlyUpdatedHeading.visible && recentlyUpdatedRepeater.numberItemsOnLastRow) ||
                                              (featuredHeading.visible && featuredRep.numberItemsOnLastRow) ||
                                              (popHeading.visible && popRep.numberItemsOnLastRow) || 0)
                count: devRep.count
                columns: apps.columns
                maxUp: 1
                maxDown: 1
            }
            property int numberItemsOnLastRow: (count % apps.columns) || apps.columns
        }

        QQC2.Button {
            text: i18nc("@action:button", "See More")
            icon.name: Qt.application.layoutDirection === Qt.LeftToRight ? "go-next-symbolic" : "go-next-rtl-symbolic"
            Layout.columnSpan: apps.columns
            // Nicer to have the arrow on the side it's pointing to
            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.LeftToRight
            onClicked: Navigation.openCategory(Discover.CategoryModel.findCategoryByName("Development"))
            visible: devRep.count > 0 && !featuredModel.isFetching
            Keys.onUpPressed: {
                var target = this
                for (var i = 0; i<devRep.numberItemsOnLastRow; i++) {
                    target = target.nextItemInFocusChain(false)
                }
                target.forceActiveFocus(Qt.TabFocusReason)
            }
            onFocusChanged: {
                if (focus) {
                    page.ensureVisible(this)
                }
            }
        }
    }
}
