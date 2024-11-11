import smartcard.System
import smartcard.util
from smartcard.CardRequest import CardRequest
from smartcard.CardType import AnyCardType
from PySide6.QtCore import QThread, Signal
import nfc

def scanCardUID():
	readers = smartcard.System.readers()
	print("selected reader: ", readers[0])

	if len(readers) == 0:
		print("error: no reader detected")
		exit()

	# reader = readers[0]

	print("Waiting for NFC Card... ")
	try:
		card_request  = CardRequest(timeout=None, cardType=AnyCardType())
		service = card_request.waitforcard()
	except smartcard.Exceptions.CardRequestTimeoutException:
		print("ERROR: card timeout.")
		return None

	# print("reader: ", reader);

	# connection = reader.createConnection()
	# connection.connect()

	service.connection.connect()

	# this allows us to get the card type, so we can check if a valid
	# card was used.
	a = service.connection.getATR() 
	# print(a)

	# run the appropriate command once to set whether the reader
	# makes a sound when it scans a card.
	# data, sw1, sw2 =service.connection.transmit(BUZZER_ON)
	BUZZER_OFF = [0xFF,0x00,0x52,0x00,0x00]
	BUZZER_ON  = [0xFF,0x00,0x52,0xFF,0x00]

	SELECT = [0xFF,0xCA,0x00,0x00,0x00]
	data, sw1, sw2 = service.connection.transmit(SELECT)
	assert (sw1 == 144 and sw2 == 0) # response -> sucessful operation
	# print(data) # UID to link to database

	service.connection.disconnect()
	stringUID = ""
	for num in data:
		stringUID += str(num)
	print("captured UID: " + stringUID)
	return stringUID


class NFCListenerThread(QThread):
	token_detected = Signal(str) # Signal to emit the NFC token
	
	def __init__(self):
		super().__init__()
		self.running = True  # Flag to control the thread loop

	def run(self):
		print("Inside run method")
		while True:
			token = nfc.scanCardUID()  # Scan for an NFC token
			if token != "" and token is not None:
				self.token_detected.emit(token)  # Emit the token if detected
				print("Emitted token")
				self.exit()

	def stop(self):
		self.running = False  # Set the flag to stop the loop
		self.quit()  # Stop the thread
		print("Stopped NFC thread")

if __name__ == "__main__":
	scanCardUID()
