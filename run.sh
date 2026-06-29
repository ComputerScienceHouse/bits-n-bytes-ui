#!/usr/bin/env bash
# bnb — Bits n Bytes dev/build CLI. Alias it:  alias bnb="$PWD/run.sh"
#
#   bnb run dev [--stream]   run the kiosk on the Pi in a container: real GPU (DRM/KMS),
#                            true virtual serial (PTYs + emulator), hot reload.
#                            --stream also captures the KMS framebuffer to your laptop (Moonlight).
#   bnb build                build the release flutter-pi bundle and push to the GitHub Actions
#                            self-hosted runner on the Pi, which deploys it to production.
set -euo pipefail

# Resolve symlinks so `bnb` can live on PATH and still find the repo (portable: no readlink -f).
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
cd "$(cd -P "$(dirname "$SOURCE")" && pwd)"

IMAGE=bnb-kiosk
NAME=bnb-dev

usage() { echo "usage: bnb run dev [--stream] | bnb run sim | bnb build"; exit 1; }

# ── bnb run dev ───────────────────────────────────────────────────────────────
# Everything runs in ONE container on the Pi. socat mints the PTY pairs, the emulator
# feeds the *_dev ends, and SerialServiceReal opens the app-facing ends => true virtual
# serial (one kernel, no TCP bridge). The inline `bash -c` keeps it all in this one file.
dev() {
  local stream="${1:-}"
  docker build -t "$IMAGE" -f docker/Dockerfile .
  docker rm -f "$NAME" >/dev/null 2>&1 || true

  # DRM/permission note: capturing/streaming the KMS framebuffer while the production
  # flutter-pi already owns the display may need a DRM lease or video/render group perms.
  docker run --rm -it --name "$NAME" \
    --device /dev/dri --device /dev/input \
    --group-add video --group-add input \
    -v "$PWD":/app -w /app \
    -p 47984-48010:47984-48010/tcp -p 47998-48000:47998-48000/udp \
    -e BNB_STREAM="$stream" -e BNB_PROFILE="${BNB_PROFILE:-}" \
    "$IMAGE" bash -c '
      set -e
      for d in esp jetson nfc; do
        socat pty,raw,echo=0,b9600,link=/tmp/$d pty,raw,echo=0,b9600,link=/tmp/${d}_dev &
      done
      sleep 1
      python3 /usr/local/bin/bnb-emulator.py /tmp/esp_dev /tmp/jetson_dev /tmp/nfc_dev &
      if [ -n "$BNB_STREAM" ]; then
        echo "[bnb] --stream: starting Sunshine KMS capture (Moonlight on your laptop)"
        if command -v sunshine >/dev/null; then sunshine & else echo "[bnb] sunshine not installed in image"; fi
      fi
      flutter pub get
      # SerialServiceReal opens these PTYs with termios -> exercises the real serial path.
      export FORCE_SERIAL=true ESP_PORT=/tmp/esp JETSON_PORT=/tmp/jetson NFC_PORT=/tmp/nfc
      # debug build = hot reload. For jitter measurement run with --profile instead.
      flutterpi_tool run ${BNB_PROFILE:+--profile}
    '
}

# ── bnb run sim ───────────────────────────────────────────────────────────────
# Lightweight, GPU-free validation that runs on ANY host (incl. macOS). Brings up the
# PTY pairs + emulator and asserts ESP/Jetson/NFC frames arrive intact. No Flutter/flutter-pi.
sim() {
  docker build -t bnb-sim -f docker/Dockerfile.sim docker/
  docker run --rm --name bnb-sim bnb-sim bash -c '
    set -e
    for d in esp jetson nfc; do
      socat pty,raw,echo=0,b9600,link=/tmp/$d pty,raw,echo=0,b9600,link=/tmp/${d}_dev &
    done
    sleep 1
    python3 /usr/local/bin/bnb-emulator.py /tmp/esp_dev /tmp/jetson_dev /tmp/nfc_dev &
    python3 /usr/local/bin/bnb-sim-check.py /tmp/esp /tmp/jetson /tmp/nfc
  '
}

# ── bnb build ─────────────────────────────────────────────────────────────────
# Build the release bundle in the container, then push to trigger the Pi's self-hosted
# GitHub Actions runner (deploy-pi.yml), which rebuilds + restarts the kiosk in production.
build() {
  docker build -t "$IMAGE" -f docker/Dockerfile .
  docker run --rm -v "$PWD":/app -w /app "$IMAGE" bash -c '
    flutter pub get && flutterpi_tool build --arch=arm64 --cpu=pi4 --release
  '
  echo "[bnb] release bundle built at ./build/flutter_assets"
  git push origin HEAD
  command -v gh >/dev/null && gh workflow run deploy-pi.yaml --ref "$(git branch --show-current)" \
    && echo "[bnb] triggered deploy-pi.yml — Pi runner deploying to production."
}

case "${1:-}" in
  run)
    case "${2:-}" in
      dev) dev "${3:-}" ;;
      sim) sim ;;
      *)   usage ;;
    esac ;;
  build) build ;;
  *)     usage ;;
esac