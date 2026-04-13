#!/bin/bash

# Assume these packages are installed:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

export CPU_TYPES="x86-64 nehalem haswell skylake"
export BUILD_TYPES="dbg shared shared-lto shared-pgo shared-lto-pgo"

# Default CPU_TYPE and BUILD
export CPU_TYPE=nehalem
export BUILD=shared

# Assume these archive files are present:
export LAPACK_VERSION=3.12.1
export SUITESPARSE_VERSION=7.12.2
export ARPACK_NG_VERSION=3.9.1
export FFTW_VERSION=3.3.10
export QRUPDATE_VERSION=1.1.2
export OCTAVE_VERSION=11.1.0
export SEDUMI_VERSION=1.3.8
export YALMIP_VERSION=R20230622
for file in lapack-$LAPACK_VERSION".tar.gz" \
            SuiteSparse-$SUITESPARSE_VERSION".tar.gz" \
            arpack-ng-$ARPACK_NG_VERSION".tar.gz" \
            fftw-$FFTW_VERSION".tar.gz" \
            qrupdate-$QRUPDATE_VERSION".tar.gz" \
            octave-$OCTAVE_VERSION".tar.lz" \
            sedumi-$SEDUMI_VERSION".tar.gz" \
            YALMIP-$YALMIP_VERSION".tar.gz" ; 
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
source ./build-lapack.sh

# Build local versions of the other libraries used by octave
export LAPACK_DIR=$LOCAL_PREFIX/lapack/$CPU_TYPE/lapack-$LAPACK_VERSION
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
rm -Rf octave-$OCTAVE_VERSION
tar -xf octave-$OCTAVE_VERSION".tar.lz"
# Patch
pushd octave-$OCTAVE_VERSION
patch -p1 < ../octave-$OCTAVE_VERSION.patch
cat > octave-$OCTAVE_VERSION".patch.gz.uue" << 'EOF'
begin-base64 644 octave-11.1.0.patch.gz
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
I3EsAAA=
====
EOF
uudecode octave-$OCTAVE_VERSION".patch.gz.uue"
gunzip -f octave-$OCTAVE_VERSION".patch.gz"
# Patch
pushd octave-$OCTAVE_VERSION
patch -p1 < ../octave-$OCTAVE_VERSION.patch
popd

# Build the benchmark versions
OCTAVE_DIR=$LOCAL_PREFIX/octave-$OCTAVE_VERSION ;
for build in $BUILD_TYPES ;
do
    #
    echo "Building" $build
    #
    OCTAVE_INSTALL_DIR=$LOCAL_PREFIX/octave-$build
    OCTAVE_BIN_DIR=$OCTAVE_INSTALL_DIR/bin
    OCTAVE_SHARE_DIR=$OCTAVE_INSTALL_DIR/share/octave
    OCTAVE_PACKAGE_DIR=$OCTAVE_SHARE_DIR/packages 
    OCTAVE_PACKAGES=$OCTAVE_SHARE_DIR/octave_packages
    #
    rm -Rf build-$build
    #
    mkdir -p build-$build
    #
    pushd build-$build
    #
    source ../build-$build.sh
    #
    make install
    # 
    $OCTAVE_BIN_DIR/octave-cli --eval "__octave_config_info__"
    #
    popd
    #
done

# Benchmark the builds with the $CPU_TYPE lapack library
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

for build in $BUILD_TYPES ; do
    #
    benchmark=iir_benchmark;
    logname="$benchmark.$CPU_TYPE.$build"
    echo "Testing $logname"
    #
    OCTAVE_BIN_DIR=$LOCAL_PREFIX/octave-$build/bin
    OCTAVE="$OCTAVE_BIN_DIR/octave-cli --no-gui -q "
    for k in `seq 1 10`; do \
        LD_PRELOAD="$LAPACK_DIR/liblapack.so:$LAPACK_DIR/libblas.so" \
        $OCTAVE $benchmark.m
    done > $logname.log
    grep Elapsed $logname.log | \
    awk -v name_var=$logname '{elapsed=elapsed+$4;}; \
      END {printf("%s elapsed=%g\n", name_var, elapsed/10);}'
    #
done

# Now do library benchmarking
source ./library-benchmark.sh
