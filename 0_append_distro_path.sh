#!/bin/sh

# Reject expansion of unset variables.
set -u

# Exit when a command fails.
if [ "${PS1:-}" == "" ]; then set -e; fi

export X_DISTRO_BIN=$X_DISTRO_ROOT/bin
export X_DISTRO_INC=$X_DISTRO_ROOT/include
export X_DISTRO_LIB=$X_DISTRO_ROOT/lib

# Add the distro and 7z to the PATH.
if [[ ! -v X_PATH_MODIFIED ]]; then export PATH=$PATH:$X_DISTRO_BIN:"/c/Program Files/7-Zip"; fi
export X_PATH_MODIFIED=meow

export C_INCLUDE_PATH=$X_DISTRO_INC
export CPLUS_INCLUDE_PATH=$X_DISTRO_INC

function untar_file {
    tar --extract --directory=$X_WORK_DIR --file=$*
}

function unzip_file {
    unzip -qo $* -d $X_WORK_DIR
}

export X_MAKE_JOBS="-j$NUMBER_OF_PROCESSORS -O"
export X_B2_JOBS="-j$NUMBER_OF_PROCESSORS"

# Print commands.
if [ "${PS1:-}" == "" ]; then set -x; fi
