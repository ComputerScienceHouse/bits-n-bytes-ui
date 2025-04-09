###############################################################################
#
# File: shelf_manager.py
#
# Purpose: Handle all interaction with shelves. The 'main_loop' function should
# be placed in a separate thread and provides watchdog functionality for
# shelves.
#
###############################################################################
import time
from threading import Lock
from model import Item
from typing import List
from scipy.stats import norm

class Slot:

    _items: List[Item]

    def __init__(self):
        self._items = list()


    def add_item(self, item: Item) -> None:
        """
        Add an item to this slot.
        :param item: The Item, where the quantity field is the number to be added to this slot.
        :return: None.
        """
        if item in self._items:
            # Add quantity to existing item object
            item_index = self._items.index(item)
            self._items[item_index] += item.quantity
        else:
            # Add new item object
            self._items.append(item)


    def remove_item(self, item: Item) -> None:
        """
        Remove an item from this slot.
        :param item: The Item, where the quantity field is the number to be removed from this slot.
        :return: None.
        """
        if item in self._items:
            # Item exists, calculate how much to remove
            item_index = self._items.index(item)
            old_quantity = self._items[item_index].quantity
            new_quantity = old_quantity - item.quantity

            if new_quantity <= 0:
                # Remove item completely
                del self._items[item_index]
            else:
                # Decrease quantity
                self._items[item_index].quantity = new_quantity
        else:
            # Item does not exist, don't remove anything
            pass


    def predict_most_likely_item(self, weight_delta: float) -> (Item, float):
        """
        Given a change in weight, predict the most likely item that could have
        been added/removed from this scale.
        :param weight_delta: Float weight change in grams
        :return: Tuple: Item, Float; The item that is most likely and the probability of
        it being that item.
        """
        # TODO support multiple items being removed at once somehow

        # Store the most probably item
        max_probability = 0
        most_probable_item: Item | None = None
        # Iterate through all possible items
        for item in self._items:
            # Calculate probability using probability density function on bell curve
            probability = norm.pdf(
                weight_delta,
                loc=item.avg_weight,
                scale=item.std_weight
            )
            # Store most likely item so far
            if probability > max_probability:
                max_probability = probability
                most_probable_item = item
        return most_probable_item, max_probability


class Shelf:

    _mac_address: str
    _last_ping_ms: float
    _num_slots: int

    def __init__(self):
        pass



class ShelfManager:

    _last_loop_ms: float
    _signal_end_lock: Lock
    _signal_end: bool

    def __init__(self):
        # TODO load tare values for shelves
        # TODO implement LOCAL mqtt client to listen to shelves
        # TODO implement REMOTE mqtt client to post shelf info, listen to tare requests
        pass


    def main_loop(self):

        self._last_loop_ms = time.time() * 1000

        while True:
            # Break out of loop if flag was set
            with self._signal_end_lock:
                if self._signal_end:
                    break

            # TODO add shelf watchdog
            # TODO post what shelves are available on an endpoint somewhere


