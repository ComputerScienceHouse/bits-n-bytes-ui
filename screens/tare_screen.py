from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize, Signal, QCoreApplication
from .ui_admin import Ui_Admin
import resources_rc
import mqtt
from .ui_tare import Ui_Tare



class TareScreen(QMainWindow):
    
     def __init__(self, parent=None):
        super(TareScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Tare()
        self.ui.setupUi(self)