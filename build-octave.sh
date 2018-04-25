#!/bin/sh

LAPACK_VER=3.8.0
SUITESPARSE_VER=4.5.6
FFTW_VER=3.3.7
GLPK_VER=4.65
QRUPDATE_VER=1.1.2
OCTAVE_VER=4.2.2
STRUCT_VER=1.0.14
OPTIM_VER=1.5.2
CONTROL_VER=3.1.0
SIGNAL_VER=1.3.2
PARALLEL_VER=3.1.1

# Assume these files are present:
LAPACK_ARCHIVE=lapack-$LAPACK_VER".tar.gz"
SUITESPARSE_ARCHIVE=SuiteSparse-$SUITESPARSE_VER".tar.gz"
ARPACK_ARCHIVE=arpack-ng-master.zip
FFTW_ARCHIVE=fftw-$FFTW_VER".tar.gz"
GLPK_ARCHIVE=glpk-$GLPK_VER".tar.gz"
QRUPDATE_ARCHIVE=qrupdate-$QRUPDATE_VER".tar.gz"
OCTAVE_ARCHIVE=octave-$OCTAVE_VER".tar.lz"
STRUCT_ARCHIVE=struct-$STRUCT_VER".tar.gz"
OPTIM_ARCHIVE=optim-$OPTIM_VER".tar.gz"
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".tar.gz"

OCTAVE_DIR=/usr/local/octave
OCTAVE_INCLUDE_DIR=$OCTAVE_DIR/include
OCTAVE_LIB_DIR=$OCTAVE_DIR/lib
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin

export LD_LIBRARY_PATH=$OCTAVE_LIB_DIR
export LDFLAGS=-L$OCTAVE_LIB_DIR
export PATH=$PATH:$OCTAVE_BIN_DIR

#
# !?!WARNING!?!
#
# Starting from scratch!
#
rm -Rf $OCTAVE_DIR

