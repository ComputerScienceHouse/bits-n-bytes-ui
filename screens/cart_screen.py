from PySide6.QtWidgets import QMainWindow, QTableWidgetItem
from .ui_cart import Ui_Cart  # Import the generated UI class
from models import Cart

class CartScreen(QMainWindow):
    def __init__(self, parent=None):
        super(CartScreen, self).__init__(parent)
        self.ui = Ui_Cart()
        self.ui.setupUi(self)
        self.cart = Cart()
        # Example button logic for Cart screen
        # self.ui.pushButton.clicked.connect(self.on_add_to_cart)

    def on_add_to_cart(self, item):
        self.cart.add(item)
        self.update()
        # Add functionality when the button is clicked
        print("Item added to cart!")

    def on_remove_from_cart(self, item):
        self.cart.remove(item)
        self.update()

    def update(self):
        self.ui.cartTableWidget.setRowCount(0)
         # Update the cart table with the current items in the cart
        for row, (item, quantity) in enumerate(self.cart.items.items()):
            if quantity > 0:
                self.ui.cartTableWidget.insertRow(row)
                self.ui.cartTableWidget.setItem(row, 0, QTableWidgetItem(item.name))
                self.ui.cartTableWidget.setItem(row, 1, QTableWidgetItem(str(quantity)))
                self.ui.cartTableWidget.setItem(row, 2, QTableWidgetItem(f"${item.price:.2f}"))
                self.ui.cartTableWidget.setItem(row, 3, QTableWidgetItem(f"${item.price * quantity:.2f}"))

        # Update the subtotal label
        subtotal = self.cart.get_subtotal()
        self.ui.subtotalLabel.setText(f"Subtotal: ${subtotal:.2f}")