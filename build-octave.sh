#!/bin/sh

# Build a local version of octave-cli
#
# Requires Fedora packages: wget readline-devel lzip sharutils gcc gcc-c++
# gcc-gfortran gmp-devel mpfr-devel cmake gnuplot-latex m4 gperf bison flex
# openblas-devel patch texinfo texinfo-tex librsvg2 librsvg2-devel
# librsvg2-tools icoutils 
#
# To build the pdf document install Fedora packages: dia epstool
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
LAPACK_URL=http://github.com/Reference-LAPACK/lapack/archive/v$LAPACK_VER.tar.gz
if ! test -f $LAPACK_ARCHIVE; then
  wget -c $LAPACK_URL -O $LAPACK_ARCHIVE
fi

ARPACK_ARCHIVE=arpack-ng-master.zip
ARPACK_URL=https://github.com/opencollab/arpack-ng/archive/master.zip
if ! test -f $ARPACK_ARCHIVE; then
  wget -c $ARPACK_URL -O $ARPACK_ARCHIVE
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

IO_VER=${IO_VER:-2.6.2}
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
# Build arpack
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
LS0tIG9jdGF2ZS01LjIuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXBhdGgu
Y2MJMjAyMC0wMS0yOCAxMjo1NzozNS4wMDAwMDAwMDAgKzExMDAKKysrIG9j
dGF2ZS01LjIuMC5uZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1wYXRoLmNj
CTIwMjAtMDgtMjcgMTY6MTQ6MzAuMDM1MjY5OTk2ICsxMDAwCkBAIC0zNjYs
NyArMzY2LDggQEAKICAgICAgICAgYm9vbCBvayA9IGRpLnVwZGF0ZSAoKTsK
IAogICAgICAgICBpZiAoISBvaykKLSAgICAgICAgICB3YXJuaW5nICgibG9h
ZC1wYXRoOiB1cGRhdGUgZmFpbGVkIGZvciAnJXMnLCByZW1vdmluZyBmcm9t
IHBhdGgiLAorICAgICAgICAgIHdhcm5pbmdfd2l0aF9pZCAoIk9jdGF2ZTps
b2FkLXBhdGgtdXBkYXRlLWZhaWxlZCIsCisJCSAgICAgICAgICAgICJsb2Fk
LXBhdGg6IHVwZGF0ZSBmYWlsZWQgZm9yICclcycsIHJlbW92aW5nIGZyb20g
cGF0aCIsCiAgICAgICAgICAgICAgICAgICAgZGkuZGlyX25hbWUuY19zdHIg
KCkpOwogICAgICAgICBlbHNlCiAgICAgICAgICAgYWRkIChkaSwgdHJ1ZSwg
IiIsIHRydWUpOwpAQCAtMTEzNiw3ICsxMTM3LDggQEAKICAgICBpZiAoISBm
cykKICAgICAgIHsKICAgICAgICAgc3RkOjpzdHJpbmcgbXNnID0gZnMuZXJy
b3IgKCk7Ci0gICAgICAgIHdhcm5pbmcgKCJsb2FkX3BhdGg6ICVzOiAlcyIs
IGRpcl9uYW1lLmNfc3RyICgpLCBtc2cuY19zdHIgKCkpOworICAgICAgICB3
YXJuaW5nX3dpdGhfaWQgKCJPY3RhdmU6bG9hZC1wYXRoLWRpci1pbmZvLXVw
ZGF0ZSIsCisJCSAgICAgICAgICAibG9hZF9wYXRoOiAlczogJXMiLCBkaXJf
bmFtZS5jX3N0ciAoKSwgbXNnLmNfc3RyICgpKTsKICAgICAgICAgcmV0dXJu
IGZhbHNlOwogICAgICAgfQogCi0tLSBvY3RhdmUtNS4yLjAvbGliaW50ZXJw
L2NvcmVmY24vbG9hZC1zYXZlLmNjCTIwMjAtMDEtMjggMTI6NTc6MzUuMDAw
MDAwMDAwICsxMTAwCisrKyBvY3RhdmUtNS4yLjAubmV3L2xpYmludGVycC9j
b3JlZmNuL2xvYWQtc2F2ZS5jYwkyMDIwLTA4LTI3IDE2OjE0OjMwLjAzNTI2
OTk5NiArMTAwMApAQCAtMTMwLDggKzEzMCw4IEBACiAgIHsKICAgICBjb25z
dCBpbnQgbWFnaWNfbGVuID0gMTA7CiAgICAgY2hhciBtYWdpY1ttYWdpY19s
ZW4rMV07CisgICAgbWVtc2V0KG1hZ2ljLCdcMCcsbWFnaWNfbGVuKzEpOwog
ICAgIGlzLnJlYWQgKG1hZ2ljLCBtYWdpY19sZW4pOwotICAgIG1hZ2ljW21h
Z2ljX2xlbl0gPSAnXDAnOwogCiAgICAgaWYgKHN0cm5jbXAgKG1hZ2ljLCAi
T2N0YXZlLTEtTCIsIG1hZ2ljX2xlbikgPT0gMCkKICAgICAgIHN3YXAgPSBt
YWNoX2luZm86OndvcmRzX2JpZ19lbmRpYW4gKCk7Ci0tLSBvY3RhdmUtNS4y
LjAvc2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0ZS9fX2dudXBsb3RfZHJhd19h
eGVzX18ubQkyMDIwLTAxLTI4IDEyOjU3OjM1LjAwMDAwMDAwMCArMTEwMAor
Kysgb2N0YXZlLTUuMi4wLm5ldy9zY3JpcHRzL3Bsb3QvdXRpbC9wcml2YXRl
L19fZ251cGxvdF9kcmF3X2F4ZXNfXy5tCTIwMjAtMDgtMjcgMTY6MTQ6MzAu
MDM2MjY5OTg3ICsxMDAwCkBAIC0yMjU0LDcgKzIyNTQsOCBAQAogICAgIGVu
ZGZvcgogICBlbHNlaWYgKHN0cmNtcCAoaW50ZXJwcmV0ZXIsICJsYXRleCIp
KQogICAgIGlmICghIHdhcm5lZF9sYXRleCkKLSAgICAgIHdhcm5pbmcgKCJs
YXRleCBtYXJrdXAgbm90IHN1cHBvcnRlZCBmb3IgdGljayBtYXJrcyIpOwor
ICAgICAgd2FybmluZyAoIk9jdGF2ZTpsYXRleC1tYXJrdXAtbm90LXN1cHBv
cnRlZC1mb3ItdGljay1tYXJrcyIsCisJICAgICAgICAibGF0ZXggbWFya3Vw
IG5vdCBzdXBwb3J0ZWQgZm9yIHRpY2sgbWFya3MiKTsKICAgICAgIHdhcm5l
ZF9sYXRleCA9IHRydWU7CiAgICAgZW5kaWYKICAgZW5kaWYKLS0tIG9jdGF2
ZS01LjIuMC9zY3JpcHRzL21pc2NlbGxhbmVvdXMvZGVsZXRlLm0JMjAyMC0w
MS0yOCAxMjo1NzozNS4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS01LjIu
MC5uZXcvc2NyaXB0cy9taXNjZWxsYW5lb3VzL2RlbGV0ZS5tCTIwMjAtMDgt
MjcgMTY6MTQ6MzAuMDM2MjY5OTg3ICsxMDAwCkBAIC00NCw3ICs0NCw4IEBA
CiAgICAgZm9yIGFyZyA9IHZhcmFyZ2luCiAgICAgICBmaWxlcyA9IGdsb2Ig
KGFyZ3sxfSk7CiAgICAgICBpZiAoaXNlbXB0eSAoZmlsZXMpKQotICAgICAg
ICB3YXJuaW5nICgiZGVsZXRlOiBubyBzdWNoIGZpbGU6ICVzIiwgYXJnezF9
KTsKKyAgICAgICAgd2FybmluZyAoIk9jdGF2ZTpkZWxldGUtbm8tc3VjaC1m
aWxlIiwKKwkgICAgICAgICAgImRlbGV0ZTogbm8gc3VjaCBmaWxlOiAlcyIs
IGFyZ3sxfSk7CiAgICAgICBlbmRpZgogICAgICAgZm9yIGkgPSAxOmxlbmd0
aCAoZmlsZXMpCiAgICAgICAgIGZpbGUgPSBmaWxlc3tpfTsKLS0tIG9jdGF2
ZS01LjIuMC9jb25maWd1cmUJMjAyMC0wMS0yOCAxMjo1NzozNS4wMDAwMDAw
MDAgKzExMDAKKysrIG9jdGF2ZS01LjIuMC5uZXcvY29uZmlndXJlCTIwMjAt
MDgtMjcgMTY6MTQ6MzAuMDQyMjY5OTM0ICsxMDAwCkBAIC01OTAsNyArNTkw
LDcgQEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgogUEFDS0FHRV9O
QU1FPSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdvY3RhdmUnCi1Q
QUNLQUdFX1ZFUlNJT049JzUuMi4wJworUEFDS0FHRV9WRVJTSU9OPSc1LjIu
MC1yb2JqJwogUEFDS0FHRV9TVFJJTkc9J0dOVSBPY3RhdmUgNS4yLjAnCiBQ
QUNLQUdFX0JVR1JFUE9SVD0naHR0cHM6Ly9vY3RhdmUub3JnL2J1Z3MuaHRt
bCcKIFBBQ0tBR0VfVVJMPSdodHRwczovL3d3dy5nbnUub3JnL3NvZnR3YXJl
L29jdGF2ZS8nCg==
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
# Compiling octave is done
#