#
# Build lapack
#
rm -Rf lapack-$LAPACK_VER
tar -xf $LAPACK_ARCHIVE
cat > lapack-$LAPACK_VER".patch.uue" << 'EOF'
begin-base64 644 lapack-3.8.0.patch
LS0tIGxhcGFjay0zLjguMC9tYWtlLmluYy5leGFtcGxlCTIwMTctMTEtMTMg
MTU6MTU6NTQuMDAwMDAwMDAwICsxMTAwCisrKyBsYXBhY2stMy44LjAubW9k
L21ha2UuaW5jLmV4YW1wbGUJMjAxOC0wMi0xNyAwODo0ODoyMS4wMjEwMjE5
NzMgKzExMDAKQEAgLTksNyArOSw4IEBACiAjICBDQyBpcyB0aGUgQyBjb21w
aWxlciwgbm9ybWFsbHkgaW52b2tlZCB3aXRoIG9wdGlvbnMgQ0ZMQUdTLgog
IwogQ0MgICAgID0gZ2NjCi1DRkxBR1MgPSAtTzMKK0JMRE9QVFMgPSAtZlBJ
QyAtbTY0IC1tdHVuZT1nZW5lcmljCitDRkxBR1MgPSAtTzMgJChCTERPUFRT
KQogCiAjICBNb2RpZnkgdGhlIEZPUlRSQU4gYW5kIE9QVFMgZGVmaW5pdGlv
bnMgdG8gcmVmZXIgdG8gdGhlIGNvbXBpbGVyCiAjICBhbmQgZGVzaXJlZCBj
b21waWxlciBvcHRpb25zIGZvciB5b3VyIG1hY2hpbmUuICBOT09QVCByZWZl
cnMgdG8KQEAgLTE5LDE1ICsyMCwxNSBAQAogIyAgYW5kIGhhbmRsZSB0aGVz
ZSBxdWFudGl0aWVzIGFwcHJvcHJpYXRlbHkuIEFzIGEgY29uc2VxdWVuY2Us
IG9uZQogIyAgc2hvdWxkIG5vdCBjb21waWxlIExBUEFDSyB3aXRoIGZsYWdz
IHN1Y2ggYXMgLWZmcGUtdHJhcD1vdmVyZmxvdy4KICMKLUZPUlRSQU4gPSBn
Zm9ydHJhbgotT1BUUyAgICA9IC1PMiAtZnJlY3Vyc2l2ZQorRk9SVFJBTiA9
IGdmb3J0cmFuIC1mcmVjdXJzaXZlICQoQkxET1BUUykKK09QVFMgICAgPSAt
TzIKIERSVk9QVFMgPSAkKE9QVFMpCi1OT09QVCAgID0gLU8wIC1mcmVjdXJz
aXZlCitOT09QVCAgID0gLU8wCiAKICMgIERlZmluZSBMT0FERVIgYW5kIExP
QURPUFRTIHRvIHJlZmVyIHRvIHRoZSBsb2FkZXIgYW5kIGRlc2lyZWQKICMg
IGxvYWQgb3B0aW9ucyBmb3IgeW91ciBtYWNoaW5lLgogIwotTE9BREVSICAg
PSBnZm9ydHJhbgorTE9BREVSICAgPSAkKEZPUlRSQU4pCiBMT0FET1BUUyA9
CiAKICMgIFRoZSBhcmNoaXZlciBhbmQgdGhlIGZsYWcocykgdG8gdXNlIHdo
ZW4gYnVpbGRpbmcgYW4gYXJjaGl2ZQpAQCAtNTksNyArNjAsNyBAQAogIyAg
VW5jb21tZW50IHRoZSBmb2xsb3dpbmcgbGluZSB0byBpbmNsdWRlIGRlcHJl
Y2F0ZWQgcm91dGluZXMgaW4KICMgIHRoZSBMQVBBQ0sgbGlicmFyeS4KICMK
LSNCVUlMRF9ERVBSRUNBVEVEID0gWWVzCitCVUlMRF9ERVBSRUNBVEVEID0g
WWVzCiAKICMgIExBUEFDS0UgaGFzIHRoZSBpbnRlcmZhY2UgdG8gc29tZSBy
b3V0aW5lcyBmcm9tIHRtZ2xpYi4KICMgIElmIExBUEFDS0VfV0lUSF9UTUcg
aXMgZGVmaW5lZCwgYWRkIHRob3NlIHJvdXRpbmVzIHRvIExBUEFDS0UuCkBA
IC03OCw3ICs3OSw3IEBACiAjICBtYWNoaW5lLXNwZWNpZmljLCBvcHRpbWl6
ZWQgQkxBUyBsaWJyYXJ5IHNob3VsZCBiZSB1c2VkIHdoZW5ldmVyCiAjICBw
b3NzaWJsZS4pCiAjCi1CTEFTTElCICAgICAgPSAuLi8uLi9saWJyZWZibGFz
LmEKK0JMQVNMSUIgICAgICA9IC4uLy4uL2xpYmJsYXMuYQogQ0JMQVNMSUIg
ICAgID0gLi4vLi4vbGliY2JsYXMuYQogTEFQQUNLTElCICAgID0gbGlibGFw
YWNrLmEKIFRNR0xJQiAgICAgICA9IGxpYnRtZ2xpYi5hCi0tLSBsYXBhY2st
My44LjAvU1JDL01ha2VmaWxlCTIwMTctMTEtMTMgMTU6MTU6NTQuMDAwMDAw
MDAwICsxMTAwCisrKyBsYXBhY2stMy44LjAubW9kL1NSQy9NYWtlZmlsZQky
MDE4LTAyLTE3IDA4OjQ4OjIxLjE3NTAyMDYxNSArMTEwMApAQCAtNTE0LDgg
KzUxNCwxMiBAQAogCiBhbGw6IC4uLyQoTEFQQUNLTElCKQogCitsaWJsYXBh
Y2suc286ICQoQUxMT0JKKSAkKEFMTFhPQkopICQoREVQUkVDQVRFRCkKKwkk
KEZPUlRSQU4pIC1zaGFyZWQgLVdsLC1zb25hbWUsJEAgLW8gJEAgJChBTExP
QkopICQoQUxMWE9CSikgJChERVBSRUNBVEVEKQorCWNwIC1mIGxpYmxhcGFj
ay5zbyAuLiA7CisKIC4uLyQoTEFQQUNLTElCKTogJChBTExPQkopICQoQUxM
WE9CSikgJChERVBSRUNBVEVEKQotCSQoQVJDSCkgJChBUkNIRkxBR1MpICRA
ICReCisJJChBUkNIKSAkKEFSQ0hGTEFHUykgJEAgJChBTExPQkopICQoQUxM
WE9CSikgJChERVBSRUNBVEVEKQogCSQoUkFOTElCKSAkQAogCiBzaW5nbGU6
ICQoU0xBU1JDKSAkKERTTEFTUkMpICQoU1hMQVNSQykgJChTQ0xBVVgpICQo
QUxMQVVYKQotLS0gbGFwYWNrLTMuOC4wL0JMQVMvU1JDL01ha2VmaWxlCTIw
MTctMTEtMTMgMTU6MTU6NTQuMDAwMDAwMDAwICsxMTAwCisrKyBsYXBhY2st
My44LjAubW9kL0JMQVMvU1JDL01ha2VmaWxlCTIwMTgtMDItMTcgMDg6NDg6
MjEuMTc1MDIwNjE1ICsxMTAwCkBAIC01Nyw2ICs1NywxMCBAQAogCiBhbGw6
ICQoQkxBU0xJQikKIAorbGliYmxhcy5zbzogJChBTExPQkopCisJJChGT1JU
UkFOKSAtc2hhcmVkIC1XbCwtc29uYW1lLCRAIC1vICRAICQoQUxMT0JKKQor
CWNwIC1mIGxpYmJsYXMuc28gLi4vLi4gOworCiAjLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCiAj
ICBDb21tZW50IG91dCB0aGUgbmV4dCA2IGRlZmluaXRpb25zIGlmIHlvdSBh
bHJlYWR5IGhhdmUKICMgIHRoZSBMZXZlbCAxIEJMQVMuCg==
====
EOF

