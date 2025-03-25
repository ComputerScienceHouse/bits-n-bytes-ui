###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
from PySide6.QtCore import QObject, QTimer, Slot
from PySide6.QtWidgets import QApplication

class AppController(QObject):
    
    def __init__(self):
        super().__init__()
        self.stack=None
        # welcome = self.stack.findChildren(QObject, "welcome")
        # for child in stack_children:
        #     print("Child object name:", child.objectName())  # Prints the QML component names inside the stack

    @Slot(QObject)
    def set_stack(self, stack):
        self.stack = stack
        stack.currentIndex = 0 # auto set to welcome screen

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