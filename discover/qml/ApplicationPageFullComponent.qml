/*
 *   SPDX-FileCopyrightText: 2012 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *   SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *   SPDX-FileCopyrightText: 2026 Lucas Ramos <lucasramos@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.discover as Discover

ColumnLayout {
    id: fullComponent

    required property Discover.AbstractResource application
    required property bool availableFromOnlySingleSource
    required property bool isOfflineUpgrade
    required property bool isTechnicalPackage
    required property var colorForLicenseType

    signal openContentRatingDialog()
    signal openLicenseDetailsDialog(licenseType: string)
    signal openAllLicensesSheet()

    spacing: Kirigami.Units.largeSpacing

    // App Hero Card
    Rectangle {
        id: heroCard
        Layout.fillWidth: true
        radius: 16
        color: Kirigami.Theme.backgroundColor
        border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
        border.width: 1

        implicitHeight: heroLayout.implicitHeight + Kirigami.Units.largeSpacing * 3

        GridLayout {
            id: heroLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing * 1.5
            columns: width > 600 ? 2 : 1
            columnSpacing: Kirigami.Units.largeSpacing * 2
            rowSpacing: Kirigami.Units.largeSpacing

            // Left: App Info (Icon, Name, Author, Rating)
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Kirigami.Units.largeSpacing * 1.5

                // App Icon Container
                Rectangle {
                    implicitWidth: 84
                    implicitHeight: 84
                    radius: 16
                    color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.04)
                    border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.08)
                    border.width: 1

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        implicitWidth: 64
                        implicitHeight: 64
                        source: fullComponent.application.icon
                    }
                }

                // Name, Author, Rating
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Kirigami.Heading {
                        Layout.fillWidth: true
                        text: fullComponent.application.name
                        level: 1
                        font.weight: Font.Bold
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.6
                        color: Kirigami.Theme.textColor
                        elide: Text.ElideRight
                        maximumLineCount: 2
                    }

                    // Author + Verified Row
                    RowLayout {
                        spacing: 6

                        QQC2.Label {
                            text: {
                                if (fullComponent.isOfflineUpgrade) {
                                    return fullComponent.application.upgradeText.length > 0 ? fullComponent.application.upgradeText : "";
                                } else if (fullComponent.application.author.length > 0) {
                                    return fullComponent.application.author;
                                } else {
                                    return i18nc("Unknown author", "Unknown author");
                                }
                            }
                            font.weight: Font.Medium
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Kirigami.Icon {
                            visible: fullComponent.application.verifiedIconName.length > 0
                            source: "checkmark"
                            implicitWidth: 14
                            implicitHeight: 14
                            color: "#10b981"
                        }
                    }

                    // Stars + Rating Count
                    RowLayout {
                        visible: !fullComponent.isTechnicalPackage
                        spacing: 6

                        Rating {
                            value: fullComponent.application.rating ? fullComponent.application.rating.rating : 0
                            precision: Rating.Precision.HalfStar
                            starSize: Kirigami.Units.gridUnit * 0.85
                        }

                        QQC2.Label {
                            text: fullComponent.application.rating ? i18ncp("%1 rating", "%1 ratings", fullComponent.application.rating.ratingCount) : i18nc("No ratings yet", "No ratings yet")
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }
                }
            }

            // Right: Primary & Secondary Action Buttons
            InstallApplicationButton {
                Layout.alignment: heroLayout.columns > 1 ? (Qt.AlignRight | Qt.AlignVCenter) : (Qt.AlignLeft | Qt.AlignVCenter)
                application: fullComponent.application
                buttonActiveFocusOnTab: true
                availableFromOnlySingleSource: fullComponent.availableFromOnlySingleSource
                hideInvokeButton: false
            }
        }
    }

    // Metadata 4-Card Grid
    GridLayout {
        id: metaGrid
        Layout.fillWidth: true
        columns: width > 650 ? 4 : 2
        columnSpacing: Kirigami.Units.largeSpacing
        rowSpacing: Kirigami.Units.largeSpacing
        visible: !fullComponent.isOfflineUpgrade

        // Card 1: VERSÃO
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 68
            radius: 12
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: 2

                QQC2.Label {
                    text: i18nc("@title:group", "VERSION")
                    font.pointSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                    color: Kirigami.Theme.disabledTextColor
                }

                QQC2.Label {
                    text: fullComponent.application.versionString.length > 0 ? fullComponent.application.versionString : "-"
                    font.weight: Font.DemiBold
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    color: Kirigami.Theme.textColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Card 2: TAMANHO
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 68
            radius: 12
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: 2

                QQC2.Label {
                    text: i18nc("@title:group", "SIZE")
                    font.pointSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                    color: Kirigami.Theme.disabledTextColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    QQC2.BusyIndicator {
                        implicitWidth: 16
                        implicitHeight: 16
                        visible: !sizeLabel.visible && fullComponent.application.sizeDescription.length > 0
                        running: visible
                    }

                    QQC2.Label {
                        id: sizeLabel
                        text: fullComponent.application.sizeDescription.length > 0 ? fullComponent.application.sizeDescription : "-"
                        font.weight: Font.DemiBold
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        color: Kirigami.Theme.textColor
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Card 3: LICENÇA
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 68
            radius: 12
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: 2

                QQC2.Label {
                    text: i18nc("@title:group", "LICENSE")
                    font.pointSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                    color: Kirigami.Theme.disabledTextColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    QQC2.Label {
                        id: licenseLabel
                        text: fullComponent.application.licenses.length > 0 ? fullComponent.application.licenses[0].name : i18nc("Unknown license", "Unknown")
                        font.weight: Font.DemiBold
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        color: "#1d99f3"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Kirigami.Icon {
                        source: "link"
                        implicitWidth: 12
                        implicitHeight: 12
                        color: "#1d99f3"
                        opacity: licenseMouseArea.containsMouse ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }
                    }
                }
            }

            MouseArea {
                id: licenseMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (fullComponent.application.licenses.length > 1) {
                        fullComponent.openAllLicensesSheet();
                    } else if (fullComponent.application.licenses.length === 1) {
                        fullComponent.openLicenseDetailsDialog(fullComponent.application.licenses[0].licenseType);
                    } else {
                        fullComponent.openLicenseDetailsDialog("unknown");
                    }
                }
            }
        }

        // Card 4: IDADES
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 68
            radius: 12
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: 2

                QQC2.Label {
                    text: i18nc("@title:group", "AGES")
                    font.pointSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                    color: Kirigami.Theme.disabledTextColor
                }

                QQC2.Label {
                    text: fullComponent.application.contentRatingMinimumAge === 0
                        ? i18nc("Suitable for everyone", "Everyone")
                        : i18nc("%1+ years old", "%1+", fullComponent.application.contentRatingMinimumAge)
                    font.weight: Font.DemiBold
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    color: "#10b981"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: fullComponent.application.contentRatingDescription.length > 0
                cursorShape: fullComponent.application.contentRatingDescription.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (fullComponent.application.contentRatingDescription.length > 0) {
                        fullComponent.openContentRatingDialog();
                    }
                }
            }
        }
    }
}
