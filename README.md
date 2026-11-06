# rh850-gcc-toolchain

Prebuilt GNU toolchain for Renesas RH850 (v850-elf), for Zephyr and NuttX CI.

v1.1.0
- The v1.0.0 binaries, unchanged
- picolibc 1.8.12 (github.com/linumiz/picolibc a1d2465, tag rh850-bsp-v1),
  built for all 8 GCC multilibs; RH850 uses v850e3v5 and soft-float/v850e3v5
- picolibc options: -Os, no TLS (errno is global), retarget locks, stdio
  locking, no crt0: the board provides its start file, link with -nostartfiles

v1.0.0
- binutils 2.43.1
- GCC 14.3.0 (releases/gcc-14.3.0), C and C++, libgcc
- GDB 16.2 with one v850 frame id fix, v850 simulator
- GMP 6.2.1, MPFR 4.1.0, MPC 1.2.1
- No C library: Zephyr builds picolibc, NuttX uses its own libc

Flags: -mv850e3v5 -mrh850-abi (soft float: add -msoft-float)

Host: x86_64 Linux, glibc 2.35 or newer. GDB needs libexpat1.

Install:
  mkdir -p /opt/toolchains/v850-elf
  tar -xzf v850-elf-toolchain-linux-x86_64.tar.gz -C /opt/toolchains/v850-elf
  export RH850_TOOLCHAIN_PATH=/opt/toolchains/v850-elf

Build v1.1.0 from the v1.0.0 asset (scripts/):
  curl -L -o v1.0.0.tar.gz https://github.com/linumiz/rh850-gcc-toolchain/releases/download/v1.0.0/v850-elf-toolchain-linux-x86_64.tar.gz
  docker build -t rh850-tc-build:22.04 scripts
  git clone https://github.com/linumiz/picolibc picolibc
  git -C picolibc checkout rh850-bsp-v1
  docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -e TMPDIR=/tmp -v $PWD:$PWD -w $PWD \
      rh850-tc-build:22.04 scripts/release.sh v1.0.0.tar.gz picolibc rel
