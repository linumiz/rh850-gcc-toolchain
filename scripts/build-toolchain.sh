#!/bin/bash
# build-toolchain.sh <source dir> <work dir>
# v1.2.0: binutils, GCC (C, C++, libgcc, libstdc++), picolibc and GDB with
# the simulator for v850-elf, installed to /opt/toolchains/v850-elf.
# <source dir> holds the release source archives and COMMITS.
# Run inside the image of ./Dockerfile.
set -eu
S=$(realpath "$1"); W=$2; mkdir -p "$W"; W=$(realpath "$W")
HERE=$(dirname "$(realpath "$0")")
P=/opt/toolchains/v850-elf; H=$W/hostlibs; J=-j${JOBS:-16}
src() { sed -n "s/^\($1-[^ ]*\) .*/\1/p" "$S/COMMITS"; }
commit() { sed -n "s/^$1-[^ ]* //p" "$S/COMMITS"; }
cd "$W"
for a in "$S"/*.tar.*; do case $a in */qemu-*) ;; *) tar -xf "$a" ;; esac; done
for p in gmp-6.2.1 mpfr-4.1.0 mpc-1.2.1; do
	mkdir -p b-$p && (cd b-$p && ../$p/configure --prefix=$H --disable-shared --enable-static \
		$([ $p = gmp-6.2.1 ] || echo --with-gmp=$H) $([ $p = mpc-1.2.1 ] && echo --with-mpfr=$H) \
		> log 2>&1 && make $J > log 2>&1 && make install >> log 2>&1)
done
mkdir -p b-binutils && cd b-binutils
../$(src binutils)/configure --target=v850-elf --prefix=$P --disable-nls --disable-werror \
	--disable-gdb --disable-sim --enable-deterministic-archives > log 2>&1
make $J > log 2>&1 && make install-strip >> log 2>&1
cd "$W"
# Stage 1: C compiler and libgcc only, to build picolibc.
G=$W/$(src gcc); S1=$W/stage1
mkdir -p b-gcc1 && cd b-gcc1
$G/configure --target=v850-elf --prefix=$S1 --enable-languages=c --without-headers --with-newlib \
	--disable-nls --disable-shared --disable-threads --disable-libssp --disable-libquadmath \
	--disable-libgomp --disable-libatomic --with-gnu-as --with-gnu-ld \
	--with-as=$P/bin/v850-elf-as --with-ld=$P/bin/v850-elf-ld --with-build-time-tools=$P/v850-elf/bin \
	--with-gmp=$H --with-mpfr=$H --with-mpc=$H > log 2>&1
make $J all-gcc all-target-libgcc > log 2>&1 && make install-gcc install-target-libgcc >> log 2>&1
cd "$W"
mkdir -p stage1-tc/bin
for t in "$P"/bin/v850-elf-*; do ln -sf "$t" stage1-tc/bin/; done
ln -sf $S1/bin/v850-elf-gcc stage1-tc/bin/v850-elf-gcc
PICOLIBC_COMMIT=$(commit picolibc) PICOLIBC_BIN=$W/stage1-tc/bin JOBS=${JOBS:-16} \
	"$HERE/build-picolibc.sh" "$P" "$W/$(src picolibc)" "$W/picolibc"
# Final GCC against picolibc; libstdc++ as tested in TC41b (stdio_pure, no
# verbose terminate, no wchar_t).
mkdir -p b-gcc && cd b-gcc
$G/configure --target=v850-elf --prefix=$P --enable-languages=c,c++ --with-newlib \
	--disable-nls --disable-shared --disable-threads --disable-libssp --disable-libquadmath \
	--disable-libgomp --disable-libatomic --disable-libsanitizer --with-gnu-as --with-gnu-ld \
	--with-build-time-tools=$P/v850-elf/bin --with-gmp=$H --with-mpfr=$H --with-mpc=$H \
	--enable-__cxa_atexit --enable-cstdio=stdio_pure --disable-libstdcxx-verbose \
	--disable-wchar_t > log 2>&1
make $J all-gcc all-target-libgcc all-target-libstdc++-v3 > log 2>&1
make install-strip-gcc install-strip-target-libgcc install-strip-target-libstdc++-v3 >> log 2>&1
cd "$W"
mkdir -p b-gdb && cd b-gdb
../$(src gdb)/configure --target=v850-elf --prefix=$P --enable-sim --disable-nls --disable-werror \
	--with-expat --with-python=no --with-gmp=$H --with-mpfr=$H \
	--disable-binutils --disable-ld --disable-gas --disable-gprof --disable-gprofng > log 2>&1
make $J all-gdb all-sim > log 2>&1 && make install-strip-gdb install-strip-sim >> log 2>&1
grep -v "^qemu-" "$S/COMMITS" > $P/v850-elf/source-commits.txt
echo "v850-elf toolchain installed in $P"
