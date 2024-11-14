from typing import List, Any
from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex

WEIGHT_UNIT = "g"
CERTAINTY_CONSTANT = 3  # number of update iterations before an item is classified as "added" or "removed"

class Item:
    def __init__(
            self, item_id, name, upc, price, units, avg_weight, std_weight,
            thumbnail_url, vision_class
    ):
        self.item_id = item_id
        self.name = name
        self.upc = upc
        self.price = price
        self.units = units
        self.avg_weight = avg_weight
        self.std_weight = std_weight
        self.thumbnail_url = thumbnail_url
        self.vision_class = vision_class

    def __str__(self):
        return (f'Item[{self.item_id},{self.name},UPC:{self.upc},${self.price},'
                f'{self.units}units,{self.avg_weight}{WEIGHT_UNIT},'
                f'{self.std_weight}{WEIGHT_UNIT},{self.thumbnail_url},'
                f'{self.vision_class}]')


    def __eq__(self, other):
        if isinstance(other, Item):
            return self.item_id == other.item_id
        else:
            return False


    def __hash__(self):
        return hash(self.item_id)


    
class User:
    def __init__(self, uid, name, token, balance, payment_type, email, phone):
        self.uid = uid
        self.name = name
        self.token = token
        self.balance = balance
        self.payment_type = payment_type
        self.email = email
        self.phone = phone

class Slot:

    def __init__(self, item: Item):
        """
        Create a Slot
        :param item: Item stocked in this slot
        """
        return None

    def update(self, raw_weight_value) -> int:
        """
        Update this slot object with its newly received weight value
        :param raw_weight_value: Raw weight value
        :return:
        """
        
        return None

class Shelf:

    slots: List[Slot]

    def __init__(self, items: List[Item]):
        """
        Create a new shelf
        :param items: List of items in this shelf, one per slot
        """
        self.slots = list()

    def update(self, raw_weights: List[float]):
        """
        Update all slots in this shelf with the raw weights
        :param raw_weights:
        :return: List of tuples (item, quantity_adjust)
        """
        result = list()
        # iterate through all weight values
        for i in range(len(raw_weights)):
            # Make sure a slot corresponds to this weight
            if i < len(self.slots):
                # Update the weight
                if self.items[i] is not None:
                    quantity_adjust = self.slots[i].update(raw_weights[i])
                    if quantity_adjust != 0:
                        result.append((self.items[i], quantity_adjust))

        return result

class Cart:
    def __init__(self):
        self.items = {}

    def add(self, item: Item):
        if item in self.items:
            self.items[item] += 1
        else:
            self.items[item] = 1

    def remove(self, item: Item):
        if item in self.items:
            self.items[item] -= 1

    def get_subtotal(self):
        subtotal = 0.0

        for item, quantity in self.items.items():
            subtotal += item.price * quantity

        return subtotal


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

    def clear(self):
        self.beginResetModel()
        self.cart.items.clear()
        self.endResetModel()