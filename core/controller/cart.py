import os
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot
from core.model import Cart, ShelfManager, Item

class CartController(QAbstractListModel):
    def __init__(self, cart: Cart):
        super().__init__()
        self.cart = cart
        self._image_cache = {}  # Cache for image paths

    def roleNames(self):
        return {
            Qt.DisplayRole: b"display",
            Qt.UserRole + 1: b"name",
            Qt.UserRole + 2: b"price",
            Qt.UserRole + 3: b"quantity",
            Qt.UserRole + 4: b"image"  # New role for image path
        }
    
    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self.cart.get_all_items()):
            return None
            
        item = self.cart.get_all_items()[index.row()]
        quantity = self.cart.get_quantity(item)
        
        if role == Qt.DisplayRole:
            return f"{item.name} (x{quantity})"
        elif role == Qt.UserRole + 1:  # name
            return item.name
        elif role == Qt.UserRole + 2:  # price
            return item.price
        elif role == Qt.UserRole + 3:  # quantity
            return quantity
        elif role == Qt.UserRole + 4:  # image
            return self._get_image_path(item)
        return None
    
    def _get_image_path(self, item):
        # Get absolute path to images folder
        base_path = os.path.abspath(os.path.join(
            os.path.dirname(__file__),  # Current file's directory (models/)
            "..",  # Move up to project root
            "images"  # Images folder
        ))
        
        # Default placeholder path
        placeholder = os.path.join(base_path, "placeholder.png")
        
        # Check if item has valid image
        if not hasattr(item, "image_path"):
            return placeholder  # Returns: /Users/.../bits-n-bytes-ui/images/placeholder.png
        
        # Build item's image path
        item_image = os.path.join(base_path, item.image_path)
        return item_image if os.path.exists(item_image) else placeholder

    def rowCount(self, parent=QModelIndex()):
        return len(self.cart.get_all_items())

    def addItem(self, item):
        if item not in self.cart.get_all_items():
            # Insert a new row if the item is not already in the cart
            print(item.thumbnail_url)
            position = len(self.cart)
            self.beginInsertRows(QModelIndex(), position, position)
            self.cart.add_item(item)
            self.endInsertRows()
        else:
            # Just update the existing item's quantity
            position = self.cart.get_index(item)
            self.cart.add_items(item)
            top_left = self.index(position, 0)
            self.dataChanged.emit(top_left, top_left, [Qt.DisplayRole])

    def removeItem(self, item):
        if item in self.cart.items:
            position = list(self.cart.items.keys()).index(item)
            self.cart.remove_item(item)
            if self.cart.get_quantity(item) <= 0:
                # Remove the row if quantity reaches 0
                self.beginRemoveRows(QModelIndex(), position, position)
                del self.cart.items[item]
                self.endRemoveRows()
            else:
                # Just update the quantity
                top_left = self.index(position, 0)
                self.dataChanged.emit(top_left, top_left, [Qt.DisplayRole])

    def clear(self):
        self.beginResetModel()
        self.cart.clear_cart()
        self.endResetModel()

    @Slot(result=float)
    def getSubtotal(self):
        return self.cart.get_subtotal()
    
    def add_item_to_cart_cb(self, item: Item) -> None:
        print("added to cart")
        self.addItem(item)

    def remove_item_from_cart_cb(self, item: Item) -> None:
        print("removed from cart")
        self.removeItem(item)
