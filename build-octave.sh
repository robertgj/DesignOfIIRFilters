#!/bin/sh

# Build a local version of octave-cli
#
# Requires Fedora packages: wget readline-devel lzip sharutils gcc gcc-c++
# gcc-gfortran gmp-devel mpfr-devel make cmake gnuplot-latex m4 gperf 
# bison flex openblas-devel patch texinfo texinfo-tex librsvg2 librsvg2-devel
# librsvg2-tools icoutils autoconf automake libtool pcre pcre-devel freetype
# freetype-devel
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
# Produce code for Intel nehalem CPU. If necessary replace with mtune=generic
#
OPTFLAGS="-m64 -march=nehalem -O2"

#
# Assume these files are present. Get them if they are not.
#

#
# Get Octave archive
#
OCTAVE_VER=6.1.0
OCTAVE_ARCHIVE=octave-$OCTAVE_VER".tar.lz"
OCTAVE_URL=https://ftp.gnu.org/gnu/octave/$OCTAVE_ARCHIVE
if ! test -f $OCTAVE_ARCHIVE; then
  wget -c $OCTAVE_URL
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
LAPACK_VER=${LAPACK_VER:-3.9.1}
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

SUITESPARSE_VER=${SUITESPARSE_VER:-5.9.0}
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

FFTW_VER=${FFTW_VER:-3.3.9}
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

#
# Get octave-forge packages
#
OCTAVE_FORGE_URL=https://sourceforge.net/projects/octave/files/\
Octave%20\Forge%20Packages/Individual%20Package%20Releases/

IO_VER=${IO_VER:-2.6.3}
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

STRUCT_VER=${STRUCT_VER:-1.0.17}
STRUCT_ARCHIVE=struct-$STRUCT_VER".tar.gz"
STRUCT_URL=$OCTAVE_FORGE_URL$STRUCT_ARCHIVE
if ! test -f $STRUCT_ARCHIVE; then
    wget -c $STRUCT_URL 
fi

OPTIM_VER=${OPTIM_VER:-1.6.1}
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

PARALLEL_VER=${PARALLEL_VER:-4.0.1}
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
NjQgLW1hcmNoPW5laGFsZW0KK0NGTEFHUyA9IC1PMyAkKEJMRE9QVFMpCiAK
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
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_DIR --with-blas=-lblas --with-lapack=-llapack
make && make install
popd
rm -Rf arpack-ng-master

