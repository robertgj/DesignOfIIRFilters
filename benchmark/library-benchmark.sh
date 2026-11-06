#!/bin/sh

if test -z "$CPU_TYPES" ;    then echo CPU_TYPES not found;      exit -1; fi
if test -z "$BUILD_TYPES" ;  then echo BUILD_TYPES not found;    exit -1; fi
if test -z $CPU_TYPE ;       then echo CPU_TYPE not found;       exit -1; fi
if test -z $BUILD ;          then echo BUILD not found;          exit -1; fi
if test -z $LOCAL_PREFIX ;   then echo LOCAL_PREFIX not found;   exit -1; fi
if test -z $OCTAVE_VERSION ; then echo OCTAVE_VERSION not found; exit -1; fi
if test -z $SEDUMI_VERSION ; then echo SEDUMI_VERSION not found; exit -1; fi
if test -z $YALMIP_VERSION ; then echo YALMIP_VERSION not found; exit -1; fi

OCTAVE_INSTALL_DIR=$LOCAL_PREFIX/octave-$BUILD
OCTAVE_BIN_DIR=$OCTAVE_INSTALL_DIR/bin
OCTAVE_SHARE_DIR=$OCTAVE_INSTALL_DIR/share/octave
OCTAVE_PACKAGE_DIR=$OCTAVE_SHARE_DIR/packages 
OCTAVE_PACKAGES=$OCTAVE_SHARE_DIR/octave_packages
OCTAVE="$OCTAVE_BIN_DIR/octave-cli --no-gui -q "

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
====
EOF
uudecode "sedumi-"$SEDUMI_VERSION".patch.gz.uue"
gunzip -f "sedumi-"$SEDUMI_VERSION".patch.gz"
pushd sedumi-$SEDUMI_VERSION
patch -p 1 < "../sedumi-"$SEDUMI_VERSION".patch"
popd
mv -f sedumi-$SEDUMI_VERSION $OCTAVE_SITE_M_DIR/SeDuMi
$OCTAVE $OCTAVE_SITE_M_DIR/SeDuMi/install_sedumi.m

# Install YALMIP
YALMIP_ARCHIVE=$YALMIP_VERSION".tar.gz"
tar -xf $LOCAL_PREFIX/"YALMIP-"$YALMIP_ARCHIVE
# Patch
cat > YALMIP-$YALMIP_VERSION.patch.gz.uue << 'EOF'
begin-base64 644 YALMIP-R20250626_fix2.patch.gz
H4sICIWA42kAA1lBTE1JUC1SMjAyNTA2MjZfZml4Mi5wYXRjaACtVN9vmzAQ
fvdfcYpUkQxMgRDyS9XSvW1qtWrby54qB46CRHBmO03y3/cMtGtXmvWhlsD2
+fN3x93Hcc7h9+XV9dcb/iMKokmQRMltXh6iczwYJTRNW6mMvwF7yoOERwlE
0SKaLeLADx4HuCG9meu6/Wx+jfs+xoQHMQ9nlnFCjGM/nCfBbJyEYce4WgEP
45k3p30zrVYMzuDTuwcDi/9ZVtURKBLIpQJTIChMsTYgsqw0paxB5mSqUGgE
I0HL6h4V1GKDjJc53awzbdTQqcp6q+Sd41Vyj2rY4nwj7kYj5hKQQBZ7Ggh2
/LXABTzBl4xjpfG5yz87kb3ts0M/+T2J7nH8hF8ywDqjdPH/SaLUG9ys0xbz
kcroIX4ukOliPPbnYTKLo2j6QiBeGNPWSxp15Ls6bUpqyVDpixe0Q+GtR4wz
fgadnWbIhTYerHcGMokaamkAD6U2UJIyUiPu0V4oKKOUOg+MOvJUmLSwd8ly
BE3ZtuDvDdiz6HYJO41qAd92RKZwW4kUG/3tC1khpDJDKFA19PvSFDDooqba
tPFRDW3IywHj5JZxW8J/MWkLYW1Q/ZhHHhIYldk9AXAJ8JhE+/tA+7yti1ZR
+jxD0iB2uw8RxgnmHmVMw3gymz9XxjS2nYPe00YauNmaY6d/+kBURlDNKAPB
8uXhXSXXouoOGL++/HV1+eW2woP1b7V1Ad1q6PCubzg2t33IV7ZhuJiMlnB2
o3Y1wlZqXa5JDIU09OGf+0noByf5DLvpFcJzhOM5fuiMPGdtV5ENx+1jGgyW
bVN8bwOl9ik3SBGIOhMq6xqIbvpkudlWZX5shMweAK05HJZNBgAA
====
EOF
uudecode YALMIP-$YALMIP_VERSION.patch.gz.uue
gunzip YALMIP-$YALMIP_VERSION.patch.gz
pushd YALMIP-$YALMIP_VERSION
patch -p 1 < ../YALMIP-$YALMIP_VERSION".patch"
popd
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
