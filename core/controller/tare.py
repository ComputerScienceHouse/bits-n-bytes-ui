from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from core.services.shelf_manager import ShelfManager
import json
from typing import Optional

class TareController(QObject):
    shelvesChanged = Signal()
    
    def __init__(self, shelf_manager: ShelfManager):
        super().__init__()
        if shelf_manager is None:
            raise ValueError("shelf_manager cannot be None")
            
        self._shelf_manager = shelf_manager
        self._shelves = []
        self._is_updating = False
        
        # Set up refresh timer (300ms interval)
        self.refresh_timer = QTimer(self)
        self.refresh_timer.setInterval(500)
        self.refresh_timer.timeout.connect(self._refresh_shelves)
        
        # Connect to MQTT updates if available
        if hasattr(shelf_manager, '_local_mqtt_client'):
            shelf_manager._local_mqtt_client.add_topic('shelf/data', self._handle_mqtt_update)

    @Property('QVariantList', notify=shelvesChanged)
    def shelves(self):
        return self._shelves

    @Slot()
    def start_real_time_updates(self):
        """Start both timer and MQTT updates"""
        self.refresh_timer.start()
        self._refresh_shelves()  # Immediate initial update

    @Slot()
    def stop_real_time_updates(self):
        """Stop all updates"""
        self.refresh_timer.stop()

    def _handle_mqtt_update(self, message):
        """Handle incoming MQTT messages"""
        try:
            data = json.loads(message)
            mac_addr = data['id']
            weights = data.get('data', [])
            
            with self._shelf_manager._active_shelves_lock:
                shelf = next((s for s in self._shelves if s["mac_addr"] == mac_addr), None)
                
                if not shelf:
                    # Create new shelf entry
                    shelf = {
                        "mac_addr": mac_addr,
                        "index": len(self._shelves) + 1,
                        "slots": []
                    }
                    self._shelves.append(shelf)
                
                # Update slots
                for i, weight in enumerate(weights):
                    if i >= len(shelf["slots"]):
                        # Add new slot
                        shelf["slots"].append({
                            "slot_index": i,
                            "tare_state": 0,
                            "weight": weight
                        })
                    else:
                        # Update existing slot
                        shelf["slots"][i]["weight"] = weight
                
                self.shelvesChanged.emit()
                
        except Exception as e:
            print(f"MQTT update error: {e}")

    # def _refresh_shelves(self):
    #     """Timer-based refresh of all shelf data"""
    #     if self._is_updating:
    #         return
            
    #     self._is_updating = True
    #     try:
    #         # Get fresh data from hardware
    #         current_shelves = self._shelf_manager.get_all_shelves()
            
    #         # Build new shelves list
    #         new_shelves = []
    #         for i, shelf in enumerate(current_shelves):
    #             slots = []
    #             for j, slot in enumerate(shelf.get_all_slots()):
    #                 # Find existing state if available
    #                 existing_state = 0
    #                 existing_shelf = next(
    #                     (s for s in self._shelves if s["mac_addr"] == shelf._mac_address),
    #                     None
    #                 )
    #                 if existing_shelf and j < len(existing_shelf["slots"]):
    #                     existing_state = existing_shelf["slots"][j].get("tare_state", 0)
                    
    #                 slots.append({
    #                     "slot_index": j,
    #                     "tare_state": existing_state,
    #                     "value": slot
    #                 })
                
    #             new_shelves.append({
    #                 "mac_addr": shelf._mac_address,
    #                 "index": i + 1,
    #                 "slots": slots
    #             })
            
    #         # Only update if changed
    #         if new_shelves != self._shelves:
    #             self._shelves = new_shelves
    #             self.shelvesChanged.emit()
                
    #     except Exception as e:
    #         print(f"Refresh error: {e}")
    #     finally:
    #         self._is_updating = False
    
    def _refresh_shelves(self):
        """Optimized shelf refresh that only updates changed items"""
        if self._is_updating:
            return
            
        self._is_updating = True
        try:
            current_shelves = self._shelf_manager.get_all_shelves()
            updated = False
            
            # Create lookup of existing shelves by mac address
            existing_shelves = {s['mac_addr']: s for s in self._shelves}
            
            # Check for removed shelves
            current_macs = {shelf._mac_address for shelf in current_shelves}
            for mac in list(existing_shelves.keys()):
                if mac not in current_macs:
                    self._shelves = [s for s in self._shelves if s['mac_addr'] != mac]
                    updated = True
            
            # Update or add shelves
            for i, shelf in enumerate(current_shelves):
                mac = shelf._mac_address
                existing_shelf = existing_shelves.get(mac)
                
                if not existing_shelf:
                    # New shelf - add it
                    self._add_new_shelf(shelf)
                    updated = True
                    continue
                    
                # Update existing shelf
                existing_shelf['index'] = i + 1  # Update position if needed
                
                # Update slots
                for j, slot in enumerate(shelf.get_all_slots()):
                    if j >= len(existing_shelf['slots']):
                        # New slot
                        existing_shelf['slots'].append({
                            'slot_index': j,
                            'tare_state': 0,
                            'value': slot
                        })
                        updated = True
                    else:
                        # Update existing slot value while preserving state
                        existing_shelf['slots'][j]['value'] = slot
            
            if updated:
                self.shelvesChanged.emit()
                
        except Exception as e:
            print(f"Refresh error: {e}")
        finally:
            self._is_updating = False

    def _add_new_shelf(self, shelf):
        """Helper to add a new shelf to our model"""
        slot_data = [
            {
                "slot_index": i,
                "tare_state": 0,  # Default state
                "value": slot
            }
            for i, slot in enumerate(shelf.get_all_slots())
        ]
        
        self._shelves.append({
            "mac_addr": shelf._mac_address,
            "index": len(self._shelves) + 1,
            "slots": slot_data
        })

    @Slot()
    def get_new_shelves(self):
        if self._is_updating:
            return
        self._is_updating = True
        try:
            shelves = sorted(self._shelf_manager.get_all_shelves(), key=lambda shelf: shelf._mac_address)
            shelf_list = []
            for i, shelf in enumerate(shelves):
                slot_data_list = []
                for j, slot in enumerate(shelf.get_all_slots()):
                    slot_data = {
                        "slot_index": j,
                        "tare_state": 0,
                        "value": slot
                    }
                    slot_data_list.append(slot_data)
                shelf_data = {
                    "mac_addr": shelf._mac_address,
                    "index": i + 1,                    
                    "slots": slot_data_list
                }

                shelf_list.append(shelf_data)
            if len(self._shelves) == 0:
                self._shelves = shelf_list
            self.shelvesChanged.emit()
        except Exception as e:
            print(f"Error updating shelves: {e}")
        finally:
            self._is_updating = False
        return shelf_list

    @Slot(str, int, result=int)
    def get_tare_state(self, mac_addr: str, slot_index: int) -> int:
        """Returns the current tare state for a specific slot"""
        try:
            for shelf in self._shelves:
                if shelf["mac_addr"] == mac_addr:
                    for slot in shelf["slots"]:
                        if slot["slot_index"] == slot_index:
                            return slot.get("tare_state", 0)
            return 0
        except Exception as e:
            print(f"Error getting tare state: {e}")
            return 0

    @Slot(str, int, float)
    def tare_slot(self, mac_addr: str, slot_id: int, calibration_weight_g: float):
        try:
            self._shelf_manager.tare_slot(mac_addr, slot_id, calibration_weight_g)
            for shelf in self._shelves:
                if shelf["mac_addr"] == mac_addr:
                    for slot in shelf["slots"]:
                        if slot["slot_index"] == slot_id:
                            slot["tare_state"] = 1 # set to taring state
                            break
            self.shelvesChanged.emit()

            QTimer.singleShot(500, lambda: self.complete_tare(mac_addr, slot_id))
        except Exception as e:
            print(f"Tare error {e}")
    
    def complete_tare(self, mac_addr: str, slot_id: int):
        """Update state to completed after operation finishes"""
        for shelf in self._shelves:
            if shelf["mac_addr"] == mac_addr:
                for slot in shelf["slots"]:
                    if slot["slot_index"] == slot_id:
                        slot["tare_state"] = 2  # Set to completed state
                        break
        self.shelvesChanged.emit()

    def _find_slot(self, mac_addr: str, slot_index: int) -> Optional[dict]:
        """Helper to find slot dict by mac_addr and slot_index"""
        try:
            if shelf := next((s for s in self._shelves if s["mac_addr"] == mac_addr), None):
                return next((s for s in shelf["slots"] if s["slot_index"] == slot_index), None)
            return None
        except Exception as e:
            print(f"Lookup error: {e}")
            return None
    # sort_shelves might be internal logic now, triggered by update_shelves if needed
    # remove sort_shelves @Slot unless QML needs to trigger it explicitly
