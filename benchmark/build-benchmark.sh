#!/bin/bash

# Assume these packages are installed:
#  atlas.x86_64            3.10.3-10.fc32
#  blas.x86_64             3.9.0-3.fc32
#  lapack.x86_64           3.9.0-3.fc32
#  gsl.x86_64              2.6-2.fc32
#  gsl-devel.x86_64        2.6-2.fc32
#  openblas.x86_64         0.3.9-3.fc32
#  openblas-threads.x86_64 0.3.9-3.fc32
# eg:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
#  lapack-3.9.1.tar.gz
#  SuiteSparse-5.9.0.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.9.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-6.2.0.tar.lz
#  io-?.?.?.tar.gz
#  statistics-?.?.?.tar.gz
#  struct-?.?.?.tar.gz
#  optim-?.?.?.tar.gz
#  control-?.?.?.tar.gz
#  signal-?.?.?.tar.gz

# Disable CPU frequency scaling:
# for c in `seq 0 7` ; do
#   echo "4500000">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq ;
#   echo "performance">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor ;
# done ; 

# Show system information
uname -r
grep -m1 -A7 vendor_id /proc/cpuinfo
sudo cpupower -c all frequency-info
dnf list installed kernel* gcc* atlas* openblas* gsl* blas* lapack* \
    | egrep -v metadata | awk '{print $1 "\t\t" $2}'

# Build local versions of the lapack and blas libraries
export LOCAL_PREFIX=`pwd`
export LPVER=3.9.1
source ./build-lapack.sh

# Build local versions of the other libraries used by octave
export LAPACK_DIR=$LOCAL_PREFIX/lapack/generic/lapack-$LPVER
export LD_LIBRARY_PATH=$LOCAL_PREFIX"/lib:"$LAPACK_DIR
source ./build-other-libs.sh

# Common octave configure options
export OCTAVE_CONFIG_OPTIONS=" \
       --disable-docs \
       --disable-java \
       --disable-atomic-refcount \
       --without-fltk \
       --without-qt \
       --without-sndfile \
       --without-portaudio \
       --without-qhull \
       --without-magick \
       --without-glpk \
       --without-hdf5 \
       --with-arpack-includedir=$LOCAL_PREFIX/include \
       --with-arpack-libdir=$LOCAL_PREFIX/lib \
       --with-qrupdate-includedir=$LOCAL_PREFIX/include \
       --with-qrupdate-libdir=$LOCAL_PREFIX/lib \
       --with-amd-includedir=$LOCAL_PREFIX/include \
       --with-amd-libdir=$LOCAL_PREFIX/lib \
       --with-camd-includedir=$LOCAL_PREFIX/include \
       --with-camd-libdir=$LOCAL_PREFIX/lib \
       --with-colamd-includedir=$LOCAL_PREFIX/include \
       --with-colamd-libdir=$LOCAL_PREFIX/lib \
       --with-ccolamd-includedir=$LOCAL_PREFIX/include \
       --with-ccolamd-libdir=$LOCAL_PREFIX/lib \
       --with-cholmod-includedir=$LOCAL_PREFIX/include \
       --with-cholmod-libdir=$LOCAL_PREFIX/lib \
       --with-cxsparse-includedir=$LOCAL_PREFIX/include \
       --with-cxsparse-libdir=$LOCAL_PREFIX/lib \
       --with-umfpack-includedir=$LOCAL_PREFIX/include \
       --with-umfpack-libdir=$LOCAL_PREFIX/lib \
       --with-fftw3-includedir=$LOCAL_PREFIX/include \
       --with-fftw3-libdir=$LOCAL_PREFIX/lib \
       --with-fftw3f-includedir=$LOCAL_PREFIX/include \
       --with-fftw3f-libdir=$LOCAL_PREFIX/lib"

