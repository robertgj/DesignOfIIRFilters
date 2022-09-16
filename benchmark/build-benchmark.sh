#!/bin/bash

# Assume these packages are installed:
#  atlas.x86_64            3.10.3-19.fc36
#  blas.x86_64             3.10.1-1.fc36
#  lapack.x86_64           3.10.1-1.fc36
#  gsl.x86_64              2.6-6.fc36
#  gsl-devel.x86_64        2.6-6.fc36
#  openblas.x86_64         0.3.19-3.fc36
#  openblas-threads.x86_64 0.3.19-3.fc36
# eg:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
#  lapack-3.10.1.tar.gz
#  SuiteSparse-5.13.0.tar.gz
#  arpack-ng-3.8.0.tar.gz
#  fftw-3.3.10.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-7.2.0.tar.lz
#  io-2.6.4.tar.gz
#  statistics-1.4.3.tar.gz
#  struct-1.0.18.tar.gz
#  optim-1.6.2.tar.gz
#  control-3.4.0.tar.gz
#  signal-1.4.2.tar.gz

# Disable CPU frequency scaling:
 for c in `seq 0 7` ; do
   echo "4500000">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq ;
   echo "performance">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor ;
 done ; 

# Show system information
uname -r
grep -m1 -A7 vendor_id /proc/cpuinfo
sudo cpupower -c all frequency-info
dnf list installed kernel* gcc* atlas* openblas* gsl* blas* lapack* \
    | egrep -v metadata | awk '{print $1 "\t\t" $2}'

# Build local versions of the lapack and blas libraries
export LOCAL_PREFIX=`pwd`
export LPVER=3.10.1
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
export OCTAVE_VER=7.2.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-7.2.0.patch
LS0tIG9jdGF2ZS03LjIuMC9jb25maWd1cmUJMjAyMi0wNy0yOCAyMzowODoy
Ni4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS03LjIuMC5uZXcvY29uZmln
dXJlCTIwMjItMDktMTUgMTI6NTQ6MTIuNzgyNzk5NzE1ICsxMDAwCkBAIC02
MjEsOCArNjIxLDggQEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgog
UEFDS0FHRV9OQU1FPSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdv
Y3RhdmUnCi1QQUNLQUdFX1ZFUlNJT049JzcuMi4wJwotUEFDS0FHRV9TVFJJ
Tkc9J0dOVSBPY3RhdmUgNy4yLjAnCitQQUNLQUdFX1ZFUlNJT049JzcuMi4w
LXJvYmonCitQQUNLQUdFX1NUUklORz0nR05VIE9jdGF2ZSA3LjIuMC1yb2Jq
JwogUEFDS0FHRV9CVUdSRVBPUlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdz
Lmh0bWwnCiBQQUNLQUdFX1VSTD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0
d2FyZS9vY3RhdmUvJwogCi0tLSBvY3RhdmUtNy4yLjAvbGliaW50ZXJwL2Nv
cmVmY24vbG9hZC1zYXZlLmNjCTIwMjItMDctMjggMjM6MDg6MjYuMDAwMDAw
MDAwICsxMDAwCisrKyBvY3RhdmUtNy4yLjAubmV3L2xpYmludGVycC9jb3Jl
ZmNuL2xvYWQtc2F2ZS5jYwkyMDIyLTA5LTE1IDEyOjU1OjQ1LjAxNzAwMjY5
OSArMTAwMApAQCAtMTI4LDggKzEyOCw4IEBACiAgIHsKICAgICBjb25zdCBp
bnQgbWFnaWNfbGVuID0gMTA7CiAgICAgY2hhciBtYWdpY1ttYWdpY19sZW4r
MV07Ci0gICAgaXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7CiAgICAgbWFn
aWNbbWFnaWNfbGVuXSA9ICdcMCc7CisgICAgaXMucmVhZCAobWFnaWMsIG1h
Z2ljX2xlbik7CiAKICAgICBpZiAoc3RybmNtcCAobWFnaWMsICJPY3RhdmUt
MS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAgICAgc3dhcCA9IG1hY2hfaW5m
bzo6d29yZHNfYmlnX2VuZGlhbiAoKTsKLS0tIG9jdGF2ZS03LjIuMC9zY3Jp
cHRzL3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5t
CTIwMjItMDctMjggMjM6MDg6MjYuMDAwMDAwMDAwICsxMDAwCisrKyBvY3Rh
dmUtNy4yLjAubmV3L3NjcmlwdHMvcGxvdC91dGlsL3ByaXZhdGUvX19nbnVw
bG90X2RyYXdfYXhlc19fLm0JMjAyMi0wOS0xNSAxMjo1ODo1MC42NzEzOTg0
MjkgKzEwMDAKQEAgLTIyODMsNyArMjI4Myw3IEBACiAgICAgaWYgKCEgd2Fy
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
                                       'pkg install ../io-2.6.4.tar.gz' 
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../struct-1.0.18.tar.gz' 
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../statistics-1.4.3.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../optim-1.6.2.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../control-3.4.0.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../signal-1.4.2.tar.gz'
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
