#!/bin/sh

# Assume these files are present:
#  SuiteSparse-4.5.6.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.7.tar.gz
#  qrupdate-1.1.2.tar.gz

export LDFLAGS="-L"$LAPACK_DIR

#
# Build arpack-ng
#
rm -Rf arpack-ng-master
unzip arpack-ng-master.zip
pushd arpack-ng-master
sh ./bootstrap
./configure --prefix=$LOCAL_PREFIX --with-blas=-lblas --with-lapack=-llapack
make -j 6 && make install
popd

#
# Build SuiteSparse
#
rm -Rf SuiteSparse
tar -xf SuiteSparse-4.5.6.tar.gz
pushd SuiteSparse
make INSTALL=$LOCAL_PREFIX OPTIMIZATION=-O2 BLAS=-lblas install
popd

#
# Build qrupdate
#
rm -Rf qrupdate-1.1.2
tar -xf qrupdate-1.1.2.tar.gz
pushd qrupdate-1.1.2
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
rm -Rf fftw-3.3.7
tar -xf fftw-3.3.7.tar.gz
pushd fftw-3.3.7
./configure --prefix=$LOCAL_PREFIX --enable-shared \
            --with-combined-threads --enable-threads
make -j 6 && make install
popd

#
# Build fftw single-precision
#
rm -Rf fftw-3.3.7
tar -xf fftw-3.3.7.tar.gz
pushd fftw-3.3.7
./configure --prefix=$LOCAL_PREFIX --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd