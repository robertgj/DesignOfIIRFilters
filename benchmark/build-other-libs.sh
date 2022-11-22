#!/bin/sh

# Assume these files are present:
#  SuiteSparse-6.0.1.tar.gz
#  arpack-ng-3.8.0.tar.gz
#  fftw-3.3.10.tar.gz
#  qrupdate-1.1.2.tar.gz

#
# Build arpack-ng
#
ARPACK_VER=3.8.0
rm -Rf arpack-ng-$ARPACK_VER
tar -xf arpack-ng-$ARPACK_VER".tar.gz"
pushd arpack-ng-$ARPACK_VER
sh ./bootstrap
./configure --prefix=$LOCAL_PREFIX --with-blas=-lblas --with-lapack=-llapack
make -j 6 && make install
popd

#
# Build SuiteSparse
#
SUITESPARSE_VER=6.0.1
rm -Rf SuiteSparse-$SUITESPARSE_VER
tar -xf SuiteSparse-$SUITESPARSE_VER.tar.gz
pushd SuiteSparse-$SUITESPARSE_VER
cd SuiteSparse_config
export BUILD_OTHER_LIBS_OPTIM="\" -m64 -march=nehalem -O3 \""
export CMAKE_OPTIONS="-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_C_FLAGS=$BUILD_OTHER_LIBS_OPTIM \
-DCMAKE_CXX_FLAGS=$BUILD_OTHER_LIBS_OPTIM \
-DCMAKE_Fortran_FLAGS=$BUILD_OTHER_LIBS_OPTIM \
-DBLA_VENDOR=generic \
-DALLOW_64BIT_BLAS=1 \
-DBLAS_LIBRARIES=$LAPACK_DIR/libblas.so \
-DLAPACK_LIBRARIES=$LAPACK_DIR/liblapack.so \
-DCMAKE_INSTALL_LIBDIR:PATH=$LOCAL_PREFIX/lib \
-DCMAKE_INSTALL_PREFIX=$LOCAL_PREFIX"
# If debugging cmake try : -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON 
make
cd ..
make -j6 && make install
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