#
# Build SuiteSparse
#
rm -Rf SuiteSparse-$SUITESPARSE_VER
tar -xf $SUITESPARSE_ARCHIVE
# Building GraphBLAS is very slow so dont
cat > SuiteSparse-$SUITESPARSE_VER".patch.uue" << 'EOF'
begin-base64 644 SuiteSparse-5.9.0.patch
LS0tIFN1aXRlU3BhcnNlLTUuOS4wL01ha2VmaWxlCTIwMjEtMDMtMDQgMDk6
MDQ6MzMuMDAwMDAwMDAwICsxMTAwCisrKyBTdWl0ZVNwYXJzZS01LjkuMC5u
ZXcvTWFrZWZpbGUJMjAyMS0wNC0yMyAxMDo0MToxMS4xNjMyMTM2MzkgKzEw
MDAKQEAgLTM0LDcgKzM0LDcgQEAKIAkoIGNkIEdQVVFSRW5naW5lICYmICQo
TUFLRSkgKQogZW5kaWYKIAkoIGNkIFNQUVIgJiYgJChNQUtFKSApCi0JKCBj
ZCBHcmFwaEJMQVMgJiYgJChNQUtFKSBKT0JTPSQoSk9CUykgQ01BS0VfT1BU
SU9OUz0nJChDTUFLRV9PUFRJT05TKScgKQorIwkoIGNkIEdyYXBoQkxBUyAm
JiAkKE1BS0UpIEpPQlM9JChKT0JTKSBDTUFLRV9PUFRJT05TPSckKENNQUtF
X09QVElPTlMpJyApCiAJKCBjZCBTTElQX0xVICYmICQoTUFLRSkgKQogIwko
IGNkIFBJUk9fQkFORCAmJiAkKE1BS0UpICkKICMJKCBjZCBTS1lMSU5FX1NW
RCAmJiAkKE1BS0UpICkKQEAgLTYzLDcgKzYzLDcgQEAKIAkoIGNkIEdQVVFS
RW5naW5lICYmICQoTUFLRSkgaW5zdGFsbCApCiBlbmRpZgogCSggY2QgU1BR
UiAmJiAkKE1BS0UpIGluc3RhbGwgKQotCSggY2QgR3JhcGhCTEFTICYmICQo
TUFLRSkgSk9CUz0kKEpPQlMpIENNQUtFX09QVElPTlM9JyQoQ01BS0VfT1BU
SU9OUyknIGluc3RhbGwgKQorIwkoIGNkIEdyYXBoQkxBUyAmJiAkKE1BS0Up
IEpPQlM9JChKT0JTKSBDTUFLRV9PUFRJT05TPSckKENNQUtFX09QVElPTlMp
JyBpbnN0YWxsICkKICMJKCBjZCBQSVJPX0JBTkQgJiYgJChNQUtFKSBpbnN0
YWxsICkKICMJKCBjZCBTS1lMSU5FX1NWRCAmJiAkKE1BS0UpIGluc3RhbGwg
KQogCSggY2QgU0xJUF9MVSAmJiAkKE1BS0UpIGluc3RhbGwgKQpAQCAtMTQ0
LDcgKzE0NCw3IEBACiAJKCBjZCBHUFVRUkVuZ2luZSAmJiAkKE1BS0UpIGxp
YnJhcnkgKQogZW5kaWYKIAkoIGNkIFNQUVIgJiYgJChNQUtFKSBsaWJyYXJ5
ICkKLQkoIGNkIEdyYXBoQkxBUyAmJiAkKE1BS0UpIEpPQlM9JChKT0JTKSBD
TUFLRV9PUFRJT05TPSckKENNQUtFX09QVElPTlMpJyBsaWJyYXJ5ICkKKyMJ
KCBjZCBHcmFwaEJMQVMgJiYgJChNQUtFKSBKT0JTPSQoSk9CUykgQ01BS0Vf
T1BUSU9OUz0nJChDTUFLRV9PUFRJT05TKScgbGlicmFyeSApCiAJKCBjZCBT
TElQX0xVICYmICQoTUFLRSkgbGlicmFyeSApCiAjCSggY2QgUElST19CQU5E
ICYmICQoTUFLRSkgbGlicmFyeSApCiAjCSggY2QgU0tZTElORV9TVkQgJiYg
JChNQUtFKSBsaWJyYXJ5ICkKQEAgLTE3Miw3ICsxNzIsNyBAQAogCSggY2Qg
R1BVUVJFbmdpbmUgJiYgJChNQUtFKSBzdGF0aWMgKQogZW5kaWYKIAkoIGNk
IFNQUVIgJiYgJChNQUtFKSBzdGF0aWMgKQotCSggY2QgR3JhcGhCTEFTICYm
ICQoTUFLRSkgSk9CUz0kKEpPQlMpIENNQUtFX09QVElPTlM9JyQoQ01BS0Vf
T1BUSU9OUyknIHN0YXRpYyApCisjCSggY2QgR3JhcGhCTEFTICYmICQoTUFL
RSkgSk9CUz0kKEpPQlMpIENNQUtFX09QVElPTlM9JyQoQ01BS0VfT1BUSU9O
UyknIHN0YXRpYyApCiAJKCBjZCBTTElQX0xVICYmICQoTUFLRSkgc3RhdGlj
ICkKICMJKCBjZCBQSVJPX0JBTkQgJiYgJChNQUtFKSBzdGF0aWMgKQogIwko
IGNkIFNLWUxJTkVfU1ZEICYmICQoTUFLRSkgc3RhdGljICkKQEAgLTIzMyw3
ICsyMzMsNyBAQAogCiAjIENyZWF0ZSB0aGUgUERGIGRvY3VtZW50YXRpb24K
IGRvY3M6Ci0JKCBjZCBHcmFwaEJMQVMgJiYgJChNQUtFKSBkb2NzICkKKyMJ
KCBjZCBHcmFwaEJMQVMgJiYgJChNQUtFKSBkb2NzICkKIAkoIGNkIE1vbmdv
b3NlICAmJiAkKE1BS0UpIGRvY3MgKQogCSggY2QgQU1EICYmICQoTUFLRSkg
ZG9jcyApCiAJKCBjZCBDQU1EICYmICQoTUFLRSkgZG9jcyApCg==
====
EOF
uudecode SuiteSparse-$SUITESPARSE_VER".patch.uue" > \
	 SuiteSparse-$SUITESPARSE_VER".patch"
pushd SuiteSparse-$SUITESPARSE_VER
patch -p 1 < ../SuiteSparse-$SUITESPARSE_VER".patch"
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS make -j 6 \
      INSTALL=$OCTAVE_DIR OPTIMIZATION=-O2 BLAS=-lblas LAPACK=-llapack install
