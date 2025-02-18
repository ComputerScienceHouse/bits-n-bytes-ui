#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import config  # Ensure environment variables are configured
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QDir
from PySide6.QtGui import QFontDatabase

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
    engine.load(QUrl("BnB/Reciept.qml"))

    if not engine.rootObjects():
        sys.exit("Error: Main.qml failed to load.")

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
