#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import typer
from typing_extensions import Annotated

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QDir
from PySide6.QtGui import QFontDatabase

from core import config
from core.controller import base
from core.services import s3

app = typer.Typer()
app.add_typer(s3.s3_cli, name="s3")

os.environ["QT_QUICK_CONTROLS_STYLE"] = "MCUDefaultStyle"
os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"

@app.command()
def run():
    qmlApp = QApplication(sys.argv)
    qmlApp.setStyle('Material')
    import_path = os.path.join(os.getcwd(), "ui", "imports")
    font_dir = os.path.join(os.getcwd(), "ui", "fonts")
    app_controller = base.Controller()
    engine = QQmlApplicationEngine()
    engine.addImportPath(import_path)
    for font_file in os.listdir(font_dir):
        font_path = os.path.join(font_dir, font_file)
        QFontDatabase.addApplicationFont(font_path)

    engine.rootContext().setContextProperty("controller", app_controller)
    engine.load(QUrl(f"ui/Main.qml"))

    if not engine.rootObjects():
        sys.exit("Error: Main.qml failed to load.")

    root_object = engine.rootObjects()[0] # Gets Window object

    if is_raspi():
        root_object.showFullScreen()

    sys.exit(qmlApp.exec())

def is_raspi():
    try:
        with open("/proc/device-tree/model") as f:
            return "Raspberry Pi" in f.read()
    except FileNotFoundError:
        pass

if __name__ == "__main__":
    app()