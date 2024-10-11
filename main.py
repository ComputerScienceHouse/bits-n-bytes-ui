# This Python file uses the following encoding: utf-8
import sys

from PySide6.QtWidgets import QApplication, QMainWindow, QStackedWidget
from screens.cart_screen import CartScreen
from screens.welcome_screen import WelcomeScreen
# Important:
# You need to run the following command to generate the ui_form.py file
#     pyside6-uic form.ui -o ui_form.py, or
#     pyside2-uic form.ui -o ui_form.py

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.setFixedSize(1024, 600);
        self.initUI()

    def initUI(self):
        # Create a QStackedWidget to manage different screens
        self.stack = QStackedWidget()
        self.setCentralWidget(self.stack)

        # Create Cart add Welcome screen
        self.welcome_screen = WelcomeScreen()
        self.cart_screen = CartScreen()

        self.stack.addWidget(self.welcome_screen)    # Index 0
        self.stack.addWidget(self.cart_screen)       # Index 1

        # Connect buttons to navigate between screens
        self.welcome_screen.ui.pushButton.clicked.connect(lambda: self.stack.setCurrentIndex(1))
        self.cart_screen.ui.pushButton.clicked.connect(lambda: self.stack.setCurrentIndex(0))



if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec())
