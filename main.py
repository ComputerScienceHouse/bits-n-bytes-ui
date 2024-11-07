# This Python file uses the following encoding: utf-8
import sys
from PySide6.QtWidgets import QApplication, QMainWindow, QStackedWidget
from PySide6.QtGui import QFontDatabase, QColor
from PySide6.QtCore import Qt
from screens.cart_screen import CartScreen
from screens.welcome_screen import WelcomeScreen
from screens.reciept_screen import RecieptScreen
import mqtt
import resources_rc  # Ensure your resources are compiled and available

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.setFixedSize(1024, 600)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.initUI()

    def initUI(self):
        # Create a QStackedWidget to manage different screens
        self.stack = QStackedWidget()
        self.setCentralWidget(self.stack)

        # Set window background color
        palette = self.palette()
        palette.setColor(self.backgroundRole(), QColor("#323232"))
        self.setPalette(palette)

        # Instantiate the screens
        self.welcome_screen = WelcomeScreen()
        self.cart_screen = CartScreen()
        self.reciept_screen = RecieptScreen(self.cart_screen.cart)

        # Add screens to the stack with respective indices
        self.stack.addWidget(self.welcome_screen)    # Index 0
        self.stack.addWidget(self.cart_screen)       # Index 1
        self.stack.addWidget(self.reciept_screen)    # Index 2

        # Connect buttons for navigation (for debugging/development)
        self.welcome_screen.ui.tapButton.clicked.connect(lambda: self.go_to_cart)
        self.cart_screen.ui.navButton.clicked.connect(lambda: self.stack.setCurrentIndex(0))
        self.cart_screen.ui.navRecieptButton.clicked.connect(lambda: self.stack.setCurrentIndex(2))

    def go_to_cart(self):
        mqtt.open_doors()
        widget.stack.setCurrentIndex(1)

def load_stylesheet(theme):
    with open(f"resources/styles/{theme}_style.qss", "r") as file:
        stylesheet = file.read()
        app.setStyleSheet(stylesheet)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()

    # Load fonts (assuming fonts are in resources.qrc)
    QFontDatabase.addApplicationFont(":/resources/Roboto")
    QFontDatabase.addApplicationFont(":/resources/IBMPlexMono")
    load_stylesheet("dark")

    # Show the main window
    widget.show()
    sys.exit(app.exec())
