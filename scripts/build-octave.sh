#!/bin/sh

# Build a local version of octave-cli
#
# Require Fedora packages: wget readline-devel lzip sharutils gcc gcc-c++
# gcc-gfortran gmp-devel mpfr-devel make cmake gnuplot-latex m4 gperf 
# bison flex openblas-devel patch texinfo texinfo-tex librsvg2 librsvg2-devel
# librsvg2-tools icoutils autoconf automake libtool pcre pcre-devel freetype
# freetype-devel gnupg2 texlive-dvisvgm gl2ps gl2ps-devel hdf5 hdf5-devel
# qhull qhull-devel portaudio portaudio-devel libsndfile libsndfile-devel
# libcurl libcurl-devel gl2ps gl2ps-devel fontconfig-devel mesa-libGLU
# mesa-libGLU-devel qt qt6-qtbase qt6-qtbase-common qt6-qtbase-devel
# qt6-qtbase-gui qt6-qt5compat qt6-qt5compat-devel qt6-qttools
# qt6-qttools-common qt6-qttools-devel rapidjson-devel python3-sympy
# java-21-openjdk-devel xerces-j2 util-linux util-linux-core util-linux-script
#
# See https://wiki.octave.org/GraphicsMagick for GraphicksMagic dependencies
#
# SuiteSparse requires extra definitions to install other than at /usr/local
#
# Octave-forge packages don't install at the prefix when the user is not root.
#
# From the fftw-3.3.8 release notes (May 28th, 2018):
#    Fixed AVX, AVX2 for gcc-8.
#      By default, FFTW 3.3.7 was broken with gcc-8. AVX and AVX2 code
#      assumed that the compiler honors the distinction between +0 and -0,
#      but gcc-8 -ffast-math does not. The default CFLAGS included
#      -ffast-math . This release ensures that FFTW works with gcc-8
#      -ffast-math , and removes -ffast-math from the default CFLAGS for
#      good measure.
# 
# Get the GNU octave public keys with:
#    wget https://ftp.gnu.org/gnu/gnu-keyring.gpg
#    gpg2 --import gnu-keyring.gpg
# then verify the .sig file with (for example):
#    gpg2 --verify octave-8.2.0.tar.lz.sig
#
# Note the worrying error from Octave-forge package control-3.2.0.tar.gz in
# the FORTRAN file from slicot.tar.gz, MA02ID.f at lines 188 and 230:
# 
#   184 |          DO 90 J = 1, N+1
#       |                                                                     2
# ......
#   188 |                DWORK(J-1) = DWORK(J-1) + TEMP
#       |                     1
# Warning: Array reference at (1) out of bounds (0 < 1) in loop beginning at (2)

#
# Produce code for Intel nehalem CPU. If necessary replace with mtune=generic
#
OPTFLAGS="-m64 -march=nehalem -O2"

#
# Assume these files are present. Get them if they are not.
#

#
# Get Octave archive
#
OCTAVE_VER=${OCTAVE_VER:-10.3.0}
OCTAVE_ARCHIVE=octave-$OCTAVE_VER".tar.lz"
OCTAVE_URL=https://ftpmirror.gnu.org/gnu/octave/$OCTAVE_ARCHIVE
if ! test -f $OCTAVE_ARCHIVE; then
  wget -c $OCTAVE_URL
fi
# Check signature
if ! test -f $OCTAVE_ARCHIVE.sig; then
  wget -c $OCTAVE_URL.sig
fi
gpg2 --verify $OCTAVE_ARCHIVE.sig
if test $? -ne 0;then 
    echo Bad GPG signature on $OCTAVE_ARCHIVE ;
    exit -1;
fi

#
# Set Octave directories
#
OCTAVE_INSTALL_DIR=/usr/local/octave-$OCTAVE_VER
OCTAVE_INCLUDE_DIR=$OCTAVE_INSTALL_DIR/include
OCTAVE_LIB_DIR=$OCTAVE_INSTALL_DIR/lib
OCTAVE_BIN_DIR=$OCTAVE_INSTALL_DIR/bin
OCTAVE_SHARE_DIR=$OCTAVE_INSTALL_DIR/share/octave
export LD_LIBRARY_PATH=$OCTAVE_LIB_DIR
export LDFLAGS=-L$OCTAVE_LIB_DIR
export PATH=$PATH:$OCTAVE_BIN_DIR

#
# Get library archives
#
LAPACK_VER=${LAPACK_VER:-3.12.1}
LAPACK_ARCHIVE=lapack-$LAPACK_VER".tar.gz"
LAPACK_URL=https://github.com/Reference-LAPACK/lapack/archive/v$LAPACK_VER.tar.gz
if ! test -f $LAPACK_ARCHIVE; then
  wget -c $LAPACK_URL -O $LAPACK_ARCHIVE
fi

ARPACK_VER=${ARPACK_VER:-3.9.1}
ARPACK_ARCHIVE=arpack-ng-$ARPACK_VER".tar.gz"
ARPACK_URL=https://github.com/opencollab/arpack-ng/archive/refs/tags/$ARPACK_VER".tar.gz"
if ! test -f $ARPACK_ARCHIVE; then
  wget -c $ARPACK_URL -O $ARPACK_ARCHIVE
fi

SUITESPARSE_VER=${SUITESPARSE_VER:-7.11.0}
SUITESPARSE_ARCHIVE=SuiteSparse-$SUITESPARSE_VER".tar.gz"
SUITESPARSE_URL=https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v$SUITESPARSE_VER".tar.gz"
if ! test -f $SUITESPARSE_ARCHIVE; then
  wget -c $SUITESPARSE_URL -O $SUITESPARSE_ARCHIVE
