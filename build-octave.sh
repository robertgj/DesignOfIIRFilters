#!/bin/sh

# Build a local version of octave-cli
#
# Requires wget, gnuplot-latex, readline-devel, lzip, sharutils, gfortran
# cmake and ???
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
#   gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 5D36644B
# then verify the .sig file with (for example):
#   gpg2 --verify octave-5.2.0.tar.lz.sig
#
# Assume these files are present. Get them if they are not.
#
LAPACK_VER=${LAPACK_VER:-3.8.0}
LAPACK_ARCHIVE=lapack-$LAPACK_VER".tar.gz"
LAPACK_URL=http://www.netlib.org/lapack/$LAPACK_ARCHIVE
if ! test -f $LAPACK_ARCHIVE; then
  wget -c $LAPACK_URL
fi

ARPACK_ARCHIVE=master.zip
ARPACK_URL=https://github.com/opencollab/arpack-ng/archive/$ARPACK_ARCHIVE
if ! test -f $ARPACK_ARCHIVE; then
  wget -c $ARPACK_URL
fi

SUITESPARSE_VER=${SUITESPARSE_VER:-4.5.6}
SUITESPARSE_ARCHIVE=SuiteSparse-$SUITESPARSE_VER".tar.gz"
SUITESPARSE_URL=http://faculty.cse.tamu.edu/davis/SuiteSparse/$SUITESPARSE_ARCHIVE
if ! test -f $SUITESPARSE_ARCHIVE; then
  wget -c $SUITESPARSE_URL
fi

QRUPDATE_VER=${QRUPDATE_VER:-1.1.2}
QRUPDATE_ARCHIVE=qrupdate-$QRUPDATE_VER".tar.gz"
QRUPDATE_URL=https://sourceforge.net/projects/qrupdate/files/qrupdate/1.2/$QRUPDATE_ARCHIVE
if ! test -f $QRUPDATE_ARCHIVE; then
  wget -c $QRUPDATE_URL
fi

FFTW_VER=${FFTW_VER:-3.3.8}
FFTW_ARCHIVE=fftw-$FFTW_VER".tar.gz"
FFTW_URL=ftp://ftp.fftw.org/pub/fftw/$FFTW_ARCHIVE
if ! test -f $FFTW_ARCHIVE; then
  wget -c $FFTW_URL
fi

GLPK_VER=${GLPK_VER:-4.65}
GLPK_ARCHIVE=glpk-$GLPK_VER".tar.gz"
GLPK_URL=https://ftp.gnu.org/gnu/glpk/$GLPK_ARCHIVE
if ! test -f $GLPK_ARCHIVE; then
  wget -c $GLPK_URL
fi

OCTAVE_VER=${OCTAVE_VER:-"5.2.0"}
OCTAVE_ARCHIVE=octave-$OCTAVE_VER".tar.lz"
OCTAVE_URL=https://ftp.gnu.org/gnu/octave/$OCTAVE_ARCHIVE
if ! test -f $OCTAVE_ARCHIVE; then
  wget -c $OCTAVE_URL
fi

#
# Get octave-forge packages
#
OCTAVE_FORGE_URL=https://sourceforge.net/projects/octave/files/\
Octave%20\Forge%20Packages/Individual%20Package%20Releases/

IO_VER=${IO_VER:-2.4.12}
IO_ARCHIVE=io-$IO_VER".tar.gz"
IO_URL=$OCTAVE_FORGE_URL$IO_ARCHIVE
if ! test -f $IO_ARCHIVE; then
    wget -c $IO_URL
fi

STATISTICS_VER=${STATISTICS_VER:-1.4.1}
STATISTICS_ARCHIVE=statistics-$STATISTICS_VER".tar.gz"
STATISTICS_URL=$OCTAVE_FORGE_URL$STATISTICS_ARCHIVE
if ! test -f $STATISTICS_ARCHIVE; then
    wget -c $STATISTICS_URL
fi

STRUCT_VER=${STRUCT_VER:-1.0.16}
STRUCT_ARCHIVE=struct-$STRUCT_VER".tar.gz"
STRUCT_URL=$OCTAVE_FORGE_URL$STRUCT_ARCHIVE
if ! test -f $STRUCT_ARCHIVE; then
    wget -c $STRUCT_URL 
fi

OPTIM_VER=${OPTIM_VER:-1.6.0}
OPTIM_ARCHIVE=optim-$OPTIM_VER".tar.gz"
OPTIM_URL=$OCTAVE_FORGE_URL$OPTIM_ARCHIVE
if ! test -f $OPTIM_ARCHIVE; then
    wget -c $OPTIM_URL 
fi

