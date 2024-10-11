from PySide6.QtWidgets import QMainWindow
from .ui_cart import Ui_Cart  # Import the generated UI class

class CartScreen(QMainWindow):
    def __init__(self, parent=None):
        super(CartScreen, self).__init__(parent)
        self.ui = Ui_Cart()
        self.ui.setupUi(self)

        # Example button logic for Cart screen
        # self.ui.pushButton.clicked.connect(self.on_add_to_cart)

    def on_add_to_cart(self):
        # Add functionality when the button is clicked
        print("Item added to cart!")