fi

# See: https://github.com/mpimd-csc/qrupdate-ng/archive/refs/tags/v1.1.5.tar.gz
QRUPDATE_VER=${QRUPDATE_VER:-1.1.2}
QRUPDATE_ARCHIVE=qrupdate-$QRUPDATE_VER".tar.gz"
QRUPDATE_URL=https://sourceforge.net/projects/qrupdate/files/qrupdate/1.2/$QRUPDATE_ARCHIVE
if ! test -f $QRUPDATE_ARCHIVE; then
  wget -c $QRUPDATE_URL
fi

FFTW_VER=${FFTW_VER:-3.3.10}
FFTW_ARCHIVE=fftw-$FFTW_VER".tar.gz"
FFTW_URL=https://www.fftw.org/$FFTW_ARCHIVE
if ! test -f $FFTW_ARCHIVE; then
  wget -c $FFTW_URL
fi

GLPK_VER=${GLPK_VER:-5.0}
GLPK_ARCHIVE=glpk-$GLPK_VER".tar.gz"
GLPK_URL=https://ftp.gnu.org/gnu/glpk/$GLPK_ARCHIVE
if ! test -f $GLPK_ARCHIVE; then
  wget -c $GLPK_URL
fi

SUNDIALS_VER=${SUNDIALS_VER:-7.5.0}
SUNDIALS_ARCHIVE=sundials-$SUNDIALS_VER".tar.gz"
SUNDIALS_URL=https://github.com/LLNL/sundials/releases/download/v$SUNDIALS_VER/$SUNDIALS_ARCHIVE
if ! test -f $SUNDIALS_ARCHIVE; then
  wget -c $SUNDIALS_URL
fi

GRAPHICSMAGICK_VER=${GRAPHICSMAGICK_VER:-1.3.45}
GRAPHICSMAGICK_ARCHIVE=GraphicsMagick-$GRAPHICSMAGICK_VER".tar.xz"
GRAPHICSMAGICK_URL=https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/$GRAPHICSMAGICK_VER/GraphicsMagick-$GRAPHICSMAGICK_VER.tar.xz
if ! test -f $GRAPHICSMAGICK_ARCHIVE; then
  wget -c $GRAPHICSMAGICK_URL
fi
if ! test -f $GRAPHICSMAGICK_ARCHIVE".asc"; then
  wget -c $GRAPHICSMAGICK_URL".asc"
fi
gpg2 --verify $GRAPHICSMAGICK_ARCHIVE".asc"
if test $? -ne 0;then 
    echo Bad GPG signature on $GRAPHICSMAGICK_ARCHIVE ;
    exit -1;
fi

# From: https://github.com/gnu-octave/docker/blob/main/build-octave-8.docker
# Install RapidJSON header library
# RAPIDJSON_VER=${RAPIDJSON_VER:-1.1.0}
# RAPIDJSON_ARCHIVE=RapidJSON-$RAPIDJSON_VER".tar.gz"
# RAPIDJSON_URL= \
#  https://github.com/Tencent/rapidjson/archive/refs/tags/v$RAPIDJSON_VER.tar.gz
# if ! test -f $RAPIDJSON_ARCHIVE; then
#   wget -c $RAPIDJSON_URL
# fi
# mv v$RAPIDJSON_VER.tar.gz $RAPIDJSON_ARCHIVE

#
# Get octave-forge packages from https://gnu-octave.github.io/packages/
#

OCTAVE_FORGE_URL=https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases

CONTROL_VER=${CONTROL_VER:-4.1.3}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL="https://github.com/gnu-octave/pkg-control/releases/download/control-"$CONTROL_VER/$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
  wget -c $CONTROL_URL 
fi

IO_VER=${IO_VER:-2.7.0}
IO_ARCHIVE=io-$IO_VER".tar.gz"
IO_URL=$OCTAVE_FORGE_URL/$IO_ARCHIVE
if ! test -f $IO_ARCHIVE; then
  wget -c $IO_URL
fi

OPTIM_VER=${OPTIM_VER:-1.6.2}
OPTIM_ARCHIVE=optim-$OPTIM_VER".tar.gz"
OPTIM_URL=$OCTAVE_FORGE_URL/$OPTIM_ARCHIVE
if ! test -f $OPTIM_ARCHIVE; then
  wget -c $OPTIM_URL 
fi

PARALLEL_VER=${PARALLEL_VER:-4.0.2}
PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".tar.gz"
PARALLEL_URL=$OCTAVE_FORGE_URL/$PARALLEL_ARCHIVE
if ! test -f $PARALLEL_ARCHIVE; then
  wget -c $PARALLEL_URL 
fi

PIQP_VER=${PIQP_VER:-0.6.0}
PIQP_ARCHIVE=piqp-$PIQP_VER.tar.gz
PIQP_URL=https://github.com/PREDICT-EPFL/piqp/releases/download/v$PIQP_VER/piqp-octave.tar.gz
if ! test -f $PIQP_ARCHIVE; then
    wget -c $PIQP_URL
    mv piqp-octave.tar.gz $PIQP_ARCHIVE
fi

SIGNAL_VER=${SIGNAL_VER:-1.4.6}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=$OCTAVE_FORGE_URL/$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
  wget -c $SIGNAL_URL 
fi

STATISTICS_VER=${STATISTICS_VER:-1.7.5}
STATISTICS_ARCHIVE=statistics-$STATISTICS_VER".tar.gz"
STATISTICS_URL="https://github.com/gnu-octave/statistics/archive/refs/tags/release-"$STATISTICS_VER".tar.gz"
if ! test -f $STATISTICS_ARCHIVE; then
  wget -c $STATISTICS_URL
  mv "release-"$STATISTICS_VER".tar.gz" $STATISTICS_ARCHIVE
