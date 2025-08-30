#!/bin/sh

BLDOPTS="-ggdb3 -m64 -O0 -march=$CPU_TYPE"
export CFLAGS="-I$LOCAL_PREFIX/include $BLDOPTS"
export CXXFLAGS="-I$LOCAL_PREFIX/include $BLDOPTS"
export FFLAGS=$BLDOPTS
export LDFLAGS="-L$LAPACK_DIR -L$LOCAL_PREFIX/lib"

$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas=-lblas --with-lapack=-llapack

make V=1 -j 6 
