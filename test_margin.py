import sys
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.loadData(b"""
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 800
    height: 600
    visible: true
    
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    
    menuBar: QQC2.ToolBar {
        id: customGlobalHeader
        height: 50
        QQC2.Label { text: "FULL WIDTH HEADER" }
    }
    
    pageStack.anchors.topMargin: 50
    
    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true
        topPadding: 50
        actions: [
            Kirigami.Action { text: "Action 1" }
        ]
    }
    
    pageStack.initialPage: Kirigami.Page {
        title: "Test Page"
        QQC2.Label { text: "Content is here" }
    }
}
""")
sys.exit(0)
