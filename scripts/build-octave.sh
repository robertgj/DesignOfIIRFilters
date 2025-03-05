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
# java-17-openjdk-devel xerces-j2
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
OCTAVE_VER=${OCTAVE_VER:-9.4.0}
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
OCTAVE_INSTALL_DIR="/usr/local/octave-"$OCTAVE_VER
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

SUITESPARSE_VER=${SUITESPARSE_VER:-7.10.0}
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

SUNDIALS_VER=${SUNDIALS_VER:-7.2.1}
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

CONTROL_VER=${CONTROL_VER:-4.1.1}
CONTROL_ARCHIVE=control-$CONTROL_VER".tar.gz"
CONTROL_URL="https://github.com/gnu-octave/pkg-control/releases/download/control-"$CONTROL_VER/$CONTROL_ARCHIVE
if ! test -f $CONTROL_ARCHIVE; then
  wget -c $CONTROL_URL 
fi

IO_VER=${IO_VER:-2.6.4}
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

PIQP_VER=${PIQP_VER:-0.4.1}
PIQP_ARCHIVE=piqp-octave.tar.gz
PIQP_URL=https://github.com/PREDICT-EPFL/piqp/releases/download/v$PIQP_VER/$PIQP_ARCHIVE
if ! test -f $PIQP_ARCHIVE; then
  wget -c $PIQP_URL 
fi

SIGNAL_VER=${SIGNAL_VER:-1.4.6}
SIGNAL_ARCHIVE=signal-$SIGNAL_VER".tar.gz"
SIGNAL_URL=$OCTAVE_FORGE_URL/$SIGNAL_ARCHIVE
if ! test -f $SIGNAL_ARCHIVE; then
  wget -c $SIGNAL_URL 
fi

STATISTICS_VER=${STATISTICS_VER:-1.7.3}
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

SYMBOLIC_VER=${SYMBOLIC_VER:-3.2.1}
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
cat > lapack-$LAPACK_VER.patch.uue << 'EOF'
begin-base64 644 lapack-3.12.1.patch
LS0tIGxhcGFjay0zLjEyLjEvQkxBUy9TUkMvTWFrZWZpbGUJMjAyNC0xMi0w
MyAyMjozOToxMS4wMDAwMDAwMDAgKzExMDAKKysrIGxhcGFjay0zLjEyLjEu
bmV3L0JMQVMvU1JDL01ha2VmaWxlCTIwMjUtMDEtMTQgMTg6NTQ6MzUuODQ3
Nzk2MDY2ICsxMTAwCkBAIC0xNDksNiArMTQ5LDkgQEAKIAkkKEFSKSAkKEFS
RkxBR1MpICRAICReCiAJJChSQU5MSUIpICRACiAKKyQobm90ZGlyICQoQkxB
U0xJQjolLmE9JS5zbykpOiAkKEFMTE9CSikKKwkkKEZDKSAtc2hhcmVkIC1X
bCwtc29uYW1lLCRAIC1vICRAICReCisKIC5QSE9OWTogc2luZ2xlIGRvdWJs
ZSBjb21wbGV4IGNvbXBsZXgxNgogc2luZ2xlOiAkKFNCTEFTMSkgJChBTExC
TEFTKSAkKFNCTEFTMikgJChTQkxBUzMpCiAJJChBUikgJChBUkZMQUdTKSAk
KEJMQVNMSUIpICReCi0tLSBsYXBhY2stMy4xMi4xL0lOU1RBTEwvbWFrZS5p
bmMuZ2ZvcnRyYW4tcXVhZAkyMDI0LTEyLTAzIDIyOjM5OjExLjAwMDAwMDAw
MCArMTEwMAorKysgbGFwYWNrLTMuMTIuMS5uZXcvSU5TVEFMTC9tYWtlLmlu
Yy5nZm9ydHJhbi1xdWFkCTIwMjUtMDEtMTQgMTg6NTQ6MzUuODQ4Nzk2MDYy
ICsxMTAwCkBAIC03LDcgKzcsOCBAQAogIyAgQ0MgaXMgdGhlIEMgY29tcGls
ZXIsIG5vcm1hbGx5IGludm9rZWQgd2l0aCBvcHRpb25zIENGTEFHUy4KICMK
IENDID0gZ2NjCi1DRkxBR1MgPSAtTzMKK0JMRE9QVFMgPSAtZlBJQyAtbTY0
IC1tYXJjaD1uZWhhbGVtCitDRkxBR1MgPSAtTzMgJChCTERPUFRTKQogCiAj
ICBNb2RpZnkgdGhlIEZDIGFuZCBGRkxBR1MgZGVmaW5pdGlvbnMgdG8gdGhl
IGRlc2lyZWQgY29tcGlsZXIKICMgIGFuZCBkZXNpcmVkIGNvbXBpbGVyIG9w
dGlvbnMgZm9yIHlvdXIgbWFjaGluZS4gIE5PT1BUIHJlZmVycyB0bwpAQCAt
MjQsMTAgKzI1LDEwIEBACiAjICBzKi9jKiBhbmQgZCoveiogZW50cnkgcG9p
bnRzIHdpbGwgZXhwZWN0IDEyOC1iaXQgZmxvYXRpbmctcG9pbnQKICMgIHR5
cGUuCiAjCi1GQyA9IGdmb3J0cmFuCi1GRkxBR1MgPSAtTzIgLWZyZWN1cnNp
dmUgLWZyZWFsLTQtcmVhbC0xNiAtZnJlYWwtOC1yZWFsLTE2CitGQyA9IGdm
b3J0cmFuIC1mcmVjdXJzaXZlICQoQkxET1BUUykKK0ZGTEFHUyA9IC1PMiAt
ZnJlYWwtOC1yZWFsLTE2CiBGRkxBR1NfRFJWID0gJChGRkxBR1MpCi1GRkxB
R1NfTk9PUFQgPSAtTzAgLWZyZWN1cnNpdmUgLWZyZWFsLTQtcmVhbC0xNiAt
ZnJlYWwtOC1yZWFsLTE2CitGRkxBR1NfTk9PUFQgPSAtTzAgLWZyZWFsLTgt
cmVhbC0xNgogCiAjICBEZWZpbmUgTERGTEFHUyB0byB0aGUgZGVzaXJlZCBs
aW5rZXIgb3B0aW9ucyBmb3IgeW91ciBtYWNoaW5lLgogIwpAQCAtNjIsNyAr
NjMsNyBAQAogIyAgVW5jb21tZW50IHRoZSBmb2xsb3dpbmcgbGluZSB0byBp
bmNsdWRlIGRlcHJlY2F0ZWQgcm91dGluZXMgaW4KICMgIHRoZSBMQVBBQ0sg
bGlicmFyeS4KICMKLSNCVUlMRF9ERVBSRUNBVEVEID0gWWVzCitCVUlMRF9E
RVBSRUNBVEVEID0gWWVzCiAKICMgIExBUEFDS0UgaGFzIHRoZSBpbnRlcmZh
Y2UgdG8gc29tZSByb3V0aW5lcyBmcm9tIHRtZ2xpYi4KICMgIElmIExBUEFD
S0VfV0lUSF9UTUcgaXMgZGVmaW5lZCwgYWRkIHRob3NlIHJvdXRpbmVzIHRv
IExBUEFDS0UuCkBAIC04MSw4ICs4MiwxMyBAQAogIyAgbWFjaGluZS1zcGVj
aWZpYywgb3B0aW1pemVkIEJMQVMgbGlicmFyeSBzaG91bGQgYmUgdXNlZCB3
aGVuZXZlcgogIyAgcG9zc2libGUuKQogIwotQkxBU0xJQiAgICAgID0gJChU
T1BTUkNESVIpL2xpYnJlZmJsYXMuYQotQ0JMQVNMSUIgICAgID0gJChUT1BT
UkNESVIpL2xpYmNibGFzLmEKLUxBUEFDS0xJQiAgICA9ICQoVE9QU1JDRElS
KS9saWJsYXBhY2suYQotVE1HTElCICAgICAgID0gJChUT1BTUkNESVIpL2xp
YnRtZ2xpYi5hCi1MQVBBQ0tFTElCICAgPSAkKFRPUFNSQ0RJUikvbGlibGFw
YWNrZS5hCitCTEFTTElCICAgICAgPSBsaWJxYmxhcy5hCitDQkxBU0xJQiAg
ICAgPSBsaWJxY2JsYXMuYQorTEFQQUNLTElCICAgID0gbGlicWxhcGFjay5h
CitUTUdMSUIgICAgICAgPSBsaWJxdG1nbGliLmEKK0xBUEFDS0VMSUIgICA9
IGxpYnFsYXBhY2tlLmEKKworIyAgRE9DVU1FTlRBVElPTiBESVJFQ1RPUlkK
KyMgSWYgeW91IGdlbmVyYXRlIGh0bWwgcGFnZXMgKG1ha2UgaHRtbCksIGRv
Y3VtZW50YXRpb24gd2lsbCBiZSBwbGFjZWQgaW4gJChET0NTRElSKS9leHBs
b3JlLWh0bWwKKyMgSWYgeW91IGdlbmVyYXRlIG1hbiBwYWdlcyAobWFrZSBt
YW4pLCBkb2N1bWVudGF0aW9uIHdpbGwgYmUgcGxhY2VkIGluICQoRE9DU0RJ
UikvbWFuCitET0NTRElSICAgICAgID0gJChUT1BTUkNESVIpL0RPQ1MKLS0t
IGxhcGFjay0zLjEyLjEvU1JDL01ha2VmaWxlCTIwMjQtMTItMDMgMjI6Mzk6
MTEuMDAwMDAwMDAwICsxMTAwCisrKyBsYXBhY2stMy4xMi4xLm5ldy9TUkMv
TWFrZWZpbGUJMjAyNS0wMS0xNCAxODo1NDozNS44NDg3OTYwNjIgKzExMDAK
QEAgLTU2MSw2ICs1NjEsOSBAQAogCSQoQVIpICQoQVJGTEFHUykgJEAgJF4K
IAkkKFJBTkxJQikgJEAKIAorJChub3RkaXIgJChMQVBBQ0tMSUI6JS5hPSUu
c28pKTogJChBTExPQkopICQoQUxMWE9CSikgJChERVBSRUNBVEVEKQorCSQo
RkMpIC1zaGFyZWQgLVdsLC1zb25hbWUsJEAgLW8gJEAgJF4KKwogLlBIT05Z
OiBzaW5nbGUgY29tcGxleCBkb3VibGUgY29tcGxleDE2CiAKIFNJTkdMRV9E
RVBTIDo9ICQoU0xBU1JDKSAkKERTTEFTUkMpCi0tLSBsYXBhY2stMy4xMi4x
L21ha2UuaW5jLmV4YW1wbGUJMjAyNC0xMi0wMyAyMjozOToxMS4wMDAwMDAw
MDAgKzExMDAKKysrIGxhcGFjay0zLjEyLjEubmV3L21ha2UuaW5jLmV4YW1w
bGUJMjAyNS0wMS0xNCAxODo1NDozNS44NDk3OTYwNTkgKzExMDAKQEAgLTcs
NyArNyw4IEBACiAjICBDQyBpcyB0aGUgQyBjb21waWxlciwgbm9ybWFsbHkg
aW52b2tlZCB3aXRoIG9wdGlvbnMgQ0ZMQUdTLgogIwogQ0MgPSBnY2MKLUNG
TEFHUyA9IC1PMworQkxET1BUUyA9IC1mUElDIC1tNjQgLW1hcmNoPW5laGFs
ZW0KK0NGTEFHUyA9IC1PMyAkKEJMRE9QVFMpCiAKICMgIE1vZGlmeSB0aGUg
RkMgYW5kIEZGTEFHUyBkZWZpbml0aW9ucyB0byB0aGUgZGVzaXJlZCBjb21w
aWxlcgogIyAgYW5kIGRlc2lyZWQgY29tcGlsZXIgb3B0aW9ucyBmb3IgeW91
ciBtYWNoaW5lLiAgTk9PUFQgcmVmZXJzIHRvCkBAIC0xNywxMCArMTgsMTAg
QEAKICMgIGFuZCBoYW5kbGUgdGhlc2UgcXVhbnRpdGllcyBhcHByb3ByaWF0
ZWx5LiBBcyBhIGNvbnNlcXVlbmNlLCBvbmUKICMgIHNob3VsZCBub3QgY29t
cGlsZSBMQVBBQ0sgd2l0aCBmbGFncyBzdWNoIGFzIC1mZnBlLXRyYXA9b3Zl
cmZsb3cuCiAjCi1GQyA9IGdmb3J0cmFuCi1GRkxBR1MgPSAtTzIgLWZyZWN1
cnNpdmUKK0ZDID0gZ2ZvcnRyYW4gLWZyZWN1cnNpdmUgJChCTERPUFRTKQor
RkZMQUdTID0gLU8yICMgLWZyZWFsLTgtcmVhbC0xNgogRkZMQUdTX0RSViA9
ICQoRkZMQUdTKQotRkZMQUdTX05PT1BUID0gLU8wIC1mcmVjdXJzaXZlCitG
RkxBR1NfTk9PUFQgPSAtTzAKIAogIyAgRGVmaW5lIExERkxBR1MgdG8gdGhl
IGRlc2lyZWQgbGlua2VyIG9wdGlvbnMgZm9yIHlvdXIgbWFjaGluZS4KICMK
QEAgLTU1LDcgKzU2LDcgQEAKICMgIFVuY29tbWVudCB0aGUgZm9sbG93aW5n
IGxpbmUgdG8gaW5jbHVkZSBkZXByZWNhdGVkIHJvdXRpbmVzIGluCiAjICB0
aGUgTEFQQUNLIGxpYnJhcnkuCiAjCi0jQlVJTERfREVQUkVDQVRFRCA9IFll
cworQlVJTERfREVQUkVDQVRFRCA9IFllcwogCiAjICBMQVBBQ0tFIGhhcyB0
aGUgaW50ZXJmYWNlIHRvIHNvbWUgcm91dGluZXMgZnJvbSB0bWdsaWIuCiAj
ICBJZiBMQVBBQ0tFX1dJVEhfVE1HIGlzIGRlZmluZWQsIGFkZCB0aG9zZSBy
b3V0aW5lcyB0byBMQVBBQ0tFLgpAQCAtNzQsMTEgKzc1LDExIEBACiAjICBt
YWNoaW5lLXNwZWNpZmljLCBvcHRpbWl6ZWQgQkxBUyBsaWJyYXJ5IHNob3Vs
ZCBiZSB1c2VkIHdoZW5ldmVyCiAjICBwb3NzaWJsZS4pCiAjCi1CTEFTTElC
ICAgICAgPSAkKFRPUFNSQ0RJUikvbGlicmVmYmxhcy5hCi1DQkxBU0xJQiAg
ICAgPSAkKFRPUFNSQ0RJUikvbGliY2JsYXMuYQotTEFQQUNLTElCICAgID0g
JChUT1BTUkNESVIpL2xpYmxhcGFjay5hCi1UTUdMSUIgICAgICAgPSAkKFRP
UFNSQ0RJUikvbGlidG1nbGliLmEKLUxBUEFDS0VMSUIgICA9ICQoVE9QU1JD
RElSKS9saWJsYXBhY2tlLmEKK0JMQVNMSUIgICAgICA9IGxpYmJsYXMuYQor
Q0JMQVNMSUIgICAgID0gbGliY2JsYXMuYQorTEFQQUNLTElCICAgID0gbGli
bGFwYWNrLmEKK1RNR0xJQiAgICAgICA9IGxpYnRtZ2xpYi5hCitMQVBBQ0tF
TElCICAgPSBsaWJsYXBhY2tlLmEKIAogIyAgRE9DVU1FTlRBVElPTiBESVJF
Q1RPUlkKICMgSWYgeW91IGdlbmVyYXRlIGh0bWwgcGFnZXMgKG1ha2UgaHRt
bCksIGRvY3VtZW50YXRpb24gd2lsbCBiZSBwbGFjZWQgaW4gJChET0NTRElS
KS9leHBsb3JlLWh0bWwK
====
EOF
uudecode lapack-$LAPACK_VER".patch.uue"
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
make -j 6 libblas.a libblas.so
popd
# Make liblapack.so
pushd lapack-$LAPACK_VER/SRC
make -j 6 liblapack.a liblapack.so
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
make -j 6 libqblas.a
popd
# Make libqlapack.a
pushd lapack-$LAPACK_VER/SRC
make -j 6 libqlapack.a
popd
# Install
mv -f lapack-$LAPACK_VER/BLAS/SRC/libqblas.a $OCTAVE_LIB_DIR
mv -f lapack-$LAPACK_VER/SRC/libqlapack.a $OCTAVE_LIB_DIR
# Cleanup
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
./configure --prefix=$OCTAVE_INSTALL_DIR --with-blas=-lblas --with-lapack=-llapack
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
make PREFIX=$OCTAVE_INSTALL_DIR solib install
popd
rm -Rf qrupdate-$QRUPDATE_VER

