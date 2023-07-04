#!/bin/bash

# Assume these packages are installed:
#  atlas.x86_64            3.10.3-22.fc37
#  blas.x86_64             3.11.0-2.fc37
#  lapack.x86_64           3.11.0-2.fc37
#  gsl.x86_64              2.7.1-4.fc37
#  gsl-devel.x86_64        2.7.1-4.fc37
#  openblas.x86_64         0.3.21-3.fc37
#  openblas-threads.x86_64 0.3.21-4.fc37
# eg:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
for file in lapack-3.11.0.tar.gz \
            SuiteSparse-7.0.1.tar.gz \
            arpack-ng-3.9.0.tar.gz \
            fftw-3.3.10.tar.gz \
            qrupdate-1.1.2.tar.gz \
            octave-8.2.0.tar.lz \
            sedumi-1.3.7.tar.gz \
            YALMIP-R20230622.tar.gz ; 
do 
  cp -f /usr/local/src/octave/$file . ; 
done

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
    | grep -Ev metadata | awk '{print $1 "\t\t" $2}'

# Build local versions of the lapack and blas libraries
export LOCAL_PREFIX=`pwd`
export LPVER=3.11.0
source ./build-lapack.sh

# Build local versions of the other libraries used by octave
export LAPACK_DIR=$LOCAL_PREFIX/lapack/generic/lapack-$LPVER
export LD_LIBRARY_PATH=$LOCAL_PREFIX"/lib:"$LAPACK_DIR
source ./build-other-libs.sh

# Common octave configure options
export OCTAVE_CONFIG_OPTIONS=" \
       --disable-docs \
       --disable-java \
       --without-fltk \
       --without-qt \
       --without-sndfile \
       --without-portaudio \
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
export OCTAVE_VER=8.2.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-8.2.0.patch
LS0tIG9jdGF2ZS04LjIuMC9jb25maWd1cmUJMjAyMy0wNC0xNCAwMjo0Mzoz
NS4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS04LjIuMC5uZXcvY29uZmln
dXJlCTIwMjMtMDYtMTEgMTU6NDk6MTMuODYwNzg0MjUwICsxMDAwCkBAIC02
MjEsOCArNjIxLDggQEAKICMgSWRlbnRpdHkgb2YgdGhpcyBwYWNrYWdlLgog
UEFDS0FHRV9OQU1FPSdHTlUgT2N0YXZlJwogUEFDS0FHRV9UQVJOQU1FPSdv
Y3RhdmUnCi1QQUNLQUdFX1ZFUlNJT049JzguMi4wJwotUEFDS0FHRV9TVFJJ
Tkc9J0dOVSBPY3RhdmUgOC4yLjAnCitQQUNLQUdFX1ZFUlNJT049JzguMi4w
LXJvYmonCitQQUNLQUdFX1NUUklORz0nR05VIE9jdGF2ZSA4LjIuMC1yb2Jq
JwogUEFDS0FHRV9CVUdSRVBPUlQ9J2h0dHBzOi8vb2N0YXZlLm9yZy9idWdz
Lmh0bWwnCiBQQUNLQUdFX1VSTD0naHR0cHM6Ly93d3cuZ251Lm9yZy9zb2Z0
d2FyZS9vY3RhdmUvJwogCi0tLSBvY3RhdmUtOC4yLjAvbGliaW50ZXJwL2Nv
cmVmY24vY2hvbC5jYwkyMDIzLTA0LTE0IDAyOjQzOjM1LjAwMDAwMDAwMCAr
MTAwMAorKysgb2N0YXZlLTguMi4wLm5ldy9saWJpbnRlcnAvY29yZWZjbi9j
aG9sLmNjCTIwMjMtMDYtMTEgMTU6NTE6MjQuMTQ3NjYxODc5ICsxMDAwCkBA
IC03NzQsNyArNzc0LDcgQEAKICUhCiAlISBSMSA9IGNob2x1cGRhdGUgKFIx
LCB1YywgIi0iKTsKICUhIGFzc2VydCAobm9ybSAodHJpdSAoUjEpLVIxLCBJ
bmYpLCAwKTsKLSUhIGFzc2VydCAobm9ybSAoUjEgLSBSLCBJbmYpIDwgMWUx
KmVwcyk7CislISBhc3NlcnQgKG5vcm0gKFIxIC0gUiwgSW5mKSA8IDJlMSpl
cHMpOwogCiAlIXRlc3QKICUhIFIgPSBjaG9sIChzaW5nbGUgKEEpKTsKLS0t
IG9jdGF2ZS04LjIuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXNhdmUuY2MJ
MjAyMy0wNC0xNCAwMjo0MzozNS4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2
ZS04LjIuMC5uZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1zYXZlLmNjCTIw
MjMtMDYtMTEgMTU6NDk6MTMuODYzNzg0MjI0ICsxMDAwCkBAIC0xMjgsOCAr
MTI4LDggQEAKIHsKICAgY29uc3QgaW50IG1hZ2ljX2xlbiA9IDEwOwogICBj
aGFyIG1hZ2ljW21hZ2ljX2xlbisxXTsKLSAgaXMucmVhZCAobWFnaWMsIG1h
Z2ljX2xlbik7CiAgIG1hZ2ljW21hZ2ljX2xlbl0gPSAnXDAnOworICBpcy5y
ZWFkIChtYWdpYywgbWFnaWNfbGVuKTsKIAogICBpZiAoc3RybmNtcCAobWFn
aWMsICJPY3RhdmUtMS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAgIHN3YXAg
PSBtYWNoX2luZm86OndvcmRzX2JpZ19lbmRpYW4gKCk7Ci0tLSBvY3RhdmUt
OC4yLjAvc2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0ZS9fX2dudXBsb3RfZHJh
d19heGVzX18ubQkyMDIzLTA0LTE0IDAyOjQzOjM1LjAwMDAwMDAwMCArMTAw
MAorKysgb2N0YXZlLTguMi4wLm5ldy9zY3JpcHRzL3Bsb3QvdXRpbC9wcml2
YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5tCTIwMjMtMDYtMTEgMTU6NDk6
MTMuODYzNzg0MjI0ICsxMDAwCkBAIC0yMjgzLDcgKzIyODMsNyBAQAogICAg
IGlmICghIHdhcm5lZF9sYXRleCkKICAgICAgIGRvX3dhcm4gPSAod2Fybmlu
ZyAoInF1ZXJ5IiwgIk9jdGF2ZTp0ZXh0X2ludGVycHJldGVyIikpLnN0YXRl
OwogICAgICAgaWYgKHN0cmNtcCAoZG9fd2FybiwgIm9uIikpCi0gICAgICAg
IHdhcm5pbmcgKCJPY3RhdmU6dGV4dF9pbnRlcnByZXRlciIsCisgICAgICAg
IHdhcm5pbmcgKCJPY3RhdmU6bGF0ZXgtbWFya3VwLW5vdC1zdXBwb3J0ZWQt
Zm9yLXRpY2stbWFya3MiLAogICAgICAgICAgICAgICAgICAibGF0ZXggbWFy
a3VwIG5vdCBzdXBwb3J0ZWQgZm9yIHRpY2sgbWFya3MiKTsKICAgICAgICAg
d2FybmVkX2xhdGV4ID0gdHJ1ZTsKICAgICAgIGVuZGlmCg==
====
EOF
uudecode octave-$OCTAVE_VER.patch.uue > octave-$OCTAVE_VER.patch
pushd octave-$OCTAVE_VER
patch -p1 < ../octave-$OCTAVE_VER.patch
popd

