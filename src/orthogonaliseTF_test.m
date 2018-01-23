% orthogonaliseTF_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("orthogonaliseTF_test.diary");
unlink("orthogonaliseTF_test.diary.tmp");
diary orthogonaliseTF_test.diary.tmp

format short 

tol=eps*10;

% Select filter transfer function numerator and denominator
if 1
  N=9;dbap=0.1;dbas=40;fc=0.05;[n,d]=ellip(N,dbap,dbas,2*fc);
elseif 0
  N=5;dbap=0.1;dbas=40;fc=0.05;[n,d]=ellip(N,dbap,dbas,2*fc);
elseif 0
  N=17;fc=0.05;[n,d]=butter(N,2*fc);
elseif 0
  n = [ 5.9470e-04,  3.6189e-01,  4.6856e-01];
  d = [ 1.00000,     0.00000,    -0.24938 ];
elseif 0
  n = [  4.0014e-04,  3.1317e-01,  4.9952e-01,  4.1228e-01,  1.6163e-01 ];
  d = [  1.00000,     0.00000,     0.31878,     0.00000,    -0.01214 ];
elseif 0
  n = [  4.0507e-02, -3.8617e-04, -4.6661e-02,  1.5829e-05,  ...
         2.2742e-01,  4.9984e-01,  6.2472e-01,  5.4765e-01,  ...
         3.6052e-01,  1.7233e-01,  5.1583e-02, ];
  d = [  1.0000e+00,  0.0000e+00,  1.0954e+00,  0.0000e+00, ...
         3.4642e-01,  0.0000e+00,  3.7828e-03,  0.0000e+00, ...
         2.9945e-03,  0.0000e+00,  3.3072e-04 ];
elseif 0
  n = [  2.3470e-04,   4.0499e-02,  -6.4720e-05,  -3.6789e-02, ...
         1.0578e-04,   2.2015e-01,   4.9985e-01,   6.7114e-01, ...
         6.6989e-01,   5.4371e-01,   3.5845e-01,   1.7185e-01, ...
         4.8528e-02 ];
  d = [  1.0000e+00,   0.0000e+00,   1.3396e+00,   0.0000e+00, ...
         7.1620e-01,   0.0000e+00,   9.4758e-02,   0.0000e+00, ...
        -2.5217e-03,   0.0000e+00,  -9.1841e-04,   0.0000e+00, ...
         1.4174e-04 ];
else
  n = [  7.80452791299164e-03, -2.17079013947796e-03, ...
        -2.40138842523452e-02, -1.66553809418605e-02, ...
         2.11309867388184e-02,  4.34213580278076e-02, ...
         2.27791122492392e-02, -1.55667458396317e-02, ...
        -3.45467246380835e-02, -6.09251388156151e-02, ...
        -1.19736775142369e-01, -1.32611272682791e-01, ...
        -6.09890661903717e-02 ];
  d = [  1.00000000000000e+00,  0.00000000000000e+00, ...
        -1.42122864470983e+00,  0.00000000000000e+00, ...
         1.46429696038793e+00,  0.00000000000000e+00, ...
        -1.06540675540574e+00,  0.00000000000000e+00, ...
         5.55264096476082e-01,  0.00000000000000e+00, ...
        -1.98425167626462e-01,  0.00000000000000e+00, ...
         3.77813629696454e-02 ];
endif

% Sanity check
if 0
  [k,epsilon,p,c] = tf2schurOneMlattice(n,d);
  [sA,sB,sC,sD,sCap,sDap]=schurOneMlattice2Abcd(k,epsilon,p,c);
else
  [s10,s11,s20,s00,s02,s22] = tf2schurNSlattice(n,d);
  [sA,sB,sC,sD,sCap,sDap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
endif
Ct=sC;
Dt=sD;
G=[sA,sB;Ct,Dt];
F=[sA,sB;sCap,sDap];
[G0prime,Fprime]=C1D1FToG0primeFprime(Ct,Dt,F);
Tq=FprimeToFdoubleprime(Fprime);
Tprime=eye(size(F));
for q=1:length(Tq)
  Tprime=Tprime*Tq{q};
endfor
G0doubleprime=Tprime'*G0prime*Tprime;
Fdoubleprime=Tprime'*Fprime*Tprime;
[Fq,Fsign]=factorFdoubleprime(Fdoubleprime);
Ftest=Fsign;
for q=length(Fq):-1:1
  Ftest=Ftest*Fq{q}';
endfor
G0doubleprime=Tprime'*G0prime*Tprime;
% Check G0prime
printf("max(max(abs(G0doubleprime - G0prime)))=%f\n",...
       max(max(abs(G0doubleprime - G0prime))))
% Check Fdoubleprime
printf("max(max(abs(Ftest - Fdoubleprime)))=%f\n",...
       max(max(abs(Ftest - Fdoubleprime))))

% Decompose G
[G0prime,Tq,Fq,Fsign]=orthogonaliseTF(n,d)

% Count the number of non-trivial rotations in Tq
nTq=0;
for q=1:length(Tq)
  if max(max(abs(Tq{q}-eye(size(Tq{q}))))) > tol
    nTq=nTq+1;
  else
    Tq{q}=eye(size(F));
  endif
endfor
printf("Found %d non-trivial rotations (of %d) in Tq\n", ...
       nTq, length(Tq));

% Count the number of non-trivial rotations in Fq
nFq=0;
for q=1:length(Fq)
  if max(max(abs(Fq{q}-eye(size(Fq{q}))))) > tol
    nFq=nFq+1;  
  else
    Fq{q}=eye(size(F));
  endif
endfor
printf("Found %d non-trivial rotations (of %d) in Fq\n", ...
       nFq, length(Fq));

% Reconstruct the upper-2-sub-diagonal-triangular orthogonal matrix
Tprime=eye(size(G0prime));
for q=1:length(Tq)
  Tprime=Tprime*Tq{q};
endfor
Fdoubleprime=Fsign;
for q=length(Fq):-1:1
  Fdoubleprime=Fdoubleprime*Fq{q}';
endfor

% Construct the synthesised filter
Gdoubleprime=G0prime*Fdoubleprime;

% Sanity check of the orthogonal decomposition
N=length(d)-1;
A=Gdoubleprime(1:N,1:N);
B=Gdoubleprime(1:N,N+1);
C=Gdoubleprime(N+1,1:N);
D=Gdoubleprime(N+1,N+1);
[nn,dd]=Abcd2tf(A,B,C,D);
printf("max(abs(n-nn))=%f\n",max(abs(n-nn)));
printf("max(abs(d-dd))=%f\n",max(abs(d-dd)));

% Compare noise gain to optimum
[K,W]=KW(A,B,C,D);
ng=diag(K)'*diag(W)
[Topt,Kopt,Wopt]=optKW(K,W,4);
ngopt=diag(Kopt)'*diag(Wopt)

% Done
diary off
movefile orthogonaliseTF_test.diary.tmp orthogonaliseTF_test.diary;