CONTROL_VER=${CONTROL_VER:-3.2.0}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL=$OCTAVE_FORGE_URL$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
    wget -c $CONTROL_URL 
fi

SIGNAL_VER=${SIGNAL_VER:-1.4.1}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=$OCTAVE_FORGE_URL$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
    wget -c $SIGNAL_URL 
fi

PARALLEL_VER=${PARALLEL_VER:-3.1.3}
PARALLEL_ARCHIVE=parallel-$PARALLEL_VER".tar.gz"
PARALLEL_URL=$OCTAVE_FORGE_URL$PARALLEL_ARCHIVE
if ! test -f $PARALLEL_ARCHIVE; then
    wget -c $PARALLEL_URL 
fi

SYMBOLIC_VER=${SYMBOLIC_VER:-2.9.0}
SYMBOLIC_ARCHIVE=symbolic-$SYMBOLIC_VER".tar.gz"
SYMBOLIC_URL=$OCTAVE_FORGE_URL$SYMBOLIC_ARCHIVE
if ! test -f $SYMBOLIC_ARCHIVE; then
    wget -c $SYMBOLIC_URL 
fi

#
# Octave directories
#
OCTAVE_DIR=${OCTAVE_DIR:-"/usr/local/octave"}-$OCTAVE_VER
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
echo "Building octave-"$OCTAVE_VER

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
unzip $ARPACK_ARCHIVE
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
pushd qrupdate-$QRUPDATE_VER
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
# Patch
cat > octave-$OCTAVE_VER".patch.uue" << 'EOF'
begin-base64 644 octave-5.2.0.patch
LS0tIC4vc2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0ZS9fX2dudXBsb3RfZHJh
d19heGVzX18ubQkyMDIwLTAxLTI4IDEyOjU3OjM1LjAwMDAwMDAwMCArMTEw
MAorKysgLi4vb2N0YXZlLTUuMi4wLm5ldy8uL3NjcmlwdHMvcGxvdC91dGls
L3ByaXZhdGUvX19nbnVwbG90X2RyYXdfYXhlc19fLm0JMjAyMC0wNC0wNSAx
MTo0MzozMi4xNzg2ODY1ODcgKzEwMDAKQEAgLTIyNTQsNyArMjI1NCw4IEBA
CiAgICAgZW5kZm9yCiAgIGVsc2VpZiAoc3RyY21wIChpbnRlcnByZXRlciwg
ImxhdGV4IikpCiAgICAgaWYgKCEgd2FybmVkX2xhdGV4KQotICAgICAgd2Fy
bmluZyAoImxhdGV4IG1hcmt1cCBub3Qgc3VwcG9ydGVkIGZvciB0aWNrIG1h
cmtzIik7CisgICAgICB3YXJuaW5nICgiT2N0YXZlOmxhdGV4LW1hcmt1cC1u
b3Qtc3VwcG9ydGVkLWZvci10aWNrLW1hcmtzIiwKKwkgICAgICAgImxhdGV4
IG1hcmt1cCBub3Qgc3VwcG9ydGVkIGZvciB0aWNrIG1hcmtzIik7CiAgICAg
ICB3YXJuZWRfbGF0ZXggPSB0cnVlOwogICAgIGVuZGlmCiAgIGVuZGlmCi0t
LSAuL3NjcmlwdHMvbWlzY2VsbGFuZW91cy9kZWxldGUubQkyMDIwLTAxLTI4
IDEyOjU3OjM1LjAwMDAwMDAwMCArMTEwMAorKysgLi4vb2N0YXZlLTUuMi4w
Lm5ldy8uL3NjcmlwdHMvbWlzY2VsbGFuZW91cy9kZWxldGUubQkyMDIwLTA0
LTA1IDExOjQzOjU0LjY4OTQ5NTY2MCArMTAwMApAQCAtNDQsNyArNDQsOCBA
QAogICAgIGZvciBhcmcgPSB2YXJhcmdpbgogICAgICAgZmlsZXMgPSBnbG9i
IChhcmd7MX0pOwogICAgICAgaWYgKGlzZW1wdHkgKGZpbGVzKSkKLSAgICAg
ICAgd2FybmluZyAoImRlbGV0ZTogbm8gc3VjaCBmaWxlOiAlcyIsIGFyZ3sx
fSk7CisgICAgICAgIHdhcm5pbmcgKCJPY3RhdmU6ZGVsZXRlLW5vLXN1Y2gt
ZmlsZSIsCisJICAgICAgICAgImRlbGV0ZTogbm8gc3VjaCBmaWxlOiAlcyIs
IGFyZ3sxfSk7CiAgICAgICBlbmRpZgogICAgICAgZm9yIGkgPSAxOmxlbmd0
aCAoZmlsZXMpCiAgICAgICAgIGZpbGUgPSBmaWxlc3tpfTsK
====
EOF
uudecode octave-$OCTAVE_VER.patch.uue > octave-$OCTAVE_VER.patch
pushd octave-$OCTAVE_VER
patch -p1 < ../octave-$OCTAVE_VER.patch
popd
# Build
rm -Rf build
mkdir build
pushd build
OPTFLAGS="-m64 -mtune=generic -O2"
export CFLAGS=$OPTFLAGS" -std=c11 -I"$OCTAVE_INCLUDE_DIR
export CXXFLAGS=$OPTFLAGS" -std=c++11 -I"$OCTAVE_INCLUDE_DIR
export FFLAGS=$OPTFLAGS
export LDFLAGS="-L"$OCTAVE_LIB_DIR
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
export PGO_LTO_FLAGS="-pthread -fopenmp -fprofile-use -flto=6 -ffat-lto-objects"
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
make install

