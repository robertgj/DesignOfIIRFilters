#!/bin/sh

BLDOPTS="-m64 -mtune=generic -O2"
export CFLAGS="-I"$LOCAL_PREFIX"/include -std=c11 "$BLDOPTS
export CXXFLAGS="-I"$LOCAL_PREFIX"/include -std=c++11 "$BLDOPTS
export FFLAGS=$BLDOPTS
export LDFLAGS="-L"$LAPACK_DIR" -L"$LOCAL_PREFIX"/lib"

$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas="-lblas" --with-lapack="-llapack"

make V=1 -j6
