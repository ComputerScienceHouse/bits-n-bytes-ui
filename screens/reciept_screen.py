from PySide6.QtWidgets import QMainWindow
from .ui_reciept import Ui_Reciept
from PySide6.QtCore import Qt
from models import Cart, ItemListModel

class RecieptScreen(QMainWindow):
    def __init__(self, cart, parent=None):
        super(RecieptScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Reciept()
        self.ui.setupUi(self)
        self.cart = cart   

        self.model = ItemListModel(cart)
        self.ui.itemList.setModel(self.model)

        self.ui.textButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(1))
        self.ui.emailButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(2))

        self.display_cart_items()

    def display_cart_items(self):
        print("Reciept items:", self.cart.items)  # Debugging line
        self.model.clear()  # Clear existing items
        for item in self.cart.items:
            print(item)
            # Add each item as a new list entry
            self.model.addItem(item)

        subtotal = self.cart.get_subtotal()
        print(f"Subtotal: {subtotal}")  # Debugging
        self.ui.subtotalLabel.setText(f"Subtotal: ${subtotal:.2f}")