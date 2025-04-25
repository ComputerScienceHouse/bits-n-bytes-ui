###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
from PySide6.QtCore import QObject, Slot, Property, Signal
from PySide6.QtWidgets import QApplication
from core.services.nfc import NFCListenerThread
from core.model import Model, Cart, User, ShelfManager
from core.database import get_user
from . import CartController, CheckoutController, AdminController, TareController, DeviceController
from core import database

class Controller(QObject):
    _model: Model
    _cart: Cart
    _shelf_manager: ShelfManager
    _nfc: NFCListenerThread
    _admin_controller: AdminController
    _cart_controller: CartController
    _checkout_controller: CheckoutController
    _tare_controller: TareController
    _nfc_signal = Signal(str)

    def __init__(self):
        super().__init__()
        self._nfc = NFCListenerThread()
        self._cart = Cart()
        self._model = Model()
        self._shelf_manager = ShelfManager(add_cart_item_cb=self.add_item_to_cart_cb, remove_cart_item_cb=self.remove_item_from_cart_cb)

        self._cart_controller = CartController(self._model._cart)
        self._checkout_controller = CheckoutController(self._model)
        self._tare_controller = TareController(self._shelf_manager)
        self._admin_controller = AdminController()
        self._device_controller = DeviceController()

    @Property(QObject, constant=True)
    def admin(self):
        return self._admin_controller

    @Property(QObject, constant=True)
    def checkout(self):
        return self._checkout_controller

    @Property(QObject, constant=True)
    def tare(self):
        return self._tare_controller
    
    @Property(QObject, constant=True)
    def cart(self):
        return self._cart_controller

    @Property(QObject, constant=True)
    def device(self):
        return self._device_controller
        
    @Slot(result=str)
    def getName(self):
        return self._model.get_user_name()
    
    @Slot()
    def runNFC(self):
        if self.is_welcome_active:
            self._nfc.run()
        else:
            self.stopNFC()

    @Slot()
    def start_shelf_manager(self):
        self._model._shelf_manager.start_loop()

    @Slot()
    def exit(self):
        self._model._shelf_manager.stop_loop()
        QApplication.instance().quit()

    @Slot()
    def wait_for_nfc(self):
        print("loaded nfc slot")
        self._nfc.token_detected.connect(self.emit_nfc)
        self._nfc.start()

    @Slot(str)
    def emit_nfc(self, msg):
        # print("recieved emitter: ", msg)
        user = database.get_user(nfc_id=msg)
        # print("User: ", user)
        if(user == None):
            print("NO USER FOUND")
            self._model._current_user = None
            self._nfc.stop()
            self._nfc_signal.emit("")
            self._nfc = NFCListenerThread()
            self.wait_for_nfc()
        else:
            self._model._current_user = user
            self._nfc_signal.emit(msg)
            self._nfc.stop()
            self._nfc = NFCListenerThread()
