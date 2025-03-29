###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
from PySide6.QtCore import QObject, QTimer, Slot
from PySide6.QtWidgets import QApplication, QStackedLayout
from os import environ
from bnb.nfc import NFCListenerThread

MQTT_LOCAL_BROKER_URL = environ.get('MQTT_LOCAL_BROKER_URL', None)
MQTT_REMOTE_BROKER_URL = environ.get('')

class AppController(QObject):
    
    nfc: NFCListenerThread

    def __init__(self):
        super().__init__()
        self.stack = None
        self.nfc = NFCListenerThread()

    @Slot(QObject)
    def set_stack(self, stack):
        self.stack = stack
        # self.stack.currentChanged.connect(self.onCurrentItemChanged)
        stack.currentIndex = 0 # auto set to welcome screen

    @Slot(QObject)
    def runNFC(self, current_item: QObject):
        if(current_item.objectName() == "welcome"):
            self.nfc.run()
        else:
            self.nfc.stop()

    def nameTimerSwitch(self, timer: QTimer):
        timer.active = True
        timer.setInterval(1000)
        timer.start()
        while(timer.remainingTime > 0):
            if(timer.remainingTime == 0):
                self.navigate("cart")

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
    def exit(self):
        QApplication.instance().quit()