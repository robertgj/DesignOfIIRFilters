#!/bin/sh

# Build a local version of octave-cli
#
# Require Fedora packages: wget readline-devel lzip sharutils gcc gcc-c++
# gcc-gfortran gmp-devel mpfr-devel make cmake gnuplot-latex m4 gperf 
# bison flex openblas-devel patch texinfo texinfo-tex librsvg2 librsvg2-devel
# librsvg2-tools icoutils autoconf automake libtool pcre pcre-devel freetype
# freetype-devel gnupg2 texlive-dvisvgm
# hdf5 hdf5-devel qt qscintilla-qt5 qscintilla-qt5-devel
# qhull qhull-devel portaudio portaudio-devel libsndfile libsndfile-devel
# libcurl libcurl-devel gl2ps gl2ps-devel fontconfig-devel mesa-libGLU
# mesa-libGLU-devel qt5-qttools qt5-qttools-common qt5-qttools-devel
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
#    gpg2 --verify octave-6.2.0.tar.lz.sig
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
OCTAVE_VER=7.1.0
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
LAPACK_VER=${LAPACK_VER:-3.10.1}
LAPACK_ARCHIVE=lapack-$LAPACK_VER".tar.gz"
LAPACK_URL=http://github.com/Reference-LAPACK/lapack/archive/v$LAPACK_VER.tar.gz
if ! test -f $LAPACK_ARCHIVE; then
  wget -c $LAPACK_URL -O $LAPACK_ARCHIVE
fi

ARPACK_VER=${ARPACK_VER:-3.8.0}
ARPACK_ARCHIVE=arpack-ng-$ARPACK_VER".tar.gz"
ARPACK_URL=https://github.com/opencollab/arpack-ng/archive/refs/tags/$ARPACK_VER".tar.gz"
if ! test -f $ARPACK_ARCHIVE; then
  wget -c $ARPACK_URL -O $ARPACK_ARCHIVE
fi

SUITESPARSE_VER=${SUITESPARSE_VER:-5.12.0}
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

SUNDIALS_VER=${SUNDIALS_VER:-6.2.0}
SUNDIALS_ARCHIVE=sundials-$SUNDIALS_VER".tar.gz"
SUNDIALS_URL=https://github.com/LLNL/sundials/releases/download/v$SUNDIALS_VER/$SUNDIALS_ARCHIVE
if ! test -f $SUNDIALS_ARCHIVE; then
  wget -c $SUNDIALS_URL
fi

GRAPHICSMAGICK_VER=${GRAPHICSMAGICK_VER:-1.3.38}
GRAPHICSMAGICK_ARCHIVE=GraphicsMagick-$GRAPHICSMAGICK_VER".tar.xz"
GRAPHICSMAGICK_URL=https://ixpeering.dl.sourceforge.net/project/graphicsmagick/graphicsmagick/$GRAPHICSMAGICK_VER/$GRAPHICSMAGICK_ARCHIVE
if ! test -f $GRAPHICSMAGICK_ARCHIVE; then
  wget -c $GRAPHICSMAGICK_URL
fi


#
# Get octave-forge packages
#
OCTAVE_FORGE_URL=https://sourceforge.net/projects/octave/files/\
Octave%20\Forge%20Packages/Individual%20Package%20Releases/

IO_VER=${IO_VER:-2.6.4}
IO_ARCHIVE=io-$IO_VER".tar.gz"
IO_URL=$OCTAVE_FORGE_URL$IO_ARCHIVE
if ! test -f $IO_ARCHIVE; then
  wget -c $IO_URL
fi

STATISTICS_VER=${STATISTICS_VER:-1.4.3}
STATISTICS_ARCHIVE=statistics-$STATISTICS_VER".tar.gz"
STATISTICS_URL=$OCTAVE_FORGE_URL$STATISTICS_ARCHIVE
if ! test -f $STATISTICS_ARCHIVE; then
  wget -c $STATISTICS_URL
fi

STRUCT_VER=${STRUCT_VER:-1.0.18}
STRUCT_ARCHIVE=struct-$STRUCT_VER".tar.gz"
STRUCT_URL=$OCTAVE_FORGE_URL$STRUCT_ARCHIVE
if ! test -f $STRUCT_ARCHIVE; then
  wget -c $STRUCT_URL 
fi

OPTIM_VER=${OPTIM_VER:-1.6.2}
OPTIM_ARCHIVE=optim-$OPTIM_VER".tar.gz"
OPTIM_URL=$OCTAVE_FORGE_URL$OPTIM_ARCHIVE
if ! test -f $OPTIM_ARCHIVE; then
  wget -c $OPTIM_URL 
fi

CONTROL_VER=${CONTROL_VER:-3.4.0}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL=$OCTAVE_FORGE_URL$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
  wget -c $CONTROL_URL 
fi

SIGNAL_VER=${SIGNAL_VER:-1.4.2}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=$OCTAVE_FORGE_URL$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
  wget -c $SIGNAL_URL 
fi

PARALLEL_VER=${PARALLEL_VER:-4.0.1}
PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".tar.gz"
PARALLEL_URL=$OCTAVE_FORGE_URL$PARALLEL_ARCHIVE
if ! test -f $PARALLEL_ARCHIVE; then
  wget -c $PARALLEL_URL 
fi

