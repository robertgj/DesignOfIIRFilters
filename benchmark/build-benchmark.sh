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
#  lapack-3.9.0.tar.gz
#  SuiteSparse-5.1.2.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.8.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-6.1.0.tar.lz
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
export LPVER=3.9.0
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
export OCTAVE_VER=6.1.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-6.1.0.patch
LS0tIG9jdGF2ZS02LjEuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXBhdGgu
Y2MJMjAyMC0xMS0yNyAwNToyMDo0NC4wMDAwMDAwMDAgKzExMDAKKysrIG9j
dGF2ZS02LjEuMC5uZXcvL2xpYmludGVycC9jb3JlZmNuL2xvYWQtcGF0aC5j
YwkyMDIwLTEyLTEzIDE1OjE1OjU2LjA0OTU5MjQ5NyArMTEwMApAQCAtNDA3
LDcgKzQwNyw4IEBACiAgICAgICAgIGJvb2wgb2sgPSBkaS51cGRhdGUgKCk7
CiAKICAgICAgICAgaWYgKCEgb2spCi0gICAgICAgICAgd2FybmluZyAoImxv
YWQtcGF0aDogdXBkYXRlIGZhaWxlZCBmb3IgJyVzJywgcmVtb3ZpbmcgZnJv
bSBwYXRoIiwKKyAgICAgICAgICB3YXJuaW5nX3dpdGhfaWQgKCJPY3RhdmU6
bG9hZC1wYXRoLXVwZGF0ZS1mYWlsZWQiLAorCQkgICAgICAgICAgICAibG9h
ZC1wYXRoOiB1cGRhdGUgZmFpbGVkIGZvciAnJXMnLCByZW1vdmluZyBmcm9t
IHBhdGgiLAogICAgICAgICAgICAgICAgICAgIGRpLmRpcl9uYW1lLmNfc3Ry
ICgpKTsKICAgICAgICAgZWxzZQogICAgICAgICAgIGFkZCAoZGksIHRydWUs
ICIiLCB0cnVlKTsKQEAgLTEyNTksNyArMTI2MCw4IEBACiAgICAgaWYgKCEg
ZnMpCiAgICAgICB7CiAgICAgICAgIHN0ZDo6c3RyaW5nIG1zZyA9IGZzLmVy
cm9yICgpOwotICAgICAgICB3YXJuaW5nICgibG9hZF9wYXRoOiAlczogJXMi
LCBkaXJfbmFtZS5jX3N0ciAoKSwgbXNnLmNfc3RyICgpKTsKKyAgICAgICAg
d2FybmluZ193aXRoX2lkICgiT2N0YXZlOmxvYWQtcGF0aC1kaXItaW5mby11
cGRhdGUiLAorCQkgICAgICAgICAgImxvYWRfcGF0aDogJXM6ICVzIiwgZGly
X25hbWUuY19zdHIgKCksIG1zZy5jX3N0ciAoKSk7CiAgICAgICAgIHJldHVy
biBmYWxzZTsKICAgICAgIH0KIAotLS0gb2N0YXZlLTYuMS4wL2xpYmludGVy
cC9jb3JlZmNuL2xvYWQtc2F2ZS5jYwkyMDIwLTExLTI3IDA1OjIwOjQ0LjAw
MDAwMDAwMCArMTEwMAorKysgb2N0YXZlLTYuMS4wLm5ldy8vbGliaW50ZXJw
L2NvcmVmY24vbG9hZC1zYXZlLmNjCTIwMjAtMTItMTMgMTU6MTU6NTYuMDUw
NTkyNDg5ICsxMTAwCkBAIC0xMjgsOCArMTI4LDggQEAKICAgewogICAgIGNv
bnN0IGludCBtYWdpY19sZW4gPSAxMDsKICAgICBjaGFyIG1hZ2ljW21hZ2lj
X2xlbisxXTsKKyAgICBtZW1zZXQobWFnaWMsJ1wwJyxtYWdpY19sZW4rMSk7
CiAgICAgaXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7Ci0gICAgbWFnaWNb
bWFnaWNfbGVuXSA9ICdcMCc7CiAKICAgICBpZiAoc3RybmNtcCAobWFnaWMs
ICJPY3RhdmUtMS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAgICAgc3dhcCA9
IG1hY2hfaW5mbzo6d29yZHNfYmlnX2VuZGlhbiAoKTsKLS0tIG9jdGF2ZS02
LjEuMC9zY3JpcHRzL3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3
X2F4ZXNfXy5tCTIwMjAtMTEtMjcgMDU6MjA6NDQuMDAwMDAwMDAwICsxMTAw
CisrKyBvY3RhdmUtNi4xLjAubmV3Ly9zY3JpcHRzL3Bsb3QvdXRpbC9wcml2
YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5tCTIwMjAtMTItMTMgMTU6MTg6
MzIuNzM0MzcwMjM3ICsxMTAwCkBAIC0yMjcwLDcgKzIyNzAsNyBAQAogICAg
IGlmICghIHdhcm5lZF9sYXRleCkKICAgICAgIGRvX3dhcm4gPSAod2Fybmlu
ZyAoInF1ZXJ5IiwgIk9jdGF2ZTp0ZXh0X2ludGVycHJldGVyIikpLnN0YXRl
OwogICAgICAgaWYgKHN0cmNtcCAoZG9fd2FybiwgIm9uIikpCi0gICAgICAg
IHdhcm5pbmcgKCJPY3RhdmU6dGV4dF9pbnRlcnByZXRlciIsCisgICAgICAg
IHdhcm5pbmcgKCJPY3RhdmU6bGF0ZXgtbWFya3VwLW5vdC1zdXBwb3J0ZWQt
Zm9yLXRpY2stbWFya3MiLAogICAgICAgICAgICAgICAgICAibGF0ZXggbWFy
a3VwIG5vdCBzdXBwb3J0ZWQgZm9yIHRpY2sgbWFya3MiKTsKICAgICAgICAg
d2FybmVkX2xhdGV4ID0gdHJ1ZTsKICAgICAgIGVuZGlmCi0tLSBvY3RhdmUt
Ni4xLjAvc2NyaXB0cy9taXNjZWxsYW5lb3VzL2RlbGV0ZS5tCTIwMjAtMTEt
MjcgMDU6MjA6NDQuMDAwMDAwMDAwICsxMTAwCisrKyBvY3RhdmUtNi4xLjAu
bmV3Ly9zY3JpcHRzL21pc2NlbGxhbmVvdXMvZGVsZXRlLm0JMjAyMC0xMi0x
MyAxNToxNTo1Ni4wNTA1OTI0ODkgKzExMDAKQEAgLTQ5LDcgKzQ5LDggQEAK
ICAgICBmb3IgYXJnID0gdmFyYXJnaW4KICAgICAgIGZpbGVzID0gZ2xvYiAo
YXJnezF9KTsKICAgICAgIGlmIChpc2VtcHR5IChmaWxlcykpCi0gICAgICAg
IHdhcm5pbmcgKCJkZWxldGU6IG5vIHN1Y2ggZmlsZTogJXMiLCBhcmd7MX0p
OworICAgICAgICB3YXJuaW5nICgiT2N0YXZlOmRlbGV0ZS1uby1zdWNoLWZp
bGUiLAorCSAgICAgICAgICAiZGVsZXRlOiBubyBzdWNoIGZpbGU6ICVzIiwg
YXJnezF9KTsKICAgICAgIGVuZGlmCiAgICAgICBmb3IgaSA9IDE6bGVuZ3Ro
IChmaWxlcykKICAgICAgICAgZmlsZSA9IGZpbGVze2l9OwotLS0gb2N0YXZl
LTYuMS4wL2NvbmZpZ3VyZQkyMDIwLTExLTI3IDA1OjIwOjQ0LjAwMDAwMDAw
MCArMTEwMAorKysgb2N0YXZlLTYuMS4wLm5ldy8vY29uZmlndXJlCTIwMjAt
MTItMTMgMTU6MTc6MjguMTM5ODg2OTExICsxMTAwCkBAIC01OTAsOCArNTkw
LDggQEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgogUEFDS0FHRV9O
QU1FPSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdvY3RhdmUnCi1Q
QUNLQUdFX1ZFUlNJT049JzYuMS4wJwotUEFDS0FHRV9TVFJJTkc9J0dOVSBP
Y3RhdmUgNi4xLjAnCitQQUNLQUdFX1ZFUlNJT049JzYuMS4wLXJvYmonCitQ
QUNLQUdFX1NUUklORz0nR05VIE9jdGF2ZSA2LjEuMC1yb2JqJwogUEFDS0FH
RV9CVUdSRVBPUlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdzLmh0bWwnCiBQ
QUNLQUdFX1VSTD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0d2FyZS9vY3Rh
dmUvJwogCg==
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
                                       'pkg install ../struct-1.0.16.tar.gz' 
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../statistics-1.4.2.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../optim-1.6.0.tar.gz'
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
