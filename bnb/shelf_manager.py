###############################################################################
#
# File: shelf_manager.py
#
# Purpose: Handle all interaction with shelves. The 'main_loop' function should
# be placed in a separate thread and provides watchdog functionality for
# shelves.
#
###############################################################################
import threading
import time
from json import JSONDecodeError
from pickle import UnpicklingError
from threading import Lock
from typing import List, Dict
from scipy.stats import norm
from pathlib import Path
import json
import pickle
from filelock import FileLock
from os import environ

SHELF_DATA_DIR = Path(Path.cwd() / 'tmp')
SHELF_DISCONNECT_TIMEOUT_MS = 5000
DEFAULT_NUM_SLOTS_PER_SHELF = 4
USE_MOCK_DATA = environ.get('USE_MOCK_DATA', False)

# TODO figure out how to import this from model without getting an import error
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

MOCK_ITEM = Item(0, "Sour Patch Kids", 1, 3.5, 5, 266, 15, '', 'sour_patch')

class Slot:

    _items: List[Item]

    def __init__(self, items: List[Item] | None = None):
        """
        Create a new slot.
        :param items: Optional list of items that are already on the shelf.
        """
        if self._items is None:
            self._items = list()
        else:
            self._items = items


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
    _slots: List[Slot]

    def __init__(self, mac_address: str, num_slots: int):
        # Set all members
        self._last_ping_ms = time.time() * 1000
        self._mac_address = mac_address
        self._num_slots = num_slots

        # Create all the slots this shelf has
        self._slots = list()
        for i in range(self._num_slots):
            self._slots.append(Slot())


    def update_last_ping_time(self, time_ms):
        """
        Update the last time this shelf was pinged.
        :param time_ms: Ms of ping
        :return:
        """
        self._last_ping_ms = time_ms


    def get_last_ping_time(self) -> float:
        """
        Get the time this shelf was last pinged.
        :return: Time in ms
        """
        return self._last_ping_ms


    def get_mac_address(self) -> str:
        """
        Get the mac address of this shelf
        :return:
        """
        return self._mac_address



