#!/bin/sh

BLDOPTS="-m64 -O0"
export CFLAGS="-I"$LOCAL_PREFIX"/include -std=c11 -ggdb3 "$BLDOPTS
export CXXFLAGS="-I"$LOCAL_PREFIX"/include -std=c++11 -ggdb3 "$BLDOPTS
export FFLAGS="-ggdb3 "$BLDOPTS
export LDFLAGS="-L"$LAPACK_DIR" -L"$LOCAL_PREFIX"/lib"

$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas="-lblas" --with-lapack="-llapack"

make V=1 -j 6 
