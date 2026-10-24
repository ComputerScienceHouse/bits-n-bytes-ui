#!/bin/bash
set -e

Xvfb :99 -screen 0 1280x800x24 &
XVFB_PID=$!

for i in $(seq 1 20); do
  if xdpyinfo -display :99 >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

x11vnc -display :99 -forever -shared -nopw -rfbport 5900 -bg -o /var/log/x11vnc.log

export DISPLAY=:99
export LIBGL_ALWAYS_SOFTWARE=1

flutter pub get
exec flutter run -d linux
