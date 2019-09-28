% allpassP_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("allpassP_test.diary");
unlink("allpassP_test.diary.tmp");
diary allpassP_test.diary.tmp


% Define the filter
V=5;Q=10;R=3;
a0=[  0.7500000, -0.5000000,  0.2000000,  0.3000000,  0.1000000, ...
     -0.7500000,  0.5000000, -0.6000000,  0.4000000, -0.3000000, ...
      0.6700726, -0.7205564,  0.8963898,  1.1980053, -0.8963898]';

% Check empty frequency
[P,gradP]=allpassP([],a0,V,Q,R);
if !isempty(P)
  error("Expected P=[]");
endif
if !isempty(gradP)
  error("Expected gradP=[]");
endif

% Check empty coefficients
[P,gradP,diagHessP]=allpassP([0.1 0.11]*2*pi,[],0,0,1);
printf("P=[ ");printf("%6.3f ",P);printf("]';\n");
printf("gradP=[ ");printf("%6.3f ",gradP);printf("]';\n");
printf("diagHessP=[ ");printf("%6.3f ",diagHessP);printf("]';\n");

% Use freqz to check response
[B,A]=a2tf(a0,V,Q,R);
L=512;
w=(0:(L-1))*pi/L;
H=freqz(B,A,w);
BAP=unwrap(arg(H(:)));

% Use allpassP to find allpass phase
P=allpassP(w,a0,V,Q,R);

%
% Check P
%
maxAbsDelPeps=max(abs(BAP-P))/eps;
if maxAbsDelPeps > 384
  error("max(abs(BAP-P))/eps(=%d) > 384*eps",maxAbsDelPeps);
endif

% Test partial frequency vector
npart=(floor(length(w)/3)):length(w);
Ppart=allpassP(w(npart),a0,V,Q,R);
maxAbsDelPparteps=max(abs(sin(BAP(npart))-sin(Ppart)))/eps;
if maxAbsDelPparteps > 397
  error("max(abs(sin(BAP(npart))-sin(Ppart)))/eps(=%d) > 397*eps",
        maxAbsDelPparteps);
endif

%
% Test partial derivatives
%
Qon2=Q/2;
fc=0.20;
wc=2*pi*fc;

% Calculated values
[Pc,gradPc,diagHessPc]=allpassP(wc,a0,V,Q,R);
delPdelRp=gradPc(1:V);
delPdelrp=gradPc((V+1):(V+Qon2));
delPdelthetap=gradPc((V+Qon2+1):(V+Q));

% Find approximate values
Rp=a0(1:V)';
rp=a0((V+1):(V+Qon2))';
thetap=a0((V+Qon2+1):(V+Q))';
del=1e-6;

% Initialise approximate Hessian
diagHessPDc=zeros(size(diagHessPc));

% Real poles
for k=1:V
  printf("Real pole/zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(V-k))];

  % delPdelRp
  [PDc,gradPDc]=allpassP(wc,[Rp+delk rp thetap],V,Q,R);
  diagHessPDc(k)=(gradPDc(k)-gradPc(k))/del;
  printf("delPdelRp=%f, approx=%f, diff=%f\n",...
         delPdelRp(k), (PDc-Pc)/del, delPdelRp(k)-(PDc-Pc)/del);
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole/zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Qon2-k))];

  % delPdelrp
  [PDc,gradPDc]=allpassP(wc,[Rp rp+delk thetap],V,Q,R);
  diagHessPDc(V+k)=(gradPDc(V+k)-gradPc(V+k))/del;
  printf("delPdelrp=%f, approx=%f, diff=%f\n",...
         delPdelrp(k), (PDc-Pc)/del, delPdelrp(k)-(PDc-Pc)/del);

  % delPdelthetap
  [PDc,gradPDc]=allpassP(wc,[Rp rp thetap+delk],V,Q,R);
  diagHessPDc(V+Qon2+k)=(gradPDc(V+Qon2+k)-gradPc(V+Qon2+k))/del;
  printf("delPdelthetap=%f, approx=%f, diff=%f\n",...
         delPdelthetap(k), (PDc-Pc)/del, delPdelthetap(k)-(PDc-Pc)/del);
endfor

%
% Test diagonal of Hessian
%
del2PdelRp2=diagHessPc(1:V);
del2Pdelrp2=diagHessPc((V+1):(V+Qon2));
del2Pdelthetap2=diagHessPc((V+Qon2+1):(V+Q));

% Real poles
for k=1:V
  printf("Real pole/zero %d\n", k);
  % del2PdelRp2
  printf("del2PdelRp2=%f, approx=%f, diff=%f\n",...
         del2PdelRp2(k), diagHessPDc(k), del2PdelRp2(k)-diagHessPDc(k));
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole/zero %d\n", k);
  % del2Pdelrp2
  printf("del2Pdelrp2=%f, approx=%f, diff=%f\n",...
         del2Pdelrp2(k), diagHessPDc(V+k), del2Pdelrp2(k)-diagHessPDc(V+k));
  % del2Pdelthetap2
  printf("del2Pdelthetap2=%f, approx=%f, diff=%f\n",...
         del2Pdelthetap2(k), diagHessPDc(V+Qon2+k), ...
	 del2Pdelthetap2(k)-diagHessPDc(V+Qon2+k));
endfor

% Done
diary off
movefile allpassP_test.diary.tmp allpassP_test.diary;
