FROM ubuntu:22.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential ca-certificates git wget xz-utils bzip2 file rsync texinfo flex bison \
    python3 python3-venv pkg-config ninja-build libglib2.0-dev zlib1g-dev \
    libexpat1-dev libncurses-dev m4 python3-tomli meson && rm -rf /var/lib/apt/lists/*
