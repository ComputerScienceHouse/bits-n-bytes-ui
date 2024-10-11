from PySide6.QtWidgets import QMainWindow
from .ui_welcome import Ui_Welcome  # Import the generated UI class

class WelcomeScreen(QMainWindow):
    def __init__(self, parent=None):
        super(WelcomeScreen, self).__init__(parent)
        self.ui = Ui_Welcome()
        self.ui.setupUi(self)

        # Example button logic for Welcome screen
        # self.ui.pushButton.clicked.connect(self.on_start)

    def on_start(self):
        # Add functionality when the button is clicked
        print("Welcome button clicked!")