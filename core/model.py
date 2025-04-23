###############################################################################
#
# File: model.py
#
# Purpose: Contains all model logic
#
###############################################################################
import copy
from typing import List, Set, Dict
from core.services.shelf_manager import ShelfManager

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



class Model:

    _cart: Cart
    _enable_cart_update: bool
    _current_user: User | None
    _shelf_manager: ShelfManager

    def __init__(self):
        self._current_user = None
        self._cart = Cart()

        # Add some sample items for testing
        self._cart.add_item(Item(1, "Sour Patch Kids", 0, 2.50, 10, 200, 10, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(2, "Brownie Brittle", 0, 2.50, 5, 200, 10, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(3, "Little Bites Chocolate", 0, 2.10, 100, 47, 10, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(4, "Little Bites Party", 0, 2.10, 50, 47, 10, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(5, "Skittles Gummies", 0, 2.40, 75, 164.4, 15, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(6, "Swedish Fish Mini Tropical", 0, 3.50, 120, 226, 10, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(7, "Swedish Fish Original", 0, 19.99, 100, 141, 10, "placeholder.png", 'sour_patch'))
        self._cart.add_item(Item(8, "Welch's Fruit Snacks", 0, 39.99, 40, 142, 14, "placeholder.png", 'sour_patch'))

        self._current_user = User(1, 'Sahil Patel', '', 999.99, 'IMAGINE25', 'sahilpatel@gmail.com', '+11111111111')

        self._shelf_manager = ShelfManager()


    def get_all_items_in_cart(self) -> List[Item]:
        """
        Get all items in the cart.
        Returns: A list of items in the cart.

        """
        return self._cart.get_all_items()


    def clear_cart(self) -> None:
        """
        Clear the cart.
        Returns: None

        """
        self._cart.clear_cart()


    def get_user_name(self) -> str | None:
        """
        Get the name of the current user.
        Returns: String name if a user is signed in, None otherwise.

        """
        if self._current_user is None:
            return None
        else:
            return self._current_user.name


    def get_user_email(self) -> str | None:
        """
        Get the email of the current user.
        :return: String email if a user is signed in, None otherwise.
        """
        if self._current_user is None:
            return None
        else:
            return self._current_user.email


    def get_user_phone_number(self) -> str | None:
        """
        Get the phone number of the current user.
        :return: String phone number if a user is signed in, None otherwise.
        """
        if self._current_user is None:
            return None
        else:
            return self._current_user.phone


    def get_payment_method(self) -> str | None:
        """
        Gets the payment method to use.
        :return:
        """
        # TODO implement getting the payment method for this user.
        # For Imagine, this suffices.
        return 'IMAGINE25'


    def set_user_name(self, name: str) -> None:
        """
        Set the name of this user.
        :param name: New name.
        :return: None.
        """
        if self._current_user is not None:
            self._current_user.name = name
            # TODO update database


    def set_user_email(self, new_email: str) -> None:
        """
        Set the email for this user.
        :param new_email: New email.
        :return: None.
        """
        if self._current_user is not None:
            self._current_user.email = new_email
            # TODO update database


    def set_user_phone_number(self, new_phone_number: str) -> None:
        """
        Set the phone number for this user.
        :param new_phone_number: The New phone number.
        :return: None.
        """
        if self._current_user is not None:
            self._current_user.phone = new_phone_number
            # TODO update database