fi

STRUCT_VER=${STRUCT_VER:-1.0.18}
STRUCT_ARCHIVE=struct-$STRUCT_VER".tar.gz"
STRUCT_URL=$OCTAVE_FORGE_URL/$STRUCT_ARCHIVE
if ! test -f $STRUCT_ARCHIVE; then
  wget -c $STRUCT_URL 
fi

SYMBOLIC_VER=${SYMBOLIC_VER:-3.2.2}
SYMBOLIC_ARCHIVE=symbolic-$SYMBOLIC_VER".tar.gz"
SYMBOLIC_URL=$OCTAVE_FORGE_URL/$SYMBOLIC_ARCHIVE
if ! test -f $SYMBOLIC_ARCHIVE; then
  wget -c $SYMBOLIC_URL 
fi

#
# !?!WARNING!?!
#
# Starting from scratch!
#
rm -Rf $OCTAVE_INSTALL_DIR
echo "Building octave-"$OCTAVE_VER
mkdir -p $OCTAVE_INSTALL_DIR

#
# Build lapack
#
cat > lapack-$LAPACK_VER.patch.gz.uue << 'EOF'
begin-base64 644 lapack-3.12.1.patch.gz
H4sICPjFr2gAA2xhcGFjay0zLjEyLjEucGF0Y2gA7VbbctpIEH2OvqKr1qmy
LEYwAiNBlWuNBTjsYqCAveRlXWMxgMq6WRK2yddvz0jCgLETx8lb9KC59Zzu
6dMz3YQQ8FjEnFtS1amh0/JFvzUpT8Z2+Yrd8rnr8Q9GxagRapBKFQyjWW00
KdUrxQcapZWKomnaLo4e8IfDWKekYhHjFKjVrJlNo643DKtu1oyKiViIqJyf
A6G1RqmOY2wacH6uwIej49ZYBfHv9luXE+yew9F/cmHcGvR7F2JGAUU7Og7C
dObGKCv040rzo87OPupJqKpNgdDvDy/+UBUNt3ZtFUiyZDGfAfnHK5EkDJjP
SwhOwlyFpoA++jQcfG5C4gYLj8MsXN1g44R+5PHHoqV1JRcQWiZCOVUzfaKv
FpPGpldVDx6ssFsV2skzhnqDyRQxyz46VXcDR1/MwziNWUDuVmz2Drq+DrzF
3WmtSat63TJp3Wo0KlvcmSVk0sx5+w3AtsFNIF1ysKWrMA7iEgRh7DPPW4Mb
3Ie36P4HN11CGKVuGCRgS1/ouF8R+89g4TgKyWZxRIZVReu3Ri37z+vhaJpN
/47zfr2GPxY7y7OAL5nHfZQ1FO2i30Y5uXU+6tno473dGA4bdEGAFEd65Amu
wpk7X8sjdG1gwQy6mewMozpwM5PTUArMeOKKaCpOKgHElv2FzVnRybAOVzH4
zFm6AdcBBkNUDzGf81gAS7catRJFNxt10eSuTU7KzkmGflL+cgI8SOM1RKEb
pAk61POAP0bcSYEaFrlxU5h7IUsxRomUkRjpOuLS0aQrHZ1zjsMnbxvotpg7
qzhx77nsM4/UiGxovZiwiglF24Ha2bzlXO1Jwz5A7uDr9vhvSUg3Jyk36jpz
kDCt8mbTDiPsqpeeaQt2OfTbmZl7BHtucPsai8KlgjeLlizQrGqJVgvachGS
IDfu3HVKEsV3vyCsuPuIfRMzZDJZhitvBjccVom4Ikse8Ps8pqIwSVx8hnRV
kpe/GSA/4bLpcIRPb7s3VssCjs9vPJboDG/RtuhzSaeQy25ILvhcLns/hOD0
6nKj+YBg6i/w/4TYyYRfQuQoqe2dBhfvcrO0PfPFUmGytmeyWNuYqe2ZKRY3
pml7pj3tlOYomgiHof3XVWcwbU17wwGg0R17Ohx/Fmu9ueAeFkhPzFIOy9T3
IGILnsCxeE3lhFrCxOGsfLykTMRMdkGR28hjDrLrBugRVDKR/sCL64UxJ2Ln
IRU+3qttDTh+mwLcoGj56DB3YvFA/vlBxcE31AUN67RhGMZWbjmtU1EXiOYd
dcEmTA5XBlnv37zb7oyQ6da0035PyVDUCrulQ/bUTHqDy37nGhVNoCk4mGCE
j22pPO8eoGGTpfkjE2DvoOIQ1G6qN0zdrNEKrVar9Feq/9mpnpoy1dPGVqoX
uEv8YfCg7oQD1mRBigbhC8CiKA6j2MV3wVvr0MIZ1B0k/G7FA4djegl4Vi9k
+QQvQmEbZM7JKJl7bJFAsnKWwBJ03zziBBN4dBZi0sHS4eFNdcJbq4DvTfqH
UvoPzeAmVl4Y9WZdNL9S+Hen8Jcz+CsJ/LX8/Vr6frIkD4UXsjf8/Oz9PyYq
ByVlDwAA
====
EOF
uudecode lapack-$LAPACK_VER".patch.gz.uue"
gunzip lapack-$LAPACK_VER".patch.gz"
# Make libblas.a and liblapack.a
# Patch
rm -Rf lapack-$LAPACK_VER
tar -xf $LAPACK_ARCHIVE
pushd lapack-$LAPACK_VER
patch -p1 < ../lapack-$LAPACK_VER".patch"
mv -f make.inc.example make.inc
popd
# Make libblas.so
pushd lapack-$LAPACK_VER/BLAS/SRC
LAPACK_OPTFLAGS=$OPTFLAGS make -j 6 libblas.a libblas.so
popd
# Make liblapack.so
pushd lapack-$LAPACK_VER/SRC
LAPACK_OPTFLAGS=$OPTFLAGS make -j 6 liblapack.a liblapack.so
popd
# Install
mkdir -p $OCTAVE_LIB_DIR
mv -f lapack-$LAPACK_VER/BLAS/SRC/libblas.a $OCTAVE_LIB_DIR
mv -f lapack-$LAPACK_VER/BLAS/SRC/libblas.so $OCTAVE_LIB_DIR
mv -f lapack-$LAPACK_VER/SRC/liblapack.a $OCTAVE_LIB_DIR
mv -f lapack-$LAPACK_VER/SRC/liblapack.so $OCTAVE_LIB_DIR
# Make libqblas.a and libqlapack.a
# Patch
rm -Rf lapack-$LAPACK_VER
tar -xf $LAPACK_ARCHIVE
pushd lapack-$LAPACK_VER
patch -p1 < ../lapack-$LAPACK_VER".patch"
mv -f INSTALL/make.inc.gfortran-quad make.inc
popd
# Make libqblas.a
pushd lapack-$LAPACK_VER/BLAS/SRC
LAPACK_OPTFLAGS=$OPTFLAGS make -j 6 libqblas.a
popd
# Make libqlapack.a
pushd lapack-$LAPACK_VER/SRC
LAPACK_OPTFLAGS=$OPTFLAGS make -j 6 libqlapack.a
popd
# Install
mv -f lapack-$LAPACK_VER/BLAS/SRC/libqblas.a $OCTAVE_LIB_DIR
mv -f lapack-$LAPACK_VER/SRC/libqlapack.a $OCTAVE_LIB_DIR
# Cleanup
rm -Rf lapack-$LAPACK_VER
rm -f lapack-$LAPACK_VER".patch" 
rm -f lapack-$LAPACK_VER".patch.gz"
rm -f lapack-$LAPACK_VER".patch.gz.uue"

