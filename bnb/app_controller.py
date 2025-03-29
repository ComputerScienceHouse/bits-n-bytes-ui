###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
import json
from PySide6.QtCore import QObject, QTimer, Slot
from PySide6.QtWidgets import QApplication
import os
import config
from typing import List

class AppController(QObject):
    
    _input: List
    _pattern: List

    def __init__(self):
        super().__init__()
        self.stack=None
        self._input = []
        self._pattern = json.loads(os.getenv("BNB_ADMIN_PATTERN"))

    @Slot(QObject)
    def set_stack(self, stack):
        self.stack = stack
        stack.currentIndex = 0 # auto set to welcome screen

    @Slot()
    def startTimer(self):
        QTimer.singleShot(1000, lambda: self.navigate("cart"))

    @Slot(str)
    def navigate(self, screen):
        screen_map = {
            "welcome": 0,
            "name": 1,
            "cart": 2,
            "reciept": 3,
            "admin": 4,
            "tare": 5
        }

        if screen in screen_map:
            self.stack.setProperty("currentIndex", screen_map[screen])

    @Slot()
    def checkSeq(self):
        if self._pattern == None:
            return "BNB_ADMIN_PATTERN not implemented in config.py"
        if self._input == self._pattern:
            self.navigate('admin')
            print("Admin screen unlocked!")
        elif len(self._input) == len(self._pattern):
            print("Incorrect pattern, try again.")
    
    @Slot(int)
    def pushInput(self, num):
        self._input.append(num)

    @Slot()
    def exit(self):
        QApplication.instance().quit()