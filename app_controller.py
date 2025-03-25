###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
from PySide6.QtCore import QObject, QTimer

class AppController(QObject):
    
    def __init__(self, stack):
        super().__init__()
        self.stack = stack
        print(self.stack)

    def navigate(self, screen):
        self.stack.append(screen)
        pass

    def nameTimerSwitch(screen: QObject, newScreen: QObject, timer: QTimer):
        timer.active = True
        timer.setInterval(1000)
        timer.start()
        while(timer.remainingTime > 0):
            if(timer.remainingTime == 0):
                switchScreen(screen)

