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
from typing import Callable
import paho.mqtt.client as mqtt_client


class MqttClient:
    _broker: str
    _port: int
    _topic_callbacks: dict
    _client: mqtt_client


    def __init__(self, broker_url: str, port: int):
        """
        Create a new MQTT Client
        :param broker_url: The URL of the broker
        :param port: The port of the broker
        """
        self._broker = broker_url
        self._port = port
        self._topic_callbacks = dict()
        self._client = mqtt_client.Client()
        self._client.connect(broker_url, port)
        self._client.on_message = self._on_message

    def post_message(self, topic: str, message: str, qos: int = 0):
        """
        :param topic: The name of the topic
        :param message: The message to send to the client
        :return: result from posting message
        """
        result = self._client.publish(topic, message, qos)
        return result
    
    def add_topic(self, topic: str, callback: Callable[[str], None], qos=0) -> None:
        """
        Add a topic this client will listen to.
        :param topic: The name of the topic
        :param callback: A callable for when a message is received on this topic,
        with a string argument that is the message.
        :param qos: The quality of service
        :return: None
        """
        self._topic_callbacks[topic] = callback
        self._client.subscribe(topic, qos=qos)


    def remove_topic(self, topic: str) -> None:
        """
        Remove a topic from this client.
        :param topic: The name of the topic
        :return: None
        """
        if topic in self._topic_callbacks:
            self._client.unsubscribe(topic)
        del self._topic_callbacks[topic]


    def _on_message(self, client, userdata, msg):
        # Check if this topic has a known callback function
        if msg.topic in self._topic_callbacks:
            callback = self._topic_callbacks[msg.topic]
            # Execute the callback function
            callback(msg.payload.decode('utf-8'))


    def start(self):
        """
        Start the client loop
        :return:
        """
        self._client.loop_start()


    def stop(self):
        """
        Stop the client loop
        :return:
        """
        self._client.loop_stop()