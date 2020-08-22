#!/bin/sh

BUILD=shared-lto-pgo
OCTAVE=$LOCAL_PREFIX"/octave-"$BUILD"/bin/octave-cli"

export LD_LIBRARY_PATH=$LOCAL_PREFIX"/lib:"\
$LOCAL_PREFIX"/lapack/generic/lapack-"$LPVER
$OCTAVE -v | grep version
$LOCAL_PREFIX"/octave-"$BUILD"/bin/mkoctfile" ../src/reprand.cc

#
# linpack.m
# 
cat > linpack.m << 'EOF'
% Linpack benchmark in Octave / Matlab
%
% MJ Rutter Nov 2015

N=2000;

fprintf('Linpack %dx%d\n',N,N);

ops=2*N*N*N/3+2*N*N;
eps=2.2e-16;

%  A=rand(N*N)-0.5;
if exist("reprand") ~= 3
  mkoctfile reprand.cc
endif
A=reprand(N,N)-0.5;

norma=max(max(max(A)),-min(min(A)));

B=sum(A,2);

t0=clock();

X=A\B;

t1=clock();

tim=etime(t1,t0);

% compute residual

R=A*X-B;

normx=max(max(X),-min(X));
resid=max(max(R),-min(R));

residn=resid/(N*norma*normx*eps);

fprintf('Norma is %f\n',norma);
fprintf('Residual is %g\n',resid);
fprintf('Normalised residual is %f\n',residn);
fprintf('Machine epsilon is %g\n',eps);
fprintf('x(1)-1 is %g\n',X(1)-1);
fprintf('x(N)-1 is %g\n',X(N)-1);
fprintf('Time is %f s\n',tim);
fprintf('MFLOPS: %.0f\n',1e-6*ops/tim);
EOF

echo "local libblas, generic, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/generic/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.generic.log
grep MFLOPS linpack.libblas.generic.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local generic libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, intel, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/intel/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.intel.log
grep MFLOPS linpack.libblas.intel.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local intel libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, haswell, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/haswell/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.haswell.log
grep MFLOPS linpack.libblas.haswell.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local haswell libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, nehalem, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/nehalem/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.nehalem.log
grep MFLOPS linpack.libblas.nehalem.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local nehalem libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, skylake, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/skylake/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.skylake.log
grep MFLOPS linpack.libblas.skylake.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local skylake libblas MFLOPS=%g\n",flops/10);}'

echo "system libblas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libblas.so.3:/usr/lib64/liblapack.so.3" \
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
    LD_PRELOAD=/usr/lib64/atlas/libsatlas.so.3 $OCTAVE -q linpack.m
done > linpack.libsatlas.log
grep MFLOPS linpack.libsatlas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libsatlas MFLOPS=%g\n",flops/10);}'

echo "libtatlas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libtatlas.so.3 $OCTAVE -q linpack.m
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
# iir_benchmark.m
#
pushd build-$BUILD

echo "local libblas, generic, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/generic/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local generic elapsed=%g\n",elapsed/10);}'

echo "local libblas, intel, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/intel/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local intel elapsed=%g\n",elapsed/10);}'

echo "local libblas, haswell, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/haswell/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local haswell elapsed=%g\n",elapsed/10);}'

echo "local libblas, nehalem, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/nehalem/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local nehalem elapsed=%g\n",elapsed/10);}'

echo "local libblas, skylake, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/skylake/lapack-"$LPVER
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local skylake elapsed=%g\n",elapsed/10);}'

echo "system libblas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libblas.so.3:/usr/lib64/liblapack.so.3" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark system libblas elapsed=%g\n",elapsed/10);}'

echo "libgslcblas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libgslcblas.so.0 $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libgslcblas elapsed=%g\n",elapsed/10);}'

echo "libsatlas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libsatlas.so.3 $OCTAVE -q iir_benchmark.m 
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libsatlas elapsed=%g\n",elapsed/10);}'

echo "libtatlas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/atlas/libtatlas.so.3 $OCTAVE -q iir_benchmark.m 
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libtatlas elapsed=%g\n",elapsed/10);}'

echo "libopenblas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblas.so.0 $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblas elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 1 thread, iir_benchmark.m"
export OPENBLAS_NUM_THREADS=1
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblasp.1 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 2 threads, iir_benchmark.m"
export OPENBLAS_NUM_THREADS=2
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblasp.2 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 4 threads, iir_benchmark.m"
export OPENBLAS_NUM_THREADS=4
for k in `seq 1 10`;do 
    LD_PRELOAD=/usr/lib64/libopenblasp.so.0 $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblasp.4 elapsed=%g\n",elapsed/10);}'

# Done
popd

