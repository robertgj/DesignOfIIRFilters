#!/bin/sh

#
# Build arpack-ng
#
rm -Rf arpack-ng-$ARPACK_NG_VERSION
tar -xf arpack-ng-$ARPACK_NG_VERSION".tar.gz"
pushd arpack-ng-$ARPACK_NG_VERSION
sh ./bootstrap
./configure --prefix=$LOCAL_PREFIX --with-blas=-lblas --with-lapack=-llapack
make -j 6 && make install
popd

#
# Build SuiteSparse
#
rm -Rf SuiteSparse-$SUITESPARSE_VERSION
tar -xf SuiteSparse-$SUITESPARSE_VERSION.tar.gz
pushd SuiteSparse-$SUITESPARSE_VERSION
cd SuiteSparse_config
export BUILD_OTHER_LIBS_OPTIM="\" -m64 -march=$CPU_TYPE -O2 \""
export CMAKE_OPTIONS="-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_C_FLAGS=$BUILD_OTHER_LIBS_OPTIM \
-DCMAKE_CXX_FLAGS=$BUILD_OTHER_LIBS_OPTIM \
-DCMAKE_Fortran_FLAGS=$BUILD_OTHER_LIBS_OPTIM \
-DBLA_VENDOR=$CPU_TYPE \
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
rm -Rf qrupdate-$QRUPDATE_VERSION
tar -xf qrupdate-$QRUPDATE_VERSION.tar.gz
pushd qrupdate-$QRUPDATE_VERSION
rm -f Makeconf
cat > Makeconf << 'EOF'
FC=gfortran
FFLAGS=-fimplicit-none -O2 -march=$(CPU_TYPE) -m64 -funroll-loops 
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
rm -Rf fftw-$FFTW_VERSION
tar -xf fftw-$FFTW_VERSION".tar.gz"
pushd fftw-$FFTW_VERSION
./configure --prefix=$LOCAL_PREFIX --enable-shared \
            --with-combined-threads --enable-threads 
make -j 6 && make install
popd

#
# Build fftw single-precision
#
rm -Rf fftw-$FFTW_VERSION
tar -xf fftw-$FFTW_VERSION".tar.gz"
pushd fftw-$FFTW_VERSION
./configure --prefix=$LOCAL_PREFIX --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd
