#!/bin/bash

# Assume these packages are installed:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
export LAPACK_VERSION=3.12.1
export SUITESPARSE_VERSION=7.10.2
export ARPACK_NG_VERSION=3.9.1
export FFTW_VERSION=3.3.10
export QRUPDATE_VERSION=1.1.2
export OCTAVE_VERSION=10.1.0
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
export LAPACK_DIR=$LOCAL_PREFIX/lapack/generic/lapack-$LAPACK_VERSION
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
cat > octave-$OCTAVE_VERSION".patch" << 'EOF'
--- octave-10.1.0/libinterp/corefcn/load-save.cc        2025-03-26 07:40:27.0000
00000 +1100
+++ octave-10.1.0.new/libinterp/corefcn/load-save.cc    2025-04-20 18:21:42.4564
06442 +1000
@@ -129,8 +129,8 @@
 {
   const int magic_len = 10;
   char magic[magic_len+1];
-  is.read (magic, magic_len);
   magic[magic_len] = '\0';
+  is.read (magic, magic_len);
 
   if (strncmp (magic, "Octave-1-L", magic_len) == 0)
     swap = mach_info::words_big_endian ();
EOF
pushd octave-$OCTAVE_VERSION
patch -p1 < ../octave-$OCTAVE_VERSION.patch
popd

# Build the benchmark versions
OCTAVE_DIR=$LOCAL_PREFIX/octave-$OCTAVE_VERSION ;
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
