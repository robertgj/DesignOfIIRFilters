% schurOneMlatticedAsqdw_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticedAsqdw_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;
tol=1e-6;

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=length(k)+Nc;

  %
  % Check the derivative of the squared-magnitude response
  %
  wmany=(0:((nplot*200)-1))'*pi/(nplot*200);
  dAsqdw=schurOneMlatticedAsqdw(wmany,k,epsilon,p,c);
  [h,wmany]=freqz(n,d,wmany);
  est_dAsqdw=diff(abs(h).^2)/(wmany(2)-wmany(1));
  max_abs_diff_dAsqdw=max(abs(est_dAsqdw - ...
                              ((dAsqdw(1:(end-1))+dAsqdw(2:end))/2)));
  if verbose
    printf("max_abs_diff_dAsqdw = %g*tol\n",max_abs_diff_dAsqdw/tol);
  endif
  if max_abs_diff_dAsqdw > 2*tol
    error("max_abs_diff_dAsqdw > 2*tol");
  endif

  %
  % Check the gradients of the derivative of the squared-magnitude
  %
  [dAsqdw,graddAsqdw]=schurOneMlatticedAsqdw(wd,k,epsilon,p,c);
  del=tol;
  est_ddAsqdwdkc=zeros(1,Nkc);
  % Check the gradients of the derivative of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    dAsqdwkP=schurOneMlatticedAsqdw(wdc,k+delk,epsilon,p,c);
    dAsqdwkM=schurOneMlatticedAsqdw(wdc,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_ddAsqdwdkc(l)=(dAsqdwkP-dAsqdwkM)/del;
  endfor
  % Check the gradient of the derivative of the squared-magnitude wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    dAsqdwcP=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c+delc);
    dAsqdwcM=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_ddAsqdwdkc(l)=(dAsqdwcP-dAsqdwcM)/del;
  endfor
  max_abs_diff_ddAsqdwdkc = max(abs(est_ddAsqdwdkc-graddAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_ddAsqdwdkc = del/%g\n", del/max_abs_diff_ddAsqdwdkc);
  endif
  if max_abs_diff_ddAsqdwdkc> del/20
    error("max_abs_diff_ddAsqdwdkc > del/20");
  endif

  %
  % Check the diagonal of the Hessian of the derivative of the squared-magnitude
  %
  [dAsqdw,graddAsqdw,diagHessdAsqdw]=schurOneMlatticedAsqdw(wd,k,epsilon,p,c);
  del=tol;
  est_diagd2dAsqdwdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the derivative of the squared-magnitude
  % wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [dAsqdwkP,graddAsqdwkP]=schurOneMlatticedAsqdw(wdc,k+delk,epsilon,p,c);
    [dAsqdwkM,graddAsqdwkM]=schurOneMlatticedAsqdw(wdc,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_diagd2dAsqdwdkc2(l)=(graddAsqdwkP(l)-graddAsqdwkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the derivative of the squared-magnitude
  % wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [dAsqdwkP,graddAsqdwkP]=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c+delc);
    [dAsqdwkM,graddAsqdwkM]=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_diagd2dAsqdwdkc2(l)=(graddAsqdwkP(l)-graddAsqdwkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the derivative of the squared-magnitude
  max_abs_diff_diagd2dAsqdwdkc2 = ...
    max(abs(est_diagd2dAsqdwdkc2-diagHessdAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_diagd2dAsqdwdkc2 = del/%g\n", ...
           del/max_abs_diff_diagd2dAsqdwdkc2);
  endif
  if max_abs_diff_diagd2dAsqdwdkc2 > del/2
    error("max_abs_diff_diagd2dAsqdwdkc2 > del/2");
  endif

  %
  % Check the Hessian of the derivative of the squared-magnitude
  %
  [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...
    schurOneMlatticedAsqdw(wd,k,epsilon,p,c);
  del=tol;
  est_d2dAsqdwdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the derivative of the squared-magnitude wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [dAsqdwkP,graddAsqdwkP]=schurOneMlatticedAsqdw(wdc,k+delk,epsilon,p,c);
      [dAsqdwkM,graddAsqdwkM]=schurOneMlatticedAsqdw(wdc,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwkP(l)-graddAsqdwkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the derivative of the squared-magnitude wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    for m=(Nk+1):Nkc
      [dAsqdwkP,graddAsqdwkP]=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c+delc);
      [dAsqdwkM,graddAsqdwkM]=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwkP(l)-graddAsqdwkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the derivative of the squared-magnitude wrt k and c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=1:Nk
    for m=(Nk+1):Nkc
      [dAsqdwkP,graddAsqdwkP]=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c+delc);
      [dAsqdwkM,graddAsqdwkM]=schurOneMlatticedAsqdw(wdc,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwkP(l)-graddAsqdwkM(l))/del;
    endfor
  endfor
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc
    for m=1:Nk
      [dAsqdwkP,graddAsqdwkP]=schurOneMlatticedAsqdw(wdc,k+delk,epsilon,p,c);
      [dAsqdwkM,graddAsqdwkM]=schurOneMlatticedAsqdw(wdc,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwkP(l)-graddAsqdwkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2dAsqdwdydx = ...
    max(max(abs(est_d2dAsqdwdydx-squeeze(hessdAsqdw(ndc,:,:)))));
  if verbose
    printf("max_abs_diff_d2dAsqdwdydx = del/%g\n",del/max_abs_diff_d2dAsqdwdydx);
  endif
  if max_abs_diff_d2dAsqdwdydx > del
    error("max_abs_diff_d2dAsqdwdydx > del");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
