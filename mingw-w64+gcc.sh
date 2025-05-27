#!/bin/sh

source ./0_append_distro_path.sh

export GMPSVer=6.3.0
export MPFRSVer=4.2.2
export MPCSVer=1.3.1
export ISLSVer=0.27
export GCCSVer=14.3.0
export MINGWSVer=v12.0.0

if [ ! -f "gcc-${GCCSVer}.tar" ];then
    wget -q -t 3 -w 1  https://ftp.gnu.org/gnu/gcc/gcc-${GCCSVer}/gcc-${GCCSVer}.tar.gz
    gzip -d gcc-${GCCSVer}.tar.gz
    wget -q -t 3 -w 1  https://ftp.gnu.org/gnu/gmp/gmp-${GMPSVer}.tar.gz
    gzip -d gmp-${GMPSVer}.tar.gz
    wget -q -t 3 -w 1  https://ftp.gnu.org/gnu/mpfr/mpfr-${MPFRSVer}.tar.gz
    gzip -d mpfr-${MPFRSVer}.tar.gz
    wget -q -t 3 -w 1  https://ftp.gnu.org/gnu/mpc/mpc-${MPCSVer}.tar.gz
    gzip -d mpc-${MPCSVer}.tar.gz
    wget -q -t 3 -w 1  https://sourceforge.net/projects/libisl/files/isl-${ISLSVer}.tar.gz/download -O isl-${ISLSVer}.tar.gz
    gzip -d isl-${ISLSVer}.tar.gz
    wget -q -t 3 -w 1 https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-${MINGWSVer}.zip/download -O mingw-w64-${MINGWSVer}.zip
fi

# Extract vanilla sources.
untar_file ./gmp-${GMPSVer}.tar
untar_file ./mpfr-${MPFRSVer}.tar
untar_file ./mpc-${MPCSVer}.tar
untar_file ./isl-${ISLSVer}.tar
unzip_file ./mingw-w64-${MINGWSVer}.zip
untar_file ./gcc-${GCCSVer}.tar

cd $X_WORK_DIR

# Build mingw-w64 and winpthreads.
mv mingw-w64-${MINGWSVer} src
mkdir build-mingw-w64 dest
cd build-mingw-w64

GCC_DISABLE_LIB32=
if [ "$X_DISTRO_target" == "x86_64-w64-mingw32" ];then
  GCC_DISABLE_LIB32=--disable-lib32
fi

../src/configure --build=$X_DISTRO_build --host=$X_DISTRO_host --target=$X_DISTRO_target $GCC_DISABLE_LIB32 \
--prefix=$X_WORK_DIR/dest/$X_DISTRO_target \
--with-sysroot=$X_WORK_DIR/dest/$X_DISTRO_target \
--enable-wildcard --with-default-msvcrt=msvcrt \
--with-libraries=winpthreads --disable-shared 

# The headers must be built first. See: https://github.com/StephanTLavavej/mingw-distro/issues/64
cd mingw-w64-headers
/bin/make $X_MAKE_JOBS all "CFLAGS=-s -O3 -w"
/bin/make $X_MAKE_JOBS install
cd $X_WORK_DIR/build-mingw-w64
/bin/make $X_MAKE_JOBS all "CFLAGS=-s -O3 -w"
/bin/make $X_MAKE_JOBS install
cd $X_WORK_DIR

rm -rf  build-mingw-w64 src

# Prepare to build gcc.
mv gcc-${GCCSVer} src
mv gmp-${GMPSVer} src/gmp
mv mpfr-${MPFRSVer} src/mpfr
mv mpc-${MPCSVer} src/mpc
mv isl-${ISLSVer} src/isl

# Prepare to build gcc - perform magic directory surgery.
if [ "$X_DISTRO_target" == "x86_64-w64-mingw32" ];then
   cp -r dest/$X_DISTRO_target/lib dest/$X_DISTRO_target/lib64
fi
cp -r dest/$X_DISTRO_target dest/mingw
mkdir -p src/gcc/winsup/mingw
cp -r dest/$X_DISTRO_target/include src/gcc/winsup/mingw/include

# Configure.
mkdir build
cd build

../src/configure --enable-languages=c,c++ --build=$X_DISTRO_build --host=$X_DISTRO_host \
--target=$X_DISTRO_target --disable-multilib \
--prefix=$X_WORK_DIR/dest --with-sysroot=$X_WORK_DIR/dest \
--disable-libstdcxx-pch --disable-libstdcxx-verbose --disable-nls --disable-shared --disable-win32-registry \
--enable-threads=posix --enable-libgomp \
--with-zstd=$X_DISTRO_ROOT \
--disable-bootstrap

# --enable-languages=c,c++        : I want C and C++ only.
# --build=i686-w64-mingw32        : I want a native compiler.
# --host=i686-w64-mingw32         : Ditto.
# --target=i686-w64-mingw32       : Ditto.
# --disable-multilib              : I want 32-bit only.
# --prefix=$X_WORK_DIR/dest       : I want the compiler to be installed here.
# --with-sysroot=$X_WORK_DIR/dest : Ditto. (This one is important!)
# --disable-libstdcxx-pch         : I don't use this, and it takes up a ton of space.
# --disable-libstdcxx-verbose     : Reduce generated executable size. This doesn't affect the ABI.
# --disable-nls                   : I don't want Native Language Support.
# --disable-shared                : I don't want DLLs.
# --disable-win32-registry        : I don't want this abomination.
# --with-tune=haswell             : Tune for Haswell by default.
# --enable-threads=posix          : Use winpthreads.
# --enable-libgomp                : Enable OpenMP.
# --with-zstd=$X_DISTRO_ROOT      : zstd is needed for LTO bytecode compression.
# --disable-bootstrap             : Significantly accelerate the build, and work around bootstrap comparison failures.

# Build and install.
/bin/make $X_MAKE_JOBS "CFLAGS=-g0 -O3 -w" "CXXFLAGS=-g0 -O3 -w" \
"CFLAGS_FOR_TARGET=-g0 -O3 -w" "CXXFLAGS_FOR_TARGET=-g0 -O3 -w" \
"BOOT_CFLAGS=-g0 -O3 -w" "BOOT_CXXFLAGS=-g0 -O3 -w" 

/bin/make install

# Cleanup.
cd $X_WORK_DIR
rm -rf build src
mv dest mingw-w64+gcc
cd mingw-w64+gcc
find -name "*.la" -type f -print -exec rm {} ";"
rm -rf bin/c++.exe bin/$X_DISTRO_target-* share/info share/man
rm -rf mingw
if [ "$X_DISTRO_target" == "x86_64-w64-mingw32" ];then
  rm -rf x86_64-w64-mingw32/lib64
fi
find -name "*.exe" -type f -print -exec strip -s {} ";"

7z -mx5 a ../mingw-w64-${MINGWSVer}+gcc-${GCCSVer}-${X_7Z_SUBFIX}.7z *

cp -nR * $MINGW_ALLINONE