#
# Build glpk
#
rm -Rf glpk-$GLPK_VER
tar -xf $GLPK_ARCHIVE
pushd glpk-$GLPK_VER
CFLAGS=$OPTFLAGS CXXFLAGS=$OPTFLAGS FFLAGS=$OPTFLAGS \
./configure --prefix=$OCTAVE_INSTALL_DIR
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
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-9.4.0.patch
LS0tIG9jdGF2ZS05LjQuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXNhdmUu
Y2MJMjAyNS0wMi0wNiAwNDowMTowNS4wMDAwMDAwMDAgKzExMDAKKysrIG9j
dGF2ZS05LjQuMC5uZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1zYXZlLmNj
CTIwMjUtMDMtMDQgMTY6Mjk6MTMuODc4NTM2MzIwICsxMTAwCkBAIC0xMjks
OCArMTI5LDggQEAKIHsKICAgY29uc3QgaW50IG1hZ2ljX2xlbiA9IDEwOwog
ICBjaGFyIG1hZ2ljW21hZ2ljX2xlbisxXTsKLSAgaXMucmVhZCAobWFnaWMs
IG1hZ2ljX2xlbik7CiAgIG1hZ2ljW21hZ2ljX2xlbl0gPSAnXDAnOworICBp
cy5yZWFkIChtYWdpYywgbWFnaWNfbGVuKTsKIAogICBpZiAoc3RybmNtcCAo
bWFnaWMsICJPY3RhdmUtMS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAgIHN3
YXAgPSBtYWNoX2luZm86OndvcmRzX2JpZ19lbmRpYW4gKCk7Ci0tLSBvY3Rh
dmUtOS40LjAvc2NyaXB0cy9zZXQvdW5pcXVlLm0JMjAyNS0wMi0wNiAwNDow
MTowNS4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS05LjQuMC5uZXcvc2Ny
aXB0cy9zZXQvdW5pcXVlLm0JMjAyNS0wMy0wNCAxNjoyOToxMy44Nzk1NDYx
OTYgKzExMDAKQEAgLTg0LDkgKzg0LDYgQEAKICMjIG91dHB1dHMgQHZhcntp
fSwgQHZhcntqfSB3aWxsIGZvbGxvdyB0aGUgc2hhcGUgb2YgdGhlIGlucHV0
IEB2YXJ7eH0gcmF0aGVyCiAjIyB0aGFuIGFsd2F5cyBiZWluZyBjb2x1bW4g
dmVjdG9ycy4KICMjCi0jIyBUaGUgdGhpcmQgb3V0cHV0LCBAdmFye2p9LCBo
YXMgbm90IGJlZW4gaW1wbGVtZW50ZWQgeWV0IHdoZW4gdGhlIHNvcnQKLSMj
IG9yZGVyIGlzIEBxY29kZXsic3RhYmxlIn0uCi0jIwogIyMgQHNlZWFsc297
dW5pcXVldG9sLCB1bmlvbiwgaW50ZXJzZWN0LCBzZXRkaWZmLCBzZXR4b3Is
IGlzbWVtYmVyfQogIyMgQGVuZCBkZWZ0eXBlZm4KIApAQCAtMjMwLDM2ICsy
MjcsODYgQEAKICAgICBlbmRpZgogICBlbmRpZgogCi0gICMjIENhbGN1bGF0
ZSBqIG91dHB1dCAoM3JkIG91dHB1dCkKLSAgaWYgKG5hcmdvdXQgPiAyKQot
ICAgIGogPSBpOyAgIyBjaGVhcCB3YXkgdG8gY29weSBkaW1lbnNpb25zCi0g
ICAgaihpKSA9IGN1bXN1bSAoWzE7ICEgbWF0Y2goOildKTsKLSAgICBpZiAo
ISBvcHRzb3J0ZWQpCi0gICAgICB3YXJuaW5nICgidW5pcXVlOiB0aGlyZCBv
dXRwdXQgSiBpcyBub3QgeWV0IGltcGxlbWVudGVkIik7Ci0gICAgICBqID0g
W107Ci0gICAgZW5kaWYKLQotICAgIGlmIChvcHRsZWdhY3kgJiYgaXNyb3d2
ZWMpCi0gICAgICBqID0gai4nOwotICAgIGVuZGlmCi0gIGVuZGlmCi0KICAg
IyMgQ2FsY3VsYXRlIGkgb3V0cHV0ICgybmQgb3V0cHV0KQogICBpZiAobmFy
Z291dCA+IDEpCisKICAgICBpZiAob3B0c29ydGVkKQorCiAgICAgICBpZHgg
PSBmaW5kIChtYXRjaCk7CisKICAgICAgIGlmICghIG9wdGxlZ2FjeSAmJiBv
cHRmaXJzdCkKICAgICAgICAgaWR4ICs9IDE7ICAgIyBpbi1wbGFjZSBpcyBm
YXN0ZXIgdGhhbiBvdGhlciBmb3JtcyBvZiBpbmNyZW1lbnQKICAgICAgIGVu
ZGlmCisKKyAgICAgIGlmIChuYXJnb3V0ID4gMikKKyAgICAgICAgaiA9IGk7
ICAjIGNoZWFwIHdheSB0byBjb3B5IGRpbWVuc2lvbnMKKyAgICAgICAgaihp
KSA9IGN1bXN1bSAoISBbZmFsc2U7IG1hdGNoKDopXSk7CisgICAgICBlbmRp
ZgorCiAgICAgICBpKGlkeCkgPSBbXTsKKwogICAgIGVsc2UKLSAgICAgIGko
W2ZhbHNlOyBtYXRjaCg6KV0pID0gW107Ci0gICAgICAjIyBGSVhNRTogSXMg
dGhlcmUgYSB3YXkgdG8gYXZvaWQgYSBjYWxsIHRvIHNvcnQ/Ci0gICAgICBp
ID0gc29ydCAoaSk7CisKKyAgICAgICMjIEdldCBpbnZlcnNlIG9mIHNvcnQg
aW5kZXggaSBzbyB0aGF0IHNvcnQoeCkoaykgPSB4LgorICAgICAgayA9IGk7
ICAjIGNoZWFwIHdheSB0byBjb3B5IGRpbWVuc2lvbnMKKyAgICAgIGsoaSkg
PSAxOm47CisKKyAgICAgIGlmIChuYXJnb3V0ID4gMikKKworICAgICAgICAj
IyBHZW5lcmF0ZSBsb2dpY2FsIGluZGV4IG9mIHNvcnRlZCB1bmlxdWUgdmFs
dWUgbG9jYXRpb25zLgorICAgICAgICBub21hdGNoID0gISBbZmFsc2U7IG1h
dGNoKDopXTsKKworICAgICAgICAjIyBDYWxjdWxhdGUgaSBvdXRwdXQgYXMg
dGhvc2UgbG9jYXRpb25zIHJlbWFwcGVkIHRvIHVuc29ydGVkIHguCisgICAg
ICAgIGlfb3V0ID0gZmluZCAobm9tYXRjaChrKSk7CisKKyAgICAgICAgIyMg
RmluZCB0aGUgbGluZWFyIGluZGV4ZXMgb2YgdGhlIHVuaXF1ZSBlbGVtZW50
cyBvZiBzb3J0KHgpLgorICAgICAgICB1ID0gZmluZCAobm9tYXRjaCk7CisK
KyAgICAgICAgIyMgRmluZCB1bmlxdWUgaW5kZXhlcyBmb3IgYWxsIGVsZW1l
bnQgbG9jYXRpb25zIC4KKyAgICAgICAgbCA9IHUoY3Vtc3VtIChub21hdGNo
KSk7CisKKyAgICAgICAgIyMgbChrKSBnaXZlcyB1IGVsZW1lbnQgbG9jYXRp
b25zIG1hcHBlZCBiYWNrIHRvIHVuc29ydGVkIHguIEUuZy4sCisgICAgICAg
ICMjIGZvciB4ID0gWzQwLDIwLDQwLDIwLDIwLDMwLDEwXScgIyBkYXRhCisg
ICAgICAgICMjIGkgPSAgIFs3LDIsNCw1LDYsMSwzXScgICAgICAgICAgIyBz
b3J0KHgpIGluZGV4LCB4KGkpID0gc29ydCh4KQorICAgICAgICAjIyBub21h
dGNoID0gWzEsMSwwLDAsMSwxLDBdJyAgICAgICMgbG9naWNhbCBzb3J0ZWQg
aW5kZXggb2YgdW5pcXVlIHgKKyAgICAgICAgIyMgaV9vdXQgPSBbMSwyLDYs
N10nICAgICAgICAgICAgICAjIHVuaXF1ZSBvdXRwdXQgaW5kZXgsIHkgPSB4
KGlfb3V0KQorICAgICAgICAjIyBrID0gWzYsMiw3LDMsNCw1LDFdJyAgICAg
ICAgICAgICMgaW52ZXJzZSBpZHggb2YgaSwgc29ydCh4KShrKSA9IHgKKyAg
ICAgICAgIyMgbCA9IFsxLDIsMiwyLDUsNiw2XScgICAgICAgICAgICAjIHVu
aXF1ZSBlbGVtLiB0byByZXByb2R1Y2Ugc29ydCh4KQorICAgICAgICAjIyBs
KGspID0gWzYsMiw2LDIsMiw1LDFdJyAgICAgICAgICMgdW5pcXVlIGVsZW1l
bnRzIHRvIHJlcHJvZHVjZSAoeCkKKyAgICAgICAgIyMgaShsKGspKSA9ICBb
MSwyLDEsMiwyLDYsN10nICAgICAjIHVuaXF1ZSBlbGVtLiBtYXBwZWQgdG8g
c29ydCh4KWlkeAorICAgICAgICAjIworICAgICAgICAjIyBpX291dCA9PSBp
KGwoaykpJyBicm9hZGNhc3RzIHRvOgorICAgICAgICAjIyAgWyAxICAxICAw
ICAwICAwICAwICAwCisgICAgICAgICMjICAgIDAgIDAgIDEgIDEgIDEgIDAg
IDAKKyAgICAgICAgIyMgICAgMCAgMCAgMCAgMCAgMCAgMSAgMAorICAgICAg
ICAjIyAgICAwICAwICAwICAwICAwICAwICAxIF0KKyAgICAgICAgIyMgUm93
IHZhbHVlIG9mIGVhY2ggY29sdW1uIG1hcHMgaShsKGspKSB0byBpX291dCwg
Z2l2ZXMgaiBmb3IgeShqKT14CisKKyAgICAgICAgIyMgRklYTUU6IDItRCBw
cm9qZWN0aW9uIHRvIGZpbmQgaiBpbmNyZWFzZXMgbGFyZ2VzdCBzdG9yZWQg
ZWxlbWVudAorICAgICAgICAjIyAgICAgICAgZnJvbSBuIHRvIG0geCBuICht
ID0gbnVtZWwgKHkpKSBhbmQgdXNlcyBzbG93ZXIgZmluZAorICAgICAgICAj
IyAgICAgICAgY29kZXBhdGguICBJZGVhbGx5IHdvdWxkIGJlIHJlcGxhY2Vk
IGJ5IGRpcmVjdCBsaW5lYXIgb3IKKyAgICAgICAgIyMgICAgICAgIGxvZ2lj
YWwgaW5kZXhpbmcuCisKKyAgICAgICAgW2osfl0gPSBmaW5kIChpX291dCA9
PSBpKGwoaykpJyk7CisKKyAgICAgICAgIyMgUmVwbGFjZSBmdWxsIHgtPiBz
b3J0KHgpIG91dHB1dCB3aXRoIGR1cGxpY2F0ZXMgcmVtb3ZlZC4KKyAgICAg
ICAgaSA9IGlfb3V0OworICAgICAgZWxzZQorCisgICAgICAgICMjIEZpbmQg
aSBvdXRwdXQgYXMgdW5pcXVlIHZhbHVlIGxvY2F0aW9ucyByZW1hcHBlZCB0
byB1bnNvcnRlZCB4LgorICAgICAgICBpID0gZmluZCAoISBbZmFsc2U7IG1h
dGNoKDopXShrKSk7CisKKyAgICAgIGVuZGlmCisKICAgICBlbmRpZgogCiAg
ICAgaWYgKG9wdGxlZ2FjeSAmJiBpc3Jvd3ZlYykKICAgICAgIGkgPSBpLic7
CisKKyAgICAgIGlmIChuYXJnb3V0ID4gMikKKyAgICAgICAgaiA9IGouJzsK
KyAgICAgIGVuZGlmCisKICAgICBlbmRpZgogICBlbmRpZgogCkBAIC0zMDIs
MTEgKzM0OSwxMCBAQAogJSEgYXNzZXJ0IChqLCBbMTsxOzI7MzszOzM7NF0p
OwogCiAlIXRlc3QKLSUhIFt5LGksfl0gPSB1bmlxdWUgKFs0LDQsMiwyLDIs
MywxXSwgInN0YWJsZSIpOworJSEgW3ksaSxqXSA9IHVuaXF1ZSAoWzQsNCwy
LDIsMiwzLDFdLCAic3RhYmxlIik7CiAlISBhc3NlcnQgKHksIFs0LDIsMywx
XSk7CiAlISBhc3NlcnQgKGksIFsxOzM7Njs3XSk7Ci0lISAjIyBGSVhNRTog
J2onIGlucHV0IG5vdCBjYWxjdWxhdGVkIHdpdGggc3RhYmxlCi0lISAjI2Fz
c2VydCAoaiwgW10pOworJSEgYXNzZXJ0IChqLCBbMTsxOzI7MjsyOzM7NF0p
OwogCiAlIXRlc3QKICUhIFt5LGksal0gPSB1bmlxdWUgKFsxLDEsMiwzLDMs
Myw0XScsICJsYXN0Iik7CkBAIC0zMzUsMTEgKzM4MSwxMCBAQAogCiAlIXRl
c3QKICUhIEEgPSBbNCw1LDY7IDEsMiwzOyA0LDUsNl07Ci0lISBbeSxpLH5d
ID0gdW5pcXVlIChBLCAicm93cyIsICJzdGFibGUiKTsKKyUhIFt5LGksal0g
PSB1bmlxdWUgKEEsICJyb3dzIiwgInN0YWJsZSIpOwogJSEgYXNzZXJ0ICh5
LCBbNCw1LDY7IDEsMiwzXSk7CiAlISBhc3NlcnQgKEEoaSw6KSwgeSk7Ci0l
ISAjIyBGSVhNRTogJ2onIG91dHB1dCBub3QgY2FsY3VsYXRlZCBjb3JyZWN0
bHkgd2l0aCAic3RhYmxlIgotJSEgIyNhc3NlcnQgKHkoaiw6KSwgQSk7Cisl
ISBhc3NlcnQgKHkoaiw6KSwgQSk7CiAKICMjIFRlc3QgImxlZ2FjeSIgb3B0
aW9uCiAlIXRlc3QKQEAgLTM1NSw2ICs0MDAsNTIgQEAKICUhIGFzc2VydCAo
aSwgWzI7IDU7IDQ7IDNdKTsKICUhIGFzc2VydCAoaiwgWzQ7IDE7IDQ7IDM7
IDJdKTsKIAorJSF0ZXN0IDwqNjUxNzY+CislISBhID0gWzMgMiAxIDI7IDIg
MSAyIDFdOworJSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChhKTsKKyUhIGFz
c2VydCAoe28xLCBvMiwgbzN9LCB7WzE7MjszXSwgWzQ7MjsxXSwgWzM7Mjsy
OzE7MTsyOzI7MV19KTsKKyUhIFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSwg
InN0YWJsZSIpOworJSEgYXNzZXJ0ICh7bzEsIG8yLCBvM30sIHtbMzsyOzFd
LCBbMTsyOzRdLCBbMTsyOzI7MzszOzI7MjszXX0pCisKKyUhdGVzdCA8KjY1
MTc2PgorJSEgYSA9IFszIDIgMSAyOyAyIDEgMiAxXTsKKyUhIFtvMSwgbzIs
IG8zXSA9IHVuaXF1ZSAoYSgxLDopLCAicm93cyIpOworJSEgYXNzZXJ0ICh7
bzEsIG8yLCBvM30sIHthKDEsOiksIDEsIDF9KTsKKyUhIFtvMSwgbzIsIG8z
XSA9IHVuaXF1ZSAoYSgxLDopLCAicm93cyIsICJzdGFibGUiKTsKKyUhIGFz
c2VydCAoe28xLCBvMiwgbzN9LCB7YSgxLDopLCAxLCAxfSk7CislISBbbzEs
IG8yLCBvM10gPSB1bmlxdWUgKGEsICJyb3dzIik7CislISBhc3NlcnQgKHtv
MSwgbzIsIG8zfSwge1thKDIsOik7IGEoMSw6KV0sIFsyOzFdLCBbMjsxXX0p
OworJSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChhLCAicm93cyIsICJzdGFi
bGUiKTsKKyUhIGFzc2VydCAoe28xLCBvMiwgbzN9LCB7YSwgWzE7Ml0sIFsx
OzJdfSk7CislISBbbzEsIG8yLCBvM10gPSB1bmlxdWUgKFthO2FdLCAicm93
cyIpOworJSEgYXNzZXJ0ICh7bzEsIG8yLCBvM30sIHtbYSgyLDopOyBhKDEs
OildLCBbMjsxXSwgWzI7MTsyOzFdfSk7CislISBbbzEsIG8yLCBvM10gPSB1
bmlxdWUgKFthO2FdLCAicm93cyIsICJzdGFibGUiKTsKKyUhIGFzc2VydCAo
e28xLCBvMiwgbzN9LCB7YSwgWzE7Ml0sIFsxOzI7MTsyXX0pOworCislIXRl
c3QgPCo2NTE3Nj4KKyUhIGEgPSBnYWxsZXJ5ICgiaW50ZWdlcmRhdGEiLCBb
LTEwMCwgMTAwXSwgNiwgNik7CislISBhID0gW2EoMiw6KTsgYSgxOjUsOik7
IGEoMjo2LDopXTsKKyUhIFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSk7Cisl
ISBhc3NlcnQgKHtvMSwgbzEobzMpLCBvMiwgbzN9LCB7YSg6KShvMiksIGEo
OiksIC4uLgorJSEgWzI2OzIyOzM0OzQ1OzU3OyA2OzExOzE3OzMzOzI4OzM1
OzE1OzU2OyAyOzU5OyA0OzY2OyAuLi4KKyUhICAxNjs1MDs0OTsyNzsyNDsz
Nzs0NDs0ODszOTszODsxMzsyMzsgNTsxMjs0Njs1NTsgMV0sIC4uLgorJSEg
WzM0OzE0OzM0OzE2OzMwOyA2OzM0OzE2OzMwOyA2OyA3OzMxOzI4OzMxOzEy
OzE4OyA4OzMxOzEyOzE4OyA4OyAyOzI5OyAuLi4KKyUhICAyMjsyOTsgMTsy
MTsxMDsyOTsgMTsyMTsxMDsgOTsgMzsxMTsgMzsyMzsyNzsyNjsgMzsyMzsy
NzsyNjsyNDsgNDszMjsgLi4uCislISAgNDsgMjU7MjA7MTk7IDQ7MjU7MjA7
MTk7MzM7MTM7IDU7MTM7MTU7IDI7MjQ7MTM7MTU7IDI7MjQ7MTddfSk7Cisl
ISBbbzEsIG8yLCBvM10gPSB1bmlxdWUgKGEsICJzdGFibGUiKTsKKyUhIGFz
c2VydCAoe28xLCBvMShvMyksIG8yLCBvM30sIHthKDopKG8yKSwgYSg6KSwg
Li4uCislISBbIDE7IDI7IDQ7IDU7IDY7MTE7MTI7MTM7MTU7MTY7MTc7MjI7
MjM7MjQ7MjY7Mjc7Mjg7IC4uLgorJSEgIDMzOzM0OzM1OzM3OzM4OzM5OzQ0
OzQ1OzQ2OzQ4OzQ5OzUwOzU1OzU2OzU3OzU5OzY2XSwgLi4uCislISBbIDE7
IDI7IDE7IDM7IDQ7IDU7IDE7IDM7IDQ7IDU7IDY7IDc7IDg7IDc7IDk7MTA7
MTE7IDc7IDk7MTA7MTE7MTI7MTM7IC4uLgorJSEgIDE0OzEzOzE1OzE2OzE3
OzEzOzE1OzE2OzE3OzE4OzE5OzIwOzE5OzIxOzIyOzIzOzE5OzIxOzIyOzIz
OzI0OzI1OzI2Oy4uLgorJSEgIDI1OzI3OzI4OzI5OzI1OzI3OzI4OzI5OzMw
OzMxOzMyOzMxOzMzOzEyOzI0OzMxOzMzOzEyOzI0OzM0XX0pOworJSEgW28x
LCBvMiwgbzNdID0gdW5pcXVlIChhLCAicm93cyIpOworJSEgYXNzZXJ0ICh7
bzEsIG8xKG8zLDopLCBvMiwgbzN9LCB7YShvMiw6KSwgYSwgLi4uCislISBb
NjsxMTsyOzQ7NTsxXSwgWzY7Mzs2OzQ7NTsxOzY7NDs1OzE7Ml19KTsKKyUh
IFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSwgInJvd3MiLCAic3RhYmxlIik7
CislISBhc3NlcnQgKHtvMSwgbzEobzMsOiksIG8yLCBvM30sIHthKG8yLDop
LCBhLCAuLi4KKyUhIFsxOzI7NDs1OzY7MTFdLCBbMTsyOzE7Mzs0OzU7MTsz
OzQ7NTs2XX0pOworCiAjIyBUZXN0IGlucHV0IHZhbGlkYXRpb24KICUhZXJy
b3IgPEludmFsaWQgY2FsbD4gdW5pcXVlICgpCiAlIWVycm9yIDxYIG11c3Qg
YmUgYW4gYXJyYXkgb3IgY2VsbCBhcnJheSBvZiBzdHJpbmdzPiB1bmlxdWUg
KHsxfSkKQEAgLTM3Niw2ICs0NjcsNCBAQAogJSFlcnJvciA8aW52YWxpZCBv
cHRpb24+IHVuaXF1ZSAoeyJhIiwgImIiLCAiYyJ9LCAicm93cyIsICJVbmtu
b3duT3B0aW9uMiIpCiAlIWVycm9yIDxpbnZhbGlkIG9wdGlvbj4gdW5pcXVl
ICh7ImEiLCAiYiIsICJjIn0sICJVbmtub3duT3B0aW9uMSIsICJsYXN0IikK
ICUhd2FybmluZyA8InJvd3MiIGlzIGlnbm9yZWQgZm9yIGNlbGwgYXJyYXlz
PiB1bmlxdWUgKHsiMSJ9LCAicm93cyIpOwotJSF3YXJuaW5nIDx0aGlyZCBv
dXRwdXQgSiBpcyBub3QgeWV0IGltcGxlbWVudGVkPgotJSEgW3ksaSxqXSA9
IHVuaXF1ZSAoWzIsMV0sICJzdGFibGUiKTsKLSUhIGFzc2VydCAoaiwgW10p
OworCg==
====
EOF
uudecode octave-$OCTAVE_VER.patch.uue
pushd octave-$OCTAVE_VER
patch -p1 < ../octave-$OCTAVE_VER.patch
popd
# Build
rm -Rf build-octave-$OCTAVE_VER
mkdir build-octave-$OCTAVE_VER
pushd build-octave-$OCTAVE_VER
export CFLAGS="$OPTFLAGS -I$OCTAVE_INCLUDE_DIR"
export CXXFLAGS="$OPTFLAGS -I$OCTAVE_INCLUDE_DIR"
export FFLAGS=$OPTFLAGS
export LDFLAGS="-L$OCTAVE_LIB_DIR"
# Add --enable-address-sanitizer-flags for address sanitizer build
# To disable checking in atexit(): export ASAN_OPTIONS="leak_check_at_exit=0"
# See: https://wiki.octave.org/Finding_Memory_Leaks
JAVA_HOME=/usr/lib/jvm/java PKG_CONFIG_PATH=$OCTAVE_LIB_DIR/pkgconfig \
../octave-$OCTAVE_VER/configure \
      PACKAGE_VERSION=$OCTAVE_VER"-robj" \
      PACKAGE_STRING="GNU Octave "$OCTAVE_VER"-robj" \
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
    --with-sundials_sunlinsolklu-libdir=$OCTAVE_LIB_DIR 

