#!/bin/sh

gcc -v

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
