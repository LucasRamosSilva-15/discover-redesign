/*
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

RowLayout {
    id: root

    required property string icon
    required property string website
    required property string linkText

    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    Kirigami.Icon {
        id: iconItem
        Layout.preferredWidth: Kirigami.Units.iconSizes.sizeForLabels
        Layout.preferredHeight: Kirigami.Units.iconSizes.sizeForLabels
        Layout.alignment: Qt.AlignVCenter
        source: root.icon
    }

    Kirigami.UrlButton {
        id: urlButton
        Layout.fillWidth: true
        visible: root.linkText.length > 0
        text: root.linkText
        url: root.website
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
}