#
# Generate profile
#
export PGO_GEN_FLAGS="-pthread -fprofile-generate"
make XTRA_CFLAGS="$PGO_GEN_FLAGS" XTRA_CXXFLAGS="$PGO_GEN_FLAGS" V=1 -j6
find . -name \*.gcda -exec rm -f {} ';'
make V=1 check

#
# Use profile
#
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
export PGO_LTO_FLAGS="-pthread -flto=6 -ffat-lto-objects -fprofile-use"
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
make install
popd

rm -Rf build-octave-$OCTAVE_VER octave-$OCTAVE_VER
rm -f octave-$OCTAVE_VER.patch.uue octave-$OCTAVE_VER.patch

#
# Update ld.so.conf.d
#
grep $OCTAVE_LIB_DIR /etc/ld.so.conf.d/usr_local_octave_lib.conf
if test $? -ne 0; then \
    echo $OCTAVE_LIB_DIR >> /etc/ld.so.conf.d/usr_local_octave_lib.conf ; \
fi
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
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$PARALLEL_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$PIQP_ARCHIVE
$OCTAVE_BIN_DIR/octave-cli --eval "pkg -verbose install "$SYMBOLIC_ARCHIVE

#
# Fix signal package and install the new signal package
#
cat > signal-$SIGNAL_VER.patch.uue << 'EOF'
begin-base64 644 signal-1.4.6.patch
LS0tIHNpZ25hbC0xLjQuNi5uZXcvaW5zdC96cGxhbmUubQkyMDI0LTA5LTIw
IDIyOjU0OjIwLjAwMDAwMDAwMCArMTAwMAorKysgc2lnbmFsLTEuNC42L2lu
c3QvenBsYW5lLm0JMjAyNC0xMC0wNyAxNjozMTozNi42MTE3Mzc4MDMgKzEx
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

