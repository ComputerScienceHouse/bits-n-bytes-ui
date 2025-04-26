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
from queue import Queue
from statistics import quantiles
from threading import Lock
from typing import List, Dict, Any, Callable
from scipy.stats import norm
from pathlib import Path
import json
from filelock import FileLock
import pandas as pd
from core.services.mqtt import MqttClient
from core.data_classes import *
import core.database as db

SHELF_DATA_DIR = Path(Path.cwd() / 'tmp')
SHELF_DISCONNECT_TIMEOUT_MS = 5000
DEFAULT_NUM_SLOTS_PER_SHELF = 4
LOCAL_MQTT_BROKER_URL = os.environ.get('MQTT_LOCAL_BROKER_URL', None)
REMOTE_MQTT_BROKER_URL = os.environ.get('MQTT_REMOTE_BROKER_URL', None)
USE_MOCK_DATA = os.environ.get('USE_MOCK_DATA', False) == 'True'
MAX_ITEM_REMOVALS_TO_CHECK = 3
THRESHOLD_WEIGHT_PROBABILITY = 0.001

class Slot:

    _items: List[Item]
    _current_weight: float
    _current_raw_weight: float
    _previous_raw_weight: float
    _conversion_factor: float

    def __init__(self, items: List[Item] | None = None, conversion_factor: float = 1):
        """
        Create a new slot.
        :param items: Optional list of items that are already on the shelf.
        """
        if items is None:
            self._items = list()
        else:
            self._items = items
        self._current_weight = 0
        self._current_raw_weight = 0
        self._previous_raw_weight = 0
        self._conversion_factor = conversion_factor


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


    def predict_most_likely_item(self, weight_delta: float) -> List[Item]:
        """
        Given a change in weight, predict the most likely item that could have
        been added/removed from this scale.
        :param weight_delta: Float weight change in grams
        :return: Tuple: Item, Float; The item that is most likely and the probability of
        it being that item.
        """
        direction = 1
        if weight_delta < 0:
            direction = -1

        # Store probabilities of the various quantities of items being added/removed from the slot
        probabilities = dict()
        # Iterate through all possible items
        for item in self._items:
            # Store probabilities
            probabilities[item.item_id] = []
            # Iterate through all possible quantities
            for potential_quantity in range(1, MAX_ITEM_REMOVALS_TO_CHECK + 1):
                expected_weight = item.avg_weight * potential_quantity
                scaled_std = item.std_weight * (potential_quantity ** 0.5)
                z_score = (abs(weight_delta) - expected_weight) / scaled_std
                probability = (1 - abs(0.5 - norm.cdf(z_score)) * 2)

                # # Calculate per-item weight at this quantity
                # quantity_weight_delta = abs(weight_delta / potential_quantity)
                # # Calculate probability using probability density function on bell curve
                # probability = norm.pdf(
                #     quantity_weight_delta,
                #     loc=item.avg_weight,
                #     scale=item.std_weight
                # )
                # Store this probability
                probabilities[item.item_id].append(probability)
        # Convert probabilities to pandas dataframe
        df = pd.DataFrame(probabilities, index=range(1, MAX_ITEM_REMOVALS_TO_CHECK + 1)).T
        # Convert to stack to get top n probabilities
        probability_series = df.stack()
        top_n = 1
        top_n_probabilities = probability_series.nlargest(top_n)
        items: List[Item] = list()
        item_ids_and_quantities = dict()

        # Iterate through the top probabilities in decreasing order
        for rank, ((item_id, quantity), probability) in enumerate(top_n_probabilities.items(), start=1):
            print(f'{quantity}x {db.get_item(item_id).name} (p={probability})')
            if probability < THRESHOLD_WEIGHT_PROBABILITY:
                # If this probability is less than the threshold, all others will be too so return early
                break
            else:
                # Probability is above the threshold, add this item/quantity combination as something that
                # probably happened.
                if item_id in item_ids_and_quantities:
                    # Item id already exists, increase quantity
                    item_ids_and_quantities[item_id] += (direction * quantity)
                else:
                    # Item id does not already exist, add this quantity
                    item_ids_and_quantities[item_id] = (direction * quantity)

        # Create item objects that represent each of the changes
        for item_id in item_ids_and_quantities:
            # Get the quantity for this item
            quantity = item_ids_and_quantities[item_id]
            # Get the existing item object
            existing_item_obj = db.get_item(item_id)
            # Create a new item object with this quantity, and add it to the list of items to be
            # returned
            items.append(
                Item(
                    item_id,
                    existing_item_obj.name,
                    existing_item_obj.upc,
                    existing_item_obj.price,
                    quantity,
                    existing_item_obj.avg_weight,
                    existing_item_obj.std_weight,
                    existing_item_obj.thumbnail_url,
                    existing_item_obj.vision_class
                )
            )
        # Return resulting items, where the quantity matches the number predicted to be added/removed from the scale.
        return items


    def update_weight(self, raw_value: float) -> List[Item]:
        """
        Update the current weight reading of this shelf.
        :param raw_value:
        :return:
        """
        self._current_raw_weight = raw_value
        new_weight = raw_value * self._conversion_factor
        weight_delta = new_weight - self._current_weight
        item_changes = self.predict_most_likely_item(weight_delta)
        self._current_weight = new_weight
        return item_changes


    def tare(self, calibration_weight_g: float) -> bool:
        """
        Tare this shelf using a certain calibration weight.
        :param calibration_weight_g: Weight in grams of the calibration weight being used.
        :return:
        """
        if self._previous_raw_weight == self._current_raw_weight:
            # Can't divide by zero, print an error
            print("Shelf Manager: Loaded weight and zero weight are the same, can't compute conversion factor.")
            return False
        else:
            # Calculate conversion factor
            self._conversion_factor = abs(calibration_weight_g / (self._current_raw_weight - self._previous_raw_weight))
            # Update previous weight
            self._previous_raw_weight = self._current_raw_weight
            return True


    def clear_items(self) -> None:
        """
        Clear all items from this slot.
        :return: None.
        """
        self._items.clear()


    def get_items(self) -> List[Item]:
        """
        Get all items from the shelf.
        :return:
        """
        return self._items


    def get_json(self) -> Dict:
        """
        Get the JSON representation of this slot.
        :return: Any
        """
        # Store a list of all items
        items_json = list()
        for item in self._items:
            items_json.append({
                'id': item.item_id,
                'name': item.name,
                'quantity': item.quantity,
            })
        # Create slot data
        json_data = {
            'conversionFactor': self._conversion_factor,
            'items': items_json
        }
        return json_data


