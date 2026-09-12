const fs = require('fs');
const path = require('path');

const targetPath = path.resolve('discover/qml/ApplicationDelegate.qml');
let content = fs.readFileSync(targetPath, 'utf-8');

const replacement = `
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
`;

const startIndex = content.indexOf('content: RowLayout {');
if (startIndex !== -1) {
    const endBlock = 'onFocusChanged: {\n        if (focus) {\n            page.ensureVisible(root)\n        }\n    }';
    const endIndex = content.lastIndexOf(endBlock);
    
    if (endIndex !== -1) {
        const newContent = content.substring(0, startIndex) + replacement + '\n\n    ' + content.substring(endIndex);
        fs.writeFileSync(targetPath, newContent, 'utf-8');
        console.log("Replaced ApplicationDelegate.qml successfully.");
    } else {
        console.log("Could not find end block");
    }
} else {
    console.log("Could not find start block");
}

