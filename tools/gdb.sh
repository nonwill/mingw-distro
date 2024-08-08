#!/bin/sh

source ./0_append_distro_path.sh

export SVer=13.2
export GMPSVer=6.2.1

untar_file ../gdb-${SVer}.tar
untar_file ../gmp-${GMPSVer}.tar

cd /f/temp/gcc

# Build gmp.
mv gmp-6.2.1 src-gmp
mkdir build-gmp dest-gmp
cd build-gmp

../src-gmp/configure --build=i686-w64-mingw32 --host=i686-w64-mingw32 --target=i686-w64-mingw32 \
--prefix=/f/temp/gcc/dest-gmp --disable-shared

/bin/make $X_MAKE_JOBS all "CFLAGS=-O3" "LDFLAGS=-s"
/bin/make $X_MAKE_JOBS install
cd /f/temp/gcc
rm -rf build-gmp src-gmp
rm -rf dest-gmp/lib/*.la dest-gmp/lib/pkgconfig dest-gmp/share

# Build gdb.
mv gdb-${SVer} src
mkdir build dest
cd build

../src/configure --build=i686-w64-mingw32 --host=i686-w64-mingw32 --target=i686-w64-mingw32 \
--prefix=/f/temp/gcc/dest --disable-nls

# -D_FORTIFY_SOURCE=0 works around https://github.com/StephanTLavavej/mingw-distro/issues/71
/bin/make $X_MAKE_JOBS all \
"CFLAGS=-O3 -D_FORTIFY_SOURCE=0 -I/f/temp/gcc/dest-gmp/include" \
"CXXFLAGS=-O3 -D_FORTIFY_SOURCE=0 -I/f/temp/gcc/dest-gmp/include" \
"LDFLAGS=-s -L/f/temp/gcc/dest-gmp/lib"
/bin/make install 
cd /f/temp/gcc
rm -rf build src dest-gmp
mv dest gdb-${SVer}
cd gdb-${SVer}
rm -rf bin/gdb-add-index include lib share

7z -mx0 a ../gdb-${SVer}.7z *
