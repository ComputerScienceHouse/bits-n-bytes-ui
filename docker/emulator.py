#!/usr/bin/env python3
"""Bits n Bytes serial emulator — true virtual serial via PTYs.

socat creates each pair (e.g. /tmp/esp <-> /tmp/esp_dev). The Flutter app opens the
ESP/Jetson/NFC ends with libserialport + termios; this writes framed bytes to the *_dev
ends. App and emulator share the Pi's kernel, so this is real serial, not a socket.

Frames match serial_service_real.dart's parsers exactly:
  ESP/Jetson -> bare {...} JSON objects   (_onJsonDataReceived)
  NFC        -> fixed 7-byte packets       (_onBinaryDataReceived, payloadSize=7)

Usage: bnb-emulator.py <esp_dev> <jetson_dev> <nfc_dev>
"""
import json, os, struct, sys, threading, time


def log(m):
    print(f"[bnb-sim] {m}", flush=True)


def open_pty(path):
    # Wait for socat to create the symlink, then open the *_dev end raw.
    for _ in range(50):
        if os.path.exists(path):
            return os.open(path, os.O_RDWR | os.O_NOCTTY)
        time.sleep(0.1)
    raise FileNotFoundError(f"PTY never appeared: {path}")


def reader(name, fd):
    # Log the app's OUTBOUND writes (door/hatch cmds, NFC init) so they're visible.
    try:
        while True:
            data = os.read(fd, 64)
            if data:
                log(f"{name} <- app: {data.hex()}")
    except OSError:
        pass


def esp(fd):
    while True:
        frame = {"doors": False, "hatch": False, "temp_c": 42,
                 "intake_rpm": 1000, "exhaust_rmp": 1000,
                 "shelf_ids": ["MAC_1", "MAC_2", "MAC_3"]}
        os.write(fd, json.dumps(frame, separators=(",", ":")).encode())
        time.sleep(float(os.getenv("ESP_INTERVAL", "2")))


def jetson(fd):
    for item_id in (1, 2, 3):                       # seed a few items into the cart
        os.write(fd, f'{{"id":{item_id},"quantity":1}}'.encode())
        time.sleep(3)
    while True:                                     # then add/remove one repeatedly
        os.write(fd, b'{"id":1,"quantity":1}');  time.sleep(5)
        os.write(fd, b'{"id":1,"quantity":-1}'); time.sleep(5)


def nfc(fd):
    uid = int(os.getenv("NFC_UID", "12345"))        # 4-byte BE UID + 3 pad = 7 bytes
    time.sleep(2)
    while True:
        os.write(fd, struct.pack(">I", uid) + b"\x00\x00\x00")
        time.sleep(10)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        sys.exit("usage: bnb-emulator.py <esp_dev> <jetson_dev> <nfc_dev>")
    for name, path, producer in [("ESP", sys.argv[1], esp),
                                 ("Jetson", sys.argv[2], jetson),
                                 ("NFC", sys.argv[3], nfc)]:
        fd = open_pty(path)
        threading.Thread(target=reader, args=(name, fd), daemon=True).start()
        threading.Thread(target=producer, args=(fd,), daemon=True).start()
        log(f"{name} writing to {path}")
    log("emulator up — true virtual serial via PTYs")
    while True:
        time.sleep(3600)