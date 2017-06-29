#!/bin/sh

BUILD=shared-lto-pgo
OCTAVE=`pwd`/octave-$BUILD/bin/octave-cli

$OCTAVE -v | grep version

`pwd`/octave-$BUILD/bin/mkoctfile ../src/reprand.cc

#
# linpack.m
# 
echo "local libblas, generic, linpack.m"
LAPACK_DIR=lapack/generic/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.generic.log
grep MFLOPS linpack.libblas.generic.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local generic libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, intel, linpack.m"
LAPACK_DIR=lapack/intel/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.intel.log
grep MFLOPS linpack.libblas.intel.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local intel libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, haswell, linpack.m"
LAPACK_DIR=lapack/haswell/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.haswell.log
grep MFLOPS linpack.libblas.haswell.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local haswell libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, nehalem, linpack.m"
LAPACK_DIR=lapack/nehalem/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.nehalem.log
grep MFLOPS linpack.libblas.nehalem.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local nehalem libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, skylake, linpack.m"
LAPACK_DIR=lapack/skylake/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.skylake.log
grep MFLOPS linpack.libblas.skylake.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local skylake libblas MFLOPS=%g\n",flops/10);}'

echo "system libblas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libblas.so:/usr/lib64/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.log
grep MFLOPS linpack.libblas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack system libblas MFLOPS=%g\n",flops/10);}'

echo "libgslcblas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libgslcblas.so.0" $OCTAVE -q linpack.m
done > linpack.libgslcblas.log
grep MFLOPS linpack.libgslcblas.log | \
awk '{flops=flops+$2;};END {printf("linpack libgslcblas MFLOPS=%g\n",flops/10);}'

echo "libsatlas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libsatlas.so $OCTAVE -q linpack.m
done > linpack.libsatlas.log
grep MFLOPS linpack.libsatlas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libsatlas MFLOPS=%g\n",flops/10);}'

echo "libtatlas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libtatlas.so $OCTAVE -q linpack.m
done > linpack.libtatlas.log
grep MFLOPS linpack.libtatlas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libtatlas MFLOPS=%g\n",flops/10);}'

echo "libopenblas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblas.so.0 $OCTAVE -q linpack.m
done > linpack.libopenblas.log
grep MFLOPS linpack.libopenblas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libopenblas MFLOPS=%g\n",flops/10);}'

echo "libopenblasp, 1 thread, linpack.m"
for k in `seq 1 10`;do 
    export OPENBLAS_NUM_THREADS=1
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 $OCTAVE -q linpack.m
done > linpack.libopenblasp.1.log
grep MFLOPS linpack.libopenblasp.1.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libopenblasp.1 MFLOPS=%g\n",flops/10);}'

echo "libopenblasp, 2 threads, linpack.m"
for k in `seq 1 10`;do 
    export OPENBLAS_NUM_THREADS=2
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 $OCTAVE -q linpack.m
done > linpack.libopenblasp.2.log
grep MFLOPS linpack.libopenblasp.2.log | \
awk '{flops=flops+$2;};\
     END {printf("linpack libopenblasp.2 MFLOPS=%g\n",flops/10);}'

echo "libopenblasp, 4 threads, linpack.m"
for k in `seq 1 10`;do 
    export OPENBLAS_NUM_THREADS=4
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 $OCTAVE -q linpack.m
done > linpack.libopenblasp.4.log
grep MFLOPS linpack.libopenblasp.4.log | \
awk '{flops=flops+$2;};\
     END {printf("linpack libopenblasp.4 MFLOPS=%g\n",flops/10);}'


#
# decimator_R2_test.m
#
cd build-$BUILD

echo "local libblas, generic, decimator_R2_test.m"
LAPACK_DIR=../lapack/generic/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.generic.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.generic.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.generic.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.generic.$k
done
grep Elapsed decimator_R2_test.diary.generic.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test local generic elapsed=%g\n",elapsed/10);}'

