###############################################################################
#
# File: shelf_manager.py
#
# Purpose: Handle all interaction with shelves. The 'main_loop' function should
# be placed in a separate thread and provides watchdog functionality for
# shelves.
#
###############################################################################
import os
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
from bnb.mqtt import MqttClient

SHELF_DATA_DIR = Path(Path.cwd() / 'tmp')
SHELF_DISCONNECT_TIMEOUT_MS = 5000
DEFAULT_NUM_SLOTS_PER_SHELF = 4
LOCAL_MQTT_BROKER_URL = os.environ.get('MQTT_LOCAL_BROKER_URL', None)
REMOTE_MQTT_BROKER_URL = os.environ.get('MQTT_REMOTE_BROKER_URL', None)
USE_MOCK_DATA = True
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
    _current_weight: float
    _previous_weight: float
    _conversion_factor: float

    def __init__(self, items: List[Item] | None = None):
        """
        Create a new slot.
        :param items: Optional list of items that are already on the shelf.
        """
        if items is None:
            self._items = list()
        else:
            self._items = items
        self._current_weight = 0
        self._previous_weight = 0
        self._conversion_factor = 1


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


    def update_weight(self, new_weight: float) -> None:
        """
        Update the current weight reading of this shelf.
        :param new_weight:
        :return:
        """
        self._current_weight = new_weight * self._conversion_factor


    def tare(self, calibration_weight_g: float) -> bool:
        """
        Tare this shelf using a certain calibration weight.
        :param calibration_weight_g: Weight in grams of the calibration weight being used.
        :return:
        """
        if self._previous_weight == self._current_weight:
            # Can't divide by zero, print an error
            print("Shelf Manager: Loaded weight and zero weight are the same, can't compute conversion factor.")
            return False
        else:
            # Calculate conversion factor
            self._conversion_factor = calibration_weight_g / (self._current_weight - self._previous_weight)
            # Update previous weight
            self._previous_weight = self._current_weight
            return True


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


    def get_num_slots(self) -> int:
        """
        Get the number of slots this shelf has.
        :return: Integer.
        """
        return self._num_slots


    def get_all_slots(self) -> List[Slot]:
        """
        Get all slots from this shelf.
        :return: A list of Slot.
        """
        return self._slots


    def tare_slot(self, slot_id: int, calibration_weight_g: float) -> bool:
        """
        Tare a slot.
        :param slot_id: The ID of the slot to tare.
        :param calibration_weight_g: The known calibration weight being used.
        :return: Whether the slot was tared successfully.
        """
        if slot_id < self._num_slots:
            return self._slots[slot_id].tare(calibration_weight_g)
        else:
            return False



