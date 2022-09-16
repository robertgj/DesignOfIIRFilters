#!/bin/sh

# Assume these files are present:
#  SuiteSparse-5.13.0.tar.gz
#  arpack-ng-3.8.0.tar.gz
#  fftw-3.3.10.tar.gz
#  qrupdate-1.1.2.tar.gz

#
# Build arpack-ng
#
rm -Rf arpack-ng-3.8.0
tar -xf arpack-ng-3.8.0.tar.gz
pushd arpack-ng-3.8.0
sh ./bootstrap
./configure --prefix=$LOCAL_PREFIX --with-blas=-lblas --with-lapack=-llapack
make -j 6 && make install
popd

#
# Build SuiteSparse
#
SUITESPARSE_VER=5.13.0
rm -Rf SuiteSparse-$SUITESPARSE_VER
tar -xf SuiteSparse-$SUITESPARSE_VER.tar.gz
pushd SuiteSparse-$SUITESPARSE_VER
cd SuiteSparse_config
make BLAS=-lblas LAPACK=-llapack INSTALL=$LOCAL_PREFIX OPTIMIZATION=-O2 \
LDFLAGS="-L$LOCAL_PREFIX/lib -L$LAPACK_DIR" install
cd ..
make -j 6 BLAS=-lblas LAPACK=-llapack INSTALL=$LOCAL_PREFIX OPTIMIZATION=-O2 \
LDFLAGS="-L$LOCAL_PREFIX/lib -L$LAPACK_DIR" install
popd

#
# Build qrupdate
#
QRUPDATE_VER=1.1.2
rm -Rf qrupdate-$QRUPDATE_VER
tar -xf qrupdate-$QRUPDATE_VER.tar.gz
pushd qrupdate-$QRUPDATE_VER
rm -f Makeconf
cat > Makeconf << 'EOF'
FC=gfortran
FFLAGS=-fimplicit-none -O2 -funroll-loops 
FPICFLAGS=-fPIC

ifeq ($(strip $(PREFIX)),)
  PREFIX=/usr/local
endif

BLAS=-L$(LAPACK_DIR) -lblas
LAPACK=-L$(LAPACK_DIR) -llapack

VERSION=1.1
MAJOR=1
LIBDIR=lib
DESTDIR=
EOF
make PREFIX=$LOCAL_PREFIX solib install
popd

#
# Build fftw
#
FFTW_VER=3.3.10
rm -Rf fftw-$FFTW_VER
tar -xf fftw-$FFTW_VER".tar.gz"
pushd fftw-$FFTW_VER
./configure --prefix=$LOCAL_PREFIX --enable-shared \
            --with-combined-threads --enable-threads 
make -j 6 && make install
popd

#
# Build fftw single-precision
#
rm -Rf fftw-$FFTW_VER
tar -xf fftw-$FFTW_VER".tar.gz"
pushd fftw-$FFTW_VER
./configure --prefix=$LOCAL_PREFIX --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd
