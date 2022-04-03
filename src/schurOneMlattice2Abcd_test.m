% schurOneMlattice2Abcd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("schurOneMlattice2Abcd_test.diary");
delete("schurOneMlattice2Abcd_test.diary.tmp");
diary schurOneMlattice2Abcd_test.diary.tmp

check_octave_file("schurOneMlattice2Abcd");

verbose=false;
del=1e-8;

for x=1:3

  % Design filter transfer function
  if x==1
    N=20;dbap=0.1;dbas=80;fc=0.1;
    [n,d]=cheby2(N,dbas,2*fc);
    tol=20*del;
  elseif x==2
    N=2;fc=0.1;
    [n,d]=butter(N,2*fc);
    tol=50*del;
  else
    N=1;fc=0.2;
    [n,d]=butter(N,2*fc);
    tol=20*del;
  endif

  % Convert filter transfer function to lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);

  % Check [A,B,C,D]
  [check_n,check_d]=Abcd2tf(A,B,C,D);
  if max(abs(check_n-n)) > 499*eps
    error("max(abs(check_n-n)) > 499*eps");
  endif
  if max(abs(check_d-d)) > 2048*eps
    error("max(abs(check_d-d)) > 2048*eps");
  endif

  % Check [A,B,Cap,Dap]
  [check_nap,check_dap]=Abcd2tf(A,B,Cap,Dap);
  if max(abs(fliplr(check_nap)-d)) > 3072*eps
    error("max(abs(fliplr(check_nap)-d)) > 3072*eps");
  endif
  if max(abs(check_dap-d)) > 2048*eps
    error("max(abs(check_dap-d)) > 2048*eps");
  endif

  % Check the differentials of A,B,C,D,Cap and Dap with respect to k and c
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc] = ...
  schurOneMlattice2Abcd(k,epsilon,p,c);
  Nkc=length(k)+length(c);
  delk=zeros(size(k));
  delk(1)=del;
  delc=zeros(size(c));
  delc(1)=del;
  dAdkc_max_err=zeros(1,Nkc);
  dBdkc_max_err=zeros(1,Nkc);
  dCdkc_max_err=zeros(1,Nkc);
  dDdkc_max_err=zeros(1,Nkc);
  dCapdkc_max_err=zeros(1,Nkc);
  dDapdkc_max_err=zeros(1,Nkc);
  for l=1:Nkc
    if l <= length(k)
      [AP,BP,CP,DP,CapP,DapP]=schurOneMlattice2Abcd(k+(delk/2),epsilon,p,c);
      [AM,BM,CM,DM,CapM,DapM]=schurOneMlattice2Abcd(k-(delk/2),epsilon,p,c);
      delk=circshift(delk,1);
    else
      [AP,BP,CP,DP,CapP,DapP]=schurOneMlattice2Abcd(k,epsilon,p,c+(delc/2));
      [AM,BM,CM,DM,CapM,DapM]=schurOneMlattice2Abcd(k,epsilon,p,c-(delc/2));
      delc=circshift(delc,1);
    endif
    dAdkc_max_err(l)=max(max(abs(((AP-AM)/del)-dAdkc{l})));
    dBdkc_max_err(l)=max(abs(((BP-BM)/del)-dBdkc{l}));
    dCdkc_max_err(l)=max(abs(((CP-CM)/del)-dCdkc{l}));
    dDdkc_max_err(l)=max(abs(((DP-DM)/del)-dDdkc{l}));
    dCapdkc_max_err(l)=max(abs(((CapP-CapM)/del)-dCapdkc{l}));
    dDapdkc_max_err(l)=max(abs(((DapP-DapM)/del)-dDapdkc{l}));
  endfor
  if verbose
    printf("max(dAdkc_max_err)=%g*tol\n",max(dAdkc_max_err)/tol);
  endif
  if max(dAdkc_max_err) > tol
    error("max(dAdkc_max_err) > %g",tol);
  endif
  if verbose
    printf("max(dBdkc_max_err)=%g*tol\n",max(dBdkc_max_err)/tol);
  endif
  if max(dBdkc_max_err) > tol/10
    error("max(dBdkc_max_err) > %g",tol/10);
  endif
  if verbose
    printf("max(dCdkc_max_err)=%g*tol\n",max(dCdkc_max_err)/tol);
  endif
  if max(dCdkc_max_err) > tol/10
    error("max(dCdkc_max_err) > %g",tol/10);
  endif
  if verbose
    printf("max(dDdkc_max_err)=%g*tol\n",max(dDdkc_max_err)/tol);
  endif
  if max(dDdkc_max_err) > tol/20
    error("max(dDdkc_max_err) > %g",tol/20);
  endif
  if verbose
    printf("max(dCapdkc_max_err)=%g*tol\n",max(dCapdkc_max_err)/tol);
  endif
  if max(dCapdkc_max_err) > tol/10
    error("max(dCapdkc_max_err) > %g",tol/10);
  endif
  if verbose
    printf("max(dDapdkc_max_err)=%g*tol\n",max(dDapdkc_max_err)/tol);
  endif
  if max(dDapdkc_max_err) > tol/10
    error("max(dDapdkc_max_err) > %g",tol/10);
  endif

endfor

% Done
diary off
movefile schurOneMlattice2Abcd_test.diary.tmp schurOneMlattice2Abcd_test.diary;
