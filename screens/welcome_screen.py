from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap
from PySide6.QtCore import Qt
from .ui_welcome import Ui_Welcome  
import resources_rc  

class WelcomeScreen(QMainWindow):
    def __init__(self, parent=None):
        super(WelcomeScreen, self).__init__(parent)
        self.ui = Ui_Welcome()
        self.ui.setupUi(self)

        pixmap = QPixmap(u":/resources/logo")
        pixmap = pixmap.scaled(200, 200, Qt.KeepAspectRatio, Qt.SmoothTransformation)
        self.ui.bitsnbyteslogo.setPixmap(pixmap)

    def on_start(self):
        # Add functionality when the button is clicked
        print("Welcome button clicked!")
