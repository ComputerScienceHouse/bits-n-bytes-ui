###############################################################################
#
# File: app_controller.py
#
# Purpose: Provide callback functions for various UI elements like buttons that
# will be used to interface with the model.
#
###############################################################################
from PySide6.QtCore import QObject, Slot, Property
from PySide6.QtWidgets import QApplication
from core.services.nfc import NFCListenerThread
from core.model import Model, Cart
from . import CartController, CheckoutController, AdminController, TareController

class Controller(QObject):
    _model: Model
    _cart: Cart
    _nfc: NFCListenerThread
    _admin_controller: AdminController
    _cart_controller: CartController
    _checkout_controller: CheckoutController
    _tare_controller: TareController

    def __init__(self):
        super().__init__()
        self._nfc = NFCListenerThread()
        self._model = Model()
        self._cart = Cart()
        self._cart_controller = CartController(self._model._cart)
        self._checkout_controller = CheckoutController(self._model)
        self._tare_controller = TareController(self._model._shelf_manager)
        self._admin_controller = AdminController()

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
    def stopNFC(self):
        self._nfc.stop()

    @Slot()
    def start_shelf_manager(self):
        self._model._shelf_manager.start_loop()

    @Slot()
    def exit(self):
        self._model._shelf_manager.stop_loop()
        QApplication.instance().quit()


if __name__ == "__main__":
    app = Controller()
    app.send_email()