popd
rm -Rf SuiteSparse-$SUITESPARSE_VER
rm -f SuiteSparse-$SUITESPARSE_VER".patch"
rm -f SuiteSparse-$SUITESPARSE_VER".patch".uue

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
# Build octave
#
rm -Rf octave-$OCTAVE_VER
tar -xf $OCTAVE_ARCHIVE
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-6.1.0.patch
LS0tIG9jdGF2ZS02LjEuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXBhdGgu
Y2MJMjAyMC0xMS0yNyAwNToyMDo0NC4wMDAwMDAwMDAgKzExMDAKKysrIG9j
dGF2ZS02LjEuMC5uZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1wYXRoLmNj
CTIwMjAtMTItMTYgMTQ6MTI6MTMuMDkyNDQ1OTIxICsxMTAwCkBAIC00MDcs
NyArNDA3LDggQEAKICAgICAgICAgYm9vbCBvayA9IGRpLnVwZGF0ZSAoKTsK
IAogICAgICAgICBpZiAoISBvaykKLSAgICAgICAgICB3YXJuaW5nICgibG9h
ZC1wYXRoOiB1cGRhdGUgZmFpbGVkIGZvciAnJXMnLCByZW1vdmluZyBmcm9t
IHBhdGgiLAorICAgICAgICAgIHdhcm5pbmdfd2l0aF9pZCAoIk9jdGF2ZTps
b2FkLXBhdGgtdXBkYXRlLWZhaWxlZCIsCisJCSAgICAgICAgICAgICJsb2Fk
LXBhdGg6IHVwZGF0ZSBmYWlsZWQgZm9yICclcycsIHJlbW92aW5nIGZyb20g
cGF0aCIsCiAgICAgICAgICAgICAgICAgICAgZGkuZGlyX25hbWUuY19zdHIg
KCkpOwogICAgICAgICBlbHNlCiAgICAgICAgICAgYWRkIChkaSwgdHJ1ZSwg
IiIsIHRydWUpOwpAQCAtMTI1OSw3ICsxMjYwLDggQEAKICAgICBpZiAoISBm
cykKICAgICAgIHsKICAgICAgICAgc3RkOjpzdHJpbmcgbXNnID0gZnMuZXJy
b3IgKCk7Ci0gICAgICAgIHdhcm5pbmcgKCJsb2FkX3BhdGg6ICVzOiAlcyIs
IGRpcl9uYW1lLmNfc3RyICgpLCBtc2cuY19zdHIgKCkpOworICAgICAgICB3
YXJuaW5nX3dpdGhfaWQgKCJPY3RhdmU6bG9hZC1wYXRoLWRpci1pbmZvLXVw
ZGF0ZSIsCisJCSAgICAgICAgICAibG9hZF9wYXRoOiAlczogJXMiLCBkaXJf
bmFtZS5jX3N0ciAoKSwgbXNnLmNfc3RyICgpKTsKICAgICAgICAgcmV0dXJu
IGZhbHNlOwogICAgICAgfQogCi0tLSBvY3RhdmUtNi4xLjAvbGliaW50ZXJw
L2NvcmVmY24vbG9hZC1zYXZlLmNjCTIwMjAtMTEtMjcgMDU6MjA6NDQuMDAw
MDAwMDAwICsxMTAwCisrKyBvY3RhdmUtNi4xLjAubmV3L2xpYmludGVycC9j
b3JlZmNuL2xvYWQtc2F2ZS5jYwkyMDIwLTEyLTE2IDE0OjEyOjEzLjA5MzQ0
NTkxMyArMTEwMApAQCAtMTI4LDggKzEyOCw4IEBACiAgIHsKICAgICBjb25z
dCBpbnQgbWFnaWNfbGVuID0gMTA7CiAgICAgY2hhciBtYWdpY1ttYWdpY19s
ZW4rMV07CisgICAgbWVtc2V0KG1hZ2ljLCdcMCcsbWFnaWNfbGVuKzEpOwog
ICAgIGlzLnJlYWQgKG1hZ2ljLCBtYWdpY19sZW4pOwotICAgIG1hZ2ljW21h
Z2ljX2xlbl0gPSAnXDAnOwogCiAgICAgaWYgKHN0cm5jbXAgKG1hZ2ljLCAi
T2N0YXZlLTEtTCIsIG1hZ2ljX2xlbikgPT0gMCkKICAgICAgIHN3YXAgPSBt
YWNoX2luZm86OndvcmRzX2JpZ19lbmRpYW4gKCk7Ci0tLSBvY3RhdmUtNi4x
LjAvbGliaW50ZXJwL2NvcmVmY24vZ3JhcGhpY3MuaW4uaAkyMDIwLTExLTI3
IDA1OjIwOjQ0LjAwMDAwMDAwMCArMTEwMAorKysgb2N0YXZlLTYuMS4wLm5l
dy9saWJpbnRlcnAvY29yZWZjbi9ncmFwaGljcy5pbi5oCTIwMjAtMTItMTYg
MTQ6MTU6MDcuOTYxMDU0MzU2ICsxMTAwCkBAIC00Mjc2LDcgKzQyNzYsNyBA
QAogICAgICAgcmFkaW9fcHJvcGVydHkgbWFya2VyICwgIntub25lfXwrfG98
KnwufHh8c3xzcXVhcmV8ZHxkaWFtb25kfF58dnw+fDx8cHxwZW50YWdyYW18
aHxoZXhhZ3JhbSIKICAgICAgIGNvbG9yX3Byb3BlcnR5IG1hcmtlcmVkZ2Vj
b2xvciAsIGNvbG9yX3Byb3BlcnR5IChyYWRpb192YWx1ZXMgKCJ7YXV0b318
bm9uZSIpLCBjb2xvcl92YWx1ZXMgKDAsIDAsIDApKQogICAgICAgY29sb3Jf
cHJvcGVydHkgbWFya2VyZmFjZWNvbG9yICwgY29sb3JfcHJvcGVydHkgKHJh
ZGlvX3ZhbHVlcyAoImF1dG98e25vbmV9IiksIGNvbG9yX3ZhbHVlcyAoMCwg
MCwgMCkpCi0gICAgICBkb3VibGVfcHJvcGVydHkgbWFya2Vyc2l6ZSAsIDYK
KyAgICAgIGRvdWJsZV9wcm9wZXJ0eSBtYXJrZXJzaXplICwgNAogICAgICAg
cm93X3ZlY3Rvcl9wcm9wZXJ0eSB4ZGF0YSB1ICwgZGVmYXVsdF9kYXRhICgp
CiAgICAgICBzdHJpbmdfcHJvcGVydHkgeGRhdGFzb3VyY2UgLCAiIgogICAg
ICAgcm93X3ZlY3Rvcl9wcm9wZXJ0eSB5ZGF0YSB1ICwgZGVmYXVsdF9kYXRh
ICgpCkBAIC00ODY1LDcgKzQ4NjUsNyBAQAogICAgICAgcmFkaW9fcHJvcGVy
dHkgbWFya2VyICwgIntub25lfXwrfG98KnwufHh8c3xzcXVhcmV8ZHxkaWFt
b25kfF58dnw+fDx8cHxwZW50YWdyYW18aHxoZXhhZ3JhbSIKICAgICAgIGNv
bG9yX3Byb3BlcnR5IG1hcmtlcmVkZ2Vjb2xvciAsIGNvbG9yX3Byb3BlcnR5
IChyYWRpb192YWx1ZXMgKCJub25lfHthdXRvfXxmbGF0IiksIGNvbG9yX3Zh
bHVlcyAoMCwgMCwgMCkpCiAgICAgICBjb2xvcl9wcm9wZXJ0eSBtYXJrZXJm
YWNlY29sb3IgLCBjb2xvcl9wcm9wZXJ0eSAocmFkaW9fdmFsdWVzICgie25v
bmV9fGF1dG98ZmxhdCIpLCBjb2xvcl92YWx1ZXMgKDAsIDAsIDApKQotICAg
ICAgZG91YmxlX3Byb3BlcnR5IG1hcmtlcnNpemUgLCA2CisgICAgICBkb3Vi
bGVfcHJvcGVydHkgbWFya2Vyc2l6ZSAsIDQKICAgICAgIGRvdWJsZV9wcm9w
ZXJ0eSBzcGVjdWxhcmNvbG9ycmVmbGVjdGFuY2UgLCAxLjAKICAgICAgIGRv
dWJsZV9wcm9wZXJ0eSBzcGVjdWxhcmV4cG9uZW50ICwgMTAuMAogICAgICAg
ZG91YmxlX3Byb3BlcnR5IHNwZWN1bGFyc3RyZW5ndGggLCAwLjkKQEAgLTUx
MjUsNyArNTEyNSw3IEBACiAgICAgICByYWRpb19wcm9wZXJ0eSBtYXJrZXIg
LCAie25vbmV9fCt8b3wqfC58eHxzfHNxdWFyZXxkfGRpYW1vbmR8Xnx2fD58
PHxwfHBlbnRhZ3JhbXxofGhleGFncmFtIgogICAgICAgY29sb3JfcHJvcGVy
dHkgbWFya2VyZWRnZWNvbG9yICwgY29sb3JfcHJvcGVydHkgKHJhZGlvX3Zh
bHVlcyAoIm5vbmV8e2F1dG99fGZsYXQiKSwgY29sb3JfdmFsdWVzICgwLCAw
LCAwKSkKICAgICAgIGNvbG9yX3Byb3BlcnR5IG1hcmtlcmZhY2Vjb2xvciAs
IGNvbG9yX3Byb3BlcnR5IChyYWRpb192YWx1ZXMgKCJ7bm9uZX18YXV0b3xm
bGF0IiksIGNvbG9yX3ZhbHVlcyAoMCwgMCwgMCkpCi0gICAgICBkb3VibGVf
cHJvcGVydHkgbWFya2Vyc2l6ZSAsIDYKKyAgICAgIGRvdWJsZV9wcm9wZXJ0
eSBtYXJrZXJzaXplICwgNAogICAgICAgcmFkaW9fcHJvcGVydHkgbWVzaHN0
eWxlICwgIntib3RofXxyb3d8Y29sdW1uIgogICAgICAgZG91YmxlX3Byb3Bl
cnR5IHNwZWN1bGFyY29sb3JyZWZsZWN0YW5jZSAsIDEKICAgICAgIGRvdWJs
ZV9wcm9wZXJ0eSBzcGVjdWxhcmV4cG9uZW50ICwgMTAKLS0tIG9jdGF2ZS02
LjEuMC9zY3JpcHRzL3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3
X2F4ZXNfXy5tCTIwMjAtMTEtMjcgMDU6MjA6NDQuMDAwMDAwMDAwICsxMTAw
CisrKyBvY3RhdmUtNi4xLjAubmV3L3NjcmlwdHMvcGxvdC91dGlsL3ByaXZh
dGUvX19nbnVwbG90X2RyYXdfYXhlc19fLm0JMjAyMC0xMi0xNiAxNDoxMjox
My4wOTU0NDU4OTggKzExMDAKQEAgLTIyNzAsNyArMjI3MCw3IEBACiAgICAg
aWYgKCEgd2FybmVkX2xhdGV4KQogICAgICAgZG9fd2FybiA9ICh3YXJuaW5n
ICgicXVlcnkiLCAiT2N0YXZlOnRleHRfaW50ZXJwcmV0ZXIiKSkuc3RhdGU7
CiAgICAgICBpZiAoc3RyY21wIChkb193YXJuLCAib24iKSkKLSAgICAgICAg
d2FybmluZyAoIk9jdGF2ZTp0ZXh0X2ludGVycHJldGVyIiwKKyAgICAgICAg
d2FybmluZyAoIk9jdGF2ZTpsYXRleC1tYXJrdXAtbm90LXN1cHBvcnRlZC1m
b3ItdGljay1tYXJrcyIsCiAgICAgICAgICAgICAgICAgICJsYXRleCBtYXJr
dXAgbm90IHN1cHBvcnRlZCBmb3IgdGljayBtYXJrcyIpOwogICAgICAgICB3
YXJuZWRfbGF0ZXggPSB0cnVlOwogICAgICAgZW5kaWYKLS0tIG9jdGF2ZS02
LjEuMC9zY3JpcHRzL21pc2NlbGxhbmVvdXMvZGVsZXRlLm0JMjAyMC0xMS0y
NyAwNToyMDo0NC4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS02LjEuMC5u
ZXcvc2NyaXB0cy9taXNjZWxsYW5lb3VzL2RlbGV0ZS5tCTIwMjAtMTItMTYg
MTQ6MTI6MTMuMDk2NDQ1ODkwICsxMTAwCkBAIC00OSw3ICs0OSw4IEBACiAg
ICAgZm9yIGFyZyA9IHZhcmFyZ2luCiAgICAgICBmaWxlcyA9IGdsb2IgKGFy
Z3sxfSk7CiAgICAgICBpZiAoaXNlbXB0eSAoZmlsZXMpKQotICAgICAgICB3
YXJuaW5nICgiZGVsZXRlOiBubyBzdWNoIGZpbGU6ICVzIiwgYXJnezF9KTsK
KyAgICAgICAgd2FybmluZyAoIk9jdGF2ZTpkZWxldGUtbm8tc3VjaC1maWxl
IiwKKwkgICAgICAgICAgImRlbGV0ZTogbm8gc3VjaCBmaWxlOiAlcyIsIGFy
Z3sxfSk7CiAgICAgICBlbmRpZgogICAgICAgZm9yIGkgPSAxOmxlbmd0aCAo
ZmlsZXMpCiAgICAgICAgIGZpbGUgPSBmaWxlc3tpfTsKLS0tIG9jdGF2ZS02
LjEuMC9jb25maWd1cmUJMjAyMC0xMS0yNyAwNToyMDo0NC4wMDAwMDAwMDAg
KzExMDAKKysrIG9jdGF2ZS02LjEuMC5uZXcvY29uZmlndXJlCTIwMjAtMTIt
MTYgMTQ6MTI6MTMuMTAyNDQ1ODQ1ICsxMTAwCkBAIC01OTAsOCArNTkwLDgg
QEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgogUEFDS0FHRV9OQU1F
PSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdvY3RhdmUnCi1QQUNL
QUdFX1ZFUlNJT049JzYuMS4wJwotUEFDS0FHRV9TVFJJTkc9J0dOVSBPY3Rh
dmUgNi4xLjAnCitQQUNLQUdFX1ZFUlNJT049JzYuMS4wLXJvYmonCitQQUNL
QUdFX1NUUklORz0nR05VIE9jdGF2ZSA2LjEuMC1yb2JqJwogUEFDS0FHRV9C
VUdSRVBPUlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdzLmh0bWwnCiBQQUNL
QUdFX1VSTD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0d2FyZS9vY3RhdmUv
JwogCg==
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
rm -Rf build octave-$OCTAVE_VER 
rm -Rf octave-$OCTAVE_VER.patch.uue octave-$OCTAVE_VER.patch

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
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$PARALLEL_ARCHIVE

