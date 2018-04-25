#!/bin/bash

# Assume these packages are installed:
#  atlas.x86_64            3.10.3-1.fc27
#  blas.x86_64             3.8.0-7.fc27
#  lapack.x86_64           3.8.0-7.fc27
#  gsl.x86_64              2.4-3.fc27
#  gsl-devel.x86_64        2.4-3.fc27
#  openblas.x86_64         0.2.20-10.fc27
#  openblas-threads.x86_64 0.2.20-10.fc27
# eg:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
#  lapack-3.8.0.tar.gz
#  lapack-3.8.0.patch
#  SuiteSparse-4.5.6.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.7.tar.gz
#  qrupdate-1.1.2.tar.gz
#  octave-4.2.2.tar.lz
#  struct-1.0.14.tar.gz
#  optim-1.5.2.tar.gz
#  control-3.1.0.tar.gz
#  signal-1.3.2.tar.gz

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
export OCTAVEVER=4.2.2
tar -xf octave-$OCTAVEVER.tar.lz

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
                                       'pkg install ../struct-1.0.14.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../optim-1.5.2.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../control-3.1.0.tar.gz'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
                                       'pkg install ../signal-1.3.2.tar.gz'
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
