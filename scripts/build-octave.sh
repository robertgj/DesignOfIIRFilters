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
# qscintilla-qt6 qscintilla-qt6-devel eigen3-devel eigen3-doc boost-devel jekyll
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
# For GraphicsMagick copy the public key from
#  http://www.graphicsmagick.org/security.html
# to, for example gm-sigs.asc, and then
#  gpg --import gm-sigs.asc
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
OCTAVE_VER=${OCTAVE_VER:-11.1.0}
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

SUITESPARSE_VER=${SUITESPARSE_VER:-7.12.2}
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

SUNDIALS_VER=${SUNDIALS_VER:-7.7.0}
SUNDIALS_ARCHIVE=sundials-$SUNDIALS_VER".tar.gz"
SUNDIALS_URL=https://github.com/LLNL/sundials/releases/download/v$SUNDIALS_VER/$SUNDIALS_ARCHIVE
if ! test -f $SUNDIALS_ARCHIVE; then
  wget -c $SUNDIALS_URL
fi

GRAPHICSMAGICK_VER=${GRAPHICSMAGICK_VER:-1.3.46}
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

CONTROL_VER=${CONTROL_VER:-4.2.1}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL="https://github.com/gnu-octave/pkg-control/releases/download/control-"$CONTROL_VER/$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
  wget -c $CONTROL_URL 
fi

DATATYPES_VER=${DATATYPES_VER:-1.2.2}
DATATYPES_ARCHIVE=datatypes-$DATATYPES_VER".tar.gz"
DATATYPES_URL="https://github.com/pr0m1th3as/datatypes/releases/download/release-$DATATYPES_VER/$DATATYPES_ARCHIVE"
if ! test -f $DATATYPES_ARCHIVE; then
  wget -c $DATATYPES_URL 
fi

IO_VER=${IO_VER:-2.7.1}
IO_ARCHIVE=io-$IO_VER".tar.gz"
IO_URL=$OCTAVE_FORGE_URL/$IO_ARCHIVE
if ! test -f $IO_ARCHIVE; then
  wget -c $IO_URL
fi

OPTIM_VER=${OPTIM_VER:-1.6.3}
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

SIGNAL_VER=${SIGNAL_VER:-1.4.7}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=https://github.com/gnu-octave/octave-signal/releases/download/$SIGNAL_VER/$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
  wget -c $SIGNAL_URL 
fi

STATISTICS_VER=${STATISTICS_VER:-1.8.2}
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
    ccmake -DSUNDIALS_ENABLE_KLU=ON \
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
begin-base64 644 octave-11.1.0.patch.gz
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
I3EsAAA=
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

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$DATATYPES_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$STATISTICS_ARCHIVE
rm -f $OCTAVE_SHARE_DIR/packages/statistics-$STATISTICS_VER/PKG_ADD
rm -f $OCTAVE_SHARE_DIR/packages/statistics-$STATISTICS_VER/PKG_DEL

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$CONTROL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$OPTIM_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$PIQP_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$SIGNAL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$SYMBOLIC_ARCHIVE

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
YALMIP_VER=${YALMIP_VER:-R20250626_fix2}
YALMIP_ARCHIVE=$YALMIP_VER".tar.gz"
YALMIP_URL="https://github.com/yalmip/YALMIP/archive/refs/tags/"$YALMIP_ARCHIVE
if ! test -f "YALMIP-"$YALMIP_ARCHIVE ; then
    wget -c $YALMIP_URL
    mv $YALMIP_ARCHIVE "YALMIP-"$YALMIP_ARCHIVE
fi
tar -xf "YALMIP-"$YALMIP_ARCHIVE
cat > YALMIP-$YALMIP_VER.patch << 'EOF'
--- YALMIP-R20250626_fix2/extras/ismembcYALMIP.m	2025-06-26 22:28:40.000000000 +1000
+++ YALMIP-R20250626_fix2.new/extras/ismembcYALMIP.m	2026-04-17 19:57:21.252246937 +1000
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
 
   
   
--- YALMIP-R20250626_fix2/solvers/definesolvers.m	2025-06-26 22:28:40.000000000 +1000
+++ YALMIP-R20250626_fix2.new/solvers/definesolvers.m	2026-04-17 20:00:21.959154279 +1000
@@ -74,9 +74,7 @@
 emptysolver.uncertain  = 0;
 emptysolver.global = 0;
 
-MATLAB_lexversion = version('-release');
-MATLAB_lexversion = MATLAB_lexversion(1:5); %Prune possible hotfix?
-MATLAB_lexversion = strrep(strrep(MATLAB_lexversion,'a','.1'),'b','.2');
+MATLAB_lexversion = "";
 
 % **************************************
 % Some standard solvers to simplify code
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
SCS_VER=${SCS_VER:-3.2.11}
SCS_ARCHIVE=scs-$SCS_VER".tar.gz"
SCS_URL="https://github.com/cvxgrp/scs/archive/refs/tags/"$SCS_VER.tar.gz
if ! test -f $SCS_ARCHIVE ; then
    wget -c $SCS_URL
    mv $SCS_VER.tar.gz $SCS_ARCHIVE
fi
tar -xf $SCS_ARCHIVE

# Copy SCS source 
cp -Rf scs-${SCS_VER}/* $SCS_MATLAB"/scs"

# Patch SCS
cat > $SCS_MATLAB".patch.gz.uue" <<EOF
begin-base64 644 scs-matlab-master.patch.gz
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
P6WjyUM6mqR09G/ldlJ54i4AAA==
====
EOF
uudecode $SCS_MATLAB".patch.gz.uue"
gunzip $SCS_MATLAB".patch.gz"
pushd $SCS_MATLAB
patch -p 1 < ../$SCS_MATLAB".patch"
popd

# Install scs_qprintf.c
cat > scs_qprintf.c.gz.uue <<EOF
begin-base64 644 scs_qprintf.c.gz
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
====
EOF
uudecode scs_qprintf.c.gz.uue
gunzip scs_qprintf.c.gz
mv scs_qprintf.c $SCS_MATLAB

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
#   doxygen texlive-cancel texlive-ellipse texlive-hyphen-polish texlive-pict2e
#   sphinx sphinx-php python3-sphinx python3-sphinx-theme-alabaster
#   python3-sphinx_rtd_theme python-sphinx_rtd_theme-doc
#   python3-sphinxcontrib-devhelp python3-sphinxcontrib-htmlhelp
#   python3-sphinxcontrib-jquery python3-sphinxcontrib-qthelp
#   python3-sphinxcontrib-serializinghtml python3-breathe python3-breathe-doc
#
# Building LaTeX documentation fails, possibly due to multirow:
#    ! Misplaced \omit.
#    \math@cr@@@ ...@ \@ne \add@amps \maxfields@ \omit 
#                                                  \kern -\alignsep@ \iftag@ ...
#    l.421 \end{align}\end{split}

pushd $SCS_MATLAB/scs/docs/src
doxygen -u
make html
rm -Rf $OCTAVE_SHARE_DIR/doc/scs
mkdir -p $OCTAVE_SHARE_DIR/doc/scs
mv _build/html $OCTAVE_SHARE_DIR/doc/scs
popd

# Done
rm -Rf $SCS_MATLAB".patch.gz.uue" $SCS_MATLAB".patch.gz"  $SCS_MATLAB".patch"
rm -f scs_qprintf.c.gz.uue scs_qprintf.c.gz
rm -Rf scs-$SCS_VER $SCS_MATLAB $SCS_MATLAB.patch $SCS_MATLAB.patch.uue

#
# Solver installation done
#
