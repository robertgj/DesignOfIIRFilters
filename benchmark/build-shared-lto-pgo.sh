#!/bin/sh

BLDOPTS="-m64 -mtune=generic -O2"
export CFLAGS="-I"$LOCAL_PREFIX"/include "$BLDOPTS
export CXXFLAGS="-I"$LOCAL_PREFIX"/include "$BLDOPTS
export FFLAGS=$BLDOPTS
export LDFLAGS="-L"$LAPACK_DIR" -L"$LOCAL_PREFIX"/lib"
                                                              
$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas="-lblas" --with-lapack="-llapack"

export PGO_GEN_FLAGS="-pthread -fopenmp -fprofile-generate"
make XTRA_CFLAGS=$PGO_GEN_FLAGS XTRA_CXXFLAGS=$PGO_GEN_FLAGS V=1 -j6
find . -name \*.gcda -exec rm {} ';'
make V=1 -j6 check
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
export PGO_LTO_FLAGS="-pthread -fopenmp -fprofile-use -flto=6 -ffat-lto-objects"
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
