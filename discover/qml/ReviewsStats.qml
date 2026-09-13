/*
 *   SPDX-FileCopyrightText: 2023 Marco Martin <mart@kde.org>
 *   SPDX-FileCopyrightText: 2026 Lucas Ramos <lucasramos@kde.org>
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
import org.kde.kitemmodels as KItemModels

Rectangle {
    id: root

    required property Discover.AbstractResource application
    required property Discover.ReviewsModel reviewsModel
    required property Discover.ReviewsModel model
    required property int visibleReviews
    required property bool compact

    property bool canShowAllReviews: false
    property bool canWriteReview: false
    property bool isInstalled: false

    signal showAllReviewsRequested()
    signal writeReviewRequested()

    radius: 16
    color: Kirigami.Theme.backgroundColor
    border.color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
    border.width: 1

    implicitHeight: mainCol.implicitHeight + Kirigami.Units.largeSpacing * 3

    ColumnLayout {
        id: mainCol
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing * 1.5
        spacing: Kirigami.Units.largeSpacing * 1.2

        Kirigami.Heading {
            text: i18nc("@title", "Reviews")
            level: 3
            font.weight: Font.Bold
            color: Kirigami.Theme.textColor
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing * 2

            // Big Score column
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 120
                spacing: 2

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: (Math.min(10, root.application.rating ? root.application.rating.rating : 0) / 2.0).toFixed(1)
                    font.pointSize: 42
                    font.weight: Font.Bold
                    color: Kirigami.Theme.textColor
                }

                Rating {
                    id: globalRating
                    Layout.alignment: Qt.AlignHCenter
                    value: root.application.rating ? root.application.rating.rating : 0
                    precision: Rating.Precision.HalfStar
                    starSize: 16
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18nc("how many reviews", "%1 reviews", root.application.rating ? root.application.rating.ratingCount : 0)
                    color: Kirigami.Theme.disabledTextColor
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            // 5 Colored Bars column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                Repeater {
                    model: [5, 4, 3, 2, 1]

                    delegate: RowLayout {
                        id: barRow
                        required property int modelData

                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.Label {
                            text: barRow.modelData.toString()
                            font.weight: Font.Medium
                            color: Kirigami.Theme.disabledTextColor
                            Layout.preferredWidth: 12
                            horizontalAlignment: Text.AlignRight
                        }

                        Rectangle {
                            id: barTrack
                            Layout.fillWidth: true
                            Layout.preferredHeight: 8
                            radius: 4
                            color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.08)
                            clip: true

                            readonly property real totalReviews: root.application.rating ? root.application.rating.ratingCount : 0
                            readonly property real starCount: (root.application.rating && root.application.rating.starCounts && root.application.rating.starCounts[barRow.modelData] !== undefined)
                                ? root.application.rating.starCounts[barRow.modelData]
                                : 0
                            readonly property real fraction: totalReviews > 0 ? Math.min(1.0, starCount / totalReviews) : 0

                            readonly property color barColor: {
                                switch (barRow.modelData) {
                                case 5: return "#10b981"; // emerald-500
                                case 4: return "#34d399"; // emerald-400
                                case 3: return "#f59e0b"; // amber-500
                                case 2: return "#f87171"; // rose-400
                                case 1: return "#ef4444"; // rose-500
                                default: return Kirigami.Theme.highlightColor;
                                }
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.round(parent.width * barTrack.fraction)
                                radius: 4
                                color: barTrack.barColor

                                Behavior on width {
                                    NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Reviews Quotes preview (if available)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.08)
            visible: reviewsPreview.visible && reviewsPreview.count > 0
        }

        Item {
            id: reviewsPreviewContainer
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 5
            visible: reviewsPreview.count > 0

            ListView {
                id: reviewsPreview
                anchors.fill: parent
                visible: count > 0
                clip: true
                orientation: ListView.Horizontal
                currentIndex: 0
                pixelAligned: true
                snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.StrictlyEnforceRange

                preferredHighlightBegin: currentItem ? Math.round((width - currentItem.width) / 2) : 0
                preferredHighlightEnd: currentItem ? preferredHighlightBegin + currentItem.width : 0

                highlightMoveDuration: Kirigami.Units.longDuration
                highlightResizeDuration: Kirigami.Units.longDuration

                model: DiscoverApp.LimitedRowCountProxyModel {
                    sourceModel: KItemModels.KSortFilterProxyModel {
                        id: sortModel
                        sourceModel: root.model
                        filterRoleName: "usefulnessFavorable"
                        filterRowCallback: (sourceRow, sourceParent) => {
                            const index = sourceModel.index(sourceRow, 0, sourceParent);
                            const shouldShow = sourceModel.data(index, Discover.ReviewsModel.ShouldShow);
                            return shouldShow === true && sourceModel.data(index, Discover.ReviewsModel.UsefulnessFavorable) > 0;
                        }
                        onSortRoleNameChanged: sortOrder = Qt.DescendingOrder
                    }
                    pageSize: root.visibleReviews
                }

                delegate: Item {
                    id: delegateItem

                    required property string summary
                    required property string display
                    required property string reviewer

                    width: reviewsPreview.width
                    height: reviewsPreview.height

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        spacing: 4

                        Kirigami.Heading {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            level: 4
                            text: delegateItem.summary
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            text: delegateItem.display
                            font.italic: true
                            color: Kirigami.Theme.disabledTextColor
                        }
                        QQC2.Label {
                            Layout.alignment: Qt.AlignHCenter
                            opacity: 0.75
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            text: delegateItem.reviewer || i18n("Unknown reviewer")
                        }
                    }
                }

                Timer {
                    running: root.visible && !reviewsPreview.moving && reviewsPreview.count > 1
                    repeat: true
                    interval: 10000
                    onTriggered: reviewsPreview.currentIndex = (reviewsPreview.currentIndex + 1) % reviewsPreview.count
                }
            }
        }

        // Action Buttons at the bottom
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.08)
            visible: root.canShowAllReviews || root.canWriteReview
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing
            visible: root.canShowAllReviews || root.canWriteReview

            QQC2.Button {
                visible: root.canShowAllReviews
                text: i18nc("@action:button", "Show All Reviews")
                icon.name: "view-visible"
                onClicked: root.showAllReviewsRequested()
            }

            QQC2.Button {
                visible: root.canWriteReview
                enabled: root.isInstalled
                text: root.isInstalled ? i18n("Write a Review") : i18n("Install to Write a Review")
                icon.name: "document-edit"
                onClicked: root.writeReviewRequested()
            }
        }
    }
}
