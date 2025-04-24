import os
import json
import core.config
from core.services.mqtt import MqttClient
from PySide6.QtCore import QObject, Signal, Slot

class AdminController(QObject):
    _input = list
    _pattern = list

    def __init__(self):
        super().__init__()
        self._input = []
        try:
            # Load pattern during initialization
            self._pattern = json.loads(os.getenv("BNB_ADMIN_PATTERN", "[]"))
        except json.JSONDecodeError:
            print("Warning: Invalid BNB_ADMIN_PATTERN environment variable.")
            self._pattern = [] # Default to empty if invalid
  
    @Slot(int)
    def pushInput(self, num):
        if not self._pattern: # Don't collect if pattern is invalid/missing
             print("Admin pattern not configured or invalid.")
             return
        self._input.append(num)
        # Optional: Trim input if it gets longer than pattern
        if len(self._input) > len(self._pattern):
            self._input = self._input[-len(self._pattern):]
        self.checkSeq() # Check sequence after each input

    @Slot()
    def checkSeq(self):
        if not self._pattern:
            print("Admin pattern not configured.")
            return
        if self._input == self._pattern:
            print("Admin pattern correct!")
            self.openAdmin.emit()
            self.notifyAdminUnlock.emit()
            self._input.clear()
        elif len(self._input) == len(self._pattern):
            print("Incorrect pattern.")
            self._input.clear()