# This Python file uses the following encoding: utf-8
# IMPORTANT: Keep this import of config.py, otherwise environment variables will not be configured!
import config
# IMPORTANT: Keep this import of config.py, otherwise environment variables will not be configured!
import sys
from PySide6.QtWidgets import QApplication, QMainWindow, QStackedWidget
from PySide6.QtGui import QFontDatabase, QColor
from PySide6.QtCore import Qt, QTimer
from screens.cart_screen import CartScreen
from screens.welcome_screen import WelcomeScreen
from screens.reciept_screen import RecieptScreen
from screens.admin_screen import AdminScreen
from screens.tare_screen import TareScreen
import mqtt
import resources_rc  # Ensure your resources are compiled and available
import nfc
from concurrent.futures import ThreadPoolExecutor
import database
from shelf_manager import ShelfManager

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
        # Create the shelf manager
        # Tell MQTT to call the shelf manager "on_shelf_data_cb" function whenever it receives
        # data on the shelf data topic
        mqtt.shelf_data_received_callback = lambda client, userdata, msg: self.shelf_manager.on_shelf_data_cb(client, userdata, msg)
        # TODO add door closed callback below
        mqtt.doors_closed_status_callback = lambda: self.show_receipt_screen()

    def initUI(self):
        # Create a QStackedWidget to manage different screens
        self.stack = QStackedWidget()
        self.setCentralWidget(self.stack)
        self.showFullScreen()
        # Set window background color
        palette = self.palette()
        palette.setColor(self.backgroundRole(), QColor("#323232"))
        self.setPalette(palette)
        self.user = None
        self.nfc_thread = None
        self.is_nfc_active = False
        # Instantiate the screens
        self.welcome_screen = WelcomeScreen()
        self.cart_screen = CartScreen(self.user)
        self.shelf_manager = ShelfManager(add_to_cart_cb=self.cart_screen.add_item_to_cart, remove_from_cart_cb=self.cart_screen.remove_item_from_cart)
        self.reciept_screen = RecieptScreen(self.cart_screen.cart)
        self.admin_screen = AdminScreen()
        self.tare_screen = TareScreen(shelf_manager=self.shelf_manager)

        # Add screens to the stack with respective indices
        self.stack.addWidget(self.welcome_screen)    # Index 0
        self.stack.addWidget(self.cart_screen)       # Index 1
        self.stack.addWidget(self.reciept_screen)    # Index 2
        self.stack.addWidget(self.admin_screen)      # Index 3
        self.stack.addWidget(self.tare_screen)       # Index 4

        # Connect buttons for navigation (for debugging/development)
        self.cart_screen.show_receipt_signal.connect(lambda: self.show_receipt_screen())
        self.welcome_screen.show_admin_signal.connect(lambda: self.stack.setCurrentIndex(3))
        self.admin_screen.show_welcome_signal.connect(lambda: self.stack.setCurrentIndex(0))
        self.welcome_screen.ui.tapButton.clicked.connect(lambda: self.go_to_cart())
        self.cart_screen.ui.navButton.clicked.connect(lambda: self.stack.setCurrentIndex(0))
        self.admin_screen.ui.tareButton.clicked.connect(lambda: self.stack.setCurrentIndex(4))
        self.reciept_screen.go_home_signal.connect(lambda: self.stack.setCurrentIndex(0))
        self.stack.currentChanged.connect(self.on_screen_change_cb)
        self.tare_screen.show_admin_signal.connect(lambda: self.stack.setCurrentIndex(3))
        # Navigate to the welcome screen, triggering the NFC callback
        self.stack.setCurrentIndex(1)
        self.stack.setCurrentIndex(0)

    def show_receipt_screen(self):
        self.stack.setCurrentIndex(2)
        self.reciept_screen.run_timer()

    def go_to_cart(self):
        mqtt.open_doors()
        widget.stack.setCurrentIndex(1)

    def on_screen_change_cb(self, index):
        """
        Callback function for when the screen changes

        Params:
        index: The index of the screen switched to
        """
        if index == 0 and not self.is_nfc_active:
            # Switched to the welcome screen
            self.start_nfc_scan()
    
    def start_nfc_scan(self):
        """Start NFC scanning if it's not active"""
        self.is_nfc_active = True
        print("Starting NFC scan...")
        self.nfc_thread = nfc.NFCListenerThread()
        self.nfc_thread.token_detected.connect(self.process_nfc_token)
        self.nfc_thread.start()

    def process_nfc_token(self, token):
        """Process the NFC token after it's detected"""
        if self.stack.currentIndex() == 0:  # Only process if on the welcome screen
            user = database.get_user(user_token=token)
            if user:
                print(f"User {user} found for token {token}")
                self.cart_screen.set_user(user.name)
                self.go_to_cart()  # Switch to the cart screen
            else:
                print("User not found for scanned token.")

            self.stop_nfc_scan()
            # Stop NFC thread after processing the token
    
    def stop_nfc_scan(self):    
        """Stop the NFC scan and clean up the thread."""
        if self.nfc_thread:
            print("Stopping NFC thread...")
            self.nfc_thread.stop()  # Stop the scanning loop
            self.nfc_thread.deleteLater()  # Delete the thread safely
            self.nfc_thread = None  # Clear the thread reference
            self.is_nfc_active = False  # Reset the NFC active flag
        else:
            print("No NFC thread to stop.")

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