echo "local libblas, intel, decimator_R2_test.m"
LAPACK_DIR=../lapack/intel/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.intel.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.intel.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.intel.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.intel.$k
done
grep Elapsed decimator_R2_test.diary.intel.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test local intel elapsed=%g\n",elapsed/10);}'

echo "local libblas, haswell, decimator_R2_test.m"
LAPACK_DIR=../lapack/haswell/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.haswell.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.haswell.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.haswell.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.haswell.$k
done
grep Elapsed decimator_R2_test.diary.haswell.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test local haswell elapsed=%g\n",elapsed/10);}'

echo "local libblas, nehalem, decimator_R2_test.m"
LAPACK_DIR=../lapack/nehalem/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.nehalem.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.nehalem.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.nehalem.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.nehalem.$k
done
grep Elapsed decimator_R2_test.diary.nehalem.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test local nehalem elapsed=%g\n",elapsed/10);}'

echo "local libblas, skylake, decimator_R2_test.m"
LAPACK_DIR=../lapack/skylake/lapack-$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.skylake.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.skylake.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.skylake.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.skylake.$k
done
grep Elapsed decimator_R2_test.diary.skylake.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test local skylake elapsed=%g\n",elapsed/10);}'

echo "system libblas, decimator_R2_test.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libblas.so:/usr/lib64/liblapack.so" \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.libblas.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.libblas.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.libblas.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.libblas.$k
done
grep Elapsed decimator_R2_test.diary.libblas.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test system libblas elapsed=%g\n",elapsed/10);}'

echo "libgslcblas, decimator_R2_test.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libgslcblas.so \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.gslcblas.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.gslcblas.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.gslcblas.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.gslcblas.$k
done
grep Elapsed decimator_R2_test.diary.gslcblas.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libgslcblas elapsed=%g\n",elapsed/10);}'

echo "libsatlas, decimator_R2_test.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libsatlas.so \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.satlas.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.satlas.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.satlas.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.satlas.$k
done
grep Elapsed decimator_R2_test.diary.satlas.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libsatlas elapsed=%g\n",elapsed/10);}'

echo "libtatlas, decimator_R2_test.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libtatlas.so \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.tatlas.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.tatlas.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.tatlas.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.tatlas.$k
done
grep Elapsed decimator_R2_test.diary.tatlas.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libtatlas elapsed=%g\n",elapsed/10);}'

echo "libopenblas, decimator_R2_test.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblas.so.0 \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.openblas.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.openblas.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.openblas.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.openblas.$k
done
grep Elapsed decimator_R2_test.diary.openblas.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libopenblas elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 1 thread, decimator_R2_test.m"
export OPENBLAS_NUM_THREADS=1
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.openblasp.1.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.openblasp.1.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.openblasp.1.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.openblasp.1.$k
done
grep Elapsed decimator_R2_test.diary.openblasp.1.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libopenblasp.1 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 2 threads, decimator_R2_test.m"
export OPENBLAS_NUM_THREADS=2
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.openblasp.2.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.openblasp.2.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.openblasp.2.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.openblasp.2.$k
done
grep Elapsed decimator_R2_test.diary.openblasp.2.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libopenblasp.2 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 4 threads, decimator_R2_test.m"
export OPENBLAS_NUM_THREADS=4
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 \
              $OCTAVE -q decimator_R2_test.m >/dev/null
    mv decimator_R2_test_d1_coef.m decimator_R2_test.d1.openblasp.4.$k
    mv decimator_R2_test_D1_coef.m decimator_R2_test.D1.openblasp.4.$k
    mv decimator_R2_test_N1_coef.m decimator_R2_test.N1.openblasp.4.$k
    mv decimator_R2_test.diary decimator_R2_test.diary.openblasp.4.$k
done
grep Elapsed decimator_R2_test.diary.openblasp.4.* | \
awk '{elapsed=elapsed+$4;};\
     END {printf("decimator_R2_test libopenblasp.4 elapsed=%g\n",elapsed/10);}'

cd ..

