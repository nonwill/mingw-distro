#!/bin/sh

gcc -v
GCC_RET=$?
if [ $GCC_RET != 0 ]; then
  echo "Gcc not found!"
  exit $GCC_RET
fi

./zstd.sh
./mingw-w64+gcc.sh
./binutils.sh
./make.sh

#./coreutils.sh
#./gdb.sh
#./grep.sh
#./sed.sh
#./zlib.sh
#./bzip2.sh
