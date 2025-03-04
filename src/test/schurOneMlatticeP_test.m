% schurOneMlatticeP_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticeP_test";

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
  % Check the phase response
  %
  h=freqz(n,d,wp);
  P=schurOneMlatticeP(wp,k,epsilon,p,c);
  max_abs_diff_P=max(abs(unwrap(arg(h))-P));
  if verbose
    printf("max_abs_diff_P = %g*eps\n",
           max_abs_diff_P/eps);
  endif
  if max_abs_diff_P > 1e4*eps
    error("max_abs_diff_P > 1e4*eps");
  endif

  %
  % Check the gradients of the phase
  %
  [P,gradP]=schurOneMlatticeP(wp,k,epsilon,p,c);
  del=1e-6;
  est_dPdkc=zeros(1,Nkc);
  % Check the gradients of the phase wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    PkP=schurOneMlatticeP(wpc,k+delk,epsilon,p,c);
    PkM=schurOneMlatticeP(wpc,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_dPdkc(l)=(PkP-PkM)/del;
  endfor
  % Check the gradient of the phase response wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    PcP=schurOneMlatticeP(wpc,k,epsilon,p,c+delc);
    PcM=schurOneMlatticeP(wpc,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_dPdkc(l)=(PcP-PcM)/del;
  endfor
  max_abs_diff_dPdkc = max(abs(est_dPdkc-gradP(npc,:)));
  if verbose
    printf("max_abs_diff_dPdkc = del/%g\n", del/max_abs_diff_dPdkc);
  endif
  if max_abs_diff_dPdkc> del/100
    error("max_abs_diff_dPdkc > del/100");
  endif

  %
  % Check the diagonal of the Hessian of the phase
  %
  [P,gradP,diagHessP]=schurOneMlatticeP(wp,k,epsilon,p,c);
  del=1e-6;
  est_diagd2Pdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the phase wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [PkP,gradPkP]=schurOneMlatticeP(wpc,k+delk,epsilon,p,c);
    [PkM,gradPkM]=schurOneMlatticeP(wpc,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_diagd2Pdkc2(l)=(gradPkP(l)-gradPkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the phase wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [PkP,gradPkP]=schurOneMlatticeP(wpc,k,epsilon,p,c+delc);
    [PkM,gradPkM]=schurOneMlatticeP(wpc,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_diagd2Pdkc2(l)=(gradPkP(l)-gradPkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the phase
  max_abs_diff_diagd2Pdkc2 = ...
    max(abs(est_diagd2Pdkc2-diagHessP(npc,:)));
  if verbose
    printf("max_abs_diff_diagd2Pdkc2 = del/%g\n",
           del/max_abs_diff_diagd2Pdkc2);
  endif
  if max_abs_diff_diagd2Pdkc2 > del/100
    error("max_abs_diff_diagd2Pdkc2 > del/100");
  endif

  %
  % Check the Hessian of the phase
  %
  [P,gradP,diagHessP,hessP]=schurOneMlatticeP(wp,k,epsilon,p,c);
  del=1e-6;
  est_d2Pdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the phase wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [PkP,gradPkP]=schurOneMlatticeP(wpc,k+delk,epsilon,p,c);
      [PkM,gradPkM]=schurOneMlatticeP(wpc,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Pdydx(l,m)=(gradPkP(l)-gradPkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the phase wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    for m=(Nk+1):Nkc
      [PkP,gradPkP]=schurOneMlatticeP(wpc,k,epsilon,p,c+delc);
      [PkM,gradPkM]=schurOneMlatticeP(wpc,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Pdydx(l,m)=(gradPkP(l)-gradPkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the phase wrt k and c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=1:Nk
    for m=(Nk+1):Nkc
      [PkP,gradPkP]=schurOneMlatticeP(wpc,k,epsilon,p,c+delc);
      [PkM,gradPkM]=schurOneMlatticeP(wpc,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Pdydx(l,m)=(gradPkP(l)-gradPkM(l))/del;
    endfor
  endfor
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc
    for m=1:Nk
      [PkP,gradPkP]=schurOneMlatticeP(wpc,k+delk,epsilon,p,c);
      [PkM,gradPkM]=schurOneMlatticeP(wpc,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Pdydx(l,m)=(gradPkP(l)-gradPkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2Pdydx = ...
    max(max(abs(est_d2Pdydx-squeeze(hessP(npc,:,:)))));
  if verbose
    printf("max_abs_diff_d2Pdydx = del/%g\n",del/max_abs_diff_d2Pdydx);
  endif
  if max_abs_diff_d2Pdydx > del/50
    error("max_abs_diff_d2Pdydx > del/50");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
