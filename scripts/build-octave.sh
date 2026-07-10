#!/bin/sh

# Build a local version of octave-cli
#
# Require Fedora packages: 
# dnf install readline-devel lzip sharutils ccache gcc gcc-c++ \
# gcc-gfortran gmp-devel mpfr-devel make cmake gnuplot-latex m4 gperf \
# bison flex openblas-devel patch texinfo texinfo-tex librsvg2-devel \
# librsvg2-tools icoutils autoconf automake libtool pcre pcre-devel \
# freetype-devel texlive-dvisvgm gl2ps gl2ps-devel hdf5 hdf5-devel \
# qhull qhull-devel portaudio-devel libsndfile-devel \
# libcurl-devel gl2ps gl2ps-devel fontconfig-devel \
# mesa-libGLU-devel qt6-qtbase-devel \
# qt6-qt5compat qt6-qt5compat-devel qt6-qttools \
# qt6-qttools-common qt6-qttools-devel rapidjson-devel python3-sympy \
# xerces-j2 util-linux util-linux-core util-linux-script \
# qscintilla-qt6 qscintilla-qt6-devel eigen3-devel eigen3-doc boost-devel \
# texlive-standalone java-25-openjdk java-25-openjdk-devel emacs \
# doxygen texlive-cancel texlive-ellipse texlive-hyphen-polish texlive-pict2e \
# sphinx sphinx-php python3-sphinx python3-sphinx-theme-alabaster \
# python3-sphinx_rtd_theme python-sphinx_rtd_theme-doc \
# python3-sphinxcontrib-devhelp python3-sphinxcontrib-htmlhelp \
# python3-sphinxcontrib-jquery python3-sphinxcontrib-qthelp \
# python3-sphinxcontrib-serializinghtml python3-breathe python-breathe-doc
#
# Remove Fedora packages: 
# dnf remove xdg-desktop-portal xdg-desktop-portal-gtk
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
OCTAVE_VER=${OCTAVE_VER:-11.3.0}
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

FFTW_VER=${FFTW_VER:-3.3.11}
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

GRAPHICSMAGICK_VER=${GRAPHICSMAGICK_VER:-1.3.47}
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

CONTROL_VER=${CONTROL_VER:-4.2.2}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL="https://github.com/gnu-octave/pkg-control/releases/download/control-"$CONTROL_VER/$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
  wget -c $CONTROL_URL 
fi

DATATYPES_VER=${DATATYPES_VER:-1.2.6}
DATATYPES_ARCHIVE=datatypes-$DATATYPES_VER".tar.gz"
DATATYPES_URL="https://github.com/pr0m1th3as/datatypes/releases/download/release-$DATATYPES_VER/$DATATYPES_ARCHIVE"
if ! test -f $DATATYPES_ARCHIVE; then
  wget -c $DATATYPES_URL 
fi

IO_VER=${IO_VER:-2.7.2}
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

PIQP_VER=${PIQP_VER:-0.6.3}
PIQP_ARCHIVE=piqp-octave-v$PIQP_VER.tar.gz
PIQP_URL=https://github.com/PREDICT-EPFL/piqp/releases/download/v$PIQP_VER/$PIQP_ARCHIVE
if ! test -f $PIQP_ARCHIVE; then
    wget -c $PIQP_URL
fi

SIGNAL_VER=${SIGNAL_VER:-1.4.7}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=https://github.com/gnu-octave/octave-signal/releases/download/$SIGNAL_VER/$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
  wget -c $SIGNAL_URL 
fi

STATISTICS_VER=${STATISTICS_VER:-1.8.3}
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
begin-base64 644 octave-11.3.0.patch.gz
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
export CXXFLAGS="$CFLAGS -std=gnu++17 -Wno-deprecated-declarations -fno-diagnostics-color"
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

OCTAVE_LOCAL_VERSION=`$OCTAVE_BIN_DIR/octave-cli --eval 'disp(OCTAVE_VERSION);'`
OCTAVE_LOCAL_INCLUDE_DIR=$OCTAVE_INCLUDE_DIR/octave-$OCTAVE_LOCAL_VERSION
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m

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

