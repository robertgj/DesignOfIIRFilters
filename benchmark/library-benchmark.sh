#!/bin/sh

BUILD=shared-lto-pgo
OCTAVE=$LOCAL_PREFIX"/octave-"$BUILD"/bin/octave-cli"

export LD_LIBRARY_PATH=$LOCAL_PREFIX"/lib:"\
$LOCAL_PREFIX"/lapack/generic/lapack-"$LAPACK_VERSION
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
LAPACK_DIR=$LOCAL_PREFIX"/lapack/generic/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.generic.log
grep MFLOPS linpack.libblas.generic.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local generic libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, intel, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/intel/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.intel.log
grep MFLOPS linpack.libblas.intel.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local intel libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, haswell, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/haswell/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.haswell.log
grep MFLOPS linpack.libblas.haswell.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local haswell libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, nehalem, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/nehalem/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
      $OCTAVE -q linpack.m
done > linpack.libblas.nehalem.log
grep MFLOPS linpack.libblas.nehalem.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack local nehalem libblas MFLOPS=%g\n",flops/10);}'

echo "local libblas, skylake, linpack.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/skylake/lapack-"$LAPACK_VERSION
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
awk '{flops=flops+$2;}; \
     END {printf("linpack libgslcblas MFLOPS=%g\n",flops/10);}'

echo "libsatlas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/atlas/libsatlas.so.3" $OCTAVE -q linpack.m
done > linpack.libsatlas.log
grep MFLOPS linpack.libsatlas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libsatlas MFLOPS=%g\n",flops/10);}'

echo "libtatlas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/atlas/libtatlas.so.3" $OCTAVE -q linpack.m
done > linpack.libtatlas.log
grep MFLOPS linpack.libtatlas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libtatlas MFLOPS=%g\n",flops/10);}'

echo "libopenblas, linpack.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblas.so.0" $OCTAVE -q linpack.m
done > linpack.libopenblas.log
grep MFLOPS linpack.libopenblas.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libopenblas MFLOPS=%g\n",flops/10);}'

echo "libopenblasp, 1 thread, linpack.m"
for k in `seq 1 10`;do 
    export OPENBLAS_NUM_THREADS=1
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q linpack.m
done > linpack.libopenblasp.1.log
grep MFLOPS linpack.libopenblasp.1.log | \
awk '{flops=flops+$2;}; \
     END {printf("linpack libopenblasp.1 MFLOPS=%g\n",flops/10);}'

echo "libopenblasp, 2 threads, linpack.m"
for k in `seq 1 10`;do 
    export OPENBLAS_NUM_THREADS=2
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q linpack.m
done > linpack.libopenblasp.2.log
grep MFLOPS linpack.libopenblasp.2.log | \
awk '{flops=flops+$2;};\
     END {printf("linpack libopenblasp.2 MFLOPS=%g\n",flops/10);}'

echo "libopenblasp, 4 threads, linpack.m"
for k in `seq 1 10`;do 
    export OPENBLAS_NUM_THREADS=4
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q linpack.m
done > linpack.libopenblasp.4.log
grep MFLOPS linpack.libopenblasp.4.log | \
awk '{flops=flops+$2;};\
     END {printf("linpack libopenblasp.4 MFLOPS=%g\n",flops/10);}'


#
# iir_benchmark.m
#
echo "local libblas, generic, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/generic/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local generic elapsed=%g\n",elapsed/10);}'

echo "local libblas, intel, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/intel/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local intel elapsed=%g\n",elapsed/10);}'

echo "local libblas, haswell, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/haswell/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local haswell elapsed=%g\n",elapsed/10);}'

echo "local libblas, nehalem, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/nehalem/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark local nehalem elapsed=%g\n",elapsed/10);}'

echo "local libblas, skylake, iir_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/skylake/lapack-"$LAPACK_VERSION
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
    LD_PRELOAD="/usr/lib64/libgslcblas.so.0" $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libgslcblas elapsed=%g\n",elapsed/10);}'

echo "libsatlas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/atlas/libsatlas.so.3" $OCTAVE -q iir_benchmark.m 
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libsatlas elapsed=%g\n",elapsed/10);}'

echo "libtatlas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/atlas/libtatlas.so.3" $OCTAVE -q iir_benchmark.m 
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libtatlas elapsed=%g\n",elapsed/10);}'

echo "libopenblas, iir_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblas.so.0" $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblas elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 1 thread, iir_benchmark.m"
export OPENBLAS_NUM_THREADS=1
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblasp.1 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 2 threads, iir_benchmark.m"
export OPENBLAS_NUM_THREADS=2
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblasp.2 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 4 threads, iir_benchmark.m"
export OPENBLAS_NUM_THREADS=4
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q iir_benchmark.m
done | awk '{elapsed=elapsed+$4;};\
  END {printf("iir_benchmark libopenblasp.4 elapsed=%g\n",elapsed/10);}'

