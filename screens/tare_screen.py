import os.path

from PySide6.QtWidgets import QMainWindow, QPushButton
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt, QSize, Signal, QCoreApplication

from shelf_manager import ShelfManager
from .ui_admin import Ui_Admin
import resources_rc
import mqtt
from .ui_tare import Ui_Tare
import json

TARE_STORE_FILE = "tmp/tare_store.json"


class TareButton:

    button: QPushButton
    shelf_mac: str
    slot_index: int
    zero_weight_value: float
    state: int

    def __init__(self, button: QPushButton, shelf_mac: str, slot_index: int):
        self.button = button
        self.shelf_mac = shelf_mac
        self.slot_index = slot_index
        self.zero_weight_value = 0
        self.state = 0


class TareScreen(QMainWindow):
    show_admin_signal = Signal()

    def __init__(self, parent=None, shelf_manager: ShelfManager = None):
        super(TareScreen, self).__init__(parent)
        self.shelf_manager = shelf_manager
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Tare()
        self.ui.setupUi(self)

        self.ui.exitButton.clicked.connect(lambda: self.on_show_admin())

        # Set up a list of the buttons
        self.button_list = [
          TareButton(self.ui.oneA, "", 0),
          TareButton(self.ui.oneB, "", 1),
          TareButton(self.ui.oneC, "", 2),
          TareButton(self.ui.oneD, "", 3),
          TareButton(self.ui.twoA, "80:65:99:49:EF:8E", 0),
          TareButton(self.ui.twoB, "80:65:99:49:EF:8E", 1),
          TareButton(self.ui.twoC, "80:65:99:49:EF:8E", 2),
          TareButton(self.ui.twoD, "80:65:99:49:EF:8E", 3),
          TareButton(self.ui.threeA, "80:65:99:E3:EF:50", 0),
          TareButton(self.ui.threeB, "80:65:99:E3:EF:50", 1),
          TareButton(self.ui.threeC, "80:65:99:E3:EF:50", 2),
          TareButton(self.ui.threeD, "80:65:99:E3:EF:50", 3),
          TareButton(self.ui.fourA, "80:65:99:E3:8B:92", 0),
          TareButton(self.ui.fourB, "80:65:99:E3:8B:92", 1),
          TareButton(self.ui.fourC, "80:65:99:E3:8B:92", 2),
          TareButton(self.ui.fourD, "80:65:99:E3:8B:92", 3),
        ]
        # Set default color and connect the click events
        for tare_button in self.button_list:
            tare_button.button.setStyleSheet("background-color: #323232;")  # Default color
            tare_button.button.clicked.connect(lambda _, b=tare_button: self.change_button_color(b))

        if not os.path.exists(TARE_STORE_FILE):
            data = { "80:65:99:49:EF:8E": [1, 1, 1, 1], "80:65:99:E3:EF:50": [1, 1, 1, 1], "80:65:99:E3:8B:92": [1, 1, 1, 1]}
            os.mkdir("./tmp")
            with open(TARE_STORE_FILE, 'w') as out_file:
                json.dump(data, out_file)
        else:
            with open(TARE_STORE_FILE, 'r') as in_file:
                data = json.load(in_file)
        for button in self.button_list:
            if button.shelf_mac != "":
                self.shelf_manager.set_conversion_factor(button.shelf_mac, button.slot_index, data[button.shelf_mac][button.slot_index])


    def change_button_color(self, button: TareButton):
        # Cycle colors: 0 (default), 1 (yellow), 2 (green)
        if button.state == 0:
            button.button.setStyleSheet("background-color: yellow;")
            button.zero_weight_value = self.shelf_manager.get_most_recent_value(button.shelf_mac, button.slot_index)
            print(f"set zero weight value to {button.zero_weight_value}")
            button.state = 1
        elif button.state == 1:
            button.button.setStyleSheet("background-color: green;")
            current_value = self.shelf_manager.get_most_recent_value(button.shelf_mac, button.slot_index)
            print(f"got most recent value: {current_value}")
            print(f"LOOK: zero_weight {button.zero_weight_value}, current {current_value}")
            conversion_factor = self.shelf_manager.tare_shelf(button.shelf_mac, button.slot_index, button.zero_weight_value, current_value)
            button.state = 2
            with open(TARE_STORE_FILE, 'r') as in_file:
                data = json.load(in_file)
            data[button.shelf_mac][button.slot_index] = conversion_factor
            with  open(TARE_STORE_FILE, 'w') as out_file:
                json.dump(data, out_file)
        else:
            button.button.setStyleSheet("background-color: #323232;")  # Back to default
            button.state = 0


    def on_show_admin(self):
        self.show_admin_signal.emit()