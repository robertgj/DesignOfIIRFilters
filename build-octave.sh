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
# Assume these files are present. Get them if they are not.
#
LAPACK_VER=${LAPACK_VER:-3.9.0}
LAPACK_ARCHIVE=lapack-$LAPACK_VER".tar.gz"
LAPACK_URL=http://www.netlib.org/lapack/$LAPACK_ARCHIVE
if ! test -f $LAPACK_ARCHIVE; then
  wget -c $LAPACK_URL
fi

ARPACK_ARCHIVE=arpack-ng-master.zip
ARPACK_URL=https://github.com/opencollab/arpack-ng/archive/$ARPACK_ARCHIVE
if ! test -f $ARPACK_ARCHIVE; then
  wget -c $ARPACK_URL
fi

SUITESPARSE_VER=${SUITESPARSE_VER:-5.1.2}
SUITESPARSE_ARCHIVE=SuiteSparse-$SUITESPARSE_VER".tar.gz"
SUITESPARSE_URL=http://people.engr.tamu.edu/davis/SuiteSparse/$SUITESPARSE_ARCHIVE
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

OCTAVE_VER=${OCTAVE_VER:-5.2.0}
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

IO_VER=${IO_VER:-2.6.1}
IO_ARCHIVE=io-$IO_VER".tar.gz"
IO_URL=$OCTAVE_FORGE_URL$IO_ARCHIVE
if ! test -f $IO_ARCHIVE; then
    wget -c $IO_URL
fi

STATISTICS_VER=${STATISTICS_VER:-1.4.2}
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

PARALLEL_VER=${PARALLEL_VER:-4.0.0}
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
OCTAVE_DIR="/usr/local/octave"-$OCTAVE_VER
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
cat > lapack.patch.uue << 'EOF'
begin-base64 644 lapack.patch
LS0tIGxhcGFjay0zLjkuMC9tYWtlLmluYy5leGFtcGxlCTIwMTktMTEtMjEg
MTg6NTc6NDMuMDAwMDAwMDAwICsxMTAwCisrKyBsYXBhY2stMy45LjAubmV3
L21ha2UuaW5jLmV4YW1wbGUJMjAyMC0wOC0yMSAxMzowMzo0Mi4xNzU0MDg1
MzUgKzEwMDAKQEAgLTksNyArOSw4IEBACiAjICBDQyBpcyB0aGUgQyBjb21w
aWxlciwgbm9ybWFsbHkgaW52b2tlZCB3aXRoIG9wdGlvbnMgQ0ZMQUdTLgog
IwogQ0MgPSBnY2MKLUNGTEFHUyA9IC1PMworQkxET1BUUyA9IC1mUElDIC1t
NjQgLW10dW5lPWdlbmVyaWMKK0NGTEFHUyA9IC1PMyAkKEJMRE9QVFMpCiAK
ICMgIE1vZGlmeSB0aGUgRkMgYW5kIEZGTEFHUyBkZWZpbml0aW9ucyB0byB0
aGUgZGVzaXJlZCBjb21waWxlcgogIyAgYW5kIGRlc2lyZWQgY29tcGlsZXIg
b3B0aW9ucyBmb3IgeW91ciBtYWNoaW5lLiAgTk9PUFQgcmVmZXJzIHRvCkBA
IC0xOSwxMCArMjAsMTAgQEAKICMgIGFuZCBoYW5kbGUgdGhlc2UgcXVhbnRp
dGllcyBhcHByb3ByaWF0ZWx5LiBBcyBhIGNvbnNlcXVlbmNlLCBvbmUKICMg
IHNob3VsZCBub3QgY29tcGlsZSBMQVBBQ0sgd2l0aCBmbGFncyBzdWNoIGFz
IC1mZnBlLXRyYXA9b3ZlcmZsb3cuCiAjCi1GQyA9IGdmb3J0cmFuCi1GRkxB
R1MgPSAtTzIgLWZyZWN1cnNpdmUKK0ZDID0gZ2ZvcnRyYW4gLWZyZWN1cnNp
dmUgJChCTERPUFRTKQorRkZMQUdTID0gLU8yIAogRkZMQUdTX0RSViA9ICQo
RkZMQUdTKQotRkZMQUdTX05PT1BUID0gLU8wIC1mcmVjdXJzaXZlCitGRkxB
R1NfTk9PUFQgPSAtTzAKIAogIyAgRGVmaW5lIExERkxBR1MgdG8gdGhlIGRl
c2lyZWQgbGlua2VyIG9wdGlvbnMgZm9yIHlvdXIgbWFjaGluZS4KICMKQEAg
LTU3LDcgKzU4LDcgQEAKICMgIFVuY29tbWVudCB0aGUgZm9sbG93aW5nIGxp
bmUgdG8gaW5jbHVkZSBkZXByZWNhdGVkIHJvdXRpbmVzIGluCiAjICB0aGUg
TEFQQUNLIGxpYnJhcnkuCiAjCi0jQlVJTERfREVQUkVDQVRFRCA9IFllcwor
QlVJTERfREVQUkVDQVRFRCA9IFllcwogCiAjICBMQVBBQ0tFIGhhcyB0aGUg
aW50ZXJmYWNlIHRvIHNvbWUgcm91dGluZXMgZnJvbSB0bWdsaWIuCiAjICBJ
ZiBMQVBBQ0tFX1dJVEhfVE1HIGlzIGRlZmluZWQsIGFkZCB0aG9zZSByb3V0
aW5lcyB0byBMQVBBQ0tFLgpAQCAtNzYsNyArNzcsNyBAQAogIyAgbWFjaGlu
ZS1zcGVjaWZpYywgb3B0aW1pemVkIEJMQVMgbGlicmFyeSBzaG91bGQgYmUg
dXNlZCB3aGVuZXZlcgogIyAgcG9zc2libGUuKQogIwotQkxBU0xJQiAgICAg
ID0gJChUT1BTUkNESVIpL2xpYnJlZmJsYXMuYQorQkxBU0xJQiAgICAgID0g
JChUT1BTUkNESVIpL2xpYmJsYXMuYQogQ0JMQVNMSUIgICAgID0gJChUT1BT
UkNESVIpL2xpYmNibGFzLmEKIExBUEFDS0xJQiAgICA9ICQoVE9QU1JDRElS
KS9saWJsYXBhY2suYQogVE1HTElCICAgICAgID0gJChUT1BTUkNESVIpL2xp
YnRtZ2xpYi5hCi0tLSBsYXBhY2stMy45LjAvU1JDL01ha2VmaWxlCTIwMTkt
MTEtMjEgMTg6NTc6NDMuMDAwMDAwMDAwICsxMTAwCisrKyBsYXBhY2stMy45
LjAubmV3L1NSQy9NYWtlZmlsZQkyMDIwLTA4LTIxIDEzOjAxOjE2LjEzMDY2
NDMwNiArMTAwMApAQCAtNTMyLDYgKzUzMiw5IEBACiAJJChBUikgJChBUkZM
QUdTKSAkQCAkXgogCSQoUkFOTElCKSAkQAogCiskKG5vdGRpciAkKExBUEFD
S0xJQjolLmE9JS5zbykpOiAkKEFMTE9CSikgJChBTExYT0JKKSAkKERFUFJF
Q0FURUQpCisJJChGQykgLXNoYXJlZCAtV2wsLXNvbmFtZSwkQCAtbyAkQCAk
XgorCiAuUEhPTlk6IHNpbmdsZSBjb21wbGV4IGRvdWJsZSBjb21wbGV4MTYK
IHNpbmdsZTogJChTTEFTUkMpICQoRFNMQVNSQykgJChTWExBU1JDKSAkKFND
TEFVWCkgJChBTExBVVgpCiAJJChBUikgJChBUkZMQUdTKSAkKExBUEFDS0xJ
QikgJF4KLS0tIGxhcGFjay0zLjkuMC9CTEFTL1NSQy9NYWtlZmlsZQkyMDE5
LTExLTIxIDE4OjU3OjQzLjAwMDAwMDAwMCArMTEwMAorKysgbGFwYWNrLTMu
OS4wLm5ldy9CTEFTL1NSQy9NYWtlZmlsZQkyMDIwLTA4LTIxIDEzOjAyOjAw
LjA1MDI4NjY2MiArMTAwMApAQCAtMTQzLDYgKzE0Myw5IEBACiAJJChBUikg
JChBUkZMQUdTKSAkQCAkXgogCSQoUkFOTElCKSAkQAogCiskKG5vdGRpciAk
KEJMQVNMSUI6JS5hPSUuc28pKTogJChBTExPQkopCisJJChGQykgLXNoYXJl
ZCAtV2wsLXNvbmFtZSwkQCAtbyAkQCAkXgorCiAuUEhPTlk6IHNpbmdsZSBk
b3VibGUgY29tcGxleCBjb21wbGV4MTYKIHNpbmdsZTogJChTQkxBUzEpICQo
QUxMQkxBUykgJChTQkxBUzIpICQoU0JMQVMzKQogCSQoQVIpICQoQVJGTEFH
UykgJChCTEFTTElCKSAkXgo=
====
EOF