#
# Build arpack
#
rm -Rf arpack-ng-$ARPACK_VER
tar -xf $ARPACK_ARCHIVE
pushd arpack-ng-$ARPACK_VER
sh ./bootstrap
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS
LDFLAGS="-L"$OCTAVE_LIB_DIR F77=gfortran \
./configure --prefix=$OCTAVE_INSTALL_DIR \
            --with-blas=-lblas --with-lapack=-llapack
make && make install
popd
rm -Rf arpack-ng-$ARPACK_VER

#
# Build SuiteSparse
#
rm -Rf SuiteSparse-$SUITESPARSE_VER
tar -xf $SUITESPARSE_ARCHIVE
pushd SuiteSparse-$SUITESPARSE_VER
cd SuiteSparse_config
export CMAKE_OPTIONS="-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_C_FLAGS=\"$OPTFLAGS\" \
-DCMAKE_CXX_FLAGS=\"$OPTFLAGS\" \
-DCMAKE_Fortran_FLAGS=\"$OPTFLAGS\" \
-DENABLE_CUDA=0 \
-DBLA_VENDOR=generic \
-DALLOW_64BIT_BLAS=0 \
-DBLAS_LIBRARIES=$OCTAVE_LIB_DIR/libblas.so \
-DLAPACK_LIBRARIES=$OCTAVE_LIB_DIR/liblapack.so \
-DCMAKE_INSTALL_LIBDIR:PATH=$OCTAVE_LIB_DIR \
-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
-DCMAKE_INSTALL_PREFIX=$OCTAVE_INSTALL_DIR"
make
cd ..
make -j 6 && make install
popd
rm -Rf SuiteSparse-$SUITESPARSE_VER

#
# Build qrupdate
#
rm -Rf qrupdate-$QRUPDATE_VER
tar -xf $QRUPDATE_ARCHIVE
pushd qrupdate-$QRUPDATE_VER
rm -f Makeconf
cat > Makeconf << 'EOF'
FC=gfortran
QRUPDATE_OPTFLAGS ?= -m64 -march=nehalem -O2
FFLAGS=-fimplicit-none -funroll-loops $(QRUPDATE_OPTFLAGS)
FPICFLAGS=-fPIC

ifeq ($(strip $(PREFIX)),)
  PREFIX=/usr/local
endif

BLAS=-L$(PREFIX)/lib -lblas
LAPACK=-L$(PREFIX)/lib -llapack

VERSION=1.1
MAJOR=1
LIBDIR=lib
DESTDIR=
EOF
PREFIX=$OCTAVE_INSTALL_DIR QRUPDATE_OPTFLAGS=$OPTFLAGS make solib install
popd
rm -Rf qrupdate-$QRUPDATE_VER

#
# Build glpk
#
rm -Rf glpk-$GLPK_VER
tar -xf $GLPK_ARCHIVE
cat > glpk-$GLPK_VER.patch << 'EOF'
--- glpk-5.0/src/minisat/minisat.h	2020-12-16 20:00:00.000000000 +1100
+++ glpk-5.0.new/src/minisat/minisat.h	2025-04-20 18:51:38.388597147 +1000
@@ -34,7 +34,9 @@
 /*====================================================================*/
 /* Simple types: */
 
+#if 0
 typedef int bool;
+#endif
 
 #define true  1
 #define false 0