# Unpack Octave
export OCTAVE_VER=6.2.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 664 octave-6.2.0.patch
LS0tIG9jdGF2ZS02LjIuMC9saWJvY3RhdmUvdXRpbC9sby1hcnJheS1lcnJ3
YXJuLmNjCTIwMjEtMDItMjAgMDQ6MzY6MzQuMDAwMDAwMDAwICsxMTAwCisr
KyBvY3RhdmUtNi4yLjAubmV3L2xpYm9jdGF2ZS91dGlsL2xvLWFycmF5LWVy
cndhcm4uY2MJMjAyMS0wNC0zMCAyMzo0OToyNi41NTU5MDEyMTggKzEwMDAK
QEAgLTI5LDcgKzI5LDcgQEAKIAogI2luY2x1ZGUgPGNpbnR0eXBlcz4KICNp
bmNsdWRlIDxjbWF0aD4KLQorI2luY2x1ZGUgPGxpbWl0cz4KICNpbmNsdWRl
IDxzc3RyZWFtPgogCiAjaW5jbHVkZSAibG8tYXJyYXktZXJyd2Fybi5oIgot
LS0gb2N0YXZlLTYuMi4wL2xpYm9jdGF2ZS91dGlsL2FjdGlvbi1jb250YWlu
ZXIuaAkyMDIxLTAyLTIwIDA0OjM2OjM0LjAwMDAwMDAwMCArMTEwMAorKysg
b2N0YXZlLTYuMi4wLm5ldy9saWJvY3RhdmUvdXRpbC9hY3Rpb24tY29udGFp
bmVyLmgJMjAyMS0wNC0zMCAyMzozMzoxMC40ODA3OTA2MzggKzEwMDAKQEAg
LTI5LDYgKzI5LDcgQEAKICNpbmNsdWRlICJvY3RhdmUtY29uZmlnLmgiCiAK
ICNpbmNsdWRlIDxmdW5jdGlvbmFsPgorI2luY2x1ZGUgPGNzdGRkZWY+CiAK
IC8vIFRoaXMgY2xhc3MgYWxsb3dzIHJlZ2lzdGVyaW5nIGFjdGlvbnMgaW4g
YSBsaXN0IGZvciBsYXRlcgogLy8gZXhlY3V0aW9uLCBlaXRoZXIgZXhwbGlj
aXRseSBvciB3aGVuIHRoZSBjb250YWluZXIgZ29lcyBvdXQgb2YKLS0tIG9j
dGF2ZS02LjIuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXBhdGguY2MJMjAy
MS0wMi0yMCAwNDozNjozNC4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS02
LjIuMC5uZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1wYXRoLmNjCTIwMjEt
MDQtMzAgMjM6MTg6MjguOTc1OTQ0ODc3ICsxMDAwCkBAIC00MDcsNyArNDA3
LDggQEAKICAgICAgICAgYm9vbCBvayA9IGRpLnVwZGF0ZSAoKTsKIAogICAg
ICAgICBpZiAoISBvaykKLSAgICAgICAgICB3YXJuaW5nICgibG9hZC1wYXRo
OiB1cGRhdGUgZmFpbGVkIGZvciAnJXMnLCByZW1vdmluZyBmcm9tIHBhdGgi
LAorICAgICAgICAgIHdhcm5pbmdfd2l0aF9pZCAoIk9jdGF2ZTpsb2FkLXBh
dGgtdXBkYXRlLWZhaWxlZCIsCisJCSAgICAgICAgICAgICJsb2FkLXBhdGg6
IHVwZGF0ZSBmYWlsZWQgZm9yICclcycsIHJlbW92aW5nIGZyb20gcGF0aCIs
CiAgICAgICAgICAgICAgICAgICAgZGkuZGlyX25hbWUuY19zdHIgKCkpOwog
ICAgICAgICBlbHNlCiAgICAgICAgICAgYWRkIChkaSwgdHJ1ZSwgIiIsIHRy
dWUpOwpAQCAtMTI1OSw3ICsxMjYwLDggQEAKICAgICBpZiAoISBmcykKICAg
ICAgIHsKICAgICAgICAgc3RkOjpzdHJpbmcgbXNnID0gZnMuZXJyb3IgKCk7
Ci0gICAgICAgIHdhcm5pbmcgKCJsb2FkX3BhdGg6ICVzOiAlcyIsIGRpcl9u
YW1lLmNfc3RyICgpLCBtc2cuY19zdHIgKCkpOworICAgICAgICB3YXJuaW5n
X3dpdGhfaWQgKCJPY3RhdmU6bG9hZC1wYXRoLWRpci1pbmZvLXVwZGF0ZSIs
CisJCSAgICAgICAgICAibG9hZF9wYXRoOiAlczogJXMiLCBkaXJfbmFtZS5j
X3N0ciAoKSwgbXNnLmNfc3RyICgpKTsKICAgICAgICAgcmV0dXJuIGZhbHNl
OwogICAgICAgfQogCi0tLSBvY3RhdmUtNi4yLjAvbGliaW50ZXJwL2NvcmVm
Y24vbG9hZC1zYXZlLmNjCTIwMjEtMDItMjAgMDQ6MzY6MzQuMDAwMDAwMDAw
ICsxMTAwCisrKyBvY3RhdmUtNi4yLjAubmV3L2xpYmludGVycC9jb3JlZmNu
L2xvYWQtc2F2ZS5jYwkyMDIxLTA0LTMwIDIzOjE4OjI4Ljk3NTk0NDg3NyAr
MTAwMApAQCAtMTI4LDggKzEyOCw4IEBACiAgIHsKICAgICBjb25zdCBpbnQg
bWFnaWNfbGVuID0gMTA7CiAgICAgY2hhciBtYWdpY1ttYWdpY19sZW4rMV07
CisgICAgbWVtc2V0KG1hZ2ljLCdcMCcsbWFnaWNfbGVuKzEpOwogICAgIGlz
LnJlYWQgKG1hZ2ljLCBtYWdpY19sZW4pOwotICAgIG1hZ2ljW21hZ2ljX2xl
bl0gPSAnXDAnOwogCiAgICAgaWYgKHN0cm5jbXAgKG1hZ2ljLCAiT2N0YXZl
LTEtTCIsIG1hZ2ljX2xlbikgPT0gMCkKICAgICAgIHN3YXAgPSBtYWNoX2lu
Zm86OndvcmRzX2JpZ19lbmRpYW4gKCk7Ci0tLSBvY3RhdmUtNi4yLjAvbGli
aW50ZXJwL2NvcmVmY24vZ3JhcGhpY3MuaW4uaAkyMDIxLTAyLTIwIDA0OjM2
OjM0LjAwMDAwMDAwMCArMTEwMAorKysgb2N0YXZlLTYuMi4wLm5ldy9saWJp
bnRlcnAvY29yZWZjbi9ncmFwaGljcy5pbi5oCTIwMjEtMDQtMzAgMjM6MTg6
MjguOTc0OTQ0ODg2ICsxMDAwCkBAIC00Mjc2LDcgKzQyNzYsNyBAQAogICAg
ICAgcmFkaW9fcHJvcGVydHkgbWFya2VyICwgIntub25lfXwrfG98KnwufHh8
c3xzcXVhcmV8ZHxkaWFtb25kfF58dnw+fDx8cHxwZW50YWdyYW18aHxoZXhh
Z3JhbSIKICAgICAgIGNvbG9yX3Byb3BlcnR5IG1hcmtlcmVkZ2Vjb2xvciAs
IGNvbG9yX3Byb3BlcnR5IChyYWRpb192YWx1ZXMgKCJ7YXV0b318bm9uZSIp
LCBjb2xvcl92YWx1ZXMgKDAsIDAsIDApKQogICAgICAgY29sb3JfcHJvcGVy
dHkgbWFya2VyZmFjZWNvbG9yICwgY29sb3JfcHJvcGVydHkgKHJhZGlvX3Zh
bHVlcyAoImF1dG98e25vbmV9IiksIGNvbG9yX3ZhbHVlcyAoMCwgMCwgMCkp
Ci0gICAgICBkb3VibGVfcHJvcGVydHkgbWFya2Vyc2l6ZSAsIDYKKyAgICAg
IGRvdWJsZV9wcm9wZXJ0eSBtYXJrZXJzaXplICwgNAogICAgICAgcm93X3Zl
Y3Rvcl9wcm9wZXJ0eSB4ZGF0YSB1ICwgZGVmYXVsdF9kYXRhICgpCiAgICAg
ICBzdHJpbmdfcHJvcGVydHkgeGRhdGFzb3VyY2UgLCAiIgogICAgICAgcm93
X3ZlY3Rvcl9wcm9wZXJ0eSB5ZGF0YSB1ICwgZGVmYXVsdF9kYXRhICgpCkBA
IC00ODY1LDcgKzQ4NjUsNyBAQAogICAgICAgcmFkaW9fcHJvcGVydHkgbWFy
a2VyICwgIntub25lfXwrfG98KnwufHh8c3xzcXVhcmV8ZHxkaWFtb25kfF58
dnw+fDx8cHxwZW50YWdyYW18aHxoZXhhZ3JhbSIKICAgICAgIGNvbG9yX3By
b3BlcnR5IG1hcmtlcmVkZ2Vjb2xvciAsIGNvbG9yX3Byb3BlcnR5IChyYWRp
b192YWx1ZXMgKCJub25lfHthdXRvfXxmbGF0IiksIGNvbG9yX3ZhbHVlcyAo
MCwgMCwgMCkpCiAgICAgICBjb2xvcl9wcm9wZXJ0eSBtYXJrZXJmYWNlY29s
b3IgLCBjb2xvcl9wcm9wZXJ0eSAocmFkaW9fdmFsdWVzICgie25vbmV9fGF1
dG98ZmxhdCIpLCBjb2xvcl92YWx1ZXMgKDAsIDAsIDApKQotICAgICAgZG91
YmxlX3Byb3BlcnR5IG1hcmtlcnNpemUgLCA2CisgICAgICBkb3VibGVfcHJv
cGVydHkgbWFya2Vyc2l6ZSAsIDQKICAgICAgIGRvdWJsZV9wcm9wZXJ0eSBz
cGVjdWxhcmNvbG9ycmVmbGVjdGFuY2UgLCAxLjAKICAgICAgIGRvdWJsZV9w
cm9wZXJ0eSBzcGVjdWxhcmV4cG9uZW50ICwgMTAuMAogICAgICAgZG91Ymxl
X3Byb3BlcnR5IHNwZWN1bGFyc3RyZW5ndGggLCAwLjkKQEAgLTUxMjUsNyAr
NTEyNSw3IEBACiAgICAgICByYWRpb19wcm9wZXJ0eSBtYXJrZXIgLCAie25v
bmV9fCt8b3wqfC58eHxzfHNxdWFyZXxkfGRpYW1vbmR8Xnx2fD58PHxwfHBl
bnRhZ3JhbXxofGhleGFncmFtIgogICAgICAgY29sb3JfcHJvcGVydHkgbWFy
a2VyZWRnZWNvbG9yICwgY29sb3JfcHJvcGVydHkgKHJhZGlvX3ZhbHVlcyAo
Im5vbmV8e2F1dG99fGZsYXQiKSwgY29sb3JfdmFsdWVzICgwLCAwLCAwKSkK
ICAgICAgIGNvbG9yX3Byb3BlcnR5IG1hcmtlcmZhY2Vjb2xvciAsIGNvbG9y
X3Byb3BlcnR5IChyYWRpb192YWx1ZXMgKCJ7bm9uZX18YXV0b3xmbGF0Iiks
IGNvbG9yX3ZhbHVlcyAoMCwgMCwgMCkpCi0gICAgICBkb3VibGVfcHJvcGVy
dHkgbWFya2Vyc2l6ZSAsIDYKKyAgICAgIGRvdWJsZV9wcm9wZXJ0eSBtYXJr
ZXJzaXplICwgNAogICAgICAgcmFkaW9fcHJvcGVydHkgbWVzaHN0eWxlICwg
Intib3RofXxyb3d8Y29sdW1uIgogICAgICAgZG91YmxlX3Byb3BlcnR5IHNw
ZWN1bGFyY29sb3JyZWZsZWN0YW5jZSAsIDEKICAgICAgIGRvdWJsZV9wcm9w
ZXJ0eSBzcGVjdWxhcmV4cG9uZW50ICwgMTAKLS0tIG9jdGF2ZS02LjIuMC9z
Y3JpcHRzL3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNf
Xy5tCTIwMjEtMDItMjAgMDQ6MzY6MzQuMDAwMDAwMDAwICsxMTAwCisrKyBv
Y3RhdmUtNi4yLjAubmV3L3NjcmlwdHMvcGxvdC91dGlsL3ByaXZhdGUvX19n
bnVwbG90X2RyYXdfYXhlc19fLm0JMjAyMS0wNC0zMCAyMzoxODoyOC45NzQ5
NDQ4ODYgKzEwMDAKQEAgLTIyNzAsNyArMjI3MCw3IEBACiAgICAgaWYgKCEg
d2FybmVkX2xhdGV4KQogICAgICAgZG9fd2FybiA9ICh3YXJuaW5nICgicXVl
cnkiLCAiT2N0YXZlOnRleHRfaW50ZXJwcmV0ZXIiKSkuc3RhdGU7CiAgICAg
ICBpZiAoc3RyY21wIChkb193YXJuLCAib24iKSkKLSAgICAgICAgd2Fybmlu
ZyAoIk9jdGF2ZTp0ZXh0X2ludGVycHJldGVyIiwKKyAgICAgICAgd2Fybmlu
ZyAoIk9jdGF2ZTpsYXRleC1tYXJrdXAtbm90LXN1cHBvcnRlZC1mb3ItdGlj
ay1tYXJrcyIsCiAgICAgICAgICAgICAgICAgICJsYXRleCBtYXJrdXAgbm90
IHN1cHBvcnRlZCBmb3IgdGljayBtYXJrcyIpOwogICAgICAgICB3YXJuZWRf
bGF0ZXggPSB0cnVlOwogICAgICAgZW5kaWYKLS0tIG9jdGF2ZS02LjIuMC9z
Y3JpcHRzL21pc2NlbGxhbmVvdXMvZGVsZXRlLm0JMjAyMS0wMi0yMCAwNDoz
NjozNC4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS02LjIuMC5uZXcvc2Ny
aXB0cy9taXNjZWxsYW5lb3VzL2RlbGV0ZS5tCTIwMjEtMDQtMzAgMjM6MTg6
MjguOTc0OTQ0ODg2ICsxMDAwCkBAIC00OSw3ICs0OSw4IEBACiAgICAgZm9y
IGFyZyA9IHZhcmFyZ2luCiAgICAgICBmaWxlcyA9IGdsb2IgKGFyZ3sxfSk7
CiAgICAgICBpZiAoaXNlbXB0eSAoZmlsZXMpKQotICAgICAgICB3YXJuaW5n
ICgiZGVsZXRlOiBubyBzdWNoIGZpbGU6ICVzIiwgYXJnezF9KTsKKyAgICAg
ICAgd2FybmluZyAoIk9jdGF2ZTpkZWxldGUtbm8tc3VjaC1maWxlIiwKKwkg
ICAgICAgICAgImRlbGV0ZTogbm8gc3VjaCBmaWxlOiAlcyIsIGFyZ3sxfSk7
CiAgICAgICBlbmRpZgogICAgICAgZm9yIGkgPSAxOmxlbmd0aCAoZmlsZXMp
CiAgICAgICAgIGZpbGUgPSBmaWxlc3tpfTsKLS0tIG9jdGF2ZS02LjIuMC9j
b25maWd1cmUJMjAyMS0wMi0yMCAwNDozNjozNC4wMDAwMDAwMDAgKzExMDAK
KysrIG9jdGF2ZS02LjIuMC5uZXcvY29uZmlndXJlCTIwMjEtMDQtMzAgMjM6
MTg6MjguOTczOTQ0ODk0ICsxMDAwCkBAIC01OTAsOCArNTkwLDggQEAKICMg
SWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgogUEFDS0FHRV9OQU1FPSdHTlUg
T2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdvY3RhdmUnCi1QQUNLQUdFX1ZF
UlNJT049JzYuMi4wJwotUEFDS0FHRV9TVFJJTkc9J0dOVSBPY3RhdmUgNi4y
LjAnCitQQUNLQUdFX1ZFUlNJT049JzYuMi4wLXJvYmonCitQQUNLQUdFX1NU
UklORz0nR05VIE9jdGF2ZSA2LjIuMC1yb2JqJwogUEFDS0FHRV9CVUdSRVBP
UlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdzLmh0bWwnCiBQQUNLQUdFX1VS
TD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0d2FyZS9vY3RhdmUvJwogCg==
====
EOF
uudecode octave-$OCTAVE_VER.patch.uue > octave-$OCTAVE_VER.patch
pushd octave-$OCTAVE_VER
patch -p1 < ../octave-$OCTAVE_VER.patch
popd
# Build the benchmark versions
for BUILD in dbg shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Building" $BUILD
    #
    OCTAVE_DIR=$LOCAL_PREFIX/octave-$OCTAVE_VER ;
    OCTAVE_INSTALL_DIR=$LOCAL_PREFIX/octave-$BUILD
    OCTAVE_PACKAGE_DIR=$OCTAVE_INSTALL_DIR/share/octave/packages 
    OCTAVE_PACKAGES=$OCTAVE_INSTALL_DIR/share/octave/octave_packages
    #
    rm -Rf build-$BUILD
    #
    mkdir -p build-$BUILD
    #
    pushd build-$BUILD
    #
    source ../build-$BUILD.sh
    #
    make install
    # 
    echo "pkg prefix $OCTAVE_PACKAGE_DIR $OCTAVE_PACKAGE_DIR ; \
          pkg local_list $OCTAVE_PACKAGES ;" > .octaverc
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../io-2.6.3.tar.gz' 
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../struct-1.0.17.tar.gz' 
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../statistics-1.4.2.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../optim-1.6.1.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../control-3.2.0.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../signal-1.4.1.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "pkg list"
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "__octave_config_info__"
    #
    echo "Testing " $BUILD
    #
    cat > iir_benchmark.m << 'EOF'
