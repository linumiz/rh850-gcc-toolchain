# rh850-gcc-toolchain

Prebuilt GNU toolchain for Renesas RH850 (v850-elf), for Zephyr and NuttX CI.

v1.0.0
- binutils 2.43.1
- GCC 14.3.0 (releases/gcc-14.3.0), C and C++, libgcc
- GDB 16.2 with one v850 frame id fix, v850 simulator
- GMP 6.2.1, MPFR 4.1.0, MPC 1.2.1
- No C library: Zephyr builds picolibc, NuttX uses its own libc

Flags: -mv850e3v5 -mrh850-abi

Host: x86_64 Linux, glibc 2.35 or newer. GDB needs libexpat1.

Install:
  mkdir -p /opt/toolchains/v850-elf
  tar -xzf v850-elf-toolchain-linux-x86_64.tar.gz -C /opt/toolchains/v850-elf
  export RH850_TOOLCHAIN_PATH=/opt/toolchains/v850-elf
