% schurOneMlattice2Abcd_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMlattice2Abcd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file(strtok(strf,"_"));

verbose=false;
del=1e-8;

for x=1:4,
  
  % Design filter transfer function
  if x==1
    N=20;dBap=0.1;dBas=80;fc=0.1;
    [n,d]=cheby2(N,dBas,2*fc);
    tol=20*del;
  elseif x==2
    N=11;dBap=0.1;dBas=60;fc=0.1;
    [n,d]=ellip(N,dBap,dBas,2*fc);
    tol=40*del;
  elseif x==3
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
  if max(abs(check_n-n)) > 1000*eps
    error("max(abs(check_n-n)) > 1000*eps");
  endif
  if max(abs(check_d-d)) > 2500*eps
    error("max(abs(check_d-d)) > 2500*eps");
  endif

  % Check [A,B,Cap,Dap]
  [check_nap,check_dap]=Abcd2tf(A,B,Cap,Dap);
  if max(abs(fliplr(check_nap)-d)) > 5000*eps
    error("max(abs(fliplr(check_nap)-d)) > 5000*eps");
  endif
  if max(abs(check_dap-d)) > 5000*eps
    error("max(abs(check_dap-d)) > 5000*eps");
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
  if max(dCdkc_max_err) > tol/2
    error("max(dCdkc_max_err) > %g",tol/2);
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
  if max(dCapdkc_max_err) > tol/5
    error("max(dCapdkc_max_err) > %g",tol/10);
  endif
  if verbose
    printf("max(dDapdkc_max_err)=%g*tol\n",max(dDapdkc_max_err)/tol);
  endif
  if max(dDapdkc_max_err) > tol/10
    error("max(dDapdkc_max_err) > %g",tol/10);
  endif

  % Check the second differentials w.r.t. k and c 
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc, ...
   d2Adxdy,d2Bdxdy,d2Cdxdy,d2Ddxdy,d2Capdxdy,d2Dapdxdy] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c);
  Nkc=length(k)+length(c);
  delk=zeros(size(k));
  delk(1)=del;
  delc=zeros(size(c));
  delc(1)=del;
  d2Adxdy_max_err=zeros(Nkc,Nkc);
  d2Bdxdy_max_err=zeros(Nkc,Nkc);
  d2Cdxdy_max_err=zeros(Nkc,Nkc);
  d2Ddxdy_max_err=zeros(Nkc,Nkc);
  d2Capdxdy_max_err=zeros(Nkc,Nkc);
  d2Dapdxdy_max_err=zeros(Nkc,Nkc);
  for l=1:Nkc,
    for m=1:Nkc,
      if m <= length(k),
        [AP,BP,CP,DP,CapP,DapP, ...
         dAdkcP,dBdkcP,dCdkcP,dDdkcP,dCapdkcP,dDapdkcP] = ...
           schurOneMlattice2Abcd(k+(delk/2),epsilon,p,c);
        [AM,BM,CM,DM,CapM,DapM, ...
         dAdkcM,dBdkcM,dCdkcM,dDdkcM,dCapdkcM,dDapdkcM] = ...
           schurOneMlattice2Abcd(k-(delk/2),epsilon,p,c);
        delk=circshift(delk,1);
      else
        [AP,BP,CP,DP,CapP,DapP, ...
         dAdkcP,dBdkcP,dCdkcP,dDdkcP,dCapdkcP,dDapdkcP] = ...
          schurOneMlattice2Abcd(k,epsilon,p,c+(delc/2));
        [AM,BM,CM,DM,CapM,DapM, ...
         dAdkcM,dBdkcM,dCdkcM,dDdkcM,dCapdkcM,dDapdkcM] = ...
          schurOneMlattice2Abcd(k,epsilon,p,c-(delc/2));
        delc=circshift(delc,1); 
      endif
      
      d2Adxdy_max_err(l,m)= ...
        max(max(abs(((dAdkcP{l}-dAdkcM{l})/del)-d2Adxdy{l,m})));
      d2Bdxdy_max_err(l,m) = ...
        max(abs(((dBdkcP{l}-dBdkcM{l})/del)-d2Bdxdy{l,m}));
      d2Cdxdy_max_err(l,m) = ...
        max(abs(((dCdkcP{l}-dCdkcM{l})/del)-d2Cdxdy{l,m}));
      d2Ddxdy_max_err(l,m) = ...
        max(abs(((dDdkcP{l}-dDdkcM{l})/del)-d2Ddxdy{l,m}));
      d2Capdxdy_max_err(l,m) = ...
        max(abs(((dCapdkcP{l}-dCapdkcM{l})/del)-d2Capdxdy{l,m}));
      d2Dapdxdy_max_err(l,m) = ...
        max(abs(((dDapdkcP{l}-dDapdkcM{l})/del)-d2Dapdxdy{l,m}));
    endfor
  endfor

  if verbose
    printf("max(max(d2Adxdy_max_err))=%g*tol\n",max(max(d2Adxdy_max_err))/tol);
  endif
  switch (x)
    case {1}
      if max(max(d2Adxdy_max_err)) > 10*tol
        error("max(max(d2Adxdy_max_err)) > %g",10*tol);
      endif
    case {2}
      if max(max(d2Adxdy_max_err)) > 4*tol
        error("max(max(d2Adxdy_max_err)) > %g",4*tol);
      endif
    otherwise
      if max(max(d2Adxdy_max_err)) > tol
        error("max(max(d2Adxdy_max_err)) > %g",tol);
      endif
  endswitch
  
  if verbose
    printf("max(max(d2Bdxdy_max_err))=%g*tol\n",max(max(d2Bdxdy_max_err))/tol);
  endif
  if max(max(d2Bdxdy_max_err)) > tol
    error("max(max(d2Bdxdy_max_err)) > %g",tol);
  endif

  if verbose
    printf("max(max(d2Cdxdy_max_err))=%g*tol\n",max(max(d2Cdxdy_max_err))/tol);
  endif
  if max(max(d2Cdxdy_max_err)) > tol
    error("max(max(d2Cdxdy_max_err)) > %g",tol);
  endif

  if verbose
    printf("max(max(d2Ddxdy_max_err))=%g*tol\n",max(max(d2Ddxdy_max_err))/tol);
  endif
  if max(max(d2Ddxdy_max_err)) > tol
    error("max(max(d2Ddxdy_max_err)) > %g",tol);
  endif

  if verbose
    printf("max(max(d2Capdxdy_max_err))=%g*tol\n", ...
           max(max(d2Capdxdy_max_err))/tol);
  endif
  if max(max(d2Capdxdy_max_err)) > tol
    error("max(max(d2Capdxdy_max_err)) > %g",tol);
  endif

  if verbose
    printf("max(max(d2Dapdxdy_max_err))=%g*tol\n", ...
           max(max(d2Dapdxdy_max_err))/tol);
  endif
  if max(max(d2Dapdxdy_max_err)) > tol
    error("max(max(d2Dapdxdy_max_err)) > %g",tol);
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
