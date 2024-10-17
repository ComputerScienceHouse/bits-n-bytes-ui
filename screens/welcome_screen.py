from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize
from .ui_welcome import Ui_Welcome  
import resources_rc  

class WelcomeScreen(QMainWindow):
    def __init__(self, parent=None):
        super(WelcomeScreen, self).__init__(parent)
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



    def on_start(self):
        # Add functionality when the button is clicked
        print("Welcome button clicked!")
