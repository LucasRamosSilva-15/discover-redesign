/*
 *   SPDX-FileCopyrightText: 2012 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *   SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.discover as Discover
import org.kde.discover.app as DiscoverApp
import org.kde.kirigami as Kirigami
import org.kde.purpose as Purpose

DiscoverPage {
    id: appInfo

    title: "" // It would duplicate the text in the header right below it
    clip: true

    required property Discover.AbstractResource application

    readonly property int visibleReviews: 3
    readonly property int internalSpacings: padding * 2
    readonly property bool availableFromOnlySingleSource: !originsMenuAction.visible

    // Usually this page is not the top level page, but when we are, isHome being
    // true will ensure that the search field suggests we are searching in the list
    // of available apps, not inside the app page itself. This will happen when
    // Discover is launched e.g. from krunner or otherwise requested to show a
    // specific application on launch.
    readonly property bool isHome: true

    readonly property bool isOfflineUpgrade: application.packageName === "discover-offline-upgrade"

    readonly property bool isTechnicalPackage: application.type == Discover.AbstractResource.ApplicationSupport
                                            || application.type == Discover.AbstractResource.System

    function colorForLicenseType(licenseType: string): string {
        switch(licenseType) {
            case "free":
                return Kirigami.Theme.positiveTextColor;
            case "non-free":
                return Kirigami.Theme.neutralTextColor;
            case "proprietary":
                return Kirigami.Theme.negativeTextColor
            case "unknown":
            default:
                return Kirigami.Theme.neutralTextColor;
        }
    }

    function explanationForLicenseType(licenseType: string): string {
        let freeSoftwareUrl = "https://www.gnu.org/philosophy/free-sw.html"
        let fsfUrl = "https://www.fsf.org/"
        let osiUrl = "https://opensource.org/"
        let proprietarySoftwareUrl = "https://www.gnu.org/proprietary"
        let hasHomepageUrl = application.homepage.toString().length > 0

        switch(licenseType) {
            case "proprietary":
                if (hasHomepageUrl) {
                    return xi18nc("@info", "Only install %1 if you fully trust its authors because it is <emphasis strong='true'>proprietary</emphasis>: Your freedom to use, modify, and redistribute this application is restricted, and its source code is partially or entirely closed to public inspection and improvement. This means third parties and users like you cannot verify its operation, security, and trustworthiness.<nl/><nl/>The application may be perfectly safe to use, or it may be acting against you in various ways — such as harvesting your personal information, tracking your location, or transmitting the contents of your data to someone else. Only use it if you fully trust its authors. More information may be available on <link url='%2'>the application’s website</link>.<nl/><nl/>Learn more at <link url='%3'>%3</link>.",
                                appInfo.application.name,
                                appInfo.application.homepage.toString(),
                                proprietarySoftwareUrl)
                } else {
                    return xi18nc("@info", "Only install %1 if you fully trust its authors because it is <emphasis strong='true'>proprietary</emphasis>: Your freedom to use, modify, and redistribute this application is restricted, and its source code is partially or entirely closed to public inspection and improvement. This means third parties and users like you cannot verify its operation, security, and trustworthiness.<nl/><nl/>The application may be perfectly safe to use, or it may be acting against you in various ways — such as harvesting your personal information, tracking your location, or transmitting the contents of your data to someone else. Only use it if you fully trust its authors. Learn more at <link url='%2'>%2</link>.",
                                  appInfo.application.name,
                                  proprietarySoftwareUrl)
                }

            case "non-free":
                if (hasHomepageUrl) {
                    return xi18nc("@info", "%1 uses one or more licenses not certified as “Free Software” by either the <link url='%2'>Free Software Foundation</link> or the <link url='%3'>Open Source Initiative</link>. This means your freedom to use, study, modify, and share it may be restricted in some ways.<nl/><nl/>Make sure to read the license text and understand any restrictions before using the software.<nl/><nl/>If the license does not even grant access to read the source code, make sure you fully trust the authors, as no one else can verify the trustworthiness and security of its code to ensure that it is not acting against you in hidden ways. More information may be available on <link url='%4'>the application’s website</link>.<nl/><nl/>Learn more at <link url='%5'>%5</link>.",
                                appInfo.application.name,
                                fsfUrl,
                                osiUrl,
                                appInfo.application.homepage.toString(),
                                freeSoftwareUrl);
                } else {
                    return xi18nc("@info", "%1 uses one or more licenses not certified as “Free Software” by either the <link url='%2'>Free Software Foundation</link> or the <link url='%3'>Open Source Initiative</link>. This means your freedom to use, study, modify, and share it may be restricted in some ways.<nl/><nl/>Make sure to read the license text and understand any restrictions before using the software.<nl/><nl/>If the license does not even grant access to read the source code, make sure you fully trust the authors, as no one else can verify the trustworthiness and security of its code to ensure that it is not acting against you in hidden ways.<nl/><nl/>Learn more at <link url='%4'>%4</link>.",
                                  appInfo.application.name,
                                  fsfUrl,
                                  osiUrl,
                                  freeSoftwareUrl);
                }

            case "unknown":
                if (hasHomepageUrl) {
                    return xi18nc("@info", "%1 does not indicate under which license it is distributed. You may be able to determine this on <link url='%2'>the application’s website</link>. Find it there or contact the author if you want to use this application for anything other than private personal use.",
                                 appInfo.application.name,
                                 appInfo.application.homepage.toString());
                } else {
                    return i18nc("@info", "%1 does not indicate under which license it is distributed. Contact the application’s author if you want to use it for anything other than private personal use.",
                                 appInfo.application.name);
                }

            case "free":
            default:
                return "";
        }
    }

    Discover.TransactionListener {
        id: transactionListener
        resource: appInfo.application
    }

    ReviewsPage {
        id: reviewsSheet
        parent: appInfo.QQC2.Overlay.overlay
        model: Discover.ReviewsModel {
            id: reviewsModel
            resource: appInfo.application
            preferredSortRole: reviewsSheet.sortRole
        }
        Component.onCompleted: reviewsSheet.sortRole = reviewsModel.preferredSortRole
    }

    actions: [
        addonsAction,
        shareAction,
        originsMenuAction
    ]

    QQC2.ActionGroup {
        id: sourcesGroup
        exclusive: true
    }

    Kirigami.Action {
        id: shareAction
        text: i18nc("@action:button share a link to this app", "Share")
        icon.name: "document-share"
        visible: application.url.toString().length > 0 && !appInfo.isTechnicalPackage
        onTriggered: shareSheet.open()
    }

    Kirigami.Action {
        id: addonsAction
        text: i18nc("@action:button", "Add-ons")
        icon.name: "extension-symbolic"
        visible: addonsView.containsAddons
        onTriggered: {
            if (addonsView.addonsCount === 0) {
                Navigation.openExtends(application.appstreamId, appInfo.application.name)
            } else {
                addonsView.visible = true
            }
        }
    }

    // Multi-source origin display and switcher
    Kirigami.Action {
        id: originsMenuAction

        text: i18nc("@item:inlistbox %1 is the name of an app source e.g. \"Flathub\" or \"Ubuntu\"", "From %1", appInfo.application.displayOrigin)

        property int maxChildren: 0
        onChildrenChanged: {
            if (children.length > maxChildren) {
                maxChildren = children.length;
            }
        }
        visible: {
            /* HACK: When we change source, ResourcesProxyModel acts in such a
             * way that the number of children decreases to 0 and then increases
             * back up (e.g. 2 -> 1 -> 0 -> 1 -> 2).
             *
             * This results in the action toggling visiblity, and for the
             * dependant install button to think there's only a single source
             * and change button text, for several frames.
             *
             * We paper over this here by remembering the max child count and
             * keeping the existing visible value if we drop below it.
             *
             * I don't believe that the number of sources can actually change
             * whilst the page is open, but if it does, this is surely rarer
             * than the UI upset caused by changing source.
             */
            if (children.length < originsMenuAction.maxChildren) {
                // Keep previous
                return originsMenuAction.visible;
            }

            return children.length > 1;
        }

        children: sourcesGroup.actions
    }

    Instantiator {
        // alternativeResourcesModel
        model: Discover.ResourcesProxyModel {
            allBackends: true
            resourcesUrl: appInfo.application.url
        }
        delegate: QQC2.Action {
            required property var model

            QQC2.ActionGroup.group: sourcesGroup
            text: model.availableVersion
                ? i18n("%1 - %2", model.displayOrigin, model.availableVersion)
                : model.displayOrigin
            icon.name: model.sourceIcon
            checkable: true
            checked: appInfo.application === model.application
            onTriggered: {
                appInfo.application = model.application
            }
        }
    }

    Kirigami.ImageColors {
        id: appImageColorExtractor
        source: appInfo.application.icon
    }

    Kirigami.PromptDialog {
        id: shareSheet
        parent: applicationWindow().overlay
        implicitWidth: Kirigami.Units.gridUnit * 20
        title: i18nc("@title:window", "Share Link to Application")
        standardButtons: QQC2.Dialog.NoButton

        Purpose.AlternativesView {
            id: alts
            Layout.fillWidth: true
            pluginType: "ShareUrl"
            inputData: {
                "urls": [ application.url.toString() ],
                "title": i18nc("The subject line for an email. %1 is the name of an application", "Check out the %1 app!", application.name)
            }
            onFinished: {
                shareSheet.close()
                if (error !== 0) {
                    console.error("job finished with error", error, message)
                }
                alts.reset()
            }
        }
    }

    // Scrollable page content
    ColumnLayout {
        id: pageLayout

        anchors {
            top: parent.top
            topMargin: Kirigami.Units.largeSpacing
            horizontalCenter: parent.horizontalCenter
        }
        width: Math.min(parent.width - Kirigami.Units.largeSpacing * 4, 1024)
        spacing: Kirigami.Units.largeSpacing * 1.5

        ApplicationPageFullComponent {
            Layout.fillWidth: true
            application: appInfo.application
            availableFromOnlySingleSource: appInfo.availableFromOnlySingleSource
            isOfflineUpgrade: appInfo.isOfflineUpgrade
            isTechnicalPackage: appInfo.isTechnicalPackage
            colorForLicenseType: (licenseType) => appInfo.colorForLicenseType(licenseType)

            onOpenContentRatingDialog: contentRatingDialog.open()
            onOpenLicenseDetailsDialog: (licenseType) => licenseDetailsDialog.openWithLicenseType(licenseType)
            onOpenAllLicensesSheet: allLicensesSheet.open()
        }

        // Screenshots Showcase
        Rectangle {
            id: showcaseCard
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(width * 9 / 21 + 50, 440)
            Layout.minimumHeight: 240
            radius: 16
            color: "#0f172a"
            clip: true
            visible: carouselModel.count > 0 && !carousel.hasFailed && !appInfo.isTechnicalPackage

            Discover.ScreenshotsModel {
                id: carouselModel
                application: appInfo.application
            }

            CarouselInlineView {
                id: carousel
                anchors.fill: parent
                carouselModel: carouselModel
            }
        }

        Kirigami.PlaceholderMessage {
            Layout.fillWidth: true
            visible: carousel.hasFailed
            icon.name: "image-missing"
            text: i18nc("@info placeholder message", "Screenshots not available for %1", appInfo.application.name)
        }

        ColumnLayout {
            id: topObjectsLayout

            // InlineMessage components are supposed to manage their spacing
            // internally. However, at least for now they require some
            // assistance from outside to stack them one after another.
            spacing: 0

            Layout.fillWidth: true

            // Cancel out parent layout's spacing, making this component effectively zero-sized when empty.
            // When non-empty, the very first top margin is provided by this layout, but bottom margins
            // are implemented by Loaders that have visible loaded items.
            Layout.topMargin: hasActiveObjects ? 0 : -pageLayout.spacing
            Layout.bottomMargin: -pageLayout.spacing

            property bool hasActiveObjects: false
            visible: hasActiveObjects

            function bindVisibility() {
                hasActiveObjects = Qt.binding(() => {
                    for (let i = 0; i < topObjectsRepeater.count; i++) {
                        const loader = topObjectsRepeater.itemAt(i);
                        const item = loader.item;
                        if (item?.Discover.Activatable.active) {
                            return true;
                        }
                    }
                    return false;
                });
            }

            Timer {
                id: bindActiveTimer

                running: false
                repeat: false
                interval: 0

                onTriggered: topObjectsLayout.bindVisibility()
            }

            Repeater {
                id: topObjectsRepeater

                model: appInfo.application.topObjects

                delegate: Loader {
                    id: topObject
                    required property string modelData

                    Layout.fillWidth: item?.Layout.fillWidth ?? false
                    Layout.topMargin: 0
                    Layout.bottomMargin: item?.Discover.Activatable.active ? appInfo.padding : 0
                    Layout.preferredHeight: item?.Discover.Activatable.active ? item.implicitHeight : 0

                    onModelDataChanged: {
                        setSource(modelData, { resource: Qt.binding(() => appInfo.application) });
                    }
                    Connections {
                        target: topObject.item?.Discover.Activatable
                        function onActiveChanged() {
                            bindActiveTimer.start();
                        }
                    }
                }
                onItemAdded: (index, item) => {
                    bindActiveTimer.start();
                }
                onItemRemoved: (index, item) => {
                    bindActiveTimer.start();
                }
            }
        }

        // App Short & Long Description
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                Layout.fillWidth: true
                        visible: !appInfo.isOfflineUpgrade && appInfo.application.comment.length > 0
                        text: appInfo.application.comment
                        level: 2
                        font.weight: Font.Bold
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.textColor
                    }

                    Kirigami.SelectableLabel {
                        objectName: "applicationDescription"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: appInfo.application.longDescription
                        textFormat: TextEdit.RichText
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.15)
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }

                // Changelog section
                ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing
                    visible: changelogLabel.visible

                    Kirigami.Heading {
                        text: i18n("What’s New")
                        level: 2
                        type: Kirigami.Heading.Type.Primary
                        wrapMode: Text.Wrap
                    }

                    QQC2.Label {
                        id: changelogLabel
                        Layout.fillWidth: true
                        visible: text !== "" && text !== "<br />"
                        wrapMode: Text.WordWrap
                        Component.onCompleted: appInfo.application.fetchChangelog()
                        Connections {
                            target: appInfo.application
                            function onChangelogFetched(changelog) {
                                changelogLabel.text = changelog
                            }
                        }
                    }
                }

                // Reviews Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    visible: !appInfo.isTechnicalPackage

                    Kirigami.Heading {
                        Layout.fillWidth: true
                        text: i18n("Reviews")
                        level: 2
                        type: Kirigami.Heading.Type.Primary
                        wrapMode: Text.Wrap
                        visible: !reviewsStats.visible && (reviewsLoadingPlaceholder.visible || reviewsError.visible)
                    }

                    Kirigami.LoadingPlaceholder {
                        id: reviewsLoadingPlaceholder
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                        visible: reviewsModel.fetching
                        text: i18n("Loading reviews for %1", appInfo.application.name)
                    }

                    Kirigami.PlaceholderMessage {
                        id: reviewsError
                        Layout.fillWidth: true
                        readonly property bool hasError: reviewsModel.backend && reviewsModel.backend.errorMessage.length > 0 && text.length > 0 && reviewsModel.count === 0 && !reviewsLoadingPlaceholder.visible
                        visible: hasError
                        icon.name: "text-unflow"
                        text: i18nc("@info placeholder message", "Reviews for %1 are temporarily unavailable", appInfo.application.name)
                        explanation: reviewsModel.backend ? reviewsModel.backend.errorMessage : ""
                    }

                    Kirigami.PlaceholderMessage {
                        Layout.fillWidth: true
                        visible: !reviewsStats.visible && !reviewsLoadingPlaceholder.visible
                        text: i18nc("@Info placeholder message", "No reviews posted yet")
                        explanation: appInfo.application.isInstalled ? "" : i18nc("@info placeholder explanation", "Install to write a review")
                        helpfulAction: Kirigami.Action {
                            enabled: appInfo.application.isInstalled
                            text: appInfo.application.isInstalled ? i18n("Write a Review") : i18n("Install to Write a Review")
                            icon.name: "document-edit"
                            onTriggered: {
                                reviewsSheet.openReviewDialog()
                            }
                        }
                    }

                    ReviewsStats {
                        id: reviewsStats
                        visible: reviewsModel.count > 0
                        Layout.fillWidth: true
                        application: appInfo.application
                        reviewsModel: reviewsModel
                        model: reviewsSheet.model
                        visibleReviews: Math.min(reviewsModel.count, appInfo.visibleReviews)
                        compact: appInfo.compact
                        canShowAllReviews: reviewsModel.count > visibleReviews
                        canWriteReview: transactionListener.resource.state !== Discover.AbstractResource.Broken
                            && reviewsModel.backend
                            && !reviewsError.visible
                            && reviewsModel.backend.isResourceSupported(appInfo.application)
                        isInstalled: appInfo.application.isInstalled
                        onShowAllReviewsRequested: {
                            reviewsSheet.open()
                        }
                        onWriteReviewRequested: {
                            reviewsSheet.openReviewDialog()
                        }
                    }
                }

        // Links externos Card
        Rectangle {
                    id: externalLinksCard
                    readonly property int visibleButtons: (helpButton.visible ? 1 : 0)
                                                        + (homepageButton.visible ? 1: 0)
                                                        + (donateButton.visible ? 1 : 0)
                                                        + (bugButton.visible ? 1 : 0)
                                                        + (contributeButton.visible ? 1 : 0)
                                                        + (faqButton.visible ? 1 : 0)
                                                        + (translateButton.visible ? 1 : 0)
                                                        + (contactButton.visible ? 1 : 0)
                                                        + (vcsBrowserButton.visible ? 1 : 0)
                    visible: visibleButtons > 0 && !appInfo.isTechnicalPackage

                    Layout.fillWidth: true
                    radius: 16
                    color: Kirigami.Theme.backgroundColor
                    border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
                    border.width: 1

                    implicitHeight: linksCol.implicitHeight + Kirigami.Units.largeSpacing * 3

                    ColumnLayout {
                        id: linksCol
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing * 1.5
                        spacing: Kirigami.Units.largeSpacing

                        Kirigami.Heading {
                            text: i18nc("@title", "External Links")
                            level: 3
                            font.weight: Font.Bold
                            color: Kirigami.Theme.textColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            ApplicationResourceButton {
                                id: faqButton
                                visible: website.length > 0
                                icon: "question-symbolic"
                                website: appInfo.application.faqURL.toString()
                                linkText: i18nc("@info text of a web URL", "Read the FAQ")
                            }

                            ApplicationResourceButton {
                                id: helpButton
                                visible: website.length > 0
                                icon: "documentation-symbolic"
                                website: appInfo.application.helpURL.toString()
                                linkText: i18nc("@info text of a web URL", faqButton.visible
                                    ? "Read the full documentation"
                                    : "Read the documentation")
                            }

                            ApplicationResourceButton {
                                id: homepageButton
                                visible: website.length > 0
                                icon: "internet-services-symbolic"
                                website: appInfo.application.homepage.toString()
                                linkText: i18nc("@info text of a web URL", "Visit the project’s website")
                            }

                            ApplicationResourceButton {
                                id: donateButton
                                visible: website.length > 0
                                icon: "help-donate-symbolic"
                                website: appInfo.application.donationURL.toString()
                                linkText: i18nc("@info text of a web URL", "Donate to the project")
                            }

                            ApplicationResourceButton {
                                id: bugButton
                                visible: website.length > 0
                                icon: "tools-report-bug-symbolic"
                                website: appInfo.application.bugURL.toString()
                                linkText: i18nc("@info text of a web URL", "Report a bug")
                            }

                            ApplicationResourceButton {
                                id: contributeButton
                                visible: website.length > 0
                                icon: "applications-development-symbolic"
                                website: appInfo.application.contributeURL.toString()
                                linkText: i18nc("@info text of a web URL", "Start contributing")
                            }

                            ApplicationResourceButton {
                                id: translateButton
                                visible: website.length > 0
                                icon: "translate-symbolic"
                                website: appInfo.application.translateURL.toString()
                                linkText: i18nc("@info text of a web URL", "Help with translations")
                            }

                            ApplicationResourceButton {
                                id: contactButton
                                visible: website.length > 0
                                icon: "mail-message-new-symbolic"
                                website: appInfo.application.contactURL.toString()
                                linkText: i18nc("@info text of a web URL", "Contact the developers")
                            }

                            ApplicationResourceButton {
                                id: vcsBrowserButton
                                visible: website.length > 0
                                icon: "folder-git-symbolic"
                                website: appInfo.application.vcsBrowserURL.toString()
                                linkText: i18nc("@info text of a web URL", "Browse the source code")
                            }
                        }
                    }
                }

                // Permissões Card
                Rectangle {
                    id: permissionsCard
                    Layout.fillWidth: true
                    radius: 16
                    color: Kirigami.Theme.backgroundColor
                    border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
                    border.width: 1

                    implicitHeight: permCol.implicitHeight + Kirigami.Units.largeSpacing * 3

                    ColumnLayout {
                        id: permCol
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing * 1.5
                        spacing: Kirigami.Units.largeSpacing

                        Kirigami.Heading {
                            text: i18nc("@title", "Permissions")
                            level: 3
                            font.weight: Font.Bold
                            color: Kirigami.Theme.textColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: appInfo.application.bottomObjects

                                delegate: Loader {
                                    required property string modelData
                                    Layout.fillWidth: true
                                    onModelDataChanged: {
                                        setSource(modelData, { resource: Qt.binding(() => appInfo.application) });
                                    }
                                }
                            }

                            RowLayout {
                                visible: appInfo.application.bottomObjects.length === 0
                                spacing: Kirigami.Units.largeSpacing

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 8
                                    color: "#fef3c7"
                                    border.color: "#fde68a"
                                    border.width: 1

                                    Kirigami.Icon {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        source: "security-medium"
                                        color: "#d97706"
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true

                                    QQC2.Label {
                                        text: i18nd("libdiscover", "Full Access")
                                        font.weight: Font.DemiBold
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                        color: Kirigami.Theme.textColor
                                    }

                                    QQC2.Label {
                                        text: i18nd("libdiscover", "Can access everything on the system")
                                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                                        color: Kirigami.Theme.disabledTextColor
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
        }

    AddonsView {
        id: addonsView

        application: appInfo.application
        parent: appInfo.QQC2.Overlay.overlay
    }

    Kirigami.Dialog {
        id: allLicensesSheet
        title: i18n("All Licenses")
        standardButtons: Kirigami.Dialog.NoButton
        preferredWidth: Kirigami.Units.gridUnit * 16
        maximumHeight: Kirigami.Units.gridUnit * 20

        ColumnLayout {
            spacing: 0

            Repeater {
                model: appInfo.application.licenses

                delegate: QQC2.ItemDelegate {
                    background: null
                    id: delegate

                    required property var modelData

                    contentItem: Kirigami.UrlButton {
                        // Override some things to keep the right appearance for non-free licenses with no URL.
                        readonly property bool hasUrl: url !== ""
                        enabled: true
                        font.underline: hasUrl
                        acceptedButtons: hasUrl ? Qt.LeftButton : Qt.NoButton
                        mouseArea.cursorShape: hasUrl ? Qt.PointingHandCursor : undefined

                        text: delegate.modelData.name
                        url: delegate.modelData.url
                        horizontalAlignment: Text.AlignLeft
                        normalColor: appInfo.colorForLicenseType(delegate.modelData.licenseType)
                    }
                }
            }
        }
    }

    Kirigami.PromptDialog {
        id: contentRatingDialog
        parent: appInfo.QQC2.Overlay.overlay
        title: i18n("Content Rating")
        preferredWidth: Kirigami.Units.gridUnit * 25
        standardButtons: Kirigami.Dialog.NoButton

        QQC2.Label {
            text: appInfo.application.contentRatingDescription
            textFormat: Text.MarkdownText
            wrapMode: Text.Wrap
        }
    }

    Kirigami.Dialog {
        id: licenseDetailsDialog

        function openWithLicenseType(licenseType: string): void {
            licenseExplanation.text = appInfo.explanationForLicenseType(licenseType);
            open();
        }

        parent: appInfo.QQC2.Overlay.overlay
        width: Kirigami.Units.gridUnit * 25
        standardButtons: Kirigami.Dialog.NoButton

        title: i18nc("@title:window", "License Information")

        TextEdit {
            id: licenseExplanation

            leftPadding: Kirigami.Units.largeSpacing
            rightPadding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing

            wrapMode: Text.Wrap
            textFormat: TextEdit.RichText
            readOnly: true

            color: Kirigami.Theme.textColor
            selectedTextColor: Kirigami.Theme.highlightedTextColor
            selectionColor: Kirigami.Theme.highlightColor

            onLinkActivated: url => Qt.openUrlExternally(url)

            HoverHandler {
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }
}