# Patch
uudecode lapack-$LAPACK_VER.patch.uue > lapack-$LAPACK_VER.patch
tar -xf $LAPACK_ARCHIVE
pushd lapack-$LAPACK_VER
patch -p1 < ../lapack-$LAPACK_VER.patch
cp make.inc.example make.inc
popd
# Make libblas.so
pushd lapack-$LAPACK_VER/BLAS/SRC
make && make libblas.so
mkdir -p $OCTAVE_LIB_DIR
cp libblas.so $OCTAVE_LIB_DIR
popd
# Make liblapack.so
pushd lapack-$LAPACK_VER/SRC
make liblapack.so
cp liblapack.so $OCTAVE_LIB_DIR
popd

#
# Build arpack-ng
#
rm -Rf arpack-ng-master
unzip arpack-ng-master.zip
pushd arpack-ng-master
sh ./bootstrap
./configure --prefix=$OCTAVE_DIR --with-blas=-lblas --with-lapack=-llapack
make && make install
popd

#
# Build SuiteSparse
#
rm -Rf SuiteSparse
tar -xf $SUITESPARSE_ARCHIVE
pushd SuiteSparse
make INSTALL=$OCTAVE_DIR OPTIMIZATION=-O2 BLAS=-lblas install
popd

#
# Build qrupdate
#
rm -Rf qrupdate-$QRUPDATE_VER
tar -xf $QRUPDATE_ARCHIVE
pushd qrupdate-1.1.2
rm -f Makeconf
cat > Makeconf << 'EOF'
FC=gfortran
FFLAGS=-fimplicit-none -O2 -funroll-loops 
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

#
# Build glpk
#
rm -Rf glpk-$GLPK_VER
tar -xf $GLPK_ARCHIVE
pushd glpk-$GLPK_VER
./configure --prefix=$OCTAVE_DIR
make -j 6 && make install
popd

#
# Build fftw
#
rm -Rf fftw-$FFTW_VER
tar -xf $FFTW_ARCHIVE
pushd fftw-$FFTW_VER
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads
make -j 6 && make install
popd

#
# Build fftw single-precision
#
rm -Rf fftw-$FFTW_VER
tar -xf $FFTW_ARCHIVE
pushd fftw-$FFTW_VER
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd

#
# Build octave
#
rm -Rf octave-$OCTAVE_VER
tar -xf $OCTAVE_ARCHIVE
rm -Rf build
mkdir build
pushd build
OPTFLAGS="-m64 -mtune=generic -O2"
export CFLAGS=$OPTFLAGS" -std=c11 -I"$OCTAVE_INCLUDE_DIR
export CXXFLAGS=$OPTFLAGS" -std=c++11 -I"$OCTAVE_INCLUDE_DIR
export FFLAGS=$OPTFLAGS
export LDFLAGS=-L$OCTAVE_LIB_DIR
../octave-$OCTAVE_VER/configure --prefix=$OCTAVE_DIR \
                          --disable-java \
                          --disable-atomic-refcount \
                          --without-fltk \
                          --without-qt \
                          --without-sndfile \
                          --without-portaudio \
                          --without-qhull \
                          --without-magick \
                          --without-hdf5 \
                          --with-blas=-lblas \
                          --with-lapack=-llapack \
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
                          --with-fftw3f-libdir=$OCTAVE_LIB_DIR

#
# Add --enable-address-sanitizer-flags for sanitizer build
#

#
# Generate profile
#
export PGO_GEN_FLAGS="-fprofile-generate"
export PGO_LTO_FLAGS="-fprofile-use -flto=6 -ffat-lto-objects"
make XTRA_CFLAGS=$PGO_GEN_FLAGS XTRA_CXXFLAGS=$PGO_GEN_FLAGS V=1 -j6
find . -name \*.gcda -exec rm -f {} ';'
make check

#
# Use profile
#
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
make install

#
# Done
#
popd

#
# Install packages
#
$OCTAVE_BIN_DIR/octave-cli \
  --eval "pkg install "$STRUCT_ARCHIVE" ; ...
          pkg install "$OPTIM_ARCHIVE" ; ...
          pkg install "$CONTROL_ARCHIVE" ; ...
          pkg install "$SIGNAL_ARCHIVE" ; ...
          pkg install "$PARALLEL_ARCHIVE" ; ...
          pkg list"
