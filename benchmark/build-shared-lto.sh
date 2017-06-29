#!/bin/sh

BLDOPTS="-m64 -mtune=generic -O2 -flto=6 -ffat-lto-objects"
export CFLAGS="-std=c11 "$BLDOPTS
export CXXFLAGS="-std=c++11 "$BLDOPTS
export FFLAGS=$BLDOPTS
export LDFLAGS="-L"$LAPACK_DIR

$OCTAVE_DIR/configure --prefix=$OCTAVE_INSTALL_DIR \
--disable-java --without-fltk --without-qt --disable-atomic-refcount \
--with-blas="-lblas" --with-lapack="-llapack"

make V=1 -j6
