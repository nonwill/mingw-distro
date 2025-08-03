#!/bin/sh

source ./0_append_distro_path.sh

#export MAKESVer=4.4.1

if [ ! -f "make-${MAKESVer}.tar" ];then
    wget -q -t 3 -w 1  https://ftp.gnu.org/gnu/make/make-${MAKESVer}.tar.gz
    gzip -d make-${MAKESVer}.tar.gz
fi

untar_file ./make-${MAKESVer}.tar
patch -Z -d $X_WORK_DIR/make-${MAKESVer} -p1 < ./make-4.4.1-mingw64-12.0.0-gcc14.patch

cd $X_WORK_DIR
mkdir -p dest/bin

mv make-${MAKESVer} src
cd src
# " /c" works around https://github.com/msys2/MSYS2-packages/issues/1606
cmd " /c" "build_w32.bat" "gcc"
strip -s GccRel/gnumake.exe
mv GccRel/gnumake.exe ../dest/bin/make.exe
# mingw32-make.exe is for CMake.
cp ../dest/bin/make.exe ../dest/bin/mingw32-make.exe
cd $X_WORK_DIR
rm -rf src

mv dest make-${MAKESVer}
cd make-${MAKESVer}

7z -mx5 a ../make-${MAKESVer}-${X_7Z_SUBFIX}.7z *

cp -nR * $MINGW_ALLINONE