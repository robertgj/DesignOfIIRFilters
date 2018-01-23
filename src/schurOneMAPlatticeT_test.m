% schurOneMAPlatticeT_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMAPlatticeT_test.diary");
unlink("schurOneMAPlatticeT_test.diary.tmp");
diary schurOneMAPlatticeT_test.diary.tmp

clear schurOneMAPlattice2H
tic;
verbose=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
t=grpdelay(flipud(d),d,nplot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,~]=tf2schurOneMlattice(n,d);
Nk=length(k);
[T,gradT,diagHessT]=schurOneMAPlatticeT(wplot,k,epsilon,p);

% Check the group-delay response
if max(abs(t(ntpl:ntpu)-T(ntpl:ntpu))) > 43328*eps
  error("max(abs(t(ntpl:ntpu)-T(ntpl:ntpu))) > 43328*eps");
endif

% Check the gradients of the group delay response wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_Tk=zeros(size(k));
for l=1:Nk
  TkPdel2=schurOneMAPlatticeT(wtpl,k+delk,epsilon,p);
  TkMdel2=schurOneMAPlatticeT(wtpl,k-delk,epsilon,p);
  delk=shift(delk,1);
  diff_Tk(l)=(TkPdel2-TkMdel2)/del;
endfor
if max(abs(diff_Tk-gradT(ntpl,:))) > del/46.48
  error("max(abs(diff_Tk-gradT(ntpl,:))) > del/46.48");
endif

% Check the diagonal of the Hessian of the group delay wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_dTdk=zeros(size(k));
for l=1:Nk
  [TkPdel2,gradTkPdel2]=schurOneMAPlatticeT(wtpl,k+delk,epsilon,p);
  [TkMdel2,gradTkMdel2]=schurOneMAPlatticeT(wtpl,k-delk,epsilon,p);
  delk=shift(delk,1);
  diff_dTdk(l)=(gradTkPdel2(1,l)-gradTkMdel2(1,l))/del;
endfor
if max(abs(diff_dTdk-diagHessT(ntpl,:))) > del/10.52
  error("max(abs(diff_dTdk-diagHessT(ntpl,:))) > del/10.52");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with R=2
R=2;
% Convert filter transfer function to Schur 1-multiplier lattice form
dp=d(1:2:end);
[kR,epsilonR,pR,~]=tf2schurOneMlattice(flipud(dp),dp);
NkR=length(kR);
[TR,gradTR,diagHessTR]=schurOneMAPlatticeT(wplot,kR,epsilonR,pR,R);
if max(abs(T-TR))/eps > 192
  error("max(abs(T-TR)) > 192*eps");
endif
if max(max(abs(gradT(ntpl:ntpu,2:2:end)-gradTR(ntpl:ntpu,:))))/eps > 776
  error("max(max(abs(gradT(ntpl:ntpu,2:2:end)-gradTR(ntpl:ntpu,:)))) > 776*eps");
endif
if max(max(abs(diagHessT(ntpl:ntpu,2:2:end)-diagHessTR(ntpl:ntpu,:))))/eps>11904
  error("max(max(abs(diagHessT(ntpl:ntpu,2:2:end)-diagHessTR(ntpl:ntpu,:))))\
>11904*eps");
endif

% Check the group-delay response
if max(abs(t(ntpl:ntpu)-TR(ntpl:ntpu))) > 38113*eps
  error("max(abs(t(ntpl:ntpu)-TR(ntpl:ntpu))) > 38113*eps");
endif

% Check the gradients of the group delay response wrt kR
del=1e-6;
delkR=zeros(size(kR));
delkR(1)=del/2;
wtpl=wplot(ntpl);
diff_TkR=zeros(size(kR));
for l=1:NkR
  TkRPdel2=schurOneMAPlatticeT(wtpl,kR+delkR,epsilonR,pR,R);
  TkRMdel2=schurOneMAPlatticeT(wtpl,kR-delkR,epsilonR,pR,R);
  delkR=shift(delkR,1);
  diff_TkR(l)=(TkRPdel2-TkRMdel2)/del;
endfor
if max(abs(diff_TkR-gradTR(ntpl,:))) > del/66
  error("max(abs(diff_TkR-gradTR(ntpl,:))) > del/66");
endif

% Check the diagonal of the Hessian of the group delay wrt kR
del=1e-6;
delkR=zeros(size(kR));
delkR(1)=del/2;
wtpl=wplot(ntpl);
diff_dTdkR=zeros(size(kR));
for l=1:NkR
  [TkRPdel2,gradTkRPdel2]=schurOneMAPlatticeT(wtpl,kR+delkR,epsilonR,pR,R);
  [TkRMdel2,gradTkRMdel2]=schurOneMAPlatticeT(wtpl,kR-delkR,epsilonR,pR,R);
  delkR=shift(delkR,1);
  diff_dTdkR(l)=(gradTkRPdel2(1,l)-gradTkRMdel2(1,l))/del;
endfor
if max(abs(diff_dTdkR-diagHessTR(ntpl,:))) > del/13.7
  error("max(abs(diff_dTdkR-diagHessT(ntpl,:))) > del/13.7");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with R=10
R10=10;
dR10=zeros(R10*(length(dp)-1)+1,1);
dR10(1:R10:end)=dp;
T10=grpdelay(flipud(dR10),dR10,nplot);
TR10=schurOneMAPlatticeT(wplot,kR,epsilonR,pR,R10);
if max(abs(T10-TR10)) > 1e-10
  error("max(abs(T10-TR10)) > 1e-10");
endif

% Done
toc;
if verbose
endif
diary off
movefile schurOneMAPlatticeT_test.diary.tmp schurOneMAPlatticeT_test.diary;
