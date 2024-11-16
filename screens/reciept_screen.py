from PySide6.QtWidgets import QMainWindow, QPushButton
import copy
from screens.welcome_screen import WelcomeScreen
from .ui_reciept import Ui_Reciept
from PySide6.QtCore import Qt, QTimer, QRect, Signal
from models import Cart, ItemListModel

class RecieptScreen(QMainWindow):
    go_home_signal = Signal()
    
    def __init__(self, cart, parent=None):
        super(RecieptScreen, self).__init__(parent)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.ui = Ui_Reciept()
        self.ui.setupUi(self)
        self.cart = cart   

        self.model = ItemListModel(cart)
        self.ui.itemList.setModel(self.model)

        # self.timer_button = QPushButton()
        # self.timer_button.setObjectName(u"timer_button")
        # print("Timer button:", self.timer_button)
        # self.timer_button.setGeometry(QRect(210, 0, 171, 31))
        self.timer = QTimer()
        self.timer.setInterval(1000)  # 1000ms = 1 second
        # self.timer.timeout.connect(self.update_countdown)
        if self.timer.isActive():
            print("Timer is active")
        self.countdown_duration = 15
        self.remaining_time = self.countdown_duration
        self.start_timer()

        self.ui.textButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(1))
        self.ui.emailButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(2))
        self.ui.noRecieptButton.clicked.connect(lambda: self.go_home())

        self.timer.timeout.connect(self.update_countdown)

        self.display_cart_items()

    def display_cart_items(self):
        #print("Reciept items:", self.cart.items)  # Debugging line
        # self.model.clear()  # Clear existing items
        for item in self.cart.items:
            # Add each item as a new list entry
            self.model.addItem(item)

        subtotal = self.cart.retrieve_subtotal()
        print(f"Subtotal: {subtotal}")  # Debugging
        self.ui.subtotalLabel.setText(f"Subtotal: ${subtotal:.2f}")
        
       
    def start_timer(self):
        self.remaining_time = 15
        self.ui.timeoutLabel.setText(f"Timeout in {self.remaining_time}s")
        self.timer.start()
        
    def update_countdown(self):
        self.remaining_time -= 1
        self.ui.timeoutLabel.setText(f"Timeout in {self.remaining_time}s")

        if self.remaining_time <= 0:
            self.timer.stop()
            self.go_home()
            
    def go_home(self):
        self.timer.stop()
        self.go_home_signal.emit()
    
    def timer_connected(self) -> bool:
        return self.timer.isActive()
        
    def run_timer(self):
        if self.timer_connected:
            self.start_timer()