SYMBOLIC_VER=${SYMBOLIC_VER:-3.0.0}
SYMBOLIC_ARCHIVE=symbolic-$SYMBOLIC_VER".tar.gz"
SYMBOLIC_URL=$OCTAVE_FORGE_URL$SYMBOLIC_ARCHIVE
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
cat > lapack-$LAPACK_VER".patch.uue" << 'EOF'
begin-base64 644 lapack-3.10.1.patch
RmlsZXMgbGFwYWNrLTMuMTAuMC5vcmlnL1NSQy9NYWtlZmlsZSBhbmQgbGFw
YWNrLTMuMTAuMC9TUkMvTWFrZWZpbGUgZGlmZmVyCi0tLSBsYXBhY2stMy4x
MC4wLm9yaWcvU1JDL01ha2VmaWxlCTIwMjEtMDYtMjkgMDI6Mzk6MTIuMDAw
MDAwMDAwICsxMDAwCisrKyBsYXBhY2stMy4xMC4wL1NSQy9NYWtlZmlsZQky
MDIxLTA5LTIwIDEyOjQxOjAyLjkxMjc4NjYzOCArMTAwMApAQCAtNTU2LDYg
KzU1Niw5IEBACiAJJChBUikgJChBUkZMQUdTKSAkQCAkXgogCSQoUkFOTElC
KSAkQAogCiskKG5vdGRpciAkKExBUEFDS0xJQjolLmE9JS5zbykpOiAkKEFM
TE9CSikgJChBTExYT0JKKSAkKERFUFJFQ0FURUQpCisJJChGQykgLXNoYXJl
ZCAtV2wsLXNvbmFtZSwkQCAtbyAkQCAkXgorCiAuUEhPTlk6IHNpbmdsZSBj
b21wbGV4IGRvdWJsZSBjb21wbGV4MTYKIAogU0lOR0xFX0RFUFMgOj0gJChT
TEFTUkMpICQoRFNMQVNSQykKRmlsZXMgbGFwYWNrLTMuMTAuMC5vcmlnL0JM
QVMvU1JDL01ha2VmaWxlIGFuZCBsYXBhY2stMy4xMC4wL0JMQVMvU1JDL01h
a2VmaWxlIGRpZmZlcgotLS0gbGFwYWNrLTMuMTAuMC5vcmlnL0JMQVMvU1JD
L01ha2VmaWxlCTIwMjEtMDYtMjkgMDI6Mzk6MTIuMDAwMDAwMDAwICsxMDAw
CisrKyBsYXBhY2stMy4xMC4wL0JMQVMvU1JDL01ha2VmaWxlCTIwMjEtMDkt
MjAgMTI6NDE6MDIuOTE1Nzg2NjEwICsxMDAwCkBAIC0xNDksNiArMTQ5LDkg
QEAKIAkkKEFSKSAkKEFSRkxBR1MpICRAICReCiAJJChSQU5MSUIpICRACiAK
KyQobm90ZGlyICQoQkxBU0xJQjolLmE9JS5zbykpOiAkKEFMTE9CSikKKwkk
KEZDKSAtc2hhcmVkIC1XbCwtc29uYW1lLCRAIC1vICRAICReCisKIC5QSE9O
WTogc2luZ2xlIGRvdWJsZSBjb21wbGV4IGNvbXBsZXgxNgogc2luZ2xlOiAk
KFNCTEFTMSkgJChBTExCTEFTKSAkKFNCTEFTMikgJChTQkxBUzMpCiAJJChB
UikgJChBUkZMQUdTKSAkKEJMQVNMSUIpICReCkZpbGVzIGxhcGFjay0zLjEw
LjAub3JpZy9tYWtlLmluYy5leGFtcGxlIGFuZCBsYXBhY2stMy4xMC4wL21h
a2UuaW5jLmV4YW1wbGUgZGlmZmVyCi0tLSBsYXBhY2stMy4xMC4wLm9yaWcv
bWFrZS5pbmMuZXhhbXBsZQkyMDIxLTA2LTI5IDAyOjM5OjEyLjAwMDAwMDAw
MCArMTAwMAorKysgbGFwYWNrLTMuMTAuMC9tYWtlLmluYy5leGFtcGxlCTIw
MjEtMDktMjAgMTI6NDE6MDIuOTExNzg2NjQ3ICsxMDAwCkBAIC03LDcgKzcs
OCBAQAogIyAgQ0MgaXMgdGhlIEMgY29tcGlsZXIsIG5vcm1hbGx5IGludm9r
ZWQgd2l0aCBvcHRpb25zIENGTEFHUy4KICMKIENDID0gZ2NjCi1DRkxBR1Mg
PSAtTzMKK0JMRE9QVFMgPSAtZlBJQyAtbTY0IC1tYXJjaD1uZWhhbGVtCitD
RkxBR1MgPSAtTzMgJChCTERPUFRTKQogCiAjICBNb2RpZnkgdGhlIEZDIGFu
ZCBGRkxBR1MgZGVmaW5pdGlvbnMgdG8gdGhlIGRlc2lyZWQgY29tcGlsZXIK
ICMgIGFuZCBkZXNpcmVkIGNvbXBpbGVyIG9wdGlvbnMgZm9yIHlvdXIgbWFj
aGluZS4gIE5PT1BUIHJlZmVycyB0bwpAQCAtMTcsMTAgKzE4LDEwIEBACiAj
ICBhbmQgaGFuZGxlIHRoZXNlIHF1YW50aXRpZXMgYXBwcm9wcmlhdGVseS4g
QXMgYSBjb25zZXF1ZW5jZSwgb25lCiAjICBzaG91bGQgbm90IGNvbXBpbGUg
TEFQQUNLIHdpdGggZmxhZ3Mgc3VjaCBhcyAtZmZwZS10cmFwPW92ZXJmbG93
LgogIwotRkMgPSBnZm9ydHJhbgotRkZMQUdTID0gLU8yIC1mcmVjdXJzaXZl
CitGQyA9IGdmb3J0cmFuIC1mcmVjdXJzaXZlICQoQkxET1BUUykKK0ZGTEFH
UyA9IC1PMiAKIEZGTEFHU19EUlYgPSAkKEZGTEFHUykKLUZGTEFHU19OT09Q
VCA9IC1PMCAtZnJlY3Vyc2l2ZQorRkZMQUdTX05PT1BUID0gLU8wCiAKICMg
IERlZmluZSBMREZMQUdTIHRvIHRoZSBkZXNpcmVkIGxpbmtlciBvcHRpb25z
IGZvciB5b3VyIG1hY2hpbmUuCiAjCkBAIC01NSw3ICs1Niw3IEBACiAjICBV
bmNvbW1lbnQgdGhlIGZvbGxvd2luZyBsaW5lIHRvIGluY2x1ZGUgZGVwcmVj
YXRlZCByb3V0aW5lcyBpbgogIyAgdGhlIExBUEFDSyBsaWJyYXJ5LgogIwot
I0JVSUxEX0RFUFJFQ0FURUQgPSBZZXMKK0JVSUxEX0RFUFJFQ0FURUQgPSBZ
ZXMKIAogIyAgTEFQQUNLRSBoYXMgdGhlIGludGVyZmFjZSB0byBzb21lIHJv
dXRpbmVzIGZyb20gdG1nbGliLgogIyAgSWYgTEFQQUNLRV9XSVRIX1RNRyBp
cyBkZWZpbmVkLCBhZGQgdGhvc2Ugcm91dGluZXMgdG8gTEFQQUNLRS4KQEAg
LTc0LDcgKzc1LDcgQEAKICMgIG1hY2hpbmUtc3BlY2lmaWMsIG9wdGltaXpl
ZCBCTEFTIGxpYnJhcnkgc2hvdWxkIGJlIHVzZWQgd2hlbmV2ZXIKICMgIHBv
c3NpYmxlLikKICMKLUJMQVNMSUIgICAgICA9ICQoVE9QU1JDRElSKS9saWJy
ZWZibGFzLmEKK0JMQVNMSUIgICAgICA9ICQoVE9QU1JDRElSKS9saWJibGFz
LmEKIENCTEFTTElCICAgICA9ICQoVE9QU1JDRElSKS9saWJjYmxhcy5hCiBM
QVBBQ0tMSUIgICAgPSAkKFRPUFNSQ0RJUikvbGlibGFwYWNrLmEKIFRNR0xJ
QiAgICAgICA9ICQoVE9QU1JDRElSKS9saWJ0bWdsaWIuYQo=
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
make
cd ..
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS LDFLAGS=-L/usr/lib64 \
INSTALL=$OCTAVE_DIR OPTIMIZATION=-O2 BLAS=-lblas LAPACK=-llapack \
make -j 6 install
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
begin-base64 644 octave-7.1.0.patch
LS0tIG9jdGF2ZS03LjEuMC9jb25maWd1cmUJMjAyMi0wNC0wNyAwMDowNTox
Mi4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS03LjEuMC5uZXcvY29uZmln
dXJlCTIwMjItMDQtMjQgMTA6NDk6NDkuMDM2MDg4Mzc2ICsxMDAwCkBAIC02
MjEsOCArNjIxLDggQEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgog
UEFDS0FHRV9OQU1FPSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdv
Y3RhdmUnCi1QQUNLQUdFX1ZFUlNJT049JzcuMS4wJwotUEFDS0FHRV9TVFJJ
Tkc9J0dOVSBPY3RhdmUgNy4xLjAnCitQQUNLQUdFX1ZFUlNJT049JzcuMS4w
LXJvYmonCitQQUNLQUdFX1NUUklORz0nR05VIE9jdGF2ZSA3LjEuMC1yb2Jq
JwogUEFDS0FHRV9CVUdSRVBPUlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdz
Lmh0bWwnCiBQQUNLQUdFX1VSTD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0
d2FyZS9vY3RhdmUvJwogCi0tLSBvY3RhdmUtNy4xLjAvbGliaW50ZXJwL2Nv
cmVmY24vbG9hZC1zYXZlLmNjCTIwMjItMDQtMDcgMDA6MDU6MTIuMDAwMDAw
MDAwICsxMDAwCisrKyBvY3RhdmUtNy4xLjAubmV3L2xpYmludGVycC9jb3Jl
ZmNuL2xvYWQtc2F2ZS5jYwkyMDIyLTA0LTI0IDEwOjQ5OjQ5LjAwMzA4ODY5
NiArMTAwMApAQCAtMTI4LDggKzEyOCw4IEBACiAgIHsKICAgICBjb25zdCBp
bnQgbWFnaWNfbGVuID0gMTA7CiAgICAgY2hhciBtYWdpY1ttYWdpY19sZW4r
MV07Ci0gICAgaXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7CiAgICAgbWFn
aWNbbWFnaWNfbGVuXSA9ICdcMCc7CisgICAgaXMucmVhZCAobWFnaWMsIG1h
Z2ljX2xlbik7CiAKICAgICBpZiAoc3RybmNtcCAobWFnaWMsICJPY3RhdmUt
MS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAgICAgc3dhcCA9IG1hY2hfaW5m
bzo6d29yZHNfYmlnX2VuZGlhbiAoKTsKLS0tIG9jdGF2ZS03LjEuMC9zY3Jp
cHRzL3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5t
CTIwMjItMDQtMDcgMDA6MDU6MTIuMDAwMDAwMDAwICsxMDAwCisrKyBvY3Rh
dmUtNy4xLjAubmV3L3NjcmlwdHMvcGxvdC91dGlsL3ByaXZhdGUvX19nbnVw
bG90X2RyYXdfYXhlc19fLm0JMjAyMi0wNC0yNCAxMDo0OTo0OS4wMDcwODg2
NTcgKzEwMDAKQEAgLTIyODMsNyArMjI4Myw3IEBACiAgICAgaWYgKCEgd2Fy
bmVkX2xhdGV4KQogICAgICAgZG9fd2FybiA9ICh3YXJuaW5nICgicXVlcnki
LCAiT2N0YXZlOnRleHRfaW50ZXJwcmV0ZXIiKSkuc3RhdGU7CiAgICAgICBp
ZiAoc3RyY21wIChkb193YXJuLCAib24iKSkKLSAgICAgICAgd2FybmluZyAo
Ik9jdGF2ZTp0ZXh0X2ludGVycHJldGVyIiwKKyAgICAgICAgd2FybmluZyAo
Ik9jdGF2ZTpsYXRleC1tYXJrdXAtbm90LXN1cHBvcnRlZC1mb3ItdGljay1t
YXJrcyIsCiAgICAgICAgICAgICAgICAgICJsYXRleCBtYXJrdXAgbm90IHN1
cHBvcnRlZCBmb3IgdGljayBtYXJrcyIpOwogICAgICAgICB3YXJuZWRfbGF0
ZXggPSB0cnVlOwogICAgICAgZW5kaWYK
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
export CFLAGS="$OPTFLAGS -std=c11 -I$OCTAVE_INCLUDE_DIR"
export CXXFLAGS="$OPTFLAGS -std=c++11 -I$OCTAVE_INCLUDE_DIR"
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
# Compiling octave is done
#

