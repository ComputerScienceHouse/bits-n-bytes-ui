# FROM debian:bookworm

# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     curl git unzip xz-utils ca-certificates \
#     clang cmake ninja-build pkg-config \
#     libgtk-3-dev liblzma-dev libstdc++-12-dev \
#     libudev-dev \
#     libgl1-mesa-dri libglx-mesa0 mesa-utils \
#     && rm -rf /var/lib/apt/lists/*

# ENV FLUTTER_HOME=/opt/flutter
# RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME \
#     && cd $FLUTTER_HOME \
#     && git checkout e74c595450
# ENV PATH="$FLUTTER_HOME/bin:$PATH"

# RUN flutter config --enable-linux-desktop --no-analytics \
#     && flutter precache --linux

# WORKDIR /home/bnbui/bits_n_bytes_ui

# CMD ["bash", "-c", "flutter pub get && flutter run -d linux"]


# Use a standard Ubuntu base
FROM ubuntu:22.04

# Avoid tzdata interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install core dependencies and Flutter Linux desktop requirements
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    xvfb x11vnc x11-utils \
    libgl1-mesa-dri libglx-mesa0 \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter (stable channel)
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter

# Add Flutter to PATH
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run basic flutter setup
RUN flutter config --enable-linux-desktop
RUN flutter doctor

# Set the working directory
WORKDIR /app

# Copy your project files
COPY . .

# Get dependencies
RUN flutter pub get

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5900

# Runs Xvfb + x11vnc, then launches the Flutter app against the virtual display
CMD ["/docker-entrypoint.sh"]