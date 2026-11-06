#!/bin/bash
# build-picolibc.sh <toolchain dir> <picolibc src> <work dir>
# Adds picolibc, one build per GCC multilib, to an installed v850-elf
# toolchain: headers in v850-elf/include, libc.a and libm.a in
# v850-elf/lib/<multilib dir>, so the compiler finds them with no options.
set -eu
TC=$(realpath "$1"); SRC=$(realpath "$2"); W=$3
mkdir -p "$W"; W=$(realpath "$W")
B=$W/picolibc-build
rm -rf "${B:?}"; mkdir -p "$B"
cat > "$W/cross.txt" <<CROSS
[binaries]
c = '$TC/bin/v850-elf-gcc'
ar = '$TC/bin/v850-elf-ar'
nm = '$TC/bin/v850-elf-nm'
strip = '$TC/bin/v850-elf-strip'

[host_machine]
system = 'none'
cpu_family = 'v850'
cpu = 'v850'
endian = 'little'

[properties]
skip_sanity_check = true

[built-in options]
c_args = ['-ffunction-sections', '-fdata-sections', '-fno-common', '-ffile-prefix-map=$SRC/=picolibc/', '-ffile-prefix-map=$B/=picolibc-build/']
c_link_args = ['-nostdlib']
CROSS
# No TLS (GCC v850 has emulated TLS only); retarget locks so an RTOS can
# back them with its mutexes; no crt0 (the board provides its own).
meson setup --cross-file "$W/cross.txt" \
	--prefix "$TC/v850-elf" --libdir lib --includedir include \
	--buildtype=custom -Doptimization=s -Ddebug=false \
	-Dmultilib=true -Dpicocrt=false -Dsemihost=false -Dtests=false \
	-Dspecsdir=none -Dthread-local-storage=false -Dsingle-thread=false \
	-Dstdio-locking=true \
	"$B" "$SRC" > "$W/picolibc-setup.log"
ninja -C "$B" -j "${JOBS:-32}" > "$W/picolibc-build.log"
meson install -C "$B" --quiet
git -C "$SRC" rev-parse HEAD > "$TC/v850-elf/picolibc-commit.txt"
echo "picolibc $(cat "$TC/v850-elf/picolibc-commit.txt") installed in $TC/v850-elf"
