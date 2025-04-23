import os
import core.config
from PySide6.QtCore import QObject, Signal, Property, Slot
from core.model import Model
from core.services.email import send_order_confirmation_email
from twilio.rest import Client
import json

class CheckoutController(QObject):
    notifyEmailInput = Signal()
    notifyPhoneInput = Signal()

    _email: str
    _phone_num: str
    _model: Model

    def __init__(self, model: Model):
        super().__init__()
        self._model = model
    
    @Property(float)
    def subtotal(self):
        return self._model._cart.get_subtotal()

    @Slot(str)
    def setPhoneNum(self, phone_num):
        self._phone_num = phone_num

    @Slot(str)
    def setEmail(self, email):
        """Stores the email entered by the user."""
        # TODO: Get email from db
        self._email = email

    @Slot()
    def send_email(self):
        """Sends the order confirmation email."""
        if not self._email:
             print("Email address not provided.")
             return
        
        items = list()
        for item in self._model._cart._items:
            item_dict = {key: value for key, value in item.__dict__.items() if key in ['name', 'price', 'quantity']}
            items.append(item_dict)
        try:
            send_order_confirmation_email(self._email, items, self.subtotal)
            self.notifyEmailInput.emit() # Notify success
        except Exception as e:
             print(f"Error sending email: {e}")

        self._email = "" # Clear email after attempting send

    @Slot()
    def send_sms(self):
        def shorten_string(s, max_length):
            if(len(s) > max_length):
                return s[:max_length-3].rstrip() + "..."
            return s
        
        account_sid = os.getenv("TWILIO_ACCOUNT_SID")
        auth_token = os.getenv("TWILIO_AUTH_TOKEN")
        from_phone_num = os.getenv("TWILIO_FROM_NUMBER")

        client = Client(account_sid, auth_token)

        items = list()
        for item in self._model._cart._items:
            product = shorten_string(item.name, 16)
            items.append(f"{item.quantity} {product}   ${item.price:.2f}")
        
        items_string = "\n".join(items)
        msg = f"""Thank you for purchasing from Bits 'n Bytes by Computer Science House @ Imagine RIT!\n\nOrder #0:\n{items_string}\nSubtotal: ${self._model._cart.get_subtotal():.2f}\nImagine RIT Credit: -${self._model._cart.get_subtotal():.2f}\nTOTAL: $0.00
        """

        client.messages.create(
            body=msg,
            from_=f"{from_phone_num}",
            to=f"+1{self._phone_num}"
        )
        self.notifyPhoneInput.emit()