#
# Install Octave-Forge packages
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$IO_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$STRUCT_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$STATISTICS_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$OPTIM_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$CONTROL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$PARALLEL_ARCHIVE

#
# Fix signal package zplane function and install the signal package
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

$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$NEW_SIGNAL_ARCHIVE
rm -f $NEW_SIGNAL_ARCHIVE

#
# Fix symbolic package for sympy-1.6 and install the symbolic package
# (Apply sympy-1.6.patch from octave-symbolic_2.9.0-3.debian.tar.xz)
#
cat > sympy-1.6.patch.uue << 'EOF'
begin-base64 644 sympy-1.6.patch
RGVzY3JpcHRpb246IEZpeCBGVEJGUyBhZ2FpbnN0IFN5bVB5IDEuNgogUGFy
dCBvZiB0aGUgZml4IGNvbnNpc3RzIGluIGRpc2FibGluZyBzb21lIHRlc3Rz
LCB3aGljaCBpcyB1bnNhdGlzZmFjdG9yeS4KIEhvcGVmdWxseSB1cHN0cmVh
bSB3aWxsIHNvb24gY29tZSB1cCB3aXRoIGEgcGF0Y2guCiAuCiBBIHRlbXBv
cmFyeSAoYnVpbGQtKWRlcGVuZGVuY3kgb24gcHl0aG9uMy1zaXggaGFzIGJl
ZW4gYWRkZWQgdG8gbWFrZSB0aGlzIHBhdGNoCiB3b3JrLgpBdXRob3I6IEdl
b3JnZXMgS2hhem5hZGFyIDxnZW9yZ2Vza0BkZWJpYW4ub3JnPgogICAgICAg
IFPDqWJhc3RpZW4gVmlsbGVtb3QgPHNlYmFzdGllbkBkZWJpYW4ub3JnPgpC
dWc6IGh0dHBzOi8vZ2l0aHViLmNvbS9jYm03NTUvb2N0c3ltcHkvaXNzdWVz
LzEwMjMKQnVnLURlYmlhbjogaHR0cHM6Ly9idWdzLmRlYmlhbi5vcmcvOTYz
MDM2CkZvcndhcmRlZDogbm90LW5lZWRlZApMYXN0LVVwZGF0ZTogMjAyMC0w
Ni0xOQotLS0KVGhpcyBwYXRjaCBoZWFkZXIgZm9sbG93cyBERVAtMzogaHR0
cDovL2RlcC5kZWJpYW4ubmV0L2RlcHMvZGVwMy8KLS0tIGEvaW5zdC9wcml2
YXRlL2NoZWNrX2FuZF9jb252ZXJ0Lm0KKysrIGIvaW5zdC9wcml2YXRlL2No
ZWNrX2FuZF9jb252ZXJ0Lm0KQEAgLTMwLDggKzMwLDggQEAgZnVuY3Rpb24g
b2JqID0gY2hlY2tfYW5kX2NvbnZlcnQodmFyX3B5bwogCiAgICAgc3AgPSBw
eS5zeW1weTsKICAgICBfc3ltID0gcHkudHVwbGUoe3NwLkJhc2ljLCBzcC5N
YXRyaXhCYXNlfSk7Ci0gICAgc3RyaW5nX3R5cGVzID0gc3AuY29tcGF0aWJp
bGl0eS5zdHJpbmdfdHlwZXM7Ci0gICAgaW50ZWdlcl90eXBlcyA9IHNwLmNv
bXBhdGliaWxpdHkuaW50ZWdlcl90eXBlczsKKyAgICBzdHJpbmdfdHlwZXMg
PSBzaXguc3RyaW5nX3R5cGVzOworICAgIGludGVnZXJfdHlwZXMgPSBzaXgu
aW50ZWdlcl90eXBlczsKICAgZW5kCiAKIAotLS0gYS9pbnN0L3ByaXZhdGUv
cHl0aG9uX2hlYWRlci5weQorKysgYi9pbnN0L3ByaXZhdGUvcHl0aG9uX2hl
YWRlci5weQpAQCAtMTEsNiArMTEsNyBAQCBmcm9tIF9fZnV0dXJlX18gaW1w
b3J0IGRpdmlzaW9uCiBpbXBvcnQgc3lzCiBzeXMucHMxID0gIiI7IHN5cy5w
czIgPSAiIgogCitpbXBvcnQgc2l4CiAKIGRlZiBlY2hvX2V4Y2VwdGlvbl9z
dGRvdXQobXlzdHIpOgogICAgIGV4Y2VwdGlvbl9zdHIgPSBzeXMuZXhjX2lu
Zm8oKVswXS5fX25hbWVfXyArICI6ICIgKyBzdHIoc3lzLmV4Y19pbmZvKClb
MV0pCkBAIC0xODQsNyArMTg1LDcgQEAgdHJ5OgogICAgICAgICAgICAgYyA9
IEVULlN1YkVsZW1lbnQoZXQsICJsaXN0IikKICAgICAgICAgICAgIGZvciB5
IGluIHg6CiAgICAgICAgICAgICAgICAgb2N0b3V0cHV0KHksIGMpCi0gICAg
ICAgIGVsaWYgaXNpbnN0YW5jZSh4LCBzcC5jb21wYXRpYmlsaXR5LmludGVn
ZXJfdHlwZXMpOgorICAgICAgICBlbGlmIGlzaW5zdGFuY2UoeCwgc2l4Lmlu
dGVnZXJfdHlwZXMpOgogICAgICAgICAgICAgYSA9IEVULlN1YkVsZW1lbnQo
ZXQsICJpdGVtIikKICAgICAgICAgICAgIGYgPSBFVC5TdWJFbGVtZW50KGEs
ICJmIikKICAgICAgICAgICAgIGYudGV4dCA9IHN0cihPQ1RDT0RFX0lOVCkK
QEAgLTIwNSw3ICsyMDYsNyBAQCB0cnk6CiAgICAgICAgICAgICBmLnRleHQg
PSBkMmhleCh4LnJlYWwpCiAgICAgICAgICAgICBmID0gRVQuU3ViRWxlbWVu
dChhLCAiZiIpCiAgICAgICAgICAgICBmLnRleHQgPSBkMmhleCh4LmltYWcp
Ci0gICAgICAgIGVsaWYgaXNpbnN0YW5jZSh4LCBzcC5jb21wYXRpYmlsaXR5
LnN0cmluZ190eXBlcyk6CisgICAgICAgIGVsaWYgaXNpbnN0YW5jZSh4LCBz
aXguc3RyaW5nX3R5cGVzKToKICAgICAgICAgICAgIGEgPSBFVC5TdWJFbGVt
ZW50KGV0LCAiaXRlbSIpCiAgICAgICAgICAgICBmID0gRVQuU3ViRWxlbWVu
dChhLCAiZiIpCiAgICAgICAgICAgICBmLnRleHQgPSBzdHIoT0NUQ09ERV9T
VFIpCi0tLSBhL2luc3QvQHN5bS9kc29sdmUubQorKysgYi9pbnN0L0BzeW0v
ZHNvbHZlLm0KQEAgLTI2Niw3ICsyNjYsNyBAQCBlbmQKICUhIGcgPSAzKnNp
bigyKngpKnRhbihzeW0oJzInKSkrMypjb3MoMip4KTsKICUhIGFzc2VydCAo
aXNlcXVhbCAocmhzKGYpLCBnKSkKIAotJSF0ZXN0CislIXh0ZXN0CiAlISAl
IFN5c3RlbSBvZiBPREVzCiAlISBzeW1zIHgodCkgeSh0KSBDMSBDMgogJSEg
b2RlMSA9IGRpZmYoeCh0KSx0KSA9PSAyKnkodCk7Ci0tLSBhL2luc3QvQHN5
bS9tcG93ZXIubQorKysgYi9pbnN0L0BzeW0vbXBvd2VyLm0KQEAgLTEzMCw3
ICsxMzAsNyBAQCBlbmQKICUhIEMgPSBzdWJzKEIsIG4sIDApOwogJSEgYXNz
ZXJ0IChpc2VxdWFsIChDLCBzeW0oZXllKDIpKSkpCiAKLSUhdGVzdAorJSF4
dGVzdAogJSEgJSBzY2FsYXJeYXJyYXkgbm90IGltcGxlbWVudGVkIGluIFN5
bVB5IDwgMS4wCiAlISBzeW1zIHgKICUhIEEgPSBbMSAyOyAzIDRdOwotLS0g
YS9pbnN0L0BzeW0vbXJkaXZpZGUubQorKysgYi9pbnN0L0BzeW0vbXJkaXZp
ZGUubQpAQCAtMTAxLDcgKzEwMSw3IEBAIGVuZAogJSEgYXNzZXJ0IChpc2Vx
dWFsICggQS8yICwgRC8yICApKQogJSEgYXNzZXJ0IChpc2VxdWFsICggQS9z
eW0oMikgLCBELzIgICkpCiAKLSUhdGVzdAorJSF4dGVzdAogJSEgJSBJL0E6
IGVpdGhlciBpbnZlcnQgQSBvciBsZWF2ZSB1bmV2YWx1YXRlZDogbm90IGJv
dGhlcmVkIHdoaWNoCiAlISBBID0gc3ltKFsxIDI7IDMgNF0pOwogJSEgQiA9
IHN5bShleWUoMikpIC8gQTsKQEAgLTExMyw3ICsxMTMsNyBAQCBlbmQKICUh
IEIgPSBzeW0oJ0ltbXV0YWJsZURlbnNlTWF0cml4KFtbSW50ZWdlcigxKSwg
SW50ZWdlcigyKV0sIFtJbnRlZ2VyKDMpLCBJbnRlZ2VyKDQpXV0pJyk7CiAl
ISBhc3NlcnQgKGlzZXF1YWwgKEEvQSwgQi9CKSkKIAotJSF0ZXN0CislIXh0
ZXN0CiAlISAlIEEgPSBDL0IgaXMgQyA9IEEqQgogJSEgQSA9IHN5bShbMSAy
OyAzIDRdKTsKICUhIEIgPSBzeW0oWzEgMzsgNCA4XSk7CkBAIC0xMzAsNyAr
MTMwLDcgQEAgZW5kCiAlISBhc3NlcnQgKGlzZXF1YWwgKEIoMiwxKSwgMCkp
CiAlISBhc3NlcnQgKGlzZXF1YWwgKEIoMSwyKSwgMCkpCiAKLSUhdGVzdAor
JSF4dGVzdAogJSEgQSA9IHN5bShbNSA2XSk7CiAlISBCID0gc3ltKFsxIDI7
IDMgNF0pOwogJSEgQyA9IEEqQjsK
====
EOF
uudecode sympy-1.6.patch.uue > sympy-1.6.patch
tar -xf $SYMBOLIC_ARCHIVE
NEW_SYMBOLIC_ARCHIVE=symbolic-$SYMBOLIC_VER".new.tar.gz"
pushd symbolic-$SYMBOLIC_VER
patch -p1 < ../sympy-1.6.patch
popd
tar -czf $NEW_SYMBOLIC_ARCHIVE symbolic-$SYMBOLIC_VER
rm -Rf symbolic-$SYMBOLIC_VER sympy-1.6.patch.uue sympy-1.6.patch

