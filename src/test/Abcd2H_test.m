% Abcd2H_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="Abcd2H_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file(strtok(strf,"_"));

verbose=false;
tol=5e-9;

% First check for a small filter
N=1;fc=0.1;
[n,d]=butter(N,2*fc);
Nw=400;
nplot=1024;
nc=(fc/0.5)*nplot;
w=pi*(0:(Nw-1))'/nplot;
h=freqz(n,d,w);
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
[A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
H=Abcd2H(w,A,B,C,D);
max_abs_diff_h=max(abs(h(1:nc)-H(1:nc)));
if max_abs_diff_h > 4*eps
  error("max_abs_diff_h(%g*eps) > 4*eps",max_abs_diff_h/eps);
endif

% Second check for a small filter
N=2;fc=0.1;
[n,d]=butter(N,2*fc);
Nw=400;
nplot=1024;
nc=(fc/0.5)*nplot;
w=pi*(0:(Nw-1))'/nplot;
h=freqz(n,d,w);
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
[A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
H=Abcd2H(w,A,B,C,D);
max_abs_diff_h=max(abs(h(1:nc)-H(1:nc)));
if max_abs_diff_h > 10*eps
  error("max_abs_diff_h(%g*eps) > 10*eps",max_abs_diff_h/eps);
endif

for N=[1,2,5,10,15]
  
  % Design filter transfer function
  fc=0.1;dBap=1;
  [n,d]=cheby1(N,dBap,2*fc);
  Nw=400;
  nplot=1024;
  nc=(fc/0.5)*nplot;
  w=pi*(0:(Nw-1))'/nplot;
  h=freqz(n,d,w);

  %
  % Convert filter transfer function to lattice form
  %
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc, ...
   d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx,d2Capdydx,d2Dapdydx] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c);
  Nk=rows(A);
  dAdk=cell(1,Nk);
  dBdk=cell(1,Nk);
  dCapdk=cell(1,Nk);
  dDapdk=cell(1,Nk);
  for l=1:Nk
    dAdk{l}=dAdkc{l}(1:Nk,1:Nk);
    dBdk{l}=dBdkc{l}(1:Nk,1);
    dCapdk{l}=dCapdkc{l}(1,1:Nk);
    dDapdk{l}=dDapdkc{l}(1,1);
  endfor
  d2Adkdk=cell(Nk,Nk);
  d2Bdkdk=cell(Nk,Nk);
  d2Capdkdk=cell(Nk,Nk);
  d2Dapdkdk=cell(Nk,Nk);
  for m=1:Nk
    for n=1:Nk
      d2Adkdk{m,n}=d2Adydx{m,n}(1:Nk,1:Nk);
      d2Bdkdk{m,n}=d2Bdydx{m,n}(1:Nk,1);
      d2Capdkdk{m,n}=d2Capdydx{m,n}(1,1:Nk);
      d2Dapdkdk{m,n}=d2Dapdydx{m,n}(1,1);
    endfor
  endfor

  %
  % Check H
  %
  H=Abcd2H(w,A,B,C,D);
  if verbose
    printf("max(abs(h-H)) = %g*tol\n",max(abs(h-H))/tol);
  endif
  if max(abs(h-H)) > 3000*tol
    error("max(abs(h-H))(%g*tol) > 3000*tol",max(abs(h-H))/tol);
  endif

  % Check Hap
  Hap=Abcd2H(w,A,B,Cap,Dap);
  if verbose
    printf("max(abs(Hap)-1) = %g*eps\n",max(abs(Hap)-1)/eps);
  endif
  if max(abs(Hap)-1) > 200*eps
    error("max(abs(Hap)-1)(%g*eps) > 200*eps",max(abs(Hap)-1)/eps);
  endif

  %
  % Check dHdw
  %
  [H,dHdw]=Abcd2H(w,A,B,C,D);
  del=tol;
  delw=del/2;
  HP=Abcd2H(w+delw,A,B,C,D);
  HM=Abcd2H(w-delw,A,B,C,D);
  est_dHdw=(HP-HM)/del;
  max_diff_dHdw=max(abs(est_dHdw-dHdw));
  if verbose
    printf("max_diff_dHdw = %g*tol\n",max_diff_dHdw/tol);
  endif
  if max_diff_dHdw > 1000*tol
    error("max_diff_dHdw(%g*tol) > 1000*tol",max_diff_dHdw/tol);
  endif

  % Check dHapdw
  [Hap,dHapdw]=Abcd2H(w,A,B,Cap,Dap);
  if any(abs(dHapdw)<tol)
    error("any(abs(dHapdw)<tol)");
  endif
  del=tol;
  delw=del/2;
  diff_Hapw=zeros(1,Nw);
  HapP=Abcd2H(w+delw,A,B,Cap,Dap);
  HapM=Abcd2H(w-delw,A,B,Cap,Dap);
  est_dHapdw=(HapP-HapM)/del;
  max_rel_diff_Hapw=max(abs(est_dHapdw-dHapdw)./abs(dHapdw));
  if verbose
    printf("max_rel_diff_dHdw = %g*tol\n",max_rel_diff_Hapw/tol);
  endif
  if max_rel_diff_Hapw > 40*tol
    error("max_rel_diff_dHdw(%g*tol) > 40*tol",max_rel_diff_Hapw/tol);
  endif

  %
  % Check dHdkc
  %
  Nkc=length(dAdkc);
  Nk=rows(A);
  Nc=Nk+1;
  [H,dHdw,dHdkc]=Abcd2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  if any(any(abs(dHdkc))<tol)
    error("any(any(abs(dHdkc)<tol))");
  endif
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  delc=zeros(size(c));
  delc(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_dHdkc=zeros(1,Nkc);
  for l=1:Nkc
    if l<=Nk
      [AP,BP,CP,DP]=schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,CM,DM]=schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);
    else
      [AP,BP,CP,DP]=schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [AM,BM,CM,DM]=schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      delc=circshift(delc,1);
    endif
    HP=Abcd2H(w(nc),AP,BP,CP,DP);
    HM=Abcd2H(w(nc),AM,BM,CM,DM);
    est_dHdkc(l)=(HP-HM)/del;
  endfor
  max_abs_rel_diff_dHdkc=max(abs(est_dHdkc(l)-dHdkc(nc,l))./abs(dHdkc(nc,l)));
  if verbose
    printf("max_abs_rel_diff_dHdkc = %g*tol\n",max_abs_rel_diff_dHdkc/tol);
  endif
  if max_abs_rel_diff_dHdkc > 200*tol
    error("max_abs_rel_diff_dHdkc(%g*tol) > 200*tol",max_abs_rel_diff_dHdkc/tol);
  endif

  % Check dHapdk
  [Hap,dHapdw,dHapdk]=Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  if any(any(abs(dHapdk))<tol)
    error("any(any(abs(dHapdk)<tol))");
  endif
  Nk=rows(A);
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_dHapdk=zeros(1,Nk);
  for l=1:Nk
    [AP,BP,CapP,DapP]=schurOneMAPlattice2Abcd(k+delk,epsilon,p);
    [AM,BM,CapM,DapM]=schurOneMAPlattice2Abcd(k-delk,epsilon,p);
    delk=circshift(delk,1);
    HapP=Abcd2H(w(nc),AP,BP,CapP,DapP);
    HapM=Abcd2H(w(nc),AM,BM,CapM,DapM);
    est_dHapdk(l)=(HapP-HapM)/del;
  endfor
  max_abs_rel_diff_dHapdk=max(abs(est_dHapdk(l)-dHapdk(nc,l)) ...
                              ./abs(dHapdk(nc,l)));
  if verbose
    printf("max_abs_rel_diff_dHapdk = %g*tol\n",max_abs_rel_diff_dHapdk/tol);
  endif
  if max_abs_rel_diff_dHapdk > 100*tol
    error("max_abs_rel_diff_dHapdk(%g*tol) > 100*tol(%g)",
          max_abs_rel_diff_dHapdk/tol);
  endif

  %
  % Check d2Hdwdkc
  %
  [H,dHdw,dHdkc,d2Hdwdkc]=Abcd2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  % Exclude d2Hdwdkc(:,end) since d2HdwdD==0
  if any(any(abs(d2Hdwdkc(:,end))))
    error("any(any(abs(d2Hdwdkc(:,end))))");
  endif
  if any(any(abs(d2Hdwdkc(:,1:(end-1))))<tol)
    error("any(any(abs(d2Hdwdkc(:,1:(end-1)))<tol))");
  endif
  Nkc=length(dAdkc);
  Nk=rows(A);
  Nc=Nk+1;
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  delc=zeros(size(c));
  delc(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_d2Hdwdkc=zeros(1,Nkc-1);
  for l=1:Nkc
    if l<=Nk
      [AP,BP,CP,DP]=schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,CM,DM]=schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);
    else
      [AP,BP,CP,DP]=schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [AM,BM,CM,DM]=schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      delc=circshift(delc,1);
    endif
    [HP,dHdwP]=Abcd2H(w(nc),AP,BP,CP,DP);
    [HM,dHdwM]=Abcd2H(w(nc),AM,BM,CM,DM);
    if l<Nkc
      est_d2Hdwdkc(l)=(dHdwP-dHdwM)/del;
    else
      est_d2Hdwdkc_Nkc=(dHdwP-dHdwM)/del;
    endif
  endfor
  max_abs_rel_diff_d2Hdwdkc = ...
    max(abs(est_d2Hdwdkc-d2Hdwdkc(nc,1:(Nkc-1)))./abs(d2Hdwdkc(nc,1:(Nkc-1))));
  if verbose
    printf("max_abs_rel_diff_d2Hdwdkc = %g*tol\n",max_abs_rel_diff_d2Hdwdkc/tol);
  endif
  if max_abs_rel_diff_d2Hdwdkc > 200*tol
    error("max_abs_rel_diff_d2Hdwdkc(%g*tol) > 200*tol",
          max_abs_rel_diff_d2Hdwdkc/tol);
  endif
  if est_d2Hdwdkc_Nkc > eps
    error("est_d2Hdwdkc_Nkc(%g)>eps",est_d2Hdwdkc_Nkc);
  endif

  % Check d2Hapdwdk
  [Hap,dHapdw,dHapdk,d2Hapdwdk]= ...
    Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  if any(any(abs(d2Hapdwdk))<tol)
    error("any(any(abs(d2Hapdwdk)<tol))");
  endif
  Nk=rows(A);
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_d2Hapdwdk=zeros(1,Nk);
  for l=1:Nk
    [AP,BP,CapP,DapP]=schurOneMAPlattice2Abcd(k+delk,epsilon,p);
    [AM,BM,CapM,DapM]=schurOneMAPlattice2Abcd(k-delk,epsilon,p);
    delk=circshift(delk,1);
    [HapP,dHapdwP]=Abcd2H(w(nc),AP,BP,CapP,DapP);
    [HapM,dHapdwM]=Abcd2H(w(nc),AM,BM,CapM,DapM);
    est_d2Hapdwdk=(dHapdwP-dHapdwM)/del;
  endfor
  max_abs_rel_diff_d2Hapdwdk(l)= ...
    max(abs(est_d2Hapdwdk-d2Hapdwdk(nc,l))./abs(d2Hapdwdk(nc,l)));
  if verbose
    printf("max_abs_rel_diff_d2Hapdwdk = %g*tol\n",max_abs_rel_diff_d2Hapdwdk);
  endif
  if max_abs_rel_diff_d2Hapdwdk > 30*tol
    error("max_abs_rel_diff_d2Hapdwdk(%g*tol) > 30*tol",
          max_abs_rel_diff_d2Hapdwdk);
  endif

  %
  % Check diagd2Hdkc2
  %
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2]= ...
    Abcd2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc, ...
           d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  % Exclude diagd2Hdkc2(:,(Nk+1):end) since d2HdC2==0 and d2HdD2==0
  if any(any(abs(diagd2Hdkc2(:,(Nk+1):end))))
    error("any(any(diagd2Hdkc2(:,(Nk+1):end)))");
  endif
  if any(any(abs(diagd2Hdkc2(:,1:Nk)))<tol)
    error("any(any(abs(diagd2Hdkc2(:,1:Nk))<tol))");
  endif
  Nkc=length(dAdkc);
  Nk=rows(A);
  Nc=Nk+1;
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  delc=zeros(size(c));
  delc(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_diagd2Hdk2=zeros(1,Nk);
  est_diagd2Hdc2=zeros(1,Nc);
  for l=1:Nkc
    if l<=Nk
      [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
         schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
        schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);
    else
      [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
          schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
        schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      delc=circshift(delc,1);
    endif
    [HP,dHdwP,dHdkcP]=Abcd2H(w(nc),AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [HM,dHdwM,dHdkcM]=Abcd2H(w(nc),AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    if l<=Nk
      est_diagd2Hdk2(l)=(dHdkcP(l)-dHdkcM(l))/del;
    else
      est_diagd2Hdc2(l-Nk)=(dHdkcP(l)-dHdkcM(l))/del;
    endif
  endfor
  max_abs_rel_diff_diagd2Hdk2= ...
    max(abs(est_diagd2Hdk2-diagd2Hdkc2(nc,1:Nk))./abs(diagd2Hdkc2(nc,1:Nk)));
  if verbose
    printf("max_abs_rel_diff_diagd2Hdk2 = %g*tol\n",
           max_abs_rel_diff_diagd2Hdk2/tol);
  endif
  if max_abs_rel_diff_diagd2Hdk2 > 100*tol
    error("max_abs_rel_diff_diagd2Hdk2(%g*tol) > 100*tol",
          max_abs_rel_diff_diagd2Hdk2/tol);
  endif
  max_abs_diff_diagd2Hdc2= ...
    max(abs(est_diagd2Hdc2-diagd2Hdkc2(nc,(Nk+1):end)));
  if max_abs_diff_diagd2Hdc2 > eps
    error("max_abs_diff_diagd2Hdc2)(%g*eps)>eps", max_abs_diff_diagd2Hdc2/eps);
  endif

  % Check diagd2Hapdk2
  [Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2]=...
    Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  if any(any(abs(diagd2Hapdk2))<tol)
    error("any(any(abs(diagd2Hapdk2)<tol))");
  endif
  Nk=rows(A);
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_diagd2Hapdk2=zeros(1,Nk);
  for l=1:Nk
    [AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP]= ...
        schurOneMAPlattice2Abcd(k+delk,epsilon,p);
    [AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM]= ...
      schurOneMAPlattice2Abcd(k-delk,epsilon,p);
    delk=circshift(delk,1);
    [HapP,dHapdwP,dHapdkP]=Abcd2H(w(nc),AP,BP,CapP,DapP, ...
                                  dAdkP,dBdkP,dCapdkP,dDapdkP);
    [HapM,dHapdwM,dHapdkM]=Abcd2H(w(nc),AM,BM,CapM,DapM, ...
                                  dAdkM,dBdkM,dCapdkM,dDapdkM);
    est_d2Hapdk2(l)=(dHapdkP(l)-dHapdkM(l))/del;
  endfor
  max_abs_rel_diff_d2Hapdk2= ...
    max(abs(est_d2Hapdk2-diagd2Hapdk2(nc,:))./abs(diagd2Hapdk2(nc,:)));
  if verbose
    printf("max_abs_rel_diff_d2Hapdk2 = %g*tol\n",max_abs_rel_diff_d2Hapdk2/tol);
  endif
  if max_abs_rel_diff_d2Hapdk2 > 200*tol
    error("max_abs_rel_diff_d2Hapdk2(%g*tol) > 200*tol",
          max_abs_rel_diff_d2Hapdk2/tol);
  endif

  %
  % Check diagd3Hdwdkc2 with delw
  %
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2]=...
    Abcd2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  % Exclude diagd3Hdwdkc2(:,(Nk+1):end) since d2HdC2==0 and d2HdD2==0
  if any(any(abs(diagd3Hdwdkc2(:,(Nk+1):end))))
    error("any(any(abs(diagd3Hdwdkc2(_,(Nk+1)_end))))");
  endif
  if any(any(abs(diagd3Hdwdkc2(:,1:Nk))<tol))
    error("any(any(abs(diagd3Hdwdkc2(_,1_Nk))<tol))");
  endif
  Nkc=length(dAdkc);
  Nk=rows(A);
  Nc=Nk+1;
  del=tol;
  delw=del/2;
  nc=round((fc/0.5)*nplot);
  [HP,dHdwP,dHdkcP,d2HdwdkcP,diagd2Hdkc2P]=...
    Abcd2H(w(nc)+delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc, ...
           d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  [HM,dHdwM,dHdkcM,d2HdwdkcM,diagd2Hdkc2M]=...
    Abcd2H(w(nc)-delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc, ...
           d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  est_diagd3Hdwdk2(1:Nk)=(diagd2Hdkc2P(1:Nk)-diagd2Hdkc2M(1:Nk))/del;
  max_abs_rel_diff_diagd3Hdwdk2 = ...
    max(abs(est_diagd3Hdwdk2-diagd3Hdwdkc2(nc,1:Nk)) ...
        ./abs(diagd3Hdwdkc2(nc,1:Nk)));
  if verbose
    printf("max_abs_rel_diff_diagd3Hdwdk2 = %g*tol\n",
           max_abs_rel_diff_diagd3Hdwdk2/tol);
  endif
  if max_abs_rel_diff_diagd3Hdwdk2 > 10*tol
    error("max_abs_rel_diff_diagd3Hdwdk2(%g*tol) > 10*tol",
          max_abs_rel_diff_diagd3Hdwdk2/tol);
  endif
  est_diagd3Hdwdc2(1:Nc)=(diagd2Hdkc2P(Nk+(1:Nc))-diagd2Hdkc2M(Nk+(1:Nc)))/del;
  max_abs_est_diagd3Hdwdc2=max(abs(est_diagd3Hdwdc2));
  if max_abs_est_diagd3Hdwdc2 > eps
    error("max_abs_est_diagd3Hdwdc2(%g*eps)>eps",max_abs_est_diagd3Hdwdc2/eps);
  endif

  % Check diagd3Hdwdkc2 with delk and delc
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2]=...
    Abcd2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc, ...
           d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  Nkc=length(dAdkc);
  Nk=rows(A);
  Nc=Nk+1;
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  delc=zeros(size(c));
  delc(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_diagd3Hdwdk2=zeros(1,Nk);
  est_diagd3Hdwdc2=zeros(1,Nc);
  for l=1:Nkc
    if l<=Nk
      [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
         schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
        schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);
    else
      [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
          schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
        schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      delc=circshift(delc,1);
    endif
    [HP,dHdwP,dHdkcP,d2HdwdkcP]=Abcd2H(w(nc),AP,BP,CP,DP, ...
                                       dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [HM,dHdwM,dHdkcM,d2HdwdkcM]=Abcd2H(w(nc),AM,BM,CM,DM, ...
                                       dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    if l<=Nk
      est_diagd3Hdwdk2(l)=(d2HdwdkcP(l)-d2HdwdkcM(l))/del;
    else
      est_diagd3Hdwdc2(l-Nk)=(d2HdwdkcP(l)-d2HdwdkcM(l))/del;
    endif
  endfor
  max_abs_rel_diff_diagd3Hdwk2 = ...
    max(abs(est_diagd3Hdwdk2 - diagd3Hdwdkc2(nc,1:Nk)) ...
        ./abs(diagd3Hdwdkc2(nc,1:Nk)));
  if verbose
    printf("max_abs_rel_diff_diagd3Hdwdk2 = %g*tol\n",
           max_abs_rel_diff_diagd3Hdwdk2/tol);
  endif
  if max_abs_rel_diff_diagd3Hdwdk2 > 10*tol
    error("max_abs_rel_diff_diagd3Hdwdk2(%g*tol) > 10*tol",
          max_abs_rel_diff_diagd3Hdwdk2/tol);
  endif
  max_abs_diff_diagd3Hdwdc2 =  ...
    max(abs(est_diagd3Hdwdc2-diagd3Hdwdkc2(nc,(Nk+1):Nkc)));
  if max_abs_diff_diagd3Hdwdc2 > eps
    error("max_abs_diff_diagd3Hdwdc2(%g)>eps",max_abs_diff_dH3dwdc2/eps);
  endif

  % Check diagd3Hapdwdk2 with delw
  [Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2,diagd3Hapdwdk2]=...
    Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  % Avoid problematic values k(1:4)
  if any(any(abs(diagd3Hapdwdk2(:,5:end))<tol))
    error("any(any(abs(diagd3Hapdwdk2(_,5_end))<tol))");
  endif
  Nk=rows(A);
  del=tol;
  delw=del/2;
  nc=round((fc/0.5)*nplot);
  [HapP,dHapdwP,dHapdkP,d2HapdwdkP,diagd2Hapdk2P]=...
    Abcd2H(w(nc)+delw,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  [HapM,dHapdwM,dHapdkM,d2HapdwdkM,diagd2Hapdk2M]=...
    Abcd2H(w(nc)-delw,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  est_diagd3Hapdwdk2=(diagd2Hapdk2P-diagd2Hapdk2M)/del;
  max_abs_rel_diff_diagd3Hapdwdk2 = ...
    max(abs(est_diagd3Hapdwdk2(5:Nk) - ...
            diagd3Hapdwdk2(nc,5:Nk))./abs(diagd3Hapdwdk2(nc,5:Nk)));
  if verbose
    printf("max_abs_rel_diff_diagd3Hapdwdk2 = %g*tol\n",
           max_abs_rel_diff_diagd3Hapdwdk2/tol);
  endif
  if max_abs_rel_diff_diagd3Hapdwdk2 > 5*tol
    error("max_abs_rel_diff_diagd3Hapdwdk2(%g*tol) > 5*tol",
          max_abs_rel_diff_diagd3Hapdwdk2/tol);
  endif

  % Check diagd3Hapdwdk2 with delk
  [Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2,diagd3Hapdwdk2]=...
    Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  Nk=rows(A);
  del=tol;
  delk=zeros(size(k));
  delk(1)=del/2;
  nc=round((fc/0.5)*nplot);
  est_diagd3Hapdwdk2=zeros(1,Nk);
  for l=1:Nk
    [AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP]= ...
        schurOneMAPlattice2Abcd(k+delk,epsilon,p);
    [AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM]= ...
      schurOneMAPlattice2Abcd(k-delk,epsilon,p);
    delk=circshift(delk,1);
    [HapP,dHapdwP,dHapdkP,d2HapdwdkP]=Abcd2H(w(nc),AP,BP,CapP,DapP, ...
                                             dAdkP,dBdkP,dCapdkP,dDapdkP);
    [HapM,dHapdwM,dHapdkM,d2HapdwdkM]=Abcd2H(w(nc),AM,BM,CapM,DapM, ...
                                             dAdkM,dBdkM,dCapdkM,dDapdkM);
    est_diagd3Hapdwdk2(l)=(d2HapdwdkP(l)-d2HapdwdkM(l))/del;
  endfor
  max_abs_rel_diff_diagd3Hapdwdk2= ...
    max(abs(est_diagd3Hapdwdk2(5:Nk)-diagd3Hapdwdk2(nc,5:Nk)) ...
        ./abs(diagd3Hapdwdk2(nc,5:Nk)));
  if verbose
    printf("max_abs_rel_diff_diagd3Hapdwdk2 = %g*tol\n",
           max_abs_rel_diff_diagd3Hapdwdk2/tol);
  endif
  if max_abs_rel_diff_diagd3Hapdwdk2 > 20*tol
    error("max_abs_rel_diff_diagd3Hapdwdk2(%g*tol) > 20*tol",
          max_abs_rel_diff_diagd3Hapdwdk2/tol);
  endif

  %
  % Check d2Hapdxdy
  %
  % Check d2Hapdkdk with delk
  [Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2,diagd3Hapdwdk2,d2Hapdkdk]= ...
    Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  Nkc=length(dAdkc);
  Nk=rows(A);
  Nc=Nk+1;
  nc=round((fc/0.5)*nplot);
  wc=w(nc);
  del=1e-6;
  delk=zeros(size(k));
  delk(1)=del/2;
  est_d2Hdkdk=zeros(Nk,Nk);
  for l=1:Nk
    for m=1:Nk
      [AP,BP,~,~,CapP,DapP,dAdkP,dBdkP,~,~,dCapdkP,dDapdkP]= ...
          schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,~,~,CapM,DapM,dAdkM,dBdkM,~,~,dCapdkM,dDapdkM]= ...
        schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);

      [HapP,dHapdwP,dHapdkP]= ...
        Abcd2H(wc,AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP);
      [HapM,dHapdwM,dHapdkM]= ...
        Abcd2H(wc,AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM);
      est_d2Hapdkdk(l,m)=(dHapdkP(l)-dHapdkM(l))/del;
    endfor
  endfor
  max_abs_rel_diff_d2Hapdkdk = ...
    max(max(abs((est_d2Hapdkdk-squeeze(d2Hapdkdk(nc,1:Nk,1:Nk))) ...
                ./squeeze(d2Hapdkdk(nc,1:Nk,1:Nk)))));
  if verbose
    printf("max_abs_rel_diff_d2Hapdkdk = %g*del\n",
           max_abs_rel_diff_d2Hapdkdk/del);
  endif
  if max_abs_rel_diff_d2Hapdkdk > 200*del
    error("max_abs_rel_diff_d2Hapdkdk(%g*del) > 200*del",
          max_abs_rel_diff_d2Hapdkdk/del);
  endif

  %
  % Check the partial derivative of d2Hapdkdk wrt w
  %
  Nk=rows(A);
  del=1e-6;
  est_d3Hdwdydx=zeros(Nk,Nk);
  nc=round((fc/0.5)*nplot);
  wc=w(nc);
  wt=w([nc,250:50:Nw]);
  [Hap,dHapdw,dHapdk,d2Hapdwdk, ...
   diagd2Hapdk2,diagd3Hapdwdk2,d2Hapdkdk,d3Hapdwdkdk] = ...
    Abcd2H(wt,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  % Check d3Hdwdkdk is symmetric
  [l,m,n]=size(d3Hapdwdkdk);
  for v=1:l,
    if ~issymmetric(squeeze(d3Hapdwdkdk(v,:,:)),1e3*eps)
      error("d3Hapdwdkdk(v,:,:) is not symmetric");
    endif
  endfor
  delw=del/2;
  for l=1:length(wt)
    [~,~,~,~,~,~,d2HapdkdkP] = ...
        Abcd2H(wt(l)+delw,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
               d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
    [~,~,~,~,~,~,d2HapdkdkM] = ...
      Abcd2H(wt(l)-delw,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
             d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
    
    est_d3Hapdwdkdk=squeeze(d2HapdkdkP-d2HapdkdkM)/del;
    max_abs_rel_diff_d3Hapdwdkdk= ...
      max(max(abs((est_d3Hapdwdkdk-squeeze(d3Hapdwdkdk(l,1:Nk,1:Nk))) ...
                  ./squeeze(d3Hapdwdkdk(l,1:Nk,1:Nk)))));
    if verbose
      printf("max_abs_rel_diff_d3Hapdwdkdk = del/%g\n",
             max_abs_rel_diff_d3Hapdwdkdk/del);
    endif
    if max_abs_rel_diff_d3Hapdwdkdk > del/2
      error("max_abs_rel_diff_d3Hapdwdkdk (del/%g) > del/2",
            del/max_abs_rel_diff_d3Hapdwdkdk);
    endif
  endfor

  % Check the derivative of d2Hapdwdk wrt k
  nc=round((fc/0.5)*nplot);
  wc=w(nc);
  [~,~,~,~,~,~,~,d3Hapdwdkdk] = ...
    Abcd2H(wc,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
           d2Adkdk,d2Bdkdk,d2Capdkdk,d2Dapdkdk);
  del=1e-6;
  delk=zeros(size(k));
  delk(1)=del/2;
  est_d3Hdwdydx=zeros(Nk,Nk);
  for l=1:Nk
    for m=1:Nk
      [AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP] = ...
          schurOneMAPlattice2Abcd(k+delk,epsilon,p);
      [AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM] = ...
        schurOneMAPlattice2Abcd(k-delk,epsilon,p);
      delk=circshift(delk,1);
      
      [~,~,~,d2HapdwdkP]=Abcd2H(wc,AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP);
      [~,~,~,d2HapdwdkM]=Abcd2H(wc,AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM);
      est_d3Hapdwdkdk(l,m)=(d2HapdwdkP(l)-d2HapdwdkM(l))/del;
    endfor
  endfor
  max_abs_rel_diff_d3Hapdwdkdk= ...
    max(max(abs((est_d3Hapdwdkdk - squeeze(d3Hapdwdkdk(1,1:Nk,1:Nk))) ...
                ./squeeze(d3Hapdwdkdk(1,1:Nk,1:Nk)))));
  if verbose
    printf("max_abs_rel_diff_d3Hapdwdkdk = del/%g\n",
           del/max_abs_rel_diff_d3Hapdwdkdk);
  endif
  if max_abs_rel_diff_d3Hapdwdkdk > del/20
    error("max_abs_rel_diff_d3Hapdwdkdk (del/%g) > del/20",
          del/max_abs_rel_diff_d3Hapdwdkdk);
  endif
endfor

%
% Repeat for the globally optimised state variable filter with 256 coefficients.
%
N=15;fc=0.1;
[n,d]=butter(N,2*fc);
nplot=1024;
[h,w]=freqz(n,d,nplot);
[A,B,C,D]=tf2Abcd(n,d);
[K,W]=KW(A,B,C,D);
delta=4;
[Topt,Kopt,Wopt]=optKW(K,W,delta);
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;

% Check H
Hopt=Abcd2H(w,Aopt,Bopt,Copt,Dopt);
if max(abs(h-Hopt)) > 2*tol
  error("max(abs(h-Hopt))(%g*tol) > 2*tol",max(abs(h-Hopt))/tol);
endif

% Check dHdw
[Hopt,dHoptdw]=Abcd2H(w,Aopt,Bopt,Copt,Dopt);
del=tol;
delw=del/2;
diff_Hoptw=zeros(1,nplot);
HoptP=Abcd2H(w+delw,Aopt,Bopt,Copt,Dopt);
HoptM=Abcd2H(w-delw,Aopt,Bopt,Copt,Dopt);
diff_Hoptw=abs(((HoptP-HoptM)/del)-dHoptdw);
if max(diff_Hoptw) > 200*tol
  error("max(abs(((HoptP-HoptM)/del)-dHoptdw))(%g*tol) > 200*tol",
        max(diff_Hoptw)/tol);
endif

% Check dHoptdx
% Initialise derivative arrays
Nr=rows(Aopt);
Nc=columns(Aopt);
dAoptdx=cell(1,(Nr+1)*(Nc+1));
dBoptdx=cell(size(dAoptdx));
dCoptdx=cell(size(dAoptdx));
dDoptdx=cell(size(dAoptdx));
for l=1:Nr
  for m=1:Nc
    dAoptdx{m+(Nr*(l-1))}=zeros(Nr,Nc);
    dAoptdx{m+(Nr*(l-1))}(l,m)=1;
    dBoptdx{m+(Nr*(l-1))}=zeros(Nr,1);
    dCoptdx{m+(Nr*(l-1))}=zeros(1,Nc);
    dDoptdx{m+(Nr*(l-1))}=0;
  endfor
endfor
for l=1:Nr
  dAoptdx{l+(Nc*Nr)}=zeros(Nr,Nc);
  dBoptdx{l+(Nc*Nr)}=zeros(Nr,1);
  dBoptdx{l+(Nc*Nr)}(l)=1;
  dCoptdx{l+(Nc*Nr)}=zeros(1,Nc);
  dDoptdx{l+(Nc*Nr)}=0;
endfor
for l=1:Nc
  dAoptdx{l+(Nc*Nr)+Nr}=zeros(Nr,Nc);
  dBoptdx{l+(Nc*Nr)+Nr}=zeros(Nr,1);
  dCoptdx{l+(Nc*Nr)+Nr}=zeros(1,Nc);
  dCoptdx{l+(Nc*Nr)+Nr}(l)=1;
  dDoptdx{l+(Nc*Nr)+Nr}=0+j*0;
endfor
dAoptdx{(Nc*Nr)+Nr+Nc+1}=zeros(Nr,Nc);
dBoptdx{(Nc*Nr)+Nr+Nc+1}=zeros(Nr,1);
dCoptdx{(Nc*Nr)+Nr+Nc+1}=zeros(1,Nc);
dDoptdx{(Nc*Nr)+Nr+Nc+1}=1;
% Exact result
[Hopt,dHoptdw,dHoptdx]=Abcd2H(w,Aopt,Bopt,Copt,Dopt,...
                              dAoptdx,dBoptdx,dCoptdx,dDoptdx);
% Aopt
del=tol;
diff_Hoptx=zeros(1,length(dAoptdx));
nc=round((fc/0.5)*nplot);
for l=1:Nr
  for m=1:Nc
    AoptP=Aopt;
    AoptP(l,m)=AoptP(l,m)+(del/2);
    AoptM=Aopt;
    AoptM(l,m)=AoptM(l,m)-(del/2);
    HoptP=Abcd2H(w(nc),AoptP,Bopt,Copt,Dopt);
    HoptM=Abcd2H(w(nc),AoptM,Bopt,Copt,Dopt);
    diff_Hoptx(m+(Nc*(l-1)))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,m+(Nc*(l-1))));
  endfor
endfor
% Bopt
for l=1:Nr
  BoptP=Bopt;
  BoptP(l)=BoptP(l)+(del/2);
  BoptM=Bopt;
  BoptM(l)=BoptM(l)-(del/2);
  HoptP=Abcd2H(w(nc),Aopt,BoptP,Copt,Dopt);
  HoptM=Abcd2H(w(nc),Aopt,BoptM,Copt,Dopt);
  diff_Hoptx(l+(Nc*Nr))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,l+(Nc*Nr)));
endfor
% Copt
for m=1:Nc
  CoptP=Copt;
  CoptP(m)=CoptP(m)+(del/2);
  CoptM=Copt;
  CoptM(m)=CoptM(m)-(del/2);
  HoptP=Abcd2H(w(nc),Aopt,Bopt,CoptP,Dopt);
  HoptM=Abcd2H(w(nc),Aopt,Bopt,CoptM,Dopt);
  diff_Hoptx(m+Nr+(Nc*Nr))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,m+Nr+(Nc*Nr)));
endfor
% Dopt
DoptP=Dopt+(del/2);
DoptM=Dopt-(del/2);
HoptP=Abcd2H(w(nc),Aopt,Bopt,Copt,DoptP);
HoptM=Abcd2H(w(nc),Aopt,Bopt,Copt,DoptM);
diff_Hoptx(1+Nc+Nr+(Nc*Nr))=abs(((HoptP-HoptM)/del)- ...
                                dHoptdx(nc,1+Nc+Nr+(Nc*Nr)));
% Check dHoptdx
if max(diff_Hoptx) > 200*tol
  error("max(abs(((HoptP-HoptM)/del)-dHoptdx(nc,_)));)(%g*tol) > 200*tol",
        max(diff_Hoptx)/tol);
endif

% Check d2Hoptdwdx
[Hopt,dHoptdw,dHoptdx,d2Hoptdwdx]=Abcd2H(w,Aopt,Bopt,Copt,Dopt, ...
                                         dAoptdx,dBoptdx,dCoptdx,dDoptdx);
del=tol;
delw=del/2;
diff_dHoptdx=zeros(1,nplot);
[HoptP,dHoptdwP,dHoptdxP]=Abcd2H(w+delw,Aopt,Bopt,Copt,Dopt, ...
                                 dAoptdx,dBoptdx,dCoptdx,dDoptdx);
[HoptM,dHoptdwM,dHoptdxM]=Abcd2H(w-delw,Aopt,Bopt,Copt,Dopt,...
                                 dAoptdx,dBoptdx,dCoptdx,dDoptdx);
diff_dHoptdx=abs(((dHoptdxP-dHoptdxM)/del)-d2Hoptdwdx);
if max(max(diff_dHoptdx)) > 2000*tol
  error(["max(max(abs(((dHoptdxP-dHoptdxM)/del)-d2Hoptdwdx))", ...
 "(%g*tol) > 2000*tol"], max(max(diff_dHoptdx))/tol);
endif

% Check diagd2Hoptdx2
[Hopt,dHoptdw,dHoptdx,d2Hoptdwdx,diagd2Hoptdx2]=...
  Abcd2H(w(nc),Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
% Aopt
del=tol;
diff_dHoptdx=zeros(1,length(dAoptdx));
nc=round((fc/0.5)*nplot);
for l=1:Nr
  for m=1:Nc
    AoptP=Aopt;
    AoptP(l,m)=AoptP(l,m)+(del/2);
    AoptM=Aopt;
    AoptM(l,m)=AoptM(l,m)-(del/2);
    [HoptP,dHoptdwP,dHoptdxP]=Abcd2H(w(nc),AoptP,Bopt,Copt,Dopt,...
                                     dAoptdx,dBoptdx,dCoptdx,dDoptdx);
    [HoptM,dHoptdwM,dHoptdxM]=Abcd2H(w(nc),AoptM,Bopt,Copt,Dopt,...
                                     dAoptdx,dBoptdx,dCoptdx,dDoptdx);
    diff_dHoptdx(m+(Nc*(l-1)))=...
      abs(((dHoptdxP(m+(Nc*(l-1)))-dHoptdxM(m+(Nc*(l-1))))/del)-...
          diagd2Hoptdx2(m+(Nc*(l-1))));
  endfor
endfor
% Bopt
for l=1:Nr
  BoptP=Bopt;
  BoptP(l)=BoptP(l)+(del/2);
  BoptM=Bopt;
  BoptM(l)=BoptM(l)-(del/2);
  [HoptP,dHoptdwP,dHoptdxP]=Abcd2H(w(nc),Aopt,BoptP,Copt,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  [HoptM,dHoptdwM,dHoptdxM]=Abcd2H(w(nc),Aopt,BoptM,Copt,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  diff_dHoptdx(l+(Nc*Nr))=...
    abs(((dHoptdxP(l+(Nc*Nr))-dHoptdxM(l+(Nc*Nr)))/del)-...
        diagd2Hoptdx2(l+(Nc*Nr)));
endfor
% Copt
for m=1:Nc
  CoptP=Copt;
  CoptP(m)=CoptP(m)+(del/2);
  CoptM=Copt;
  CoptM(m)=CoptM(m)-(del/2);
  [HoptP,dHoptdwP,dHoptdxP]=Abcd2H(w(nc),Aopt,Bopt,CoptP,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  [HoptM,dHoptdwM,dHoptdxM]=Abcd2H(w(nc),Aopt,Bopt,CoptM,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  diff_dHoptdx(m+Nr+(Nc*Nr))=...
    abs(((dHoptdxP(m+Nr+(Nc*Nr))-dHoptdxM(m+Nr+(Nc*Nr)))/del)-...
        diagd2Hoptdx2(m+Nr+(Nc*Nr)));
endfor
% Dopt
DoptP=Dopt+(del/2);
DoptM=Dopt-(del/2);
[HoptP,dHoptdwP,dHoptdxP]=Abcd2H(w(nc),Aopt,Bopt,Copt,DoptP,...
                                 dAoptdx,dBoptdx,dCoptdx,dDoptdx);
[HoptM,dHoptdwM,dHoptdxM]=Abcd2H(w(nc),Aopt,Bopt,Copt,DoptM,...
                                 dAoptdx,dBoptdx,dCoptdx,dDoptdx);
diff_dHoptdx(1+Nc+Nr+(Nc*Nr))=...
  abs(((dHoptdxP(1+Nc+Nr+(Nc*Nr))-dHoptdxM(1+Nc+Nr+(Nc*Nr)))/del)-...
      diagd2Hoptdx2(1+Nc+Nr+(Nc*Nr)));
% Check d2Hoptdx2
if max(diff_dHoptdx) > 500*tol
  error(["max(abs(((dHoptdxP-dHoptdxM)/del)-diagd2Hoptdx2));)", ...
 "(%g*tol) > 500*tol"],max(diff_dHoptdx)/tol);
endif

% Check diagd3Hoptdwdx2
[Hopt,dHoptdw,dHoptdx,d2Hoptdwdx,diagd2Hoptdx2,diagd3Hoptdwdx2]=...
  Abcd2H(w(nc),Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
del=tol;
delw=del/2;
diff_dHoptdx=zeros(1,nplot);
[HoptP,dHoptdwP,dHoptdxP,d2HoptdwdxP,diagd2Hoptdx2P]=...
  Abcd2H(w(nc)+delw,Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
[HoptM,dHoptdwM,dHoptdxM,d2HoptdwdxM,diagd2Hoptdx2M]=...
  Abcd2H(w(nc)-delw,Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
diff_diagd2Hoptdx2=abs(((diagd2Hoptdx2P-diagd2Hoptdx2M)/del)-diagd3Hoptdwdx2);
if max(diff_diagd2Hoptdx2) > 25000*tol
  error(["max(abs(((diagd2Hoptdx2P-diagd2Hoptdx2M)/del)-", ...
 "diagd3Hoptdwdx2(nc,_)))(%g*tol) > 25000*tol"],
        max(max(diff_diagd2Hoptdx2))/tol);
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
