# rh850-gcc-toolchain

Prebuilt GNU toolchain for Renesas RH850 (v850-elf), for Zephyr and NuttX CI.

v1.2.0
- Built from source (scripts/build-toolchain.sh), not from the v1.0.0 binaries
- GCC 14.3.0 with the Zephyr SDK GCC patches and the RH850 series
  (github.com/zephyrproject-rtos/gcc zephyr-gcc-14.3.0 + RH850 commits, 562bfbd51bb):
  C, C++, libgcc, libstdc++ (cstdio stdio_pure, no wchar_t, no verbose terminate)
- binutils 2.43.1 (Zephyr SDK base + RH850 series, 3615d17e8db); ar defaults to
  deterministic archives (D)
- GDB 16.2 with the v850 simulator (Zephyr SDK base + RH850 series, 8857b22c713),
  no Python
- picolibc 1.8.12 (picolibc main + RH850 series, 4be0e6348f) for every multilib, with
  the v1.1.0 options: -Os, no TLS, retarget locks, stdio locking, no crt0, no
  semihost, no specs (the board provides its start file, link with -nostartfiles)
- GMP 6.2.1, MPFR 4.1.0, MPC 1.2.1
- 16 multilibs: default, gcc-abi, soft-float and the v850e3v5, v850e3v5/g4 and
  v850e3v5/g4/fxu variants; RH850 U2C uses v850e3v5 (or v850e3v5/g4 with -mg4),
  U2B/U2A use v850e3v5/g4/fxu with -mfxu
- New since v1.1.0: -mg4, -mg4mh2 and -mfxu (G4KH, G4MH2, FXU vector unit),
  inline atomics, CLIP, RH850 interrupt handlers (eiret, FPU/FXU state, CFI),
  fenv for the FPU and the FXU, ZDA addressing under the RH850 ABI, CFI fixes,
  volatile bit operations no longer narrowed to set1/clr1/not1, gas range checks
  for PC-relative branches and loop relaxation, GDB frame unwinding fixes and
  the G4 simulator instructions
- Source archives and their commits: release assets (COMMITS, SHA256SUMS);
  v850-elf/source-commits.txt in the toolchain lists them too

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

Build v1.2.0 from the release source archives (scripts/; byte-identical result):
  mkdir -p src work tc rel   # src: the source archives and COMMITS of the release
  docker build -t rh850-tc-build:22.04 scripts
  docker run --rm -u $(id -u):$(id -g) -e HOME=/work -e TMPDIR=/work/tmp -e JOBS=16 \
      -v $PWD/src:/src:ro -v $PWD/scripts:/scripts:ro -v $PWD/work:/work \
      -v $PWD/tc:/opt/toolchains/v850-elf -v $PWD/rel:/out \
      rh850-tc-build:22.04 sh -c 'mkdir -p /work/tmp && /scripts/release.sh /src /work /out'
  cat rel/SHA256SUMS

Build v1.1.0: see the scripts and README of tag v1.1.0.

Copyright 2026 Linumiz. License: Apache-2.0 for the build scripts and Dockerfile in
this repository. The components keep their own: GPL for GCC, binutils, GDB and QEMU,
BSD for picolibc.
