#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import config  # Ensure environment variables are configured
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject
from PySide6.QtCore import QDir
from PySide6.QtGui import QFontDatabase
from app_controller import AppController


os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
def main():
    app = QApplication(sys.argv)
    app.setStyle('Material')
    # Optionally, load fonts if needed
    # QFontDatabase.addApplicationFont(":/resources/Roboto")
    # QFontDatabase.addApplicationFont(":/resources/IBMPlexMono")
    import_path = os.path.join(os.getcwd(), "BnB", "imports")
    engine = QQmlApplicationEngine()
    engine.addImportPath(import_path)

    engine.load(QUrl("BnB/Main.qml"))
    if not engine.rootObjects():
        sys.exit("Error: Main.qml failed to load.")

    root = engine.rootObjects()[0]
    for child in root.children():
        print("Child object name:", child.objectName())
    stack = root.findChild(QObject, 'stack')
    if stack is None:
        sys.exit("Error: stack not found in Main.qml")
    controller = AppController(stack)
    engine.rootContext().setContextProperty("controller", controller)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
