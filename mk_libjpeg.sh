#!/bin/sh
set -e
set -v
BUILD="x86_64-linux-gnu"
TARGET="arm-linux-gnueabi"
SRC_DIR=`pwd`
mkdir build
mkdir bin
cd build
curl http://ijg.org/files/jpegsrc.v9a.tar.gz | tar xzf -
cd jpeg-9a
# --enable-static is useless because libc is still dynamically linked
./configure --build="$BUILD" --host="$TARGET" CFLAGS='-Os -static -static-libgcc -Wl,-Bstatic'
make
cp jpegtran "${SRC_DIR}/bin"
"${TARGET}-strip" -s "${SRC_DIR}/bin/jpegtran"
