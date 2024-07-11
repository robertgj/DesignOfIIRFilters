% schurOneMlatticeAsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticeAsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2
  if x==1
    N=3;
    ftpl=0.1;
    [n,d]=butter(N,ftpl*2);
  else
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
  endif

  nplot=1024;
  ntpl=floor(nplot*ftpl/0.5);
  [h,wplot]=freqz(n,d,nplot);

  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=length(k)+Nc;
  [Asq,gradAsq,diagHessAsq,hessAsq]=schurOneMlatticeAsq(wplot,k,epsilon,p,c);

  %
  % Check the squared-magnitude response
  %
  max_abs_diff_Asq=max(abs((abs(h).^2)-Asq));
  if verbose
    printf("max_abs_diff_Asq = %g*eps\n",max_abs_diff_Asq/eps);
  endif
  if max_abs_diff_Asq > 40*eps
    error("max_abs_diff_Asq > 40*eps");
  endif

  %
  % Check the gradients of the squared-magnitude
  %
  del=1e-6;
  wtpl=wplot(ntpl);
  est_dAsqdkc=zeros(1,Nkc);
  % Check the gradients of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    AsqkP=schurOneMlatticeAsq(wtpl,k+delk,epsilon,p,c);
    AsqkM=schurOneMlatticeAsq(wtpl,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_dAsqdkc(l)=(AsqkP-AsqkM)/del;
  endfor
  % Check the gradient of the squared-magnitude response wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    AsqcP=schurOneMlatticeAsq(wtpl,k,epsilon,p,c+delc);
    AsqcM=schurOneMlatticeAsq(wtpl,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_dAsqdkc(l)=(AsqcP-AsqcM)/del;
  endfor
  max_abs_diff_dAsqdkc = max(abs(est_dAsqdkc-gradAsq(ntpl,:)));
  if verbose
    printf("max_abs_diff_dAsqdkc = del/%g\n", del/max_abs_diff_dAsqdkc);
  endif
  if max_abs_diff_dAsqdkc> del/1000
    error("max_abs_diff_dAsqdkc > del/1000");
  endif

  %
  % Check the diagonal of the Hessian of the squared-magnitude
  %
  del=1e-6;
  wtpl=wplot(ntpl);
  est_diagd2Asqdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wtpl,k+delk,epsilon,p,c);
    [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wtpl,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_diagd2Asqdkc2(l)=(gradAsqkP(l)-gradAsqkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-magnitude wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c+delc);
    [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_diagd2Asqdkc2(l)=(gradAsqkP(l)-gradAsqkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-magnitude
  max_abs_diff_diagd2Asqdkc2 = ...
    max(abs(est_diagd2Asqdkc2-diagHessAsq(ntpl,:)));
  if verbose
    printf("max_abs_diff_diagd2Asqdkc2 = del/%g\n",
           del/max_abs_diff_diagd2Asqdkc2);
  endif
  if max_abs_diff_diagd2Asqdkc2 > del/400
    error("max_abs_diff_diagd2Asqdkc2 > del/400");
  endif

  %
  % Check the Hessian of the squared-magnitude
  %
  del=1e-6;
  wtpl=wplot(ntpl);
  est_d2Asqdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wtpl,k+delk,epsilon,p,c);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wtpl,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-magnitude wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    for m=(Nk+1):Nkc
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c+delc);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-magnitude wrt k and c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=1:Nk
    for m=(Nk+1):Nkc
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c+delc);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wtpl,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc
    for m=1:Nk
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wtpl,k+delk,epsilon,p,c);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wtpl,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2Asqdydx = ...
    max(max(abs(est_d2Asqdydx-squeeze(hessAsq(ntpl,:,:)))));
  if verbose
    printf("max_abs_diff_d2Asqdydx = del/%g\n",del/max_abs_diff_d2Asqdydx);
  endif
  if max_abs_diff_d2Asqdydx > del/100
    error("max_abs_diff_d2Asqdydx > del/100");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
