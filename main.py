# This Python file uses the following encoding: utf-8
import sys

from PySide6.QtWidgets import QApplication, QMainWindow, QStackedWidget
from PySide6.QtGui import QFontDatabase, QFont
from PySide6.QtCore import QFile, QTextStream, Qt
from screens.cart_screen import CartScreen
from screens.welcome_screen import WelcomeScreen
from screens.reciept_screen import RecieptScreen
import resources_rc
import database
import os
import config

# Important:
# You need to run the following command to generate the ui_form.py file
#     pyside6-uic form.ui -o ui_form.py, or
#     pyside2-uic form.ui -o ui_form.py

themes = {
    "light": {
        "primary": "#6C0164",
        "secondary": "#F76902",
        "text": "#000000",
        "background": "#ffffff"
    },
    "dark": {
        "primary": "#2b2b2b",
        "secondary": "#2ecc71",
        "text": "#ffffff",
        "background": "#1e1e1e" 
    }
}

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.setFixedSize(1024, 600);
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.initUI()

    def initUI(self):
        # Create a QStackedWidget to manage different screens
        self.stack = QStackedWidget()
        self.setCentralWidget(self.stack)

        # Create Cart add Welcome screen
        self.welcome_screen = WelcomeScreen()
        self.cart_screen = CartScreen()
        self.reciept_screen = RecieptScreen()

        self.stack.addWidget(self.welcome_screen)    # Index 0
        self.stack.addWidget(self.cart_screen)       # Index 1
        self.stack.addWidget(self.reciept_screen)    # Index 2


        # Connect buttons to navigate between screens
        self.welcome_screen.ui.tapButton.clicked.connect(lambda: self.stack.setCurrentIndex(1))
        self.cart_screen.ui.navButton.clicked.connect(lambda: self.stack.setCurrentIndex(0))
        self.cart_screen.ui.navRecieptButton.clicked.connect(lambda: self.stack.setCurrentIndex(2))

def load_stylesheet(theme):
    with open(f"resources/styles/{theme}_style.qss", "r") as file:
        stylesheet = file.read()
        app.setStyleSheet(stylesheet)

# def apply_stylesheet(app, qss_path, theme_name):
#     """Apply a stylesheet with the specified theme to the application."""
#     theme_colors = themes.get(theme_name)
#     if not theme_colors:
#         print(f"Theme '{theme_name}' not found.")
#         return

#     # Load the QSS template file
#     file = QFile(qss_path)
#     if not file.exists():
#         print(f"File not found: {qss_path}")
#         return

#     if file.open(QFile.ReadOnly | QFile.Text):
#         stream = QTextStream(file)
#         qss_template = stream.readAll()
#         file.close()

#         # Manually replace each placeholder with the corresponding theme color
#         qss = qss_template
#         qss = qss.replace("{primary}", theme_colors["primary"])
#         qss = qss.replace("{secondary}", theme_colors["secondary"])
#         qss = qss.replace("{text}", theme_colors["text"])
#         qss = qss.replace("{background}", theme_colors["background"])

#         # Apply the generated QSS to the application
#         # app.setStyleSheet(qss)
#         print("Stylesheet loaded successfully.")
#     else:
#         print(f"Failed to open stylesheet from {qss_path}")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()  # Replace this with your main window
    # Load fonts (assuming fonts are defined in resources.qrc)
    roboto_font_id = QFontDatabase.addApplicationFont(":/resources/Roboto")
    ibm_plex_mono_font_id = QFontDatabase.addApplicationFont(":/resources/IBMPlexMono")
    load_stylesheet("dark")

    if roboto_font_id == -1 or ibm_plex_mono_font_id == -1:
        print("Failed to load one or more fonts from resources.")
    else:
        print("Fonts loaded successfully.")

    # Define the current theme and QSS path
    # current_theme = "dark"  # Set to 'dark' if you want to use the dark theme
    # qss_path = ":/resources/style"  # Path to the QSS template

    # # Apply the stylesheet using the method
    # apply_stylesheet(app, qss_path, current_theme)

    # Show the main window
    widget.show()

    sys.exit(app.exec())
