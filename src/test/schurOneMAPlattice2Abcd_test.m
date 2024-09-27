% schurOneMAPlattice2Abcd_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice2Abcd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;
del=1e-8;

for x=1:4,

  % Design filter transfer function
  if x==1
    N=1;fc=0.2;
    [n,d]=butter(N,2*fc);
    tol=20*del;
  elseif x==2
    N=2;fc=0.1;
    [n,d]=butter(N,2*fc);
    tol=50*del;
  elseif x==3
    N=11;dBap=0.1;dBas=60;fc=0.1;
    [n,d]=ellip(N,dBap,dBas,2*fc);
    tol=40*del;
  else
    N=20;dBap=0.1;dBas=80;fc=0.1;
    [n,d]=cheby2(N,dBas,2*fc);
    tol=20*del;
  endif

  % Convert filter transfer function to lattice form
  [k,epsilon,p,~]=tf2schurOneMlattice(n,d);

  % Check [Aap,Bap,Cap,Dap]
  [Aap,Bap,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon,p);
  [check_nap,check_d]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(fliplr(check_nap)-check_d)) > 5000*eps
    error("max(abs(fliplr(check_nap)-check_d)) > 5000*eps");
  endif
  if max(abs(check_d-d)) > 2500*eps
    error("max(abs(check_d-d)) > 2500*eps");
  endif

  % Check [Aap,Bap,Cap,Dap] without p
  [Aap,Bap,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon);
  [check_nap,check_d]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(fliplr(check_nap)-check_d)) > 5000*eps
    error("max(abs(fliplr(check_nap)-check_d)) > 5000*eps");
  endif
  if max(abs(check_d-d)) > 2500*eps
    error("max(abs(check_d-d)) > 2500*eps");
  endif

  % Check [Aap,Bap,Cap,Dap] without epsilon and p
  [Aap,Bap,Cap,Dap]=schurOneMAPlattice2Abcd(k);
  [check_nap,check_d]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(fliplr(check_nap)-check_d)) > 5000*eps
    error("max(abs(fliplr(check_nap)-check_d)) > 5000*eps");
  endif
  if max(abs(check_d-d)) > 2500*eps
    error("max(abs(check_d-d)) > 2500*eps");
  endif

  % Check the differentials of Aap,Bap,Cap and Dap with respect to k
  [Aap,Bap,Cap,Dap,dAapdk,dBapdk,dCapdk,dDapdk] = ...
    schurOneMAPlattice2Abcd(k,epsilon,p);
  Nk=length(k);
  delk=zeros(size(k));
  delk(1)=del;
  dAapdk_max_err=zeros(1,Nk);
  dBapdk_max_err=zeros(1,Nk);
  dCapdk_max_err=zeros(1,Nk);
  dDapdk_max_err=zeros(1,Nk);
  for l=1:Nk
    [AapP,BapP,CapP,DapP]=schurOneMAPlattice2Abcd(k+(delk/2),epsilon,p);
    [AapM,BapM,CapM,DapM]=schurOneMAPlattice2Abcd(k-(delk/2),epsilon,p);
    delk=circshift(delk,1);
    dAapdk_max_err(l)=max(max(abs(((AapP-AapM)/del)-dAapdk{l})));
    dBapdk_max_err(l)=max(abs(((BapP-BapM)/del)-dBapdk{l}));
    dCapdk_max_err(l)=max(abs(((CapP-CapM)/del)-dCapdk{l}));
    dDapdk_max_err(l)=max(abs(((DapP-DapM)/del)-dDapdk{l}));
  endfor
  if verbose
    printf("max(dAapdk_max_err)=%g*tol\n",max(dAapdk_max_err)/tol);
  endif
  if max(dAapdk_max_err) > tol
    error("max(dAapdk_max_err) > %g",tol);
  endif
  if verbose
    printf("max(dBapdk_max_err)=%g*tol\n",max(dBapdk_max_err)/tol);
  endif
  if max(dBapdk_max_err) > tol/10
    error("max(dBapdk_max_err) > %g",tol/10);
  endif
  if verbose
    printf("max(dCapdk_max_err)=%g*tol\n",max(dCapdk_max_err)/tol);
  endif
  if max(dCapdk_max_err) > tol/5
    error("max(dCapdk_max_err) > %g",tol/5);
  endif
  if verbose
    printf("max(dDapdk_max_err)=%g*tol\n",max(dDapdk_max_err)/tol);
  endif
  if max(dDapdk_max_err) > tol/10
    error("max(dDapdk_max_err) > %g",tol/10);
  endif

  % Check the second differentials w.r.t. k
  [Aap,Bap,Cap,Dap,dAapdk,dBapdk,dCapdk,dDapdk, ...
   d2Aapdydx,d2Bapdydx,d2Capdydx,d2Dapdydx] = ...
    schurOneMAPlattice2Abcd(k,epsilon,p);
  Nk=length(k);
  delk=zeros(size(k));
  delk(1)=del/2;
  d2Aapdydx_max_err=zeros(Nk,Nk);
  d2Bapdydx_max_err=zeros(Nk,Nk);
  d2Cdydx_max_err=zeros(Nk,Nk);
  d2Ddydx_max_err=zeros(Nk,Nk);
  d2Capdydx_max_err=zeros(Nk,Nk);
  d2Dapdydx_max_err=zeros(Nk,Nk);
  for l=1:Nk,
    for m=1:Nk,
      [AapP,BapP,CapP,DapP,dAapdkP,dBapdkP,dCapdkP,dDapdkP] = ...
        schurOneMAPlattice2Abcd(k+delk,epsilon,p);
      [AapM,BapM,CapM,DapM,dAapdkM,dBapdkM,dCapdkM,dDapdkM] = ...
        schurOneMAPlattice2Abcd(k-delk,epsilon,p);
      delk=circshift(delk,1);
      
      d2Aapdydx_max_err(l,m)= ...
        max(max(abs(((dAapdkP{l}-dAapdkM{l})/del)-d2Aapdydx{l,m})));
      d2Bapdydx_max_err(l,m) = ...
        max(abs(((dBapdkP{l}-dBapdkM{l})/del)-d2Bapdydx{l,m}));
      d2Capdydx_max_err(l,m) = ...
        max(abs(((dCapdkP{l}-dCapdkM{l})/del)-d2Capdydx{l,m}));
      d2Dapdydx_max_err(l,m) = ...
        max(abs(((dDapdkP{l}-dDapdkM{l})/del)-d2Dapdydx{l,m}));
    endfor
  endfor

  if verbose
    printf("max(max(d2Aapdydx_max_err))=%g*tol\n", ...
           max(max(d2Aapdydx_max_err))/tol);
  endif
  switch (x)
    case {4}
      if max(max(d2Aapdydx_max_err)) > 10*tol
        error("max(max(d2Aapdydx_max_err)) > %g",10*tol);
      endif
    case {3}
      if max(max(d2Aapdydx_max_err)) > 4*tol
        error("max(max(d2Aapdydx_max_err)) > %g",4*tol);
      endif
    otherwise
      if max(max(d2Aapdydx_max_err)) > tol
        error("max(max(d2Aapdydx_max_err)) > %g",tol);
      endif
  endswitch
  
  if verbose
    printf("max(max(d2Bapdydx_max_err))=%g*tol\n", ...
           max(max(d2Bapdydx_max_err))/tol);
  endif
  if max(max(d2Bapdydx_max_err)) > tol
    error("max(max(d2Bapdydx_max_err)) > %g",tol);
  endif

  if verbose
    printf("max(max(d2Capdydx_max_err))=%g*tol\n", ...
           max(max(d2Capdydx_max_err))/tol);
  endif
  if max(max(d2Capdydx_max_err)) > tol
    error("max(max(d2Capdydx_max_err)) > %g",tol);
  endif

  if verbose
    printf("max(max(d2Dapdydx_max_err))=%g*tol\n", ...
           max(max(d2Dapdydx_max_err))/tol);
  endif
  if max(max(d2Dapdydx_max_err)) > tol
    error("max(max(d2Dapdydx_max_err)) > %g",tol);
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