class ShelfManager:

    _last_loop_ms: float

    _signal_end_lock: Lock
    _signal_end: bool

    _active_shelves_lock: Lock
    _active_shelves: Dict[str, Shelf]

    _local_mqtt_client: MqttClient | None

    def __init__(self, shelf_data_dir: Path = SHELF_DATA_DIR):

        # Connect to local MQTT broker
        if not (LOCAL_MQTT_BROKER_URL == "None" or LOCAL_MQTT_BROKER_URL == None or LOCAL_MQTT_BROKER_URL == ""):
            self._local_mqtt_client = MqttClient(LOCAL_MQTT_BROKER_URL, 1883)
            self._local_mqtt_client.add_topic('shelf/data', self._shelf_data_received)
            self._local_mqtt_client.start()
        else:
            self._local_mqtt_client = None

        # Connect to remote MQTT broker
        if not (REMOTE_MQTT_BROKER_URL == "None" or REMOTE_MQTT_BROKER_URL == None or REMOTE_MQTT_BROKER_URL == ""):
            self._remote_mqtt_client = MqttClient(REMOTE_MQTT_BROKER_URL, 1883)
            self._remote_mqtt_client.start()
        else:
            self._remote_mqtt_client = None

        # Create shelf data directory if it doesn't exist
        self._shelf_data_dir = shelf_data_dir
        self._shelf_data_dir.mkdir(parents=True, exist_ok=True)

        # Setup signal end system
        self._signal_end_lock = Lock()
        self._signal_end = False

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
        shelf_data_path = Path(self._shelf_data_dir / f"{mac_address}.pickle")
        with FileLock(Path(self._shelf_data_dir / f"{mac_address}.lock")):
            # Open it, if it exists
            if shelf_data_path.exists():
                with open(shelf_data_path, 'rb') as file:
                    try:
                        shelf_obj = pickle.load(file)
                        if not isinstance(shelf_obj, Shelf):
                            print("Shelf Manager: Error: Invalid shelf data in file. Expected Shelf object.")
                            return None
                    except Exception:
                        # Print error, jump to next file
                        print(f"Shelf Manager: Error unpickling file '{shelf_data_path}'.")
                        return None
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
        shelf_data_path = Path(self._shelf_data_dir / f"{shelf.get_mac_address()}.pickle")
        with FileLock(Path(self._shelf_data_dir / f"{shelf.get_mac_address()}.lock")):
            # Open file and dump pickle data
            with open(shelf_data_path, 'wb') as file:
                pickle.dump(shelf, file)


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


    def get_all_shelves(self) -> List[Shelf | None]:
        """
        Get a list of all shelves that are actively connected.
        :return: A list that, in each index, contains either a Shelf or None. The indexes of this list
        represent where the shelf should be on the UI. The UI should have two columns and any number of rows.
        Index 0 and 1 are on the top row, then 2 and 3 on the 2nd row, then 4 and 5... etc.
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


    def tare_slot(self, shelf_id: str, slot_id: int, calibration_weight_g: float) -> bool:
        """
        Tare a slot on a shelf.
        :param shelf_id: The mac address of the shelf.
        :param slot_id: The integer ID of the slot.
        :param calibration_weight_g: The weight of the calibration weight in grams.
        :return: True if successful, False otherwise.
        """
        with self._active_shelves_lock:
            # Check if this shelf exists
            if shelf_id in self._active_shelves:
                shelf_obj = self._active_shelves[shelf_id]
                # Tare the slot
                return shelf_obj.tare_slot(slot_id, calibration_weight_g)

        return False


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
        try:
            mac_address = json_data['id']
        except KeyError:
            print("Shelf Manager: Error: 'id' field not in dictionary")
            return

        # Update shelves with new data
        with self._active_shelves_lock:
            # Check if this shelf is active
            if mac_address in self._active_shelves:
                # TODO if item count changed, update the data file
                shelf_obj = self._active_shelves[mac_address]
            else:
                print(f"Shelf Manager: New shelf connected with ID '{mac_address}'")
                # Shelf is not active, see if any info exists in storage
                shelf_obj = self._load_shelf_data(mac_address)
                if shelf_obj is None:
                    # Shelf not loaded, create a new one
                    shelf_obj = Shelf(mac_address, 4)
                else:
                    # Shelf is loaded
                    print("\tSuccessfully loaded shelf data from file.")
                    pass
                # Add this shelf to active
                self._active_shelves[mac_address] = shelf_obj
            # Update the last time shit shelf pinged
            shelf_obj.update_last_ping_time(msg_received_ms)
            try:
                data = json_data['data']
            except KeyError:
                print("Shelf Manager: Error: 'data' field not in dictionary")
                return
            # Update the weight values for all slots
            all_slots = shelf_obj.get_all_slots()
            for i, raw_weight in enumerate(data):
                if isinstance(raw_weight, float):
                    if i < len(all_slots):
                        all_slots[i].update_weight(raw_weight)


    def _main_loop(self):
        """
        Main loop for this shelf manager, can be started by start_thread() and stopped with stop_thread().
        This loop checks whether each shelf is connected, and removes them if they are not.
        :return:
        """
        print("Shelf Manager: Starting")


        self._last_loop_ms = time.time() * 1000

        while True:
            current_time_ms = time.time() * 1000
            # Break out of loop if flag was set
            with self._signal_end_lock:
                if self._signal_end:
                    break

            # Shelf watchdog. Remove shelves that haven't sent any data in a certain amount of time.
            macs_to_remove = list()
            for shelf_mac in self._active_shelves:
                shelf_obj = self._active_shelves[shelf_mac]
                if shelf_obj.get_last_ping_time() < current_time_ms - SHELF_DISCONNECT_TIMEOUT_MS:
                    # Shelf has timed out, needs to be removed
                    print(f"Shelf Manager: Shelf '{shelf_mac}' disconnected (timed out).")
                    # Make sure most recent version of this shelf is saved
                    self._save_shelf_data(shelf_obj)
                    # Add this shelf to the list of shelves to remove
                    macs_to_remove.append(shelf_mac)

            for mac_address in macs_to_remove:
                del self._active_shelves[mac_address]
            macs_to_remove.clear()


            # TODO post what shelves are available on an endpoint somewhere

            # Update time
            self._last_loop_ms = current_time_ms

