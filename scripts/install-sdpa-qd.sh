#!/bin/sh
#
# Install sdpa_qd
#
# Run this script as root!
#

#
# Set Octave directories
#
OCTAVE_VER=8.4.0
OCTAVE_DIR="/usr/local/octave-"$OCTAVE_VER
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin
OCTAVE_SHARE_DIR=$OCTAVE_DIR/share/octave
OCTAVE_CLI=$OCTAVE_BIN_DIR/octave-cli
OCTAVE_LOCAL_VERSION="`$OCTAVE_CLI --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m
OCTAVE_MKOCTFILE="$OCTAVE_BIN_DIR/mkoctfile --mex"

#
# Set sdpa-qd directories
#
THIS_DIR=`pwd`/SDPAQD
SDPAQD_INSTALL_DIR=$THIS_DIR/sdpa-qd
SDPAQD_INCLUDE_DIR=$SDPAQD_INSTALL_DIR/include/qd
SDPAQD_LIB_DIR=$SDPAQD_INSTALL_DIR/lib
SDPAQD_BIN_DIR=$SDPAQD_INSTALL_DIR/bin

mkdir -p $SDPAQD_INSTALL_DIR
cd $THIS_DIR

#
# Build libqd.a
#
QD_VER=2.3.24
QD_ARCHIVE="qd-"$QD_VER".tar.gz"
QD_URL="https://www.davidhbailey.com/dhbsoftware/"$QD_ARCHIVE
if ! test -f $QD_ARCHIVE ; then
    wget -c $QD_URL
fi
rm -Rf qd-$QD_VER
tar -xf $QD_ARCHIVE
mkdir build-qd
cd build-qd
../qd-$QD_VER/configure --prefix=$SDPAQD_INSTALL_DIR
make V=1 && make install
cd ..

#
# Install SDPA
#
SDPAQD_VER=7.1.2
SDPAQD_ARCHIVE="sdpa-qd."$SDPAQD_VER".src.20091005.tar.gz"
SDPAQD_URL="https://sourceforge.net/projects/sdpa/files/sdpa-qd-dd/"$SDPAQD_ARCHIVE
if ! test -f $SDPAQD_ARCHIVE ; then
    wget -c $SDPAQD_URL
fi
rm -Rf sdpa-$SDPAQD_VER
tar -xf $SDPAQD_ARCHIVE
# Silence some warning messages
cat > sdpa-qd-$SDPAQD_VER".patch.uue" <<EOF
begin-base64 644 sdpa-qd-7.1.2.patch
LS0tIHNkcGEtcWQtNy4xLjIvc2RwYV9pby5jcHAJMjAwOS0xMC0wNSAxMjox
NDoxMS4wMDAwMDAwMDAgKzExMDAKKysrIHNkcGEtcWQtNy4xLjIubmV3L3Nk
cGFfaW8uY3BwCTIwMjQtMDItMTYgMDg6Mjc6MTguMTAxMjQzMTYyICsxMTAw
CkBAIC0zOTksNyArMzk5LDcgQEAKIAkJICBxZF9yZWFsIHRtcDsKICAgICAg
ICAgICAgICAgICAgZnNjYW5mKGZwRGF0YSwiJSpbXjAtOSstXSVbXix9IFx0
XG5dIixtcGJ1ZmZlcik7IHRtcCA9IG1wYnVmZmVyOwogCQkgIGlmICh0bXAh
PTAuMCkgewotCQkJTFBfQ05vblplcm9Db3VudFtibG9ja051bWJlcltsMl0r
al0rKzsKKwkJCUxQX0NOb25aZXJvQ291bnRbYmxvY2tOdW1iZXJbbDJdK2pd
PXRydWU7CiAJCSAgfQogCQl9CiAJICB9IGVsc2UgewotLS0gc2RwYS1xZC03
LjEuMi9zcG9vbGVzL3BhdGNoZXMvcGF0Y2gtTWFrZS5pbmMJMjAwOS0wMy0x
MCAxMjowNjo0My4wMDAwMDAwMDAgKzExMDAKKysrIHNkcGEtcWQtNy4xLjIu
bmV3L3Nwb29sZXMvcGF0Y2hlcy9wYXRjaC1NYWtlLmluYwkyMDI0LTAyLTE2
IDA4OjM2OjM4LjYzNTAzNTQ3MCArMTEwMApAQCAtMTQsNyArMTQsNyBAQAog
ICMgQ0ZMQUdTID0gLVdhbGwgLXBnCiAgIyBDRkxBR1MgPSAkKE9QVExFVkVM
KSAtRF9QT1NJWF9DX1NPVVJDRT0xOTk1MDZMCiAtICBDRkxBR1MgPSAkKE9Q
VExFVkVMKQotKyAgQ0ZMQUdTICs9IC1PMiAtZnVucm9sbC1hbGwtbG9vcHMg
JChwdGhlYWRfY2ZsYWdzKQorKyAgQ0ZMQUdTICs9IC1PMiAtZnVucm9sbC1h
bGwtbG9vcHMgJChwdGhlYWRfY2ZsYWdzKSAtRF9ERUZBVUxUX1NPVVJDRQog
ICMgQ0ZMQUdTID0gLVdhbGwgJChPUFRMRVZFTCkKICAjCiAgIy0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0K
====
EOF
uudecode sdpa-qd-$SDPAQD_VER.patch.uue
pushd sdpa-qd-$SDPAQD_VER
patch -p 1 < ../sdpa-qd-$SDPAQD_VER.patch
./configure --prefix=$SDPAQD_INSTALL_DIR \
            --enable-metis \
            --enable-openmp \
            --with-qd-includedir=$SDPAQD_INCLUDE_DIR \
            --with-qd-libdir=$SDPAQD_LIB_DIR
make V=1 && make -k install
popd

#
# Copy sdpa_qd to Octave 
#
cp $SDPAQD_BIN_DIR/sdpa_qd $OCTAVE_BIN_DIR

#
# Test
#

# From "SDPA-M (SemiDefinite Programming Algorithm in MATLAB)
# User’s Manual — Version 6.2.0", K. Fujisawa, Y. Futakata,
# M. Kojima, S. Matsuyama, S. Nakamura, K. Nakata and M. Yamashita
# B-359, January 2000 Revised: May 2005
#
rm -f example_1*
cat > example_1.dat <<EOF
"Example 1: mDim = 3, nBLOCK = 1, {2}"
   3  =  mDIM
   1  =  nBLOCK
   2  = bLOCKsTRUCT
{48, -8, 20}
{ {-11,  0}, { 0, 23} }
{ { 10,  4}, { 4,  0} }
{ {  0,  0}, { 0, -8} }
{ {  0, -8}, {-8, -2} }
EOF
cat > example_1.ini <<EOF
{0.0, -4.0, 0.0}
{ {11.0, 0.0}, {0.0, 9.0} }
{ {5.9,  -1.375}, {-1.375, 1.0} }
EOF
$OCTAVE_BIN_DIR/sdpa_qd -dd example_1.dat -o example_1.results 

#
# Done
#
rm -f example_1* sdpa-qd-$SDPAQD_VER.patch sdpa-qd-$SDPAQD_VER.patch.uue
rm -Rf build-qd qd-$QD_VER sdpa-qd-$SDPAQD_VER