#
# Install SeDuMi
#
SEDUMI_VER=1.3.8
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

#
# Install SDPT3
#
if ! test -f sdpt3-master.zip ; then
  wget -c $GITHUB_URL/sdpt3/archive/refs/heads/master.zip
  mv master.zip sdpt3-master.zip
fi
rm -Rf sdpt3-master $OCTAVE_SITE_M_DIR/SDPT3
unzip sdpt3-master.zip 
rm -f sdpt3-master/Solver/Mexfun/*.mex*
rm -Rf sdpt3-master/Solver/Mexfun/o_win
mv -f sdpt3-master $OCTAVE_SITE_M_DIR/SDPT3
if test $? -ne 0;then rm -Rf sdpt3-master; exit -1; fi
$OCTAVE_BIN_DIR/octave-cli $OCTAVE_SITE_M_DIR/SDPT3/install_sdpt3.m

#
# Install YALMIP
#
YALMIP_VER=R20230622
YALMIP_ARCHIVE=$YALMIP_VER".tar.gz"
YALMIP_URL="https://github.com/yalmip/YALMIP/archive/refs/tags/"$YALMIP_ARCHIVE
if ! test -f "YALMIP-"$YALMIP_ARCHIVE ; then
    wget -c $YALMIP_URL
    mv $YALMIP_ARCHIVE "YALMIP-"$YALMIP_ARCHIVE
fi
tar -xf "YALMIP-"$YALMIP_ARCHIVE
cat > YALMIP-$YALMIP_VER.patch.uue << 'EOF'
begin-base64 644 YALMIP-R20230622.patch
LS0tIFlBTE1JUC1SMjAyMzA2MjIub3JpZy9leHRyYXMvaXNtZW1iY1lBTE1J
UC5tCTIwMjMtMDYtMjIgMjE6NTc6NTIuMDAwMDAwMDAwICsxMDAwCisrKyBZ
QUxNSVAtUjIwMjMwNjIyL2V4dHJhcy9pc21lbWJjWUFMTUlQLm0JMjAyNC0w
Mi0wOSAxNzo1Nzo1Ni42NzQxODYxOTAgKzExMDAKQEAgLTEsMTQgKzEsNiBA
QAogZnVuY3Rpb24gbWVtYmVycz1pc21lbWJjWUFMTUlQKGEsYikKLQotJSBp
c21lbWJjIGlzIGZhc3QsIGJ1dCBkb2VzIG5vdCBleGlzdCBpbiBvY3RhdmUK
LSUgaG93ZXZlciwgdHJ5LWNhdGNoIGlzIHZlcnkgc2xvdyBpbiBPY3RhdmUs
Ci0lIE9jdGF2ZSB1c2VyOiBKdXN0IHJlcGxhY2UgdGhlIHdob2xlIGNvZGUg
aGVyZQotJSB3aXRoICJtZW1iZXJzID0gaXNtZW1iZXIoYSxiKTsiCi10cnkK
LSAgICBtZW1iZXJzID0gaXNtZW1iYyhhLGIpOwotY2F0Y2gKLSAgICBtZW1i
ZXJzID0gaXNtZW1iZXIoYSxiKTsKLWVuZAorICBtZW1iZXJzID0gaXNtZW1i
ZXIoYSxiKTsKK2VuZGZ1bmN0aW9uCiAKICAgCiAgIAo=
====
EOF
# Patch
uudecode YALMIP-$YALMIP_VER".patch.uue"
pushd YALMIP-$YALMIP_VER
patch -p 1 < ../YALMIP-$YALMIP_VER".patch"
popd
rm -f "YALMIP-"$YALMIP_VER".patch" "YALMIP-"$YALMIP_VER".patch.uue"
mv -f "YALMIP-"$YALMIP_VER $OCTAVE_SITE_M_DIR/YALMIP
if test $? -ne 0;then rm -Rf "YALMIP-"$YALMIP_VER; exit -1; fi

#
# Install SparsePOP
#
if ! test -f SparsePOP-master.zip ; then
  wget -c $GITHUB_URL/SparsePOP/archive/refs/heads/master.zip
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
cat > $SCS_MATLAB".patch.uue" <<EOF
begin-base64 644 scs-matlab-master.patch
LS0tIHNjcy1tYXRsYWItbWFzdGVyL2NvbXBpbGVfZGlyZWN0Lm0JMjAyNC0w
Ny0xMCAwMjoyMjozNS4wMDAwMDAwMDAgKzEwMDAKKysrIHNjcy1tYXRsYWIt
bWFzdGVyLm5ldy9jb21waWxlX2RpcmVjdC5tCTIwMjQtMDgtMjUgMTk6NTk6
MjcuMDkwMjA5NjEyICsxMDAwCkBAIC0xLDcgKzEsMTMgQEAKIGZ1bmN0aW9u
IGNvbXBpbGVfZGlyZWN0KGZsYWdzLCBjb21tb25fc2NzKQogJSBjb21waWxl
IGRpcmVjdAotY21kID0gc3ByaW50ZignbWV4IC1PIC12ICVzICVzICVzICVz
IENPTVBGTEFHUz0iJENPTVBGTEFHUyAlcyIgQ0ZMQUdTPSIkQ0ZMQUdTICVz
IiAtSXNjcyAtSXNjcy9saW5zeXMgLUlzY3MvaW5jbHVkZScsIGZsYWdzLmFy
ciwgZmxhZ3MuTENGTEFHLCBmbGFncy5JTkNTLCBmbGFncy5JTlQsIGZsYWdz
LkNPTVBGTEFHUywgZmxhZ3MuQ0ZMQUdTKTsKLQorY21kID0gc3ByaW50Zign
bWV4IC1PIC12ICVzICVzICVzICVzIC1Jc2NzIC1Jc2NzL2xpbnN5cyAtSXNj
cy9pbmNsdWRlJywgLi4uCisgICAgICAgICAgICAgIGZsYWdzLmFyciwgZmxh
Z3MuTENGTEFHLCBmbGFncy5JTkNTLCBmbGFncy5JTlQpOworaWYgZXhpc3Qo
J09DVEFWRV9WRVJTSU9OJykKKyAgY21kID0gc3ByaW50ZignJXMgJXMgJXMn
LCBjbWQsIGZsYWdzLkNPTVBGTEFHUywgZmxhZ3MuQ0ZMQUdTKTsKK2Vsc2UK
KyAgY21kID0gc3ByaW50ZignJXMgQ09NUEZMQUdTPSIkQ09NUEZMQUdTICVz
IiBDRkxBR1M9IiRDRkxBR1MgJXMiJywgLi4uCisgICAgICAgICAgICAgICAg
Y21kLCBmbGFncy5DT01QRkxBR1MsIGZsYWdzLkNGTEFHUyk7CitlbmRpZgog
YW1kX2ZpbGVzID0geydhbWRfb3JkZXInLCAnYW1kX2R1bXAnLCAnYW1kX3Bv
c3RvcmRlcicsICdhbWRfcG9zdF90cmVlJywgLi4uCiAgICAgJ2FtZF9hYXQn
LCAnYW1kXzInLCAnYW1kXzEnLCAnYW1kX2RlZmF1bHRzJywgJ2FtZF9jb250
cm9sJywgLi4uCiAgICAgJ2FtZF9pbmZvJywgJ2FtZF92YWxpZCcsICdhbWRf
Z2xvYmFsJywgJ2FtZF9wcmVwcm9jZXNzJywgLi4uCkBAIC0xMCw1ICsxNiw4
IEBACiAgICAgY21kID0gc3ByaW50ZiAoJyVzIHNjcy9saW5zeXMvZXh0ZXJu
YWwvYW1kLyVzLmMnLCBjbWQsIGFtZF9maWxlcyB7aX0pIDsKIGVuZAogCi1j
bWQgPSBzcHJpbnRmICgnJXMgJXMgc2NzL2xpbnN5cy9leHRlcm5hbC9xZGxk
bC9xZGxkbC5jIHNjcy9saW5zeXMvY3B1L2RpcmVjdC9wcml2YXRlLmMgJXMg
JXMgJXMgLW91dHB1dCBzY3NfZGlyZWN0JywgY21kLCBjb21tb25fc2NzLCBm
bGFncy5saW5rLCBmbGFncy5MT0NTLCBmbGFncy5CTEFTTElCKTsKK2NtZCA9
IHNwcmludGYgKCclcyAlcyBzY3MvbGluc3lzL2V4dGVybmFsL3FkbGRsL3Fk
bGRsLmMgc2NzL2xpbnN5cy9jcHUvZGlyZWN0L3ByaXZhdGUuYyAlcyAlcyAl
cyAtLW91dHB1dCBzY3NfZGlyZWN0JywgY21kLCBjb21tb25fc2NzLCBmbGFn
cy5saW5rLCBmbGFncy5MT0NTLCBmbGFncy5CTEFTTElCKTsKKworY21kID0g
c3ByaW50ZignJXMgXG4nLGNtZCk7CiBldmFsKGNtZCk7CitkaXNwKCcnKTsK
LS0tIHNjcy1tYXRsYWItbWFzdGVyL2NvbXBpbGVfaW5kaXJlY3QubQkyMDI0
LTA3LTEwIDAyOjIyOjM1LjAwMDAwMDAwMCArMTAwMAorKysgc2NzLW1hdGxh
Yi1tYXN0ZXIubmV3L2NvbXBpbGVfaW5kaXJlY3QubQkyMDI0LTA4LTI1IDE5
OjU5OjIxLjcxNDI1MjIyMyArMTAwMApAQCAtMSw0ICsxLDEzIEBACiBmdW5j
dGlvbiBjb21waWxlX2luZGlyZWN0KGZsYWdzLCBjb21tb25fc2NzKQogJSBj
b21waWxlIGluZGlyZWN0Ci1jbWQgPSBzcHJpbnRmKCdtZXggLU8gLXYgJXMg
JXMgJXMgJXMgLURJTkRJUkVDVCBDT01QRkxBR1M9IiRDT01QRkxBR1MgJXMi
IENGTEFHUz0iJENGTEFHUyAlcyIgc2NzL2xpbnN5cy9jcHUvaW5kaXJlY3Qv
cHJpdmF0ZS5jICVzIC1Jc2NzIC1Jc2NzL2xpbnN5cyAtSXNjcy9pbmNsdWRl
ICVzICVzICVzIC1vdXRwdXQgc2NzX2luZGlyZWN0JywgZmxhZ3MuYXJyLCBm
bGFncy5MQ0ZMQUcsIGNvbW1vbl9zY3MsIGZsYWdzLklOQ1MsIGZsYWdzLkNP
TVBGTEFHUywgZmxhZ3MuQ0ZMQUdTLCBmbGFncy5saW5rLCBmbGFncy5MT0NT
LCBmbGFncy5CTEFTTElCLCBmbGFncy5JTlQpOworY21kID0gc3ByaW50Zign
bWV4IC1PIC12ICVzICVzICVzICVzIC1ESU5ESVJFQ1Qgc2NzL2xpbnN5cy9j
cHUvaW5kaXJlY3QvcHJpdmF0ZS5jICVzIC1Jc2NzIC1Jc2NzL2xpbnN5cyAt
SXNjcy9pbmNsdWRlICVzICVzICVzIC0tb3V0cHV0IHNjc19pbmRpcmVjdCcs
IGZsYWdzLmFyciwgZmxhZ3MuTENGTEFHLCBjb21tb25fc2NzLCBmbGFncy5J
TkNTLCBmbGFncy5saW5rLCBmbGFncy5MT0NTLCBmbGFncy5CTEFTTElCLCBm
bGFncy5JTlQpOworaWYgZXhpc3QoJ09DVEFWRV9WRVJTSU9OJykKKyAgY21k
ID0gc3ByaW50ZignJXMgJXMgJXMnLCBjbWQsIGZsYWdzLkNPTVBGTEFHUywg
ZmxhZ3MuQ0ZMQUdTKTsKK2Vsc2UKKyAgY21kID0gc3ByaW50ZignJXMgQ09N
UEZMQUdTPSIkQ09NUEZMQUdTICVzIiBDRkxBR1M9IiRDRkxBR1MgJXMiJywg
Li4uCisgICAgICAgICAgICAgICAgY21kLCBmbGFncy5DT01QRkxBR1MsIGZs
YWdzLkNGTEFHUyk7CitlbmRpZgorCitjbWQgPSBzcHJpbnRmKCclcyBcbics
Y21kKTsKIGV2YWwoY21kKTsKK2Rpc3AoJycpOwotLS0gc2NzLW1hdGxhYi1t
YXN0ZXIvbWFrZV9zY3MubQkyMDI0LTA3LTEwIDAyOjIyOjM1LjAwMDAwMDAw
MCArMTAwMAorKysgc2NzLW1hdGxhYi1tYXN0ZXIubmV3L21ha2Vfc2NzLm0J
MjAyNC0wOC0yNiAwMDowODozNi45NDYxMzg5MTYgKzEwMDAKQEAgLTEsMjYg
KzEsNDcgQEAKIGdwdSA9IGZhbHNlOyAlIGNvbXBpbGUgdGhlIGdwdSB2ZXJz
aW9uIG9mIFNDUwotZmxvYXQgPSBmYWxzZTsgJSB1c2luZyBzaW5nbGUgcHJl
Y2lzaW9uIChyYXRoZXIgdGhhbiBkb3VibGUpIGZsb2F0aW5nIHBvaW50cwor
c2Zsb2F0ID0gZmFsc2U7ICUgdXNpbmcgc2luZ2xlIHByZWNpc2lvbiAocmF0
aGVyIHRoYW4gZG91YmxlKSBmbG9hdGluZyBwb2ludHMKK3FmbG9hdCA9IGZh
bHNlOyAlIHVzaW5nIHF1YWQgcHJlY2lzaW9uIChyYXRoZXIgdGhhbiBkb3Vi
bGUpIGZsb2F0aW5nIHBvaW50cwogaW50ID0gZmFsc2U7ICUgdXNlIDMyIGJp
dCBpbnRlZ2VycyBmb3IgaW5kZXhpbmcKK3dpdGhfZ2NjX2RlYnVnID0gZmFs
c2U7ICUgY29tcGlsZSB3aXRoIGRlYnVnZ2luZyBzeW1ib2xzCiAlIFdBUk5J
Tkc6IE9QRU5NUCBXSVRIIE1BVExBQiBDQU4gQ0FVU0UgRVJST1JTIEFORCBD
UkFTSCwgVVNFIFdJVEggQ0FVVElPTjoKICUgb3Blbm1wIHBhcmFsbGVsaXpl
cyB0aGUgbWF0cml4IG11bHRpcGx5IGZvciB0aGUgaW5kaXJlY3Qgc29sdmVy
ICh1c2luZyBDRykKICUgYW5kIHNvbWUgY29uZSBwcm9qZWN0aW9ucy4KIHVz
ZV9vcGVuX21wID0gZmFsc2U7CiAKLWZsYWdzLkJMQVNMSUIgPSAnLWxtd2Js
YXMgLWxtd2xhcGFjayc7CitpZiAoIGV4aXN0KCdPQ1RBVkVfVkVSU0lPTicp
ICkKKyAgaWYgKCBxZmxvYXQgKQorICAgIGZsYWdzLkJMQVNMSUIgPSAnLWxx
YmxhcyAtbHFsYXBhY2sgLWxxdWFkbWF0aCc7CisgIGVsc2UKKyAgICBmbGFn
cy5CTEFTTElCID0gJy1sYmxhcyAtbGxhcGFjayc7CisgIGVuZGlmCitlbHNl
CisgIGZsYWdzLkJMQVNMSUIgPSAnLWxtd2JsYXMgLWxtd2xhcGFjayc7Citl
bmRpZgorCiAlIE1BVExBQl9NRVhfRklMRSBlbnYgdmFyaWFibGUgc2V0cyBi
bGFzaW50IHRvIHB0cmRpZmZfdAotZmxhZ3MuTENGTEFHID0gJy1ETUFUTEFC
X01FWF9GSUxFIC1EVVNFX0xBUEFDSyAtRENUUkxDPTEgLURDT1BZQU1BVFJJ
WCAtREdQVV9UUkFOU1BPU0VfTUFUIC1EVkVSQk9TSVRZPTAnOworZmxhZ3Mu
TENGTEFHID0gJy1ETUFUTEFCX01FWF9GSUxFIC1EVVNFX0xBUEFDSyAtRENU
UkxDPTEtRENPUFlBTUFUUklYJzsKK2ZsYWdzLkxDRkxBRyA9IHNwcmludGYo
JyVzIC1ER1BVX1RSQU5TUE9TRV9NQVQgLURWRVJCT1NJVFk9MCcsIGZsYWdz
LkxDRkxBRyk7CitpZiBleGlzdCgnT0NUQVZFX1ZFUlNJT04nKQorICBmbGFn
cy5MQ0ZMQUcgPSBzcHJpbnRmKCclcyAtRE9DVEFWRV9NRVhfRklMRScsIGZs
YWdzLkxDRkxBRyk7CitlbmRpZgoraWYgKCB3aXRoX2djY19kZWJ1ZyApCisg
IGZsYWdzLkxDRkxBRyA9IHNwcmludGYoJyVzIC1PMCAtZ2dkYjMnLCBmbGFn
cy5MQ0ZMQUcpOworZW5kaWYKIGZsYWdzLklOQ1MgPSAnJzsKIGZsYWdzLkxP
Q1MgPSAnJzsKIAogY29tbW9uX3NjcyA9ICdzY3Mvc3JjL2xpbmFsZy5jIHNj
cy9zcmMvY29uZXMuYyBzY3Mvc3JjL2V4cF9jb25lLmMgc2NzL3NyYy9hYS5j
IHNjcy9zcmMvdXRpbC5jIHNjcy9zcmMvc2NzLmMgc2NzL3NyYy9jdHJsYy5j
IHNjcy9zcmMvbm9ybWFsaXplLmMgc2NzL3NyYy9zY3NfdmVyc2lvbi5jIHNj
cy9saW5zeXMvc2NzX21hdHJpeC5jIHNjcy9saW5zeXMvY3NwYXJzZS5jIHNj
cy9zcmMvcncuYyBzY3NfbWV4LmMnOwotaWYgKGNvbnRhaW5zKGNvbXB1dGVy
LCAnNjQnKSkKK2lmICggcWZsb2F0ICYmIGV4aXN0KCdPQ1RBVkVfVkVSU0lP
TicpICkKKyAgY29tbW9uX3NjcyA9IHNwcmludGYoJyVzICVzJywgY29tbW9u
X3NjcywgJ3Njc19xcHJpbnRmLmMnKTsKK2VuZGlmCitpZiB+aXNlbXB0eShz
dHJmaW5kKGNvbXB1dGVyLCAnNjQnKSkgJiYgfmV4aXN0KCdPQ1RBVkVfVkVS
U0lPTicpCiAgICAgZmxhZ3MuYXJyID0gJy1sYXJnZUFycmF5RGltcyc7CiBl
bHNlCiAgICAgZmxhZ3MuYXJyID0gJyc7CiBlbmQKIAogaWYgKCBpc3VuaXgg
JiYgfmlzbWFjICkKLSAgICBmbGFncy5saW5rID0gJy1sbSAtbHV0IC1scnQn
OworICAgIGZsYWdzLmxpbmsgPSAnLWxtJzsKIGVsc2VpZiAgKCBpc21hYyAp
CiAgICAgZmxhZ3MubGluayA9ICctbG0gLWx1dCc7CiBlbHNlCkBAIC0yOCw4
ICs0OSwxMCBAQAogICAgIGZsYWdzLkxDRkxBRyA9IHNwcmludGYoJy1ETk9C
TEFTU1VGRklYICVzJywgZmxhZ3MuTENGTEFHKTsKIGVuZAogCi1pZiAoZmxv
YXQpCitpZiAoIHNmbG9hdCApCiAgICAgZmxhZ3MuTENGTEFHID0gc3ByaW50
ZignLURTRkxPQVQgJXMnLCBmbGFncy5MQ0ZMQUcpOworZWxzZWlmICggcWZs
b2F0ICkKKyAgICBmbGFncy5MQ0ZMQUcgPSBzcHJpbnRmKCctRFFGTE9BVCAl
cycsIGZsYWdzLkxDRkxBRyk7CiBlbmQKIGlmIChpbnQpCiAgICAgZmxhZ3Mu
SU5UID0gJyc7CkBAIC02Miw1ICs4NSw2IEBACiAKIGFkZHBhdGggJy4nCiAK
K2Rpc3AoJycpCiBkaXNwKCdTVUNDRVNTRlVMTFkgSU5TVEFMTEVEIFNDUycp
CiBkaXNwKCcoSWYgdXNpbmcgU0NTIHdpdGggQ1ZYLCBub3RlIHRoYXQgU0NT
IG9ubHkgc3VwcG9ydHMgQ1ZYIHYzLjAgb3IgbGF0ZXIpLicpCi0tLSBzY3Mt
bWF0bGFiLW1hc3Rlci9zY3MvaW5jbHVkZS9nbGJvcHRzLmgJMjAyNC0wOC0y
NiAwMDoxMjoxNy4zMzAzOTYxMDUgKzEwMDAKKysrIHNjcy1tYXRsYWItbWFz
dGVyLm5ldy9zY3MvaW5jbHVkZS9nbGJvcHRzLmgJMjAyNC0wOC0yNSAyMTo1
NTo1Ny45ODQ5MzM4NTEgKzEwMDAKQEAgLTQ1LDcgKzQ1LDEzIEBACiAjaWYg
Tk9fUFJJTlRJTkcgPiAwICAgICAvKiBEaXNhYmxlIGFsbCBwcmludGluZyAq
LwogI2RlZmluZSBzY3NfcHJpbnRmKC4uLikgLyogTm8tb3AgKi8KICNlbHNl
Ci0jaWZkZWYgTUFUTEFCX01FWF9GSUxFCisjaWYgZGVmaW5lZChPQ1RBVkVf
TUVYX0ZJTEUpICYmIGRlZmluZWQoUUZMT0FUKQorI2luY2x1ZGUgPHN0ZGlv
Lmg+CisjaW5jbHVkZSA8c3RkbGliLmg+CisjaW5jbHVkZSA8cXVhZG1hdGgu
aD4KKyNkZWZpbmUgc2NzX3ByaW50ZiBzY3NfcXByaW50ZgorZXh0ZXJuIGlu
dCBzY3NfcXByaW50Zihjb25zdCBjaGFyKiBmbXQsIC4uLik7CisjZWxpZiBk
ZWZpbmVkKE1BVExBQl9NRVhfRklMRSkKICNpbmNsdWRlICJtZXguaCIKICNk
ZWZpbmUgc2NzX3ByaW50ZiBtZXhQcmludGYKICNlbGlmIGRlZmluZWQgUFlU
SE9OCkBAIC0xMTEsMjEgKzExNywxMyBAQAogI2RlZmluZSBzY3NfcmVhbGxv
YyByZWFsbG9jCiAjZW5kaWYKIAotI2lmbmRlZiBTRkxPQVQKLSNpZm5kZWYg
TkFOCi0jZGVmaW5lIE5BTiAoKHNjc19mbG9hdCkweDdmZjgwMDAwMDAwMDAw
MDApCi0jZW5kaWYKLSNpZm5kZWYgSU5GSU5JVFkKLSNkZWZpbmUgSU5GSU5J
VFkgTkFOCi0jZW5kaWYKLSNlbHNlCiAjaWZuZGVmIE5BTgotI2RlZmluZSBO
QU4gKChmbG9hdCkweDdmYzAwMDAwKQorI2RlZmluZSBOQU4gKChzY3NfZmxv
YXQpKDAuMC8wLjApCiAjZW5kaWYKKyAgCiAjaWZuZGVmIElORklOSVRZCiAj
ZGVmaW5lIElORklOSVRZIE5BTgogI2VuZGlmCi0jZW5kaWYKIAogI2lmbmRl
ZiBNQVgKICNkZWZpbmUgTUFYKGEsIGIpICgoKGEpID4gKGIpKSA/IChhKSA6
IChiKSkKQEAgLTE0MCwxNiArMTM4LDIwIEBACiAjZW5kaWYKIAogI2lmbmRl
ZiBQT1dGCi0jaWZkZWYgU0ZMT0FUCisjaWYgZGVmaW5lZChTRkxPQVQpCiAj
ZGVmaW5lIFBPV0YgcG93ZgorI2VsaWYgZGVmaW5lZChRRkxPQVQpCisjZGVm
aW5lIFBPV0YgcG93cQogI2Vsc2UKICNkZWZpbmUgUE9XRiBwb3cKICNlbmRp
ZgogI2VuZGlmCiAKICNpZm5kZWYgU1FSVEYKLSNpZmRlZiBTRkxPQVQKKyNp
ZiBkZWZpbmVkKFNGTE9BVCkKICNkZWZpbmUgU1FSVEYgc3FydGYKKyNlbGlm
IGRlZmluZWQoUUZMT0FUKQorI2RlZmluZSBTUVJURiBzcXJ0cQogI2Vsc2UK
ICNkZWZpbmUgU1FSVEYgc3FydAogI2VuZGlmCi0tLSBzY3MtbWF0bGFiLW1h
c3Rlci9zY3MvaW5jbHVkZS9zY3NfYmxhcy5oCTIwMjQtMDgtMjYgMDA6MTI6
MTcuMzM0Mzk2MDczICsxMDAwCisrKyBzY3MtbWF0bGFiLW1hc3Rlci5uZXcv
c2NzL2luY2x1ZGUvc2NzX2JsYXMuaAkyMDI0LTA4LTI1IDE3OjEwOjA1LjA1
ODAxNzA2NCArMTAwMApAQCAtMzgsNiArMzgsNyBAQAogI2VuZGlmCiAKICNp
ZmRlZiBNQVRMQUJfTUVYX0ZJTEUKKyNpbmNsdWRlIDxzdGRkZWYuaD4KIHR5
cGVkZWYgcHRyZGlmZl90IGJsYXNfaW50OwogI2VsaWYgZGVmaW5lZCBCTEFT
NjQKICNpbmNsdWRlIDxzdGRpbnQuaD4KLS0tIHNjcy1tYXRsYWItbWFzdGVy
L3Njcy9pbmNsdWRlL3Njc190eXBlcy5oCTIwMjQtMDgtMjYgMDA6MTI6MTcu
MzM0Mzk2MDczICsxMDAwCisrKyBzY3MtbWF0bGFiLW1hc3Rlci5uZXcvc2Nz
L2luY2x1ZGUvc2NzX3R5cGVzLmgJMjAyNC0wOC0yNSAxODowMDowOC44ODEw
OTM2NzYgKzEwMDAKQEAgLTI0LDEwICsyNCwxMiBAQAogdHlwZWRlZiBpbnQg
c2NzX2ludDsKICNlbmRpZgogCi0jaWZuZGVmIFNGTE9BVAotdHlwZWRlZiBk
b3VibGUgc2NzX2Zsb2F0OwotI2Vsc2UKKyNpZiBkZWZpbmVkKFNGTE9BVCkK
IHR5cGVkZWYgZmxvYXQgc2NzX2Zsb2F0OworI2VsaWYgZGVmaW5lZChRRkxP
QVQpCit0eXBlZGVmIF9fZmxvYXQxMjggc2NzX2Zsb2F0OworI2Vsc2UKK3R5
cGVkZWYgZG91YmxlIHNjc19mbG9hdDsKICNlbmRpZgogCiAjaWZkZWYgX19j
cGx1c3BsdXMKLS0tIHNjcy1tYXRsYWItbWFzdGVyL3Njcy9zcmMvY3RybGMu
YwkyMDI0LTA4LTI2IDAwOjEyOjE3LjM2NjM5NTgyMCArMTAwMAorKysgc2Nz
LW1hdGxhYi1tYXN0ZXIubmV3L3Njcy9zcmMvY3RybGMuYwkyMDI0LTA4LTI1
IDE3OjExOjEwLjU2OTQ5NzA5OCArMTAwMApAQCAtMTEsNyArMTEsNyBAQAog
CiAjaWYgQ1RSTEMgPiAwCiAKLSNpZmRlZiBNQVRMQUJfTUVYX0ZJTEUKKyNp
ZiBkZWZpbmVkKE1BVExBQl9NRVhfRklMRSkgJiYgIWRlZmluZWQoT0NUQVZF
X01FWF9GSUxFKQogI2luY2x1ZGUgPHN0ZGJvb2wuaD4KIAogZXh0ZXJuIGJv
b2wgdXRJc0ludGVycnVwdFBlbmRpbmcodm9pZCk7Ci0tLSBzY3MtbWF0bGFi
LW1hc3Rlci9zY3Mvc3JjL3Njcy5jCTIwMjQtMDgtMjYgMDA6MTI6MTcuMzcw
Mzk1Nzg5ICsxMDAwCisrKyBzY3MtbWF0bGFiLW1hc3Rlci5uZXcvc2NzL3Ny
Yy9zY3MuYwkyMDI0LTA4LTI2IDAwOjIxOjM3LjEyMDk2OTcwMSArMTAwMApA
QCAtODcsOSArODcsOSBAQAogICBmb3IgKGkgPSAwOyBpIDwgTElORV9MRU47
ICsraSkgewogICAgIHNjc19wcmludGYoIi0iKTsKICAgfQotICBzY3NfcHJp
bnRmKCJcblx0ICAgICAgIFNDUyB2JXMgLSBTcGxpdHRpbmcgQ29uaWMgU29s
dmVyXG5cdChjKSBCcmVuZGFuICIKLSAgICAgICAgICAgICAiTydEb25vZ2h1
ZSwgU3RhbmZvcmQgVW5pdmVyc2l0eSwgMjAxMlxuIiwKLSAgICAgICAgICAg
ICBzY3NfdmVyc2lvbigpKTsKKworICBzY3NfcHJpbnRmKCJcblx0ICAgICAg
IFNDUyB2JXMgLSBTcGxpdHRpbmcgQ29uaWMgU29sdmVyXG4iLCBTQ1NfVkVS
U0lPTik7CisgIHNjc19wcmludGYoIlx0KGMpIEJyZW5kYW4gTydEb25vZ2h1
ZSwgU3RhbmZvcmQgVW5pdmVyc2l0eSwgMjAxMlxuIik7CiAgIGZvciAoaSA9
IDA7IGkgPCBMSU5FX0xFTjsgKytpKSB7CiAgICAgc2NzX3ByaW50ZigiLSIp
OwogICB9CkBAIC0xMTUsMTEgKzExNSwxMiBAQAogI2lmZGVmIF9PUEVOTVAK
ICAgc2NzX3ByaW50ZigiXHQgIGNvbXBpbGVkIHdpdGggb3Blbm1wIHBhcmFs
bGVsaXphdGlvbiBlbmFibGVkXG4iKTsKICNlbmRpZgorICBzY3NfcHJpbnRm
KCJcdCAgY29tcGlsZWQgd2l0aCBzY3NfZmxvYXQ6ICV6ZCBieXRlc1xuIiwg
c2l6ZW9mKHNjc19mbG9hdCkpOwogICBpZiAobGluX3N5c19tZXRob2QpIHsK
ICAgICBzY3NfcHJpbnRmKCJsaW4tc3lzOiAgJXNcblx0ICBubnooQSk6ICVs
aSwgbm56KFApOiAlbGlcbiIsIGxpbl9zeXNfbWV0aG9kLAogICAgICAgICAg
ICAgICAgKGxvbmcpZC0+QS0+cFtkLT5BLT5uXSwgZC0+UCA/IChsb25nKWQt
PlAtPnBbZC0+UC0+bl0gOiAwbCk7CiAgIH0KLQorICAKICNpZmRlZiBNQVRM
QUJfTUVYX0ZJTEUKICAgbWV4RXZhbFN0cmluZygiZHJhd25vdzsiKTsKICNl
bmRpZgotLS0gc2NzLW1hdGxhYi1tYXN0ZXIvc2NzX21leC5jCTIwMjQtMDct
MTAgMDI6MjI6MzUuMDAwMDAwMDAwICsxMDAwCisrKyBzY3MtbWF0bGFiLW1h
c3Rlci5uZXcvc2NzX21leC5jCTIwMjQtMDgtMjUgMTc6NTc6NTUuMzA1MTU5
MDEzICsxMDAwCkBAIC0xLDYgKzEsOCBAQAogI2luY2x1ZGUgImdsYm9wdHMu
aCIKICNpbmNsdWRlICJsaW5hbGcuaCIKKyNpZiAhZGVmaW5lZChPQ1RBVkVf
TUVYX0ZJTEUpCiAjaW5jbHVkZSAibWF0cml4LmgiCisjZW5kaWYKICNpbmNs
dWRlICJtZXguaCIKICNpbmNsdWRlICJzY3MuaCIKICNpbmNsdWRlICJzY3Nf
bWF0cml4LmgiCkBAIC0zNiw3ICszOCw3IEBACiB9CiAjZW5kaWYKIAotI2lm
IFNGTE9BVCA+IDAKKyNpZiBkZWZpbmVkKFNGTE9BVCkgfHwgZGVmaW5lZChR
RkxPQVQpCiAvKiB0aGlzIG1lbW9yeSBtdXN0IGJlIGZyZWVkICovCiBzY3Nf
ZmxvYXQgKmNhc3RfdG9fc2NzX2Zsb2F0X2Fycihkb3VibGUgKmFyciwgc2Nz
X2ludCBsZW4pIHsKICAgc2NzX2ludCBpOwpAQCAtNTksNyArNjEsNyBAQAog
CiB2b2lkIHNldF9vdXRwdXRfZmllbGQobXhBcnJheSAqKnBvdXQsIHNjc19m
bG9hdCAqb3V0LCBzY3NfaW50IGxlbikgewogICAqcG91dCA9IG14Q3JlYXRl
RG91YmxlTWF0cml4KDAsIDAsIG14UkVBTCk7Ci0jaWYgU0ZMT0FUID4gMAor
I2lmIGRlZmluZWQoU0ZMT0FUKSB8fCBkZWZpbmVkKFFGTE9BVCkKICAgbXhT
ZXRQcigqcG91dCwgY2FzdF90b19kb3VibGVfYXJyKG91dCwgbGVuKSk7CiAg
IHNjc19mcmVlKG91dCk7CiAjZWxzZQpAQCAtMTc4LDcgKzE4MCw3IEBACiAg
IHNldHRpbmdzID0gcHJoc1syXTsKICAgZC0+biA9IChzY3NfaW50KSAqICht
eEdldERpbWVuc2lvbnMoY19tZXgpKTsKICAgZC0+bSA9IChzY3NfaW50KSAq
IChteEdldERpbWVuc2lvbnMoYl9tZXgpKTsKLSNpZiBTRkxPQVQgPiAwCisj
aWYgZGVmaW5lZChTRkxPQVQpIHx8IGRlZmluZWQoUUZMT0FUKQogICBkLT5i
ID0gY2FzdF90b19zY3NfZmxvYXRfYXJyKG14R2V0UHIoYl9tZXgpLCBkLT5t
KTsKICAgZC0+YyA9IGNhc3RfdG9fc2NzX2Zsb2F0X2FycihteEdldFByKGNf
bWV4KSwgZC0+bik7CiAjZWxzZQpAQCAtMjU3LDEyICsyNTksMjIgQEAKICAg
aWYgKHRtcCAhPSBTQ1NfTlVMTCkgewogICAgIC8qIG5lZWQgdG8gZnJlZSB0
aGlzIGxhdGVyICovCiAgICAgc3Rncy0+d3JpdGVfZGF0YV9maWxlbmFtZSA9
IG14QXJyYXlUb1N0cmluZyh0bXApOworICAgIC8qIFlBTE1JUCBwdXRzICIi
IGhlcmUgISEgKi8KKyAgICBpZiAoc3RybGVuKHN0Z3MtPndyaXRlX2RhdGFf
ZmlsZW5hbWUpID09IDApIHsKKyAgICAgIHNjc19mcmVlKCh2b2lkICopc3Rn
cy0+d3JpdGVfZGF0YV9maWxlbmFtZSk7CisgICAgICBzdGdzLT53cml0ZV9k
YXRhX2ZpbGVuYW1lID0gU0NTX05VTEw7CisgICAgfQogICB9CiAKICAgdG1w
ID0gbXhHZXRGaWVsZChzZXR0aW5ncywgMCwgImxvZ19jc3ZfZmlsZW5hbWUi
KTsKICAgaWYgKHRtcCAhPSBTQ1NfTlVMTCkgewogICAgIC8qIG5lZWQgdG8g
ZnJlZSB0aGlzIGxhdGVyICovCiAgICAgc3Rncy0+bG9nX2Nzdl9maWxlbmFt
ZSA9IG14QXJyYXlUb1N0cmluZyh0bXApOworICAgIC8qIFlBTE1JUCBwdXRz
ICIiIGhlcmUgISEgKi8KKyAgICBpZiAoc3RybGVuKHN0Z3MtPmxvZ19jc3Zf
ZmlsZW5hbWUpID09IDApIHsKKyAgICAgIHNjc19mcmVlKCh2b2lkICopc3Rn
cy0+bG9nX2Nzdl9maWxlbmFtZSk7CisgICAgICBzdGdzLT5sb2dfY3N2X2Zp
bGVuYW1lID0gU0NTX05VTEw7CisgICAgfQogICB9CiAKICAgLyogY29uZXMg
Ki8KQEAgLTQzMCw3ICs0NDIsNyBAQAogICAgIFAtPmkgPSBjYXN0X3RvX3Nj
c19pbnRfYXJyKG14R2V0SXIoUF9tZXgpLCBQLT5wW1AtPm5dKTsKICAgfQog
I2VuZGlmCi0jaWYgU0ZMT0FUID4gMAorI2lmIGRlZmluZWQoU0ZMT0FUKSB8
fCBkZWZpbmVkKFFGTE9BVCkKICAgQS0+eCA9IGNhc3RfdG9fc2NzX2Zsb2F0
X2FycihteEdldFByKEFfbWV4KSwgQS0+cFtBLT5uXSk7CiAgIGlmIChQX21l
eCkgewogICAgIFAtPnggPSBjYXN0X3RvX3Njc19mbG9hdF9hcnIobXhHZXRQ
cihQX21leCksIFAtPnBbUC0+bl0pOwpAQCAtNTU4LDcgKzU3MCw3IEBACiAg
ICAgc2NzX2ZyZWUoc3Rncyk7CiAgIH0KICAgaWYgKGQpIHsKLSNpZiBTRkxP
QVQgPiAwIC8qIG9ubHkgZnJlZSBpZiBjb3BpZXMsIHdoaWNoIGlzIG9ubHkg
d2hlbiBmbGFncyBzZXQgKi8KKyNpZiBkZWZpbmVkKFNGTE9BVCkgfHwgZGVm
aW5lZChRRkxPQVQpIC8qIG9ubHkgZnJlZSBpZiBjb3BpZXMsIHdoaWNoIGlz
IG9ubHkgd2hlbiBmbGFncyBzZXQgKi8KICAgICBpZiAoZC0+YikgewogICAg
ICAgc2NzX2ZyZWUoZC0+Yik7CiAgICAgfQpAQCAtNTc1LDcgKzU4Nyw3IEBA
CiAgICAgICAgIHNjc19mcmVlKGQtPkEtPmkpOwogICAgICAgfQogI2VuZGlm
Ci0jaWYgU0ZMT0FUID4gMCAvKiBvbmx5IGZyZWUgaWYgY29waWVzLCB3aGlj
aCBpcyBvbmx5IHdoZW4gZmxhZ3Mgc2V0ICovCisjaWYgZGVmaW5lZChTRkxP
QVQpIHx8IGRlZmluZWQoUUZMT0FUKSAvKiBvbmx5IGZyZWUgaWYgY29waWVz
LCB3aGljaCBpcyBvbmx5IHdoZW4gZmxhZ3Mgc2V0ICovCiAgICAgICBpZiAo
ZC0+QS0+eCkgewogICAgICAgICBzY3NfZnJlZShkLT5BLT54KTsKICAgICAg
IH0KQEAgLTU5MSw3ICs2MDMsNyBAQAogICAgICAgICBzY3NfZnJlZShkLT5Q
LT5pKTsKICAgICAgIH0KICNlbmRpZgotI2lmIFNGTE9BVCA+IDAgLyogb25s
eSBmcmVlIGlmIGNvcGllcywgd2hpY2ggaXMgb25seSB3aGVuIGZsYWdzIHNl
dCAqLworI2lmIGRlZmluZWQoU0ZMT0FUKSB8fCBkZWZpbmVkKFFGTE9BVCkg
Lyogb25seSBmcmVlIGlmIGNvcGllcywgd2hpY2ggaXMgb25seSB3aGVuIGZs
YWdzIHNldCAqLwogICAgICAgaWYgKGQtPlAtPngpIHsKICAgICAgICAgc2Nz
X2ZyZWUoZC0+UC0+eCk7CiAgICAgICB9Cg==
====
EOF
uudecode $SCS_MATLAB".patch.uue"
pushd $SCS_MATLAB
patch -p 1 < ../$SCS_MATLAB".patch"
popd

# Install scs_qprintf.c
cat > scs_qprintf.c.uue <<EOF
begin-base64 644 scs_qprintf.c
LyoKICBzY3NfcXByaW50Zi5jCiovCgojaW5jbHVkZSA8c3RkaW8uaD4KI2lu
Y2x1ZGUgPHN0ZGxpYi5oPgojaW5jbHVkZSA8c3RkYXJnLmg+CiNpbmNsdWRl
IDxzdHJpbmcuaD4KI2luY2x1ZGUgPGN0eXBlLmg+CiNpbmNsdWRlIDxzdGRk
ZWYuaD4KI2luY2x1ZGUgPHF1YWRtYXRoLmg+CgppbnQgc2NzX3FwcmludGYo
Y29uc3QgY2hhciogZm10LCAuLi4pCnsKICAvLyBTYW5pdHkgY2hlY2sKICBj
b25zdCBzaXplX3QgbWF4X3N0cl9sZW4gPSAyNTY7CiAgc2l6ZV90IGxlbj1z
dHJsZW4oZm10KTsKICBpZiAobGVuPj1tYXhfc3RyX2xlbikKICAgIHsKICAg
ICAgZnByaW50ZihzdGRlcnIsICJJbnB1dCBzdHJpbmcgdG9vIGxvbmchIElz
IGl0IGNvcnJ1cHRlZD8hXG4iKTsKICAgICAgcmV0dXJuIC0xOwogICAgfSAg
ICAKCiAgLy8gUGFyc2UgdGhlIHR5cGUgb2YgdGhlIGZtdCBhcmd1bWVudAog
IHZhX2xpc3QgYXJnczsKICB2YV9zdGFydChhcmdzLCBmbXQpOwoKICAvLyBG
aW5kIHRoZSBmb3JtYXQgY29udmVyc2lvbiBjaGFyYWN0ZXJzIGFuZCBwcmlu
dGYgdGhlIGNvcnJlc3BvbmRpbmcgYXJndW1lbnQKICBjaGFyICpzdHIgPSAo
Y2hhciAqKWZtdDsKICB3aGlsZSAoKnN0ciAhPSAnXDAnKQogICAgewogICAg
ICAvLyBDaGVjayBmb3IgYSAnJScgZm9ybWF0IGNoYXJhY3RlcgogICAgICBp
ZiAoKnN0ciAhPSAnJScpCiAgICAgICAgewogICAgICAgICAgcHV0Y2hhciAo
KnN0cik7CiAgICAgICAgICBzdHIrKzsKICAgICAgICAgIGNvbnRpbnVlOwog
ICAgICAgIH0KCiAgICAgIC8vIEZpbmQgdGhlIGNvcnJlc3BvbmRpbmcgZm9y
bWF0IGNvbnZlcnNpb24gY2hhcmFjdGVyCiAgICAgIGNoYXIgKmNjID0gc3Ry
KzE7CiAgICAgIGlmICgqY2MgPT0gJyUnKQogICAgICAgIHsKICAgICAgICAg
IHB1dGNoYXIoJyUnKTsKICAgICAgICAgIHN0cisrOwogICAgICAgICAgY29u
dGludWU7CiAgICAgICAgfQoKICAgICAgLy8gQ2hlY2sgZm9yIGEgdmFyaWFi
bGUgd2lkdGggYXJndW1lbnQKICAgICAgaW50IHdpZHRoID0gMDsKICAgICAg
aWYgKCpjYyA9PSAnKicpCiAgICAgICAgewogICAgICAgICAgd2lkdGggPSB2
YV9hcmcoYXJncyxpbnQpOwogICAgICAgICAgY2MrKzsKICAgICAgICB9Cgog
ICAgICAvLyBGaW5kIHRoZSBjb252ZXJzaW9uIGNoYXJhY3RlciBmb2xsb3dp
bmcgdGhlICclJwogICAgICBpbnQgaXNfbG9uZ19pbnQgPSAwOwogICAgICB3
aGlsZSAoKmNjICE9ICdcMCcpCiAgICAgICAgewogICAgICAgICAgLy8gQ2hl
Y2sgZm9yIGxvbmcgaW50ZWdlciBmb3JtYXQKICAgICAgICAgIGlmICgqY2Mg
PT0gJ2wnKSAKICAgICAgICAgICAgewogICAgICAgICAgICAgIGlzX2xvbmdf
aW50ID0gMTsKICAgICAgICAgICAgICBjYysrOwogICAgICAgICAgICAgIGlm
ICgqY2MgPT0gJ1wwJykKICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAg
ICAgICAgZnByaW50ZihzdGRlcnIsIkJhZCBsb25nIGludCBmb3JtYXQgY29u
dmVyc2lvbiEiKTsKICAgICAgICAgICAgICAgICAgdmFfZW5kKGFyZ3MpOwog
ICAgICAgICAgICAgICAgICByZXR1cm4gLTE7CiAgICAgICAgICAgICAgICB9
CiAgICAgICAgICAgIH0KICAgICAgICAgIGlmIChpc2FscGhhKCpjYykpIAog
ICAgICAgICAgICB7CiAgICAgICAgICAgICAgYnJlYWs7CiAgICAgICAgICAg
IH0KICAgICAgICAgIGNjKys7CiAgICAgICAgfQogICAgICAvLyBGYWlsZWQg
dG8gZmluZCBhIGNvbnZlcnNpb24gY2hhcmFjdGVyID8hPwogICAgICBpZiAo
KmNjID09ICdcMCcpCiAgICAgICAgewogICAgICAgICAgZnByaW50ZihzdGRl
cnIsICJEaWQgbm90IGZpbmQgYSBjb252ZXJzaW9uIGNoYXJhY3Rlcj8hXG4i
KTsKICAgICAgICAgIHZhX2VuZChhcmdzKTsKICAgICAgICAgIHJldHVybiAt
MTsKICAgICAgICB9CgogICAgICAvLyBBbGxvY2F0ZSBzcGFjZSBmb3IgdGhl
IGNvbnZlcnNpb24gc3RyaW5nICIlLi4uIiBwbHVzIHNwYWNlIGZvciAnUScK
ICAgICAgc2l6ZV90IGNvbnZfc3RyX2xlbj0ocHRyZGlmZl90KShjYy1zdHIp
OwogICAgICBjaGFyICpjb252X3N0cj1jYWxsb2MoY29udl9zdHJfbGVuKzMs
c2l6ZW9mKGNoYXIpKTsKICAgICAgc3RybmNweShjb252X3N0cixzdHIsY29u
dl9zdHJfbGVuKTsKCiAgICAgIC8vIENyZWF0ZSB0aGUgbmV3IGZvcm1hdCBz
dHJpbmcgYW5kIHRoZW4gcHJpbnQgaXQKICAgICAgc3dpdGNoICgqY2MpCiAg
ICAgICAgewoKICAgICAgICBjYXNlICdhJzogIAogICAgICAgIGNhc2UgJ0En
OiAgCiAgICAgICAgY2FzZSAnZSc6ICAKICAgICAgICBjYXNlICdFJzogIAog
ICAgICAgIGNhc2UgJ2YnOiAgCiAgICAgICAgY2FzZSAnRic6ICAKICAgICAg
ICBjYXNlICdnJzogIAogICAgICAgIGNhc2UgJ0cnOgogICAgICAgICAgLy8g
UXVhZCBmbG9hdGluZyBwb2ludCBjb252ZXJzaW9uCiAgICAgICAgICBjb252
X3N0cltjb252X3N0cl9sZW5dPSdRJzsKICAgICAgICAgIGNvbnZfc3RyW2Nv
bnZfc3RyX2xlbisxXT0qY2M7CiAgICAgICAgICAvLyBGaW5kIHRoZSByZXF1
aXJlZCBxdWFkIGZsb2F0aW5nIHBvaW50IHN0cmluZyBsZW5ndGgKICAgICAg
ICAgIGludCBuOwogICAgICAgICAgX19mbG9hdDEyOCB2YWwgPSB2YV9hcmco
YXJncyxfX2Zsb2F0MTI4KTsKICAgICAgICAgIGlmICh3aWR0aCkKICAgICAg
ICAgICAgewogICAgICAgICAgICAgIG49cXVhZG1hdGhfc25wcmludGYgKE5V
TEwsIDAsIGNvbnZfc3RyLCB3aWR0aCwgdmFsKTsKICAgICAgICAgICAgfQog
ICAgICAgICAgZWxzZQogICAgICAgICAgICB7CiAgICAgICAgICAgICAgbj1x
dWFkbWF0aF9zbnByaW50ZiAoTlVMTCwgMCwgY29udl9zdHIsIHZhbCk7CiAg
ICAgICAgICAgIH0KICAgICAgICAgIC8vIENyZWF0ZSB0aGUgcXVhZCBmbG9h
dGluZyBwb2ludCBzdHJpbmcgYW5kIHRoZW4gcHJpbnQgaXQKICAgICAgICAg
IGlmIChuPi0xKQogICAgICAgICAgICB7CiAgICAgICAgICAgICAgY2hhciAq
cXVhZF9zdHIgPSBjYWxsb2MobisxLCBzaXplb2YoY2hhcikpOwogICAgICAg
ICAgICAgIGlmIChxdWFkX3N0ciA9PSBOVUxMKQogICAgICAgICAgICAgICAg
ewogICAgICAgICAgICAgICAgICB2YV9lbmQoYXJncyk7CiAgICAgICAgICAg
ICAgICAgIGZyZWUoY29udl9zdHIpOwogICAgICAgICAgICAgICAgICBmcHJp
bnRmKHN0ZGVyciwgImNhbGxvYygpIGZhaWxlZCFcbiIpOwogICAgICAgICAg
ICAgICAgICByZXR1cm4gLTE7CiAgICAgICAgICAgICAgICB9CiAgICAgICAg
ICAgICAgaWYgKHdpZHRoKQogICAgICAgICAgICAgICAgewogICAgICAgICAg
ICAgICAgICBxdWFkbWF0aF9zbnByaW50ZiAocXVhZF9zdHIsIG4rMSwgY29u
dl9zdHIsIHdpZHRoLCB2YWwpOwogICAgICAgICAgICAgICAgfQogICAgICAg
ICAgICAgIGVsc2UKICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAg
ICAgcXVhZG1hdGhfc25wcmludGYgKHF1YWRfc3RyLCBuKzEsIGNvbnZfc3Ry
LCB2YWwpOwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgIHByaW50
ZiAoIiVzIiwgcXVhZF9zdHIpOwogICAgICAgICAgICAgIGZyZWUgKHF1YWRf
c3RyKTsKICAgICAgICAgICAgfQogICAgICAgICAgZnJlZShjb252X3N0cik7
CiAgICAgICAgICBicmVhazsKICAgICAgICAgIAogICAgICAgIGNhc2UgJ2Qn
OgogICAgICAgIGNhc2UgJ2knOgogICAgICAgICAgLy8gVGhpcyBpcyBhbiBp
bnRlZ2VyIGZvcm1hdCBzdHJpbmcKICAgICAgICAgIGNvbnZfc3RyW2NvbnZf
c3RyX2xlbl09KmNjOwogICAgICAgICAgaWYgKGlzX2xvbmdfaW50KQogICAg
ICAgICAgICB7CiAgICAgICAgICAgICAgaWYgKHdpZHRoKQogICAgICAgICAg
ICAgICAgewogICAgICAgICAgICAgICAgICBwcmludGYoY29udl9zdHIsIHdp
ZHRoLCB2YV9hcmcoYXJncywgbG9uZykpOwogICAgICAgICAgICAgICAgfQog
ICAgICAgICAgICAgIGVsc2UKICAgICAgICAgICAgICAgIHsKICAgICAgICAg
ICAgICAgICAgcHJpbnRmKGNvbnZfc3RyLCB2YV9hcmcoYXJncywgbG9uZykp
OwogICAgICAgICAgICAgICAgfSAgICAgICAgICAgICAgICAKICAgICAgICAg
ICAgfQogICAgICAgICAgZWxzZQogICAgICAgICAgICB7CiAgICAgICAgICAg
ICAgaWYgKHdpZHRoKQogICAgICAgICAgICAgICAgewogICAgICAgICAgICAg
ICAgICBwcmludGYoY29udl9zdHIsIHdpZHRoLCB2YV9hcmcoYXJncywgaW50
KSk7CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgZWxzZQogICAg
ICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICBwcmludGYoY29udl9z
dHIsIHZhX2FyZyhhcmdzLCBpbnQpKTsKICAgICAgICAgICAgICAgIH0gICAg
ICAgICAgICAgICAgCiAgICAgICAgICAgIH0KICAgICAgICAgIGZyZWUoY29u
dl9zdHIpOwogICAgICAgICAgYnJlYWs7CgogICAgICAgIGNhc2UgJ3MnOgog
ICAgICAgICAgLy8gSXQgaXMgYSBzdHJpbmcgZm9ybWF0IHN0cmluZwogICAg
ICAgICAgY29udl9zdHJbY29udl9zdHJfbGVuXT0qY2M7CiAgICAgICAgICBw
cmludGYoY29udl9zdHIsIHZhX2FyZyhhcmdzLCBpbnQpKTsKICAgICAgICAg
IGZyZWUoY29udl9zdHIpOwogICAgICAgICAgYnJlYWs7CiAgICAgICAgICAK
ICAgICAgICBkZWZhdWx0OgogICAgICAgICAgLy8gQ29udmVyc2lvbiBub3Qg
c3VwcG9ydGVkCiAgICAgICAgICBmcHJpbnRmKHN0ZGVyciwgIkNvbnZlcnNp
b24gbm90IHN1cHBvcnRlZCEiKTsKICAgICAgICAgIGZyZWUoY29udl9zdHIp
OwogICAgICAgICAgdmFfZW5kKGFyZ3MpOwogICAgICAgICAgcmV0dXJuIC0x
OwogICAgICAgICAgYnJlYWs7CiAgICAgICAgfQoKICAgICAgLy8gTW92ZSBz
dHIgYmV5b25kIHRoZSBjdXJyZW50IGZvcm1hdCBjaGFyYWN0ZXIKICAgICAg
c3RyPWNjKzE7CiAgICB9CgogIC8vIERvbmUKICB2YV9lbmQoYXJncyk7CiAg
cmV0dXJuIDA7Cn0KCiNpZiBkZWZpbmVkKFRFU1RfU0NTX1FQUklOVEYpCi8q
CkNvbXBpbGUgd2l0aCA6CiAgIGdjYyAtbyBzY3NfcXByaW50Zl90ZXN0IHNj
c19xcHJpbnRmLmMgLVdhbGwgLWxxdWFkbWF0aCAtTzAgLWdnZGIzIFwKICAg
ICAgIC1EVEVTVF9TQ1NfUVBSSU5URgoqLwppbnQgbWFpbih2b2lkKQp7CiAg
aW50IHJldCA9IHNjc19xcHJpbnRmKCJUaGlzIHN0cmluZyBoYXMgbm8gZm9y
bWF0IGNvbnZlcnNpb24hXG4iKTsKICAKICBfX2Zsb2F0MTI4IHYgPSAxMjg7
CiAgX19mbG9hdDEyOCB3ID0gMTAwMDAwMS4zOwogIF9fZmxvYXQxMjggeCA9
IDExLjM7CiAgX19mbG9hdDEyOCB5ID0gLTExLjM7CiAgX19mbG9hdDEyOCB6
ID0gMjAwMDAwMS4zOwogIHJldCA9IHNjc19xcHJpbnRmKCJ2OiAlLjRhLCB3
OiAlLjJnLCB4OiAlLjRlLCB5OiAlLjRmLCB6OiAlKi44Z1xuIiwKICAgICAg
ICAgICAgICAgICAgICB2LCB3LCB4LCB5LCAxNCwgeik7CgogIGludCBrID0g
MTAwOwogIGxvbmcgbGsgPSAyMDA7CiAgcmV0ID0gc2NzX3FwcmludGYoIms6
ICVkLCAlKmQsIGxrOiAlbGlcbiIsIGssIDYsIGssIGxrKTsKCiAgcmV0ID0g
c2NzX3FwcmludGYoIlRoaXMgaXMgYSBzdHJpbmcgOiAlc1xuIiwgIlN0cmlu
Z1N0cmluZyIpOwoKICByZXQgPSBzY3NfcXByaW50ZigidjogJS40QSwgdzog
JS4yRywgeDogJS40RSwgeTogJS40RiwgejogJSouMTBHXG4gXAprOiAlZCwg
bGs6ICVsaVxuIFRoaXMgaXMgYSBhbm90aGVyIHN0cmluZyA6ICVzXG4iLAog
ICAgICAgICAgICAgICAgICAgIDkqdiwgNCp3LCAyKngsIDMqeSwgMTQsIDUq
eiwgNiprLCA3KmxrLCAiRGlmZmVyZW50U3RyaW5nIik7CgogIAogIHJldHVy
biByZXQ7Cn0KI2VuZGlmCg==
====
EOF
uudecode scs_qprintf.c.uue
mv scs_qprintf.c  $SCS_MATLAB
rm -f scs_qprintf.c.uue

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
