#!/usr/bin/env python3
"""bnb run sim — validate the virtual-serial plumbing on any host (no GPU/Flutter).

Opens the app-facing PTY ends (esp/jetson/nfc) that socat created, reads what the
emulator writes, frames it with the SAME logic as serial_service_real.dart, and
asserts ESP/Jetson JSON objects and a 7-byte NFC packet arrive intact.

Exits 0 on success, 1 on timeout/failure.
Usage: sim_check.py <esp> <jetson> <nfc>
"""
import json, os, struct, sys, threading, time

TIMEOUT = float(os.getenv("SIM_TIMEOUT", "20"))
results = {"esp": None, "jetson": None, "nfc": None}


def log(m):
    print(f"[bnb-sim-check] {m}", flush=True)


def frame_json(buf):
    """Yield complete {...} objects from a byte buffer -> (objects, remainder bytes)."""
    s = buf.decode(errors="ignore")
    objs = []
    while True:
        start = s.find("{")
        if start < 0:
            return objs, b""
        s = s[start:]
        depth, end = 0, -1
        for i, c in enumerate(s):
            if c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end < 0:
            return objs, s.encode()
        try:
            objs.append(json.loads(s[:end + 1]))
        except json.JSONDecodeError:
            pass
        s = s[end + 1:]


def watch_json(name, path, want_key):
    try:
        fd = os.open(path, os.O_RDWR | os.O_NOCTTY)
        buf = b""
        while results[name] is None:
            buf += os.read(fd, 128)
            objs, buf = frame_json(buf)
            for o in objs:
                if want_key in o:
                    results[name] = o
                    log(f"{name}: OK -> {o}")
                    return
    except OSError as e:
        log(f"{name}: read error {e}")


def watch_nfc(path):
    try:
        fd = os.open(path, os.O_RDWR | os.O_NOCTTY)
        buf = b""
        while results["nfc"] is None:
            buf += os.read(fd, 16)
            if len(buf) >= 7:
                pkt = buf[:7]
                uid = struct.unpack(">I", pkt[:4])[0]   # matches getUint32(0) in welcome.dart
                results["nfc"] = uid
                log(f"nfc: OK -> uid={uid} ({pkt.hex()})")
                return
    except OSError as e:
        log(f"nfc: read error {e}")


if __name__ == "__main__":
    if len(sys.argv) < 4:
        sys.exit("usage: sim_check.py <esp> <jetson> <nfc>")
    esp_p, jetson_p, nfc_p = sys.argv[1:4]
    for t in (
        threading.Thread(target=watch_json, args=("esp", esp_p, "doors"), daemon=True),
        threading.Thread(target=watch_json, args=("jetson", jetson_p, "id"), daemon=True),
        threading.Thread(target=watch_nfc, args=(nfc_p,), daemon=True),
    ):
        t.start()

    start = time.time()
    while time.time() - start < TIMEOUT:
        if all(v is not None for v in results.values()):
            log("ALL CHECKS PASSED ✅  (PTYs + emulator + framing OK)")
            sys.exit(0)
        time.sleep(0.2)
    missing = [k for k, v in results.items() if v is None]
    log(f"TIMEOUT ❌ after {TIMEOUT:.0f}s — missing: {missing}")
    sys.exit(1)
