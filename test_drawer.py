import sys
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.loadData(b"""
import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.GlobalDrawer {
    id: drawer
    Component.onCompleted: {
        console.log("Drawer properties:");
        for (var prop in drawer) {
            if (prop.indexOf("header") !== -1) {
                console.log(prop);
            }
        }
    }
}
""")
sys.exit(0)
