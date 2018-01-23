#!/bin/bash

# Assume these files are present:
#  lapack-3.7.1.tgz
#  SuiteSparse-4.5.6.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.7.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-4.2.1.tar.lz
#  octave-4.2.1.patch
#  struct-1.0.14.tar.gz
#  optim-1.5.2.tar.gz
#  control-3.0.0.tar.gz
#  signal-1.3.2.tar.gz
#
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
export LPVER=3.7.1
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
export OCTAVEVER=4.2.1
cat > octave-$OCTAVEVER.patch.uue << 'EOF'
begin-base64 666 octave-4.2.1.patch
LS0tIG9jdGF2ZS00LjIuMS5vbGQvY29uZmlndXJlCTIwMTctMDItMjMgMDU6
MTg6MzYuMDAwMDAwMDAwICsxMTAwCisrKyBvY3RhdmUtNC4yLjEvY29uZmln
dXJlCTIwMTctMTEtMTkgMTc6MTg6MDIuNDQzMzg1NTQzICsxMTAwCkBAIC03
MzcwMyw5ICs3MzcwMyw5IEBACiAgIGRvbmUKIGZpCiAKLUdDQ19BRERSRVNT
X1NBTklUSVpFUl9GTEFHUz0iLWZzYW5pdGl6ZT1hZGRyZXNzIC1mbm8tb21p
dC1mcmFtZS1wb2ludGVyIgotR1hYX0FERFJFU1NfU0FOSVRJWkVSX0ZMQUdT
PSItZnNhbml0aXplPWFkZHJlc3MgLWZuby1vbWl0LWZyYW1lLXBvaW50ZXIi
Ci1MRF9BRERSRVNTX1NBTklUSVpFUl9GTEFHUz0iLWZzYW5pdGl6ZT1hZGRy
ZXNzIgorR0NDX0FERFJFU1NfU0FOSVRJWkVSX0ZMQUdTPSItZnNhbml0aXpl
PWFkZHJlc3MgLWZzYW5pdGl6ZT11bmRlZmluZWQgLWZuby1zYW5pdGl6ZT12
cHRyIC1mbm8tb21pdC1mcmFtZS1wb2ludGVyIgorR1hYX0FERFJFU1NfU0FO
SVRJWkVSX0ZMQUdTPSItZnNhbml0aXplPWFkZHJlc3MgLWZzYW5pdGl6ZT11
bmRlZmluZWQgLWZuby1zYW5pdGl6ZT12cHRyIC1mbm8tb21pdC1mcmFtZS1w
b2ludGVyIgorTERfQUREUkVTU19TQU5JVElaRVJfRkxBR1M9Ii1mc2FuaXRp
emU9YWRkcmVzcyAtZnNhbml0aXplPXVuZGVmaW5lZCAtZm5vLXNhbml0aXpl
PXZwdHIiCiAKIHRyeV9hZGRyZXNzX3Nhbml0aXplcl9mbGFncz1ubwogCi0t
LSBvY3RhdmUtNC4yLjEub2xkL2xpYm9jdGF2ZS9zeXN0ZW0vZmlsZS1zdGF0
LmNjCTIwMTctMDItMjMgMDU6MDE6NTUuMDAwMDAwMDAwICsxMTAwCisrKyBv
Y3RhdmUtNC4yLjEvbGlib2N0YXZlL3N5c3RlbS9maWxlLXN0YXQuY2MJMjAx
Ny0xMS0xOSAxNzoxNzoxMi41MDc4NzY5MjUgKzExMDAKQEAgLTE3NCw3ICsx
NzQsNyBAQAogICAgICAgICAgIHVwZGF0ZV9pbnRlcm5hbCAoKTsKICAgICAg
IH0KIAotICAgIGlubGluZSBmaWxlX3N0YXQ6On5maWxlX3N0YXQgKCkgeyB9
CisgICAgZmlsZV9zdGF0Ojp+ZmlsZV9zdGF0ICgpIHsgfQogCiAgICAgdm9p
ZAogICAgIGZpbGVfc3RhdDo6dXBkYXRlX2ludGVybmFsIChib29sIGZvcmNl
KQotLS0gb2N0YXZlLTQuMi4xLm9sZC9saWJvY3RhdmUvbnVtZXJpYy9zY2h1
ci5jYwkyMDE3LTAyLTIzIDA1OjAxOjU1LjAwMDAwMDAwMCArMTEwMAorKysg
b2N0YXZlLTQuMi4xL2xpYm9jdGF2ZS9udW1lcmljL3NjaHVyLmNjCTIwMTct
MTEtMTkgMTc6MTc6MTIuNTA4ODc2OTE1ICsxMTAwCkBAIC0xMDIsNyArMTAy
LDcgQEAKICAgICAgIGlmIChvcmRfY2hhciA9PSAnQScgfHwgb3JkX2NoYXIg
PT0gJ0QnIHx8IG9yZF9jaGFyID09ICdhJyB8fCBvcmRfY2hhciA9PSAnZCcp
CiAgICAgICAgIHNvcnQgPSAnUyc7CiAKLSAgICAgIHZvbGF0aWxlIGRvdWJs
ZV9zZWxlY3RvciBzZWxlY3RvciA9IDA7CisgICAgICAgZG91YmxlX3NlbGVj
dG9yIHNlbGVjdG9yID0gMDsKICAgICAgIGlmIChvcmRfY2hhciA9PSAnQScg
fHwgb3JkX2NoYXIgPT0gJ2EnKQogICAgICAgICBzZWxlY3RvciA9IHNlbGVj
dF9hbmE8ZG91YmxlPjsKICAgICAgIGVsc2UgaWYgKG9yZF9jaGFyID09ICdE
JyB8fCBvcmRfY2hhciA9PSAnZCcpCkBAIC0xODksNyArMTg5LDcgQEAKICAg
ICAgIGlmIChvcmRfY2hhciA9PSAnQScgfHwgb3JkX2NoYXIgPT0gJ0QnIHx8
IG9yZF9jaGFyID09ICdhJyB8fCBvcmRfY2hhciA9PSAnZCcpCiAgICAgICAg
IHNvcnQgPSAnUyc7CiAKLSAgICAgIHZvbGF0aWxlIGZsb2F0X3NlbGVjdG9y
IHNlbGVjdG9yID0gMDsKKyAgICAgICBmbG9hdF9zZWxlY3RvciBzZWxlY3Rv
ciA9IDA7CiAgICAgICBpZiAob3JkX2NoYXIgPT0gJ0EnIHx8IG9yZF9jaGFy
ID09ICdhJykKICAgICAgICAgc2VsZWN0b3IgPSBzZWxlY3RfYW5hPGZsb2F0
PjsKICAgICAgIGVsc2UgaWYgKG9yZF9jaGFyID09ICdEJyB8fCBvcmRfY2hh
ciA9PSAnZCcpCkBAIC0yNzYsNyArMjc2LDcgQEAKICAgICAgIGlmIChvcmRf
Y2hhciA9PSAnQScgfHwgb3JkX2NoYXIgPT0gJ0QnIHx8IG9yZF9jaGFyID09
ICdhJyB8fCBvcmRfY2hhciA9PSAnZCcpCiAgICAgICAgIHNvcnQgPSAnUyc7
CiAKLSAgICAgIHZvbGF0aWxlIGNvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3Ig
PSAwOworICAgICAgIGNvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3IgPSAwOwog
ICAgICAgaWYgKG9yZF9jaGFyID09ICdBJyB8fCBvcmRfY2hhciA9PSAnYScp
CiAgICAgICAgIHNlbGVjdG9yID0gc2VsZWN0X2FuYTxDb21wbGV4PjsKICAg
ICAgIGVsc2UgaWYgKG9yZF9jaGFyID09ICdEJyB8fCBvcmRfY2hhciA9PSAn
ZCcpCkBAIC0zODQsNyArMzg0LDcgQEAKICAgICAgIGlmIChvcmRfY2hhciA9
PSAnQScgfHwgb3JkX2NoYXIgPT0gJ0QnIHx8IG9yZF9jaGFyID09ICdhJyB8
fCBvcmRfY2hhciA9PSAnZCcpCiAgICAgICAgIHNvcnQgPSAnUyc7CiAKLSAg
ICAgIHZvbGF0aWxlIGZsb2F0X2NvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3Ig
PSAwOworICAgICAgIGZsb2F0X2NvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3Ig
PSAwOwogICAgICAgaWYgKG9yZF9jaGFyID09ICdBJyB8fCBvcmRfY2hhciA9
PSAnYScpCiAgICAgICAgIHNlbGVjdG9yID0gc2VsZWN0X2FuYTxGbG9hdENv
bXBsZXg+OwogICAgICAgZWxzZSBpZiAob3JkX2NoYXIgPT0gJ0QnIHx8IG9y
ZF9jaGFyID09ICdkJykK
====
EOF
uudecode octave-$OCTAVEVER.patch.uue
tar -xf octave-$OCTAVEVER.tar.lz
pushd octave-$OCTAVEVER
patch -p 1 < ../octave-$OCTAVEVER.patch
popd

