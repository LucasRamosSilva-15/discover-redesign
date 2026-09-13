const fs = require('fs');
const path = require('path');

const targetPath = path.resolve('discover/qml/BrowsingPage.qml');
let content = fs.readFileSync(targetPath, 'utf-8');

// Modernize the Hero Banner
const heroOld = `            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#2563eb" } // blue-600
                GradientStop { position: 0.5; color: "#0284c7" } // sky-600
                GradientStop { position: 1.0; color: "#4338ca" } // indigo-700
            }`;

const heroNew = `            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.8) }
                GradientStop { position: 1.0; color: Qt.darker(Kirigami.Theme.highlightColor, 1.2) }
            }`;
content = content.replace(heroOld, heroNew);

// Now, we need to extract the "See More" buttons and move them into a RowLayout with the Heading.
// We will use regex to find each section block.
const sections = [
    { id: 'pop', title: 'Most Popular', category: 'All Applications' },
    { id: 'featured', title: 'Editor’s Choice', category: 'None' }, // Featured doesn't have See More
    { id: 'recentlyUpdated', title: 'Newly Published & Recently Updated', category: 'None' }, // Doesn't have See More
    { id: 'games', title: 'Highest-Rated Games', category: 'Games' },
    { id: 'dev', title: 'Highest-Rated Developer Tools', category: 'Development' }
];

for (const sec of sections) {
    if (sec.category !== 'None') {
        // Regex to find the Heading, Repeater, and Button block
        const regex = new RegExp(
            \`Kirigami\\.Heading \\{\\s+id: \\w+Heading[\\s\\S]*?text: i18nc\\("@title:group", "${sec.title}"\\)[\\s\\S]*?\\}\\s+Repeater \\{[\\s\\S]*?id: \\w+Rep[\\s\\S]*?\\}\\s+QQC2\\.Button \\{[\\s\\S]*?text: i18nc\\("@action:button", "See More"\\)[\\s\\S]*?visible:[^\\n]*\\n\\s*\\}\`,
            'm'
        );

        // We can't simply regex easily because of nested braces. It's safer to just do simple string replacements.
    }
}

// Alternatively, let's just completely replace the Kirigami.CardsLayout content.
// Since the user wants to reduce lines, we can create a generic component inside the file or just use standard blocks.
// Actually, since there are complex Keys.onUpPressed calculations, rewriting the whole file might break KDE TV/keyboard support.
// Let's just fix the visual part: change the Headings into RowLayouts that include the "See More" button!

// 1. Replace all QQC2.Button "See More" with empty string. We will inject them next to the headings.
content = content.replace(/QQC2\.Button \{\s+text: i18nc\("@action:button", "See More"\)[\s\S]+?onFocusChanged: \{[\s\S]+?\}\s+\}\s+\}/g, '}');

// Now, replace Headings with RowLayouts containing the Heading and the Button.
function replaceHeading(id, titleText, categoryAction) {
    const search = new RegExp(\`Kirigami\\.Heading \\{\\s+id: \${id}Heading[\\s\\S]*?text: i18nc\\("@title:group", "\${titleText}"\\)[\\s\\S]*?\\}\`, 'm');
    
    const replacement = \`RowLayout {
            Layout.topMargin: page.padding
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            visible: \${id}Rep.count > 0 && !featuredModel.isFetching

            Kirigami.Heading {
                Layout.fillWidth: true
                text: i18nc("@title:group", "\${titleText}")
                wrapMode: Text.Wrap
                level: 2
                font.weight: Font.Bold
            }
            
            QQC2.Button {
                text: i18nc("@action:button", "Ver Todos")
                icon.name: Qt.application.layoutDirection === Qt.LeftToRight ? "go-next-symbolic" : "go-next-rtl-symbolic"
                flat: true
                onClicked: Navigation.openCategory(Discover.CategoryModel.findCategoryByName("\${categoryAction}"))
            }
        }\`;
    content = content.replace(search, replacement);
}

replaceHeading('pop', 'Most Popular', 'All Applications');
replaceHeading('games', 'Highest-Rated Games', 'Games');
replaceHeading('dev', 'Highest-Rated Developer Tools', 'Development');

// For featured and recently updated (which don't have See More):
const featureSearch = /Kirigami\.Heading \{\s+id: featuredHeading[\s\S]*?visible: featuredRep\.count > 0 && !featuredModel\.isFetching\s*\}/m;
const featureRep = \`Kirigami.Heading {
            id: featuredHeading
            Layout.topMargin: page.padding
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Editor’s Choice")
            wrapMode: Text.Wrap
            level: 2
            font.weight: Font.Bold
            visible: featuredRep.count > 0 && !featuredModel.isFetching
        }\`;
content = content.replace(featureSearch, featureRep);

const recentSearch = /Kirigami\.Heading \{\s+id: recentlyUpdatedHeading[\s\S]*?visible: recentlyUpdatedRepeater\.count > 0 && !featuredModel\.isFetching\s*\}/m;
const recentRep = \`Kirigami.Heading {
            id: recentlyUpdatedHeading
            Layout.topMargin: page.padding
            Layout.columnSpan: apps.columns
            Layout.fillWidth: true
            text: i18nc("@title:group", "Newly Published & Recently Updated")
            wrapMode: Text.Wrap
            level: 2
            font.weight: Font.Bold
            visible: recentlyUpdatedRepeater.count > 0 && !featuredModel.isFetching
        }\`;
content = content.replace(recentSearch, recentRep);


fs.writeFileSync(targetPath, content, 'utf-8');
console.log('BrowsingPage updated.');
