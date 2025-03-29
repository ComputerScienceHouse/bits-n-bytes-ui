#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import config  # Ensure environment variables are configured
import typer
from rich.progress import track
from typing_extensions import Annotated

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QDir
from PySide6.QtGui import QFontDatabase
from bnb.app_controller import AppController

app = typer.Typer(no_args_is_help=True)
run = typer.Typer()
app.add_typer(run)

os.environ["QT_QUICK_CONTROLS_STYLE"] = "MCUDefaultStyle"
os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"

@run.command()
def run(screen: Annotated[str, typer.Argument()] = "main"):
    
        if screen != screen.lower():
            raise typer.BadParameter("The screen name must be in lowercase.")

        qmlApp = QApplication(sys.argv)
        qmlApp.setStyle('Material')
        import_path = os.path.join(os.getcwd(), "ui", "imports")
        font_dir = os.path.join(os.getcwd(), "ui", "fonts")
        controller = AppController()
        engine = QQmlApplicationEngine()
        engine.addImportPath(import_path)

        total = 0
        for font_file in track(os.listdir(font_dir), description="Adding fonts..."):
            font_path = os.path.join(font_dir, font_file)
            QFontDatabase.addApplicationFont(font_path)
            total += 1
        print(f"Added {total} fonts.")           

        engine.rootContext().setContextProperty("controller", controller)
        engine.load(QUrl(f"ui/Main.qml"))

        if not engine.rootObjects():
            sys.exit("Error: Main.qml failed to load.")

        root_object = engine.rootObjects()[0] # Gets Window object

        # all_children = root_object.findChildren(QObject)
        # for child in all_children:
            # print(f"Child: {child} is of type - {child.metaObject().className()}")

        if is_raspi():
            root_object.showFullScreen()

        # navigate to screen if arg is given
        controller.navigate(screen)

        sys.exit(qmlApp.exec())

def is_raspi():
    try:
        with open("/proc/device-tree/model") as f:
            return "Raspberry Pi" in f.read()
    except FileNotFoundError:
        pass

if __name__ == "__main__":
    app()