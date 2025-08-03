#!/bin/sh

source ./0_append_distro_path.sh

export SVer=2.45

if [ ! -f "binutils-${SVer}.tar" ];then
    wget -q -t 3 -w 1  https://ftp.gnu.org/gnu/binutils/binutils-${SVer}.tar.gz
    gzip -d binutils-${SVer}.tar.gz
fi

untar_file ./binutils-${SVer}.tar

cd $X_WORK_DIR
mv binutils-${SVer} src
mkdir build dest
cd build

../src/configure --disable-nls --disable-shared \
--build=$X_DISTRO_build --host=$X_DISTRO_host --target=$X_DISTRO_target \
--disable-multilib \
--prefix=$X_WORK_DIR/dest --with-sysroot=$X_WORK_DIR/dest 
/bin/make $X_MAKE_JOBS all "CFLAGS=-O3 -w" "LDFLAGS=-s" 
/bin/make $X_MAKE_JOBS install 
cd $X_WORK_DIR
rm -rf build src
mv dest binutils-${SVer}
cd binutils-${SVer}
rm -rf lib/*.la share

7z -mx5 a ../binutils-${SVer}-${X_7Z_SUBFIX}.7z *

cp -nR * $MINGW_ALLINONE