#!/bin/sh

BLDOPTS="-m64 -mtune=generic -O2"
export CFLAGS="-I"$LOCAL_PREFIX"/include  "$BLDOPTS
export CXXFLAGS="-I"$LOCAL_PREFIX"/include "$BLDOPTS
export FFLAGS=$BLDOPTS
export LDFLAGS="-L"$LAPACK_DIR" -L"$LOCAL_PREFIX"/lib"
                      
$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
  --prefix=$OCTAVE_INSTALL_DIR --with-blas="-lblas" --with-lapack="-llapack"

make XTRA_CFLAGS="-pthread -fopenmp -fprofile-generate" \
     XTRA_CXXFLAGS="-pthread -fopenmp -fprofile-generate" V=1 -j6
find . -name \*.gcda -exec rm {} ';'
make V=1 -j6 check
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
make XTRA_CFLAGS="-pthread -fopenmp -fprofile-use" \
     XTRA_CXXFLAGS="-pthread -fopenmp -fprofile-use" V=1 -j6