# Patch
uudecode lapack.patch.uue > lapack.patch
tar -xf $LAPACK_ARCHIVE
pushd lapack-$LAPACK_VER
patch -p1 < ../lapack.patch
cp -f make.inc.example make.inc
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
rm -Rf lapack-$LAPACK_VER lapack.patch.uue lapack.patch

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
rm -Rf arpack-ng-master

#
# Build SuiteSparse
#
rm -Rf SuiteSparse
tar -xf $SUITESPARSE_ARCHIVE
pushd SuiteSparse
make -j 6 INSTALL=$OCTAVE_DIR OPTIMIZATION=-O2 BLAS=-lblas install
popd
rm -Rf SuiteSparse

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
rm -Rf qrupdate-$QRUPDATE_VER

#
# Build glpk
#
rm -Rf glpk-$GLPK_VER
tar -xf $GLPK_ARCHIVE
pushd glpk-$GLPK_VER
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
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd
rm -Rf fftw-$FFTW_VER

#
# Build octave
#
rm -Rf octave-$OCTAVE_VER
tar -xf $OCTAVE_ARCHIVE
# Patch
cat > octave.patch.uue << 'EOF'
begin-base64 644 octave.patch
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
uudecode octave.patch.uue > octave.patch
pushd octave-$OCTAVE_VER
patch -p1 < ../octave.patch
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
# Add --enable-address-sanitizer-flags for address sanitizer build
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
popd
rm -Rf build octave-$OCTAVE_VER octave.patch.uue octave.patch

#
# Done
#

#
# Fix signal package zplane function
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
tar -xf $SIGNAL_ARCHIVE
NEW_SIGNAL_ARCHIVE=signal-$SIGNAL_VER".new.tar.gz"
pushd signal-$SIGNAL_VER
patch -p1 < ../zplane.m.patch
popd
tar -czf $NEW_SIGNAL_ARCHIVE signal-$SIGNAL_VER
rm -Rf signal-$SIGNAL_VER zplane.m.patch.uue zplane.m.patch

#
# Install packages
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$IO_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$STRUCT_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$STATISTICS_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$OPTIM_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$CONTROL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$PARALLEL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$SYMBOLIC_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$NEW_SIGNAL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg list"

#
# Cleanup
#
rm -f $NEW_SIGNAL_ARCHIVE