EOF
pushd glpk-$GLPK_VER
patch -p1 < "../glpk-"$GLPK_VER".patch"
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_INSTALL_DIR
make -j 6 && make install
popd
rm -Rf glpk-$GLPK_VER glpk-$GLPK_VER.patch

#
# Build fftw
#
rm -Rf fftw-$FFTW_VER
tar -xf $FFTW_ARCHIVE
pushd fftw-$FFTW_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_INSTALL_DIR --enable-shared \
            --with-combined-threads --enable-threads
make -j 6 && make install
popd
rm -Rf fftw-$FFTW_VER

#
# Build fftw single-precision
#
rm -Rf fftw-$FFTW_VER
tar -xf $FFTW_ARCHIVE
pushd fftw-$FFTW_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_INSTALL_DIR --enable-shared \
           --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd
rm -Rf fftw-$FFTW_VER

#
# Build sundials
#
rm -Rf sundials-$SUNDIALS_VER
tar -xf $SUNDIALS_ARCHIVE
mkdir build-sundials-$SUNDIALS_VER
pushd build-sundials-$SUNDIALS_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
echo " c \n g \n q \n" | \
    ccmake -DENABLE_KLU=ON \
           -DKLU_LIBRARY_DIR:PATH=$OCTAVE_LIB_DIR \
           -DKLU_INCLUDE_DIR:PATH=$OCTAVE_INCLUDE_DIR/suitesparse \
           -DCMAKE_INSTALL_LIBDIR=lib \
           --install-prefix $OCTAVE_INSTALL_DIR \
           ../sundials-$SUNDIALS_VER
cmake ../sundials-$SUNDIALS_VER
make -j 6 && make install
popd
rm -Rf build-sundials-$SUNDIALS_VER sundials-$SUNDIALS_VER

#
# Build GraphicsMagick
#
rm -Rf GraphicsMagick-$GRAPHICSMAGICK_VER
tar -xf $GRAPHICSMAGICK_ARCHIVE
mkdir build-GraphicsMagick-$GRAPHICSMAGICK_VER
pushd build-GraphicsMagick-$GRAPHICSMAGICK_VER
../GraphicsMagick-$GRAPHICSMAGICK_VER/configure \
    --prefix=$OCTAVE_INSTALL_DIR --enable-shared --disable-static \
    --with-quantum-depth=16  --with-magick-plus-plus=yes
make && make install
popd
rm -Rf build-GraphicsMagick-$GRAPHICSMAGICK_VER \
       GraphicsMagick-$GRAPHICSMAGICK_VER

#
# Build octave
#
rm -Rf octave-$OCTAVE_VER
tar -xf $OCTAVE_ARCHIVE
# Patch
cat > octave-$OCTAVE_VER".patch.gz.uue" << 'EOF'
begin-base64 644 octave-10.3.0.patch.gz
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
dn9XVqulQgEL9Q640lA/nPd/EQ7K/zoyAAA=
====
EOF
uudecode octave-$OCTAVE_VER".patch.gz.uue"
gunzip -f octave-$OCTAVE_VER".patch.gz"
# Patch
pushd octave-$OCTAVE_VER
patch -p1 < ../octave-$OCTAVE_VER.patch
popd

# Build
rm -Rf build-octave-$OCTAVE_VER
mkdir build-octave-$OCTAVE_VER
pushd build-octave-$OCTAVE_VER

# Add --enable-address-sanitizer-flags for address sanitizer build
# To disable checking in atexit(): export ASAN_OPTIONS="leak_check_at_exit=0"
# See: https://wiki.octave.org/Finding_Memory_Leaks

export CFLAGS="$OPTFLAGS -I$OCTAVE_INCLUDE_DIR"
# Suppress warning for deprecated std::wbuffer_convert<convfacet_u8, char>
export CXXFLAGS="$OPTFLAGS -I$OCTAVE_INCLUDE_DIR -Wno-deprecated-declarations -fno-diagnostics-color"
export FFLAGS=$OPTFLAGS
export LDFLAGS="-L$OCTAVE_LIB_DIR"

export JAVA_HOME=/usr/lib/jvm/java
export PKG_CONFIG_PATH=$OCTAVE_LIB_DIR/pkgconfig
OCTAVE_CONFIG_OPTIONS="\
    --prefix=$OCTAVE_INSTALL_DIR \
    --without-fltk \
    --disable-openmp \
    --with-blas=-lblas \
    --with-lapack=-llapack \
    --with-qt=6 \
    --with-arpack-includedir=$OCTAVE_INCLUDE_DIR \
    --with-arpack-libdir=$OCTAVE_LIB_DIR \
    --with-qrupdate-includedir=$OCTAVE_INCLUDE_DIR \
    --with-qrupdate-libdir=$OCTAVE_LIB_DIR \
    --with-amd-includedir=$OCTAVE_INCLUDE_DIR \
    --with-amd-libdir=$OCTAVE_LIB_DIR \
    --with-camd-includedir=$OCTAVE_INCLUDE_DIR \
    --with-camd-libdir=$OCTAVE_LIB_DIR \
    --with-colamd-includedir=$OCTAVE_INCLUDE_DIR \
    --with-colamd-libdir=$OCTAVE_LIB_DIR \
    --with-ccolamd-includedir=$OCTAVE_INCLUDE_DIR \
    --with-ccolamd-libdir=$OCTAVE_LIB_DIR \
    --with-cholmod-includedir=$OCTAVE_INCLUDE_DIR \
    --with-cholmod-libdir=$OCTAVE_LIB_DIR \
    --with-cxsparse-includedir=$OCTAVE_INCLUDE_DIR \
    --with-cxsparse-libdir=$OCTAVE_LIB_DIR \
    --with-umfpack-includedir=$OCTAVE_INCLUDE_DIR \
    --with-umfpack-libdir=$OCTAVE_LIB_DIR \
    --with-glpk-includedir=$OCTAVE_INCLUDE_DIR \
    --with-glpk-libdir=$OCTAVE_LIB_DIR \
    --with-fftw3-includedir=$OCTAVE_INCLUDE_DIR \
    --with-fftw3-libdir=$OCTAVE_LIB_DIR \
    --with-fftw3f-includedir=$OCTAVE_INCLUDE_DIR \
    --with-fftw3f-libdir=$OCTAVE_LIB_DIR \
    --with-klu-includedir=$OCTAVE_INCLUDE_DIR/suitesparse \
    --with-klu-libdir=$OCTAVE_LIB_DIR \
    --with-sundials_nvecserial-includedir=$OCTAVE_INCLUDE_DIR \
    --with-sundials_nvecserial-libdir=$OCTAVE_LIB_DIR \
    --with-sundials_ida-includedir=$OCTAVE_INCLUDE_DIR \
    --with-sundials_ida-libdir=$OCTAVE_LIB_DIR \
    --with-sundials_sunlinsolklu-includedir=$OCTAVE_INCLUDE_DIR \
    --with-sundials_sunlinsolklu-libdir=$OCTAVE_LIB_DIR"

