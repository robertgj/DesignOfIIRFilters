#!/bin/bash

# Assumes lapack-$LPVER.tgz and $OCTAVE_DIR is the octave source directory

# Disable CPU frequency scaling:
# for c in `seq 0 7` ; do
#    echo "4500000" > /sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq
#    echo "performance" > /sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor
# done

# Show system information
uname -r
grep -m1 -A7 vendor_id /proc/cpuinfo
sudo cpupower -c all frequency-info
dnf list installed kernel* atlas* openblas* gsl* blas* lapack* \
    | egrep -v metadata | awk '{print $1 "\t\t" $2}'

# Build local versions of the lapack and blas libraries
source ./build-lapack.sh
export LAPACK_DIR=`pwd`/lapack/generic/lapack-$LPVER
export LAPACK_LTO_DIR=`pwd`/lapack/generic-lto/lapack-$LPVER

# Build the bench mark versions
for BUILD in dbg static static-lto static-pgo static-lto-pgo \
                 shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Building" $BUILD
    #
    OCTAVE_DIR=/usr/local/src/octave/octave-4.2.1
    OCTAVE_INSTALL_DIR=`pwd`/octave-$BUILD
    OCTAVE_PACKAGE_DIR=$OCTAVE_INSTALL_DIR/share/octave/packages 
    OCTAVE_PACKAGES=$OCTAVE_INSTALL_DIR/share/octave/octave_packages 
    mkdir -p build-$BUILD
    #
    cd build-$BUILD
    #
    rm -Rf *
    #
    source ../build-$BUILD.sh
    #
    make install
    # 
    echo "pkg prefix $OCTAVE_PACKAGE_DIR $OCTAVE_PACKAGE_DIR ; \
          pkg local_list $OCTAVE_PACKAGES ;" > .octaverc
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
         "pkg install -forge struct optim control signal"
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "pkg list"
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "__octave_config_info__"
    #
    echo "Testing " $BUILD
    #
    for file in decimator_R2_test.m test_common.m print_polynomial.m \
      print_pole_zero.m Aerror.m Terror.m armijo_kim.m fixResultNaN.m \
      iirA.m iirE.m iirP.m iirT.m invSVD.m local_max.m iir_sqp_mmse.m \
      iir_slb.m iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
      iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
      iir_slb_update_constraints.m showResponseBands.m showResponse.m \
      showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m \
      updateWbfgs.m xConstraints.m x2tf.m xInitHd.m ; do cp ../../src/$file . ;
    done

    for k in `seq 1 10`; do \
      LD_PRELOAD=$LAPACK_DIR"/liblapack.so:"$LAPACK_DIR"/libblas.so" \
        $OCTAVE_INSTALL_DIR/bin/octave-cli decimator_R2_test.m
      mv decimator_R2_test.diary decimator_R2_test.diary.$BUILD.$k
    done
    grep Elapsed decimator_R2_test.diary.$BUILD.* | \
      awk -v build_var=$BUILD '{elapsed=elapsed+$4;}; \
      END {printf("decimator_R2_test %s elapsed=%g\n",build_var,elapsed/10);}'
    #
    cd ..
    #    
done

# Now do library benchmarking
source ./library-benchmark.sh

# Done
