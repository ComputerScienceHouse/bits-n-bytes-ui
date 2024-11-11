# This Python file uses the following encoding: utf-8
import sys
from PySide6.QtWidgets import QApplication, QMainWindow, QStackedWidget
from PySide6.QtGui import QFontDatabase, QColor
from PySide6.QtCore import Qt, QTimer
from screens.cart_screen import CartScreen
from screens.welcome_screen import WelcomeScreen
from screens.reciept_screen import RecieptScreen
from screens.admin_screen import AdminScreen
import mqtt
import resources_rc  # Ensure your resources are compiled and available
import nfc
from concurrent.futures import ThreadPoolExecutor
import database

try:
    import config
except ModuleNotFoundError:
    print("No config.py found, code might not work properly")

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
        self.showFullScreen()
        # Set window background color
        palette = self.palette()
        palette.setColor(self.backgroundRole(), QColor("#323232"))
        self.setPalette(palette)
        self.user = None;

        self.user = None;
        # Instantiate the screens
        self.welcome_screen = WelcomeScreen()
        self.cart_screen = CartScreen(self.user)
        self.cart_screen = CartScreen(self.user)
        self.reciept_screen = RecieptScreen(self.cart_screen.cart)
        self.admin_screen = AdminScreen()

        # Add screens to the stack with respective indices
        self.stack.addWidget(self.welcome_screen)    # Index 0
        self.stack.addWidget(self.cart_screen)       # Index 1
        self.stack.addWidget(self.reciept_screen)    # Index 2
        self.stack.addWidget(self.admin_screen)

        # Connect buttons for navigation (for debugging/development)

        self.nfc_thread = nfc.NFCListenerThread()
        self.nfc_thread.token_detected.connect(self.process_nfc_token)
        self.nfc_thread.start()

        self.cart_screen.show_receipt_signal.connect(lambda: self.stack.setCurrentIndex(2))
        self.welcome_screen.ui.tapButton.clicked.connect(lambda: self.go_to_cart())
        self.cart_screen.ui.navButton.clicked.connect(lambda: self.stack.setCurrentIndex(0))
        # self.cart_screen.show_receipt_signal.connect(lambda: self.stack.setCurrentIndex(2))
        # self.stack.currentChanged.connect(self.on_screen_change_cb)
        # Navigate to the welcome screen, triggering the NFC callback
        self.stack.setCurrentIndex(1)
        self.stack.setCurrentIndex(0)


    def go_to_cart(self):
        mqtt.open_doors()
        widget.stack.setCurrentIndex(1)

    # def on_screen_change_cb(self, index):
    #     """
    #     Callback function for when the screen changes

    #     Params:
    #     index: The index of the screen switched to
    #     """
    #     if index == 0:
    #         # Switched to the welcome screen
    #         print("Switched to welcome screen")
    #         QTimer.singleShot(100, self.get_nfc_data)
    

    def process_nfc_token(self, token):
        # This function is called when a token is detected by the NFC listener thread
        if self.stack.currentIndex() == 0:
            user = database.get_user(user_token=token)
            if user:
                print(f"User {user} found for token {token}")
                self.go_to_cart()  # Switch to cart if user is found
            else:
                print("User not found for scanned token.")


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
