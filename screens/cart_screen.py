from PySide6.QtWidgets import QMainWindow
from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex
from .ui_cart import Ui_Cart  # Import the generated UI class
from models import Cart
from database import MOCK_ITEMS
import array

class ItemListModel(QAbstractListModel):
    def __init__(self, cart: Cart, parent=None):
        super().__init__(parent)
        self.cart = cart

    def rowCount(self, parent=QModelIndex()):
        return len(self.cart.items)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or not (0 <= index.row() < len(self.cart.items)):
            return None  # Return None for invalid index

        item_list = list(self.cart.items.keys())
        if not item_list:
            return None  # No items in the cart, return None

        item = item_list[index.row()]
        quantity = self.cart.items[item]

        if role == Qt.DisplayRole:
            return f"{item.name} (x{quantity})"
        elif role == Qt.ToolTipRole:
            return f"Price: ${item.price:.2f} each"  # Access price directly from the Item object

        return None

    def addItem(self, item):
        if item not in self.cart.items:
            # Insert a new row if the item is not already in the cart
            position = len(self.cart.items)
            self.beginInsertRows(QModelIndex(), position, position)
            self.cart.add(item)
            self.endInsertRows()
        else:
            # Just update the existing item's quantity
            position = list(self.cart.items.keys()).index(item)
            self.cart.add(item)
            top_left = self.index(position, 0)
            self.dataChanged.emit(top_left, top_left, [Qt.DisplayRole])

    def removeItem(self, item):
        if item in self.cart.items:
            position = list(self.cart.items.keys()).index(item)
            self.cart.remove(item)
            if self.cart.items[item] <= 0:
                # Remove the row if quantity reaches 0
                self.beginRemoveRows(QModelIndex(), position, position)
                del self.cart.items[item]
                self.endRemoveRows()
            else:
                # Just update the quantity
                top_left = self.index(position, 0)
                self.dataChanged.emit(top_left, top_left, [Qt.DisplayRole])

    # def flags(self, index):
    #     if not index.isValid():
    #         return Qt.NoItemFlags
    #     return Qt.ItemIsEnabled | Qt.ItemIsSelectable


class CartScreen(QMainWindow):
    def __init__(self, parent=None):
        super(CartScreen, self).__init__(parent)
        self.ui = Ui_Cart()
        self.ui.setupUi(self)
        self.cart = Cart()

        # Initialize an index for the next item and set the first item
        self.model = ItemListModel(self.cart)
        self.ui.itemList.setModel(self.model)

        # Connect the button click to the method
        self.ui.addButton.clicked.connect(self.on_add_to_cart)
        # intialize subtotal
        self.update_subtotal()

    def on_add_to_cart(self): 
        # TODO: once ESP32 stuff is implemented bascially refer to the index of said item here
        id = 3
        item = MOCK_ITEMS.get(id)
        if item:
            self.model.addItem(item)
            self.update_subtotal()

    def on_remove_from_cart(self, item):
       self.model.removeItem(item)
       self.update_subtotal()

    def update_subtotal(self):
        # Update the subtotal label
        subtotal = self.cart.get_subtotal()
        self.ui.subtotalLabel.setText(f"Subtotal: ${subtotal:.2f}")