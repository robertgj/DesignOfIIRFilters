#!/bin/bash

# Assume these packages are installed:
#  atlas.x86_64            3.10.3-20.fc37
#  blas.x86_64             3.10.1-2.fc37
#  lapack.x86_64           3.10.1-2.fc37
#  gsl.x86_64              2.6-7.fc37
#  gsl-devel.x86_64        2.6-7.fc37
#  openblas.x86_64         0.3.21-3.fc37
#  openblas-threads.x86_64 0.3.21-3.fc37
# eg:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
#  lapack-3.10.1.tar.gz
#  SuiteSparse-6.0.1.tar.gz
#  arpack-ng-3.8.0.tar.gz
#  fftw-3.3.10.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-7.3.0.tar.lz
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
export OCTAVE_VER=7.3.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-7.3.0.patch
ZGlmZiAtciAtVSAzIG9jdGF2ZS03LjMuMC9jb25maWd1cmUgb2N0YXZlLTcu
My4wLm5ldy9jb25maWd1cmUKLS0tIG9jdGF2ZS03LjMuMC9jb25maWd1cmUJ
MjAyMi0xMS0wMyAwNToxOTo1Ni4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2
ZS03LjMuMC5uZXcvY29uZmlndXJlCTIwMjItMTEtMTcgMTI6Mjc6MjQuOTYy
Nzg5NDgyICsxMTAwCkBAIC02MjEsOCArNjIxLDggQEAKICMgSWRlbnRpdHkg
b2YgdGhpcyBwYWNrYWdlLgogUEFDS0FHRV9OQU1FPSdHTlUgT2N0YXZlJwog
UEFDS0FHRV9UQVJOQU1FPSdvY3RhdmUnCi1QQUNLQUdFX1ZFUlNJT049Jzcu
My4wJwotUEFDS0FHRV9TVFJJTkc9J0dOVSBPY3RhdmUgNy4zLjAnCitQQUNL
QUdFX1ZFUlNJT049JzcuMy4wLXJvYmonCitQQUNLQUdFX1NUUklORz0nR05V
IE9jdGF2ZSA3LjMuMC1yb2JqJwogUEFDS0FHRV9CVUdSRVBPUlQ9J2h0dHBz
Oi8vb2N0YXZlLm9yZy9idWdzLmh0bWwnCiBQQUNLQUdFX1VSTD0naHR0cHM6
Ly93d3cuZ251Lm9yZy9zb2Z0d2FyZS9vY3RhdmUvJwogCk9ubHkgaW4gb2N0
YXZlLTcuMy4wLm5ldzogY29uZmlndXJlLm9yaWcKT25seSBpbiBvY3RhdmUt
Ny4zLjAubmV3OiBjb25maWd1cmUucmVqCmRpZmYgLXIgLVUgMyBvY3RhdmUt
Ny4zLjAvbGliaW50ZXJwL2NvcmVmY24vaW52LmNjIG9jdGF2ZS03LjMuMC5u
ZXcvbGliaW50ZXJwL2NvcmVmY24vaW52LmNjCi0tLSBvY3RhdmUtNy4zLjAv
bGliaW50ZXJwL2NvcmVmY24vaW52LmNjCTIwMjItMTEtMDMgMDU6MTk6NTYu
MDAwMDAwMDAwICsxMTAwCisrKyBvY3RhdmUtNy4zLjAubmV3L2xpYmludGVy
cC9jb3JlZmNuL2ludi5jYwkyMDIyLTExLTE3IDEyOjI2OjI2Ljc1MzI3NzI4
NiArMTEwMApAQCAtNzcsNyArNzcsNyBAQAogICAgIGVycl9zcXVhcmVfbWF0
cml4X3JlcXVpcmVkICgiaW52ZXJzZSIsICJBIik7CiAKICAgb2N0YXZlX3Zh
bHVlIHJlc3VsdDsKLSAgb2N0YXZlX2lkeF90eXBlIGluZm87CisgIG9jdGF2
ZV9pZHhfdHlwZSBpbmZvID0gMDsKICAgZG91YmxlIHJjb25kID0gMC4wOwog
ICBmbG9hdCBmcmNvbmQgPSAwLjA7CiAgIGJvb2wgaXNmbG9hdCA9IGFyZy5p
c19zaW5nbGVfdHlwZSAoKTsKZGlmZiAtciAtVSAzIG9jdGF2ZS03LjMuMC9s
aWJpbnRlcnAvY29yZWZjbi9sb2FkLXNhdmUuY2Mgb2N0YXZlLTcuMy4wLm5l
dy9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXNhdmUuY2MKLS0tIG9jdGF2ZS03
LjMuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXNhdmUuY2MJMjAyMi0xMS0w
MyAwNToxOTo1Ni4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS03LjMuMC5u
ZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1zYXZlLmNjCTIwMjItMTEtMTcg
MTI6MjY6MjYuNzU0Mjc3Mjc4ICsxMTAwCkBAIC0xMjgsOCArMTI4LDggQEAK
ICAgewogICAgIGNvbnN0IGludCBtYWdpY19sZW4gPSAxMDsKICAgICBjaGFy
IG1hZ2ljW21hZ2ljX2xlbisxXTsKLSAgICBpcy5yZWFkIChtYWdpYywgbWFn
aWNfbGVuKTsKICAgICBtYWdpY1ttYWdpY19sZW5dID0gJ1wwJzsKKyAgICBp
cy5yZWFkIChtYWdpYywgbWFnaWNfbGVuKTsKIAogICAgIGlmIChzdHJuY21w
IChtYWdpYywgIk9jdGF2ZS0xLUwiLCBtYWdpY19sZW4pID09IDApCiAgICAg
ICBzd2FwID0gbWFjaF9pbmZvOjp3b3Jkc19iaWdfZW5kaWFuICgpOwpkaWZm
IC1yIC1VIDMgb2N0YXZlLTcuMy4wL3NjcmlwdHMvcGxvdC91dGlsL3ByaXZh
dGUvX19nbnVwbG90X2RyYXdfYXhlc19fLm0gb2N0YXZlLTcuMy4wLm5ldy9z
Y3JpcHRzL3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNf
Xy5tCi0tLSBvY3RhdmUtNy4zLjAvc2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0
ZS9fX2dudXBsb3RfZHJhd19heGVzX18ubQkyMDIyLTExLTAzIDA1OjE5OjU2
LjAwMDAwMDAwMCArMTEwMAorKysgb2N0YXZlLTcuMy4wLm5ldy9zY3JpcHRz
L3Bsb3QvdXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5tCTIw
MjItMTEtMTcgMTI6MjY6MjYuNzU1Mjc3MjcwICsxMTAwCkBAIC0yMjgzLDcg
KzIyODMsNyBAQAogICAgIGlmICghIHdhcm5lZF9sYXRleCkKICAgICAgIGRv
X3dhcm4gPSAod2FybmluZyAoInF1ZXJ5IiwgIk9jdGF2ZTp0ZXh0X2ludGVy
cHJldGVyIikpLnN0YXRlOwogICAgICAgaWYgKHN0cmNtcCAoZG9fd2Fybiwg
Im9uIikpCi0gICAgICAgIHdhcm5pbmcgKCJPY3RhdmU6dGV4dF9pbnRlcnBy
ZXRlciIsCisgICAgICAgIHdhcm5pbmcgKCJPY3RhdmU6bGF0ZXgtbWFya3Vw
LW5vdC1zdXBwb3J0ZWQtZm9yLXRpY2stbWFya3MiLAogICAgICAgICAgICAg
ICAgICAibGF0ZXggbWFya3VwIG5vdCBzdXBwb3J0ZWQgZm9yIHRpY2sgbWFy
a3MiKTsKICAgICAgICAgd2FybmVkX2xhdGV4ID0gdHJ1ZTsKICAgICAgIGVu
ZGlmCg==
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
