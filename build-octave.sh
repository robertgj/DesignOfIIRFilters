#!/bin/sh

# Build a local version of octave-cli
#
# Require Fedora packages: wget readline-devel lzip sharutils gcc gcc-c++
# gcc-gfortran gmp-devel mpfr-devel make cmake gnuplot-latex m4 gperf 
# bison flex openblas-devel patch texinfo texinfo-tex librsvg2 librsvg2-devel
# librsvg2-tools icoutils autoconf automake libtool pcre pcre-devel freetype
# freetype-devel gnupg2 texlive-dvisvgm gl2ps gl2ps-devel
# hdf5 hdf5-devel qt qscintilla-qt5 qscintilla-qt5-devel
# qhull qhull-devel portaudio portaudio-devel libsndfile libsndfile-devel
# libcurl libcurl-devel gl2ps gl2ps-devel fontconfig-devel mesa-libGLU
# mesa-libGLU-devel qt5-qttools qt5-qttools-common qt5-qttools-devel
# rapidjson-devel python3-sympy
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
OCTAVE_VER=8.2.0
OCTAVE_ARCHIVE=octave-$OCTAVE_VER".tar.lz"
OCTAVE_URL=https://ftp.gnu.org/gnu/octave/$OCTAVE_ARCHIVE
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
OCTAVE_DIR="/usr/local/octave-"$OCTAVE_VER
OCTAVE_INCLUDE_DIR=$OCTAVE_DIR/include
OCTAVE_LIB_DIR=$OCTAVE_DIR/lib
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin
OCTAVE_SHARE_DIR=$OCTAVE_DIR/share/octave
export LD_LIBRARY_PATH=$OCTAVE_LIB_DIR
export LDFLAGS=-L$OCTAVE_LIB_DIR
export PATH=$PATH:$OCTAVE_BIN_DIR

#
# Get library archives
#
LAPACK_VER=${LAPACK_VER:-3.11.0}
LAPACK_ARCHIVE=lapack-$LAPACK_VER".tar.gz"
LAPACK_URL=http://github.com/Reference-LAPACK/lapack/archive/v$LAPACK_VER.tar.gz
if ! test -f $LAPACK_ARCHIVE; then
  wget -c $LAPACK_URL -O $LAPACK_ARCHIVE
fi

ARPACK_VER=${ARPACK_VER:-3.9.0}
ARPACK_ARCHIVE=arpack-ng-$ARPACK_VER".tar.gz"
ARPACK_URL=https://github.com/opencollab/arpack-ng/archive/refs/tags/$ARPACK_VER".tar.gz"
if ! test -f $ARPACK_ARCHIVE; then
  wget -c $ARPACK_URL -O $ARPACK_ARCHIVE
fi

SUITESPARSE_VER=${SUITESPARSE_VER:-7.0.1}
SUITESPARSE_ARCHIVE=SuiteSparse-$SUITESPARSE_VER".tar.gz"
SUITESPARSE_URL=https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v$SUITESPARSE_VER".tar.gz"
if ! test -f $SUITESPARSE_ARCHIVE; then
  wget -c $SUITESPARSE_URL -O $SUITESPARSE_ARCHIVE
fi

QRUPDATE_VER=${QRUPDATE_VER:-1.1.2}
QRUPDATE_ARCHIVE=qrupdate-$QRUPDATE_VER".tar.gz"
QRUPDATE_URL=https://sourceforge.net/projects/qrupdate/files/qrupdate/1.2/$QRUPDATE_ARCHIVE
if ! test -f $QRUPDATE_ARCHIVE; then
  wget -c $QRUPDATE_URL
fi

FFTW_VER=${FFTW_VER:-3.3.10}
FFTW_ARCHIVE=fftw-$FFTW_VER".tar.gz"
FFTW_URL=ftp://ftp.fftw.org/pub/fftw/$FFTW_ARCHIVE
if ! test -f $FFTW_ARCHIVE; then
  wget -c $FFTW_URL
fi

GLPK_VER=${GLPK_VER:-5.0}
GLPK_ARCHIVE=glpk-$GLPK_VER".tar.gz"
GLPK_URL=https://ftp.gnu.org/gnu/glpk/$GLPK_ARCHIVE
if ! test -f $GLPK_ARCHIVE; then
  wget -c $GLPK_URL
fi

SUNDIALS_VER=${SUNDIALS_VER:-6.5.1}
SUNDIALS_ARCHIVE=sundials-$SUNDIALS_VER".tar.gz"
SUNDIALS_URL=https://github.com/LLNL/sundials/releases/download/v$SUNDIALS_VER/$SUNDIALS_ARCHIVE
if ! test -f $SUNDIALS_ARCHIVE; then
  wget -c $SUNDIALS_URL
fi

GRAPHICSMAGICK_VER=${GRAPHICSMAGICK_VER:-1.3.40}
GRAPHICSMAGICK_ARCHIVE=GraphicsMagick-$GRAPHICSMAGICK_VER".tar.xz"
GRAPHICSMAGICK_URL=https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/$GRAPHICSMAGICK_VER/GraphicsMagick-$GRAPHICSMAGICK_VER.tar.xz
if ! test -f $GRAPHICSMAGICK_ARCHIVE; then
  wget -c $GRAPHICSMAGICK_URL
fi
if ! test -f $GRAPHICSMAGICK_ARCHIVE".sig"; then
  wget -c $GRAPHICSMAGICK_URL".sig"
fi
gpg2 --verify $GRAPHICSMAGICK_ARCHIVE".sig"
if test $? -ne 0;then 
    echo Bad GPG signature on $GRAPHICSMAGICK_ARCHIVE ;
    exit -1;
fi

#
# Get octave-forge packages
#

OCTAVE_FORGE_URL=https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases

IO_VER=${IO_VER:-2.6.4}
IO_ARCHIVE=io-$IO_VER".tar.gz"
IO_URL=$OCTAVE_FORGE_URL/$IO_ARCHIVE
if ! test -f $IO_ARCHIVE; then
  wget -c $IO_URL
fi

STATISTICS_VER=${STATISTICS_VER:-1.5.4}
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

OPTIM_VER=${OPTIM_VER:-1.6.2}
OPTIM_ARCHIVE=optim-$OPTIM_VER".tar.gz"
OPTIM_URL=$OCTAVE_FORGE_URL/$OPTIM_ARCHIVE
if ! test -f $OPTIM_ARCHIVE; then
  wget -c $OPTIM_URL 
fi

CONTROL_VER=${CONTROL_VER:-3.5.2}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL="https://github.com/gnu-octave/pkg-control/releases/download/control-"$CONTROL_VER/$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
  wget -c $CONTROL_URL 
fi

SIGNAL_VER=${SIGNAL_VER:-1.4.4}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=$OCTAVE_FORGE_URL/$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
  wget -c $SIGNAL_URL 
fi

PARALLEL_VER=${PARALLEL_VER:-4.0.1}
PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".tar.gz"
PARALLEL_URL=$OCTAVE_FORGE_URL/$PARALLEL_ARCHIVE
if ! test -f $PARALLEL_ARCHIVE; then
  wget -c $PARALLEL_URL 
fi

SYMBOLIC_VER=${SYMBOLIC_VER:-3.1.1}
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
rm -Rf $OCTAVE_DIR
echo "Building octave-"$OCTAVE_VER

#
# Build lapack
#
rm -Rf lapack-$LAPACK_VER
tar -xf $LAPACK_ARCHIVE
cat > lapack-$LAPACK_VER.patch.uue << 'EOF'
begin-base64 644 lapack-3.11.0.patch
LS0tIGxhcGFjay0zLjExLjAub3JpZy9CTEFTL1NSQy9NYWtlZmlsZQkyMDIy
LTExLTEyIDA0OjQ5OjU0LjAwMDAwMDAwMCArMTEwMAorKysgbGFwYWNrLTMu
MTEuMC9CTEFTL1NSQy9NYWtlZmlsZQkyMDIzLTAzLTE4IDE2OjMwOjAwLjY0
OTQyNDA3NCArMTEwMApAQCAtMTQ5LDYgKzE0OSw5IEBACiAJJChBUikgJChB
UkZMQUdTKSAkQCAkXgogCSQoUkFOTElCKSAkQAogCiskKG5vdGRpciAkKEJM
QVNMSUI6JS5hPSUuc28pKTogJChBTExPQkopCisJJChGQykgLXNoYXJlZCAt
V2wsLXNvbmFtZSwkQCAtbyAkQCAkXgorCiAuUEhPTlk6IHNpbmdsZSBkb3Vi
bGUgY29tcGxleCBjb21wbGV4MTYKIHNpbmdsZTogJChTQkxBUzEpICQoQUxM
QkxBUykgJChTQkxBUzIpICQoU0JMQVMzKQogCSQoQVIpICQoQVJGTEFHUykg
JChCTEFTTElCKSAkXgotLS0gbGFwYWNrLTMuMTEuMC5vcmlnL1NSQy9NYWtl
ZmlsZQkyMDIyLTExLTEyIDA0OjQ5OjU0LjAwMDAwMDAwMCArMTEwMAorKysg
bGFwYWNrLTMuMTEuMC9TUkMvTWFrZWZpbGUJMjAyMy0wMy0xOCAxNjozMDow
MC42NDg0MjQwODIgKzExMDAKQEAgLTU1Niw2ICs1NTYsOSBAQAogCSQoQVIp
ICQoQVJGTEFHUykgJEAgJF4KIAkkKFJBTkxJQikgJEAKIAorJChub3RkaXIg
JChMQVBBQ0tMSUI6JS5hPSUuc28pKTogJChBTExPQkopICQoQUxMWE9CSikg
JChERVBSRUNBVEVEKQorCSQoRkMpIC1zaGFyZWQgLVdsLC1zb25hbWUsJEAg
LW8gJEAgJF4KKwogLlBIT05ZOiBzaW5nbGUgY29tcGxleCBkb3VibGUgY29t
cGxleDE2CiAKIFNJTkdMRV9ERVBTIDo9ICQoU0xBU1JDKSAkKERTTEFTUkMp
Ci0tLSBsYXBhY2stMy4xMS4wLm9yaWcvbWFrZS5pbmMuZXhhbXBsZQkyMDIy
LTExLTEyIDA0OjQ5OjU0LjAwMDAwMDAwMCArMTEwMAorKysgbGFwYWNrLTMu
MTEuMC9tYWtlLmluYy5leGFtcGxlCTIwMjMtMDMtMTggMTY6MzA6MDAuNjQ5
NDI0MDc0ICsxMTAwCkBAIC03LDcgKzcsOCBAQAogIyAgQ0MgaXMgdGhlIEMg
Y29tcGlsZXIsIG5vcm1hbGx5IGludm9rZWQgd2l0aCBvcHRpb25zIENGTEFH
Uy4KICMKIENDID0gZ2NjCi1DRkxBR1MgPSAtTzMKK0JMRE9QVFMgPSAtZlBJ
QyAtbTY0IC1tYXJjaD1uZWhhbGVtCitDRkxBR1MgPSAtTzMgJChCTERPUFRT
KQogCiAjICBNb2RpZnkgdGhlIEZDIGFuZCBGRkxBR1MgZGVmaW5pdGlvbnMg
dG8gdGhlIGRlc2lyZWQgY29tcGlsZXIKICMgIGFuZCBkZXNpcmVkIGNvbXBp
bGVyIG9wdGlvbnMgZm9yIHlvdXIgbWFjaGluZS4gIE5PT1BUIHJlZmVycyB0
bwpAQCAtMTcsMTAgKzE4LDEwIEBACiAjICBhbmQgaGFuZGxlIHRoZXNlIHF1
YW50aXRpZXMgYXBwcm9wcmlhdGVseS4gQXMgYSBjb25zZXF1ZW5jZSwgb25l
CiAjICBzaG91bGQgbm90IGNvbXBpbGUgTEFQQUNLIHdpdGggZmxhZ3Mgc3Vj
aCBhcyAtZmZwZS10cmFwPW92ZXJmbG93LgogIwotRkMgPSBnZm9ydHJhbgot
RkZMQUdTID0gLU8yIC1mcmVjdXJzaXZlCitGQyA9IGdmb3J0cmFuIC1mcmVj
dXJzaXZlICQoQkxET1BUUykKK0ZGTEFHUyA9IC1PMiAKIEZGTEFHU19EUlYg
PSAkKEZGTEFHUykKLUZGTEFHU19OT09QVCA9IC1PMCAtZnJlY3Vyc2l2ZQor
RkZMQUdTX05PT1BUID0gLU8wCiAKICMgIERlZmluZSBMREZMQUdTIHRvIHRo
ZSBkZXNpcmVkIGxpbmtlciBvcHRpb25zIGZvciB5b3VyIG1hY2hpbmUuCiAj
CkBAIC01NSw3ICs1Niw3IEBACiAjICBVbmNvbW1lbnQgdGhlIGZvbGxvd2lu
ZyBsaW5lIHRvIGluY2x1ZGUgZGVwcmVjYXRlZCByb3V0aW5lcyBpbgogIyAg
dGhlIExBUEFDSyBsaWJyYXJ5LgogIwotI0JVSUxEX0RFUFJFQ0FURUQgPSBZ
ZXMKK0JVSUxEX0RFUFJFQ0FURUQgPSBZZXMKIAogIyAgTEFQQUNLRSBoYXMg
dGhlIGludGVyZmFjZSB0byBzb21lIHJvdXRpbmVzIGZyb20gdG1nbGliLgog
IyAgSWYgTEFQQUNLRV9XSVRIX1RNRyBpcyBkZWZpbmVkLCBhZGQgdGhvc2Ug
cm91dGluZXMgdG8gTEFQQUNLRS4KQEAgLTc0LDcgKzc1LDcgQEAKICMgIG1h
Y2hpbmUtc3BlY2lmaWMsIG9wdGltaXplZCBCTEFTIGxpYnJhcnkgc2hvdWxk
IGJlIHVzZWQgd2hlbmV2ZXIKICMgIHBvc3NpYmxlLikKICMKLUJMQVNMSUIg
ICAgICA9ICQoVE9QU1JDRElSKS9saWJyZWZibGFzLmEKK0JMQVNMSUIgICAg
ICA9ICQoVE9QU1JDRElSKS9saWJibGFzLmEKIENCTEFTTElCICAgICA9ICQo
VE9QU1JDRElSKS9saWJjYmxhcy5hCiBMQVBBQ0tMSUIgICAgPSAkKFRPUFNS
Q0RJUikvbGlibGFwYWNrLmEKIFRNR0xJQiAgICAgICA9ICQoVE9QU1JDRElS
KS9saWJ0bWdsaWIuYQo=
====
EOF
# Patch
uudecode lapack-$LAPACK_VER".patch.uue"
tar -xf $LAPACK_ARCHIVE
pushd lapack-$LAPACK_VER
patch -p1 < ../lapack-$LAPACK_VER".patch"
mv -f make.inc.example make.inc
popd
# Make libblas.so
pushd lapack-$LAPACK_VER/BLAS/SRC
make -j 6 libblas.so
popd
# Make liblapack.so
pushd lapack-$LAPACK_VER/SRC
make -j 6 liblapack.so
popd
# Install
mkdir -p $OCTAVE_LIB_DIR
pushd lapack-$LAPACK_VER/BLAS/SRC
cp libblas.so $OCTAVE_LIB_DIR
popd
pushd lapack-$LAPACK_VER/SRC
cp liblapack.so $OCTAVE_LIB_DIR
popd
rm -Rf lapack-$LAPACK_VER
rm -f lapack-$LAPACK_VER".patch" lapack-$LAPACK_VER".patch.uue"