#
# Install Octave-Forge packages
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$IO_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$STRUCT_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$STATISTICS_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$CONTROL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$OPTIM_ARCHIVE

#
# Fix parallel package pserver.cc and install the parallel package
#
cat > parallel-$PARALLEL_VER".patch.uue" << 'EOF'
begin-base64 644 parallel-4.0.1.patch
RmlsZXMgcGFyYWxsZWwtNC4wLjEvc3JjL2Vycm9yLWhlbHBlcnMuaCBhbmQg
cGFyYWxsZWwtNC4wLjEubmV3L3NyYy9lcnJvci1oZWxwZXJzLmggZGlmZmVy
Ci0tLSBwYXJhbGxlbC00LjAuMS9zcmMvZXJyb3ItaGVscGVycy5oCTIwMjEt
MDMtMTcgMDU6MDM6MDkuMDAwMDAwMDAwICsxMTAwCisrKyBwYXJhbGxlbC00
LjAuMS5uZXcvc3JjL2Vycm9yLWhlbHBlcnMuaAkyMDIyLTAyLTE0IDIxOjI0
OjMyLjY2NDQ1NjYwNyArMTEwMApAQCAtMSwxMCArMSwxMCBAQAogLyoKIAot
Q29weXJpZ2h0IChDKSAyMDE2LTIwMTggT2xhZiBUaWxsIDxpN3Rpb2xAdC1v
bmxpbmUuZGU+CitDb3B5cmlnaHQgKEMpIDIwMTYtMjAxOSBPbGFmIFRpbGwg
PGk3dGlvbEB0LW9ubGluZS5kZT4KIAogVGhpcyBwcm9ncmFtIGlzIGZyZWUg
c29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2Rp
ZnkKIGl0IHVuZGVyIHRoZSB0ZXJtcyBvZiB0aGUgR05VIEdlbmVyYWwgUHVi
bGljIExpY2Vuc2UgYXMgcHVibGlzaGVkIGJ5Ci10aGUgRnJlZSBTb2Z0d2Fy
ZSBGb3VuZGF0aW9uOyBlaXRoZXIgdmVyc2lvbiAzIG9mIHRoZSBMaWNlbnNl
LCBvcgordGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbjsgZWl0aGVyIHZl
cnNpb24gMiBvZiB0aGUgTGljZW5zZSwgb3IKIChhdCB5b3VyIG9wdGlvbikg
YW55IGxhdGVyIHZlcnNpb24uCiAKIFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmli
dXRlZCBpbiB0aGUgaG9wZSB0aGF0IGl0IHdpbGwgYmUgdXNlZnVsLApAQCAt
NDQsMTMgKzQ0LDYgQEAKICAgICB0cnkgXAogICAgICAgeyBcCiAgICAgICAg
IGNvZGUgOyBcCi0gXAotICAgICAgICBpZiAoZXJyb3Jfc3RhdGUpIFwKLSAg
ICAgICAgICB7IFwKLSAgICAgICAgICAgIGVycm9yIChfX1ZBX0FSR1NfXyk7
IFwKLSBcCi0gICAgICAgICAgICByZXR1cm4gcmV0dmFsOyBcCi0gICAgICAg
ICAgfSBcCiAgICAgICB9IFwKICAgICBjYXRjaCAoT0NUQVZFX19FWEVDVVRJ
T05fRVhDRVBUSU9OJiBlKSBcCiAgICAgICB7IFwKQEAgLTY0LDcgKzU3LDkg
QEAKICAgICAgIH0gXAogICAgIGNhdGNoIChPQ1RBVkVfX0VYRUNVVElPTl9F
WENFUFRJT04mIGUpIFwKICAgICAgIHsgXAotICAgICAgICB2ZXJyb3IgKGUs
IF9fVkFfQVJHU19fKTsgXAorICAgICAgICBfcF9lcnJvciAoX19WQV9BUkdT
X18pOyBcCisgXAorICAgICAgICBleGl0ICgxKTsgXAogICAgICAgfQogI2Vu
ZGlmCiAKQEAgLTc3LDEzICs3Miw2IEBACiAgICAgdHJ5IFwKICAgICAgIHsg
XAogICAgICAgICBjb2RlIDsgXAotIFwKLSAgICAgICAgaWYgKGVycm9yX3N0
YXRlKSBcCi0gICAgICAgICAgeyBcCi0gICAgICAgICAgICBfcF9lcnJvciAo
X19WQV9BUkdTX18pOyBcCi0gXAotICAgICAgICAgICAgZXhpdCAoMSk7IFwK
LSAgICAgICAgICB9IFwKICAgICAgIH0gXAogICAgIGNhdGNoIChPQ1RBVkVf
X0VYRUNVVElPTl9FWENFUFRJT04mKSBcCiAgICAgICB7IFwKQEAgLTExNiwx
MSArMTA0LDYgQEAKICAgICB0cnkgXAogICAgICAgeyBcCiAgICAgICAgIGNv
ZGUgOyBcCi0gICAgICAgIGlmIChlcnJvcl9zdGF0ZSkgXAotICAgICAgICAg
IHsgXAotICAgICAgICAgICAgZXJyb3Jfc3RhdGUgPSAwOyBcCi0gICAgICAg
ICAgICBlcnIgPSB0cnVlOyBcCi0gICAgICAgICAgfSBcCiAgICAgICB9IFwK
ICAgICBjYXRjaCAoT0NUQVZFX19FWEVDVVRJT05fRVhDRVBUSU9OJikgXAog
ICAgICAgeyBcCkZpbGVzIHBhcmFsbGVsLTQuMC4xL3NyYy9wLWNvbnRyb2wu
Y2MgYW5kIHBhcmFsbGVsLTQuMC4xLm5ldy9zcmMvcC1jb250cm9sLmNjIGRp
ZmZlcgotLS0gcGFyYWxsZWwtNC4wLjEvc3JjL3AtY29udHJvbC5jYwkyMDIx
LTAzLTE3IDA1OjAzOjA5LjAwMDAwMDAwMCArMTEwMAorKysgcGFyYWxsZWwt
NC4wLjEubmV3L3NyYy9wLWNvbnRyb2wuY2MJMjAyMi0wMi0xNCAyMTo1Mzox
Ni40MDYyNjQ0MTAgKzExMDAKQEAgLTI4Niw3ICsyODYsNyBAQAogICAgICAg
ICB9CiAgICAgICBlbHNlCiAgICAgICAgIHsKLSAgICAgICAgICBucHJvY19t
YXggPSBudW1fcHJvY2Vzc29ycyAoTlBST0NfQ1VSUkVOVCk7CisgICAgICAg
ICAgbnByb2NfbWF4ID0gb2N0YXZlX251bV9wcm9jZXNzb3JzX3dyYXBwZXIg
KE5QUk9DX0NVUlJFTlQpOwogCiAgICAgICAgICAgZ251bGliX3BvbGxmZHMg
PSBnbnVsaWJfYWxsb2NfcG9sbGZkcyAobnByb2NfbWF4KTsKICAgICAgICAg
fQpGaWxlcyBwYXJhbGxlbC00LjAuMS9zcmMvcGFyYWxsZWwtZ251dGxzLmgg
YW5kIHBhcmFsbGVsLTQuMC4xLm5ldy9zcmMvcGFyYWxsZWwtZ251dGxzLmgg
ZGlmZmVyCi0tLSBwYXJhbGxlbC00LjAuMS9zcmMvcGFyYWxsZWwtZ251dGxz
LmgJMjAyMS0wMy0xNyAwNTowMzowOS4wMDAwMDAwMDAgKzExMDAKKysrIHBh
cmFsbGVsLTQuMC4xLm5ldy9zcmMvcGFyYWxsZWwtZ251dGxzLmgJMjAyMi0w
Mi0xNCAyMTo1MzoxMC45ODMyOTAyMzMgKzExMDAKQEAgLTQ0LDcgKzQ0LDcg
QEAKIAogI2luY2x1ZGUgPHN0ZGludC5oPgogCi0vLyBXZSBsaW5rIGFnYWlu
c3QgdGhlIGdudWxpYiBudW1fcHJvY2Vzc29ycygpIHVzZWQgYnkgT2N0YXZl
LiBucHJvYy5oCisvLyBXZSBsaW5rIGFnYWluc3QgdGhlIGdudWxpYiBvY3Rh
dmVfbnVtX3Byb2Nlc3NvcnNfd3JhcHBlcigpIHVzZWQgYnkgT2N0YXZlLiBu
cHJvYy5oCiAvLyB1c2VkIGJ5IE9jdGF2ZSBpcyBub3QgYWNjZXNzaWJsZS4g
SWYgdGhlIGludGVyZmFjZSBjaGFuZ2VzLCB0aGlzCiAvLyB3aWxsIHN0b3Ag
d29ya2luZy4KIGV4dGVybiAiQyIgewpAQCAtNTgsNyArNTgsNyBAQAogCiAv
KiBSZXR1cm4gdGhlIHRvdGFsIG51bWJlciBvZiBwcm9jZXNzb3JzLiAgVGhl
IHJlc3VsdCBpcyBndWFyYW50ZWVkIHRvCiAgICBiZSBhdCBsZWFzdCAxLiAg
Ki8KLWV4dGVybiB1bnNpZ25lZCBsb25nIGludCBudW1fcHJvY2Vzc29ycyAo
ZW51bSBucHJvY19xdWVyeSBxdWVyeSk7CitleHRlcm4gdW5zaWduZWQgbG9u
ZyBpbnQgb2N0YXZlX251bV9wcm9jZXNzb3JzX3dyYXBwZXIgKGVudW0gbnBy
b2NfcXVlcnkgcXVlcnkpOwogfQogCiAKRmlsZXMgcGFyYWxsZWwtNC4wLjEv
c3JjL3Bjb25uZWN0LmNjIGFuZCBwYXJhbGxlbC00LjAuMS5uZXcvc3JjL3Bj
b25uZWN0LmNjIGRpZmZlcgotLS0gcGFyYWxsZWwtNC4wLjEvc3JjL3Bjb25u
ZWN0LmNjCTIwMjEtMDMtMTcgMDU6MDM6MDkuMDAwMDAwMDAwICsxMTAwCisr
KyBwYXJhbGxlbC00LjAuMS5uZXcvc3JjL3Bjb25uZWN0LmNjCTIwMjItMDIt
MTQgMjE6NTQ6MjQuMzg5OTQwNjg1ICsxMTAwCkBAIC00MDcsNyArNDA3LDcg
QEAKICAgbmV0d29yay0+aW5zZXJ0X2Nvbm5lY3Rpb24gKGNvbm4sIDApOwog
CiAgIC8vIHN0b3JlIG51bWJlciBvZiBwcm9jZXNzb3IgY29yZXMgYXZhaWxh
YmxlIGluIGNsaWVudAotICBjb25uLT5zZXRfbnByb2MgKG51bV9wcm9jZXNz
b3JzIChOUFJPQ19DVVJSRU5UKSk7CisgIGNvbm4tPnNldF9ucHJvYyAob2N0
YXZlX251bV9wcm9jZXNzb3JzX3dyYXBwZXIgKE5QUk9DX0NVUlJFTlQpKTsK
IAogICBmb3IgKHVpbnQzMl90IGkgPSAwOyBpIDwgbmhvc3RzOyBpKyspCiAg
ICAgewpGaWxlcyBwYXJhbGxlbC00LjAuMS9zcmMvY29uZmlndXJlIGFuZCBw
YXJhbGxlbC00LjAuMS5uZXcvc3JjL2NvbmZpZ3VyZSBkaWZmZXIKLS0tIHBh
cmFsbGVsLTQuMC4xL3NyYy9jb25maWd1cmUJMjAyMS0wMy0xNyAwNTowMzo0
NC43NjY3Mzc4MTcgKzExMDAKKysrIHBhcmFsbGVsLTQuMC4xLm5ldy9zcmMv
Y29uZmlndXJlCTIwMjItMDItMTQgMjE6MjQ6MzIuNjY3NDU2NTkyICsxMTAw
CkBAIC0yMzQ4MiwxMSArMjM0ODIsMTEgQEAKIF9BQ0VPRgogaWYgYWNfZm5f
Y3h4X3RyeV9jb21waWxlICIkTElORU5PIjsgdGhlbiA6CiAKLSRhc19lY2hv
ICIjZGVmaW5lIE9DVEFWRV9fSU5URVJQUkVURVJfX1NZTUJPTF9UQUJMRV9f
QVNTSUdOIG9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRlciAo
KSAtPiBnZXRfc3ltYm9sX3RhYmxlICgpLmFzc2lnbiIgPj5jb25mZGVmcy5o
CiskYXNfZWNobyAiI2RlZmluZSBPQ1RBVkVfX0lOVEVSUFJFVEVSX19TWU1C
T0xfVEFCTEVfX0FTU0lHTiBvY3RhdmU6OmludGVycHJldGVyOjp0aGVfaW50
ZXJwcmV0ZXIgKCkgLT4gYXNzaWduIiA+PmNvbmZkZWZzLmgKIAogCi0gICAg
IHsgJGFzX2VjaG8gIiRhc19tZToke2FzX2xpbmVuby0kTElORU5PfTogcmVz
dWx0OiBvY3RhdmU6OmludGVycHJldGVyOjp0aGVfaW50ZXJwcmV0ZXIgKCkg
LT4gZ2V0X3N5bWJvbF90YWJsZSAoKS5hc3NpZ24iID4mNQotJGFzX2VjaG8g
Im9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRlciAoKSAtPiBn
ZXRfc3ltYm9sX3RhYmxlICgpLmFzc2lnbiIgPiY2OyB9CisgICAgIHsgJGFz
X2VjaG8gIiRhc19tZToke2FzX2xpbmVuby0kTElORU5PfTogcmVzdWx0OiBv
Y3RhdmU6OmludGVycHJldGVyOjp0aGVfaW50ZXJwcmV0ZXIgKCkgLT4gYXNz
aWduIiA+JjUKKyRhc19lY2hvICJvY3RhdmU6OmludGVycHJldGVyOjp0aGVf
aW50ZXJwcmV0ZXIgKCkgLT4gYXNzaWduIiA+JjY7IH0KICAgICAgZWNobyAn
CiAnID4+IG9jdC1hbHQtaW5jbHVkZXMuaAogZWxzZQpGaWxlcyBwYXJhbGxl
bC00LjAuMS9zcmMvX19vY3RhdmVfc2VydmVyX18uY2MgYW5kIHBhcmFsbGVs
LTQuMC4xLm5ldy9zcmMvX19vY3RhdmVfc2VydmVyX18uY2MgZGlmZmVyCi0t
LSBwYXJhbGxlbC00LjAuMS9zcmMvX19vY3RhdmVfc2VydmVyX18uY2MJMjAy
MS0wMy0xNyAwNTowMzowOS4wMDAwMDAwMDAgKzExMDAKKysrIHBhcmFsbGVs
LTQuMC4xLm5ldy9zcmMvX19vY3RhdmVfc2VydmVyX18uY2MJMjAyMi0wMi0x
NCAyMTozOTo1MC45NjgwOTg3OTMgKzExMDAKQEAgLTMxNyw3ICszMTcsNyBA
QAogI2VuZGlmIC8vIEhBVkVfTElCR05VVExTCiAKICAgLy8gZGV0ZXJtaW5l
IG93biBudW1iZXIgb2YgdXNhYmxlIHByb2Nlc3NvciBjb3JlcwotICB1aW50
MzJfdCBucHJvYyA9IG51bV9wcm9jZXNzb3JzIChOUFJPQ19DVVJSRU5UKTsK
KyAgdWludDMyX3QgbnByb2MgPSBvY3RhdmVfbnVtX3Byb2Nlc3NvcnNfd3Jh
cHBlciAoTlBST0NfQ1VSUkVOVCk7CiAKICAgLy8gVGhlIHNlcnZlcnMgY29t
bWFuZCBzdHJlYW0gd2lsbCBub3QgYmUgaW5zZXJ0ZWQgaW50byBhCiAgIC8v
IGNvbm5lY3Rpb24gb2JqZWN0Lgo=
====
EOF
uudecode parallel-$PARALLEL_VER".patch.uue" > parallel-$PARALLEL_VER".patch"
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
begin-base64 664 signal-1.4.2.patch
LS0tIHNpZ25hbC0xLjQuMi9pbnN0L2dycGRlbGF5Lm0JMjAyMi0wNC0yMyAy
MToyMToyNS4wMDAwMDAwMDAgKzEwMDAKKysrIHNpZ25hbC0xLjQuMi5uZXcv
aW5zdC9ncnBkZWxheS5tCTIwMjItMDQtMjYgMTQ6MDA6NTAuNzYxNDU1ODcx
ICsxMDAwCkBAIC0xMDksNjMgKzEwOSw2MyBAQAogIyMgaXMgY29udmVydGVk
IHRvIHRoZSBGSVIgZmlsdGVyIGNvbnYoYixmbGlwbHIoY29uaihhKSkpLgog
IyMgRm9yIGZ1cnRoZXIgZGV0YWlscywgc2VlCiAjIyBodHRwOi8vY2NybWEu
c3RhbmZvcmQuZWR1L35qb3MvZmlsdGVycy9OdW1lcmljYWxfQ29tcHV0YXRp
b25fR3JvdXBfRGVsYXkuaHRtbAorIyMgCisjIyBCRVdBUkUgOgorIyMgICAx
LiBUaGUgQVBJIGZvciBncnBkZWxheShiLGEsbikgYW5kIGdycGRlbGF5KGIs
YSx3KSBpcyBhbWJpZ3VvdXMhCisjIyAgICAgIEluIHRoZSBsYXR0ZXIgY2Fz
ZSwgdyBpcyBhc3N1bWVkIHRvIG5vdCBiZSBhIHBvc2l0aXZlIGludGVnZXIg
c2NhbGFyLgorIyMgICAyLiBUaGUgQVBJIGZvciBncnBkZWxheShiLGEsbixG
cykgYW5kIGdycGRlbGF5KGIsYSxmLEZzKSBpcyBhbWJpZ3VvdXMhCisjIyAg
ICAgIEluIHRoZSBsYXR0ZXIgY2FzZSwgZiBpcyBhc3N1bWVkIHRvIG5vdCBi
ZSBhIHBvc2l0aXZlIGludGVnZXIgc2NhbGFyLgorIyMgICAzLiBUaGlzIG1l
dGhvZCBtYXkgYmUgaW5hY2N1cmF0ZSBmb3IgbG9uZyBJSVIgZmlsdGVycyBh
bmQgc21hbGwgbiEKICMjIEBlbmQgZGVmdHlwZWZuCiAKLWZ1bmN0aW9uIFtn
ZCwgd10gPSBncnBkZWxheSAoYiwgYSA9IDEsIG5mZnQgPSA1MTIsIHdob2xl
LCBGcykKK2Z1bmN0aW9uIFtnZCwgd10gPSBncnBkZWxheSAoYiwgYSA9IDEs
IG5mZnQgPSA1MTIsIHdob2xlID0gIiIsIEZzID0gMSkKIAorICAjIFNhbml0
eSBjaGVja3MKICAgaWYgKG5hcmdpbiA8IDEgfHwgbmFyZ2luID4gNSkKICAg
ICBwcmludF91c2FnZSAoKTsKICAgZW5kaWYKIAotICBIekZsYWcgPSBmYWxz
ZTsKLSAgaWYgKGxlbmd0aCAobmZmdCkgPiAxKQorICBpZiBpc2VtcHR5IChu
ZmZ0KQorICAgIG5mZnQgPSA1MTI7CisgIGVuZGlmCisgIAorICBpZiBpc3Nj
YWxhcihuZmZ0KSAmJiAoYWJzKHJvdW5kKG5mZnQpLW5mZnQpPGVwcykgJiYg
KHJvdW5kKG5mZnQpPjApCisgICAgbmZmdF9pc19sZW5ndGggPSB0cnVlOwor
ICAgIG5mZnQgPSByb3VuZChuZmZ0KTsKKyAgZWxzZQorICAgIG5mZnRfaXNf
bGVuZ3RoID0gZmFsc2U7CisgIGVuZGlmCisKKyAgIyBEZWNvZGUgdGhlIEFQ
SQorICBIekZsYWc9ZmFsc2U7CisgIGlmIG5mZnRfaXNfbGVuZ3RoCisgICAg
aWYgKG5hcmdpbiA9PSA1KQorICAgICAgSHpGbGFnID0gdHJ1ZTsKKyAgICBl
bHNlaWYgKG5hcmdpbiA9PSA0KSAmJiAoISBpc2NoYXIgKHdob2xlKSkKKyAg
ICAgIEh6RmxhZyA9IHRydWU7CisgICAgICBGcyA9IHdob2xlOworICAgICAg
d2hvbGUgPSAiIjsKKyAgICBlbmRpZgorICAgIGlmICEgc3RyY21wKHdob2xl
LCJ3aG9sZSIpCisgICAgICBuZmZ0ID0gMipuZmZ0OworICAgIGVuZGlmCisg
ICAgdyA9IDIqcGkqKDA6KG5mZnQtMSkpL25mZnQ7CisgIGVsc2UKICAgICBp
ZiAobmFyZ2luID4gNCkKICAgICAgIHByaW50X3VzYWdlICgpOwotICAgIGVs
c2VpZiAobmFyZ2luID4gMykKLSAgICAgICMjIGdycGRlbGF5IChCLCBBLCBG
LCBGcykKLSAgICAgIEZzICAgICA9IHdob2xlOworICAgIGVsc2VpZiAobmFy
Z2luID09IDQpCisgICAgICAjIGdycGRlbGF5IChCLCBBLCBGLCBGcykKICAg
ICAgIEh6RmxhZyA9IHRydWU7CisgICAgICBGcyA9IHdob2xlOworICAgICAg
dyA9IDIqcGkqbmZmdCg6KScvRnM7CiAgICAgZWxzZQotICAgICAgIyMgZ3Jw
ZGVsYXkgKEIsIEEsIFcpCi0gICAgICBGcyA9IDE7CisgICAgICAjIGdycGRl
bGF5IChCLCBBLCBXKQorICAgICAgdyA9IG5mZnQoOiknOwogICAgIGVuZGlm
Ci0gICAgdyAgICAgPSAyKnBpKm5mZnQvRnM7Ci0gICAgbmZmdCAgPSBsZW5n
dGggKHcpICogMjsKICAgICB3aG9sZSA9ICIiOwotICBlbHNlCi0gICAgaWYg
KG5hcmdpbiA8IDUpCi0gICAgICBGcyA9IDE7ICMgcmV0dXJuIHcgaW4gcmFk
aWFucyBwZXIgc2FtcGxlCi0gICAgICBpZiAobmFyZ2luIDwgNCkKLSAgICAg
ICAgd2hvbGUgPSAiIjsKLSAgICAgIGVsc2VpZiAoISBpc2NoYXIgKHdob2xl
KSkKLSAgICAgICAgRnMgICAgICA9IHdob2xlOwotICAgICAgICBIekZsYWcg
ID0gdHJ1ZTsKLSAgICAgICAgd2hvbGUgICA9ICIiOwotICAgICAgZW5kaWYK
LSAgICAgIGlmIChuYXJnaW4gPCAzKQotICAgICAgICBuZmZ0ID0gNTEyOwot
ICAgICAgZW5kaWYKLSAgICAgIGlmIChuYXJnaW4gPCAyKQotICAgICAgICBh
ID0gMTsKLSAgICAgIGVuZGlmCi0gICAgZWxzZQotICAgICAgSHpGbGFnID0g
dHJ1ZTsKLSAgICBlbmRpZgotCi0gICAgaWYgKGlzZW1wdHkgKG5mZnQpKQot
ICAgICAgbmZmdCA9IDUxMjsKLSAgICBlbmRpZgotICAgIGlmICghIHN0cmNt
cCAod2hvbGUsICJ3aG9sZSIpKQotICAgICAgbmZmdCA9IDIqbmZmdDsKLSAg
ICBlbmRpZgotICAgIHcgPSBGcypbMDpuZmZ0LTFdL25mZnQ7CiAgIGVuZGlm
Ci0KLSAgaWYgKCEgSHpGbGFnKQotICAgIHcgPSB3ICogMiAqIHBpOwotICBl
bmRpZgotCi0gICMjIE1ha2Ugc3VyZSBib3RoIGFyZSByb3cgdmVjdG9yCisg
CisgICMgTWFrZSBzdXJlIGJvdGggYXJlIHJvdyB2ZWN0b3JzCiAgIGEgPSBh
KDopLic7CiAgIGIgPSBiKDopLic7CiAKQEAgLTE4MSwzNSArMTgxLDQ3IEBA
CiAgIGVuZGlmCiAgIG9jID0gb2EgKyBvYjsgICAgICAgICAgICMgb3JkZXIg
b2YgYyh6KQogCisgICMgQ2FsY3VsYXRlIHRoZSBncm91cCBkZWxheSBhcyBz
aG93biBpbiB0aGUgcmVmZXJlbmNlCiAgIGMgICA9IGNvbnYgKGIsIGZsaXBs
ciAoY29uaiAoYSkpKTsgICMgYyh6KSA9IGIoeikqY29uaihhKSgxL3opKnpe
KC1vYSkKICAgY3IgID0gYy4qKDA6b2MpOyAgICAgICAgICAgICAgICAgICAg
IyBjcih6KSA9IGRlcml2YXRpdmUgb2YgYyB3cnQgMS96Ci0gIG51bSA9IGZm
dCAoY3IsIG5mZnQpOwotICBkZW4gPSBmZnQgKGMsIG5mZnQpOwotICBtaW5t
YWcgICAgPSAxMCplcHM7Ci0gIHBvbGViaW5zICA9IGZpbmQgKGFicyAoZGVu
KSA8IG1pbm1hZyk7Ci0gIGZvciBiID0gcG9sZWJpbnMKLSAgICB3YXJuaW5n
ICgic2lnbmFsOmdycGRlbGF5LXNpbmd1bGFyaXR5IiwgImdycGRlbGF5OiBz
ZXR0aW5nIGdyb3VwIGRlbGF5IHRvIDAgYXQgc2luZ3VsYXJpdHkiKTsKLSAg
ICBudW0oYikgPSAwOwotICAgIGRlbihiKSA9IDE7Ci0gICAgIyMgdHJ5IHRv
IHByZXNlcnZlIGFuZ2xlOgotICAgICMjIGRiID0gZGVuKGIpOwotICAgICMj
IGRlbihiKSA9IG1pbm1hZyphYnMobnVtKGIpKSpleHAoaiphdGFuMihpbWFn
KGRiKSxyZWFsKGRiKSkpOwotICAgICMjIHdhcm5pbmcoc3ByaW50ZignZ3Jw
ZGVsYXk6IGRlbihiKSBjaGFuZ2VkIGZyb20gJWYgdG8gJWYnLGRiLGRlbihi
KSkpOwotICBlbmRmb3IKKyAgaWYgbmZmdF9pc19sZW5ndGgKKyAgICBudW0g
PSBmZnQgKGNyLCBuZmZ0KTsKKyAgICBkZW4gPSBmZnQgKGMsIG5mZnQpOwor
ICBlbHNlCisgICAgZXhwamt3ID0gZXhwKC1qKmtyb24oKDA6b2MpJyx3KSk7
CisgICAgbnVtID0gY3IqZXhwamt3OworICAgIGRlbiA9IGMqZXhwamt3Owor
ICBlbmRpZgorCisgICMgQ2hlY2sgZm9yIHNpbmd1bGFyaXRpZXMgaW4gdGhl
IGdyb3VwIGRlbGF5CisgIG1pbm1hZyAgPSAxMCplcHM7CisgIHBvbGViaW5z
ID0gZmluZCAoYWJzIChkZW4pIDwgbWlubWFnKTsKKyAgaWYgISBpc2VtcHR5
KHBvbGViaW5zKQorICAgIHdhcm5pbmcgKCJzaWduYWw6Z3JwZGVsYXktc2lu
Z3VsYXJpdHkiLAorICAgICAgICAgICAgICJncnBkZWxheTogc2V0dGluZyBn
cm91cCBkZWxheSB0byAwIGF0IHNpbmd1bGFyaXRpZXMiKTsKKyAgICBvYSA9
IG9hKm9uZXMoc2l6ZShudW0pKTsKKyAgICBvYShwb2xlYmlucykgPSAwOwor
ICAgIG51bShwb2xlYmlucykgPSAwOworICAgIGRlbihwb2xlYmlucykgPSAx
OworICBlbmRpZgogICBnZCA9IHJlYWwgKG51bSAuLyBkZW4pIC0gb2E7CiAK
LSAgaWYgKCEgc3RyY21wICh3aG9sZSwgIndob2xlIikpCisgICMgVHJpbSBn
ZAorICBpZiBuZmZ0X2lzX2xlbmd0aCAmJiAoISBzdHJjbXAgKHdob2xlLCAi
d2hvbGUiKSkKICAgICBucyA9IG5mZnQvMjsgIyBNYXRsYWIgY29udmVudGlv
biAuLi4gc2hvdWxkIGJlIG5mZnQvMiArIDEKICAgICBnZCA9IGdkKDE6bnMp
OwogICAgIHcgID0gdygxOm5zKTsKICAgZWxzZQotICAgIG5zID0gbmZmdDsg
IyB1c2VkIGluIHBsb3QgYmVsb3cKKyAgICBucyA9IGxlbmd0aCh3KTsgIyB1
c2VkIGluIHBsb3QgYmVsb3cKICAgZW5kaWYKIAotICAjIyBjb21wYXRpYmls
aXR5CisgICMgQ29tcGF0aWJpbGl0eQogICBnZCA9IGdkKDopOwotICB3ICA9
IHcoOik7Ci0KKyAgdyA9IHcoOik7CisgIGlmIEh6RmxhZworICAgIHcgPSBG
cyp3LygyKnBpKTsKKyAgZW5kaWYKKyAgCiAgIGlmIChuYXJnb3V0ID09IDAp
CiAgICAgdW53aW5kX3Byb3RlY3QKICAgICAgIGdyaWQgKCJvbiIpOyAjIGdy
aWQoKSBzaG91bGQgcmV0dXJuIGl0cyBwcmV2aW91cyBzdGF0ZQpAQCAtMzg0
LDMgKzM5Niw5MCBAQAogJSEgICAgICAgMC4wMTE1MDk4IDAuMDA5NTA1MSAw
LjAwNDM4NzRdOwogJSEgYXNzZXJ0IChudGhhcmdvdXQgKDE6MiwgQGdycGRl
bGF5LCBOLCAgRFIsICAxMDI0KSwKICUhICAgICAgICAgbnRoYXJnb3V0ICgx
OjIsIEBncnBkZWxheSwgTicsIERSJywgMTAyNCkpOworCisjIyB0ZXN0cyBm
b3IgYnVnICM0NTgzNCAodXNlIHZlY3RvciBvZiB3IG9yIEYgdmFsdWVzKQor
JSF0ZXN0CislISBbZ2Qsd10gPSBncnBkZWxheShbMSAxIDBdLCBbXSwgMCk7
CislISBhc3NlcnQgKGdkLDAuNSk7CislISBhc3NlcnQgKHcsMCk7CisKKyUh
dGVzdAorJSEgYSA9IFsxIDAgMC45XTsKKyUhIGIgPSBbMC45IDAgMV07Cisl
ISBbZ2QsIHddID0gZ3JwZGVsYXkoYiwgYSwgMCk7CisjIyBUaGUgZm9sbG93
aW5nIGZhaWxzIGZvciBuPTIgISEKKyUhIFtnZDIsIHcyXSA9IGdycGRlbGF5
KGIsIGEsIDIpOworJSEgW2dkNCwgdzRdID0gZ3JwZGVsYXkoYiwgYSwgNCk7
CislISBhc3NlcnQodyx3NCgxKSwxMDAwKmVwcyk7CislISBhc3NlcnQoZ2Qs
Z2Q0KDEpLDEwMDAqZXBzKTsKKworJSF0ZXN0CislISBhID0gWzEgMCAwLjld
OworJSEgYiA9IFswLjkgMCAxXTsKKyUhIFtnZCwgd10gPSBncnBkZWxheShi
LCBhLCAwLCAxMDAwKTsKKyMjIFRoZSBmb2xsb3dpbmcgZmFpbHMgZm9yIG49
MiAhIQorJSEgW2dkMiwgdzJdID0gZ3JwZGVsYXkoYiwgYSwgMiwgMTAwMCk7
CislISBbZ2Q0LCB3NF0gPSBncnBkZWxheShiLCBhLCA0LCAxMDAwKTsKKyUh
IGFzc2VydCh3LHc0KDEpLDEwMDAqZXBzKTsKKyUhIGFzc2VydChnZCxnZDQo
MSksMTAwMCplcHMpOworCislIXRlc3QKKyUhIERSPSBbMS4wMDAwMCAtMC4w
MDAwMCAtMy4zNzIxOSAwLjAwMDAwIC4uLgorJSEgICAgICA1LjQ1NzEwIC0w
LjAwMDAwIC01LjI0Mzk0IDAuMDAwMDAgLi4uCislISAgICAgIDMuMTIwNDkg
LTAuMDAwMDAgLTEuMDg3NzAgMC4wMDAwMCAwLjE3NDA0XTsKKyUhIE4gPSBb
LTAuMDEzOTQ2OSAtMC4wMjIyMzc2IDAuMDE3ODYzMSAwLjA0NTE3MzcgLi4u
CislISAgICAgICAwLjAwMTM5NjIgLTAuMDI1OTcxMiAwLjAwMTYzMzggMC4w
MTY1MTg5IC4uLgorJSEgICAgICAgMC4wMTE1MDk4IDAuMDA5NTA1MSAwLjAw
NDM4NzRdOworJSEgRj0oMC4xMDowLjAyOjAuMjApOworJSEgW2dkLCB3XSA9
IGdycGRlbGF5KE4sIERSLCAyKnBpKkYpOworJSEgW2dkMjUsIHcyNV0gPSBn
cnBkZWxheShOLCBEUiwgMjUpOworJSEgYXNzZXJ0ICh3LDIqcGkqRicsMTAq
ZXBzKTsKKyUhIGFzc2VydCAoZ2QsZ2QyNSg2OjExKSwxMDAwKmVwcyk7CisK
KyUhdGVzdAorJSEgRFI9IFsxLjAwMDAwIC0wLjAwMDAwIC0zLjM3MjE5IDAu
MDAwMDAgLi4uCislISAgICAgIDUuNDU3MTAgLTAuMDAwMDAgLTUuMjQzOTQg
MC4wMDAwMCAuLi4KKyUhICAgICAgMy4xMjA0OSAtMC4wMDAwMCAtMS4wODc3
MCAwLjAwMDAwIDAuMTc0MDRdOworJSEgTiA9IFstMC4wMTM5NDY5IC0wLjAy
MjIzNzYgMC4wMTc4NjMxIDAuMDQ1MTczNyAuLi4KKyUhICAgICAgIDAuMDAx
Mzk2MiAtMC4wMjU5NzEyIDAuMDAxNjMzOCAwLjAxNjUxODkgLi4uCislISAg
ICAgICAwLjAxMTUwOTggMC4wMDk1MDUxIDAuMDA0Mzg3NF07CislISBuPTI1
OworJSEgRnM9MTAwMDsKKyUhIEY9KDEwMDoyMDoyMDApOworJSEgW2dkRiwg
ZkZdID0gZ3JwZGVsYXkoTiwgRFIsIEYsIEZzKTsKKyUhIFtnZDI1LCB3MjVd
ID0gZ3JwZGVsYXkoTiwgRFIsIG4pOworJSEgW2dkMjVGLCBmMjVGXSA9IGdy
cGRlbGF5KE4sIERSLCBuLCBGcyk7CislISBhc3NlcnQgKGZGLEZzKncyNSg2
OjExKS8oMipwaSksMTAwMCplcHMpOworJSEgYXNzZXJ0IChmRixGJywxMDAw
KmVwcyk7CislISBhc3NlcnQgKGdkRixnZDI1KDY6MTEpLDEwMDAqZXBzKTsK
KyUhIGFzc2VydCAoZ2QyNSxnZDI1RiwxMDAwKmVwcyk7CisKKyUhdGVzdAor
JSEgRD0gWzEsIDAuOSwgMV07CislISBOID0gWzEsIDAuOV07CislISB3ID0g
cGkvNDsKKyUhIGdkID0gZ3JwZGVsYXkoTiwgRCwgdyk7CislISBbZ2Q0LHc0
XSA9IGdycGRlbGF5KE4sIEQsIDQpOworJSEgYXNzZXJ0ICh3LHc0KDIpLDEw
MDAqZXBzKTsKKyUhIGFzc2VydCAoZ2QsZ2Q0KDIpLDEwMDAqZXBzKTsKKwor
JSF0ZXN0CislISBEUj0gWzEuMDAwMDAgLTAuMDAwMDAgLTMuMzcyMTkgMC4w
MDAwMCAuLi4KKyUhICAgICAgNS40NTcxMCAtMC4wMDAwMCAtNS4yNDM5NCAw
LjAwMDAwIC4uLgorJSEgICAgICAzLjEyMDQ5IC0wLjAwMDAwIC0xLjA4Nzcw
IDAuMDAwMDAgMC4xNzQwNF07CislISBOID0gWy0wLjAxMzk0NjkgLTAuMDIy
MjM3NiAwLjAxNzg2MzEgMC4wNDUxNzM3IC4uLgorJSEgICAgICAgMC4wMDEz
OTYyIC0wLjAyNTk3MTIgMC4wMDE2MzM4IDAuMDE2NTE4OSAuLi4KKyUhICAg
ICAgIDAuMDExNTA5OCAwLjAwOTUwNTEgMC4wMDQzODc0XTsKKyUhIHcgPSBw
aS80OworJSEgZ2QgPSBncnBkZWxheShOLCBEUiwgdyk7CisjIyBUaGUgZm9s
bG93aW5nIGZhaWxzIGZvciBuPDEyICEhCislISBbZ2Q4LHc4XSA9IGdycGRl
bGF5KE4sIERSLCA4KTsKKyUhIFtnZDEyLHcxMl0gPSBncnBkZWxheShOLCBE
UiwgMTIpOworJSEgYXNzZXJ0ICh3LHcxMig0KSwxMDAwKmVwcyk7CislISBh
c3NlcnQgKGdkLGdkMTIoNCksMTAwMCplcHMpOworJSEgW2dkMTYsdzE2XSA9
IGdycGRlbGF5KE4sIERSLCAxNik7CislISBhc3NlcnQgKHcsdzE2KDUpLDEw
MDAqZXBzKTsKKyUhIGFzc2VydCAoZ2QsZ2QxNig1KSwxMDAwKmVwcyk7Cisl
ISBbZ2QyNTYsdzI1Nl0gPSBncnBkZWxheShOLCBEUiwgMjU2KTsKKyUhIGFz
c2VydCAodyx3MjU2KDY1KSwxMDAwKmVwcyk7CislISBhc3NlcnQgKGdkLGdk
MjU2KDY1KSwxMDAwKmVwcyk7Ci0tLSBzaWduYWwtMS40LjIvaW5zdC96cGxh
bmUubQkyMDIyLTA0LTIzIDIxOjIxOjI1LjAwMDAwMDAwMCArMTAwMAorKysg
c2lnbmFsLTEuNC4yLm5ldy9pbnN0L3pwbGFuZS5tCTIwMjItMDQtMjYgMTM6
NTg6NDcuNDcyNDkzOTc1ICsxMDAwCkBAIC0xMTUsOCArMTE1LDkgQEAKICAg
ICAgIGZvciBpID0gMTpsZW5ndGggKHhfdSkKICAgICAgICAgbiA9IHN1bSAo
eF91KGkpID09IHgoOixjKSk7CiAgICAgICAgIGlmIChuID4gMSkKLSAgICAg
ICAgICBsYWJlbCA9IHNwcmludGYgKCIgXiVkIiwgbik7Ci0gICAgICAgICAg
dGV4dCAocmVhbCAoeF91KGkpKSwgaW1hZyAoeF91KGkpKSwgbGFiZWwsICJj
b2xvciIsIGNvbG9yKTsKKyAgICAgICAgICBsYWJlbCA9IHNwcmludGYgKCIl
ZCIsIG4pOworICAgICAgICAgIHRleHQgKHJlYWwgKHhfdShpKSksIGltYWcg
KHhfdShpKSksIGxhYmVsLCAiY29sb3IiLCBjb2xvciwgLi4uCisgICAgICAg
ICAgICAgICAgInZlcnRpY2FsYWxpZ25tZW50IiwgImJvdHRvbSIsICJob3Jp
em9udGFsYWxpZ25tZW50IiwgImxlZnQiKTsKICAgICAgICAgZW5kaWYKICAg
ICAgIGVuZGZvcgogICAgIGVuZGZvcgo=
====
EOF
uudecode signal-$SIGNAL_VER.patch.uue > signal-$SIGNAL_VER.patch
tar -xf $SIGNAL_ARCHIVE
pushd signal-$SIGNAL_VER
patch -p1 < ../signal-$SIGNAL_VER.patch
popd
NEW_SIGNAL_ARCHIVE=signal-$SIGNAL_VER".new.tar.gz"
tar -czf $NEW_SIGNAL_ARCHIVE signal-$SIGNAL_VER
rm -Rf signal-$SIGNAL_VER signal-$SIGNAL_VER.patch.uue signal-$SIGNAL_VER.patch

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_SIGNAL_ARCHIVE
rm -f $NEW_SIGNAL_ARCHIVE


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
if ! test -f sedumi-master.zip ; then
  wget -c $GITHUB_URL/sedumi/archive/master.zip
  mv -f master.zip sedumi-master.zip