CFLAGS="$CFLAGS -I$OCTAVE_LOCAL_INCLUDE_DIR" \
CXXFLAGS="$CXXFLAGS -I$OCTAVE_LOCAL_INCLUDE_DIR" \
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
rm -Rf $OCTAVE_SITE_M_DIR/SeDuMi
cat > sedumi-$SEDUMI_VER.patch.gz.uue << 'EOF'
begin-base64 644 sedumi-1.3.8.patch.gz
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
====
EOF
uudecode sedumi-$SEDUMI_VER.patch.gz.uue
gunzip sedumi-$SEDUMI_VER.patch.gz
pushd sedumi-$SEDUMI_VER
patch -p 1 < ../sedumi-$SEDUMI_VER.patch
popd
rm -Rf sedumi-$SEDUMI_VER.patch.gz.uue
rm -Rf sedumi-$SEDUMI_VER.patch.gz
rm -Rf sedumi-$SEDUMI_VER.patch
rm -Rf sedumi-$SEDUMI_VER/vec.m
rm -Rf sedumi-$SEDUMI_VER/*.mex*
rm -Rf sedumi-$SEDUMI_VER/.github
rm -Rf sedumi-$SEDUMI_VER/.gitignore
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
rm -Rf sdpt3-$SDPT3_VER/.github
rm -Rf sdpt3-$SDPT3_VER/.gitignore
rm -Rf sdpt3-$SDPT3_VER/Solver/Mexfun/*.mex*
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
# Patch
cat > YALMIP-$YALMIP_VER.patch.gz.uue << 'EOF'
begin-base64 644 YALMIP-R20250626_fix2.patch.gz
H4sICIWA42kAA1lBTE1JUC1SMjAyNTA2MjZfZml4Mi5wYXRjaACtVN9vmzAQ
fvdfcYpUkQxMgRDyS9XSvW1qtWrby54qB46CRHBmO03y3/cMtGtXmvWhlsD2
+fN3x93Hcc7h9+XV9dcb/iMKokmQRMltXh6iczwYJTRNW6mMvwF7yoOERwlE
0SKaLeLADx4HuCG9meu6/Wx+jfs+xoQHMQ9nlnFCjGM/nCfBbJyEYce4WgEP
45k3p30zrVYMzuDTuwcDi/9ZVtURKBLIpQJTIChMsTYgsqw0paxB5mSqUGgE
I0HL6h4V1GKDjJc53awzbdTQqcp6q+Sd41Vyj2rY4nwj7kYj5hKQQBZ7Ggh2
/LXABTzBl4xjpfG5yz87kb3ts0M/+T2J7nH8hF8ywDqjdPH/SaLUG9ys0xbz
kcroIX4ukOliPPbnYTKLo2j6QiBeGNPWSxp15Ls6bUpqyVDpixe0Q+GtR4wz
fgadnWbIhTYerHcGMokaamkAD6U2UJIyUiPu0V4oKKOUOg+MOvJUmLSwd8ly
BE3ZtuDvDdiz6HYJO41qAd92RKZwW4kUG/3tC1khpDJDKFA19PvSFDDooqba
tPFRDW3IywHj5JZxW8J/MWkLYW1Q/ZhHHhIYldk9AXAJ8JhE+/tA+7yti1ZR
+jxD0iB2uw8RxgnmHmVMw3gymz9XxjS2nYPe00YauNmaY6d/+kBURlDNKAPB
8uXhXSXXouoOGL++/HV1+eW2woP1b7V1Ad1q6PCubzg2t33IV7ZhuJiMlnB2
o3Y1wlZqXa5JDIU09OGf+0noByf5DLvpFcJzhOM5fuiMPGdtV5ENx+1jGgyW
bVN8bwOl9ik3SBGIOhMq6xqIbvpkudlWZX5shMweAK05HJZNBgAA
====
EOF
uudecode YALMIP-$YALMIP_VER.patch.gz.uue
gunzip YALMIP-$YALMIP_VER.patch.gz
pushd YALMIP-$YALMIP_VER
patch -p 1 < ../YALMIP-$YALMIP_VER".patch"
popd
rm -f "YALMIP-"$YALMIP_VER".patch"
rm -f "YALMIP-"$YALMIP_VER".patch.gz"
rm -f "YALMIP-"$YALMIP_VER".patch.gz.uue"
rm -f "YALMIP-"$YALMIP_VER/.gitignore
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
SCS_MATLAB_VER=${SCS_MATLAB_VER:-3.2.5}
SCS_MATLAB_ARCHIVE=scs-matlab-$SCS_MATLAB_VER".tar.gz"
SCS_MATLAB_URL="https://github.com/bodono/scs-matlab/archive/refs/tags/"$SCS_MATLAB_VER".tar.gz"

if ! test -f $SCS_MATLAB_ARCHIVE ; then
    wget -c $SCS_MATLAB_URL
    mv $SCS_MATLAB_VER".tar.gz" $SCS_MATLAB_ARCHIVE
fi
tar -xf $SCS_MATLAB_ARCHIVE

# Patch scs-matlab
cat > "scs-matlab-"$SCS_MATLAB_VER".patch.gz.uue" <<EOF
begin-base64 644 scs-matlab-3.2.5.patch.gz
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
5X+bmC6LxHS5Iqb/B/g0TB80RgAA
====
EOF
uudecode "scs-matlab-"$SCS_MATLAB_VER".patch.gz.uue"
gunzip "scs-matlab-"$SCS_MATLAB_VER".patch.gz"
pushd "scs-matlab-"$SCS_MATLAB_VER
patch -p 1 < ../"scs-matlab-"$SCS_MATLAB_VER".patch"
popd

# Get SCS source
SCS_VER=${SCS_VER:-3.2.11}
SCS_ARCHIVE=scs-$SCS_VER".tar.gz"
SCS_URL="https://github.com/cvxgrp/scs/archive/refs/tags/"$SCS_VER".tar.gz"
if ! test -f $SCS_ARCHIVE ; then
    wget -c $SCS_URL
    mv $SCS_VER".tar.gz" $SCS_ARCHIVE
fi
tar -xf $SCS_ARCHIVE
# Patch scs
cat > "scs-"$SCS_VER".patch.gz.uue" <<EOF
begin-base64 644 scs-3.2.11.patch.gz
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
/hS6AAA=
====
EOF
uudecode "scs-"$SCS_VER".patch.gz.uue"
gunzip "scs-"$SCS_VER".patch.gz"
pushd "scs-"$SCS_VER
patch -p 1 < ../"scs-"$SCS_VER".patch"
popd

# Copy SCS source
cp -Rf "scs-"$SCS_VER/* "scs-matlab-"$SCS_MATLAB_VER"/scs"

# Install scs_qprintf.c
cat > scs_qprintf.c.gz.uue <<EOF
begin-base64 644 scs_qprintf.c.gz
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
====
EOF
uudecode scs_qprintf.c.gz.uue
gunzip scs_qprintf.c.gz
mv scs_qprintf.c "scs-matlab-"$SCS_MATLAB_VER"/scs/src"

# Build and install SCS
rm -Rf $OCTAVE_SITE_M_DIR/SCS
mkdir -p $OCTAVE_SITE_M_DIR/SCS
pushd "scs-matlab-"$SCS_MATLAB_VER
$OCTAVE_BIN_DIR/octave-cli --eval "make_scs"
rm -Rf matlab/scs_dense.mex
cp -Rf LICENSE README.md scs_*.mex matlab $OCTAVE_SITE_M_DIR/SCS
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

pushd "scs-matlab-"$SCS_MATLAB_VER/scs/docs/src
doxygen -u
make html
rm -Rf $OCTAVE_SHARE_DIR/doc/scs
mkdir -p $OCTAVE_SHARE_DIR/doc/scs
mv _build/html $OCTAVE_SHARE_DIR/doc/scs
popd

# Done
rm -Rf "scs-matlab-"$SCS_MATLAB_VER".patch.gz.uue"
rm -Rf "scs-matlab-"$SCS_MATLAB_VER".patch.gz"
rm -Rf "scs-matlab-"$SCS_MATLAB_VER".patch"
rm -Rf "scs-matlab-"$SCS_MATLAB_VER
rm -Rf "scs-"$SCS_VER".patch.gz.uue"
rm -Rf "scs-"$SCS_VER".patch.gz"
rm -Rf "scs-"$SCS_VER".patch"
rm -Rf "scs-"$SCS_VER 
rm -f scs_qprintf.c.gz.uue scs_qprintf.c.gz

#
# Solver installation done
#
