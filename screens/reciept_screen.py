from PySide6.QtWidgets import QMainWindow
from .ui_reciept import Ui_Reciept
from PySide6.QtCore import Qt
from models import Cart

class RecieptScreen(QMainWindow):
    def __init__(self, cart: Cart, parent=None):
        super(RecieptScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Reciept()
        self.ui.setupUi(self)
        self.cart = cart
        
        self.ui.textButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(1))
        self.ui.emailButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(2))

        self.display_cart_items()

    def display_cart_items(self):
        print("Cart items:", self.cart.items)  # Debugging line
        self.ui.itemList.clear()  # Clear existing items
        for item, quantity in self.cart.items.items():
            # Add each item as a new list entry
            self.ui.itemList.addItem(f"{item.name} (x{quantity}) - ${item.price * quantity:.2f}")

        subtotal = self.cart.get_subtotal()
        self.ui.subtotalText.setText(f"${subtotal:.2f}")