../octave-$OCTAVE_VER/configure $OCTAVE_CONFIG_OPTIONS \
PACKAGE_VERSION="$OCTAVE_VER-robj" \
PACKAGE_STRING="GNU Octave $OCTAVE_VER-robj"
make V=1 -j6 -O 
make install
popd

rm -Rf build-octave-$OCTAVE_VER octave-$OCTAVE_VER octave-$OCTAVE_VER.patch*

#
# Update ld.so.conf.d
#
grep $OCTAVE_LIB_DIR /etc/ld.so.conf.d/usr_local_octave_lib.conf
if test $? -ne 0; then \
    echo $OCTAVE_LIB_DIR > /etc/ld.so.conf.d/usr_local_octave_lib.conf ; \
fi
ldconfig $OCTAVE_LIB_DIR

#
# Compiling octave is done
#

#
# Install Octave-Forge packages
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$IO_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$STRUCT_ARCHIVE

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$STATISTICS_ARCHIVE
rm -f $OCTAVE_SHARE_DIR/packages/statistics-$STATISTICS_VER/PKG_ADD
rm -f $OCTAVE_SHARE_DIR/packages/statistics-$STATISTICS_VER/PKG_DEL

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$CONTROL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$PIQP_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$SYMBOLIC_ARCHIVE

#
# Fix optim package and install the new optim package
#
cat > optim-$OPTIM_VER.patch << 'EOF'
--- optim-1.6.2/src/__max_nargin_optim__.cc	2022-04-11 00:31:04.000000000 +1000
+++ optim-1.6.2.new/src/__max_nargin_optim__.cc	2024-02-12 23:39:51.725763032 +1100
@@ -74,7 +74,7 @@
   else {
 
     retval = octave_value
-      (fcn.user_function_value ()->parameter_list ()->length ());
+      (fcn.user_function_value ()->parameter_list ()->size ());
   }
 
   return retval;
EOF
tar -xf $OPTIM_ARCHIVE
pushd optim-$OPTIM_VER
patch -p1 < ../optim-$OPTIM_VER.patch
popd
NEW_OPTIM_ARCHIVE=optim-$OPTIM_VER".new.tar.gz"
tar -czf $NEW_OPTIM_ARCHIVE optim-$OPTIM_VER
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_OPTIM_ARCHIVE
rm -Rf optim-$OPTIM_VER optim-$OPTIM_VER.patch $NEW_OPTIM_ARCHIVE

