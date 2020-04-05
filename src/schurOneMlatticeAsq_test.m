% schurOneMlatticeAsq_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("schurOneMlatticeAsq_test.diary");
delete("schurOneMlatticeAsq_test.diary.tmp");
diary schurOneMlatticeAsq_test.diary.tmp

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

% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
Nk=length(k);
Nc=length(c);
Nkc=length(k)+Nc;
[Asq,gradAsq,diagHessAsq]=schurOneMlatticeAsq(wplot,k,epsilon,p,c);

% Check the magnitude-squared response
if max(abs((abs(h).^2)-Asq)) > 33.5*eps
  error("max(abs((abs(h).^2)-Asq)) > 33.5*eps");
endif

% Check the gradients of the squared-magnitude wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_Asqk=zeros(size(k));
for l=1:Nk
  AsqkPdel2=schurOneMlatticeAsq(wtpl,k+delk,epsilon,p,c);
  AsqkMdel2=schurOneMlatticeAsq(wtpl,k-delk,epsilon,p,c);
  delk=shift(delk,1);
  diff_Asqk(l)=(AsqkPdel2-AsqkMdel2)/del;
endfor
if max(abs(diff_Asqk-gradAsq(ntpl,1:Nk))) > del/1000
  error("max(abs(diff_Asqk-gradAsq(ntpl,1:Nk))) > del/1000");
endif

% Check the gradient of the squared-magnitude response wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_Asqc=zeros(size(c));
for l=1:Nc
  AsqcPdel2=schurOneMlatticeAsq(wtpl,k,epsilon,p,c+delc);
  AsqcMdel2=schurOneMlatticeAsq(wtpl,k,epsilon,p,c-delc);
  delc=shift(delc,1);
  diff_Asqc(l)=(AsqcPdel2-AsqcMdel2)/del;
endfor
if max(abs(diff_Asqc-gradAsq(ntpl,(Nk+1):Nkc))) > del/2500
  error("max(abs(diff_Asqc-gradAsq(ntpl,(Nk+1):Nkc))) > del/2500");
endif

% Check the diagonal of the Hessian of the squared-magnitude wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_dAsqdk=zeros(size(k));
for l=1:Nk
  [AsqkPdel2,gradAsqkPdel2]=schurOneMlatticeAsq(wtpl,k+delk,epsilon,p,c);
  [AsqkMdel2,gradAsqkMdel2]=schurOneMlatticeAsq(wtpl,k-delk,epsilon,p,c);
  delk=shift(delk,1);
  diff_dAsqdk(l)=(gradAsqkPdel2(1,l)-gradAsqkMdel2(1,l))/del;
endfor
if max(abs(diff_dAsqdk-diagHessAsq(ntpl,1:Nk))) > del/400
  error("max(abs(diff_dAsqdk-diagHessAsq(ntpl,1:Nk))) > del/400");
endif

% Check the diagonal of the Hessian of the squared-magnitude wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_dAsqdc=zeros(size(c));
for l=1:Nc
  [AsqkPdel2,gradAsqkPdel2]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c+delc);
  [AsqkMdel2,gradAsqkMdel2]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c-delc);
  delc=shift(delc,1);
  diff_dAsqdc(l)=(gradAsqkPdel2(1,Nk+l)-gradAsqkMdel2(1,Nk+l))/del;
endfor
if max(abs(diff_dAsqdc-diagHessAsq(ntpl,(Nk+1):Nkc))) > del/2500
  error("max(abs(diff_dAsqdc-diagHessAsq(ntpl,(Nk+1):Nkc))) > del/2500");
endif

% Done
diary off
movefile schurOneMlatticeAsq_test.diary.tmp schurOneMlatticeAsq_test.diary;