#
# Build arpack
#
rm -Rf arpack-ng-$ARPACK_VER
tar -xf $ARPACK_ARCHIVE
pushd arpack-ng-$ARPACK_VER
sh ./bootstrap
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
LDFLAGS=-L$OCTAVE_LIB_DIR F77=gfortran \
./configure --prefix=$OCTAVE_DIR --with-blas=-lblas --with-lapack=-llapack
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
-DALLOW_64BIT_BLAS=1 \
-DBLAS_LIBRARIES=$OCTAVE_LIB_DIR/libblas.so \
-DLAPACK_LIBRARIES=$OCTAVE_LIB_DIR/liblapack.so \
-DCMAKE_INSTALL_LIBDIR:PATH=$OCTAVE_LIB_DIR \
-DCMAKE_INSTALL_PREFIX=$OCTAVE_DIR"
# If debugging cmake try : -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON 
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
FFLAGS=-fimplicit-none -funroll-loops -m64 -march=nehalem -O2
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
make PREFIX=$OCTAVE_DIR solib install
popd
rm -Rf qrupdate-$QRUPDATE_VER

#
# Build glpk
#
rm -Rf glpk-$GLPK_VER
tar -xf $GLPK_ARCHIVE
pushd glpk-$GLPK_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_DIR
make -j 6 && make install
popd
rm -Rf glpk-$GLPK_VER

#
# Build fftw
#
rm -Rf fftw-$FFTW_VER
tar -xf $FFTW_ARCHIVE
pushd fftw-$FFTW_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_DIR --enable-shared \
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
./configure --prefix=$OCTAVE_DIR --enable-shared \
           --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd
rm -Rf fftw-$FFTW_VER

#
# Build sundials
#
rm -Rf sundials-$SUNDIALS_VER
tar -xf $SUNDIALS_ARCHIVE
mkdir -p build-sundials-$SUNDIALS_VER
pushd build-sundials-$SUNDIALS_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
echo " c \n g \n q \n" | \
    ccmake -DENABLE_KLU=ON \
           -DKLU_LIBRARY_DIR:PATH=$OCTAVE_LIB_DIR \
           -DKLU_INCLUDE_DIR:PATH=$OCTAVE_INCLUDE_DIR \
           -DCMAKE_INSTALL_LIBDIR=lib \
           --install-prefix $OCTAVE_DIR \
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
mkdir -p build-GraphicsMagick-$GRAPHICSMAGICK_VER
pushd build-GraphicsMagick-$GRAPHICSMAGICK_VER
../GraphicsMagick-$GRAPHICSMAGICK_VER/configure \
    --prefix=$OCTAVE_DIR --enable-shared --disable-static \
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
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-8.2.0.patch
LS0tIG9jdGF2ZS04LjIuMC9jb25maWd1cmUJMjAyMy0wNC0xNCAwMjo0Mzoz
NS4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS04LjIuMC5uZXcvY29uZmln
dXJlCTIwMjMtMDUtMDEgMDk6NDg6NTAuODYyOTQ0NzY0ICsxMDAwCkBAIC02
MjEsOCArNjIxLDggQEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgog
UEFDS0FHRV9OQU1FPSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdv
Y3RhdmUnCi1QQUNLQUdFX1ZFUlNJT049JzguMi4wJwotUEFDS0FHRV9TVFJJ
Tkc9J0dOVSBPY3RhdmUgOC4yLjAnCitQQUNLQUdFX1ZFUlNJT049JzguMi4w
LXJvYmonCitQQUNLQUdFX1NUUklORz0nR05VIE9jdGF2ZSA4LjIuMC1yb2Jq
JwogUEFDS0FHRV9CVUdSRVBPUlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdz
Lmh0bWwnCiBQQUNLQUdFX1VSTD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0
d2FyZS9vY3RhdmUvJwogCi0tLSBvY3RhdmUtOC4yLjAvbGliaW50ZXJwL2Nv
cmVmY24vbG9hZC1zYXZlLmNjCTIwMjMtMDQtMTQgMDI6NDM6MzUuMDAwMDAw
MDAwICsxMDAwCisrKyBvY3RhdmUtOC4yLjAubmV3L2xpYmludGVycC9jb3Jl
ZmNuL2xvYWQtc2F2ZS5jYwkyMDIzLTA1LTAxIDA5OjQ4OjUwLjg2ODk0NDgw
OCArMTAwMApAQCAtMTI4LDggKzEyOCw4IEBACiB7CiAgIGNvbnN0IGludCBt
YWdpY19sZW4gPSAxMDsKICAgY2hhciBtYWdpY1ttYWdpY19sZW4rMV07Ci0g
IGlzLnJlYWQgKG1hZ2ljLCBtYWdpY19sZW4pOwogICBtYWdpY1ttYWdpY19s
ZW5dID0gJ1wwJzsKKyAgaXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7CiAK
ICAgaWYgKHN0cm5jbXAgKG1hZ2ljLCAiT2N0YXZlLTEtTCIsIG1hZ2ljX2xl
bikgPT0gMCkKICAgICBzd2FwID0gbWFjaF9pbmZvOjp3b3Jkc19iaWdfZW5k
aWFuICgpOwotLS0gb2N0YXZlLTguMi4wL3NjcmlwdHMvcGxvdC91dGlsL3By
aXZhdGUvX19nbnVwbG90X2RyYXdfYXhlc19fLm0JMjAyMy0wNC0xNCAwMjo0
MzozNS4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS04LjIuMC5uZXcvc2Ny
aXB0cy9wbG90L3V0aWwvcHJpdmF0ZS9fX2dudXBsb3RfZHJhd19heGVzX18u
bQkyMDIzLTA1LTAxIDA5OjQ4OjUwLjg2OTk0NDgxNSArMTAwMApAQCAtMjI4
Myw3ICsyMjgzLDcgQEAKICAgICBpZiAoISB3YXJuZWRfbGF0ZXgpCiAgICAg
ICBkb193YXJuID0gKHdhcm5pbmcgKCJxdWVyeSIsICJPY3RhdmU6dGV4dF9p
bnRlcnByZXRlciIpKS5zdGF0ZTsKICAgICAgIGlmIChzdHJjbXAgKGRvX3dh
cm4sICJvbiIpKQotICAgICAgICB3YXJuaW5nICgiT2N0YXZlOnRleHRfaW50
ZXJwcmV0ZXIiLAorICAgICAgICB3YXJuaW5nICgiT2N0YXZlOmxhdGV4LW1h
cmt1cC1ub3Qtc3VwcG9ydGVkLWZvci10aWNrLW1hcmtzIiwKICAgICAgICAg
ICAgICAgICAgImxhdGV4IG1hcmt1cCBub3Qgc3VwcG9ydGVkIGZvciB0aWNr
IG1hcmtzIik7CiAgICAgICAgIHdhcm5lZF9sYXRleCA9IHRydWU7CiAgICAg
ICBlbmRpZgo=
====
EOF
uudecode octave-$OCTAVE_VER.patch.uue
pushd octave-$OCTAVE_VER
patch -p1 < ../octave-$OCTAVE_VER.patch
popd
# Build
rm -Rf build
mkdir build
pushd build
export CFLAGS="$OPTFLAGS -std=c17 -I$OCTAVE_INCLUDE_DIR"
export CXXFLAGS="$OPTFLAGS -std=c++17 -I$OCTAVE_INCLUDE_DIR"
export FFLAGS=$OPTFLAGS
export LDFLAGS="-L$OCTAVE_LIB_DIR"
# Add --enable-address-sanitizer-flags for address sanitizer build
PKG_CONFIG_PATH=$OCTAVE_LIB_DIR/pkgconfig \
../octave-$OCTAVE_VER/configure \
    --prefix=$OCTAVE_DIR \
    --disable-java \
    --without-fltk \
    --with-blas=-lblas \
    --with-lapack=-llapack \
    --with-qt=5 \
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
    --with-klu-includedir=$OCTAVE_INCLUDE_DIR \
    --with-klu-libdir=$OCTAVE_LIB_DIR \
    --with-sundials_nvecserial-includedir=$OCTAVE_INCLUDE_DIR \
    --with-sundials_nvecserial-libdir=$OCTAVE_LIB_DIR \
    --with-sundials_ida-includedir=$OCTAVE_INCLUDE_DIR \
    --with-sundials_ida-libdir=$OCTAVE_LIB_DIR \
    --with-sundials_sunlinsolklu-includedir=$OCTAVE_INCLUDE_DIR \
    --with-sundials_sunlinsolklu-libdir=$OCTAVE_LIB_DIR 

#
# Generate profile
#
export PGO_GEN_FLAGS="-pthread -fopenmp -fprofile-generate"
make XTRA_CFLAGS="$PGO_GEN_FLAGS" XTRA_CXXFLAGS="$PGO_GEN_FLAGS" V=1 -j6
find . -name \*.gcda -exec rm -f {} ';'
make V=1 check

#
# Use profile
#
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
export PGO_LTO_FLAGS="-pthread -fopenmp -flto=6 -ffat-lto-objects -fprofile-use"
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
make install
popd
rm -Rf build octave-$OCTAVE_VER
rm -f octave-$OCTAVE_VER.patch.uue octave-$OCTAVE_VER.patch

#
# Update ld.so.conf.d
#
echo $OCTAVE_LIB_DIR > /etc/ld.so.conf.d/usr_local_octave_lib.conf
ldconfig 

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
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$OPTIM_ARCHIVE

