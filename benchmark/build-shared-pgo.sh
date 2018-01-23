#!/bin/sh

BLDOPTS="-m64 -mtune=generic -O2"
export CFLAGS="-I"$LOCAL_PREFIX"/include -std=c11 "$BLDOPTS
export CXXFLAGS="-I"$LOCAL_PREFIX"/include -std=c++11 "$BLDOPTS
export FFLAGS=$BLDOPTS
export LDFLAGS="-L"$LAPACK_DIR" -L"$LOCAL_PREFIX"/lib"
                      
$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas="-lblas" --with-lapack="-llapack"

make XTRA_CFLAGS="-fprofile-generate" XTRA_CXXFLAGS="-fprofile-generate" V=1 -j6
find . -name \*.gcda -exec rm {} ';'
make check
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
make XTRA_CFLAGS="-fprofile-use" XTRA_CXXFLAGS="-fprofile-use" V=1 -j6
