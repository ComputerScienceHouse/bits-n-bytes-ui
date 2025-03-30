###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
import json
from PySide6.QtCore import QObject, QTimer, Slot, QMetaObject, QUrl, Q_ARG, Qt, Property, Signal
from PySide6.QtWidgets import QApplication, QStackedLayout
from PySide6.QtQml import QQmlComponent
from os import environ
from bnb.nfc import NFCListenerThread

MQTT_LOCAL_BROKER_URL = environ.get('MQTT_LOCAL_BROKER_URL', None)
MQTT_REMOTE_BROKER_URL = environ.get('')
import os
from bnb import config
from typing import List

class AppController(QObject):
    
    openAdmin = Signal()

    nfc: NFCListenerThread
    _input: List
    _pattern: List

    def __init__(self):
        super().__init__()
        self.stack = None
        self._input = []
        self._pattern = json.loads(os.getenv("BNB_ADMIN_PATTERN"))
        self.nfc = NFCListenerThread()
        self.is_welcome_active = False

    @Property(QObject)
    def stackView(self):
        return self.stack

    @stackView.setter
    def stackView(self, value):
        self.stack = value

    @Slot()
    def runNFC(self):
        if self.is_welcome_active:
            self.nfc.run()
        else:
            self.stopNFC()
    
    @Slot()
    def stopNFC(self):
        self.nfc.stop()

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