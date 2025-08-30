#!/bin/sh

OCTAVE="$LOCAL_PREFIX/octave-$BUILD/bin/octave-cli --no-gui -q "

export LD_LIBRARY_PATH="$LOCAL_PREFIX/lib:\
$LOCAL_PREFIX/lapack/$CPU_TYPE/lapack-$LAPACK_VERSION"
$OCTAVE -v | grep version
"$LOCAL_PREFIX/octave-$BUILD/bin/mkoctfile" ../src/reprand.cc

declare -A system_libs=(\
  ["system_libblas"]="/usr/lib64/libblas.so.3:/usr/lib64/liblapack.so.3" \
  ["libgslcblas"]="/usr/lib64/libgslcblas.so.0" \
  ["libsatlas"]="/usr/lib64/atlas/libsatlas.so.3" \
  ["libtatlas"]="/usr/lib64/atlas/libtatlas.so.3" \
  ["libopenblas"]="/usr/lib64/libopenblas.so.0" \
  ["libopenblasp"]="/usr/lib64/libopenblasp.so.0")

#
# Install linpack.m
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

#
# Run linpack benchmark
#

benchmark=linpack
for cpu_type in $CPU_TYPES; do
    logname="$benchmark.$cpu_type.local_libblas"
    echo "Testing $logname"
    LAPACK_DIR="$LOCAL_PREFIX/lapack/$cpu_type/lapack-$LAPACK_VERSION"
    lapacklib="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so"
    for k in `seq 1 10`;do 
        LD_PRELOAD=$lapacklib $OCTAVE $benchmark.m
    done > $logname.log
    grep MFLOPS $logname.log | \
    awk -v name_var=$logname '{flops=flops+$2;}; \
         END {printf("%s MFLOPS=%g\n", name_var, flops/10);}'
done

for key in system_libblas libgslcblas libsatlas libtatlas libopenblas; do
    logname="$benchmark.$CPU_TYPE.$key"
    echo "Testing $logname"
    for k in `seq 1 10`;do 
        LD_PRELOAD=${system_libs[$key]} $OCTAVE $benchmark.m
    done > $logname.log
    grep MFLOPS $logname.log | \
    awk -v name_var=$logname '{flops=flops+$2;}; \
         END {printf("%s MFLOPS=%g\n", name_var, flops/10);}'
done

key="libopenblasp"
for thrds in 1 2 4; do
    logname="$benchmark.$CPU_TYPE.$key.$thrds"
    echo "Testing $logname"
    for k in `seq 1 10`;do 
        export OPENBLAS_NUM_THREADS=$thrds
        LD_PRELOAD=${system_libs[$key]} $OCTAVE $benchmark.m
    done > $logname.log
    grep MFLOPS $logname.log | \
    awk -v name_var=$logname '{flops=flops+$2;}; \
         END {printf("%s MFLOPS=%g\n", name_var, flops/10);}'
done

#
# Install KYP benchmark
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
cat > sedumi-$SEDUMI_VERSION.patch.gz.uue << 'EOF'
begin-base64 644 sedumi-1.3.8.patch.gz
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
AA==
====
EOF
uudecode "sedumi-"$SEDUMI_VERSION".patch.gz.uue"
gunzip "sedumi-"$SEDUMI_VERSION".patch.gz"
pushd sedumi-$SEDUMI_VERSION
patch -p 1 < "../sedumi-"$SEDUMI_VERSION".patch"
popd
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

#
# Run iir and kyp benchmarks
#

for benchmark in iir_benchmark kyp_benchmark; do
    
    for cpu_type in $CPU_TYPES; do
        logname="$benchmark.$cpu_type.local_libblas"
        echo "Testing $logname"
        LAPACK_DIR="$LOCAL_PREFIX/lapack/$cpu_type/lapack-$LAPACK_VERSION"
        lapacklib="$LAPACK_DIR/libblas.so:$LAPACK_DIR/liblapack.so"
        for k in `seq 1 10`;do 
            LD_PRELOAD=$lapacklib $OCTAVE $benchmark.m
        done > $logname.log
        grep Elapsed $logname.log | \
        awk -v name_var=$logname '{elapsed=elapsed+$4;}; \
          END {printf("%s elapsed=%g\n", name_var, elapsed/10);}'
    done

    for key in system_libblas libgslcblas libsatlas libtatlas libopenblas; do
        logname="$benchmark.$CPU_TYPE.$key"
        echo "Testing $logname"        
        for k in `seq 1 10`;do 
            LD_PRELOAD=${system_libs[$key]} $OCTAVE $benchmark.m
        done > $logname.log
        grep Elapsed $logname.log | \
        awk -v name_var=$logname '{elapsed=elapsed+$4;}; \
          END {printf("%s elapsed=%g\n", name_var, elapsed/10);}'
    done

    key="libopenblasp"
    for thrds in 1 2 4; do
        logname="$benchmark.$CPU_TYPE.$key.$thrds"
        echo "Testing $logname"
        for k in `seq 1 10`;do 
            export OPENBLAS_NUM_THREADS=$thrds
            LD_PRELOAD=${system_libs[$key]} $OCTAVE $benchmark.m
        done > $logname.log
        grep Elapsed $logname.log | \
        awk -v name_var=$logname '{elapsed=elapsed+$4;}; \
          END {printf("%s elapsed=%g\n", name_var, elapsed/10);}'
    done 
    
done
