from PySide6.QtWidgets import QMainWindow
from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex, Signal
from screens.reciept_screen import RecieptScreen
from .ui_cart import Ui_Cart  # Import the generated UI class
from models import Cart, ItemListModel, Item
from database import MOCK_ITEMS
import array

class CartScreen(QMainWindow):
    show_receipt_signal = Signal()

    def __init__(self, parent=None):
        super(CartScreen, self).__init__(parent)
        self.ui = Ui_Cart()
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui.setupUi(self)
        self.cart = Cart()
        self.user = None 

        # Initialize an index for the next item and set the first item
        self.model = ItemListModel(self.cart)
        self.ui.itemList.setModel(self.model)
    
        self.update_subtotal()

    def add_item_to_cart(self, item: Item) -> None:
        """
        Add an item to the cart
        Args:
            item: The Item to add

        Returns:
            None
        """
        self.model.addItem(item)
        self.update_subtotal()

    def remove_item_from_cart(self, item: Item) -> None:
        """
        Remove an item from the cart
        Args:
            item: The Item to remove

        Returns:
            None

        """
        self.model.removeItem(item)
        self.update_subtotal()

    def clear_cart(self) -> None:
        self.model.clear()
        self.update_subtotal()

    def on_add_to_cart(self): 
        # TODO: once ESP32 stuff is implemented bascially refer to the index of said item here
        id = 3
        item = MOCK_ITEMS.get(id)
        if item:
            self.add_item_to_cart(item)

    def on_remove_from_cart(self, item):
       self.model.removeItem(item)
       self.update_subtotal()

    def update_subtotal(self):
        # Update the subtotal label
        subtotal = self.cart.get_subtotal(self)
        self.ui.subtotalLabel.setText(f"Subtotal: ${subtotal:.2f}")

    def on_show_receipt(self):
        # Create an instance of the receipt screen and pass the cart
        self.show_receipt_signal.emit()
        #self.reciept_screen = RecieptScreen(self.cart)

    def set_user(self, user):
        self.user = user
        print(user)
        if self.user:
            self.ui.nameLabel.setText(f"Welcome, {self.user}")

    def activateScreen(self):
        self.screenActivated.emit()