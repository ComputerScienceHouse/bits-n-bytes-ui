# Bits n Bytes kiosk — dev + runtime container, built FOR and run ON the production Pi (arm64).
#
# Bundles everything the edgeless dev loop needs:
#   - flutter-pi            : real VideoCore VI rendering via DRM/KMS (passed in at runtime: --device /dev/dri)
#   - Flutter SDK + flutterpi_tool : build the release bundle and run with hot reload
#   - socat + python3       : true virtual serial (PTYs live in the Pi's kernel, same as the app)
#
# GPU/input devices are NOT baked in — they are passed at `docker run` time (see run.sh).
# NOTE: pin the flutter / flutter-pi / engine versions for reproducibility before relying on this in CI.
FROM --platform=linux/arm64 debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/root/.pub-cache/bin:${PATH}"

# --- flutter-pi build deps, Mesa/GPU userland, serial sim, tooling ---
RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl unzip xz-utils ca-certificates \
      cmake pkg-config build-essential ninja-build \
      libgl1-mesa-dri libegl1-mesa libgles2-mesa libdrm2 libgbm1 \
      libinput10 libxkbcommon0 libudev1 libsystemd0 libffi8 \
      libegl-dev libgles-dev \
      libdrm-dev libgbm-dev libsystemd-dev libinput-dev libxkbcommon-dev libudev-dev \
      socat python3 \
 && rm -rf /var/lib/apt/lists/*

# --- Flutter SDK (provides dart + flutter, drives flutterpi_tool) ---
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /opt/flutter \
 && git config --global --add safe.directory /opt/flutter \
 && flutter config --no-analytics \
 && flutter precache --universal

# --- flutter-pi embedder (built from source for arm64; engine .so is fetched by flutterpi_tool) ---
RUN git clone --depth 1 https://github.com/ardera/flutter-pi.git /opt/flutter-pi \
 && cmake -S /opt/flutter-pi -B /opt/flutter-pi/build -DCMAKE_BUILD_TYPE=Release \
 && cmake --build /opt/flutter-pi/build --target install -j"$(nproc)"

# --- flutterpi_tool: builds/runs the app bundle for flutter-pi ---
RUN dart pub global activate flutterpi_tool

# Emulator ships in the image; the Flutter project source is bind-mounted at /app at runtime.
COPY docker/emulator.py /usr/local/bin/bnb-emulator.py

# Optional: Sunshine for KMS-capture streaming (bnb run dev --stream). Install the arm64 .deb here
# if you want it baked in; left out to keep the image lean. Moonlight ports are published in run.sh.

WORKDIR /app
ENTRYPOINT ["/bin/bash"]