#
# Done
#
popd

#
# Fix parallel-3.1.3 package
#
cat > parallel-3.1.3.patch.uue << 'EOF'
begin-base64 644 parallel-3.1.3.patch
LS0tIC4vc3JjL3BzZXJ2ZXIuY2MJMjAxOC0wOC0wMyAxNzo0MTo0Mi41NzA0
NzgyMDcgKzEwMDAKKysrIC4uL3BhcmFsbGVsLTMuMS4zLm5ldy8uL3NyYy9w
c2VydmVyLmNjCTIwMTktMDQtMTUgMTI6MjA6MDUuMDAwMDAwMDAwICsxMDAw
CkBAIC0xNjksNyArMTY5LDcgQEAKICAgICAgICAgICBpZiAob2N0YXZlX2Nv
bXBsZXRpb25fbWF0Y2hlc19jYWxsZWQpCiAgICAgICAgICAgICBvY3RhdmVf
Y29tcGxldGlvbl9tYXRjaGVzX2NhbGxlZCA9IGZhbHNlOwogICAgICAgICAg
IGVsc2UKLSAgICAgICAgICAgIGNvbW1hbmRfZWRpdG9yOjppbmNyZW1lbnRf
Y3VycmVudF9jb21tYW5kX251bWJlciAoKTsKKyAgICAgICAgICAgIG9jdGF2
ZTo6Y29tbWFuZF9lZGl0b3I6OmNvbW1hbmRfZWRpdG9yOjppbmNyZW1lbnRf
Y3VycmVudF9jb21tYW5kX251bWJlciAoKTsKICAgICAgICAgICBkc3ByaW50
ZiAoInJldmFsIGxvb3AsIG5vIGVycm9yLCBhZnRlciBjYXJpbmcgZm9yIE9j
dGF2ZSBjb21tYW5kIG51bWJlclxuIik7CiAgICAgICAgIH0KICAgICB9CkBA
IC0xMTE2LDEwICsxMTE2LDEwIEBACiAgICAgICAgICAgT0NUQVZFX19JTlRF
UlBSRVRFUl9fU1lNQk9MX1RBQkxFX19BU1NJR04gKCJzb2NrZXRzIiwgc29j
a2V0cyk7CiAgICAgICAgICAgZHNwcmludGYgKCInc29ja2V0cycgaW5zdGFs
bGVkXG4iKTsKIAotICAgICAgICAgIGludCBjZF9vayA9IG9jdGF2ZV9lbnY6
OmNoZGlyIChkaXJlY3RvcnkuY19zdHIgKCkpOworICAgICAgICAgIGludCBj
ZF9vayA9IG9jdGF2ZTo6c3lzOjplbnY6OmNoZGlyIChkaXJlY3RvcnkuY19z
dHIgKCkpOwogICAgICAgICAgIGlmICghIGNkX29rKQogICAgICAgICAgICAg
ewotICAgICAgICAgICAgb2N0YXZlX2Vudjo6Y2hkaXIgKCIvdG1wIik7CisJ
ICAgICAgb2N0YXZlOjpzeXM6OmVudjo6Y2hkaXIgKCIvdG1wIik7CiAgICAg
ICAgICAgICBkc3ByaW50ZiAoInBlcmZvcm1lZCBjaGRpciB0byAvdG1wXG4i
KTsKICAgICAgICAgICAgIH0KICAgICAgICAgICBlbHNlCi0tLSAuL3NyYy9l
cnJvci1oZWxwZXJzLmNjCTIwMTgtMDgtMDMgMTc6NDE6NDIuNTM0NDc3NDk2
ICsxMDAwCisrKyAuLi9wYXJhbGxlbC0zLjEuMy5uZXcvLi9zcmMvZXJyb3It
aGVscGVycy5jYwkyMDE5LTA0LTE1IDExOjA5OjA5LjAwMDAwMDAwMCArMTAw
MApAQCAtMTYsNiArMTYsNyBAQAogYWxvbmcgd2l0aCB0aGlzIHByb2dyYW07
IElmIG5vdCwgc2VlIDxodHRwOi8vd3d3LmdudS5vcmcvbGljZW5zZXMvPi4K
IAogKi8KKyNpbmNsdWRlIDxpb3N0cmVhbT4KIAogI2luY2x1ZGUgPG9jdGF2
ZS9vY3QuaD4KIApAQCAtNTAsNyArNTEsNyBAQAogCiAgIHN0ZDo6b3N0cmlu
Z3N0cmVhbSBvdXRwdXRfYnVmOwogCi0gIG9jdGF2ZV92Zm9ybWF0IChvdXRw
dXRfYnVmLCBmbXQsIGFyZ3MpOworICBvY3RhdmU6OnZmb3JtYXQgKG91dHB1
dF9idWYsIGZtdCwgYXJncyk7CiAKICAgc3RkOjpzdHJpbmcgbXNnID0gb3V0
cHV0X2J1Zi5zdHIgKCk7CiAKLS0tIC4vc3JjL2FjbG9jYWwubTQJMjAxOC0w
OC0wMyAxNzo0MTo0NC4yNDI1MTEyMjEgKzEwMDAKKysrIC4uL3BhcmFsbGVs
LTMuMS4zLm5ldy8uL3NyYy9hY2xvY2FsLm00CTIwMTktMDQtMTUgMTI6MDk6
MDcuMDAwMDAwMDAwICsxMDAwCkBAIC0xLDYgKzEsNiBAQAotIyBnZW5lcmF0
ZWQgYXV0b21hdGljYWxseSBieSBhY2xvY2FsIDEuMTUgLSotIEF1dG9jb25m
IC0qLQorIyBnZW5lcmF0ZWQgYXV0b21hdGljYWxseSBieSBhY2xvY2FsIDEu
MTYuMSAtKi0gQXV0b2NvbmYgLSotCiAKLSMgQ29weXJpZ2h0IChDKSAxOTk2
LTIwMTQgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLCBJbmMuCisjIENvcHly
aWdodCAoQykgMTk5Ni0yMDE4IEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwg
SW5jLgogCiAjIFRoaXMgZmlsZSBpcyBmcmVlIHNvZnR3YXJlOyB0aGUgRnJl
ZSBTb2Z0d2FyZSBGb3VuZGF0aW9uCiAjIGdpdmVzIHVubGltaXRlZCBwZXJt
aXNzaW9uIHRvIGNvcHkgYW5kL29yIGRpc3RyaWJ1dGUgaXQsCi0tLSAuL3Ny
Yy9wY29ubmVjdC5jYwkyMDE4LTA4LTAzIDE3OjQxOjQyLjU3MDQ3ODIwNyAr
MTAwMAorKysgLi4vcGFyYWxsZWwtMy4xLjMubmV3Ly4vc3JjL3Bjb25uZWN0
LmNjCTIwMTktMDQtMTUgMTA6Mzg6MTEuMDAwMDAwMDAwICsxMDAwCkBAIC01
MzMsNyArNTMzLDcgQEAKICAgICAgICAgICAgICAgZGNwcmludGYgKCJob3N0
bmFtZSAlaSB3cml0dGVuICglcylcbiIsIGosIGhvc3RzKGopLmNfc3RyICgp
KTsKICAgICAgICAgICAgIH0KIAotICAgICAgICAgIHN0ZDo6c3RyaW5nIGRp
cmVjdG9yeSA9IG9jdGF2ZV9lbnY6OmdldF9jdXJyZW50X2RpcmVjdG9yeSAo
KTsKKyAgICAgICAgICBzdGQ6OnN0cmluZyBkaXJlY3RvcnkgPSBvY3RhdmU6
OnN5czo6ZW52OjpnZXRfY3VycmVudF9kaXJlY3RvcnkgKCk7CiAKICAgICAg
ICAgICBjb25uLT5nZXRfY21kX3N0cmVhbSAoKS0+bmV0d29ya19zZW5kX3N0
cmluZyAoZGlyZWN0b3J5LmNfc3RyICgpKTsKICAgICAgICAgICBkY3ByaW50
ZiAoImRpcmVjdG9yeSB3cml0dGVuICglcylcbiIsIGRpcmVjdG9yeS5jX3N0
ciAoKSk7Ci0tLSAuL3NyYy9jb25maWd1cmUJMjAxOC0wOC0wMyAxNzo0MTo0
NC43MTA1MjA0NjIgKzEwMDAKKysrIC4uL3BhcmFsbGVsLTMuMS4zLm5ldy8u
L3NyYy9jb25maWd1cmUJMjAxOS0wNC0xNSAxMjowOTowNy4wMDAwMDAwMDAg
KzEwMDAKQEAgLTY2Niw3ICs2NjYsNiBAQAogZG9jZGlyCiBvbGRpbmNsdWRl
ZGlyCiBpbmNsdWRlZGlyCi1ydW5zdGF0ZWRpcgogbG9jYWxzdGF0ZWRpcgog
c2hhcmVkc3RhdGVkaXIKIHN5c2NvbmZkaXIKQEAgLTc0Miw3ICs3NDEsNiBA
QAogc3lzY29uZmRpcj0nJHtwcmVmaXh9L2V0YycKIHNoYXJlZHN0YXRlZGly
PScke3ByZWZpeH0vY29tJwogbG9jYWxzdGF0ZWRpcj0nJHtwcmVmaXh9L3Zh
cicKLXJ1bnN0YXRlZGlyPScke2xvY2Fsc3RhdGVkaXJ9L3J1bicKIGluY2x1
ZGVkaXI9JyR7cHJlZml4fS9pbmNsdWRlJwogb2xkaW5jbHVkZWRpcj0nL3Vz
ci9pbmNsdWRlJwogZG9jZGlyPScke2RhdGFyb290ZGlyfS9kb2MvJHtQQUNL
QUdFX1RBUk5BTUV9JwpAQCAtOTk1LDE1ICs5OTMsNiBAQAogICB8IC1zaWxl
bnQgfCAtLXNpbGVudCB8IC0tc2lsZW4gfCAtLXNpbGUgfCAtLXNpbCkKICAg
ICBzaWxlbnQ9eWVzIDs7CiAKLSAgLXJ1bnN0YXRlZGlyIHwgLS1ydW5zdGF0
ZWRpciB8IC0tcnVuc3RhdGVkaSB8IC0tcnVuc3RhdGVkIFwKLSAgfCAtLXJ1
bnN0YXRlIHwgLS1ydW5zdGF0IHwgLS1ydW5zdGEgfCAtLXJ1bnN0IHwgLS1y
dW5zIFwKLSAgfCAtLXJ1biB8IC0tcnUgfCAtLXIpCi0gICAgYWNfcHJldj1y
dW5zdGF0ZWRpciA7OwotICAtcnVuc3RhdGVkaXI9KiB8IC0tcnVuc3RhdGVk
aXI9KiB8IC0tcnVuc3RhdGVkaT0qIHwgLS1ydW5zdGF0ZWQ9KiBcCi0gIHwg
LS1ydW5zdGF0ZT0qIHwgLS1ydW5zdGF0PSogfCAtLXJ1bnN0YT0qIHwgLS1y
dW5zdD0qIHwgLS1ydW5zPSogXAotICB8IC0tcnVuPSogfCAtLXJ1PSogfCAt
LXI9KikKLSAgICBydW5zdGF0ZWRpcj0kYWNfb3B0YXJnIDs7Ci0KICAgLXNi
aW5kaXIgfCAtLXNiaW5kaXIgfCAtLXNiaW5kaSB8IC0tc2JpbmQgfCAtLXNi
aW4gfCAtLXNiaSB8IC0tc2IpCiAgICAgYWNfcHJldj1zYmluZGlyIDs7CiAg
IC1zYmluZGlyPSogfCAtLXNiaW5kaXI9KiB8IC0tc2JpbmRpPSogfCAtLXNi
aW5kPSogfCAtLXNiaW49KiBcCkBAIC0xMTQxLDcgKzExMzAsNyBAQAogZm9y
IGFjX3ZhciBpbglleGVjX3ByZWZpeCBwcmVmaXggYmluZGlyIHNiaW5kaXIg
bGliZXhlY2RpciBkYXRhcm9vdGRpciBcCiAJCWRhdGFkaXIgc3lzY29uZmRp
ciBzaGFyZWRzdGF0ZWRpciBsb2NhbHN0YXRlZGlyIGluY2x1ZGVkaXIgXAog
CQlvbGRpbmNsdWRlZGlyIGRvY2RpciBpbmZvZGlyIGh0bWxkaXIgZHZpZGly
IHBkZmRpciBwc2RpciBcCi0JCWxpYmRpciBsb2NhbGVkaXIgbWFuZGlyIHJ1
bnN0YXRlZGlyCisJCWxpYmRpciBsb2NhbGVkaXIgbWFuZGlyCiBkbwogICBl
dmFsIGFjX3ZhbD1cJCRhY192YXIKICAgIyBSZW1vdmUgdHJhaWxpbmcgc2xh
c2hlcy4KQEAgLTEyOTQsNyArMTI4Myw2IEBACiAgIC0tc3lzY29uZmRpcj1E
SVIgICAgICAgIHJlYWQtb25seSBzaW5nbGUtbWFjaGluZSBkYXRhIFtQUkVG
SVgvZXRjXQogICAtLXNoYXJlZHN0YXRlZGlyPURJUiAgICBtb2RpZmlhYmxl
IGFyY2hpdGVjdHVyZS1pbmRlcGVuZGVudCBkYXRhIFtQUkVGSVgvY29tXQog
ICAtLWxvY2Fsc3RhdGVkaXI9RElSICAgICBtb2RpZmlhYmxlIHNpbmdsZS1t
YWNoaW5lIGRhdGEgW1BSRUZJWC92YXJdCi0gIC0tcnVuc3RhdGVkaXI9RElS
ICAgICAgIG1vZGlmaWFibGUgcGVyLXByb2Nlc3MgZGF0YSBbTE9DQUxTVEFU
RURJUi9ydW5dCiAgIC0tbGliZGlyPURJUiAgICAgICAgICAgIG9iamVjdCBj
b2RlIGxpYnJhcmllcyBbRVBSRUZJWC9saWJdCiAgIC0taW5jbHVkZWRpcj1E
SVIgICAgICAgIEMgaGVhZGVyIGZpbGVzIFtQUkVGSVgvaW5jbHVkZV0KICAg
LS1vbGRpbmNsdWRlZGlyPURJUiAgICAgQyBoZWFkZXIgZmlsZXMgZm9yIG5v
bi1nY2MgWy91c3IvaW5jbHVkZV0KQEAgLTY0MTMsNyArNjQwMSw3IEBACiBp
bnQKIG1haW4gKCkKIHsKLXN0ZDo6Y291dCA8PCBvY3RhdmU6Om1hY2hfaW5m
bzo6Zmx0X2ZtdF91bmtub3duOworaW50IHg9b2N0YXZlOjptYWNoX2luZm86
OmZsdF9mbXRfdW5rbm93bjsKICAgOwogICByZXR1cm4gMDsKIH0KQEAgLTY4
MTEsOCArNjc5OSw4IEBACiBmaQogcm0gLWYgY29yZSBjb25mdGVzdC5lcnIg
Y29uZnRlc3QuJGFjX29iamV4dCBjb25mdGVzdC4kYWNfZXh0CiAKLXsgJGFz
X2VjaG8gIiRhc19tZToke2FzX2xpbmVuby0kTElORU5PfTogY2hlY2tpbmcg
ICBldmFsX3N0cmluZyBvciBvY3RhdmU6OmV2YWxfc3RyaW5nIiA+JjUKLSRh
c19lY2hvX24gImNoZWNraW5nICAgZXZhbF9zdHJpbmcgb3Igb2N0YXZlOjpl
dmFsX3N0cmluZy4uLiAiID4mNjsgfQoreyAkYXNfZWNobyAiJGFzX21lOiR7
YXNfbGluZW5vLSRMSU5FTk99OiBjaGVja2luZyAgIGV2YWxfc3RyaW5nIG9y
IG9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRlciAoKSAtPiBl
dmFsX3N0cmluZyIgPiY1CiskYXNfZWNob19uICJjaGVja2luZyAgIGV2YWxf
c3RyaW5nIG9yIG9jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRl
ciAoKSAtPiBldmFsX3N0cmluZy4uLiAiID4mNjsgfQogICBjYXQgY29uZmRl
ZnMuaCAtIDw8X0FDRU9GID5jb25mdGVzdC4kYWNfZXh0CiAvKiBlbmQgY29u
ZmRlZnMuaC4gICovCiAjaW5jbHVkZSA8b2N0YXZlL29jdC5oPgpAQCAtNjgy
MSwxNyArNjgwOSwxNyBAQAogaW50CiBtYWluICgpCiB7Ci1pbnQgcF9lcnI7
IG9jdGF2ZTo6ZXZhbF9zdHJpbmcgKCJkYXRlIiwgZmFsc2UsIHBfZXJyLCAw
KTsKK2ludCBwX2VycjsgY29uc3Qgc3RkOjpzdHJpbmcgc3RyPSJkYXRlIjtv
Y3RhdmVfdmFsdWVfbGlzdCByZXR2YWw9b2N0YXZlOjppbnRlcnByZXRlcjo6
dGhlX2ludGVycHJldGVyICgpIC0+IGV2YWxfc3RyaW5nIChzdHIsIGZhbHNl
LCBwX2VyciwgMCk7CiAgIDsKICAgcmV0dXJuIDA7CiB9CiBfQUNFT0YKIGlm
IGFjX2ZuX2N4eF90cnlfY29tcGlsZSAiJExJTkVOTyI7IHRoZW4gOgogCi0k
YXNfZWNobyAiI2RlZmluZSBPQ1RBVkVfX0VWQUxfU1RSSU5HIG9jdGF2ZTo6
ZXZhbF9zdHJpbmciID4+Y29uZmRlZnMuaAorJGFzX2VjaG8gIiNkZWZpbmUg
T0NUQVZFX19FVkFMX1NUUklORyBvY3RhdmU6OmludGVycHJldGVyOjp0aGVf
aW50ZXJwcmV0ZXIgKCkgLT4gZXZhbF9zdHJpbmciID4+Y29uZmRlZnMuaAog
Ci0gICAgIHsgJGFzX2VjaG8gIiRhc19tZToke2FzX2xpbmVuby0kTElORU5P
fTogcmVzdWx0OiBvY3RhdmU6OmV2YWxfc3RyaW5nIiA+JjUKLSRhc19lY2hv
ICJvY3RhdmU6OmV2YWxfc3RyaW5nIiA+JjY7IH0KKyAgICAgeyAkYXNfZWNo
byAiJGFzX21lOiR7YXNfbGluZW5vLSRMSU5FTk99OiByZXN1bHQ6IG9jdGF2
ZTo6aW50ZXJwcmV0ZXI6OnRoZV9pbnRlcnByZXRlciAoKSAtPiBldmFsX3N0
cmluZyIgPiY1CiskYXNfZWNobyAib2N0YXZlOjppbnRlcnByZXRlcjo6dGhl
X2ludGVycHJldGVyICgpIC0+IGV2YWxfc3RyaW5nIiA+JjY7IH0KICAgICAg
ZWNobyAnI2luY2x1ZGUgPG9jdGF2ZS9wYXJzZS5oPgogJyA+PiBvY3QtYWx0
LWluY2x1ZGVzLmgKIGVsc2UKLS0tIC4vc3JjL2NvbmZpZ3VyZS5hYwkyMDE4
LTA4LTAzIDE3OjQxOjQyLjUzNDQ3NzQ5NiArMTAwMAorKysgLi4vcGFyYWxs
ZWwtMy4xLjMubmV3Ly4vc3JjL2NvbmZpZ3VyZS5hYwkyMDE5LTA0LTE1IDEy
OjA5OjAyLjAwMDAwMDAwMCArMTAwMApAQCAtMjcyLDcgKzI3Miw3IEBACiBb
ZG5sCiAgIFtvY3RfbWFjaF9pbmZvXSwKICAgW29jdGF2ZTo6bWFjaF9pbmZv
XSwKLSAgW1tzdGQ6OmNvdXQgPDwgb2N0YXZlOjptYWNoX2luZm86OmZsdF9m
bXRfdW5rbm93bjtdXSwKKyAgW1tpbnQgeD1vY3RhdmU6Om1hY2hfaW5mbzo6
Zmx0X2ZtdF91bmtub3duO11dLAogICBbT0NUQVZFX19NQUNIX0lORk9dLAog
ICBbXSwKICAgW10KQEAgLTM3OSw4ICszNzksOCBAQAogCiBbZG5sCiAgIFtl
dmFsX3N0cmluZ10sCi0gIFtvY3RhdmU6OmV2YWxfc3RyaW5nXSwKLSAgW1tp
bnQgcF9lcnI7IG9jdGF2ZTo6ZXZhbF9zdHJpbmcgKCJkYXRlIiwgZmFsc2Us
IHBfZXJyLCAwKTtdXSwKKyAgW29jdGF2ZTo6aW50ZXJwcmV0ZXI6OnRoZV9p
bnRlcnByZXRlciAoKSAtPiBldmFsX3N0cmluZ10sCisgIFtbaW50IHBfZXJy
OyBjb25zdCBzdGQ6OnN0cmluZyBzdHI9ImRhdGUiO29jdGF2ZV92YWx1ZV9s
aXN0IHJldHZhbD1vY3RhdmU6OmludGVycHJldGVyOjp0aGVfaW50ZXJwcmV0
ZXIgKCkgLT4gZXZhbF9zdHJpbmcgKHN0ciwgZmFsc2UsIHBfZXJyLCAwKTtd
XSwKICAgW09DVEFWRV9fRVZBTF9TVFJJTkddLAogICBbWyNpbmNsdWRlIDxv
Y3RhdmUvcGFyc2UuaD5dXSwKICAgW1sjaW5jbHVkZSA8b2N0YXZlL3BhcnNl
Lmg+XV0KLS0tIC4vZG9jL3BhcmFsbGVsLmluZm8JMjAxOC0wOC0wMyAxNzo0
Mzo1My4wMDUwNTM1NjQgKzEwMDAKKysrIC4uL3BhcmFsbGVsLTMuMS4zLm5l
dy8uL2RvYy9wYXJhbGxlbC5pbmZvCTIwMTktMDQtMTUgMTE6MDk6MTYuMDAw
MDAwMDAwICsxMDAwCkBAIC0xLDQgKzEsNCBAQAotVGhpcyBpcyBwYXJhbGxl
bC5pbmZvLCBwcm9kdWNlZCBieSBtYWtlaW5mbyB2ZXJzaW9uIDYuMyBmcm9t
CitUaGlzIGlzIHBhcmFsbGVsLmluZm8sIHByb2R1Y2VkIGJ5IG1ha2VpbmZv
IHZlcnNpb24gNi41IGZyb20KIHBhcmFsbGVsLnRleGkuCiAKIEdlbmVyYWwg
ZG9jdW1lbnRhdGlvbiBmb3IgdGhlIHBhcmFsbGVsIHBhY2thZ2UgZm9yIE9j
dGF2ZS4K
====
EOF
uudecode parallel-3.1.3.patch.uue > parallel-3.1.3.patch
tar -xf parallel-3.1.3.tar.gz
pushd parallel-3.1.3
patch -p1 < ../parallel-3.1.3.patch
popd
tar -cvzf parallel-3.1.3.new.tar.gz parallel-3.1.3

