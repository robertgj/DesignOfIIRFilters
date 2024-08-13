#!/bin/sh
# Install sdpa_gmp as a YALMIP solver

#
# 1. Run this script as root!
# 2. The Fedora gmp-static and gmp-devel packages are prerequisites
#
# Add address-sanitizer flags for address sanitizer build
# To disable checking in atexit(): export ASAN_OPTIONS="leak_check_at_exit=0"
#

#
# Set Octave directories
#
OCTAVE_VER=${OCTAVE_VER:-9.2.0}
OCTAVE_DIR="/usr/local/octave-"$OCTAVE_VER
OCTAVE_SHARE_DIR=$OCTAVE_DIR/share/octave
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin
OCTAVE_CLI=$OCTAVE_BIN_DIR/octave-cli
OCTAVE_LOCAL_VERSION="`$OCTAVE_CLI --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m
OCTAVE_MKOCTFILE="$OCTAVE_BIN_DIR/mkoctfile --mex"

#
# Install sdpa_gmp
#
SDPA_GMP_VER=master
SDPA_GMP_ARCHIVE=master.zip
SDPA_GMP_URL="https://github.com/nakatamaho/sdpa-gmp/archive/refs/heads/$SDPA_GMP_ARCHIVE"
if ! test -f sdpa-gmp-$SDPA_GMP_ARCHIVE ; then
    wget -c $SDPA_GMP_URL
    mv -f $SDPA_GMP_ARCHIVE sdpa-gmp-$SDPA_GMP_ARCHIVE
fi
rm -Rf sdpa-gmp-$SDPA_GMP_VER
unzip sdpa-gmp-$SDPA_GMP_ARCHIVE
pushd sdpa-gmp-$SDPA_GMP_VER
aclocal ; autoconf ; automake --add-missing ; autoreconf --force --install
# For gcc address-sanitizer
# CFLAGS="-fsanitize=leak,undefined,address -fno-omit-frame-pointer" \
# LDFLAGS="-lasan -fsanitize=leak,undefined,address -fno-omit-frame-pointer"
./configure --enable-openmp=yes \
            --with-gmp-includedir=/usr/include \
            --with-gmp-libdir=/usr/lib64
make -j 8
cp sdpa_gmp $OCTAVE_BIN_DIR

#
# Test
#
./sdpa_gmp example1.dat example1.result
cat example1.result

#
# Done
#
popd
rm -Rf sdpa-gmp-$SDPA_GMP_VER
rm -f sdpa-gmp-$SDPA_GMP_VER.patch.uue sdpa-gmp-$SDPA_GMP_VER.patch