#
# Fix parallel package pserver.cc and install the parallel package
#
cat > parallel-$PARALLEL_VER".patch.uue" << 'EOF'
begin-base64 644 parallel-4.0.1.patch
LS0tIHBhcmFsbGVsLTQuMC4xLm9yaWcvc3JjL3AtY29udHJvbC5jYwkyMDIx
LTAzLTE3IDA1OjAzOjA5LjAwMDAwMDAwMCArMTEwMAorKysgcGFyYWxsZWwt
NC4wLjEvc3JjL3AtY29udHJvbC5jYwkyMDIzLTAzLTE5IDA5OjMyOjE4LjAw
MDAwMDAwMCArMTEwMApAQCAtMjg2LDcgKzI4Niw3IEBACiAgICAgICAgIH0K
ICAgICAgIGVsc2UKICAgICAgICAgewotICAgICAgICAgIG5wcm9jX21heCA9
IG51bV9wcm9jZXNzb3JzIChOUFJPQ19DVVJSRU5UKTsKKyAgICAgICAgICBu
cHJvY19tYXggPSBvY3RhdmVfbnVtX3Byb2Nlc3NvcnNfd3JhcHBlciAoTlBS
T0NfQ1VSUkVOVCk7CiAKICAgICAgICAgICBnbnVsaWJfcG9sbGZkcyA9IGdu
dWxpYl9hbGxvY19wb2xsZmRzIChucHJvY19tYXgpOwogICAgICAgICB9Ci0t
LSBwYXJhbGxlbC00LjAuMS5vcmlnL3NyYy9jb25maWd1cmUJMjAyMS0wMy0x
NyAwNTowMzo0NC43NjY3Mzc4MTcgKzExMDAKKysrIHBhcmFsbGVsLTQuMC4x
L3NyYy9jb25maWd1cmUJMjAyMy0wMy0xOSAwOTozMjoxOC4wMDAwMDAwMDAg
KzExMDAKQEAgLTIzNDgyLDExICsyMzQ4MiwxMSBAQAogX0FDRU9GCiBpZiBh
Y19mbl9jeHhfdHJ5X2NvbXBpbGUgIiRMSU5FTk8iOyB0aGVuIDoKIAotJGFz
X2VjaG8gIiNkZWZpbmUgT0NUQVZFX19JTlRFUlBSRVRFUl9fU1lNQk9MX1RB
QkxFX19BU1NJR04gb2N0YXZlOjppbnRlcnByZXRlcjo6dGhlX2ludGVycHJl
dGVyICgpIC0+IGdldF9zeW1ib2xfdGFibGUgKCkuYXNzaWduIiA+PmNvbmZk
ZWZzLmgKKyRhc19lY2hvICIjZGVmaW5lIE9DVEFWRV9fSU5URVJQUkVURVJf
X1NZTUJPTF9UQUJMRV9fQVNTSUdOIG9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRo
ZV9pbnRlcnByZXRlciAoKSAtPiBhc3NpZ24iID4+Y29uZmRlZnMuaAogCiAK
LSAgICAgeyAkYXNfZWNobyAiJGFzX21lOiR7YXNfbGluZW5vLSRMSU5FTk99
OiByZXN1bHQ6IG9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRl
ciAoKSAtPiBnZXRfc3ltYm9sX3RhYmxlICgpLmFzc2lnbiIgPiY1Ci0kYXNf
ZWNobyAib2N0YXZlOjppbnRlcnByZXRlcjo6dGhlX2ludGVycHJldGVyICgp
IC0+IGdldF9zeW1ib2xfdGFibGUgKCkuYXNzaWduIiA+JjY7IH0KKyAgICAg
eyAkYXNfZWNobyAiJGFzX21lOiR7YXNfbGluZW5vLSRMSU5FTk99OiByZXN1
bHQ6IG9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRlciAoKSAt
PiBhc3NpZ24iID4mNQorJGFzX2VjaG8gIm9jdGF2ZTo6aW50ZXJwcmV0ZXI6
OnRoZV9pbnRlcnByZXRlciAoKSAtPiBhc3NpZ24iID4mNjsgfQogICAgICBl
Y2hvICcKICcgPj4gb2N0LWFsdC1pbmNsdWRlcy5oCiBlbHNlCi0tLSBwYXJh
bGxlbC00LjAuMS5vcmlnL3NyYy9lcnJvci1oZWxwZXJzLmgJMjAyMS0wMy0x
NyAwNTowMzowOS4wMDAwMDAwMDAgKzExMDAKKysrIHBhcmFsbGVsLTQuMC4x
L3NyYy9lcnJvci1oZWxwZXJzLmgJMjAyMy0wMy0xOSAwOTozMjoxOC4wMDAw
MDAwMDAgKzExMDAKQEAgLTEsMTAgKzEsMTAgQEAKIC8qCiAKLUNvcHlyaWdo
dCAoQykgMjAxNi0yMDE4IE9sYWYgVGlsbCA8aTd0aW9sQHQtb25saW5lLmRl
PgorQ29weXJpZ2h0IChDKSAyMDE2LTIwMTkgT2xhZiBUaWxsIDxpN3Rpb2xA
dC1vbmxpbmUuZGU+CiAKIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJl
OyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IgbW9kaWZ5CiBpdCB1
bmRlciB0aGUgdGVybXMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNl
bnNlIGFzIHB1Ymxpc2hlZCBieQotdGhlIEZyZWUgU29mdHdhcmUgRm91bmRh
dGlvbjsgZWl0aGVyIHZlcnNpb24gMyBvZiB0aGUgTGljZW5zZSwgb3IKK3Ro
ZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb247IGVpdGhlciB2ZXJzaW9uIDIg
b2YgdGhlIExpY2Vuc2UsIG9yCiAoYXQgeW91ciBvcHRpb24pIGFueSBsYXRl
ciB2ZXJzaW9uLgogCiBUaGlzIHByb2dyYW0gaXMgZGlzdHJpYnV0ZWQgaW4g
dGhlIGhvcGUgdGhhdCBpdCB3aWxsIGJlIHVzZWZ1bCwKQEAgLTQ0LDEzICs0
NCw2IEBACiAgICAgdHJ5IFwKICAgICAgIHsgXAogICAgICAgICBjb2RlIDsg
XAotIFwKLSAgICAgICAgaWYgKGVycm9yX3N0YXRlKSBcCi0gICAgICAgICAg
eyBcCi0gICAgICAgICAgICBlcnJvciAoX19WQV9BUkdTX18pOyBcCi0gXAot
ICAgICAgICAgICAgcmV0dXJuIHJldHZhbDsgXAotICAgICAgICAgIH0gXAog
ICAgICAgfSBcCiAgICAgY2F0Y2ggKE9DVEFWRV9fRVhFQ1VUSU9OX0VYQ0VQ
VElPTiYgZSkgXAogICAgICAgeyBcCkBAIC02NCw3ICs1Nyw5IEBACiAgICAg
ICB9IFwKICAgICBjYXRjaCAoT0NUQVZFX19FWEVDVVRJT05fRVhDRVBUSU9O
JiBlKSBcCiAgICAgICB7IFwKLSAgICAgICAgdmVycm9yIChlLCBfX1ZBX0FS
R1NfXyk7IFwKKyAgICAgICAgX3BfZXJyb3IgKF9fVkFfQVJHU19fKTsgXAor
IFwKKyAgICAgICAgZXhpdCAoMSk7IFwKICAgICAgIH0KICNlbmRpZgogCkBA
IC03NywxMyArNzIsNiBAQAogICAgIHRyeSBcCiAgICAgICB7IFwKICAgICAg
ICAgY29kZSA7IFwKLSBcCi0gICAgICAgIGlmIChlcnJvcl9zdGF0ZSkgXAot
ICAgICAgICAgIHsgXAotICAgICAgICAgICAgX3BfZXJyb3IgKF9fVkFfQVJH
U19fKTsgXAotIFwKLSAgICAgICAgICAgIGV4aXQgKDEpOyBcCi0gICAgICAg
ICAgfSBcCiAgICAgICB9IFwKICAgICBjYXRjaCAoT0NUQVZFX19FWEVDVVRJ
T05fRVhDRVBUSU9OJikgXAogICAgICAgeyBcCkBAIC0xMTYsMTEgKzEwNCw2
IEBACiAgICAgdHJ5IFwKICAgICAgIHsgXAogICAgICAgICBjb2RlIDsgXAot
ICAgICAgICBpZiAoZXJyb3Jfc3RhdGUpIFwKLSAgICAgICAgICB7IFwKLSAg
ICAgICAgICAgIGVycm9yX3N0YXRlID0gMDsgXAotICAgICAgICAgICAgZXJy
ID0gdHJ1ZTsgXAotICAgICAgICAgIH0gXAogICAgICAgfSBcCiAgICAgY2F0
Y2ggKE9DVEFWRV9fRVhFQ1VUSU9OX0VYQ0VQVElPTiYpIFwKICAgICAgIHsg
XAotLS0gcGFyYWxsZWwtNC4wLjEub3JpZy9zcmMvcGNvbm5lY3QuY2MJMjAy
MS0wMy0xNyAwNTowMzowOS4wMDAwMDAwMDAgKzExMDAKKysrIHBhcmFsbGVs
LTQuMC4xL3NyYy9wY29ubmVjdC5jYwkyMDIzLTAzLTE5IDA5OjMyOjE4LjAw
MDAwMDAwMCArMTEwMApAQCAtNDA3LDcgKzQwNyw3IEBACiAgIG5ldHdvcmst
Pmluc2VydF9jb25uZWN0aW9uIChjb25uLCAwKTsKIAogICAvLyBzdG9yZSBu
dW1iZXIgb2YgcHJvY2Vzc29yIGNvcmVzIGF2YWlsYWJsZSBpbiBjbGllbnQK
LSAgY29ubi0+c2V0X25wcm9jIChudW1fcHJvY2Vzc29ycyAoTlBST0NfQ1VS
UkVOVCkpOworICBjb25uLT5zZXRfbnByb2MgKG9jdGF2ZV9udW1fcHJvY2Vz
c29yc193cmFwcGVyIChOUFJPQ19DVVJSRU5UKSk7CiAKICAgZm9yICh1aW50
MzJfdCBpID0gMDsgaSA8IG5ob3N0czsgaSsrKQogICAgIHsKLS0tIHBhcmFs
bGVsLTQuMC4xLm9yaWcvc3JjL19fb2N0YXZlX3NlcnZlcl9fLmNjCTIwMjEt
MDMtMTcgMDU6MDM6MDkuMDAwMDAwMDAwICsxMTAwCisrKyBwYXJhbGxlbC00
LjAuMS9zcmMvX19vY3RhdmVfc2VydmVyX18uY2MJMjAyMy0wMy0xOSAwOToz
MjoxOC4wMDAwMDAwMDAgKzExMDAKQEAgLTMxNyw3ICszMTcsNyBAQAogI2Vu
ZGlmIC8vIEhBVkVfTElCR05VVExTCiAKICAgLy8gZGV0ZXJtaW5lIG93biBu
dW1iZXIgb2YgdXNhYmxlIHByb2Nlc3NvciBjb3JlcwotICB1aW50MzJfdCBu
cHJvYyA9IG51bV9wcm9jZXNzb3JzIChOUFJPQ19DVVJSRU5UKTsKKyAgdWlu
dDMyX3QgbnByb2MgPSBvY3RhdmVfbnVtX3Byb2Nlc3NvcnNfd3JhcHBlciAo
TlBST0NfQ1VSUkVOVCk7CiAKICAgLy8gVGhlIHNlcnZlcnMgY29tbWFuZCBz
dHJlYW0gd2lsbCBub3QgYmUgaW5zZXJ0ZWQgaW50byBhCiAgIC8vIGNvbm5l
Y3Rpb24gb2JqZWN0LgotLS0gcGFyYWxsZWwtNC4wLjEub3JpZy9zcmMvcC1j
b25uZWN0aW9uLmNjCTIwMjEtMDMtMTcgMDU6MDM6MDkuMDAwMDAwMDAwICsx
MTAwCisrKyBwYXJhbGxlbC00LjAuMS9zcmMvcC1jb25uZWN0aW9uLmNjCTIw
MjMtMDMtMTkgMDk6NTQ6MzMuMDAwMDAwMDAwICsxMTAwCkBAIC0xOCw3ICsx
OCw3IEBACiAqLwogCiAjaW5jbHVkZSA8b2N0YXZlL29jdC5oPgotI2luY2x1
ZGUgPG9jdGF2ZS9BcnJheS5jYz4KKyNpbmNsdWRlIDxvY3RhdmUvQXJyYXkt
b2N0LmNjPgogCiAjaW5jbHVkZSAicGFyYWxsZWwtZ251dGxzLmgiCiAKLS0t
IHBhcmFsbGVsLTQuMC4xLm9yaWcvc3JjL3BhcmFsbGVsLWdudXRscy5oCTIw
MjEtMDMtMTcgMDU6MDM6MDkuMDAwMDAwMDAwICsxMTAwCisrKyBwYXJhbGxl
bC00LjAuMS9zcmMvcGFyYWxsZWwtZ251dGxzLmgJMjAyMy0wMy0xOSAwOToz
MjoxOC4wMDAwMDAwMDAgKzExMDAKQEAgLTQ0LDcgKzQ0LDcgQEAKIAogI2lu
Y2x1ZGUgPHN0ZGludC5oPgogCi0vLyBXZSBsaW5rIGFnYWluc3QgdGhlIGdu
dWxpYiBudW1fcHJvY2Vzc29ycygpIHVzZWQgYnkgT2N0YXZlLiBucHJvYy5o
CisvLyBXZSBsaW5rIGFnYWluc3QgdGhlIGdudWxpYiBvY3RhdmVfbnVtX3By
b2Nlc3NvcnNfd3JhcHBlcigpIHVzZWQgYnkgT2N0YXZlLiBucHJvYy5oCiAv
LyB1c2VkIGJ5IE9jdGF2ZSBpcyBub3QgYWNjZXNzaWJsZS4gSWYgdGhlIGlu
dGVyZmFjZSBjaGFuZ2VzLCB0aGlzCiAvLyB3aWxsIHN0b3Agd29ya2luZy4K
IGV4dGVybiAiQyIgewpAQCAtNTgsNyArNTgsNyBAQAogCiAvKiBSZXR1cm4g
dGhlIHRvdGFsIG51bWJlciBvZiBwcm9jZXNzb3JzLiAgVGhlIHJlc3VsdCBp
cyBndWFyYW50ZWVkIHRvCiAgICBiZSBhdCBsZWFzdCAxLiAgKi8KLWV4dGVy
biB1bnNpZ25lZCBsb25nIGludCBudW1fcHJvY2Vzc29ycyAoZW51bSBucHJv
Y19xdWVyeSBxdWVyeSk7CitleHRlcm4gdW5zaWduZWQgbG9uZyBpbnQgb2N0
YXZlX251bV9wcm9jZXNzb3JzX3dyYXBwZXIgKGVudW0gbnByb2NfcXVlcnkg
cXVlcnkpOwogfQogCiAK
====
EOF
uudecode parallel-$PARALLEL_VER".patch.uue"
tar -xf $PARALLEL_ARCHIVE
NEW_PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".new.tar.gz"
pushd parallel-$PARALLEL_VER
patch -p1 < ../parallel-$PARALLEL_VER".patch"
popd
tar -czf $NEW_PARALLEL_ARCHIVE parallel-$PARALLEL_VER
rm -Rf parallel-$PARALLEL_VER parallel-$PARALLEL_VER".patch.uue" parallel-$PARALLEL_VER".patch"

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_PARALLEL_ARCHIVE
rm -f $NEW_PARALLEL_ARCHIVE


#
# Fix signal package and install the new signal package
#
cat > signal-$SIGNAL_VER.patch.uue << 'EOF'
begin-base64 644 signal-1.4.4.patch
LS0tIHNpZ25hbC0xLjQuNC9pbnN0L3pwbGFuZS5tCTIwMjMtMDUtMTggMDM6
MjA6MDkuMDAwMDAwMDAwICsxMDAwCisrKyBzaWduYWwtMS40LjQubmV3L2lu
c3QvenBsYW5lLm0JMjAyMy0wNi0wOSAxNDoxMzowOC45MDEwMDI3NDggKzEw
MDAKQEAgLTExNSw4ICsxMTUsOSBAQAogICAgICAgZm9yIGkgPSAxOmxlbmd0
aCAoeF91KQogICAgICAgICBuID0gc3VtICh4X3UoaSkgPT0geCg6LGMpKTsK
ICAgICAgICAgaWYgKG4gPiAxKQotICAgICAgICAgIGxhYmVsID0gc3ByaW50
ZiAoIiBeJWQiLCBuKTsKLSAgICAgICAgICB0ZXh0IChyZWFsICh4X3UoaSkp
LCBpbWFnICh4X3UoaSkpLCBsYWJlbCwgImNvbG9yIiwgY29sb3IpOworICAg
ICAgICAgIGxhYmVsID0gc3ByaW50ZiAoIiVkIiwgbik7CisgICAgICAgICAg
dGV4dCAocmVhbCAoeF91KGkpKSwgaW1hZyAoeF91KGkpKSwgbGFiZWwsICJj
b2xvciIsIGNvbG9yLCAuLi4KKyAgICAgICAgICAgICAgICAidmVydGljYWxh
bGlnbm1lbnQiLCAiYm90dG9tIiwgImhvcml6b250YWxhbGlnbm1lbnQiLCAi
bGVmdCIpOwogICAgICAgICBlbmRpZgogICAgICAgZW5kZm9yCiAgICAgZW5k
Zm9yCg==
====
EOF
uudecode signal-$SIGNAL_VER.patch.uue
tar -xf $SIGNAL_ARCHIVE
pushd signal-$SIGNAL_VER
patch -p1 < ../signal-$SIGNAL_VER.patch
popd
NEW_SIGNAL_ARCHIVE=signal-$SIGNAL_VER".new.tar.gz"
tar -czf $NEW_SIGNAL_ARCHIVE signal-$SIGNAL_VER
rm -Rf signal-$SIGNAL_VER signal-$SIGNAL_VER.patch.uue signal-$SIGNAL_VER.patch

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_SIGNAL_ARCHIVE
rm -f $NEW_SIGNAL_ARCHIVE