fi
rm -Rf sedumi-master $OCTAVE_SITE_M_DIR/SeDuMi
unzip sedumi-master.zip
rm -f sedumi-master/vec.m
rm -f sedumi-master/*.mex*
mv -f sedumi-master $OCTAVE_SITE_M_DIR/SeDuMi
if test $? -ne 0;then rm -Rf sedumi-master; exit -1; fi
$OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SeDuMi/install_sedumi.m

# Install SDPT3
if ! test -f sdpt3-master.zip ; then
  wget -c $GITHUB_URL/sdpt3/archive/master.zip
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
  wget -c $GITHUB_URL/YALMIP/archive/develop.zip
  mv develop.zip YALMIP-develop.zip
fi
rm -Rf YALMIP-develop $OCTAVE_SITE_M_DIR/YALMIP
unzip YALMIP-develop.zip 
mv YALMIP-develop $OCTAVE_SITE_M_DIR/YALMIP
if test $? -ne 0;then rm -Rf YALMIP-develop; exit -1; fi

# Install SparsePOP
if ! test -f SparsePOP-master.zip ; then
  wget -c $GITHUB_URL/SparsePOP/archive/master.zip
  mv master.zip SparsePOP-master.zip
fi
rm -Rf SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
unzip SparsePOP-master.zip
find SparsePOP-master -name \*.mex* -exec rm -f {} ';'
mv SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
if test $? -ne 0;then rm -Rf SparsePOP-master; exit -1; fi
# !! Do not build the SparsePOP .mex files !!
# $OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SparsePOP/compileSparsePOP.m

#
# Solver installation done
#
