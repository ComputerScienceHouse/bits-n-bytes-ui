from typing import List, Any

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
    
class Slot:

    item: Item
    _conversion_factor: float
    # Weight of iteration before ROLLING_AVERAGE (CERTAINTY_CONSTANT + 1)
    _previous_weight_g: float
    # Store a number of previous weights to calculate rolling average
    _last_weights_store = list
    _last_pos = False
    _last_neg = False

    def __init__(self, item: Item):
        """
        Create a Slot
        :param item: Item stocked in this slot
        """
        # Set passed in values
        self.item = item
        # Initialize weights and conversion factor
        self._conversion_factor = 1
        self._previous_weight_g = 0
        # Initialize list of previous values
        self._last_weights_store = list()
        for i in range(CERTAINTY_CONSTANT - 1):
            self._last_weights_store.append(0)

    def set_conversion_factor(self, value: float) -> None:
        """
        Set the conversion factor. This should be calculating by:
        1. Take the raw value of the scale with no weight (value is 'x1')
        2. Get a calibration weight. (Weight is 'x2')
        3. Take the raw value of the scale with a calibration weight (value is 'x3')
        4. conversion_factor = (x2) / (x3 - x1)
        :param value: float new conversion factor
        :return: None
        """
        self._conversion_factor = value

    def get_conversion_factor(self) -> float:
        """
        Get the conversion factor
        :return: float conversion factor
        """
        return self._conversion_factor

    def update(self, raw_weight_value) -> int:
        """
        Update this slot object with its newly received weight value
        :param raw_weight_value: Raw weight value
        :return:
        """
        # Normalize weight with conversion factor
        normalized_weight_g = raw_weight_value * self._conversion_factor
        # Calculate rolling average
        rolling_average = (sum(self._last_weights_store) + normalized_weight_g) / (len(self._last_weights_store) + 1)

        # Difference from previous iteration to now
        difference_g = rolling_average - self._previous_weight_g
        remainder_weight = difference_g % self.item.avg_weight
        quantity_to_modify_cart = 0
        # Check that the remainder is within the top std_dev or bottom_std of the avg_weight
        if remainder_weight >= self.item.avg_weight - self.item.std_weight or remainder_weight <= self.item.avg_weight + self.item.std_weight:
            # Calculate quantity removed
            quantity = round(difference_g / self.item.avg_weight)
            if quantity > 0:
                if not self._last_pos:
                    print(f"\t{quantity} item(s) placed back")
                    quantity_to_modify_cart = quantity
                    self._last_pos = True
                else:
                    self._last_pos = False
            elif quantity < 0:
                if not self._last_neg:
                    print(f"\t{quantity} item(s) removed")
                    quantity_to_modify_cart = quantity
                    self._last_neg = True
                else:
                    self._last_neg = False

        # Update previous rate and rolling average data for next iteration
        oldest_weight = self._last_weights_store[-1]
        self._last_weights_store.insert(0, normalized_weight_g)
        self._last_weights_store.pop()
        self._previous_weight_g = oldest_weight
        return quantity_to_modify_cart

class Shelf:

    slots: List[Slot]
    items: List[Item]

    def __init__(self, items: List[Item]):
        """
        Create a new shelf
        :param items: List of items in this shelf, one per slot
        """
        self.slots = list()
        self.items = list()
        for item in items:
            self.slots.append(Slot(item))
            self.items.append(item)

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
        self.payment = False

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