#
# KYP benchmark
#

# Install SeDuMi
OCTAVE_LOCAL_VERSION=\
"`$OCTAVE --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m
SEDUMI_ARCHIVE="sedumi-"$SEDUMI_VERSION".tar.gz"
tar -xf $LOCAL_PREFIX/$SEDUMI_ARCHIVE
rm -f sedumi-$SEDUMI_VERSION/vec.m
rm -f sedumi-$SEDUMI_VERSION/*.mex*
rm -Rf $OCTAVE_SITE_M_DIR/SeDuMi
mv -f sedumi-$SEDUMI_VERSION $OCTAVE_SITE_M_DIR/SeDuMi
$OCTAVE $OCTAVE_SITE_M_DIR/SeDuMi/install_sedumi.m

# Install YALMIP
YALMIP_ARCHIVE=$YALMIP_VERSION".tar.gz"
tar -xf $LOCAL_PREFIX/"YALMIP-"$YALMIP_ARCHIVE
rm -Rf $OCTAVE_SITE_M_DIR/YALMIP
mv -f "YALMIP-"$YALMIP_VERSION $OCTAVE_SITE_M_DIR/YALMIP

cat > kyp_benchmark.m << 'EOF'
% Low-pass filter specification (Reduce Esq_z while satisfying the constraints)
M=25;N=2*M;fap=0.15;fas=0.2;Esq_s=1e-4;
d=20;Esq_z=1e-4;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
Phi=[-1,0;0,1];
c_p=2*cos(2*pi*fap);
Psi_z=[0,1;1,-c_p];
c_s=2*cos(2*pi*fas);
Psi_s=[0,-1;-1,c_s];

% Filter impulse response SDP variable
CD=sdpvar(1,N+1);
CD_d=CD-[C_d,0];
              
% Pass band constraint on the error |H(w)-e^(-j*w*d)|^2
P_z=sdpvar(N,N,"symmetric","real");
Q_z=sdpvar(N,N,"symmetric","real");
F_z=[[((AB')*(kron(Phi,P_z)+kron(Psi_z,Q_z))*AB) + ...
      diag([zeros(1,N),-Esq_z]),CD_d']; ...
     [CD_d,-1]];

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
F_s=[[((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + ...
      diag([zeros(1,N),-Esq_s]),CD']; ...
     [CD,-1]];

% Satisfy constraints on zero-phase pass-band error and stop-band error
Objective=[];
Constraints=[F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
Options=sdpsettings("solver","sedumi");
id=tic();
sol=optimize(Constraints,Objective,Options);
toc(id);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
EOF

echo "local libblas, generic, kyp_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/generic/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark local generic elapsed=%g\n",elapsed/10);}'

echo "local libblas, intel, kyp_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/intel/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark local intel elapsed=%g\n",elapsed/10);}'

echo "local libblas, haswell, kyp_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/haswell/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark local haswell elapsed=%g\n",elapsed/10);}'

echo "local libblas, nehalem, kyp_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/nehalem/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark local nehalem elapsed=%g\n",elapsed/10);}'

echo "local libblas, skylake, kyp_benchmark.m"
LAPACK_DIR=$LOCAL_PREFIX"/lapack/skylake/lapack-"$LAPACK_VERSION
for k in `seq 1 10`;do 
    LD_PRELOAD="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so" \
    $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark local skylake elapsed=%g\n",elapsed/10);}'

echo "system libblas, kyp_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libblas.so.3:/usr/lib64/liblapack.so.3" \
    $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark system libblas elapsed=%g\n",elapsed/10);}'

echo "libgslcblas, kyp_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libgslcblas.so.0" $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libgslcblas elapsed=%g\n",elapsed/10);}'

echo "libsatlas, kyp_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/atlas/libsatlas.so.3" $OCTAVE -q kyp_benchmark.m 
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libsatlas elapsed=%g\n",elapsed/10);}'

echo "libtatlas, kyp_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/atlas/libtatlas.so.3" $OCTAVE -q kyp_benchmark.m 
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libtatlas elapsed=%g\n",elapsed/10);}'

echo "libopenblas, kyp_benchmark.m"
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblas.so.0" $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libopenblas elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 1 thread, kyp_benchmark.m"
export OPENBLAS_NUM_THREADS=1
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libopenblasp.1 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 2 threads, kyp_benchmark.m"
export OPENBLAS_NUM_THREADS=2
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libopenblasp.2 elapsed=%g\n",elapsed/10);}'

echo "libopenblasp, 4 threads, kyp_benchmark.m"
export OPENBLAS_NUM_THREADS=4
for k in `seq 1 10`;do 
    LD_PRELOAD="/usr/lib64/libopenblasp.so.0" $OCTAVE -q kyp_benchmark.m
done | grep Elapsed | awk '{elapsed=elapsed+$4;};\
  END {printf("kyp_benchmark libopenblasp.4 elapsed=%g\n",elapsed/10);}'