#
# Add collect.m to the symbolic package and install the new symbolic package
#
cat > collect.m.uue << 'EOF'
begin-base64 644 collect.m
JSUgQ29weXJpZ2h0IChDKSAyMDE0LCAyMDE2LTIwMTkgQ29saW4gQi4gTWFj
ZG9uYWxkCiUlCiUlIFRoZSBzeW1ib2xpYy0yLjkuMCBwYWNrYWdlIGRvZXMg
bm90IHN1cHBvcnQgdGhlIFN5bVB5IGNvbGxlY3QgZnVuY3Rpb24uCiUlIFRo
aXMgY29kZSBpcyBjb3BpZWQgZnJvbSBvY3RhdmUvcGFja2FnZXMvc3ltYm9s
aWMtMi45LjAvQHN5bS9mYWN0b3IubQoKJSUKJSUgT2N0U3ltUHkgaXMgZnJl
ZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1v
ZGlmeQolJSBpdCB1bmRlciB0aGUgdGVybXMgb2YgdGhlIEdOVSBHZW5lcmFs
IFB1YmxpYyBMaWNlbnNlIGFzIHB1Ymxpc2hlZAolJSBieSB0aGUgRnJlZSBT
b2Z0d2FyZSBGb3VuZGF0aW9uOyBlaXRoZXIgdmVyc2lvbiAzIG9mIHRoZSBM
aWNlbnNlLAolJSBvciAoYXQgeW91ciBvcHRpb24pIGFueSBsYXRlciB2ZXJz
aW9uLgolJQolJSBUaGlzIHNvZnR3YXJlIGlzIGRpc3RyaWJ1dGVkIGluIHRo
ZSBob3BlIHRoYXQgaXQgd2lsbCBiZSB1c2VmdWwsCiUlIGJ1dCBXSVRIT1VU
IEFOWSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJh
bnR5CiUlIG9mIE1FUkNIQU5UQUJJTElUWSBvciBGSVRORVNTIEZPUiBBIFBB
UlRJQ1VMQVIgUFVSUE9TRS4gIFNlZQolJSB0aGUgR05VIEdlbmVyYWwgUHVi
bGljIExpY2Vuc2UgZm9yIG1vcmUgZGV0YWlscy4KJSUKJSUgWW91IHNob3Vs
ZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVi
bGljCiUlIExpY2Vuc2UgYWxvbmcgd2l0aCB0aGlzIHNvZnR3YXJlOyBzZWUg
dGhlIGZpbGUgQ09QWUlORy4KJSUgSWYgbm90LCBzZWUgPGh0dHA6Ly93d3cu
Z251Lm9yZy9saWNlbnNlcy8+LgoKJSUgLSotIHRleGluZm8gLSotCiUlIEBk
b2N1bWVudGVuY29kaW5nIFVURi04CiUlIEBkZWZ0eXBlbWV0aG9kICBAQHN5
bSB7QHZhcntlfSA9fSBjb2xsZWN0IChAdmFye2Z9LCBAdmFye3h9KQolJSBD
b2xsZWN0IGNvbW1vbiBwb3dlcnMgb2YgYSB0ZXJtIGluIGFuIGV4cHJlc3Np
b24uCiUlCiUlIEFuIGV4YW1wbGUgb2YgY29sbGVjdGluZyB0ZXJtcyBpbiBh
IHBvbHlub21pYWw6CiUlIEBleGFtcGxlCiUlIEBncm91cAolJSBzeW1zIHgg
eSB6CiUlIGUgPSBjb2xsZWN0KFt4KnkgKyB4IC0gMyArIDIqeF4yIC0geip4
XjMgKyB4XjNdLCB4KQolJSAgIEByZXN1bHR7fSAoc3ltKSB4XjPii4UoMSAt
IHopICsgMuKLhXheMiAgKyB44ouFKHkgKyAxKSAtIDMKJSUgQGVuZCBncm91
cAolJSBAZW5kIGV4YW1wbGUKJSUKJSUgQHNlZWFsc297QEBzeW0vZXhwYW5k
fQolJSBAZW5kIGRlZnR5cGVtZXRob2QKCgpmdW5jdGlvbiBlID0gY29sbGVj
dChmLCB2YXJhcmdpbikKICAKICBpZiAobmFyZ291dCA+IDEpCiAgICBwcmlu
dF91c2FnZSAoKTsKICBlbmRpZgoKICBmID0gc3ltKGYpOwogIGZvciBpID0g
MTpsZW5ndGgodmFyYXJnaW4pCiAgICB2YXJhcmdpbntpfSA9IHN5bSh2YXJh
cmdpbntpfSk7CiAgZW5kZm9yCiAgCiAgZSA9IHB5Y2FsbF9zeW1weV9fICgn
cmV0dXJuIGNvbGxlY3QoKl9pbnMpJywgZiwgdmFyYXJnaW57On0pOwoKZW5k
ZnVuY3Rpb24KCiUhdGVzdCBzeW1zIHggeSB6CiUhIGYgPSBbeCp5ICsgeCAt
IDMgKyAyKnheMiAtIHoqeF4zICsgeF4zXQolISBhc3NlcnQoIGxvZ2ljYWwg
KGNvbGxlY3QoZix4KSA9PSAoKHheMykqKDEgLSB6KSArIDIqKHheMikgICsg
eCooeSArIDEpIC0gMykpKQoK
====
EOF
uudecode collect.m.uue > collect.m
tar -xf $SYMBOLIC_ARCHIVE
mv -f collect.m symbolic-$SYMBOLIC_VER/inst/@sym
NEW_SYMBOLIC_ARCHIVE=symbolic-$SYMBOLIC_VER".new.tar.gz"
tar -czf $NEW_SYMBOLIC_ARCHIVE symbolic-$SYMBOLIC_VER
rm -Rf symbolic-$SYMBOLIC_VER collect.m.uue

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_SYMBOLIC_ARCHIVE
rm -f $NEW_SYMBOLIC_ARCHIVE

#
# Installing Octave-Forge packages is done
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg list"

#
# Install solver packages from the GitHub forked repositories
#

GITHUB_URL="https://github.com/robertgj"

OCTAVE_LOCAL_VERSION=\
"`$OCTAVE_BIN_DIR/octave-cli --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m

# Install SeDuMi
SEDUMI_VER=1.3.7
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
mv -f sedumi-$SEDUMI_VER $OCTAVE_SITE_M_DIR/SeDuMi
if test $? -ne 0;then rm -Rf sedumi-$SEDUMI_VER; exit -1; fi
$OCTAVE_BIN_DIR/octave --no-gui $OCTAVE_SITE_M_DIR/SeDuMi/install_sedumi.m

# Install SDPT3
if ! test -f sdpt3-master.zip ; then
  wget -c $GITHUB_URL/sdpt3/archive/refs/heads/master.zip
  mv master.zip sdpt3-master.zip
