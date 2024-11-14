###############################################################################
#
# File: mqtt.py
#
# Author: Isaac Ingram
#
# Purpose: Provide MQTT facilities for the UI to send and receive data from the
# cabinet.
#
###############################################################################
import os

import paho.mqtt.client as mqtt

# TODO update broker URI with local broker
broker = os.environ.get("MQTT_BROKER", 'test.mosquitto.org')
port = 1883
open_doors_topic = "aux/control/doors"
open_doors_msg = "open"

client = mqtt.Client()
client.connect(broker, port)

def open_doors() -> bool:
    """
    Send a MQTT message to open the cabinet doors.

    Returns:
        bool: True if the message sent successfully, False otherwise.
    """
    result = client.publish(open_doors_topic, open_doors_msg)
    status = result[0]
    return status == 0

client.loop_start()