class Shelf:

    _mac_address: str
    _last_ping_ms: float
    _slots: List[Slot]

    def __init__(self, mac_address: str, slots_list: List[Slot] | None = None) -> None:
        # Set all members
        self._last_ping_ms = time.time() * 1000
        self._mac_address = mac_address

        if slots_list is None:
            self._slots = list()
        else:
            self._slots = slots_list


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
        return len(self._slots)


    def get_all_slots(self) -> List[Slot]:
        """
        Get all slots from this shelf.
        :return: A list of Slot.
        """
        return self._slots


    def get_slot(self, slot_id: int) -> Slot:
        """
        Get a slot from this shelf.
        :param slot_id: ID of the slot to get.
        :return:
        """
        return self._slots[slot_id]


    def tare_slot(self, slot_id: int, calibration_weight_g: float) -> bool:
        """
        Tare a slot.
        :param slot_id: The ID of the slot to tare.
        :param calibration_weight_g: The known calibration weight being used.
        :return: Whether the slot was tared successfully.
        """
        if slot_id < len(self._slots):
            return self._slots[slot_id].tare(calibration_weight_g)
        else:
            return False


    def get_json(self) -> Any:
        """
        Get JSON representation of this shelf.
        :return: Any
        """
        json_data = {
            'macAddress': self._mac_address,
            'slots': [slot.get_json() for slot in self._slots],
        }
        return json_data



