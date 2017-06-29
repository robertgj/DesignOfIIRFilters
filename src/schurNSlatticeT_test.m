% schurNSlatticeT_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurNSlatticeT_test.diary");
unlink("schurNSlatticeT_test.diary.tmp");
diary schurNSlatticeT_test.diary.tmp

tic;
verbose=true;

% R=2 bandpass filter
fapl=0.1;fapu=0.2;fasl=0.05;ftpl=0.09;ftpu=0.21;
n = [   0.0127469845,   0.0032780608,   0.0285568297,   0.0217618336, ... 
        0.0543730436,   0.0291811860,   0.0325479489,  -0.0069026091, ... 
       -0.0040414137,  -0.0430974012,  -0.0720651216,  -0.1000828758, ... 
       -0.0551462733,   0.0517204345,   0.1392956867,   0.1495935341, ... 
        0.0498555510,  -0.0445198094,  -0.1009805373,  -0.0681447152, ... 
       -0.0338056405 ]';
d = [   1.0000000000,   0.0000000000,   1.8632536514,   0.0000000000, ... 
        2.2039281157,   0.0000000000,   2.2677909197,   0.0000000000, ... 
        2.0451496224,   0.0000000000,   1.5409563677,   0.0000000000, ... 
        1.0011650113,   0.0000000000,   0.5514123431,   0.0000000000, ... 
        0.2533493166,   0.0000000000,   0.0849599294,   0.0000000000, ... 
        0.0186365784 ]';
nplot=1024;
ntpl=floor(nplot*ftpl/0.5);
ntpu=ceil(nplot*ftpu/0.5);
[t,wplot]=grpdelay(n,d,nplot);

% Convert filter transfer function to Schur normalised-scaled lattice form
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
Ns=length(s10);
[T,gradT,diagHessT]=schurNSlatticeT(wplot,s10,s11,s20,s00,s02,s22);

% Check the magnitude-squared response
if max(abs(t(ntpl:ntpu)-T(ntpl:ntpu))) > 496*eps
  error("max(abs(t(ntpl:ntpu)-T(ntpl:ntpu))) > 496*eps");
endif

% Check the gradients of the squared-magnitude wrt s
del=1e-6;
dels=zeros(size(s10));
dels(1)=del/2;
wtpl=wplot(ntpl);
diff_T=zeros(1,Ns*6);
for l=1:Ns
  % s10
  Ts10P=schurNSlatticeT(wtpl,s10+dels,s11,s20,s00,s02,s22);
  Ts10M=schurNSlatticeT(wtpl,s10-dels,s11,s20,s00,s02,s22);
  diff_T(1+((l-1)*6))=(Ts10P-Ts10M)/del;
  % s11
  Ts11P=schurNSlatticeT(wtpl,s10,s11+dels,s20,s00,s02,s22);
  Ts11M=schurNSlatticeT(wtpl,s10,s11-dels,s20,s00,s02,s22);
  diff_T(2+((l-1)*6))=(Ts11P-Ts11M)/del;
  % s20
  Ts20P=schurNSlatticeT(wtpl,s10,s11,s20+dels,s00,s02,s22);
  Ts20M=schurNSlatticeT(wtpl,s10,s11,s20-dels,s00,s02,s22);
  diff_T(3+((l-1)*6))=(Ts20P-Ts20M)/del;
  % s00
  Ts00P=schurNSlatticeT(wtpl,s10,s11,s20,s00+dels,s02,s22);
  Ts00M=schurNSlatticeT(wtpl,s10,s11,s20,s00-dels,s02,s22);
  diff_T(4+((l-1)*6))=(Ts00P-Ts00M)/del;
  % s02
  Ts02P=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02+dels,s22);
  Ts02M=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02-dels,s22);
  diff_T(5+((l-1)*6))=(Ts02P-Ts02M)/del;
  % s22
  Ts22P=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02,s22+dels);
  Ts22M=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02,s22-dels);
  diff_T(6+((l-1)*6))=(Ts22P-Ts22M)/del;
  % Shift dels
  dels=shift(dels,1);
endfor
if max(abs(diff_T-gradT(ntpl,:))) > del/26.98
  error("max(abs(diff_T-gradT(ntpl,:))) > del/26.98");
endif

% Check the diagonal of the Hessian of the squared-magnitude wrt s
del=1e-6;
dels=zeros(size(s10));
dels(1)=del/2;
wtpl=wplot(ntpl);
diff_gradT=zeros(1,Ns*6);
for l=1:Ns
  % s10
  [Ts10P,gradTs10P]=schurNSlatticeT(wtpl,s10+dels,s11,s20,s00,s02,s22);
  [Ts10M,gradTs10M]=schurNSlatticeT(wtpl,s10-dels,s11,s20,s00,s02,s22);
  lindex=(1+((l-1)*6));
  diff_gradT(lindex)=(gradTs10P(lindex)-gradTs10M(lindex))/del;
  % s11
  [Ts11P,gradTs11P]=schurNSlatticeT(wtpl,s10,s11+dels,s20,s00,s02,s22);
  [Ts11M,gradTs11M]=schurNSlatticeT(wtpl,s10,s11-dels,s20,s00,s02,s22);
  lindex=(2+((l-1)*6));
  diff_gradT(lindex)=(gradTs11P(lindex)-gradTs11M(lindex))/del;
  % s20
  [Ts20P,gradTs20P]=schurNSlatticeT(wtpl,s10,s11,s20+dels,s00,s02,s22);
  [Ts20M,gradTs20M]=schurNSlatticeT(wtpl,s10,s11,s20-dels,s00,s02,s22);
  lindex=(3+((l-1)*6));
  diff_gradT(lindex)=(gradTs20P(lindex)-gradTs20M(lindex))/del;
  % s00
  [Ts00P,gradTs00P]=schurNSlatticeT(wtpl,s10,s11,s20,s00+dels,s02,s22);
  [Ts00M,gradTs00M]=schurNSlatticeT(wtpl,s10,s11,s20,s00-dels,s02,s22);
  lindex=(4+((l-1)*6));
  diff_gradT(lindex)=(gradTs00P(lindex)-gradTs00M(lindex))/del;
  % s02
  [Ts02P,gradTs02P]=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02+dels,s22);
  [Ts02M,gradTs02M]=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02-dels,s22);
  lindex=(5+((l-1)*6));
  diff_gradT(lindex)=(gradTs02P(lindex)-gradTs02M(lindex))/del;
  % s22
  [Ts22P,gradTs22P]=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02,s22+dels);
  [Ts22M,gradTs22M]=schurNSlatticeT(wtpl,s10,s11,s20,s00,s02,s22-dels);
  lindex=(6+((l-1)*6));
  diff_gradT(lindex)=(gradTs22P(lindex)-gradTs22M(lindex))/del;
  % Shift dels
  dels=shift(dels,1);
endfor
if max(abs(diff_gradT-diagHessT(ntpl,:))) > del/18.6
  error("max(abs(diff_gradT-diagHessT(ntpl,:))) > del/18.6");
endif

% Done
toc;
diary off
movefile schurNSlatticeT_test.diary.tmp schurNSlatticeT_test.diary;
