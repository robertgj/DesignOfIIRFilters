#!/bin/sh

BLDOPTS="-m64 -march=$CPU_TYPE -O2 -flto=6 -ffat-lto-objects"
export CFLAGS="-I"$LOCAL_PREFIX"/include $BLDOPTS"
export CXXFLAGS="-I"$LOCAL_PREFIX"/include $BLDOPTS"
export FFLAGS=$BLDOPTS
export LDFLAGS="-L$LAPACK_DIR -L$LOCAL_PREFIX/lib"

$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas=-lblas --with-lapack=-llapack

make V=1 -j6
