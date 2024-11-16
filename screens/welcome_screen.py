from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize, Signal
from .ui_welcome import Ui_Welcome  
from screens.admin_screen import AdminScreen
import resources_rc

ADMIN_TAP_DEAD_ZONE = 250
ADMIN_TARGET_SEQUENCE = [2, 1, 3, 4]

class WelcomeScreen(QMainWindow):

    admin_sequence_pressed = []
    show_admin_signal = Signal()

    def __init__(self, parent=None):
        super(WelcomeScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Welcome()
        self.ui.setupUi(self)

        pixmap = QPixmap(u":/resources/logo")
        pixmap = pixmap.scaled(300, 300, Qt.KeepAspectRatio, Qt.SmoothTransformation)
        self.ui.bitsnbyteslogo.setPixmap(pixmap)

        pixmap = QPixmap(u":/resources/info")
        button_size = self.ui.infoButton.size()
        scaled_pixmap = pixmap.scaled(button_size.width(), button_size.height(), Qt.KeepAspectRatio, Qt.SmoothTransformation)
        self.ui.infoButton.setIcon(QIcon(scaled_pixmap))
        self.ui.infoButton.setIconSize(button_size)
        self.ui.tapButton.setIcon(QIcon(u":/resources/tap"))
        self.ui.tapButton.setIconSize(QSize(64, 64))

    def on_show_admin(self):
        self.show_admin_signal.emit()

    def is_sequence_completed(self, tap_location_num: int) -> bool:
        """
        Check if the sequence for accessing the admin page is completed
        Args:
            tap_location_num: The number of the location

        Returns: Whether the sequence is completed

        """
        # Check if this is the next step in the sequence
        if tap_location_num == ADMIN_TARGET_SEQUENCE[len(self.admin_sequence_pressed)]:
            # It is the next step, add this step to the list of completed steps
            self.admin_sequence_pressed.append(tap_location_num)
            # Check if the sequence is completed
            if len(self.admin_sequence_pressed) == len(ADMIN_TARGET_SEQUENCE):
                # It is completed so clear the sequence and signal that it's completed
                self.admin_sequence_pressed.clear()
                return True
            else:
                return False
        else:
            # It's not the next step, reset the sequence
            self.admin_sequence_pressed.clear()
            return False


    def mousePressEvent(self, event):
        click_x, click_y = event.position().x(), event.position().y()
        width, height = self.size().width(), self.size().height()

        # Calculate dynamic dead zones
        dead_zone_width = width * 0.50
        dead_zone_height = height * 0.50

        if click_x < dead_zone_width:
            if click_y < dead_zone_height:
                location_id = 1  # Top-left
            elif click_y > height - dead_zone_height:
                location_id = 3  # Bottom-left
            else:
                self.admin_sequence_pressed.clear()
                return
        elif click_x > width - dead_zone_width:
            if click_y < dead_zone_height:
                location_id = 2  # Top-right
            elif click_y > height - dead_zone_height:
                location_id = 4  # Bottom-right
            else:
                self.admin_sequence_pressed.clear()
                return
        else:
            self.admin_sequence_pressed.clear()
            return

        if self.is_sequence_completed(location_id):
            self.on_show_admin()

    

    def on_start(self):
        # Add functionality when the button is clicked
        print("Welcome button clicked!")

    def show_admin(self):
        # Create an instance of the receipt screen and pass the cart
        self.admin_screen = AdminScreen()
        self.admin_screen.show()