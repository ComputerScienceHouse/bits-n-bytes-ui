###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
from PySide6.QtCore import QObject, QTimer, Slot, QMetaObject, QUrl, Q_ARG, Qt, Property, Signal
from PySide6.QtWidgets import QApplication, QStackedLayout
from PySide6.QtQml import QQmlComponent

import json
import os
from bnb.nfc import NFCListenerThread
from bnb.model import Model
from bnb import config
from typing import List

MQTT_LOCAL_BROKER_URL = os.getenv('MQTT_LOCAL_BROKER_URL', None)
MQTT_REMOTE_BROKER_URL = os.getenv('')

class Countdown(QObject):
    remainingTimeChanged = Signal()
    finished = Signal()

    def __init__(self, parent=None):
        super().__init__()
        self._remaining_time = 10
        self.timer = QTimer(self)
        self.timer.setInterval(1000)
        self.timer.timeout.connect(self._update_time)
    
    @Property(int, notify=remainingTimeChanged)
    def remainingTime(self):
        return self._remaining_time
        
    @Slot()
    def startCountdown(self):
        self._remaining_time = 10
        self.remainingTimeChanged.emit()  # Immediately update display
        self.timer.start()

    @Slot()
    def _update_time(self):
        if self._remaining_time > 0:
            self._remaining_time -= 1
            self.remainingTimeChanged.emit()
        else:
            self.finished.emit()
            self.timer.stop()

class AppController(QObject):
    
    openAdmin = Signal()

    _countdown: Countdown
    _model: Model
    _nfc: NFCListenerThread
    _input: List
    _pattern: List

    def __init__(self):
        super().__init__()
        self._stack = None
        self._input = []
        self._pattern = json.loads(os.getenv("BNB_ADMIN_PATTERN"))
        self._nfc = NFCListenerThread()
        self._model = Model()
        self._countdown = Countdown(self)

    @Slot(result=str)
    def getName(self):
        return self._model.get_user_name()

    @Property(QObject, constant=True)
    def countdown(self):
        return self._countdown

    @Property(QObject)
    def stackView(self):
        return self._stack

    @stackView.setter
    def stackView(self, value):
        self._stack = value

    @Slot()
    def runNFC(self):
        if self.is_welcome_active:
            self._nfc.run()
        else:
            self.stopNFC()
    
    @Slot()
    def stopNFC(self):
        self._nfc.stop()

    @Slot()
    def checkSeq(self):
        if self._pattern == None:
            return "BNB_ADMIN_PATTERN not implemented in config.py"
        if self._input == self._pattern:
            self.openAdmin.emit()
            self._input.clear()
            print("Admin screen unlocked!")
        elif len(self._input) == len(self._pattern):
            print("Incorrect pattern, try again.")
    
    @Slot(int)
    def pushInput(self, num):
        self._input.append(num)

    @Slot()
    def exit(self):
        QApplication.instance().quit()