$OCTAVE_BIN_DIR/octave-cli --eval "pkg install "$NEW_SYMBOLIC_ARCHIVE
rm -f $NEW_SYMBOLIC_ARCHIVE

#
# Installing Octave-Forge packages is done
#
$OCTAVE_BIN_DIR/octave-cli --eval "pkg list"

#
# Install solver packages from GitHub
#

GITHUB_URL="https://github.com/robertgj"

OCTAVE_LOCAL_VERSION=\
"`$OCTAVE_BIN_DIR/octave-cli -q --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SHARE_DIR=$OCTAVE_DIR"/share/octave"
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
$OCTAVE_BIN_DIR/octave-cli -q $OCTAVE_SITE_M_DIR/SDPT3/install_sdpt3.m

# Install YALMIP
if ! test -f YALMIP-develop.zip ; then
   wget -c $GITHUB_URL/YALMIP/archive/develop.zip
   mv develop.zip YALMIP-develop.zip
fi
rm -Rf YALMIP-develop $OCTAVE_SITE_M_DIR/YALMIP
unzip YALMIP-develop.zip 
mv YALMIP-develop $OCTAVE_SITE_M_DIR/YALMIP

# Install SparsePOP
if ! test -f SparsePOP-master.zip ; then
   wget -c $GITHUB_URL/SparsePOP/archive/master.zip
   mv master.zip SparsePOP-master.zip
fi
rm -Rf SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP
unzip SparsePOP-master.zip
find SparsePOP-master -name \*.mex* -exec rm -f {} ';'
mv SparsePOP-master $OCTAVE_SITE_M_DIR/SparsePOP

#
# Solver installation done
#
