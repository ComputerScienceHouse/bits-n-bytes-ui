from typing import List, Dict
import copy

WEIGHT_UNIT = 'g'

class Item:

    def __init__(
            self, item_id, name, upc, price, quantity, avg_weight, std_weight,
            thumbnail_url, vision_class
    ):
        self.item_id = item_id
        self.name = name
        self.upc = upc
        self.price = price
        self.quantity = quantity
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


class NFC:
    def __init__(self, id, assigned_user, type):
        self.uid = id
        self.assigned_user = assigned_user
        self.type = type

    def __str__(self):
        return (f'NFC[ID: {self.id}, UserID: {self.assigned_user}, Type: {self.type}]')


class Cart:
    _items: List[Item]

    def __init__(self):
        self._items = list()

    def add_item(self, item: Item) -> None:
        """
        Add item to the cart.
        :param item: The Item to add. Note that the quantity field must represent the quantity to be added.
        :return: None
        """
        # Check if this item is in the cart already
        if item in self._items:
            # It's in the cart, increment the existing instance's quantity
            index = self._items.index(item)
            self._items[index].quantity += item.quantity
        else:
            # It's not in the cart, add it!
            # This uses a copy of item to prevent modifying the object passed into this function
            self._items.append(copy.deepcopy(item))

    def remove_item(self, item: Item) -> None:
        """
        Remove item from the cart.
        :param item: The Item to add. Note that the quantity field must represent the quantity to be removed.
        If the list has 5 of item 'Foo' and you remove item 'Foo' with quantity 3, the cart will now
        contain quantity 2 of 'Foo'.
        :return: None
        """
        # Check if the item is even in the cart
        if item in self._items:
            index = self._items.index(item)
            # Calculate the new quantity for the cart
            new_quantity = self._items[index].quantity - item.quantity
            if new_quantity > 0:
                # If the quantity is positive, modify it
                self._items[index].quantity = new_quantity
            else:
                # If the quantity is 0 or negative, remove the item from the cart
                self._items.remove(item)

    def get_index(self, item: Item) -> int:
        '''
        Get index for specific item in the cart
        :return: A integer for the index of item
        '''
        if item in self._items:
            return self._items.index(item)
        return None

    def get_quantity(self, item: Item) -> int:
        '''
        Get quantity for specific item in the cart
        :return: A integer for the quantity of item
        '''
        if (index := self.get_index(item)) is not None:
            return self._items[index].quantity
        else:
            return None

    def get_all_items(self) -> List[Item]:
        """
        Get all items in the cart
        :return: A list of items in the cart
        """
        return self._items

    def clear_cart(self) -> None:
        """
        Clear all items from the cart.
        :return: None
        """
        self._items.clear()

    def get_subtotal(self) -> float:
        """
        Get the subtotal of the cart.
        :return: Float subtotal.
        """
        subtotal = 0.0
        for item in self._items:
            subtotal += (item.price * item.quantity)
        return subtotal