#
# Fix parallel package and install the new parallel package
#
cat > parallel-$PARALLEL_VER.patch << 'EOF'
--- parallel-4.0.2/src/octave-pserver.cc	2023-09-10 02:01:50.000000000 +1000
+++ parallel-4.0.2.new/src/octave-pserver.cc	2025-08-15 12:36:19.425637344 +1000
@@ -380,7 +380,7 @@
 static
 char * copy_to_non_const (const char *str)
 {
-  char *ret = new char [strlen (str)];
+  char *ret = new char [strlen (str)+1];
 
   strcpy (ret, str);
 
EOF
tar -xf $PARALLEL_ARCHIVE
pushd parallel-$PARALLEL_VER
patch -p1 < ../parallel-$PARALLEL_VER.patch
popd
NEW_PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".new.tar.gz"
tar -czf $NEW_PARALLEL_ARCHIVE parallel-$PARALLEL_VER
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_PARALLEL_ARCHIVE
rm -Rf parallel-$PARALLEL_VER parallel-$PARALLEL_VER.patch $NEW_PARALLEL_ARCHIVE

#
# Fix signal package and install the new signal package
#
tar -xf $SIGNAL_ARCHIVE
cat > signal-$SIGNAL_VER.patch << 'EOF'
--- signal-1.4.6.new/inst/zplane.m	2024-09-20 22:54:20.000000000 +1000
+++ signal-1.4.6/inst/zplane.m	2024-10-07 16:31:36.611737803 +1100
@@ -115,8 +115,9 @@
       for i = 1:length (x_u)
         n = sum (x_u(i) == x(:,c));
         if (n > 1)
-          label = sprintf (" ^%d", n);
-          text (real (x_u(i)), imag (x_u(i)), label, "color", color);
+          label = sprintf ("%d", n);
+          text (real (x_u(i)), imag (x_u(i)), label, "color", color, ...
+                "verticalalignment", "bottom", "horizontalalignment", "left");
         endif
       endfor
     endfor
EOF
pushd signal-$SIGNAL_VER
patch -p1 < ../signal-$SIGNAL_VER.patch
popd
NEW_SIGNAL_ARCHIVE=signal-$SIGNAL_VER".new.tar.gz"
tar -czf $NEW_SIGNAL_ARCHIVE signal-$SIGNAL_VER
rm -Rf signal-$SIGNAL_VER signal-$SIGNAL_VER.patch

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_SIGNAL_ARCHIVE
rm -f $NEW_SIGNAL_ARCHIVE

#
#
# Installing Octave-Forge packages is done
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg list"

#
# Install solver packages from the GitHub forked repositories
#

OCTAVE_LOCAL_VERSION=\
"`$OCTAVE_BIN_DIR/octave-cli --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m

#
# Install SeDuMi
#
SEDUMI_VER=${SEDUMI_VER:-1.3.8}
SEDUMI_ARCHIVE="sedumi-"$SEDUMI_VER".tar.gz"
SEDUMI_URL="https://github.com/sqlp/sedumi/archive/refs/tags/v"$SEDUMI_VER".tar.gz"
if ! test -f $SEDUMI_ARCHIVE ; then
    wget -c $SEDUMI_URL
    mv "v"$SEDUMI_VER".tar.gz" $SEDUMI_ARCHIVE
fi
tar -xf $SEDUMI_ARCHIVE
rm -f sedumi-$SEDUMI_VER/vec.m
rm -f sedumi-$SEDUMI_VER/*.mex*
rm -Rf $OCTAVE_SITE_M_DIR/SeDuMi
cat > sedumi-$SEDUMI_VER.patch.gz.uue << 'EOF'
begin-base64 644 sedumi-1.3.8.patch.gz
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
AA==
====
EOF
uudecode "sedumi-"$SEDUMI_VER".patch.gz.uue"
gunzip "sedumi-"$SEDUMI_VER".patch.gz"
pushd sedumi-$SEDUMI_VER
patch -p 1 < ../sedumi-$SEDUMI_VER".patch"
popd
rm -Rf sedumi-"$SEDUMI_VER".patch.gz.uue \
sedumi-"$SEDUMI_VER".patch.gz sedumi-"$SEDUMI_VER".patch
mv -f sedumi-$SEDUMI_VER $OCTAVE_SITE_M_DIR/SeDuMi
if test $? -ne 0;then rm -Rf sedumi-$SEDUMI_VER; exit -1; fi
$OCTAVE_BIN_DIR/octave --no-gui $OCTAVE_SITE_M_DIR/SeDuMi/install_sedumi.m

#
# Install SDPT3
#
SDPT3_VER=${SDPT3_VER:-4.0-20240410}
SDPT3_ARCHIVE="sdpt3-"$SDPT3_VER".tar.gz"
SDPT3_URL="https://github.com/sqlp/sdpt3/archive/refs/tags/"$SDPT3_VER".tar.gz"
if ! test -f sdpt3-$SDPT3_VER.tar.gz ; then
  wget -c $SDPT3_URL
  mv $SDPT3_VER.tar.gz $SDPT3_ARCHIVE
fi
rm -Rf sdpt3-$SDPT3_VER $OCTAVE_SITE_M_DIR/SDPT3
tar -xf $SDPT3_ARCHIVE 
rm -f sdpt3-$SDPT3_VER/Solver/Mexfun/*.mex*
rm -Rf sdpt3-$SDPT3_VER/Solver/Mexfun/o_win
mv -f sdpt3-$SDPT3_VER $OCTAVE_SITE_M_DIR/SDPT3
if test $? -ne 0;then rm -Rf sdpt3-$SDPT3_VER; exit -1; fi
$OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SDPT3/install_sdpt3.m

#
# Install YALMIP
#
YALMIP_VER=${YALMIP_VER:-R20230622}
YALMIP_ARCHIVE=$YALMIP_VER".tar.gz"
YALMIP_URL="https://github.com/yalmip/YALMIP/archive/refs/tags/"$YALMIP_ARCHIVE
if ! test -f "YALMIP-"$YALMIP_ARCHIVE ; then
    wget -c $YALMIP_URL
    mv $YALMIP_ARCHIVE "YALMIP-"$YALMIP_ARCHIVE
fi
tar -xf "YALMIP-"$YALMIP_ARCHIVE
cat > YALMIP-$YALMIP_VER.patch << 'EOF'
--- YALMIP-R20230622.orig/extras/ismembcYALMIP.m	2023-06-22 21:57:52.000000000 +1000
+++ YALMIP-R20230622/extras/ismembcYALMIP.m	2024-02-09 17:57:56.674186190 +1100
@@ -1,14 +1,6 @@
 function members=ismembcYALMIP(a,b)
-
-% ismembc is fast, but does not exist in octave
-% however, try-catch is very slow in Octave,
-% Octave user: Just replace the whole code here
-% with "members = ismember(a,b);"
-try
-    members = ismembc(a,b);
-catch
-    members = ismember(a,b);
-end
+  members = ismember(a,b);
+endfunction
EOF
# Patch
pushd YALMIP-$YALMIP_VER
patch -p 1 < ../YALMIP-$YALMIP_VER".patch"
popd
rm -f "YALMIP-"$YALMIP_VER".patch"
mv -f "YALMIP-"$YALMIP_VER $OCTAVE_SITE_M_DIR/YALMIP
if test $? -ne 0;then rm -Rf "YALMIP-"$YALMIP_VER; exit -1; fi

#
# Install SparsePOP
#
if ! test -f SparsePOP-master.zip ; then
  wget -c https://github.com/robertgj/SparsePOP/archive/refs/heads/master.zip
  mv master.zip SparsePOP-master.zip
fi
rm -Rf SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
unzip SparsePOP-master.zip
find SparsePOP-master -name \*.mex* -exec rm -f {} ';'
mv -f SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
if test $? -ne 0;then rm -Rf SparsePOP-master; exit -1; fi
# !! Do not build the SparsePOP .mex files !!
# $OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SparsePOP/compileSparsePOP.m

#
# Install gloptipoly
#
GLOPTIPOLY3_URL=http://homepages.laas.fr/henrion/software/gloptipoly3
if ! test -f gloptipoly3.zip ; then
  wget -c $GLOPTIPOLY3_URL/gloptipoly3.zip
fi
GLOPTIPOLY3_VER=3.10-octave-20220924
cat > gloptipoly3-$GLOPTIPOLY3_VER.patch.gz.uue << 'EOF'
begin-base64 644 gloptipoly3-3.10-octave-20220924.patch.gz
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
====
EOF
uudecode gloptipoly3-$GLOPTIPOLY3_VER.patch.gz.uue
gunzip gloptipoly3-$GLOPTIPOLY3_VER.patch.gz
rm -Rf gloptipoly3 $OCTAVE_SITE_M_DIR/gloptipoly3
unzip gloptipoly3.zip
pushd gloptipoly3
patch -p 1 < ../gloptipoly3-$GLOPTIPOLY3_VER.patch
popd
rm -f gloptipoly3-$GLOPTIPOLY3_VER.patch.gz.uue \
gloptipoly3-$GLOPTIPOLY3_VER.patch.gz gloptipoly3-$GLOPTIPOLY3_VER.patch
mv -f gloptipoly3 $OCTAVE_SITE_M_DIR

#
# Install SCS
#

# Get SCS Matlab interface source
SCS_MATLAB=${SCS_MATLAB:-"scs-matlab-master"}
SCS_MATLAB_ARCHIVE=$SCS_MATLAB".zip"
SCS_MATLAB_URL="https://github.com/bodono/scs-matlab/archive/refs/heads/master.zip"
if ! test -f $SCS_MATLAB_ARCHIVE ; then
    wget -c $SCS_MATLAB_URL
    mv master.zip $SCS_MATLAB_ARCHIVE
fi
unzip $SCS_MATLAB_ARCHIVE

# Get SCS source
SCS_VER=${SCS_VER:-3.2.7}
SCS_ARCHIVE=scs-$SCS_VER".tar.gz"
SCS_URL="https://github.com/cvxgrp/scs/archive/refs/tags/"$SCS_VER.tar.gz
if ! test -f $SCS_ARCHIVE ; then
    wget -c $SCS_URL
    mv $SCS_VER.tar.gz $SCS_ARCHIVE
fi
tar -xf $SCS_ARCHIVE

# Copy SCS source 
mv -f scs-${SCS_VER}/* $SCS_MATLAB"/scs"

# Patch SCS
cat > $SCS_MATLAB".patch.gz.uue" <<EOF
begin-base64 644 scs-matlab-master.patch.gz
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
====
EOF
uudecode $SCS_MATLAB".patch.gz.uue"
gunzip $SCS_MATLAB".patch.gz"
pushd $SCS_MATLAB
patch -p 1 < ../$SCS_MATLAB".patch"
popd
rm -Rf $SCS_MATLAB".patch.gz.uue" $SCS_MATLAB".patch.gz"  $SCS_MATLAB".patch"

# Install scs_qprintf.c
cat > scs_qprintf.c.gz.uue <<EOF
begin-base64 644 scs_qprintf.c.gz
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
====
EOF
uudecode scs_qprintf.c.gz.uue
gunzip scs_qprintf.c.gz
mv scs_qprintf.c  $SCS_MATLAB
rm -f scs_qprintf.c.gz.uue scs_qprintf.c.gz

# Build and install SCS
rm -Rf $OCTAVE_SITE_M_DIR/SCS
mkdir -p $OCTAVE_SITE_M_DIR/SCS
pushd $SCS_MATLAB
$OCTAVE_BIN_DIR/octave-cli --eval "make_scs"
cp -f LICENSE README.md scs*.m scs*.mex $OCTAVE_SITE_M_DIR/SCS
popd

# Build HTML documentation
#
# Install (at least) the following Fedora packages:
#    texlive-cancel texlive-ellipse texlive-hyphen-polish texlive-pict2e
#    sphinx sphinx-php sphinxbase sphinxbase-devel sphinxbase-libs
#    python3-sphinx python3-sphinx-theme-alabaster python3-sphinx_rtd_theme
#    python-sphinx_rtd_theme-doc python3-sphinxcontrib-devhelp
#    python3-sphinxcontrib-htmlhelp python3-sphinxcontrib-jquery
#    python3-sphinxcontrib-qthelp python3-sphinxcontrib-serializinghtml
#
# Building LaTeX documentation fails, possibly due to multirow:
#    ! Misplaced \omit.
#    \math@cr@@@ ...@ \@ne \add@amps \maxfields@ \omit 
#                                                  \kern -\alignsep@ \iftag@ ...
#    l.421 \end{align}\end{split}
#
pushd $SCS_MATLAB/scs/docs/src
doxygen -u
make html
rm -Rf $OCTAVE_SHARE_DIR/doc/scs
mkdir -p $OCTAVE_SHARE_DIR/doc/scs
mv _build/html $OCTAVE_SHARE_DIR/doc/scs
popd

# Done
rm -Rf scs-$SCS_VER $SCS_MATLAB $SCS_MATLAB.patch $SCS_MATLAB.patch.uue

#
# Solver installation done
#
