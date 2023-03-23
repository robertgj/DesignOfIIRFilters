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
#  lapack-3.11.0.tar.gz
#  SuiteSparse-7.0.1.tar.gz
#  arpack-ng-3.9.0.tar.gz
#  fftw-3.3.10.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-8.1.0.tar.lz
#  io-2.6.4.tar.gz
#  statistics-1.5.4.tar.gz
#  struct-1.0.18.tar.gz
#  optim-1.6.2.tar.gz
#  control-3.5.0.tar.gz
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
export OCTAVE_VER=8.1.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-8.1.0.patch
LS0tIG9jdGF2ZS04LjEuMC5vcmlnL2NvbmZpZ3VyZQkyMDIzLTAzLTA3IDE2
OjM0OjMyLjAwMDAwMDAwMCArMTEwMAorKysgb2N0YXZlLTguMS4wL2NvbmZp
Z3VyZQkyMDIzLTAzLTE4IDE4OjU5OjU0LjU4Mzc3NDIwNyArMTEwMApAQCAt
NjIxLDggKzYyMSw4IEBACiAjIElkZW50aXR5IG9mIHRoaXMgcGFja2FnZS4K
IFBBQ0tBR0VfTkFNRT0nR05VIE9jdGF2ZScKIFBBQ0tBR0VfVEFSTkFNRT0n
b2N0YXZlJwotUEFDS0FHRV9WRVJTSU9OPSc4LjEuMCcKLVBBQ0tBR0VfU1RS
SU5HPSdHTlUgT2N0YXZlIDguMS4wJworUEFDS0FHRV9WRVJTSU9OPSc4LjEu
MC1yb2JqJworUEFDS0FHRV9TVFJJTkc9J0dOVSBPY3RhdmUgOC4xLjAtcm9i
aicKIFBBQ0tBR0VfQlVHUkVQT1JUPSdodHRwczovL29jdGF2ZS5vcmcvYnVn
cy5odG1sJwogUEFDS0FHRV9VUkw9J2h0dHBzOi8vd3d3LmdudS5vcmcvc29m
dHdhcmUvb2N0YXZlLycKIAotLS0gb2N0YXZlLTguMS4wLm9yaWcvbGliaW50
ZXJwL2NvcmVmY24vbG9hZC1zYXZlLmNjCTIwMjMtMDMtMDcgMTY6MzQ6MzIu
MDAwMDAwMDAwICsxMTAwCisrKyBvY3RhdmUtOC4xLjAvbGliaW50ZXJwL2Nv
cmVmY24vbG9hZC1zYXZlLmNjCTIwMjMtMDMtMTggMTg6NTk6NTQuNTg0Nzc0
MTk5ICsxMTAwCkBAIC0xMjgsOCArMTI4LDggQEAKIHsKICAgY29uc3QgaW50
IG1hZ2ljX2xlbiA9IDEwOwogICBjaGFyIG1hZ2ljW21hZ2ljX2xlbisxXTsK
LSAgaXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7CiAgIG1hZ2ljW21hZ2lj
X2xlbl0gPSAnXDAnOworICBpcy5yZWFkIChtYWdpYywgbWFnaWNfbGVuKTsK
IAogICBpZiAoc3RybmNtcCAobWFnaWMsICJPY3RhdmUtMS1MIiwgbWFnaWNf
bGVuKSA9PSAwKQogICAgIHN3YXAgPSBtYWNoX2luZm86OndvcmRzX2JpZ19l
bmRpYW4gKCk7Ci0tLSBvY3RhdmUtOC4xLjAub3JpZy9zY3JpcHRzL3Bsb3Qv
dXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5tCTIwMjMtMDMt
MDcgMTY6MzQ6MzIuMDAwMDAwMDAwICsxMTAwCisrKyBvY3RhdmUtOC4xLjAv
c2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0ZS9fX2dudXBsb3RfZHJhd19heGVz
X18ubQkyMDIzLTAzLTE4IDE4OjU5OjU0LjU4NTc3NDE5MiArMTEwMApAQCAt
MjI4Myw3ICsyMjgzLDcgQEAKICAgICBpZiAoISB3YXJuZWRfbGF0ZXgpCiAg
ICAgICBkb193YXJuID0gKHdhcm5pbmcgKCJxdWVyeSIsICJPY3RhdmU6dGV4
dF9pbnRlcnByZXRlciIpKS5zdGF0ZTsKICAgICAgIGlmIChzdHJjbXAgKGRv
X3dhcm4sICJvbiIpKQotICAgICAgICB3YXJuaW5nICgiT2N0YXZlOnRleHRf
aW50ZXJwcmV0ZXIiLAorICAgICAgICB3YXJuaW5nICgiT2N0YXZlOmxhdGV4
LW1hcmt1cC1ub3Qtc3VwcG9ydGVkLWZvci10aWNrLW1hcmtzIiwKICAgICAg
ICAgICAgICAgICAgImxhdGV4IG1hcmt1cCBub3Qgc3VwcG9ydGVkIGZvciB0
aWNrIG1hcmtzIik7CiAgICAgICAgIHdhcm5lZF9sYXRleCA9IHRydWU7CiAg
ICAgICBlbmRpZgo=
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
