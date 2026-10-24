#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_TAG="bits_n_bytes_ui-linux"

sudo docker build -t "$IMAGE_TAG" "$PROJECT_DIR"

sudo docker run --rm -it \
  --name bits_n_bytes_ui \
  -p 5900:5900 \
  --device /dev/ttyAMA0:/dev/ttyAMA0 \
  --device /dev/ttyAMA3:/dev/ttyAMA3 \
  --device /dev/ttyAMA4:/dev/ttyAMA4 \
  "$IMAGE_TAG"
