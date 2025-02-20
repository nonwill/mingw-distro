#!/bin/sh

source ./0_append_distro_path.sh

export ZSTDVer=1.5.7

if [ ! -f "zstd-${ZSTDVer}.tar" ];then
    wget -q -t 3 -w 1  https://github.com/facebook/zstd/releases/download/v${ZSTDVer}/zstd-${ZSTDVer}.tar.gz
    gzip -d zstd-${ZSTDVer}.tar.gz
fi

# Work around https://github.com/msys2/MSYS2-packages/issues/1216 by excluding the directory
# that contains the affected symlink. We don't need it, as ZSTD_BUILD_TESTS defaults to OFF.
untar_file ./zstd-${ZSTDVer}.tar --exclude=zstd-${ZSTDVer}/tests

cd $X_WORK_DIR
mv zstd-${ZSTDVer} src
mkdir build dest
cd build

cmake \
"-DCMAKE_BUILD_TYPE=Release" \
"-DCMAKE_C_FLAGS=-s -O3 -w" \
"-DCMAKE_INSTALL_PREFIX=$X_WORK_DIR/dest" \
"-DZSTD_BUILD_SHARED=OFF" \
-G Ninja $X_WORK_DIR/src/build/cmake

ninja
ninja install
cd $X_WORK_DIR
rm -rf build src
mv dest zstd-${ZSTDVer}
cd zstd-${ZSTDVer}
cp -r * ${X_DISTRO_ROOT}
rm -rf bin/zstdgrep bin/zstdless lib/cmake lib/pkgconfig share
for i in bin/unzstd bin/zstdcat bin/zstdmt; do mv $i $i.exe; done

7z -mx5 a ../zstd-${ZSTDVer}-${X_7Z_SUBFIX}.7z *

cp -nR * $MINGW_ALLINONE