% schurOneMlatticeP_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMlatticeP_test.diary");
unlink("schurOneMlatticeP_test.diary.tmp");
diary schurOneMlatticeP_test.diary.tmp

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
pp=unwrap(atan2(imag(h),real(h)));

% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
Nk=length(k);
Nc=length(c);
[P,gradP,diagHessP]=schurOneMlatticeP(wplot,k,epsilon,p,c);

% Check the phase response
if max(abs(pp-P)) > 424*eps
  error("max(abs(pp-P)) > 424*eps");
endif

% Check the gradients of the phase response wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_Pk=zeros(size(k));
for l=1:Nk
  PkPdel2=schurOneMlatticeP(wtpl,k+delk,epsilon,p,c);
  PkMdel2=schurOneMlatticeP(wtpl,k-delk,epsilon,p,c);
  delk=shift(delk,1);
  diff_Pk(l)=(PkPdel2-PkMdel2)/del;
endfor
if max(abs(diff_Pk-gradP(ntpl,1:Nk))) > del/1325.3
  error("max(abs(diff_Pk-gradP(ntpl,1:Nk))) > del/1325.3");
endif

% Check the gradient of the phase response wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_Pc=zeros(size(c));
for l=1:Nc
  PcPdel2=schurOneMlatticeP(wtpl,k,epsilon,p,c+delc);
  PcMdel2=schurOneMlatticeP(wtpl,k,epsilon,p,c-delc);
  delc=shift(delc,1);
  diff_Pc(l)=(PcPdel2-PcMdel2)/del;
endfor
if max(abs(diff_Pc-gradP(ntpl,(Nk+1):end))) > del/5357.09
  error("max(abs(diff_Pc-gradP(ntpl,(Nk+1):end))) > del/5357.09");
endif

% Check the diagonal of the Hessian of the phase response wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_dPdk=zeros(size(k));
for l=1:Nk
  [PkPdel2,gradPkPdel2]=schurOneMlatticeP(wtpl,k+delk,epsilon,p,c);
  [PkMdel2,gradPkMdel2]=schurOneMlatticeP(wtpl,k-delk,epsilon,p,c);
  delk=shift(delk,1);
  diff_dPdk(l)=(gradPkPdel2(1,l)-gradPkMdel2(1,l))/del;
endfor
if max(abs(diff_dPdk-diagHessP(ntpl,1:Nk))) > del/226.61
  error("max(abs(diff_dPdk-diagHessP(ntpl,1:Nk))) > del/226.61");
endif

% Check the diagonal of the Hessian of the phase response wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_dPdc=zeros(size(c));
for l=1:Nc
  [PkPdel2,gradPkPdel2]=schurOneMlatticeP(wtpl,k,epsilon,p,c+delc);
  [PkMdel2,gradPkMdel2]=schurOneMlatticeP(wtpl,k,epsilon,p,c-delc);
  delc=shift(delc,1);
  diff_dPdc(l)=(gradPkPdel2(1,Nk+l)-gradPkMdel2(1,Nk+l))/del;
endfor
if max(abs(diff_dPdc-diagHessP(ntpl,(Nk+1):end))) > del/2244.9
  error("max(abs(diff_dPdc-diagHessP(ntpl,(Nk+1):end))) > del/2244.9");
endif

% Done
toc;
if verbose
endif
diary off
movefile schurOneMlatticeP_test.diary.tmp schurOneMlatticeP_test.diary;
