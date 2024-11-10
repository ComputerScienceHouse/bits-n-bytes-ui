from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize
from .ui_admin import Ui_Admin
import resources_rc
import mqtt


class AdminScreen(QMainWindow):
    def __init__(self, parent=None):
        super(AdminScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Admin()
        self.ui.setupUi(self)

        self.ui.openDoorButton.clicked.connect(lambda: mqtt.open_doors())
        # TODO add hatch button functionality
        #self.ui.openHatchButton