#
# Fix optim package quadprog function and install the optim package
#
cat > optim-$OPTIM_VER".patch.uue" << 'EOF'
begin-base64 664 optim-1.6.1.patch
LS0tIG9wdGltLTEuNi4wL2luc3Qvb3B0aW1fZG9jLm0JMjAxOS0wMy0xNiAx
NzowMzozNS44Mzg4Mjg5OTggKzExMDAKKysrIG9wdGltLTEuNi4wLm5ldy9p
bnN0L29wdGltX2RvYy5tCTIwMjEtMDEtMTUgMjE6NDA6MzQuMjE2NjEzNzA0
ICsxMTAwCkBAIC0zNSwxMiArMzUsMTQgQEAKICAgcGVyc2lzdGVudCBpbmZv
cGF0aCA9ICIiOwogICBpZiAoaXNlbXB0eSAoaW5mb3BhdGgpKQogICAgIFts
b2NhbF9saXN0LCBnbG9iYWxfbGlzdF0gPSBwa2cgKCJsaXN0Iik7Ci0gICAg
aWYgKCEgaXNlbXB0eSAoaWR4ID0gLi4uCisgICAgaWYgKGxlbmd0aChsb2Nh
bF9saXN0KT4wKSAmJiAuLi4KKyAgICAgICAoISBpc2VtcHR5IChpZHggPSAu
Li4KICAgICAgICAgICAgICAgICAgICBmaW5kIChzdHJjbXAgKCJvcHRpbSIs
CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7c3RydWN0Y2F0
KDEsIGxvY2FsX2xpc3R7On0pLm5hbWV9KSwKICAgICAgICAgICAgICAgICAg
ICAgICAgICAxKSkpCi0gICAgICBpZGlyID0gbG9jYWxfbGlzdHtpZHh9LmRp
cjsKLSAgICBlbHNlaWYgKCEgaXNlbXB0eSAoaWR4ID0gLi4uCisgICAgICBp
ZGlyID0gbG9jYWxfbGlzdHtpZHh9LmRpcjsgCisgICAgZWxzZWlmIChsZW5n
dGgoZ2xvYmFsX2xpc3QpPjApICYmIC4uLgorICAgICAgICAgICAoISBpc2Vt
cHR5IChpZHggPSAuLi4KICAgICAgICAgICAgICAgICAgICAgICAgZmluZCAo
c3RyY21wICgib3B0aW0iLAogICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIHtzdHJ1Y3RjYXQoMSwgZ2xvYmFsX2xpc3R7On0pLm5hbWV9
KSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMSkpKQotLS0gb3B0
aW0tMS42LjAvc3JjL2Vycm9yLWhlbHBlcnMuaAkyMDE5LTAzLTE2IDE3OjAz
OjM1Ljg2NjgyOTQwMSArMTEwMAorKysgb3B0aW0tMS42LjAubmV3L3NyYy9l
cnJvci1oZWxwZXJzLmgJMjAyMS0wMS0xNSAyMjowNDoxNS4yMTM3Mzk1ODgg
KzExMDAKQEAgLTQ1LDEyICs0NSw2IEBACiAgICAgICB7IFwKICAgICAgICAg
Y29kZSA7IFwKICBcCi0gICAgICAgIGlmIChlcnJvcl9zdGF0ZSkgXAotICAg
ICAgICAgIHsgXAotICAgICAgICAgICAgZXJyb3IgKF9fVkFfQVJHU19fKTsg
XAotIFwKLSAgICAgICAgICAgIHJldHVybiByZXR2YWw7IFwKLSAgICAgICAg
ICB9IFwKICAgICAgIH0gXAogICAgIGNhdGNoIChPQ1RBVkVfX0VYRUNVVElP
Tl9FWENFUFRJT04mIGUpIFwKICAgICAgIHsgXApAQCAtNzgsMTIgKzcyLDYg
QEAKICAgICAgIHsgXAogICAgICAgICBjb2RlIDsgXAogIFwKLSAgICAgICAg
aWYgKGVycm9yX3N0YXRlKSBcCi0gICAgICAgICAgeyBcCi0gICAgICAgICAg
ICBfcF9lcnJvciAoX19WQV9BUkdTX18pOyBcCi0gXAotICAgICAgICAgICAg
ZXhpdCAoMSk7IFwKLSAgICAgICAgICB9IFwKICAgICAgIH0gXAogICAgIGNh
dGNoIChPQ1RBVkVfX0VYRUNVVElPTl9FWENFUFRJT04mKSBcCiAgICAgICB7
IFwKQEAgLTExNiwxMSArMTA0LDYgQEAKICAgICB0cnkgXAogICAgICAgeyBc
CiAgICAgICAgIGNvZGUgOyBcCi0gICAgICAgIGlmIChlcnJvcl9zdGF0ZSkg
XAotICAgICAgICAgIHsgXAotICAgICAgICAgICAgZXJyb3Jfc3RhdGUgPSAw
OyBcCi0gICAgICAgICAgICBlcnIgPSB0cnVlOyBcCi0gICAgICAgICAgfSBc
CiAgICAgICB9IFwKICAgICBjYXRjaCAoT0NUQVZFX19FWEVDVVRJT05fRVhD
RVBUSU9OJikgXAogICAgICAgeyBcCg==
====
EOF
uudecode optim-$OPTIM_VER".patch.uue" > optim-$OPTIM_VER".patch"
tar -xf $OPTIM_ARCHIVE
NEW_OPTIM_ARCHIVE=optim-$OPTIM_VER".new.tar.gz"
pushd optim-$OPTIM_VER
patch -p1 < ../optim-$OPTIM_VER".patch"
popd
tar -czf $NEW_OPTIM_ARCHIVE optim-$OPTIM_VER
rm -Rf optim-$OPTIM_VER optim-$OPTIM_VER".patch.uue" optim-$OPTIM_VER".patch"

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_OPTIM_ARCHIVE
rm -f $NEW_OPTIM_ARCHIVE

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

