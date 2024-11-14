from PySide6.QtWidgets import QMainWindow
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize, Signal, QCoreApplication
from .ui_admin import Ui_Admin
import resources_rc
import mqtt
from .ui_tare import Ui_Tare



class TareScreen(QMainWindow):
    
   def __init__(self, parent=None):
      super(TareScreen, self).__init__(parent)
      self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
      self.ui = Ui_Tare()
      self.ui.setupUi(self)
      
      # Set up a list of the buttons
      self.buttons = [
            self.ui.oneA, self.ui.oneB, self.ui.oneC, self.ui.oneD,
            self.ui.twoA, self.ui.twoB, self.ui.twoC, self.ui.twoD,
            self.ui.threeA, self.ui.threeB, self.ui.threeC, self.ui.threeD,
            self.ui.fourA, self.ui.fourB, self.ui.fourC, self.ui.fourD
        ]

      # Set default color and connect the click events
      for button in self.buttons:
            button.setStyleSheet("background-color: #323232;")  # Default color
            button.clicked.connect(lambda checked, b=button: self.change_button_color(b))

      # Track button states to cycle colors
      self.button_states = {button: 0 for button in self.buttons}

   def change_button_color(self, button):
        # Cycle colors: 0 (default), 1 (yellow), 2 (green)
        state = self.button_states[button]

        if state == 0:
            button.setStyleSheet("background-color: yellow;")
        elif state == 1:
            button.setStyleSheet("background-color: green;")
        else:
            button.setStyleSheet("background-color: #323232;")  # Back to default

        # Update button state for next press
        self.button_states[button] = (state + 1) % 3