class ShelfManager:

    _last_loop_ms: float

    _signal_end_lock: Lock
    _signal_end: bool

    _active_shelves_lock: Lock
    _active_shelves: Dict[str, Shelf]

    # TODO implement shelf data file locks
    _shelf_data_locks: Dict[str, FileLock]

    def __init__(self, shelf_data_dir: Path = SHELF_DATA_DIR):

        # Create shelf data directory if it doesn't exist
        self._shelf_data_dir = shelf_data_dir
        self._shelf_data_dir.mkdir(parents=True, exist_ok=True)

        # Instantiate active shelves
        self._active_shelves_lock = Lock()
        with self._active_shelves_lock:
            self._active_shelves = dict()

            # Populate with mock data if environment variables are configured
            if USE_MOCK_DATA:
                self._active_shelves = {
                    "00:00:00:00:00:01": Shelf("00:00:00:00:00:01", 4),
                    "00:00:00:00:00:02": Shelf("00:00:00:00:00:02", 4),
                    "00:00:00:00:00:03": Shelf("00:00:00:00:00:03", 4)
                }


    def _load_shelf_data(self, mac_address: str) -> Shelf | None:
        """
        Load data for a shelf
        :param mac_address: MAC address of the shelf to load
        :return: A Shelf object if the data was loaded successfully, None otherwise.
        """
        # Create path
        shelf_data_path = Path(self._shelf_data_dir / f"{mac_address}.json")
        # Open it, if it exists
        if shelf_data_path.exists():
            with open(shelf_data_path, 'r') as file:
                try:
                    json_data = json.load(file)
                except JSONDecodeError:
                    # Print error, jump to next file
                    print(f"Shelf Manager: Error loading shelf data from '{shelf_data_path}': Invalid JSON format'.")
                    return None
                # Check that expected data is in JSON
                if 'macAddress' not in json_data or 'pickle' not in json_data:
                    print(f"Shelf Manager: Error: Invalid shelf JSON in '{shelf_data_path}'.")
                    return None
                # Load shelf object from the json
                try:
                    shelf_obj = pickle.loads(json_data['pickle'])
                except UnpicklingError:
                    print(f"Shelf Manager: Error: Unpickling file '{shelf_data_path}'.")
                    return None
                # Return object
                return shelf_obj
        else:
            return None


    def _save_shelf_data(self, shelf: Shelf) -> None:
        """
        Save data for a shelf.
        :param shelf: Shelf to save.
        :return: None.
        """
        # Get path for the file
        shelf_data_path = Path(self._shelf_data_dir / f"{shelf.get_mac_address()}.json")
        # Write JSOn data to file
        with open(shelf_data_path, 'w') as file:
            json_data = {
                "macAddress": shelf.get_mac_address(),
                "pickle": pickle.dumps(shelf)
            }
            json.dump(json_data, file)


    def stop_loop(self) -> None:
        """
        Stop this shelf manager's main loop.
        :return: None.
        """
        with self._signal_end_lock:
            self._signal_end = True


    def start_loop(self) -> None:
        """
        Start this shelf manager's main loop. This is a non-blocking call, because it spawns
        a new thread for the shelf manager to run in.
        :return: None.
        """
        thread = threading.Thread(target=self._main_loop)
        thread.start()


    def get_all_shelves(self) -> List[Shelf]:
        """
        Get a list of all shelves that are actively connected.
        :return: A list of shelves
        """
        # Compile a list of all shelves that are actively connected
        all_shelves = list()
        with self._active_shelves_lock:
            # Iterate through al shelves
            for mac_address in self._active_shelves:
                # Add each shelf to the list
                shelf_obj = self._active_shelves[mac_address]
                all_shelves.append(shelf_obj)
        return all_shelves


    def _shelf_data_received(self, message: str):
        """
        Callback function for when shelf data is received. This is just to keep shelves alive,
        because a separate, external model converts the weight data to add/remove from shelves
        and sends those back to the shelf manager.
        :return:
        """

        msg_received_ms = time.time() * 1000

        # Convert message to JSON
        try:
            json_data = json.loads(message)
        except JSONDecodeError:
            print("Shelf Manager: Error: Unable to decode shelf data message as JSON.")
            return

        # Get mac address from shelf
        mac_address = json_data['id']

        # Update shelves with new data
        with self._active_shelves_lock:
            # Check if this shelf is active
            if mac_address in self._active_shelves:
                # Update active shelf last heard time
                self._active_shelves[mac_address].update_last_ping_time(msg_received_ms)
                # TODO if item count changed, update the data file
            else:
                # Shelf is not active, see if any info exists in storage
                shelf_obj = self._load_shelf_data(mac_address)
                if shelf_obj is None:
                    # Shelf not loaded, create a new one
                    shelf_obj = Shelf(mac_address, 4)
                else:
                    # Shelf is loaded
                    pass
                # Add this shelf to active
                self._active_shelves[mac_address] = shelf_obj


    def _main_loop(self):
        """
        Main loop for this shelf manager, can be started by start_thread() and stopped with stop_thread().
        This loop checks whether each shelf is connected, and removes them if they are not.
        :return:
        """

        self._last_loop_ms = time.time() * 1000

        while True:
            current_time_ms = time.time() * 1000
            # Break out of loop if flag was set
            with self._signal_end_lock:
                if self._signal_end:
                    break

            # Shelf watchdog. Remove shelves that haven't sent any data in a certain amount of time.
            for shelf_mac in self._active_shelves:
                shelf_obj = self._active_shelves[shelf_mac]
                if shelf_obj.get_last_ping_time() < current_time_ms - SHELF_DISCONNECT_TIMEOUT_MS:
                    # Shelf has timed out, needs to be removed
                    print(f"Shelf Manager: Shelf '{shelf_mac}' disconnected (timed out).")
                    # Make sure most recent version of this shelf is saved
                    self._save_shelf_data(shelf_obj)
                    # Remove shelf from active shelves
                    del self._active_shelves[shelf_mac]


            # TODO post what shelves are available on an endpoint somewhere

            # Update time
            self._last_loop_ms = current_time_ms