# Build the benchmark versions
OCTAVE_DIR=$LOCAL_PREFIX/octave-$OCTAVE_VER ;
for BUILD in dbg shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Building" $BUILD
    #
    OCTAVE_INSTALL_DIR=$LOCAL_PREFIX/octave-$BUILD
    OCTAVE_BIN_DIR=$OCTAVE_INSTALL_DIR/bin
    OCTAVE_SHARE_DIR=$OCTAVE_INSTALL_DIR/share/octave
    OCTAVE_PACKAGE_DIR=$OCTAVE_SHARE_DIR/packages 
    OCTAVE_PACKAGES=$OCTAVE_SHARE_DIR/octave_packages
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
    $OCTAVE_BIN_DIR/octave-cli --eval "__octave_config_info__"
    #
    popd
    #
done

# Benchmark the builds with the generic lapack library
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
cp -f ../src/{fixResultNaN,iirA,iirP,iirT}.m .

for BUILD in dbg shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Testing " $BUILD
    #
    OCTAVE_BIN_DIR=$LOCAL_PREFIX/octave-$BUILD/bin
    for k in `seq 1 10`; do \
        LD_PRELOAD=$LAPACK_DIR"/liblapack.so:"$LAPACK_DIR"/libblas.so" \
                              $OCTAVE_BIN_DIR/octave-cli iir_benchmark.m
    done | awk -v build_var=$BUILD '{elapsed=elapsed+$4;}; \
      END {printf("iir_benchmark %s elapsed=%g\n",build_var,elapsed/10);}'
    #
done

# Now do library benchmarking
source ./library-benchmark.sh