$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$NEW_SIGNAL_ARCHIVE
rm -f $NEW_SIGNAL_ARCHIVE

#
# Fix symbolic package for sympy-1.6 and install the symbolic package
# (Apply sympy-1.6.patch from octave-symbolic_2.9.0-3.debian.tar.xz)
#
cat > sympy-1.6.patch.uue << 'EOF'
begin-base64 644 sympy-1.6.patch
LS0tIHN5bWJvbGljLTIuOS4wL2luc3QvcHJpdmF0ZS9jaGVja19hbmRfY29u
dmVydC5tCTIwMjAtMDMtMDkgMDU6NDM6MTUuMDAwMDAwMDAwICsxMTAwCisr
KyBzeW1ib2xpYy0yLjkuMC5uZXcvL2luc3QvcHJpdmF0ZS9jaGVja19hbmRf
Y29udmVydC5tCTIwMjAtMTItMTMgMTE6NDU6MjUuNzk1MTQ1Mzk1ICsxMTAw
CkBAIC0zMCw4ICszMCw4IEBACiAKICAgICBzcCA9IHB5LnN5bXB5OwogICAg
IF9zeW0gPSBweS50dXBsZSh7c3AuQmFzaWMsIHNwLk1hdHJpeEJhc2V9KTsK
LSAgICBzdHJpbmdfdHlwZXMgPSBzcC5jb21wYXRpYmlsaXR5LnN0cmluZ190
eXBlczsKLSAgICBpbnRlZ2VyX3R5cGVzID0gc3AuY29tcGF0aWJpbGl0eS5p
bnRlZ2VyX3R5cGVzOworICAgIHN0cmluZ190eXBlcyA9IHNpeC5zdHJpbmdf
dHlwZXM7CisgICAgaW50ZWdlcl90eXBlcyA9IHNpeC5pbnRlZ2VyX3R5cGVz
OwogICBlbmQKIAogCi0tLSBzeW1ib2xpYy0yLjkuMC9pbnN0L3ByaXZhdGUv
cHl0aG9uX2lwY19uYXRpdmUubQkyMDIwLTAzLTA5IDA1OjQzOjE1LjAwMDAw
MDAwMCArMTEwMAorKysgc3ltYm9saWMtMi45LjAubmV3Ly9pbnN0L3ByaXZh
dGUvcHl0aG9uX2lwY19uYXRpdmUubQkyMDIwLTEyLTEzIDEyOjE1OjE1LjI2
NTYzMzI3OSArMTEwMApAQCAtODIsNyArODIsNyBAQAogICAgICAgICAgICAg
ICAgICAgICAnaW1wb3J0IGNvbGxlY3Rpb25zJwogICAgICAgICAgICAgICAg
ICAgICAnZnJvbSByZSBpbXBvcnQgc3BsaXQnCiAgICAgICAgICAgICAgICAg
ICAgICcjIHBhdGNoIHByZXR0eSBwcmludGVyLCBpc3N1ZSAjOTUyJwotICAg
ICAgICAgICAgICAgICAgICAnX215cHAgPSBwcmV0dHkuX19nbG9iYWxzX19b
IlByZXR0eVByaW50ZXIiXScKKyAgICAgICAgICAgICAgICAgICAgJ19teXBw
ID0gcHJldHR5JwogICAgICAgICAgICAgICAgICAgICAnZGVmIF9teV9yZXZf
cHJpbnQoY2xzLCBmLCAqKmt3YXJncyk6JwogICAgICAgICAgICAgICAgICAg
ICAnICAgIGcgPSBmLmZ1bmMoKnJldmVyc2VkKGYuYXJncyksIGV2YWx1YXRl
PUZhbHNlKScKICAgICAgICAgICAgICAgICAgICAgJyAgICByZXR1cm4gY2xz
Ll9wcmludF9GdW5jdGlvbihnLCAqKmt3YXJncyknCi0tLSBzeW1ib2xpYy0y
LjkuMC9pbnN0L3ByaXZhdGUvcHl0aG9uX2hlYWRlci5weQkyMDIwLTAzLTA5
IDA1OjQzOjE1LjAwMDAwMDAwMCArMTEwMAorKysgc3ltYm9saWMtMi45LjAu
bmV3Ly9pbnN0L3ByaXZhdGUvcHl0aG9uX2hlYWRlci5weQkyMDIwLTEyLTEz
IDEyOjE1OjQ3Ljc1MjM2MTQ1MSArMTEwMApAQCAtMTEsNiArMTEsNyBAQAog
aW1wb3J0IHN5cwogc3lzLnBzMSA9ICIiOyBzeXMucHMyID0gIiIKIAoraW1w
b3J0IHNpeAogCiBkZWYgZWNob19leGNlcHRpb25fc3Rkb3V0KG15c3RyKToK
ICAgICBleGNlcHRpb25fc3RyID0gc3lzLmV4Y19pbmZvKClbMF0uX19uYW1l
X18gKyAiOiAiICsgc3RyKHN5cy5leGNfaW5mbygpWzFdKQpAQCAtNTAsNyAr
NTEsNyBAQAogICAgIGltcG9ydCBjb2xsZWN0aW9ucwogICAgIGZyb20gcmUg
aW1wb3J0IHNwbGl0CiAgICAgIyBwYXRjaCBwcmV0dHkgcHJpbnRlciwgaXNz
dWUgIzk1MgotICAgIF9teXBwID0gcHJldHR5Ll9fZ2xvYmFsc19fWyJQcmV0
dHlQcmludGVyIl0KKyAgICBfbXlwcCA9IHByZXR0eQogICAgIGRlZiBfbXlf
cmV2X3ByaW50KGNscywgZiwgKiprd2FyZ3MpOgogICAgICAgICBnID0gZi5m
dW5jKCpyZXZlcnNlZChmLmFyZ3MpLCBldmFsdWF0ZT1GYWxzZSkKICAgICAg
ICAgcmV0dXJuIGNscy5fcHJpbnRfRnVuY3Rpb24oZywgKiprd2FyZ3MpCkBA
IC0xODQsNyArMTg1LDcgQEAKICAgICAgICAgICAgIGMgPSBFVC5TdWJFbGVt
ZW50KGV0LCAibGlzdCIpCiAgICAgICAgICAgICBmb3IgeSBpbiB4OgogICAg
ICAgICAgICAgICAgIG9jdG91dHB1dCh5LCBjKQotICAgICAgICBlbGlmIGlz
aW5zdGFuY2UoeCwgc3AuY29tcGF0aWJpbGl0eS5pbnRlZ2VyX3R5cGVzKToK
KyAgICAgICAgZWxpZiBpc2luc3RhbmNlKHgsIHNpeC5pbnRlZ2VyX3R5cGVz
KToKICAgICAgICAgICAgIGEgPSBFVC5TdWJFbGVtZW50KGV0LCAiaXRlbSIp
CiAgICAgICAgICAgICBmID0gRVQuU3ViRWxlbWVudChhLCAiZiIpCiAgICAg
ICAgICAgICBmLnRleHQgPSBzdHIoT0NUQ09ERV9JTlQpCkBAIC0yMDUsNyAr
MjA2LDcgQEAKICAgICAgICAgICAgIGYudGV4dCA9IGQyaGV4KHgucmVhbCkK
ICAgICAgICAgICAgIGYgPSBFVC5TdWJFbGVtZW50KGEsICJmIikKICAgICAg
ICAgICAgIGYudGV4dCA9IGQyaGV4KHguaW1hZykKLSAgICAgICAgZWxpZiBp
c2luc3RhbmNlKHgsIHNwLmNvbXBhdGliaWxpdHkuc3RyaW5nX3R5cGVzKToK
KyAgICAgICAgZWxpZiBpc2luc3RhbmNlKHgsIHNpeC5zdHJpbmdfdHlwZXMp
OgogICAgICAgICAgICAgYSA9IEVULlN1YkVsZW1lbnQoZXQsICJpdGVtIikK
ICAgICAgICAgICAgIGYgPSBFVC5TdWJFbGVtZW50KGEsICJmIikKICAgICAg
ICAgICAgIGYudGV4dCA9IHN0cihPQ1RDT0RFX1NUUikKLS0tIHN5bWJvbGlj
LTIuOS4wL2luc3QvQHN5bS9tcmRpdmlkZS5tCTIwMjAtMDMtMDkgMDU6NDM6
MTUuMDAwMDAwMDAwICsxMTAwCisrKyBzeW1ib2xpYy0yLjkuMC5uZXcvL2lu
c3QvQHN5bS9tcmRpdmlkZS5tCTIwMjAtMTItMTMgMTE6NDU6MjUuNzk1MTQ1
Mzk1ICsxMTAwCkBAIC0xMDEsNyArMTAxLDcgQEAKICUhIGFzc2VydCAoaXNl
cXVhbCAoIEEvMiAsIEQvMiAgKSkKICUhIGFzc2VydCAoaXNlcXVhbCAoIEEv
c3ltKDIpICwgRC8yICApKQogCi0lIXRlc3QKKyUheHRlc3QKICUhICUgSS9B
OiBlaXRoZXIgaW52ZXJ0IEEgb3IgbGVhdmUgdW5ldmFsdWF0ZWQ6IG5vdCBi
b3RoZXJlZCB3aGljaAogJSEgQSA9IHN5bShbMSAyOyAzIDRdKTsKICUhIEIg
PSBzeW0oZXllKDIpKSAvIEE7CkBAIC0xMTMsNyArMTEzLDcgQEAKICUhIEIg
PSBzeW0oJ0ltbXV0YWJsZURlbnNlTWF0cml4KFtbSW50ZWdlcigxKSwgSW50
ZWdlcigyKV0sIFtJbnRlZ2VyKDMpLCBJbnRlZ2VyKDQpXV0pJyk7CiAlISBh
c3NlcnQgKGlzZXF1YWwgKEEvQSwgQi9CKSkKIAotJSF0ZXN0CislIXh0ZXN0
CiAlISAlIEEgPSBDL0IgaXMgQyA9IEEqQgogJSEgQSA9IHN5bShbMSAyOyAz
IDRdKTsKICUhIEIgPSBzeW0oWzEgMzsgNCA4XSk7CkBAIC0xMzAsNyArMTMw
LDcgQEAKICUhIGFzc2VydCAoaXNlcXVhbCAoQigyLDEpLCAwKSkKICUhIGFz
c2VydCAoaXNlcXVhbCAoQigxLDIpLCAwKSkKIAotJSF0ZXN0CislIXh0ZXN0
CiAlISBBID0gc3ltKFs1IDZdKTsKICUhIEIgPSBzeW0oWzEgMjsgMyA0XSk7
CiAlISBDID0gQSpCOwotLS0gc3ltYm9saWMtMi45LjAvaW5zdC9Ac3ltL2Rz
b2x2ZS5tCTIwMjAtMDMtMDkgMDU6NDM6MTUuMDAwMDAwMDAwICsxMTAwCisr
KyBzeW1ib2xpYy0yLjkuMC5uZXcvL2luc3QvQHN5bS9kc29sdmUubQkyMDIw
LTEyLTEzIDExOjQ1OjI1Ljc5NTE0NTM5NSArMTEwMApAQCAtMjY2LDcgKzI2
Niw3IEBACiAlISBnID0gMypzaW4oMip4KSp0YW4oc3ltKCcyJykpKzMqY29z
KDIqeCk7CiAlISBhc3NlcnQgKGlzZXF1YWwgKHJocyhmKSwgZykpCiAKLSUh
dGVzdAorJSF4dGVzdAogJSEgJSBTeXN0ZW0gb2YgT0RFcwogJSEgc3ltcyB4
KHQpIHkodCkgQzEgQzIKICUhIG9kZTEgPSBkaWZmKHgodCksdCkgPT0gMip5
KHQpOwotLS0gc3ltYm9saWMtMi45LjAvaW5zdC9Ac3ltL21wb3dlci5tCTIw
MjAtMDMtMDkgMDU6NDM6MTUuMDAwMDAwMDAwICsxMTAwCisrKyBzeW1ib2xp
Yy0yLjkuMC5uZXcvL2luc3QvQHN5bS9tcG93ZXIubQkyMDIwLTEyLTEzIDEx
OjQ1OjI1Ljc5NTE0NTM5NSArMTEwMApAQCAtMTMwLDcgKzEzMCw3IEBACiAl
ISBDID0gc3VicyhCLCBuLCAwKTsKICUhIGFzc2VydCAoaXNlcXVhbCAoQywg
c3ltKGV5ZSgyKSkpKQogCi0lIXRlc3QKKyUheHRlc3QKICUhICUgc2NhbGFy
XmFycmF5IG5vdCBpbXBsZW1lbnRlZCBpbiBTeW1QeSA8IDEuMAogJSEgc3lt
cyB4CiAlISBBID0gWzEgMjsgMyA0XTsK
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
