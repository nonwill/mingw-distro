#!/bin/sh

export USER_MINGW_DIR=$(pwd)/mingw64
mkdir -p $USER_MINGW_DIR

export X_7Z_SUBFIX=x86_64
export X_WORK_DIR=$(pwd)/gcc-$X_7Z_SUBFIX

export MINGW_ALLINONE=$X_WORK_DIR/mingw-w64+gcc-$X_7Z_SUBFIX
mkdir -p $MINGW_ALLINONE

wget -q -t 3 -w 1 https://github.com/nonwill/mingw-distro/releases/download/mingw64-gcc-crt_latest/mingw-w64+gcc-$X_7Z_SUBFIX-all.7z
7z x mingw-w64+gcc-$X_7Z_SUBFIX-all.7z -r -o$USER_MINGW_DIR
rm -f mingw-w64+gcc-$X_7Z_SUBFIX-all.7z

export PATH=$USER_MINGW_DIR/bin:$PATH

export X_DISTRO_ROOT=$X_WORK_DIR/mingw64
mkdir -p ${X_DISTRO_ROOT}

export X_DISTRO_build=x86_64-w64-mingw32
export X_DISTRO_host=x86_64-w64-mingw32
export X_DISTRO_target=x86_64-w64-mingw32


./build_everything.sh

rm -rf $USER_MINGW_DIR/*
mv $MINGW_ALLINONE/* $USER_MINGW_DIR/
rm -rf $X_WORK_DIR
mkdir -p $MINGW_ALLINONE
mkdir -p ${X_DISTRO_ROOT}

# Bootstrap
./build_everything.sh


if [ ! -f "mingw-w64-cppwinrt-2.0.221221.0-beta.1-headers.tar.gz" ];then
  wget -q -t 3 -w 1 https://github.com/alvinhochun/mingw-w64-cppwinrt/releases/download/2.0.221221.0-beta.1/mingw-w64-cppwinrt-2.0.221221.0-beta.1-headers.tar.gz
  tar -xf mingw-w64-cppwinrt-2.0.221221.0-beta.1-headers.tar.gz
  mv ./mingw-w64-cppwinrt-2.0.221221.0-beta.1-headers/include/cppwinrt-2.0.221221.0/winrt ./winrt
  7z -mx5 a $X_WORK_DIR/cppwinrt-2.0.221221.0.7z ./winrt
fi
cp -nR ./winrt $MINGW_ALLINONE/$X_DISTRO_target/include

7z -mx5 a $X_WORK_DIR/mingw-w64+gcc-$X_7Z_SUBFIX-all.7z $MINGW_ALLINONE/*
