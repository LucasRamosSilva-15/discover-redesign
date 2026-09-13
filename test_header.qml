import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 800
    height: 600
    visible: true
    
    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true
        actions: [
            Kirigami.Action { text: "Action 1" }
        ]
    }
    
    pageStack.initialPage: Kirigami.Page {
        title: "Test Page"
        QQC2.Label { text: "Hello World" }
    }
}
