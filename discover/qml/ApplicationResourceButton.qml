/*
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *   SPDX-FileCopyrightText: 2026 Lucas Ramos <lucasramos@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Item {
    id: root

    required property string icon
    required property string website
    required property string linkText

    implicitWidth: layout.implicitWidth
    implicitHeight: 36
    Layout.fillWidth: true

    Rectangle {
        id: bgHover
        anchors.fill: parent
        anchors.leftMargin: -Kirigami.Units.smallSpacing
        anchors.rightMargin: -Kirigami.Units.smallSpacing
        radius: 8
        color: mouseArea.containsMouse
            ? Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.12)
            : "transparent"
        Behavior on color {
            ColorAnimation { duration: Kirigami.Units.shortDuration }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter
            source: root.icon
            color: "#1d99f3"
        }

        QQC2.Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.linkText
            color: mouseArea.containsMouse ? "#0284c7" : "#1d99f3"
            font.weight: Font.Medium
            font.pointSize: Kirigami.Theme.defaultFont.pointSize
            elide: Text.ElideRight
        }

        Kirigami.Icon {
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            Layout.alignment: Qt.AlignVCenter
            source: "go-next-symbolic"
            color: mouseArea.containsMouse ? "#1d99f3" : Kirigami.Theme.disabledTextColor
            opacity: mouseArea.containsMouse ? 1.0 : 0.6
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.website.length > 0) {
                Qt.openUrlExternally(root.website);
            }
        }
    }
}
