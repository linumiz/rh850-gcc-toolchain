#!/bin/bash
# release.sh <v1.0.0 tarball> <picolibc src> <out dir>
# v1.1.0 = the v1.0.0 toolchain (same binutils, GCC, GDB binaries) plus
# picolibc for every GCC multilib. Run inside the image of ./Dockerfile.
set -eu
TAR=$(realpath "$1"); SRC=$(realpath "$2"); OUT=$3
mkdir -p "$OUT"; OUT=$(realpath "$OUT")
HERE=$(dirname "$(realpath "$0")")
TC=$OUT/stage/opt/toolchains/v850-elf
rm -rf "${OUT:?}/stage" "$OUT/work"; mkdir -p "$TC"
tar -xzf "$TAR" -C "$TC"
"$HERE/build-picolibc.sh" "$TC" "$SRC" "$OUT/work"
tar -czf "$OUT/v850-elf-toolchain-linux-x86_64.tar.gz" --owner=0 --group=0 \
	--sort=name --mtime=@0 -C "$TC" .
(cd "$OUT" && sha256sum v850-elf-toolchain-linux-x86_64.tar.gz > SHA256SUMS)
cat "$OUT/SHA256SUMS"
