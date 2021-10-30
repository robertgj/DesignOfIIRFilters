#!/bin/bash

# Assume these packages are installed:
#  atlas.x86_64            3.10.3-18.fc35
#  blas.x86_64             3.10.0-3.fc35
#  lapack.x86_64           3.10.0-3.fc35
#  gsl.x86_64              2.6-5.fc35
#  gsl-devel.x86_64        2.6-5.fc35
#  openblas.x86_64         0.3.17-2.fc35
#  openblas-threads.x86_64 0.3.17-2.fc35
# eg:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
#  lapack-3.10.0.tar.gz
#  SuiteSparse-5.10.1.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.10.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-6.3.0.tar.lz
#  io-?.?.?.tar.gz
#  statistics-?.?.?.tar.gz
#  struct-?.?.?.tar.gz
#  optim-?.?.?.tar.gz
#  control-?.?.?.tar.gz
#  signal-?.?.?.tar.gz

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
export LPVER=3.10.0
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
export OCTAVE_VER=6.3.0
rm -Rf octave-$OCTAVE_VER
tar -xf octave-$OCTAVE_VER".tar.lz"
# Patch
cat > octave-$OCTAVE_VER.patch.uue << 'EOF'
begin-base64 644 octave-6.3.0.patch
RmlsZXMgb2N0YXZlLTYuMy4wLm9yaWcvbGlib2N0YXZlL3V0aWwvYWN0aW9u
LWNvbnRhaW5lci5oIGFuZCBvY3RhdmUtNi4zLjAvbGlib2N0YXZlL3V0aWwv
YWN0aW9uLWNvbnRhaW5lci5oIGRpZmZlcgotLS0gb2N0YXZlLTYuMy4wLm9y
aWcvbGlib2N0YXZlL3V0aWwvYWN0aW9uLWNvbnRhaW5lci5oCTIwMjEtMDct
MTIgMDM6MTk6MzIuMDAwMDAwMDAwICsxMDAwCisrKyBvY3RhdmUtNi4zLjAv
bGlib2N0YXZlL3V0aWwvYWN0aW9uLWNvbnRhaW5lci5oCTIwMjEtMDktMjAg
MTg6NDg6MTQuMDczMDI4MDYwICsxMDAwCkBAIC0yOSw2ICsyOSw3IEBACiAj
aW5jbHVkZSAib2N0YXZlLWNvbmZpZy5oIgogCiAjaW5jbHVkZSA8ZnVuY3Rp
b25hbD4KKyNpbmNsdWRlIDxjc3RkZGVmPgogCiAvLyBUaGlzIGNsYXNzIGFs
bG93cyByZWdpc3RlcmluZyBhY3Rpb25zIGluIGEgbGlzdCBmb3IgbGF0ZXIK
IC8vIGV4ZWN1dGlvbiwgZWl0aGVyIGV4cGxpY2l0bHkgb3Igd2hlbiB0aGUg
Y29udGFpbmVyIGdvZXMgb3V0IG9mCkZpbGVzIG9jdGF2ZS02LjMuMC5vcmln
L2xpYmludGVycC9jb3JlZmNuL2xvYWQtcGF0aC5jYyBhbmQgb2N0YXZlLTYu
My4wL2xpYmludGVycC9jb3JlZmNuL2xvYWQtcGF0aC5jYyBkaWZmZXIKLS0t
IG9jdGF2ZS02LjMuMC5vcmlnL2xpYmludGVycC9jb3JlZmNuL2xvYWQtcGF0
aC5jYwkyMDIxLTA3LTEyIDAzOjE5OjMyLjAwMDAwMDAwMCArMTAwMAorKysg
b2N0YXZlLTYuMy4wL2xpYmludGVycC9jb3JlZmNuL2xvYWQtcGF0aC5jYwky
MDIxLTA5LTIwIDE4OjQ4OjE0LjA3NDAyODA1MSArMTAwMApAQCAtNDA3LDgg
KzQwNyw4IEBACiAgICAgICAgIGJvb2wgb2sgPSBkaS51cGRhdGUgKCk7CiAK
ICAgICAgICAgaWYgKCEgb2spCi0gICAgICAgICAgd2FybmluZyAoImxvYWQt
cGF0aDogdXBkYXRlIGZhaWxlZCBmb3IgJyVzJywgcmVtb3ZpbmcgZnJvbSBw
YXRoIiwKLSAgICAgICAgICAgICAgICAgICBkaS5kaXJfbmFtZS5jX3N0ciAo
KSk7CisgICAgICAgICAgd2FybmluZ193aXRoX2lkICgiT2N0YXZlOmxvYWQt
cGF0aDp1cGRhdGUtZmFpbGVkIiwKKwkJCSAgICJsb2FkLXBhdGg6IHVwZGF0
ZSBmYWlsZWQgZm9yICclcycsIHJlbW92aW5nIGZyb20gcGF0aCIsICAgICAg
ICAgICAgICAgICAgIGRpLmRpcl9uYW1lLmNfc3RyICgpKTsKICAgICAgICAg
ZWxzZQogICAgICAgICAgIGFkZCAoZGksIHRydWUsICIiLCB0cnVlKTsKICAg
ICAgIH0KQEAgLTEyNTksNyArMTI1OSw4IEBACiAgICAgaWYgKCEgZnMpCiAg
ICAgICB7CiAgICAgICAgIHN0ZDo6c3RyaW5nIG1zZyA9IGZzLmVycm9yICgp
OwotICAgICAgICB3YXJuaW5nICgibG9hZF9wYXRoOiAlczogJXMiLCBkaXJf
bmFtZS5jX3N0ciAoKSwgbXNnLmNfc3RyICgpKTsKKyAgICAgICAgd2Fybmlu
Z193aXRoX2lkICgiT2N0YXZlOmxvYWQtcGF0aDpkaXItaW5mbzp1cGRhdGUt
ZmFpbGVkIiwKKwkJCSAibG9hZF9wYXRoOiAlczogJXMiLCBkaXJfbmFtZS5j
X3N0ciAoKSwgbXNnLmNfc3RyICgpKTsKICAgICAgICAgcmV0dXJuIGZhbHNl
OwogICAgICAgfQogCkZpbGVzIG9jdGF2ZS02LjMuMC5vcmlnL2xpYmludGVy
cC9jb3JlZmNuL2xvYWQtc2F2ZS5jYyBhbmQgb2N0YXZlLTYuMy4wL2xpYmlu
dGVycC9jb3JlZmNuL2xvYWQtc2F2ZS5jYyBkaWZmZXIKLS0tIG9jdGF2ZS02
LjMuMC5vcmlnL2xpYmludGVycC9jb3JlZmNuL2xvYWQtc2F2ZS5jYwkyMDIx
LTA3LTEyIDAzOjE5OjMyLjAwMDAwMDAwMCArMTAwMAorKysgb2N0YXZlLTYu
My4wL2xpYmludGVycC9jb3JlZmNuL2xvYWQtc2F2ZS5jYwkyMDIxLTA5LTIw
IDE4OjQ4OjE0LjA3NTAyODA0MSArMTAwMApAQCAtMTI4LDggKzEyOCw4IEBA
CiAgIHsKICAgICBjb25zdCBpbnQgbWFnaWNfbGVuID0gMTA7CiAgICAgY2hh
ciBtYWdpY1ttYWdpY19sZW4rMV07Ci0gICAgaXMucmVhZCAobWFnaWMsIG1h
Z2ljX2xlbik7CiAgICAgbWFnaWNbbWFnaWNfbGVuXSA9ICdcMCc7CisgICAg
aXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7CiAKICAgICBpZiAoc3RybmNt
cCAobWFnaWMsICJPY3RhdmUtMS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAg
ICAgc3dhcCA9IG1hY2hfaW5mbzo6d29yZHNfYmlnX2VuZGlhbiAoKTsKRmls
ZXMgb2N0YXZlLTYuMy4wLm9yaWcvc2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0
ZS9fX2dudXBsb3RfZHJhd19heGVzX18ubSBhbmQgb2N0YXZlLTYuMy4wL3Nj
cmlwdHMvcGxvdC91dGlsL3ByaXZhdGUvX19nbnVwbG90X2RyYXdfYXhlc19f
Lm0gZGlmZmVyCi0tLSBvY3RhdmUtNi4zLjAub3JpZy9zY3JpcHRzL3Bsb3Qv
dXRpbC9wcml2YXRlL19fZ251cGxvdF9kcmF3X2F4ZXNfXy5tCTIwMjEtMDct
MTIgMDM6MTk6MzIuMDAwMDAwMDAwICsxMDAwCisrKyBvY3RhdmUtNi4zLjAv
c2NyaXB0cy9wbG90L3V0aWwvcHJpdmF0ZS9fX2dudXBsb3RfZHJhd19heGVz
X18ubQkyMDIxLTA5LTIwIDE4OjQ4OjE0LjA3NzAyODAyMiArMTAwMApAQCAt
MjI3MCw3ICsyMjcwLDcgQEAKICAgICBpZiAoISB3YXJuZWRfbGF0ZXgpCiAg
ICAgICBkb193YXJuID0gKHdhcm5pbmcgKCJxdWVyeSIsICJPY3RhdmU6dGV4
dF9pbnRlcnByZXRlciIpKS5zdGF0ZTsKICAgICAgIGlmIChzdHJjbXAgKGRv
X3dhcm4sICJvbiIpKQotICAgICAgICB3YXJuaW5nICgiT2N0YXZlOnRleHRf
aW50ZXJwcmV0ZXIiLAorICAgICAgICB3YXJuaW5nICgiT2N0YXZlOmxhdGV4
LW1hcmt1cC1ub3Qtc3VwcG9ydGVkLWZvci10aWNrLW1hcmtzIiwKICAgICAg
ICAgICAgICAgICAgImxhdGV4IG1hcmt1cCBub3Qgc3VwcG9ydGVkIGZvciB0
aWNrIG1hcmtzIik7CiAgICAgICAgIHdhcm5lZF9sYXRleCA9IHRydWU7CiAg
ICAgICBlbmRpZgpGaWxlcyBvY3RhdmUtNi4zLjAub3JpZy9zY3JpcHRzL21p
c2NlbGxhbmVvdXMvZGVsZXRlLm0gYW5kIG9jdGF2ZS02LjMuMC9zY3JpcHRz
L21pc2NlbGxhbmVvdXMvZGVsZXRlLm0gZGlmZmVyCi0tLSBvY3RhdmUtNi4z
LjAub3JpZy9zY3JpcHRzL21pc2NlbGxhbmVvdXMvZGVsZXRlLm0JMjAyMS0w
Ny0xMiAwMzoxOTozMi4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS02LjMu
MC9zY3JpcHRzL21pc2NlbGxhbmVvdXMvZGVsZXRlLm0JMjAyMS0wOS0yMCAx
ODo0ODoxNC4wNzgwMjgwMTMgKzEwMDAKQEAgLTQ5LDcgKzQ5LDggQEAKICAg
ICBmb3IgYXJnID0gdmFyYXJnaW4KICAgICAgIGZpbGVzID0gZ2xvYiAoYXJn
ezF9KTsKICAgICAgIGlmIChpc2VtcHR5IChmaWxlcykpCi0gICAgICAgIHdh
cm5pbmcgKCJkZWxldGU6IG5vIHN1Y2ggZmlsZTogJXMiLCBhcmd7MX0pOwor
ICAgICAgICB3YXJuaW5nICgiT2N0YXZlOmRlbGV0ZTpuby1zdWNoLWZpbGUi
LAorCQkgImRlbGV0ZTogbm8gc3VjaCBmaWxlOiAlcyIsIGFyZ3sxfSk7CiAg
ICAgICBlbmRpZgogICAgICAgZm9yIGkgPSAxOmxlbmd0aCAoZmlsZXMpCiAg
ICAgICAgIGZpbGUgPSBmaWxlc3tpfTsKRmlsZXMgb2N0YXZlLTYuMy4wLm9y
aWcvY29uZmlndXJlIGFuZCBvY3RhdmUtNi4zLjAvY29uZmlndXJlIGRpZmZl
cgotLS0gb2N0YXZlLTYuMy4wLm9yaWcvY29uZmlndXJlCTIwMjEtMDctMTIg
MDM6MTk6MzIuMDAwMDAwMDAwICsxMDAwCisrKyBvY3RhdmUtNi4zLjAvY29u
ZmlndXJlCTIwMjEtMDktMjAgMTg6NDk6MjguNjYwMzI3NDg4ICsxMDAwCkBA
IC01OTEsNyArNTkxLDcgQEAKIFBBQ0tBR0VfTkFNRT0nR05VIE9jdGF2ZScK
IFBBQ0tBR0VfVEFSTkFNRT0nb2N0YXZlJwogUEFDS0FHRV9WRVJTSU9OPSc2
LjMuMCcKLVBBQ0tBR0VfU1RSSU5HPSdHTlUgT2N0YXZlIDYuMy4wJworUEFD
S0FHRV9TVFJJTkc9J0dOVSBPY3RhdmUgNi4zLjAtcm9iaicKIFBBQ0tBR0Vf
QlVHUkVQT1JUPSdodHRwczovL29jdGF2ZS5vcmcvYnVncy5odG1sJwogUEFD
S0FHRV9VUkw9J2h0dHBzOi8vd3d3LmdudS5vcmcvc29mdHdhcmUvb2N0YXZl
LycKIAo=
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
                                       'pkg install ../control-3.3.1.tar.gz'
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