% Define a filter
fc=0.10;U=2;V=2;M=20;Q=8;R=3;tol=1e-6;
x0=[ 0.0089234, ...
     2.0000000, -2.0000000,  ...
     0.5000000, -0.5000000,  ...
    -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
     0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
     0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
     1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
    -0.9698147, -0.8442244,  0.4511337,  0.4242641, ...
     1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';
% Run
nplot=4000;
w=(0:(nplot-1))'*pi/nplot;
id=tic();
for n=1:100
  [A,gradA,hessA]=iirA(w,x0,U,V,M,Q,R,tol);
  [T,gradT,hessT]=iirT(w,x0,U,V,M,Q,R,tol);
  [P,gradP]=iirP(w,x0,U,V,M,Q,R,tol);
endfor
toc(id)
EOF
    cp -f ../../src/{fixResultNaN,iirA,iirP,iirT}.m .
    #
    for k in `seq 1 10`; do \
      LD_PRELOAD=$LAPACK_DIR"/liblapack.so:"$LAPACK_DIR"/libblas.so" \
        $OCTAVE_INSTALL_DIR/bin/octave-cli iir_benchmark.m
    done | awk -v build_var=$BUILD '{elapsed=elapsed+$4;}; \
      END {printf("iir_benchmark %s elapsed=%g\n",build_var,elapsed/10);}'
    #
    popd
    #    
done

# Now do library benchmarking
source ./library-benchmark.sh

# Done
