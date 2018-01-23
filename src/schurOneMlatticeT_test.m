% schurOneMlatticeT_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMlatticeT_test.diary");
unlink("schurOneMlatticeT_test.diary.tmp");
diary schurOneMlatticeT_test.diary.tmp

clear schurOneMlattice2H
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
[h,wplot]=freqz(n,d,nplot);
t=grpdelay(n,d,nplot);

% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
Nk=length(k);
Nc=length(c);
[T,gradT,diagHessT]=schurOneMlatticeT(wplot,k,epsilon,p,c);

% Check the group-delay response
if max(abs(t(ntpl:ntpu)-T(ntpl:ntpu))) > 472*eps
  error("max(abs(t(ntpl:ntpu)-T(ntpl:ntpu))) > 472*eps");
endif

% Check the gradients of the group delay response wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_Tk=zeros(size(k));
for l=1:Nk
  TkPdel2=schurOneMlatticeT(wtpl,k+delk,epsilon,p,c);
  TkMdel2=schurOneMlatticeT(wtpl,k-delk,epsilon,p,c);
  delk=shift(delk,1);
  diff_Tk(l)=(TkPdel2-TkMdel2)/del;
endfor
if max(abs(diff_Tk-gradT(ntpl,1:Nk))) > del/52.34
  error("max(abs(diff_Tk-gradT(ntpl,1:Nk))) > del/52.34");
endif

% Check the gradient of the group-delay response wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_Tc=zeros(size(c));
for l=1:Nc
  TcPdel2=schurOneMlatticeT(wtpl,k,epsilon,p,c+delc);
  TcMdel2=schurOneMlatticeT(wtpl,k,epsilon,p,c-delc);
  delc=shift(delc,1);
  diff_Tc(l)=(TcPdel2-TcMdel2)/del;
endfor
if max(abs(diff_Tc-gradT(ntpl,(Nk+1):end))) > del/85.63
  error("max(abs(diff_Tc-gradT(ntpl,(Nk+1):end))) > del/85.63");
endif

% Check the diagonal of the Hessian of the group delay wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_dTdk=zeros(size(k));
for l=1:Nk
  [TkPdel2,gradTkPdel2]=schurOneMlatticeT(wtpl,k+delk,epsilon,p,c);
  [TkMdel2,gradTkMdel2]=schurOneMlatticeT(wtpl,k-delk,epsilon,p,c);
  delk=shift(delk,1);
  diff_dTdk(l)=(gradTkPdel2(1,l)-gradTkMdel2(1,l))/del;
endfor
if max(abs(diff_dTdk-diagHessT(ntpl,1:Nk))) > del/13.84
  error("max(abs(diff_dTdk-diagHessT(ntpl,1:Nk))) > del/13.84");
endif

% Check the diagonal of the Hessian of the group delay wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_dTdc=zeros(size(c));
for l=1:Nc
  [TkPdel2,gradTkPdel2]=schurOneMlatticeT(wtpl,k,epsilon,p,c+delc);
  [TkMdel2,gradTkMdel2]=schurOneMlatticeT(wtpl,k,epsilon,p,c-delc);
  delc=shift(delc,1);
  diff_dTdc(l)=(gradTkPdel2(1,Nk+l)-gradTkMdel2(1,Nk+l))/del;
endfor
if max(abs(diff_dTdc-diagHessT(ntpl,(Nk+1):end))) > del/33.546
  error("max(abs(diff_dTdc-diagHessT(ntpl,(Nk+1):end))) > del/33.546");
endif

% Done
toc;
if verbose
endif
diary off
movefile schurOneMlatticeT_test.diary.tmp schurOneMlatticeT_test.diary;
