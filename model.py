###############################################################################
#
# File: model.py
#
# Purpose: Contains all model logic
#
###############################################################################
from typing import List


class CartItem:

    name: str
    price: float
    quantity: int

    def __init__(self, name, price, quantity=1):
        self.name = name
        self.price = price
        self.quantity = quantity



class ShoppingCart:

    items: List[CartItem]

    def __init__(self):
        self.items = list()


    def add_item(self, item: CartItem):
        pass


