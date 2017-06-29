#!/bin/sh

BLDOPTS="-m64 -mtune=generic -O2 -flto=6 -ffat-lto-objects"
export CFLAGS="-std=c11 "$BLDOPTS
export CXXFLAGS="-std=c++11 "$BLDOPTS
export FFLAGS=$BLDOPTS

$OCTAVE_DIR/configure --prefix=$OCTAVE_INSTALL_DIR \
--disable-java --without-fltk --without-qt --disable-atomic-refcount \
--with-blas=$LAPACK_LTO_DIR/libblas.a --with-lapack=$LAPACK_LTO_DIR/liblapack.a

make V=1 -j6
