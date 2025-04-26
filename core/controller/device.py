import os
import json
import core.config
from core.services.mqtt import MqttClient
from PySide6.QtCore import QObject, Signal, Slot   

open_doors_topic = "aux/control/doors"
open_hatch_topic = "aux/control/hatch"
open_doors_and_hatch_msg = "open"
shelf_data_topic = "shelf/data"
doors_status_topic = "aux/status/doors"
hatch_status_topic = "aux/status/hatch"

MQTT_LOCAL_BROKER_URL = os.getenv('MQTT_LOCAL_BROKER_URL', None)
MQTT_REMOTE_BROKER_URL = os.getenv('', None)

class DeviceController(QObject):
    hatchUnlock = Signal()
    doorsUnlock = Signal()
    doorsClosed = Signal()

    _mqttRemoteClient: MqttClient | None
    _mqttLocalClient: MqttClient | None

    def __init__(self):
        super().__init__()
        self._input = []
        try:
            # Load pattern during initialization
            self._pattern = json.loads(os.getenv("BNB_ADMIN_PATTERN", "[]"))
        except json.JSONDecodeError:
            print("Warning: Invalid BNB_ADMIN_PATTERN environment variable.")
            self._pattern = [] # Default to empty if invalid

        if MQTT_LOCAL_BROKER_URL is not None and MQTT_LOCAL_BROKER_URL != '':
            self._mqttLocalClient = MqttClient(MQTT_LOCAL_BROKER_URL, 1883)
            self._mqttLocalClient.add_topic(doors_status_topic, self.notifyDoorUnlock, qos=0)
            self._mqttLocalClient.add_topic(hatch_status_topic, self.notifyHatchUnlock, qos=1)
            self._mqttLocalClient.start()
        else:
            self._mqttLocalClient = None
        if MQTT_REMOTE_BROKER_URL is not None and MQTT_REMOTE_BROKER_URL != '':
            self._mqttRemoteClient = MqttClient(MQTT_REMOTE_BROKER_URL, 1883)
            self._mqttRemoteClient.add_topic(doors_status_topic, self.notifyDoorUnlock, qos=0)
            self._mqttRemoteClient.add_topic(hatch_status_topic, self.notifyHatchUnlock, qos=1)
            self._mqttRemoteClient.start()
        else:
            self._mqttRemoteClient = None

    def notifyDoorUnlock(self, msg: str):
        if msg == "open":
            self.doorsUnlock.emit()
        if msg == "closed":
            self.doorsClosed.emit()
        else:
            print("Unknown message received: ", msg)

    def notifyHatchUnlock(self, msg: str):
        if msg == "open":
            self.hatchUnlock.emit()
        else:
            print("Unknown message recieved: ", msg)

    @Slot(result=bool)
    def open_doors(self):
        if self._mqttLocalClient is not None:
            #result = self._mqttLocalClient.post_message(open_doors_topic, open_doors_and_hatch_msg)
            return result[0] == 0
        else:
            return False

    @Slot(result=bool)
    def open_hatch(self):
        if self._mqttLocalClient is not None:
            result = self._mqttLocalClient.post_message(open_hatch_topic, open_doors_and_hatch_msg)
            return result[0] == 0
        else:
            return False