# Build the benchmark versions
for BUILD in dbg shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Building" $BUILD
    #
    OCTAVE_DIR=$LOCAL_PREFIX/octave-$OCTAVEVER ;
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
'texi_macros_file("/dev/null");pkg install ../struct-1.0.14.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
'texi_macros_file("/dev/null");pkg install ../optim-1.5.2.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
'texi_macros_file("/dev/null");pkg install ../control-3.0.0.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
'texi_macros_file("/dev/null");pkg install ../signal-1.3.2.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "pkg list"
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "__octave_config_info__"
    #
    echo "Testing " $BUILD
    #
    for file in iir_sqp_slb_bandpass_test.m \
      test_common.m print_polynomial.m print_pole_zero.m \
      iir_slb.m iir_sqp_mmse.m iir_slb_show_constraints.m \
      iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
      iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
      Aerror.m Terror.m armijo_kim.m cl2bp.m fixResultNaN.m \
      iirA.m iirE.m iirP.m iirT.m iir_sqp_octave.m invSVD.m \
      local_max.m local_peak.m showResponseBands.m showResponse.m \
      showResponsePassBands.m showZPplot.m sqp_bfgs.m tf2x.m updateWchol.m \
      updateWbfgs.m x2tf.m xConstraints.m ; do
        cp -f ../../src/$file . 
    done
    #
    for k in `seq 1 10`; do \
      LD_PRELOAD=$LAPACK_DIR"/liblapack.so:"$LAPACK_DIR"/libblas.so" \
        $OCTAVE_INSTALL_DIR/bin/octave-cli iir_sqp_slb_bandpass_test.m
      mv iir_sqp_slb_bandpass_test.diary \
         iir_sqp_slb_bandpass_test.diary.$BUILD.$k
    done
    grep Elapsed iir_sqp_slb_bandpass_test.diary.$BUILD.* | \
      awk -v build_var=$BUILD '{elapsed=elapsed+$4;}; \
        END {printf("iir_sqp_slb_bandpass_test %s elapsed=%g\n", \
                    build_var,elapsed/10);}'
    #
    popd
    #    
done

# Now do library benchmarking
source ./library-benchmark.sh

# Done
