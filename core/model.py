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
from core.data_classes import *
import core.database as db
from core.controller.cart import CartController

WEIGHT_UNIT = 'g'


class Model:

    _cart: Cart
    _enable_cart_update: bool
    _current_user: User | None
    _shelf_manager: ShelfManager
    _cart_controller: CartController

    def __init__(self, cart_controller: CartController):
        db.get_items()
        self._current_user = None
        self._cart = Cart()

        self._current_user = User(-1, 'Bilson McDade', '', 999.99, 'IMAGINE25', '', '')
        self._cart_controller = cart_controller
        self._shelf_manager = ShelfManager(add_cart_item_cb=self.add_item_to_cart_cb, remove_cart_item_cb=self.remove_item_from_cart_cb)

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


    def add_item_to_cart_cb(self, item: Item) -> None:
        print("added to cart")
        self._cart.add_item(item)
        self._cart_controller.addItem(item)


    def remove_item_from_cart_cb(self, item: Item) -> None:
        print("removed from cart")
        self._cart.remove_item(item)
        self._cart_controller.removeItem(item)

