import sys
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.loadData(b"""
import QtQuick
import QtQuick.Controls
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
    
    header: ToolBar {
        Label { text: "FULL WIDTH HEADER" }
    }
    
    pageStack.initialPage: Kirigami.Page {
        title: "Test Page"
        Label { text: "Content" }
    }
}
""")
if not engine.rootObjects():
    sys.exit(-1)
sys.exit(0)
