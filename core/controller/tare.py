
from PySide6.QtCore import QObject, Signal, Slot, Property
from core.services.shelf_manager import ShelfManager

SHELF_1_MAC_ADDRESS = None
SHELF_2_MAC_ADDRESS = None
SHELF_3_MAC_ADDRESS = None
SHELF_4_MAC_ADDRESS = None

class TareController(QObject):
    shelvesChanged = Signal()

    _shelves: dict

    def __init__(self, shelf_manager: ShelfManager):
        super().__init__()
        if shelf_manager is None:
             raise ValueError("shelf_manager cannot be None")
        self._shelf_manager = shelf_manager
        self._shelves = dict() # Store internal representation
        self._is_updating = False # Prevent concurrent updates

        # Connect shelf manager signals to update internal state and notify QML
        # self._shelf_manager.some_signal_indicating_change.connect(self.update_shelves) # TODO: Implement this signal in ShelfManager

    @Property('QVariantList', notify=shelvesChanged)
    def shelves(self):
        """Read-only property exposing shelf data formatted for QML."""
        return self._shelves

    # Maybe make this a private method called by signal from ShelfManager?
    @Slot()
    def update_shelves(self):
        if self._is_updating:
            return
        self._is_updating = True
        try:
            current_shelves = sorted(self._model._shelf_manager.get_all_shelves(), key=lambda shelf: shelf._mac_address)
            shelf_list = []
            for i, shelf in enumerate(current_shelves):
                slot_data_list = []
                for j, slot in enumerate(shelf.get_all_slots()):
                    slot_data = {
                        "slot_index": j,
                        "value": slot
                    }
                    slot_data_list.append(slot_data)
                shelf_data = {
                    "index": i + 1,
                    "slots": slot_data_list
                }
                shelf_list.append(shelf_data)
            if self._shelves != shelf_list:
                self.shelves = shelf_list
                self.shelvesChanged.emit()
        except Exception as e:
            print(f"Error updating shelves: {e}")
        finally:
            self._is_updating = False

    # Example - adapt based on ShelfManager capabilities
    @Slot(str, int, float)
    def tare_slot(self, mac_addr: str, slot_id: int, calibration_weight_g: float):
        self._model._shelf_manager.tare_slot(mac_addr, slot_id, calibration_weight_g)
        slot = self._shelves["mac_address"][slot_id]
        slot.get

    # sort_shelves might be internal logic now, triggered by update_shelves if needed
    # remove sort_shelves @Slot unless QML needs to trigger it explicitly

