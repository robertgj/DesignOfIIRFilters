% schurOneMlatticeT_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticeT_test";

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
  % Check the group-delay response
  %
  T=schurOneMlatticeT(wt,k,epsilon,p,c);
  t=delayz(n,d,wt);
  max_abs_diff_T=max(abs(t-T));
  if verbose
    printf("max_abs_diff_T = %g*eps\n",
           max_abs_diff_T/eps);
  endif
  if max_abs_diff_T > 1e7*eps
    error("max_abs_diff_T > 1e7*eps");
  endif

  %
  % Check the gradients of the group-delay
  %
  [T,gradT]=schurOneMlatticeT(wt,k,epsilon,p,c);
  del=1e-6;
  est_dTdkc=zeros(1,Nkc);
  % Check the gradients of the group-delay wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    TkP=schurOneMlatticeT(wtc,k+delk,epsilon,p,c);
    TkM=schurOneMlatticeT(wtc,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_dTdkc(l)=(TkP-TkM)/del;
  endfor
  % Check the gradient of the group-delay response wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    TcP=schurOneMlatticeT(wtc,k,epsilon,p,c+delc);
    TcM=schurOneMlatticeT(wtc,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_dTdkc(l)=(TcP-TcM)/del;
  endfor
  max_abs_diff_dTdkc = max(abs(est_dTdkc-gradT(ntc,:)));
  if verbose
    printf("max_abs_diff_dTdkc = del/%g\n", del/max_abs_diff_dTdkc);
  endif
  if max_abs_diff_dTdkc> del/20
    error("max_abs_diff_dTdkc > del/20");
  endif

  %
  % Check the diagonal of the Hessian of the group-delay
  %
  [T,gradT,diagHessT]=schurOneMlatticeT(wt,k,epsilon,p,c);
  del=1e-6;
  est_diagd2Tdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the group-delay wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [TkP,gradTkP]=schurOneMlatticeT(wtc,k+delk,epsilon,p,c);
    [TkM,gradTkM]=schurOneMlatticeT(wtc,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_diagd2Tdkc2(l)=(gradTkP(l)-gradTkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the group-delay wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [TkP,gradTkP]=schurOneMlatticeT(wtc,k,epsilon,p,c+delc);
    [TkM,gradTkM]=schurOneMlatticeT(wtc,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_diagd2Tdkc2(l)=(gradTkP(l)-gradTkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the group-delay
  max_abs_diff_diagd2Tdkc2 = ...
    max(abs(est_diagd2Tdkc2-diagHessT(ntc,:)));
  if verbose
    printf("max_abs_diff_diagd2Tdkc2 = del/%g\n",
           del/max_abs_diff_diagd2Tdkc2);
  endif
  if max_abs_diff_diagd2Tdkc2 > del/5
    error("max_abs_diff_diagd2Tdkc2 > del/5");
  endif

  %
  % Check the Hessian of the group-delay
  %
  [T,gradT,diagHessT,hessT]=schurOneMlatticeT(wt,k,epsilon,p,c);
  del=1e-6;
  est_d2Tdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the group-delay wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [TkP,gradTkP]=schurOneMlatticeT(wtc,k+delk,epsilon,p,c);
      [TkM,gradTkM]=schurOneMlatticeT(wtc,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the group-delay wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    for m=(Nk+1):Nkc
      [TkP,gradTkP]=schurOneMlatticeT(wtc,k,epsilon,p,c+delc);
      [TkM,gradTkM]=schurOneMlatticeT(wtc,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the group-delay wrt k and c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=1:Nk
    for m=(Nk+1):Nkc
      [TkP,gradTkP]=schurOneMlatticeT(wtc,k,epsilon,p,c+delc);
      [TkM,gradTkM]=schurOneMlatticeT(wtc,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc
    for m=1:Nk
      [TkP,gradTkP]=schurOneMlatticeT(wtc,k+delk,epsilon,p,c);
      [TkM,gradTkM]=schurOneMlatticeT(wtc,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2Tdydx = ...
    max(max(abs(est_d2Tdydx-squeeze(hessT(ntc,:,:)))));
  if verbose
    printf("max_abs_diff_d2Tdydx = del/%g\n",del/max_abs_diff_d2Tdydx);
  endif
  if max_abs_diff_d2Tdydx > del
    error("max_abs_diff_d2Tdydx > del");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
