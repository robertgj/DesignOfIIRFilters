% schurOneMlatticeEsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMlatticeEsq_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

for x=1:2,

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=Nk+Nc;

  %
  % Check the squared-error response
  %
  Asq=schurOneMlatticeAsq(wa,k,epsilon,p,c);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
  
  T=schurOneMlatticeT(wt,k,epsilon,p,c);
  TErr=Wt.*((T-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
  
  P=schurOneMlatticeP(wp,k,epsilon,p,c);
  PErr=Wp.*((P-Pd).^2);  
  PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
  
  D=schurOneMlatticedAsqdw(wd,k,epsilon,p,c);
  DErr=Wd.*((D-Dd).^2);
  DErrSum=sum(diff(wd).*(DErr(1:(length(wd)-1))+DErr(2:end)))/2;
  
  % Find the squared-error
  Esq=schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa);
  EsqErrSum=AsqErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt);
  EsqErrSum=AsqErrSum+TErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(AsqErrSum+TErrSum-Esq) > eps
    error("abs(AsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum+DErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  %
  % Check the gradients of the squared-error
  %
  [Esq,gradEsq]=...
    schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  del=1e-6;
  est_dEsqdkc=zeros(1,Nkc);
  % Check the gradients of the squared-error wrt k
  delk=zeros(1,Nk);
  delk(1)=del/2;
  for l=1:Nk
    EsqkP=schurOneMlatticeEsq(k+delk,epsilon,p,c, ...
                              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    EsqkM=schurOneMlatticeEsq(k-delk,epsilon,p,c, ...
                              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delk=circshift(delk,1);
    est_dEsqdkc(l)=(EsqkP-EsqkM)/del;
  endfor
  % Check the gradient of the squared-error response wrt c
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    EsqcP=schurOneMlatticeEsq(k,epsilon,p,c+delc,wa, ...
                              Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    EsqcM=schurOneMlatticeEsq(k,epsilon,p,c-delc, ...
                              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delc=circshift(delc,1);
    est_dEsqdkc(l)=(EsqcP-EsqcM)/del;
  endfor
  % Check the gradient of the squared-error response
  max_abs_rel_diff_dEsqdkc = max(abs((est_dEsqdkc-gradEsq)./gradEsq));
  if verbose
    printf("max_abs_rel_diff_dEsqdkc = del/%g\n",
           del/max_abs_rel_diff_dEsqdkc);
  endif
  if max_abs_rel_diff_dEsqdkc > del/50
    error("max_abs_rel_diff_dEsqdkc > del/50");
  endif

  %
  % Check the diagonal of the Hessian of the squared-error
  %
  [Esq,gradEsq,diagHessEsq]=...
    schurOneMlatticeEsq(k,epsilon,p,c, ...
                        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  del=1e-6;
  est_diagd2Esqdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the squared-error wrt k
  delk=zeros(1,length(k));
  delk(1)=del/2;
  for l=1:Nk
    [EsqkP,gradEsqkP] = ...
      schurOneMlatticeEsq(k+delk,epsilon,p,c, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    [EsqkM,gradEsqkM] = ...
      schurOneMlatticeEsq(k-delk,epsilon,p,c, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delk=circshift(delk,1);
    est_diagd2Esqdkc2(l)=(gradEsqkP(l)-gradEsqkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error wrt c
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [EsqcP,gradEsqcP] = ...
        schurOneMlatticeEsq(k,epsilon,p,c+delc, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    [EsqcM,gradEsqcM] = ...
      schurOneMlatticeEsq(k,epsilon,p,c-delc, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delc=circshift(delc,1);
    est_diagd2Esqdkc2(l)=(gradEsqcP(l)-gradEsqcM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error wrt k
  max_abs_rel_diff_diagd2Esqdkc2 = ...
    max(max(abs((est_diagd2Esqdkc2-diagHessEsq)./diagHessEsq)));
  if verbose
    printf("max_abs_rel_diff_diagd2Esqdkc2 = del/%g\n",
           del/max_abs_rel_diff_diagd2Esqdkc2);
  endif
  if max_abs_rel_diff_diagd2Esqdkc2 > del/1000
    error("max_abs_rel_diff_diagd2Esqdkc2 > del/1000");
  endif

  %
  % Check the Hessian of the squared-error
  %
  [Esq,gradEsq,diagHessEsq,hessEsq]=...
    schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  del=1e-6;
  est_d2Esqdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the squared-error wrt k
  delk=zeros(1,length(k));
  delk(1)=del/2;
  for l=1:Nk,
    for m=1:Nk,
      [EsqkP,gradEsqkP] = ...
          schurOneMlatticeEsq(k+delk,epsilon,p,c, ...
                              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      [EsqkM,gradEsqkM] = ...
        schurOneMlatticeEsq(k-delk,epsilon,p,c, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      delk=circshift(delk,1);
      est_d2Esqdydx(l,m)=(gradEsqkP(l)-gradEsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-error wrt c
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc,
    for m=(Nk+1):Nkc,
      [EsqcP,gradEsqcP] = ...
        schurOneMlatticeEsq(k,epsilon,p,c+delc, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      [EsqcM,gradEsqcM] = ...
        schurOneMlatticeEsq(k,epsilon,p,c-delc, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      delc=circshift(delc,1);
      est_d2Esqdydx(l,m)=(gradEsqcP(l)-gradEsqcM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-error wrt k and c
  delk=zeros(1,length(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc,
    for m=1:Nk,
      [EsqckP,gradEsqckP] = ...
        schurOneMlatticeEsq(k+delk,epsilon,p,c, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      [EsqckM,gradEsqckM] = ...
        schurOneMlatticeEsq(k-delk,epsilon,p,c, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      delk=circshift(delk,1);
      est_d2Esqdydx(l,m)=(gradEsqckP(l)-gradEsqckM(l))/del;
    endfor
  endfor
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=1:Nk,
    for m=(Nk+1):Nkc,
      [EsqkcP,gradEsqkcP] = ...
        schurOneMlatticeEsq(k,epsilon,p,c+delc, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      [EsqkcM,gradEsqkcM] = ...
        schurOneMlatticeEsq(k,epsilon,p,c-delc, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      delc=circshift(delc,1);
      est_d2Esqdydx(l,m)=(gradEsqkcP(l)-gradEsqkcM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-error
  max_abs_rel_diff_d2Esqdydx = max(max(abs((est_d2Esqdydx-hessEsq)./hessEsq)));
  if verbose
    printf("max_abs_rel_diff_d2Esqdydx = del/%g\n",
           del/max_abs_rel_diff_d2Esqdydx);
  endif
  if max_abs_rel_diff_d2Esqdydx > del/4
    error("max_abs_rel_diff_d2Esqdydx > del/4");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