class ShelfManager:

    _last_loop_ms: float

    _signal_end_lock: Lock
    _signal_end: bool

    _active_shelves_lock: Lock
    _active_shelves: Dict[str, Shelf]

    _local_mqtt_client: MqttClient | None

    _weight_updates_queue: Queue

    _add_cart_item_cb: Callable[[Item], None] | None
    _remove_cart_item_cb: Callable[[Item], None] | None

    def __init__(
            self,
            shelf_data_dir: Path = SHELF_DATA_DIR,
            add_cart_item_cb: Callable[[Item], None] | None = None,
            remove_cart_item_cb: Callable[[Item], None] | None = None
    ) -> None:

        # Instantiate active shelves
        self._active_shelves_lock = Lock()
        with self._active_shelves_lock:
            self._active_shelves = dict()

        # Create shelf data directory if it doesn't exist
        self._shelf_data_dir = shelf_data_dir
        self._shelf_data_dir.mkdir(parents=True, exist_ok=True)

        # Setup signal end system
        self._signal_end_lock = Lock()
        self._signal_end = False

        # Set up weight queue system
        self._weight_updates_queue = Queue()

        # Setup add/remove cart item callbacks
        self._add_cart_item_cb = add_cart_item_cb
        self._remove_cart_item_cb = remove_cart_item_cb

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
            self._remote_mqtt_client.add_topic('shelf/tare', self._shelf_tare_received, qos=1)
            self._remote_mqtt_client.add_topic('shelf/set/item', self._shelf_update_items_received, qos=1)
            self._remote_mqtt_client.start()
        else:
            self._remote_mqtt_client = None



    def _load_shelf_data(self, mac_address: str) -> Shelf | None:
        """
        Load data for a shelf
        :param mac_address: MAC address of the shelf to load
        :return: A Shelf object if the data was loaded successfully, None otherwise.
        """
        # Create path
        shelf_data_path = Path(self._shelf_data_dir / f"{mac_address}.json")
        with FileLock(Path(self._shelf_data_dir / f"{mac_address}.lock")):
            # Open it, if it exists
            if shelf_data_path.exists():
                with open(shelf_data_path, 'r') as file:
                    # Load the JSON
                    json_data = json.load(file)
                    mac_address = json_data["macAddress"]
                    slots = list()
                    # Load all slots
                    slots_list = list()
                    for slot_json in json_data["slots"]:
                        conversion_factor = slot_json["conversionFactor"]
                        # Load all items
                        items_list = list()
                        for item_json in slot_json["items"]:
                            # Get most recent version of item by ID
                            item_id = item_json["id"]
                            quantity = item_json["quantity"]
                            # Make a copy of the item and modify the quantity
                            item_to_copy = db.get_item(item_id)
                            item_obj = Item(
                                item_to_copy.item_id,
                                item_to_copy.name,
                                item_to_copy.upc,
                                item_to_copy.price,
                                quantity,
                                item_to_copy.avg_weight,
                                item_to_copy.std_weight,
                                item_to_copy.thumbnail_url,
                                item_to_copy.vision_class
                            )
                            items_list.append(item_obj)
                        slot_obj = Slot(items_list, conversion_factor)
                        slots_list.append(slot_obj)
                    shelf_obj = Shelf(mac_address, slots_list)
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
        with FileLock(Path(self._shelf_data_dir / f"{shelf.get_mac_address()}.lock")):
            # Open file and dump pickle data
            with open(shelf_data_path, 'w') as file:
                json.dump(shelf.get_json(), file)


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
        Tare a slot on a shelf. Note that this function is thread safe,
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
                    shelf_obj = Shelf(mac_address, [Slot(), Slot(), Slot(), Slot()])
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
                        item_updates = all_slots[i].update_weight(raw_weight)
                        for item in item_updates:
                            self._weight_updates_queue.put(item)


    def _shelf_tare_received(self, message: str):

        # Convert message to JSON
        try:
            json_data = json.loads(message)
        except JSONDecodeError:
            print("Shelf Manager: Error: Unable to decode shelf data message as JSON.")
            return

        slots_to_tare = list()
        # Get data from shelf
        try:
            calibration_weight_g = json_data['calibrationWeight']
            shelves_json = json_data['shelves']
            for shelf_mac in shelves_json:
                slot_list = shelves_json[shelf_mac]['slots']
                for slot_id in slot_list:
                    self.tare_slot(shelf_mac, slot_id, calibration_weight_g=calibration_weight_g)

        except KeyError:
            print("Shelf Manager: Error: Invalid tare message received.")
            return
        print("tared shelves")


    def _shelf_update_items_received(self, message: str):
        """
        Callback for when item update is received from website.
        :param message:
        :return:
        """
        # Convert message to JSON
        try:
            json_data = json.loads(message)
        except JSONDecodeError:
            print("Shelf Manager: Error: Unable to decode shelf data message as JSON.")
            return
        for shelf_mac in json_data['shelves']:
            for slot_id_str in json_data['shelves'][shelf_mac]['slotInfo']:
                slot_json = json_data['shelves'][shelf_mac]['slotInfo'][slot_id_str]
                slot_id = int(slot_id_str)
                item_id = slot_json['itemId']
                quantity = slot_json['quantity']


                with self._active_shelves_lock:
                    # Get the slot to modify
                    slot_obj = self._active_shelves[shelf_mac].get_slot(slot_id)

                    # If item ID is -1 (empty), clear items
                    if item_id == -1:
                        slot_obj.clear_items()
                    else:
                        # Check if this object already exists
                        obj_found = False
                        for existing_item in slot_obj.get_items():
                            if existing_item.item_id == item_id:
                                # Item exists, updated quantity
                                existing_item.quantity = quantity
                                obj_found = True
                                break
                        existing_item = db.get_item(item_id)
                        if not obj_found:
                            slot_obj.add_item(
                                Item(
                                    item_id,
                                    existing_item.name,
                                    existing_item.upc,
                                    existing_item.price,
                                    quantity,
                                    existing_item.avg_weight,
                                    existing_item.std_weight,
                                    existing_item.thumbnail_url,
                                    existing_item.vision_class
                                )
                            )



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
                    with self._active_shelves_lock:
                        for shelf_mac in self._active_shelves:
                            self._save_shelf_data(self._active_shelves[shelf_mac])
                    break

            # Shelf watchdog. Remove shelves that haven't sent any data in a certain amount of time.
            macs_to_remove = list()
            with self._active_shelves_lock:
                for shelf_mac in self._active_shelves:
                    shelf_obj = self._active_shelves[shelf_mac]
                    if shelf_obj.get_last_ping_time() < current_time_ms - SHELF_DISCONNECT_TIMEOUT_MS:
                        # Shelf has timed out, needs to be removed
                        print(f"Shelf Manager: Shelf '{shelf_mac}' disconnected (timed out).")
                        # Make sure most recent version of this shelf is saved
                        self._save_shelf_data(shelf_obj)
                        # Add this shelf to the list of shelves to remove
                        macs_to_remove.append(shelf_mac)

            with self._active_shelves_lock:
                for mac_address in macs_to_remove:
                    del self._active_shelves[mac_address]
                macs_to_remove.clear()

            # Process item updates from queue
            while not self._weight_updates_queue.empty():
                # Get next update to process
                item_to_update: Item = self._weight_updates_queue.get()
                if item_to_update.quantity < 0:
                    # Add to cart
                    item_to_update.quantity *= -1
                    if self._add_cart_item_cb is not None:
                        self._add_cart_item_cb(item_to_update)
                elif item_to_update.quantity > 0:
                    # Remove from cart
                    if self._remove_cart_item_cb is not None:
                        self._remove_cart_item_cb(item_to_update)


            # TODO post what shelves are available on an endpoint somewhere

            # Update time
            self._last_loop_ms = current_time_ms

