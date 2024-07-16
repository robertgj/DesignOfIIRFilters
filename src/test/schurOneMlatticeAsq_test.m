% schurOneMlatticeAsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticeAsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=length(k)+Nc;

  %
  % Check the squared-magnitude response
  %
  h=freqz(n,d,wa);
  [Asq,gradAsq,diagHessAsq,hessAsq]=schurOneMlatticeAsq(wa,k,epsilon,p,c);
  max_abs_diff_Asq=max(abs((abs(h).^2)-Asq));
  if verbose
    printf("max_abs_diff_Asq = %g*eps\n",max_abs_diff_Asq/eps);
  endif
  if max_abs_diff_Asq > 1e4*eps
    error("max_abs_diff_Asq > 1e4*eps");
  endif

  %
  % Check the gradients of the squared-magnitude
  %
  del=1e-6;
  est_dAsqdkc=zeros(1,Nkc);
  % Check the gradients of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    AsqkP=schurOneMlatticeAsq(wac,k+delk,epsilon,p,c);
    AsqkM=schurOneMlatticeAsq(wac,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_dAsqdkc(l)=(AsqkP-AsqkM)/del;
  endfor
  % Check the gradient of the squared-magnitude response wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    AsqcP=schurOneMlatticeAsq(wac,k,epsilon,p,c+delc);
    AsqcM=schurOneMlatticeAsq(wac,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_dAsqdkc(l)=(AsqcP-AsqcM)/del;
  endfor
  max_abs_diff_dAsqdkc = max(abs(est_dAsqdkc-gradAsq(nac,:)));
  if verbose
    printf("max_abs_diff_dAsqdkc = del/%g\n", del/max_abs_diff_dAsqdkc);
  endif
  if max_abs_diff_dAsqdkc> del/600
    error("max_abs_diff_dAsqdkc > del/600");
  endif

  %
  % Check the diagonal of the Hessian of the squared-magnitude
  %
  del=1e-6;
  est_diagd2Asqdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wac,k+delk,epsilon,p,c);
    [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wac,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_diagd2Asqdkc2(l)=(gradAsqkP(l)-gradAsqkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-magnitude wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wac,k,epsilon,p,c+delc);
    [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wac,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_diagd2Asqdkc2(l)=(gradAsqkP(l)-gradAsqkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-magnitude
  max_abs_diff_diagd2Asqdkc2 = ...
    max(abs(est_diagd2Asqdkc2-diagHessAsq(nac,:)));
  if verbose
    printf("max_abs_diff_diagd2Asqdkc2 = del/%g\n",
           del/max_abs_diff_diagd2Asqdkc2);
  endif
  if max_abs_diff_diagd2Asqdkc2 > del/50
    error("max_abs_diff_diagd2Asqdkc2 > del/50");
  endif

  %
  % Check the Hessian of the squared-magnitude
  %
  del=1e-6;
  est_d2Asqdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wac,k+delk,epsilon,p,c);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wac,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-magnitude wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    for m=(Nk+1):Nkc
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wac,k,epsilon,p,c+delc);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wac,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-magnitude wrt k and c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=1:Nk
    for m=(Nk+1):Nkc
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wac,k,epsilon,p,c+delc);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wac,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc
    for m=1:Nk
      [AsqkP,gradAsqkP]=schurOneMlatticeAsq(wac,k+delk,epsilon,p,c);
      [AsqkM,gradAsqkM]=schurOneMlatticeAsq(wac,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Asqdydx(l,m)=(gradAsqkP(l)-gradAsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2Asqdydx = ...
    max(max(abs(est_d2Asqdydx-squeeze(hessAsq(nac,:,:)))));
  if verbose
    printf("max_abs_diff_d2Asqdydx = del/%g\n",del/max_abs_diff_d2Asqdydx);
  endif
  if max_abs_diff_d2Asqdydx > del/40
    error("max_abs_diff_d2Asqdydx > del/40");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
