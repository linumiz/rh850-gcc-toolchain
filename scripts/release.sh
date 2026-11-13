#!/bin/bash
# release.sh <source dir> <work dir> <out dir>
# v1.2.0: build the toolchain from the release source archives and pack it.
# Run inside the image of ./Dockerfile with /opt/toolchains/v850-elf
# writable and empty.
set -eu
SRC=$(realpath "$1"); W=$2; OUT=$3
mkdir -p "$W" "$OUT"; W=$(realpath "$W"); OUT=$(realpath "$OUT")
HERE=$(dirname "$(realpath "$0")")
TC=/opt/toolchains/v850-elf
"$HERE/build-toolchain.sh" "$SRC" "$W"
tar -czf "$OUT/v850-elf-toolchain-linux-x86_64.tar.gz" --owner=0 --group=0 \
	--sort=name --mtime=@0 -C "$TC" .
(cd "$OUT" && sha256sum v850-elf-toolchain-linux-x86_64.tar.gz > SHA256SUMS)
cat "$OUT/SHA256SUMS"
