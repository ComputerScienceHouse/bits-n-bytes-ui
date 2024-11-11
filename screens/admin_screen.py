from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize, Signal, QCoreApplication
from .ui_admin import Ui_Admin
import resources_rc
import mqtt


class AdminScreen(QMainWindow):

    show_welcome_signal = Signal()

    def __init__(self, parent=None):
        super(AdminScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Admin()
        self.ui.setupUi(self)

        self.ui.openDoorButton.clicked.connect(lambda: mqtt.open_doors())
        self.ui.exitButton.clicked.connect(self.on_show_welcome)
        self.ui.exitAppButton.clicked.connect(lambda: QCoreApplication.quit())

        # TODO add hatch button functionality
        #self.ui.openHatchButton

    def on_show_welcome(self):
        self.show_welcome_signal.emit()

