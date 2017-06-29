% schurOneMAPlatticeP_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMAPlatticeP_test.diary");
unlink("schurOneMAPlatticeP_test.diary.tmp");
diary schurOneMAPlatticeP_test.diary.tmp

tic;
verbose=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
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
[h,wplot]=freqz(flipud(d),d,nplot);
pp=unwrap(atan2(imag(h),real(h)));

% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,~]=tf2schurOneMlattice(n,d);
Nk=length(k);
[P,gradP,diagHessP]=schurOneMAPlatticeP(wplot,k,epsilon,p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check the phase response
if max(abs(pp-P)) > 64*eps
  error("max(abs(pp-P)) > 64*eps");
endif

% Check the gradients of the phase response wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_Pk=zeros(size(k));
for l=1:Nk
  PkPdel2=schurOneMAPlatticeP(wtpl,k+delk,epsilon,p);
  PkMdel2=schurOneMAPlatticeP(wtpl,k-delk,epsilon,p);
  delk=shift(delk,1);
  diff_Pk(l)=(PkPdel2-PkMdel2)/del;
endfor
if max(abs(diff_Pk-gradP(ntpl,:))) > del/2325
  error("max(abs(diff_Pk-gradP(ntpl,:))) > del/2325");
endif

% Check the diagonal of the Hessian of the phase response wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_dPdk=zeros(size(k));
for l=1:Nk
  [PkPdel2,gradPkPdel2]=schurOneMAPlatticeP(wtpl,k+delk,epsilon,p);
  [PkMdel2,gradPkMdel2]=schurOneMAPlatticeP(wtpl,k-delk,epsilon,p);
  delk=shift(delk,1);
  diff_dPdk(l)=(gradPkPdel2(1,l)-gradPkMdel2(1,l))/del;
endfor
if max(abs(diff_dPdk-diagHessP(ntpl,:))) > del/339.2
  error("max(abs(diff_dPdk-diagHessP(ntpl,:))) > del/339.2");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with R=2
R=2;
dp=d(1:2:end);
[kR,epsilonR,pR,~]=tf2schurOneMlattice(flipud(dp),dp);
[PR,gradPR,diagHessPR]=schurOneMAPlatticeP(wplot,kR,epsilonR,pR,R);
if max(abs(P-PR))/eps > 32
  error("max(abs(P-PR)) > 32*eps");
endif
if max(max(abs(gradP(ntpl:ntpu,2:2:end)-gradPR(ntpl:ntpu,:))))/eps > 40
  error("max(max(abs(gradP(ntpl:ntpu,2:2:end)-gradPR(ntpl:ntpu,:)))) > 40*eps");
endif
if max(max(abs(diagHessP(ntpl:ntpu,2:2:end)-diagHessPR(ntpl:ntpu,:))))/eps>192
  error("max(max(abs(diagHessP(ntpl:ntpu,2:2:end)-diagHessPR(ntpl:ntpu,:))))\
>192*eps");
endif

% Check the phase response
if max(abs(pp-PR)) > 64*eps
  error("max(abs(pp-PR)) > 64*eps");
endif

% Check the gradients of the phase response wrt kR
del=1e-6;
delkR=zeros(size(kR));
delkR(1)=del/2;
wtpl=wplot(ntpl);
diff_PkR=zeros(size(kR));
NkR=length(kR);
for l=1:NkR
  PkRPdel2=schurOneMAPlatticeP(wtpl,kR+delkR,epsilonR,pR,R);
  PkRMdel2=schurOneMAPlatticeP(wtpl,kR-delkR,epsilonR,pR,R);
  delkR=shift(delkR,1);
  diff_PkR(l)=(PkRPdel2-PkRMdel2)/del;
endfor
if max(abs(diff_PkR-gradPR(ntpl,:))) > del/1722
  error("max(abs(diff_PkR-gradPR(ntpl,:))) > del/1722");
endif

% Check the diagonal of the Hessian of the phase response wrt kR
del=1e-6;
delkR=zeros(size(kR));
delkR(1)=del/2;
wtpl=wplot(ntpl);
diffd_PdkR=zeros(size(kR));
for l=1:NkR
  [PkRPdel2,gradPkRPdel2]=schurOneMAPlatticeP(wtpl,kR+delkR,epsilonR,pR,R);
  [PkRMdel2,gradPkRMdel2]=schurOneMAPlatticeP(wtpl,kR-delkR,epsilonR,pR,R);
  delkR=shift(delkR,1);
  diff_dPdkR(l)=(gradPkRPdel2(1,l)-gradPkRMdel2(1,l))/del;
endfor
if max(abs(diff_dPdkR-diagHessPR(ntpl,:))) > del/485
  error("max(abs(diff_dPdkR-diagHessPR(ntpl,:))) > del/485");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with R=10
R10=10;
dR10=zeros(R10*(length(dp)-1)+1,1);
dR10(1:R10:end)=dp;
[hR10,wplot]=freqz(flipud(dR10),dR10,nplot);
P10=unwrap(arg(hR10));
[PR10,gradPR10,diagHessPR10]=schurOneMAPlatticeP(wplot,kR,epsilonR,pR,R10);
if max(abs(P10-PR10))/eps > 256
  error("max(abs(P10-PR10)) > 256*eps");
endif

% Done
toc;
if verbose
endif
diary off
movefile schurOneMAPlatticeP_test.diary.tmp schurOneMAPlatticeP_test.diary;
