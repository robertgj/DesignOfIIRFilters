% allpassT_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("allpassT_test.diary");
delete("allpassT_test.diary.tmp");
diary allpassT_test.diary.tmp


% Define the filter
V=5;Q=10;R=3;
a0=[  0.7500000, -0.5000000,  0.2000000,  0.3000000,  0.1000000, ...
     -0.7500000,  0.5000000, -0.6000000,  0.4000000, -0.3000000, ...
      0.6700726, -0.7205564,  0.8963898,  1.1980053, -0.8963898]';

% Check empty frequency
[T,gradT]=allpassT([],a0,V,Q,R);
if ~isempty(T)
  error("Expected T=[]");
endif
if ~isempty(gradT)
  error("Expected gradT=[]");
endif

% Use freqz to check response
[B,A]=a2tf(a0,V,Q,R);
L=512;
[BAT,w]=delayz(B,A,L);

% Use allpassT to find allpass phase
T=allpassT(w,a0,V,Q,R);

%
% Check T
%
maxAbsDelT=max(abs(BAT-T));
tol=1793*eps;
if maxAbsDelT > tol
  error("max(abs(BAT-T))/eps(=%d) > 1793",maxAbsDelT/eps);
endif

% Check partial frequency vector
npart=floor(length(w)/3):length(w);
Tpart=allpassT(w(npart),a0,V,Q,R);
maxAbsDelTpart=max(abs(BAT(npart)-Tpart));
tol=1568*eps;
if maxAbsDelTpart > tol
  error("max(abs(BAT(npart)-Tpart))/eps(=%d) > 1568",maxAbsDelTpart/eps);
endif

%
% Test partial derivatives
%
Qon2=Q/2;
fc=0.2;
wc=2*pi*fc;

% Calculated values
[Tc,gradTc,diagHessTc]=allpassT(wc,a0,V,Q,R);
delTdelRp=gradTc(1:V);
delTdelrp=gradTc((V+1):(V+Qon2));
delTdelthetap=gradTc((V+Qon2+1):(V+Q));

% Find approximate values
Rp=a0(1:V)';
rp=a0((V+1):(V+Qon2))';
thetap=a0((V+Qon2+1):(V+Q))';
del=1e-6;

% Initialise approximate Hessian
diagHessTDc=zeros(size(diagHessTc));

% Real poles
delk=[del zeros(1,V-1)];
for k=1:V
  printf("Real pole/zero %d\n", k);

  % delTdelRp
  [TDc,gradTDc]=allpassT(wc,[Rp+delk rp thetap],V,Q,R);
  diagHessTDc(k)=(gradTDc(k)-gradTc(k))/del;
  printf("delTdelRp=%f, approx=%f, diff=%f\n",...
         delTdelRp(k), (TDc-Tc)/del, delTdelRp(k)-(TDc-Tc)/del);

  delk=circshift(delk,1);
endfor

% Conjugate poles
delk=[del zeros(1,Qon2-1)];
for k=1:Qon2
  printf("Conjugate pole/zero %d\n", k);
  
  % delTdelrp
  [TDc,gradTDc]=allpassT(wc,[Rp rp+delk thetap],V,Q,R);
  diagHessTDc(V+k)=(gradTDc(V+k)-gradTc(V+k))/del;
  printf("delTdelrp=%f, approx=%f, diff=%f\n",...
         delTdelrp(k), (TDc-Tc)/del, delTdelrp(k)-(TDc-Tc)/del);

  % delTdelthetap
  [TDc,gradTDc]=allpassT(wc,[Rp rp thetap+delk],V,Q,R);
  diagHessTDc(V+Qon2+k)=(gradTDc(V+Qon2+k)-gradTc(V+Qon2+k))/del;
  printf("delTdelthetap=%f, approx=%f, diff=%f\n",...
         delTdelthetap(k), (TDc-Tc)/del, delTdelthetap(k)-(TDc-Tc)/del);

  delk=circshift(delk,1);
endfor

%
% Test diagonal of Hessian
%
del2TdelRp2=diagHessTc(1:V);
del2Tdelrp2=diagHessTc((V+1):(V+Qon2));
del2Tdelthetap2=diagHessTc((V+Qon2+1):(V+Q));

% Real poles
for k=1:V
  printf("Real pole/zero %d\n", k);
  % del2TdelRp2
  printf("del2TdelRp2=%f, approx=%f, diff=%f\n",...
         del2TdelRp2(k), diagHessTDc(k), del2TdelRp2(k)-diagHessTDc(k));
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole/zero %d\n", k);
  % del2Tdelrp2
  printf("del2Tdelrp2=%f, approx=%f, diff=%f\n",...
         del2Tdelrp2(k), diagHessTDc(V+k), del2Tdelrp2(k)-diagHessTDc(V+k));
  % del2Tdelthetap2
  printf("del2Tdelthetap2=%f, approx=%f, diff=%f\n",...
         del2Tdelthetap2(k), diagHessTDc(V+Qon2+k), ...
	     del2Tdelthetap2(k)-diagHessTDc(V+Qon2+k));
endfor

% Done
diary off
movefile allpassT_test.diary.tmp allpassT_test.diary;
