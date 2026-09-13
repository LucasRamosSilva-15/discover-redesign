/*
 *   SPDX-FileCopyrightText: 2012 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2018-2026 Nate Graham <nate@kde.org>
 *   SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
 *   SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.discover as Discover
import org.kde.kirigami as Kirigami

BasicAbstractCard {
    id: root

    required property int index
    required property Discover.AbstractResource application

    property bool showRating: true
    property bool showSize: false
    property bool showInstallButton: !compact

    // Remove the hard visual border (linhas visuais) and add a soft shadow like the prototype
    background: Kirigami.ShadowedRectangle {
        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.smallSpacing * 3
        shadow.size: 8
        shadow.color: Qt.rgba(0, 0, 0, 0.05)
        shadow.yOffset: 2
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
    }

    readonly property bool compact: !applicationWindow().wideScreen
    readonly property int appIconSize: Kirigami.Units.iconSizes.large
    readonly property bool appIsFromNonDefaultBackend: Discover.ResourcesModel.currentApplicationBackend !== application.backend && application.backend.hasApplications
    readonly property int nonDefaultBackendLogoSize: Kirigami.Units.iconSizes.smallMedium
    readonly property int maximumLineCount: compact ? 3 : 4

    showClickFeedback: true
    activeFocusOnTab: true
    highlighted: focus

    Accessible.name: application.name
    Accessible.role: Accessible.ListItem
    Accessible.onPressAction: trigger()
    onClicked: trigger()

    function trigger() {
        ListView.currentIndex = index
        Navigation.openApplication(application)
    }

    QQC2.ToolTip.text: "<b>" + appName.text + "</b><br/>" + appDescription.text
    QQC2.ToolTip.visible: (hovered || activeFocus) && (appName.truncated || appDescription.truncated)
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

    
    content: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        // 1. App Icon with Rounded Background
        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: root.appIconSize + Kirigami.Units.largeSpacing
            Layout.preferredHeight: root.appIconSize + Kirigami.Units.largeSpacing
            radius: 12
            color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.1)
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
            
            Kirigami.Icon {
                anchors.centerIn: parent
                implicitWidth: root.appIconSize
                implicitHeight: root.appIconSize
                source: root.application.icon
                animated: false
            }
            
            // Backend badge
            Loader {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -Kirigami.Units.smallSpacing
                anchors.bottomMargin: -Kirigami.Units.smallSpacing
                active: root.appIsFromNonDefaultBackend
                visible: active
                sourceComponent: Kirigami.Badge {
                    padding: 0
                    icon.width: root.nonDefaultBackendLogoSize
                    icon.height: root.nonDefaultBackendLogoSize
                    icon.source: root.application.sourceIcon
                    customColor: "white"
                    QQC2.ToolTip.text: root.application.backend.displayName
                    QQC2.ToolTip.visible: hovered || activeFocus
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                }
            }
        }
        
        // 2. Info Column (Name, Desc, Meta)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.smallSpacing
            
            RowLayout {
                Layout.fillWidth: true
                Kirigami.Heading {
                    id: appName
                    level: 3
                    type: Kirigami.Heading.Type.Primary
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    text: root.application.name
                }
                
                // Show size if requested
                Loader {
                    active: root.showSize
                    visible: active
                    sourceComponent: Rectangle {
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
                        radius: Kirigami.Units.smallSpacing
                        implicitHeight: sizeLbl.implicitHeight + Kirigami.Units.smallSpacing
                        implicitWidth: sizeLbl.implicitWidth + Kirigami.Units.largeSpacing
                        QQC2.Label {
                            id: sizeLbl
                            anchors.centerIn: parent
                            text: root.application.sizeDescription
                            font: Kirigami.Theme.smallFont
                            color: Kirigami.Theme.textColor
                            opacity: 0.7
                        }
                    }
                }
            }
            
            QQC2.Label {
                id: appDescription
                Layout.fillWidth: true
                maximumLineCount: 2
                visible: maximumLineCount > 0
                opacity: 0.75
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: root.application.comment
                Layout.alignment: Qt.AlignTop
            }
            
            // Spacer to push ratings to the bottom if needed
            Item { Layout.fillHeight: true }
            
            // Footer: Rating and Author/Backend
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                
                Loader {
                    id: ratingsLoader
                    readonly property bool ratingsSupported: root.application.backend.reviewsBackend?.isResourceSupported(root.application) ?? false
                    readonly property bool hasRatings: root.application.rating.ratingCount > 0
                    active: root.showRating && ratingsSupported && hasRatings
                    visible: active
                    sourceComponent: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Kirigami.Icon {
                            source: "rating"
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                            color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 1.0)
                        }
                        QQC2.Label {
                            text: (root.application.rating.rating / 2).toPrecision(2)
                            font.bold: true
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                        }
                        Rectangle {
                            implicitWidth: 3
                            implicitHeight: 3
                            radius: 1.5
                            color: Kirigami.Theme.textColor
                            opacity: 0.3
                        }
                    }
                }
                
                QQC2.Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.application.author || root.application.backend.displayName
                    font: Kirigami.Theme.smallFont
                    opacity: 0.6
                }
            }
        }
        
        // 3. Install Button
        Loader {
            active: root.showInstallButton
            visible: active
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            sourceComponent: InstallApplicationButton {
                application: root.application
                installOrRemoveButtonDisplayStyle: QQC2.AbstractButton.IconOnly
            }
        }
    }


    onFocusChanged: {
        if (focus) {
            page.ensureVisible(root)
        }
    }
}
