#!/bin/sh

BLDOPTS="-m64 -march=$CPU_TYPE -O2"
export CFLAGS="-I$LOCAL_PREFIX/include $BLDOPTS"
export CXXFLAGS="-I$LOCAL_PREFIX/include $BLDOPTS"
export FFLAGS=$BLDOPTS
export LDFLAGS="-L$LAPACK_DIR -L$LOCAL_PREFIX/lib"
                                                              
PGO_GEN_FLAGS="-pthread -fprofile-generate"
XTRA_CFLAGS=$PGO_GEN_FLAGS \
XTRA_CXXFLAGS=$PGO_GEN_FLAGS \
$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
--prefix=$OCTAVE_INSTALL_DIR --with-blas=-lblas --with-lapack=-llapack

make V=1 -j6 -O

find . -name \*.gcda -exec rm {} ';'
make check

find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
find . -name moc* -exec rm -f {} ';'

PGO_LTO_FLAGS="-pthread -flto=6 -ffat-lto-objects -fprofile-use"
XTRA_CFLAGS=$PGO_LTO_FLAGS \
XTRA_CXXFLAGS=$PGO_LTO_FLAGS \
$OCTAVE_DIR/configure $OCTAVE_CONFIG_OPTIONS \
--prefix=$OCTAVE_INSTALL_DIR --with-blas=-lblas --with-lapack=-llapack

make V=1 -j6 -O

# Hack to remove LTO profiling from mkoctfile
sed -i -e "s/$PGO_LTO_FLAGS//" ./src/mkoctfile.cc
make V=1 src/mkoctfile