#
# Fix signal-1.4.1 package zplane function
#
cat > zplane.m.patch.uue << 'EOF'
begin-base64 644 zplane.m.patch
LS0tIHNpZ25hbC0xLjQuMS9pbnN0L3pwbGFuZS5tCTIwMTktMDItMDkgMDk6
MDA6MzcuMDAwMDAwMDAwICsxMTAwCisrKyB6cGxhbmUubQkyMDE5LTA1LTEx
IDE1OjAyOjQwLjM2MzE3OTI4MiArMTAwMApAQCAtMTE1LDggKzExNSw5IEBA
CiAgICAgICBmb3IgaSA9IDE6bGVuZ3RoICh4X3UpCiAgICAgICAgIG4gPSBz
dW0gKHhfdShpKSA9PSB4KDosYykpOwogICAgICAgICBpZiAobiA+IDEpCi0g
ICAgICAgICAgbGFiZWwgPSBzcHJpbnRmICgiIF4lZCIsIG4pOwotICAgICAg
ICAgIHRleHQgKHJlYWwgKHhfdShpKSksIGltYWcgKHhfdShpKSksIGxhYmVs
LCAiY29sb3IiLCBjb2xvcik7CisgICAgICAgICAgbGFiZWwgPSBzcHJpbnRm
ICgiJWQiLCBuKTsKKyAgICAgICAgICB0ZXh0IChyZWFsICh4X3UoaSkpLCBp
bWFnICh4X3UoaSkpLCBsYWJlbCwgImNvbG9yIiwgY29sb3IsIC4uLgorICAg
ICAgICAgICAgICAgICJ2ZXJ0aWNhbGFsaWdubWVudCIsICJib3R0b20iLCAi
aG9yaXpvbnRhbGFsaWdubWVudCIsICJsZWZ0Iik7CiAgICAgICAgIGVuZGlm
CiAgICAgICBlbmRmb3IKICAgICBlbmRmb3IK
====
EOF
uudecode zplane.m.patch.uue > zplane.m.patch
tar -xf signal-1.4.1.tar.gz
pushd signal-1.4.1
patch -p1 < ../zplane.m.patch
popd
tar -cvzf signal-1.4.1.new.tar.gz signal-1.4.1

#
# Install packages
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$IO_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$STRUCT_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$STATISTICS_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$OPTIM_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$CONTROL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$SYMBOLIC_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install signal-1.4.1.new.tar.gz"
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install parallel-3.1.3.new.tar.gz"
$OCTAVE_BIN_DIR/octave-cli --eval "pkg list"

#
# Cleanup
#
rm -Rf lapack-$LAPACK_VER fftw-$FFTW_VER glpk-$GLPK_VER qrupdate-$QRUPDATE_VER \
   SuiteSparse arpack-ng-master build *patch* signal-1.4.1 parallel-3.1.3 \
   signal-1.4.1.new.tar.gz parallel-3.1.3.new.tar.gz octave-$OCTAVE_VER

