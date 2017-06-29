#!/bin/sh

export CFLAGS="-std=c11 -ggdb3 -O0"
export CXXFLAGS="-std=c++11 -ggdb3 -O0"
export FFLAGS="-ggdb3 -O0"
export LDFLAGS="-L"$LAPACK_DIR

$OCTAVE_DIR/configure --prefix=$OCTAVE_INSTALL_DIR \
--disable-java --without-fltk --without-qt --disable-atomic-refcount \
--with-blas="-lblas" --with-lapack="-llapack" \
--disable-openmp --disable-threads --enable-bounds-check \
--without-opengl --without-OSMesa --without-magick \
--without-portaudio --without-sndfile \
# --disable-docs --enable-address-sanitizer-flags

make V=1 -j 6 
