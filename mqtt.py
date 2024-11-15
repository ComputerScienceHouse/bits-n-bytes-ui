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
open_hatch_topic = "aux/control/hatch"
open_doors_and_hatch_msg = "open"
shelf_data_topic = "shelf/data"

client = mqtt.Client()
client.connect(broker, port)
client.subscribe(shelf_data_topic)

client.loop_start()

shelf_data_received_callback = None

def open_doors() -> bool:
    """
    Send a MQTT message to open the cabinet doors.

    Returns:
        bool: True if the message sent successfully, False otherwise.
    """
    result = client.publish(open_doors_topic, open_doors_and_hatch_msg)
    status = result[0]
    return status == 0


def open_hatch() -> bool:
    """
    Send a MQTT message to open the hatch doors.

    Returns:
        bool: True if the message sent successfully, False otherwise.
    """
    result = client.publish(open_hatch_topic, open_doors_and_hatch_msg)
    status = result[0]
    return status == 0


def on_message(client, userdata, msg):
    if msg.topic == shelf_data_topic:
        if callable(shelf_data_received_callback):
            shelf_data_received_callback(client, userdata, msg)