fi
rm -Rf sdpt3-master $OCTAVE_SITE_M_DIR/SDPT3
unzip sdpt3-master.zip 
rm -f sdpt3-master/Solver/Mexfun/*.mex*
rm -Rf sdpt3-master/Solver/Mexfun/o_win
mv sdpt3-master $OCTAVE_SITE_M_DIR/SDPT3
if test $? -ne 0;then rm -Rf sdpt3-master; exit -1; fi
$OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SDPT3/install_sdpt3.m

# Install YALMIP
if ! test -f YALMIP-develop.zip ; then
  wget -c $GITHUB_URL/YALMIP/archive/refs/heads/develop.zip
  mv develop.zip YALMIP-develop.zip
fi
rm -Rf YALMIP-develop $OCTAVE_SITE_M_DIR/YALMIP
unzip YALMIP-develop.zip 
mv YALMIP-develop $OCTAVE_SITE_M_DIR/YALMIP
if test $? -ne 0;then rm -Rf YALMIP-develop; exit -1; fi

# Install SparsePOP
if ! test -f SparsePOP-master.zip ; then
  wget -c $GITHUB_URL/SparsePOP/archive/refs/heads/master.zip
  mv master.zip SparsePOP-master.zip
fi
rm -Rf SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
unzip SparsePOP-master.zip
find SparsePOP-master -name \*.mex* -exec rm -f {} ';'
mv SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
if test $? -ne 0;then rm -Rf SparsePOP-master; exit -1; fi
# !! Do not build the SparsePOP .mex files !!
# $OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SparsePOP/compileSparsePOP.m

# Install gloptipoly
GLOPTIPOLY3_URL=http://homepages.laas.fr/henrion/software/gloptipoly3
if ! test -f gloptipoly3.zip ; then
  wget -c $GLOPTIPOLY3_URL/gloptipoly3.zip
fi
GLOPTIPOLY3_VER=3.10-octave-20220924
cat > gloptipoly3-$GLOPTIPOLY3_VER.patch.uue << 'EOF'
begin-base64 644 gloptipoly3-3.10-octave-20220924.patch
LS0tIGdsb3B0aXBvbHkzL0BtZWFzL2Rpc3BsYXkubQkyMDEwLTAzLTI2IDEx
OjU1OjAwLjAwMDAwMDAwMCArMTEwMAorKysgZ2xvcHRpcG9seTMtMy4xMC1v
Y3RhdmUtMjAyMjA5MjQvQG1lYXMvZGlzcGxheS5tCTIwMjItMDktMjQgMjA6
NTk6MzYuNTM5ODEyNTEwICsxMDAwCkBAIC03LDExICs3LDIwIEBACiBnbG9i
YWwgTU1NDQogDQogJSBTcGFjaW5nDQoraWYgZXhpc3QoJ09DVEFWRV9WRVJT
SU9OJykKKyAgW34sZnNdPWZvcm1hdDsKKyAgaWYgaXNlcXVhbChmcywnY29t
cGFjdCcpCisgICAgY3IgPSAnJzsKKyAgZWxzZQorICAgIGNyID0gJ1xuJzsK
KyAgZW5kCitlbHNlICAgIAogaWYgaXNlcXVhbChnZXQoMCwnRm9ybWF0U3Bh
Y2luZycpLCdjb21wYWN0JykNCiAgY3IgPSAnJzsNCiBlbHNlDQogIGNyID0g
J1xuJzsNCiBlbmQNCitlbmQKIA0KICUgRGlzcGxheSB2YXJpYWJsZSBuYW1l
DQogJSB4bmFtZSA9IGlucHV0bmFtZSgxKTsNCi0tLSBnbG9wdGlwb2x5My9A
bWVhcy9tZXh0Lm0JMjAxNS0xMC0xOSAxMTowMDoxMC4wMDAwMDAwMDAgKzEx
MDAKKysrIGdsb3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIwOTI0L0BtZWFz
L21leHQubQkyMDIyLTA5LTI0IDIwOjU5OjM2LjUzOTgxMjUxMCArMTAwMApA
QCAtNzAsNyArNzAsNyBAQAogCiBOID0gY2VsbCgxLG52YXIpOwogaSA9IDA7
IGZhaWwgPSAwOwotd2hpbGUgfmZhaWwgJiAoaSA8IG52YXIpCit3aGlsZSB+
ZmFpbCAmJiAoaSA8IG52YXIpCiAgaSA9IGkgKyAxOwogICUgYnVpbGQgbXVs
dGlwbGljYXRpb24gbWF0cml4CiAgJSBmb3IgbW9ub21pYWwgQyhJKSBpbiBi
YXNpcyBCKDEpLi5CKE5CKQpAQCAtMTc4LDcgKzE3OCw3IEBACiAKICUgTG9v
cCBvdmVyIHRoZSBlbnRpcmUgbWF0cml4LgogaSA9IDE7IGogPSAxOyBiYXNp
cyA9IFtdOwotd2hpbGUgKGkgPD0gbSkgJiAoaiA8PSBuKQord2hpbGUgKGkg
PD0gbSkgJiYgKGogPD0gbikKICAlIEZpbmQgdmFsdWUgYW5kIGluZGV4IG9m
IGxhcmdlc3QgZWxlbWVudCBpbiB0aGUgcmVtYWluZGVyIG9mIHJvdyBqCiAg
W3Asa10gPSBtYXgoYWJzKEEoaixpOm0pKSk7IGsgPSBrK2ktMTsKICBpZiAo
cCA8PSB0b2wpCi0tLSBnbG9wdGlwb2x5My9AbWVhcy9tbWF0Lm0JMjAwOC0w
OS0xMSAwOTo1Mjo1MC4wMDAwMDAwMDAgKzEwMDAKKysrIGdsb3B0aXBvbHkz
LTMuMTAtb2N0YXZlLTIwMjIwOTI0L0BtZWFzL21tYXQubQkyMDIyLTA5LTI0
IDIwOjU5OjM2LjU1MjgxMjQwMiArMTAwMApAQCAtMjYsNyArMjYsNyBAQAog
ICUgc3Vic2V0IG9mIHZhcmlhYmxlcw0KICBtYXJnaW5hbCA9IHRydWU7DQog
IGltID0gaW5kbWVhcyh4KTsNCi0gaWYgKGxlbmd0aChpbSkgPiAxKSB8IChp
bSB+PSBtKQ0KKyBpZiAobGVuZ3RoKGltKSA+IDEpIHx8IChpbSB+PSBtKQ0K
ICAgZXJyb3IoJ0luY29uc2lzdGVudCBtZWFzdXJlIGluIHNlY29uZCBpbnB1
dCBhcmd1bWVudCcpDQogIGVuZA0KICBpdiA9IGluZHZhcih4KTsNCkBAIC02
MCw3ICs2MCw3IEBACiAlIEFyZSB0aGUgcG93ZXJzIGFscmVhZHkgc3RvcmVk
IGluIHRoZSBNTU0uVCB0YWJsZXMgPw0KIGdlbmVyYXRlID0gdHJ1ZTsNCiBp
ZiBpc2ZpZWxkKE1NTSwnVCcpDQotIGlmIChzaXplKE1NTS5ULDEpID49IG52
YXIpICYgKHNpemUoTU1NLlQsMikgPj0gb3JkKQ0KKyBpZiAoc2l6ZShNTU0u
VCwxKSA+PSBudmFyKSAmJiAoc2l6ZShNTU0uVCwyKSA+PSBvcmQpDQogICBp
ZiB+aXNlbXB0eShNTU0uVChudmFyLG9yZCkpDQogICAgdnBvdyA9IE1NTS5U
KG52YXIsb3JkKS5wb3c7DQogICAgbXBvdyA9IE1NTS5UKG52YXIsb3JkKS5i
YXM7DQotLS0gZ2xvcHRpcG9seTMvQG1lYXMvbXZlYy5tCTIwMTAtMDMtMjYg
MTQ6MzI6NTQuMDAwMDAwMDAwICsxMTAwCisrKyBnbG9wdGlwb2x5My0zLjEw
LW9jdGF2ZS0yMDIyMDkyNC9AbWVhcy9tdmVjLm0JMjAyMi0wOS0yNCAyMDo1
OTozNi41NTI4MTI0MDIgKzEwMDAKQEAgLTI2LDcgKzI2LDcgQEAKICAlIHN1
YnNldCBvZiB2YXJpYWJsZXMNCiAgbWFyZ2luYWwgPSB0cnVlOw0KICBpbSA9
IGluZG1lYXMoeCk7DQotIGlmIChsZW5ndGgoaW0pID4gMSkgfCAoaW0gfj0g
bSkNCisgaWYgKGxlbmd0aChpbSkgPiAxKSB8fCAoaW0gfj0gbSkNCiAgIGVy
cm9yKCdJbmNvbnNpc3RlbnQgbWVhc3VyZSBpbiBzZWNvbmQgaW5wdXQgYXJn
dW1lbnQnKQ0KICBlbmQNCiAgaXYgPSBpbmR2YXIoeCk7DQpAQCAtNjAsNyAr
NjAsNyBAQAogJSBBcmUgdGhlIHBvd2VycyBhbHJlYWR5IHN0b3JlZCBpbiB0
aGUgTU1NLlQgdGFibGVzID8NCiBnZW5lcmF0ZSA9IHRydWU7DQogaWYgaXNm
aWVsZChNTU0sJ1QnKQ0KLSBpZiAoc2l6ZShNTU0uVCwxKSA+PSBudmFyKSAm
IChzaXplKE1NTS5ULDIpID49IG9yZCkNCisgaWYgKHNpemUoTU1NLlQsMSkg
Pj0gbnZhcikgJiYgKHNpemUoTU1NLlQsMikgPj0gb3JkKQ0KICAgaWYgfmlz
ZW1wdHkoTU1NLlQobnZhcixvcmQpLnBvdykNCiAgICB2cG93ID0gTU1NLlQo
bnZhcixvcmQpLnBvdzsNCiAgICBnZW5lcmF0ZSA9IGZhbHNlOw0KLS0tIGds
b3B0aXBvbHkzL0Btb20vY29uc2lzdGVudC5tCTIwMDgtMDktMTEgMDk6NTI6
NTAuMDAwMDAwMDAwICsxMDAwCisrKyBnbG9wdGlwb2x5My0zLjEwLW9jdGF2
ZS0yMDIyMDkyNC9AbW9tL2NvbnNpc3RlbnQubQkyMDIyLTA5LTI0IDIwOjU5
OjM2LjU1MjgxMjQwMiArMTAwMApAQCAtMTUsNyArMTUsNyBAQAogZm9yIGsg
PSAxOmxlbmd0aChwKQogICUgRWFjaCBwb2x5bm9taWFsIHNob3VsZCBjb3Jy
ZXNwb25kIHRvIG9uZSBtZWFzdXJlIG9ubHkKICBtcCA9IGluZG1lYXMocChr
KSk7Ci0gaWYgKGxlbmd0aChtcCkgPiAxKSB8ICgobXAgfj0gMCkgJiAobXAg
fj0gbShrKSkpCisgaWYgKGxlbmd0aChtcCkgPiAxKSB8fCAoKG1wIH49IDAp
ICYmIChtcCB+PSBtKGspKSkKICAgZihrKSA9IGZhbHNlOwogIGVuZAogZW5k
Ci0tLSBnbG9wdGlwb2x5My9AbW9tL2Rpc3BsYXkubQkyMDA4LTA5LTExIDA5
OjUyOjUwLjAwMDAwMDAwMCArMTAwMAorKysgZ2xvcHRpcG9seTMtMy4xMC1v
Y3RhdmUtMjAyMjA5MjQvQG1vbS9kaXNwbGF5Lm0JMjAyMi0wOS0yNCAyMDo1
OTozNi41NTI4MTI0MDIgKzEwMDAKQEAgLTEwLDExICsxMCwyMCBAQAogJSBk
aXNwKCdAbW9tL2Rpc3BsYXknKTsga2V5Ym9hcmQNCiANCiAlIFNwYWNpbmcN
CitpZiBleGlzdCgnT0NUQVZFX1ZFUlNJT04nKQ0KKyAgW34sZnNdPWZvcm1h
dDsNCisgIGlmIGlzZXF1YWwoZnMsJ2NvbXBhY3QnKQ0KKyAgICBjciA9ICcn
Ow0KKyAgZWxzZQ0KKyAgICBjciA9ICdcbic7DQorICBlbmQNCitlbHNlICAg
IA0KIGlmIGlzZXF1YWwoZ2V0KDAsJ0Zvcm1hdFNwYWNpbmcnKSwnY29tcGFj
dCcpDQogIGNyID0gJyc7DQogZWxzZQ0KICBjciA9ICdcbic7DQogZW5kDQor
ZW5kDQogDQogJSBUaHJlc2hvbGQgZm9yIGRpc3BsYXlpbmcgemVyb3Mgb3Ig
b25lcw0KIHRvbCA9IDFlLTg7DQpAQCAtMzIsNyArNDEsNyBAQAogDQogZWxz
ZQ0KIA0KLSBpZiAobnJvd3MgPT0gMSkgJiAobmNvbHMgPT0gMSkNCisgaWYg
KG5yb3dzID09IDEpICYmIChuY29scyA9PSAxKQ0KICAgaWQgPSAnU2NhbGFy
IG1vbWVudCc7DQogIGVsc2VpZiBtaW4obnJvd3MsbmNvbHMpID09IDENCiAg
IGlkID0gW2ludDJzdHIobnJvd3MpICctYnktJyBpbnQyc3RyKG5jb2xzKSAu
Li4NCkBAIC03Nyw3ICs4Niw3IEBACiAgIGVuZA0KICAgDQogICBpZiB+c2ls
ZW50DQotICAgaWYgKG5yb3dzID4gMSkgfCAobmNvbHMgPiAxKQ0KKyAgIGlm
IChucm93cyA+IDEpIHx8IChuY29scyA+IDEpDQogICAgIGRpc3AoWycoJyBp
bnQyc3RyKHIpICcsJyBpbnQyc3RyKGMpICcpOicgc3Rye3IsY31dKTsNCiAg
ICBlbHNlDQogICAgIGRpc3Aoc3Rye3IsY30pOyANCi0tLSBnbG9wdGlwb2x5
My9AbW9tL21vbS5tCTIwMTgtMDktMTEgMTE6MTg6NDAuMDAwMDAwMDAwICsx
MDAwCisrKyBnbG9wdGlwb2x5My0zLjEwLW9jdGF2ZS0yMDIyMDkyNC9AbW9t
L21vbS5tCTIwMjItMDktMjQgMjA6NTk6MzYuNTUzODEyMzkzICsxMDAwCkBA
IC0yMCw3ICsyMCw3IEBACiAgaWYgbmFyZ2luIDwgMg0KICAgbWVhc3ggPSBp
bmRtZWFzKHgpOw0KICBlbmQNCi0gaWYgKG1lYXN4PT0wKSAmIChuYXJnaW4g
PCAyKQ0KKyBpZiAobWVhc3g9PTApICYmIChuYXJnaW4gPCAyKQ0KICAgeSA9
IG1vbSh4LG1lYXN4KTsgJSBjb25zdGFudA0KICBlbmQNCiAgaWYgbGVuZ3Ro
KG1lYXN4KSA+IDENCi0tLSBnbG9wdGlwb2x5My9AbW9tY29uL2Rpc3BsYXku
bQkyMDA4LTA5LTExIDEzOjU4OjE0LjAwMDAwMDAwMCArMTAwMAorKysgZ2xv
cHRpcG9seTMtMy4xMC1vY3RhdmUtMjAyMjA5MjQvQG1vbWNvbi9kaXNwbGF5
Lm0JMjAyMi0wOS0yNCAyMDo1OTozNi41NTM4MTIzOTMgKzEwMDAKQEAgLTE0
LDcgKzE0LDcgQEAKIA0KIFtucm93cyxuY29sc10gPSBzaXplKHgpOw0KIA0K
LWlmIChtaW4obnJvd3MsbmNvbHMpIDwgMSkgfCBpc2VtcHR5KHR5cGUoeCkp
DQoraWYgKG1pbihucm93cyxuY29scykgPCAxKSB8fCBpc2VtcHR5KHR5cGUo
eCkpDQogIA0KICBpZCA9ICdFbXB0eSBtb21lbnQgY29uc3RyYWludCc7CiAg
c3RyID0gW107DQpAQCAtMjQsNyArMjQsNyBAQAogCiBlbHNlDQogIA0KLSBp
ZiAobnJvd3MgPT0gMSkgJiAobmNvbHMgPT0gMSkNCisgaWYgKG5yb3dzID09
IDEpICYmIChuY29scyA9PSAxKQ0KICAgaWQgPSAnU2NhbGFyJzsNCiAgZWxz
ZQ0KICAgaWQgPSBbaW50MnN0cihucm93cykgJy1ieS0nIGludDJzdHIobmNv
bHMpIC4uLg0KQEAgLTc4LDcgKzc4LDcgQEAKICAgZW5kCiANCiAgIGlmIH5z
aWxlbnQNCi0gICBpZiAobnJvd3MgPiAxKSB8IChuY29scyA+IDEpDQorICAg
aWYgKG5yb3dzID4gMSkgfHwgKG5jb2xzID4gMSkNCiAgICAgZGlzcChbJygn
IGludDJzdHIocikgJywnIGludDJzdHIoYykgJyk6JyBzdHJ7cixjfV0pOw0K
ICAgIGVsc2UNCiAgICAgZGlzcChzdHJ7cixjfSk7IA0KLS0tIGdsb3B0aXBv
bHkzL0Btb21jb24vbW9tY29uLm0JMjAxMS0wMy0yNSAxMTo0MTo1Ni4wMDAw
MDAwMDAgKzExMDAKKysrIGdsb3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIw
OTI0L0Btb21jb24vbW9tY29uLm0JMjAyMi0wOS0yNCAyMDo1OTozNi41NTM4
MTIzOTMgKzEwMDAKQEAgLTMxLDcgKzMxLDcgQEAKIAogZWxzZWlmIG5hcmdp
biA9PSAyICUgbW9tZW50IG9iamVjdGl2ZSBmdW5jdGlvbgogCi0gaWYgfnN0
cmNtcCh5LCdtaW4nKSAmIH5zdHJjbXAoeSwnbWF4JykKKyBpZiB+c3RyY21w
KHksJ21pbicpICYmIH5zdHJjbXAoeSwnbWF4JykKICAgZXJyb3IoJ0ludmFs
aWQgc2Vjb25kIGlucHV0IGFyZ3VtZW50Jyk7CiAgZWxzZQogICBpZiBpc2Vt
cHR5KHgpCi0tLSBnbG9wdGlwb2x5My9AbW9tY29uL3JpZ2h0Lm0JMjAwOC0w
OS0xMSAwOTo1Mjo1Mi4wMDAwMDAwMDAgKzEwMDAKKysrIGdsb3B0aXBvbHkz
LTMuMTAtb2N0YXZlLTIwMjIwOTI0L0Btb21jb24vcmlnaHQubQkyMDIyLTA5
LTI0IDIwOjU5OjM2LjU1MzgxMjM5MyArMTAwMApAQCAtOCw3ICs4LDcgQEAK
IHkgPSBtb20oemVyb3MobnIsbmMpLDApOwogZm9yIHIgPSAxOm5yCiAgZm9y
IGMgPSAxOm5jCi0gIGlmIHN0cmNtcCh4KHIsYykudHlwZSwnbWluJykgfCBz
dHJjbXAoeChyLGMpLnR5cGUsJ21heCcpCisgIGlmIHN0cmNtcCh4KHIsYyku
dHlwZSwnbWluJykgfHwgc3RyY21wKHgocixjKS50eXBlLCdtYXgnKQogICAg
eShyLGMpID0geChyLGMpLmxlZnQ7CiAgIGVsc2UKICAgIHkocixjKSA9IHgo
cixjKS5yaWdodDsKLS0tIGdsb3B0aXBvbHkzL0BtcG9sL2Fzc2lnbi5tCTIw
MDgtMDktMTEgMDk6NTI6NTIuMDAwMDAwMDAwICsxMDAwCisrKyBnbG9wdGlw
b2x5My0zLjEwLW9jdGF2ZS0yMDIyMDkyNC9AbXBvbC9hc3NpZ24ubQkyMDIy
LTA5LTI0IDIwOjU5OjM2LjU1NDgxMjM4NSArMTAwMApAQCAtMzcsOCArMzcs
OCBAQAogIHYgPSByZXNoYXBlKHYsMSwxLHByb2Qoc2l6ZSh2KSkpOwogZW5k
CiBucnYgPSBzaXplKHYsMSk7IG5jdiA9IHNpemUodiwyKTsKLWlmIChucnYg
fj0gbnIpIHwgKG5jdiB+PSBuYykKLSBpZiAoc2l6ZSh2LDMpID09IDEpICYg
KG1pbihucixuYykgPT0gMSkKK2lmIChucnYgfj0gbnIpIHx8IChuY3Ygfj0g
bmMpCisgaWYgKHNpemUodiwzKSA9PSAxKSAmJiAobWluKG5yLG5jKSA9PSAx
KQogICBpZiBuYyA9PSAxICUgY29sdW1uIHZlY3RvciB4CiAgICBpZiBuciA9
PSBucnYgJSAyRCB0byAzRCB2CiAgICAgdiA9IHJlc2hhcGUodixucnYsMSxu
Y3YpOwpAQCAtNTUsNyArNTUsNyBAQAogIGVuZAogZW5kCiBucnYgPSBzaXpl
KHYsMSk7IG5jdiA9IHNpemUodiwyKTsKLWlmIChzaXplKHYsMSkgfj0gbnIp
IHwgKHNpemUodiwyKSB+PSBuYykKK2lmIChzaXplKHYsMSkgfj0gbnIpIHx8
IChzaXplKHYsMikgfj0gbmMpCiAgZXJyb3IoJ0luY29uc2lzdGVudCBkaW1l
bnNpb25zJykKIGVuZAogCkBAIC04MCw3ICs4MCw3IEBACiBmb3IgciA9IDE6
bnIKICBmb3IgYyA9IDE6bmMKICAgeGMgPSBjb2VmKHgocixjKSk7Ci0gIGlm
IChzaXplKHhjLDEpID4gMSkgfCAoeGMoMSkgfj0gMSkKKyAgaWYgKHNpemUo
eGMsMSkgPiAxKSB8fCAoeGMoMSkgfj0gMSkKICAgIGVycm9yKCdJbnZhbGlk
IHBvbHlub21pYWwgd2l0aCBzZXZlcmFsIG1vbm9taWFscycpCiAgIGVuZAog
ICB4ZCA9IHBvdyh4KHIsYykpOwotLS0gZ2xvcHRpcG9seTMvQG1wb2wvY29l
Zi5tCTIwMDgtMDktMTEgMDk6NTI6NTIuMDAwMDAwMDAwICsxMDAwCisrKyBn
bG9wdGlwb2x5My0zLjEwLW9jdGF2ZS0yMDIyMDkyNC9AbXBvbC9jb2VmLm0J
MjAyMi0wOS0yNCAyMDo1OTozNi41NTQ4MTIzODUgKzEwMDAKQEAgLTIwLDcg
KzIwLDcgQEAKIGlmIGlzZmllbGQoTU1NLCdNJykNCiAgIGlmIG0gPiAwDQog
ICAgaWYgbGVuZ3RoKE1NTS5NKSA+PSBtCi0gICAgaWYgfmlzZW1wdHkoTU1N
Lk17bX0pICYgaXNmaWVsZChNTU0uTXttfSwnaW5kdmFyJykgJiBpc2ZpZWxk
KE1NTS5Ne219LCdzY2FsZScpDQorICAgIGlmIH5pc2VtcHR5KE1NTS5Ne219
KSAmJiBpc2ZpZWxkKE1NTS5Ne219LCdpbmR2YXInKSAmJiBpc2ZpZWxkKE1N
TS5Ne219LCdzY2FsZScpDQogICAgICAgaWYgYW55KE1NTS5Ne219LnNjYWxl
IH49IDEpDQogICAgICAgIHNjYWxlID0gdHJ1ZTsNCiAgICAgIGVuZA0KLS0t
IGdsb3B0aXBvbHkzL0BtcG9sL2RpZmYubQkyMDA4LTA5LTExIDA5OjUyOjUy
LjAwMDAwMDAwMCArMTAwMAorKysgZ2xvcHRpcG9seTMtMy4xMC1vY3RhdmUt
MjAyMjA5MjQvQG1wb2wvZGlmZi5tCTIwMjItMDktMjQgMjA6NTk6MzYuNTU0
ODEyMzg1ICsxMDAwCkBAIC0yOCw3ICsyOCw3IEBACiAKIGVsc2UKICAgCi0g
aWYgKG1pbihucixuYykgPiAxKSAmIChsZW5ndGgodikgPiAxKQorIGlmICht
aW4obnIsbmMpID4gMSkgJiYgKGxlbmd0aCh2KSA+IDEpCiAgIGVycm9yKCdD
YW5ub3QgZ2VuZXJhdGUgSmFjb2JpYW4gb2YgYSBtYXRyaXggcG9seW5vbWlh
bCcpCiAgZW5kCiAKLS0tIGdsb3B0aXBvbHkzL0BtcG9sL2Rpc3BsYXkubQky
MDA4LTA5LTExIDA5OjUyOjUyLjAwMDAwMDAwMCArMTAwMAorKysgZ2xvcHRp
cG9seTMtMy4xMC1vY3RhdmUtMjAyMjA5MjQvQG1wb2wvZGlzcGxheS5tCTIw
MjItMDktMjQgMjA6NTk6MzYuNTU0ODEyMzg1ICsxMDAwCkBAIC0xMiwxMSAr
MTIsMjAgQEAKICVkaXNwKCdkaXNwbGF5JyksIGtleWJvYXJkDQogDQogJSBT
cGFjaW5nDQoraWYgZXhpc3QoJ09DVEFWRV9WRVJTSU9OJykKKyAgW34sZnNd
PWZvcm1hdDsKKyAgaWYgaXNlcXVhbChmcywnY29tcGFjdCcpCisgICAgY3Ig
PSAnJzsKKyAgZWxzZQorICAgIGNyID0gJ1xuJzsKKyAgZW5kCitlbHNlICAg
IAogaWYgaXNlcXVhbChnZXQoMCwnRm9ybWF0U3BhY2luZycpLCdjb21wYWN0
JykNCiAgY3IgPSAnJzsNCiBlbHNlDQogIGNyID0gJ1xuJzsNCiBlbmQNCitl
bmQKIA0KICUgVGhyZXNob2xkIGZvciBkaXNwbGF5aW5nIHplcm9zIG9yIG9u
ZXMNCiB0b2wgPSAxZS04Ow0KQEAgLTM0LDcgKzQzLDcgQEAKIA0KIGVsc2UN
CiANCi0gaWYgKG5yb3dzID09IDEpICYgKG5jb2xzID09IDEpDQorIGlmIChu
cm93cyA9PSAxKSAmJiAobmNvbHMgPT0gMSkNCiAgIGlkID0gJ1NjYWxhciBw
b2x5bm9taWFsJzsNCiAgZWxzZWlmIG1pbihucm93cyxuY29scykgPT0gMQ0K
ICAgaWQgPSBbaW50MnN0cihucm93cykgJy1ieS0nIGludDJzdHIobmNvbHMp
IC4uLg0KQEAgLTY2LDcgKzc1LDcgQEAKICAgICUgTm9uLXplcm8gY29lZg0K
ICAgIGlmIGFicyh4KHIsYykuY29lZihtKSkgPiB0b2wNCiAgICAgJSBTaWdu
ICAgDQotICAgIGlmIH5ub3Rlcm0gJiAoeChyLGMpLmNvZWYobSkgPiAwKQ0K
KyAgICBpZiB+bm90ZXJtICYmICh4KHIsYykuY29lZihtKSA+IDApDQogICAg
ICBzdHJ7cixjfSA9IFtzdHJ7cixjfSAnKyddOw0KICAgICBlbHNlaWYgKHgo
cixjKS5jb2VmKG0pIDwgMCkNCiAgICAgIHN0cntyLGN9ID0gW3N0cntyLGN9
ICctJ107DQpAQCAtOTgsNyArMTA3LDcgQEAKICAgZW5kDQogDQogICBpZiB+
c2lsZW50DQotICAgaWYgKG5yb3dzID4gMSkgfCAobmNvbHMgPiAxKQ0KKyAg
IGlmIChucm93cyA+IDEpIHx8IChuY29scyA+IDEpDQogICAgIGRpc3AoWyco
JyBpbnQyc3RyKHIpICcsJyBpbnQyc3RyKGMpICcpOicgc3Rye3IsY31dKTsN
CiAgICBlbHNlDQogICAgIGRpc3Aoc3Rye3IsY30pOyANCi0tLSBnbG9wdGlw
b2x5My9AbXBvbC9pbmRtZWFzLm0JMjAwOC0wOS0xMSAwOTo1Mjo1Mi4wMDAw
MDAwMDAgKzEwMDAKKysrIGdsb3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIw
OTI0L0BtcG9sL2luZG1lYXMubQkyMDIyLTA5LTI0IDIwOjU5OjM2LjU1NDgx
MjM4NSArMTAwMApAQCAtMSw0ICsxLDQgQEAKLWZ1bmN0aW9uIG0gPSBJTkRN
RUFTKHgpCitmdW5jdGlvbiBtID0gaW5kbWVhcyh4KQogJSBATVBPTC9JTkRN
RUFTIC0gSW50ZXJuYWwgdXNlIG9ubHkKIAogJSBJTkRNRUFTKFgpIHJldHVy
bnMgaW5kaWNlcyBvZiBtZWFzdXJlcyBhc3NvY2lhdGVkIHdpdGggdmFyaWFi
bGVzIGluIFgKQEAgLTMxLDcgKzMxLDcgQEAKIG0gPSBtKFsxIGkoZD4wKV0p
OwogCiAlIFJlbW92ZSB6ZXJvIG1lYXN1cmUgaW5kZXgKLWlmIChsZW5ndGgo
bSkgPiAxKSAmIChtKDEpID09IDApCitpZiAobGVuZ3RoKG0pID4gMSkgJiYg
KG0oMSkgPT0gMCkKICBtID0gbSgyOmVuZCk7CiBlbmQKIAotLS0gZ2xvcHRp
cG9seTMvQG1wb2wvaW5kdmFyLm0JMjAwOC0wOS0xMSAwOTo1Mjo1Mi4wMDAw
MDAwMDAgKzEwMDAKKysrIGdsb3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIw
OTI0L0BtcG9sL2luZHZhci5tCTIwMjItMDktMjQgMjA6NTk6MzYuNTU0ODEy
Mzg1ICsxMDAwCkBAIC0yNSw3ICsyNSw3IEBACiB2ID0gdihbMSBpKGQ+MCld
KTsNCiANCiAlIFJlbW92ZSB6ZXJvIHZhcmlhYmxlIGluZGV4DQotaWYgKGxl
bmd0aCh2KSA+IDEpICYgKHYoMSkgPT0gMCkNCitpZiAobGVuZ3RoKHYpID4g
MSkgJiYgKHYoMSkgPT0gMCkNCiAgdiA9IHYoMjplbmQpOw0KIGVuZA0KIA0K
LS0tIGdsb3B0aXBvbHkzL0BtcG9sL21wb2wubQkyMDA4LTA5LTExIDA5OjUy
OjUyLjAwMDAwMDAwMCArMTAwMAorKysgZ2xvcHRpcG9seTMtMy4xMC1vY3Rh
dmUtMjAyMjA5MjQvQG1wb2wvbXBvbC5tCTIwMjItMDktMjQgMjA6NTk6MzYu
NTU1ODEyMzc2ICsxMDAwCkBAIC0zNyw3ICszNyw3IEBACiANCiAgJSBIb3cg
bWFueSB2YXJpYWJsZXMgPw0KICBudmFyID0gMDsNCi0gd2hpbGUgKG52YXIg
PCBuYXJnaW4pICYgaXN2YXJuYW1lKHZhcmFyZ2lue252YXIrMX0pDQorIHdo
aWxlIChudmFyIDwgbmFyZ2luKSAmJiBpc3Zhcm5hbWUodmFyYXJnaW57bnZh
cisxfSkNCiAgICBudmFyID0gbnZhcisxOw0KICBlbmQNCiAgaWYgbnZhciA9
PSAwDQpAQCAtMTEzLDcgKzExMyw3IEBACiAgICAgIGlmIHIgPD0gbmNvbHMN
CiAgICAgICB2YXJ7YyxyfSA9IGk7DQogICAgICBlbmQNCi0gICAgZWxzZWlm
IChyIDw9IG5yb3dzKSAmIChjIDw9IG5jb2xzKSAlIGNvbHVtbiB2ZWN0b3Ig
b3IgbWF0cml4DQorICAgIGVsc2VpZiAociA8PSBucm93cykgJiYgKGMgPD0g
bmNvbHMpICUgY29sdW1uIHZlY3RvciBvciBtYXRyaXgNCiAgICAgIHZhcnty
LGN9ID0gaTsNCiAgICAgZW5kDQogICAgZW5kDQotLS0gZ2xvcHRpcG9seTMv
QG1wb2wvbXBvd2VyLm0JMjAwOC0wOS0xMSAwOTo1Mjo1Mi4wMDAwMDAwMDAg
KzEwMDAKKysrIGdsb3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIwOTI0L0Bt
cG9sL21wb3dlci5tCTIwMjItMDktMjQgMjA6NTk6MzYuNTU1ODEyMzc2ICsx
MDAwCkBAIC0xMCw3ICsxMCw3IEBACiAgeSA9IDE7DQogZW5kDQogDQotaWYg
KG1heChzaXplKHkpKSA+IDEpIHwgKHkgPCAwKSB8IChhYnMocm91bmQoeSkt
eSkgPiAwKQ0KK2lmIChtYXgoc2l6ZSh5KSkgPiAxKSB8fCAoeSA8IDApIHx8
IChhYnMocm91bmQoeSkteSkgPiAwKQ0KICBlcnJvcignRXhwb25lbnQgbXVz
dCBiZSBhIG5vbm5lZ2F0aXZlIGludGVnZXInKQ0KIGVuZA0KIA0KQEAgLTIz
LDcgKzIzLDcgQEAKICAlIFplcm8gZXhwb25lbnQNCiAgeiA9IG1wb2woZXll
KHNpemUoeCkpKTsNCiANCi1lbHNlaWYgKG1heChzaXplKHgpKSA9PSAxKSAm
IChzaXplKGNvZWYoeCksMSkgPT0gMSkNCitlbHNlaWYgKG1heChzaXplKHgp
KSA9PSAxKSAmJiAoc2l6ZShjb2VmKHgpLDEpID09IDEpDQogDQogICUgT25s
eSBvbmUgc2NhbGFyIG1vbm9taWFsDQogIHogPSB4Ow0KLS0tIGdsb3B0aXBv
bHkzL0BtcG9sL3NjYWxlLm0JMjAwOS0xMC0zMCAxNjo0NDoyOC4wMDAwMDAw
MDAgKzExMDAKKysrIGdsb3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIwOTI0
L0BtcG9sL3NjYWxlLm0JMjAyMi0wOS0yNCAyMDo1OTozNi41NTU4MTIzNzYg
KzEwMDAKQEAgLTI2LDcgKzI2LDcgQEAKIAogW25yLG5jXSA9IHNpemUoeCk7
CiBpZiBpc2EoeSwnZG91YmxlJykKLSBpZiAobWF4KHNpemUoeSkpID09IDEp
ICYgKG1pbihzaXplKHgpKSA9PSAxKQorIGlmIChtYXgoc2l6ZSh5KSkgPT0g
MSkgJiYgKG1pbihzaXplKHgpKSA9PSAxKQogICB5ID0gcmVwbWF0KHksc2l6
ZSh4LDEpLHNpemUoeCwyKSk7CiAgZW5kCiAgaWYgfmFsbChzaXplKHgpPT1z
aXplKHkpKQpAQCAtNTEsNyArNTEsNyBAQAogZm9yIHIgPSAxOm5yCiAgZm9y
IGMgPSAxOm5jCiAgIHhjID0gY29lZih4KHIsYykpOwotICBpZiAoc2l6ZSh4
YywxKSA+IDEpIHwgKHhjKDEpIH49IDEpCisgIGlmIChzaXplKHhjLDEpID4g
MSkgfHwgKHhjKDEpIH49IDEpCiAgICBlcnJvcignSW52YWxpZCBwb2x5bm9t
aWFsIHdpdGggc2V2ZXJhbCBtb25vbWlhbHMnKQogICBlbmQKICAgeGQgPSBw
b3coeChyLGMpKTsKLS0tIGdsb3B0aXBvbHkzL0Btc2RwL2Rpc3BsYXkubQky
MDA4LTA5LTExIDA5OjUyOjUyLjAwMDAwMDAwMCArMTAwMAorKysgZ2xvcHRp
cG9seTMtMy4xMC1vY3RhdmUtMjAyMjA5MjQvQG1zZHAvZGlzcGxheS5tCTIw
MjItMDktMjQgMjA6NTk6MzYuNTU1ODEyMzc2ICsxMDAwCkBAIC01LDExICs1
LDIwIEBACiAlIExhc3QgbW9kaWZpZWQgb24gMzEgTWFyY2ggMjAwNgogICAK
ICUgU3BhY2luZworaWYgZXhpc3QoJ09DVEFWRV9WRVJTSU9OJykKKyAgW34s
ZnNdPWZvcm1hdDsKKyAgaWYgaXNlcXVhbChmcywnY29tcGFjdCcpCisgICAg
Y3IgPSAnJzsKKyAgZWxzZQorICAgIGNyID0gJ1xuJzsKKyAgZW5kCitlbHNl
ICAgIAogaWYgaXNlcXVhbChnZXQoMCwnRm9ybWF0U3BhY2luZycpLCdjb21w
YWN0JykKICBjciA9ICcnOwogZWxzZQogIGNyID0gJ1xuJzsKIGVuZAorZW5k
CiAKICUgRGlzcGxheSB2YXJpYWJsZSBuYW1lCiAlIHhuYW1lID0gaW5wdXRu
YW1lKDEpOwotLS0gZ2xvcHRpcG9seTMvQG1zZHAvbXNkcC5tCTIwMTktMDIt
MjggMTY6MTk6MDguMDAwMDAwMDAwICsxMTAwCisrKyBnbG9wdGlwb2x5My0z
LjEwLW9jdGF2ZS0yMDIyMDkyNC9AbXNkcC9tc2RwLm0JMjAyMi0wOS0yNCAy
MDo1OTozNi41NTY4MTIzNjggKzEwMDAKQEAgLTcwLDcgKzcwLDcgQEAKICBh
cmcgPSB2YXJhcmdpbntrfTsKICBpZiBpc2EoYXJnLCdkb3VibGUnKQogICBp
ZiBtYXgoc2l6ZShhcmcpKSA9PSAxCi0gICBpZiAoZmxvb3IoYXJnKSB+PSBh
cmcpIHwgKGFyZyA8PSAwKQorICAgaWYgKGZsb29yKGFyZykgfj0gYXJnKSB8
fCAoYXJnIDw9IDApCiAgICAgZXJyb3IoJ1JlbGF4YXRpb24gb3JkZXIgbXVz
dCBiZSBhIHBvc2l0aXZlIGludGVnZXInKQogICAgZW5kCiAgICBvcmQgPSBh
cmc7ICUgU0RQIHJlbGF4YXRpb24gb3JkZXIKQEAgLTgwLDcgKzgwLDcgQEAK
ICAgZW5kCiAgZWxzZWlmIGlzYShhcmcsJ21wb2wnKQogICBlcnJvcignSW52
YWxpZCBpbnB1dCBwb2x5bm9taWFsJykKLSBlbHNlaWYgfmlzYShhcmcsJ3N1
cGNvbicpICYgfmlzYShhcmcsJ21vbWNvbicpCisgZWxzZWlmIH5pc2EoYXJn
LCdzdXBjb24nKSAmJiB+aXNhKGFyZywnbW9tY29uJykKICAgZXJyb3IoJ0lu
dmFsaWQgaW5wdXQgYXJndW1lbnQnKQogIGVuZAogZW5kCkBAIC05Miw3ICs5
Miw3IEBACiBvYmpzaWduID0gMTsgJSBtYXggPSArMSwgbWluID0gLTEKIGZv
ciBrID0gMTpsZW5ndGgoYXJnKQogIG0gPSBhcmd7a307IHQgPSB0eXBlKG0p
OwotIGlmIGlzYShtLCdtb21jb24nKSAmIChzdHJjbXAodCwnbWluJykgfCBz
dHJjbXAodCwnbWF4JykpCisgaWYgaXNhKG0sJ21vbWNvbicpICYmIChzdHJj
bXAodCwnbWluJykgfHwgc3RyY21wKHQsJ21heCcpKQogICBpZiB+aXNlbXB0
eShtb2JqKQogICAgZXJyb3IoJ01vbWVudCBvYmplY3RpdmUgZnVuY3Rpb24g
aXMgbm90IHVuaXF1ZScpCiAgIGVuZApAQCAtMTQwLDE4ICsxNDAsMTggQEAK
ICAgICAgJSBjb25zdGFudCBzdXBwb3J0IGNvbnN0cmFpbnQKICAgICAgJSBj
aGVjayBjb25zaXN0ZW5jeQogICAgICBjcCA9IGNvZWYocHApOwotICAgICBp
ZiBzdHJjbXAodCwgJ2VxJykgJiBjcAorICAgICBpZiBzdHJjbXAodCwgJ2Vx
JykgJiYgY3AKICAgICAgIGVycm9yKCdJbmNvbnNpc3RlbnQgc3VwcG9ydCBl
cXVhbGl0eSBjb25zdHJhaW50JykKLSAgICAgZWxzZWlmIHN0cmNtcCh0LCAn
Z2UnKSAmIGNwIDwgMAorICAgICBlbHNlaWYgc3RyY21wKHQsICdnZScpICYm
IGNwIDwgMAogICAgICAgZXJyb3IoJ0luY29uc2lzdGVudCBzdXBwb3J0IGlu
ZXF1YWxpdHkgY29uc3RyYWludCcpCi0gICAgIGVsc2VpZiBzdHJjbXAodCwg
J2xlJykgJiBjcCA+IDAKKyAgICAgZWxzZWlmIHN0cmNtcCh0LCAnbGUnKSAm
JiBjcCA+IDAKICAgICAgIGVycm9yKCdJbmNvbnNpc3RlbnQgc3VwcG9ydCBp
bmVxdWFsaXR5IGNvbnN0cmFpbnQnKQogICAgICBlbmQKICAgICBlbHNlCiAg
ICAgICUgc3RvcmUgc3VwcG9ydCBjb25zdHJhaW50ICAgCiAgICAgIG1wID0g
aW5kbWVhcyhscCk7CiAgICAgIGNwID0gY29lZihscCk7Ci0gICAgIGlmIHN0
cmNtcCh0LCAnZXEnKSAmIChsZW5ndGgoY3ApPT0xKSAmIChjcCgxKT09MSkg
JiBtcAorICAgICBpZiBzdHJjbXAodCwgJ2VxJykgJiYgKGxlbmd0aChjcCk9
PTEpICYmIChjcCgxKT09MSkgJiYgbXAKICAgICAgICUgb25seSBvbmUgbW9u
b21pYWwgaW4gTEhTID0KICAgICAgICUgc3VwcG9ydCB0byBiZSBleHBsaWNp
dGx5IHN1YnN0aXR1dGVkCiAgICAgICBtc3VwcyA9IFttc3VwcyBzdHJ1Y3Qo
J2xlZnQnLGxwLCdyaWdodCcscnApXTsKQEAgLTE5NCwxMiArMTk0LDEyIEBA
CiBtbW9tcyA9IFtdOyAlIG1vbWVudCBzdWJzdGl0dXRpb25zCiBmb3IgayA9
IDE6bGVuZ3RoKGFyZykKICBtID0gYXJne2t9OyB0ID0gdHlwZShtKTsKLSBp
ZiBpc2EobSwnbW9tY29uJykgJiB+KHN0cmNtcCh0LCdtaW4nKSB8IHN0cmNt
cCh0LCdtYXgnKSkKKyBpZiBpc2EobSwnbW9tY29uJykgJiYgfihzdHJjbXAo
dCwnbWluJykgfHwgc3RyY21wKHQsJ21heCcpKQogICBmb3IgciA9IDE6c2l6
ZShtLDEpCiAgICBmb3IgYyA9IDE6c2l6ZShtLDIpCiAgICAgcCA9IG0ocixj
KTsgdCA9IHR5cGUocCk7CiAgICAgbHAgPSBsZWZ0KHApOyBycCA9IHJpZ2h0
KHApOyAlIHNjYWxhciBtb21lbnRzCi0gICAgaWYgfmNvbnNpc3RlbnQobHAp
IHwgfmNvbnNpc3RlbnQocnApCisgICAgaWYgfmNvbnNpc3RlbnQobHApIHx8
IH5jb25zaXN0ZW50KHJwKQogICAgICBlcnJvcignSW52YWxpZCBtb21lbnQg
Y29uc3RyYWludCB3aXRoIGluY29uc2lzdGVudCB2YXJpYWJsZXMgYW5kIG1l
YXN1cmVzJykKICAgICBlbmQKICAgICAlIHN0b3JlIG1lYXN1cmUgYW5kIHZh
cmlhYmxlIGluZGljZXMKQEAgLTIwOCwxMSArMjA4LDExIEBACiAgICAgICUg
Y29uc3RhbnQgbW9tZW50IGNvbnN0cmFpbnQKICAgICAgJSBjaGVjayBjb25z
aXN0ZW5jeQogICAgICBjcCA9IGNvZWYoc3BsaXQobHApKSAtIGNvZWYoc3Bs
aXQocnApKTsKLSAgICAgaWYgc3RyY21wKHQsICdlcScpICYgY3AKKyAgICAg
aWYgc3RyY21wKHQsICdlcScpICYmIGNwCiAgICAgICBlcnJvcignSW5jb25z
aXN0ZW50IG1vbWVudCBlcXVhbGl0eSBjb25zdHJhaW50JykKLSAgICAgZWxz
ZWlmIHN0cmNtcCh0LCAnZ2UnKSAmIGNwIDwgMAorICAgICBlbHNlaWYgc3Ry
Y21wKHQsICdnZScpICYmIGNwIDwgMAogICAgICAgZXJyb3IoJ0luY29uc2lz
dGVudCBtb21lbnQgaW5lcXVhbGl0eSBjb25zdHJhaW50JykKLSAgICAgZWxz
ZWlmIHN0cmNtcCh0LCAnbGUnKSAmIGNwID4gMAorICAgICBlbHNlaWYgc3Ry
Y21wKHQsICdsZScpICYmIGNwID4gMAogICAgICAgZXJyb3IoJ0luY29uc2lz
dGVudCBtb21lbnQgaW5lcXVhbGl0eSBjb25zdHJhaW50JykKICAgICAgZW5k
CiAgICAgZWxzZQpAQCAtMjIxLDcgKzIyMSw3IEBACiAgICAgIHBpbmR2YXIg
PSBbcGluZHZhciBpbmR2YXIobHApIGluZHZhcihycCldOwogICAgICAlIHN1
YnN0aXR1dGlvbiA/CiAgICAgIGxwcCA9IHNwbGl0KGxwKTsgY3AgPSBjb2Vm
KGxwcCgxKSk7Ci0gICAgIGlmIHN0cmNtcCh0LCdlcScpICYgKGxlbmd0aChs
cHApPT0xKSAmIChsZW5ndGgoY3ApPT0xKSAmIChjcCgxKSA9PSAxKSAmIG5l
d3BpbmRtZWFzKDEpCisgICAgIGlmIHN0cmNtcCh0LCdlcScpICYmIChsZW5n
dGgobHBwKT09MSkgJiYgKGxlbmd0aChjcCk9PTEpICYmIChjcCgxKSA9PSAx
KSAmJiBuZXdwaW5kbWVhcygxKQogICAgICAgJSBvbmx5IG9uZSBtb25pYyBt
b25vbWlhbCBpbiBMSFMgPQogICAgICAgJSBtb21lbnQgdG8gYmUgZXhwbGlj
aXRseSBzdWJzdGl0dXRlZAogICAgICAgbW1vbXMgPSBbbW1vbXMgc3RydWN0
KCdsZWZ0JyxscCwncmlnaHQnLHJwKV07CkBAIC0yOTcsNyArMjk3LDcgQEAK
IHBpbmRtZWFzID0gbShbMSBpKGQ+MCldKTsKIAogJSBSZW1vdmUgemVybyBt
ZWFzdXJlIGluZGV4Ci1pZiAobGVuZ3RoKHBpbmRtZWFzKSA+IDEpICYgKHBp
bmRtZWFzKDEpID09IDApCitpZiAobGVuZ3RoKHBpbmRtZWFzKSA+IDEpICYm
IChwaW5kbWVhcygxKSA9PSAwKQogIHBpbmRtZWFzID0gcGluZG1lYXMoMjpl
bmQpOwogZW5kCiAKQEAgLTMxNSw3ICszMTUsNyBAQAogcGluZHZhciA9IHYo
WzEgaShkPjApXSk7CiAKICUgUmVtb3ZlIHplcm8gdmFyaWFibGUgaW5kZXgK
LWlmIChsZW5ndGgocGluZHZhcikgPiAxICkgJiAocGluZHZhcigxKSA9PSAw
KQoraWYgKGxlbmd0aChwaW5kdmFyKSA+IDEgKSAmJiAocGluZHZhcigxKSA9
PSAwKQogIHBpbmR2YXIgPSBwaW5kdmFyKDI6ZW5kKTsKIGVuZAogCkBAIC0z
NzMsNyArMzczLDcgQEAKIAogJSBBbGdlYnJhaWMgY29uc3RyYWludHMgb24g
bW9tZW50cwogCi1pZiBpc2VtcHR5KG1tb21jZ2UpICYgaXNlbXB0eShtbW9t
Y2VxKSAmIGlzZW1wdHkobW1vbXMpCitpZiBpc2VtcHR5KG1tb21jZ2UpICYm
IGlzZW1wdHkobW1vbWNlcSkgJiYgaXNlbXB0eShtbW9tcykKIAogICUgTm8g
bW9tZW50IGNvbnN0cmFpbnRzIHNvIGFsbCBtZWFzdXJlIG1hc3NlcyBhcmUg
c2V0IHRvIG9uZQogIGZvciBtID0gMTpubWVhcwpAQCAtNDEzLDcgKzQxMyw3
IEBACiBzdWJzID0gemVyb3ModG5tLDEpOyAlIG51bWJlciBvZiBzdWJzdGl0
dXRpb25zIGZvciBlYWNoIHZhcmlhYmxlCiBjb25mbGljdCA9IDA7ICUgY29u
ZmxpY3Rpbmcgc3Vic3RpdHV0aW9ucwogCi1pZiB+aXNlbXB0eShtbW9tcykg
fCB+aXNlbXB0eShtc3VwcykKK2lmIH5pc2VtcHR5KG1tb21zKSB8fCB+aXNl
bXB0eShtc3VwcykKIAogICUgLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAlIFN1
cHBvcnQgc3Vic3RpdHV0aW9ucwpAQCAtNTI5LDcgKzUyOSw3IEBACiAgJSBj
aGFyKGxvZ2ljYWwoZnVsbChBcikpK2NoYXIoJzAnKSkKIAogICUgRGV0ZWN0
IHRyaWFuZ3VsYXIgc3RydWN0dXJlCi0gaWYgfmFueShhbnkodHJpdShBcig6
LDI6ZW5kKSwxKSkpIHwgfmFueShhbnkodHJpbChBcig6LDI6ZW5kKSwtMSkp
KQorIGlmIH5hbnkoYW55KHRyaXUoQXIoOiwyOmVuZCksMSkpKSB8fCB+YW55
KGFueSh0cmlsKEFyKDosMjplbmQpLC0xKSkpCiAgICUgcHJvcGFnYXRlIGxp
bmVhciBkZXBlbmRlbmNlIHJlbGF0aW9ucwogICBmb3IgYyA9IDE6dG5tCiAg
ICBpZiBBcihjLGMrMSkgPT0gMAotLS0gZ2xvcHRpcG9seTMvQG1zZHAvbXNv
bC5tCTIwMjAtMDYtMTYgMTU6MTg6MDQuMDAwMDAwMDAwICsxMDAwCisrKyBn
bG9wdGlwb2x5My0zLjEwLW9jdGF2ZS0yMDIyMDkyNC9AbXNkcC9tc29sLm0J
MjAyMi0wOS0yNCAyMDo1OTozNi41NTY4MTIzNjggKzEwMDAKQEAgLTI4Myw3
ICsyODMsNyBAQAogIG5tZWFzID0gbGVuZ3RoKFAuaW5kbWVhcyk7CiAKICAl
IG9ubHkgb25lIG1lYXN1cmUgd2l0aCBubyBtb21lbnQgb3Igc3VwcG9ydCBz
dWJzdGl0dXRpb24KLSBwb2x5b3B0ID0gKG5tZWFzID09IDEpICYgKHNpemUo
UC5BciwxKSA9PSBsZW5ndGgoUC5pbmRlcCkrMSk7CisgcG9seW9wdCA9IChu
bWVhcyA9PSAxKSAmJiAoc2l6ZShQLkFyLDEpID09IGxlbmd0aChQLmluZGVw
KSsxKTsKIAogIGlmIHBvbHlvcHQKIApAQCAtMzEzLDcgKzMxMyw3IEBACiAg
ICBlbmQKICAgICUgVGVzdGluZyBvYmplY3RpdmUgYW5kIGNvbnN0cmFpbnRz
IGF0IHRoZSBzb2x1dGlvbgogICAgW3JlYWNoLGZlYXNdID0gY2hlY2twb2x5
KFAsMSk7Ci0gICBnbG9ib3B0ID0gYWxsKHJlYWNoICYgZmVhcyk7CisgICBn
bG9ib3B0ID0gYWxsKHJlYWNoICYmIGZlYXMpOwogICBlbmQKICAgCiAgZW5k
CkBAIC0zNjQsNyArMzY0LDcgQEAKICAgICByYW5rZGlmZiA9IDA7CiAgICAg
CiAgICAgayA9IDA7Ci0gICAgd2hpbGUgKGsgPCBrbWF4KSAmIH5yYW5rY2hl
Y2sobSkKKyAgICB3aGlsZSAoayA8IGttYXgpICYmIH5yYW5rY2hlY2sobSkK
ICAgICAgayA9IGsgKyAxOwogICAgICBubSA9IE1NTS5UKG52YXIsa21heCku
YmluKG52YXIsaysyKTsgJSBhbGwgbW9ub21pYWxzCiAgICAgIGluZGVwdSA9
IE1NTS5Ne21tfS5pbmRlcCgxOm5tKTsKQEAgLTM5Miw3ICszOTIsNyBAQAog
ICAgICBlbHNlCiAgICAgICByYW5rZGlmZiA9IDA7CiAgICAgIGVuZAotICAg
ICBpZiAocmFua2RpZmYgPj0gUC5yYW5rc2hpZnQobSkpICYgfnJhbmtjaGVj
ayhtKQorICAgICBpZiAocmFua2RpZmYgPj0gUC5yYW5rc2hpZnQobSkpICYm
IH5yYW5rY2hlY2sobSkKICAgICAgIHJhbmtjaGVjayhtKSA9IHRydWU7CiAg
ICAgIGVuZAogICAgICBvbGRyYW5rID0gcmFua00oayk7CkBAIC02OTUsMTUg
KzY5NSwxNSBAQAogCiAgJSBDaGVjayBmZWFzaWJpbGl0eSBvZiBzdXBwb3J0
IGVxdWFsaXR5IGNvbnN0cmFpbnRzCiAgaWYgfmlzZW1wdHkocG9seWNlcSkK
LSAgZmVhcyhpKSA9IGZlYXMoaSkgJiBhbGwoYWJzKHBvbHljZXEoOiw6LGkp
KSA8IE1NTS50ZXN0b2wpIDsKKyAgZmVhcyhpKSA9IGZlYXMoaSkgJiYgYWxs
KGFicyhwb2x5Y2VxKDosOixpKSkgPCBNTU0udGVzdG9sKSA7CiAgZW5kCiAg
CiAgJSBDaGVjayBmZWFzaWJpbGl0eSBvZiBzdXBwb3J0IGluZXF1YWxpdHkg
Y29uc3RyYWludHMKICBpZiB+aXNlbXB0eShwb2x5Y2dlKQotICBmZWFzKGkp
ID0gZmVhcyhpKSAmIGFsbCgtcG9seWNnZSg6LDosaSkgPCBNTU0udGVzdG9s
KTsKKyAgZmVhcyhpKSA9IGZlYXMoaSkgJiYgYWxsKC1wb2x5Y2dlKDosOixp
KSA8IE1NTS50ZXN0b2wpOwogIGVuZAogIAotIGlmIH5pc2VtcHR5KHBvbHlj
ZXEpIHwgfmlzZW1wdHkocG9seWNnZSkKKyBpZiB+aXNlbXB0eShwb2x5Y2Vx
KSB8fCB+aXNlbXB0eShwb2x5Y2dlKQogICBpZiBNTU0udmVyYm9zZQogICAg
aWYgZmVhcyhpKQogICAgIGRpc3AoJyAgICBTb2x1dGlvbiBpcyBmZWFzaWJs
ZScpOwotLS0gZ2xvcHRpcG9seTMvQHN1cGNvbi9kaXNwbGF5Lm0JMjAwOC0w
OS0xMSAwOTo1Mjo1Mi4wMDAwMDAwMDAgKzEwMDAKKysrIGdsb3B0aXBvbHkz
LTMuMTAtb2N0YXZlLTIwMjIwOTI0L0BzdXBjb24vZGlzcGxheS5tCTIwMjIt
MDktMjQgMjA6NTk6MzYuNTU2ODEyMzY4ICsxMDAwCkBAIC0xMiw3ICsxMiw3
IEBACiANCiBbbnJvd3MsbmNvbHNdID0gc2l6ZSh4KTsNCiANCi1pZiAobWlu
KG5yb3dzLG5jb2xzKSA8IDEpIHwgaXNlbXB0eSh0eXBlKHgpKQ0KK2lmICht
aW4obnJvd3MsbmNvbHMpIDwgMSkgfHwgaXNlbXB0eSh0eXBlKHgpKQ0KICAN
CiAgaWQgPSAnRW1wdHkgc3VwcG9ydCBjb25zdHJhaW50JzsNCiAgaWYgfnNp
bGVudA0KQEAgLTIxLDcgKzIxLDcgQEAKIAogZWxzZQ0KICANCi0gaWYgKG5y
b3dzID09IDEpICYgKG5jb2xzID09IDEpDQorIGlmIChucm93cyA9PSAxKSAm
JiAobmNvbHMgPT0gMSkNCiAgIGlkID0gJ1NjYWxhcic7DQogIGVsc2VpZiBt
aW4obnJvd3MsbmNvbHMpID09IDENCiAgIGlkID0gW2ludDJzdHIobnJvd3Mp
ICctYnktJyBpbnQyc3RyKG5jb2xzKSAuLi4NCkBAIC03NCw3ICs3NCw3IEBA
CiAgIGVuZAogDQogICBpZiB+c2lsZW50DQotICAgaWYgKG5yb3dzID4gMSkg
fCAobmNvbHMgPiAxKQ0KKyAgIGlmIChucm93cyA+IDEpIHx8IChuY29scyA+
IDEpDQogICAgIGRpc3AoWycoJyBpbnQyc3RyKHIpICcsJyBpbnQyc3RyKGMp
ICcpOicgc3Rye3IsY31dKTsNCiAgICBlbHNlDQogICAgIGRpc3Aoc3Rye3Is
Y30pOyANCi0tLSBnbG9wdGlwb2x5My9Ac3VwY29uL3N1cGNvbi5tCTIwMDgt
MDktMTEgMDk6NTI6NTIuMDAwMDAwMDAwICsxMDAwCisrKyBnbG9wdGlwb2x5
My0zLjEwLW9jdGF2ZS0yMDIyMDkyNC9Ac3VwY29uL3N1cGNvbi5tCTIwMjIt
MDktMjQgMjE6MDA6MjkuMTYxMzcyNzYyICsxMDAwCkBAIC0yOSw3ICsyOSw3
IEBACiANCiAlIENoZWNrIHRoaXJkIGlucHV0IGFyZ3VtZW50DQogDQotaWYg
fnN0cmNtcChvcCwnZ2UnKSAmIH5zdHJjbXAob3AsJ2xlJykgJiB+c3RyY21w
KG9wLCdlcScpDQoraWYgfnN0cmNtcChvcCwnZ2UnKSAmJiB+c3RyY21wKG9w
LCdsZScpICYmIH5zdHJjbXAob3AsJ2VxJykNCiAgZXJyb3IoJ0ludmFsaWQg
b3BlcmF0b3InKQ0KIGVuZA0KIA0KQEAgLTM5LDggKzM5LDggQEAKICUgQ2hl
Y2sgbWVhc3VyZXMNCiAgDQogbWVhc3ggPSBpbmRtZWFzKHgpOyBtZWFzeSA9
IGluZG1lYXMoeSk7DQotaWYgKGxlbmd0aChtZWFzeCkgPiAxKSB8IChsZW5n
dGgobWVhc3kpID4gMSkgfCAuLi4NCi0gICAgICAgIChtZWFzeCAmIG1lYXN5
ICYgKG1lYXN4IH49IG1lYXN5KSkNCitpZiAobGVuZ3RoKG1lYXN4KSA+IDEp
IHx8IChsZW5ndGgobWVhc3kpID4gMSkgfHwgLi4uDQorICAgICAgICBhbnko
bWVhc3ggJiBtZWFzeSAmIChtZWFzeCB+PSBtZWFzeSkpDQogIGVycm9yKCdJ
bnZhbGlkIHJlZmVyZW5jZSB0byBzZXZlcmFsIG1lYXN1cmVzJykNCiBlbmQN
CiAgICAgIA0KLS0tIGdsb3B0aXBvbHkzL2dlbmluZC5tCTIwMDgtMDktMTEg
MDk6NTI6NTAuMDAwMDAwMDAwICsxMDAwCisrKyBnbG9wdGlwb2x5My0zLjEw
LW9jdGF2ZS0yMDIyMDkyNC9nZW5pbmQubQkyMDIyLTA5LTI0IDIwOjU5OjM2
LjU1NzgxMjM2MCArMTAwMApAQCAtMjksNyArMjksNyBAQAogY3JlYXRlID0g
dHJ1ZTsNCiBpZiBpc2ZpZWxkKE1NTSwnVCcpDQogIFttYXhudmFyLG1heG9y
ZF0gPSBzaXplKE1NTS5UKTsNCi0gaWYgKG1heG52YXIgPj0gbnZhcikgJiAo
bWF4b3JkID49IG9yZCkNCisgaWYgKG1heG52YXIgPj0gbnZhcikgJiYgKG1h
eG9yZCA+PSBvcmQpDQogICBjcmVhdGUgPSBpc2VtcHR5KE1NTS5UKG52YXIs
b3JkKS5iaW4pOw0KICBlbmQNCiBlbmQNCi0tLSBnbG9wdGlwb2x5My9tZXh0
Lm0JMjAyMC0wOS0yNiAxNTowMToxMi4wMDAwMDAwMDAgKzEwMDAKKysrIGds
b3B0aXBvbHkzLTMuMTAtb2N0YXZlLTIwMjIwOTI0L21leHQubQkyMDIyLTA5
LTI0IDIwOjU5OjM2LjU1NzgxMjM2MCArMTAwMApAQCAtMjMsNyArMjMsNyBA
QAogIGVycm9yKCdJbnZhbGlkIGNhbGxpbmcgc3ludGF4JykKIGVuZAogCi1p
ZiAoZGVnbSA8IDApIHwgcmVtKGRlZ20sMikKK2lmIChkZWdtIDwgMCkgfHwg
cmVtKGRlZ20sMikKICBlcnJvcignRGVncmVlIG11c3QgYmUgZXZlbiBhbmQg
cG9zaXRpdmUnKQogZW5kCiBvcmQgPSBkZWdtLzI7CkBAIC0zNSw3ICszNSw3
IEBACiBjcmVhdGUgPSB0cnVlOwogaWYgaXNmaWVsZChNTU0sJ1QnKQogIFt2
LG9dID0gc2l6ZShNTU0uVCk7Ci0gaWYgKHYgPj0gbnZhcikgJiAobyA+PSBv
cmQpCisgaWYgKHYgPj0gbnZhcikgJiYgKG8gPj0gb3JkKQogICBjcmVhdGUg
PSB+aXNlbXB0eShNTU0uVCh2LG8pKTsKICBlbmQKIGVuZAotLS0gZ2xvcHRp
cG9seTMvbXNldC5tCTIwMDgtMDktMzAgMTA6MDg6MTQuMDAwMDAwMDAwICsx
MDAwCisrKyBnbG9wdGlwb2x5My0zLjEwLW9jdGF2ZS0yMDIyMDkyNC9tc2V0
Lm0JMjAyMi0wOS0yNCAyMDo1OTozNi41NTc4MTIzNjAgKzEwMDAKQEAgLTE1
Miw3ICsxNTIsNyBAQAogICAgcGFyMiA9IHZhcmFyZ2lue2srMX07CiAgICBp
ZiBpc2EocGFyMiwnY2hhcicpCiAgICAgcGFyMiA9IHN0cjJudW0obG93ZXIo
cGFyMikpOwotICAgZWxzZWlmIH5pc2EocGFyMiwnZG91YmxlJykgJiB+aXNh
KHBhcjIsICdsb2dpY2FsJykKKyAgIGVsc2VpZiB+aXNhKHBhcjIsJ2RvdWJs
ZScpICYmIH5pc2EocGFyMiwgJ2xvZ2ljYWwnKQogICAgIGVycm9yKCdJbnZh
bGlkIHBhcmFtZXRlciB2YWx1ZScpCiAgICBlbmQKICAgIE1NTSA9IHNldGZp
ZWxkKE1NTSxwYXIscGFyMik7Cg==
====
EOF
uudecode gloptipoly3-$GLOPTIPOLY3_VER.patch.uue
rm -Rf gloptipoly3 $OCTAVE_SITE_M_DIR/gloptipoly3
unzip gloptipoly3.zip
cd gloptipoly3
patch -p 1 < ../gloptipoly3-$GLOPTIPOLY3_VER.patch
cd ..
mv -f gloptipoly3 $OCTAVE_SITE_M_DIR
rm -f gloptipoly3-$GLOPTIPOLY3_VER.patch.uue
rm -f gloptipoly3-$GLOPTIPOLY3_VER.patch

#
# Solver installation done
#
