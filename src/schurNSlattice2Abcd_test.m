% schurNSlattice2Abcd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("schurNSlattice2Abcd_test.diary");
delete("schurNSlattice2Abcd_test.diary.tmp");
diary schurNSlattice2Abcd_test.diary.tmp

check_octave_file("schurNSlattice2Abcd");

verbose=true;

%
% Test for 6 arguments: s10,s11,s20,s02,s00,s22
%
for x=1:3
  % Design filter transfer function
  if x==1
    N=20;dbap=0.1;dbas=80;fc=0.1;
    [n,d]=cheby2(N,dbas,2*fc);
  elseif x==2
    N=2;fc=0.1;
    [n,d]=butter(N,2*fc);
  else
    N=1;fc=0.1;
    [n,d]=butter(N,2*fc);
  endif

  % Convert filter transfer function to lattice form
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  Ns=length(s10);
  [A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);

  % Check [A,B,C,D]
  [check_n,check_d]=Abcd2tf(A,B,C,D);
  if max(abs(check_n-n))/eps > 102.13
    error("max(abs(check_n-n))/eps > 102.13");
  endif
  if max(abs(check_d-d))/eps > 4096
    error("max(abs(check_d-d))/eps > 4096");
  endif

  % Check [A,B,Cap,Dap]
  [check_nap,check_dap]=Abcd2tf(A,B,Cap,Dap);
  if max(abs(fliplr(check_nap)-d))/eps > 2048
    error("max(abs(fliplr(check_nap)-d))/eps > 2048");
  endif
  if max(abs(check_dap-d))/eps > 4096
    error("max(abs(check_dap-d))/eps > 4096");
  endif

  % Calculate differentials of A,B,C,D,Cap,Dap with respect to s
  [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
    schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
  % A
  dAds10=cell(size(s10));
  dAds11=cell(size(s11));
  dAds20=cell(size(s20));
  dAds00=cell(size(s00));
  dAds02=cell(size(s02));
  dAds22=cell(size(s22));
  for l=1:Ns
    dAds10{l}=dAds{((l-1)*6)+1};
    dAds11{l}=dAds{((l-1)*6)+2};
    dAds20{l}=dAds{((l-1)*6)+3};
    dAds00{l}=dAds{((l-1)*6)+4};
    dAds02{l}=dAds{((l-1)*6)+5};
    dAds22{l}=dAds{((l-1)*6)+6};
  endfor
  % B
  dBds10=cell(size(s10));
  dBds11=cell(size(s11));
  dBds20=cell(size(s20));
  dBds00=cell(size(s00));
  dBds02=cell(size(s02));
  dBds22=cell(size(s22));
  for l=1:Ns
    dBds10{l}=dBds{((l-1)*6)+1};
    dBds11{l}=dBds{((l-1)*6)+2};
    dBds20{l}=dBds{((l-1)*6)+3};
    dBds00{l}=dBds{((l-1)*6)+4};
    dBds02{l}=dBds{((l-1)*6)+5};
    dBds22{l}=dBds{((l-1)*6)+6};
  endfor
  % C
  dCds10=cell(size(s10));
  dCds11=cell(size(s11));
  dCds20=cell(size(s20));
  dCds00=cell(size(s00)); 
  dCds02=cell(size(s02));
  dCds22=cell(size(s22));
  for l=1:Ns
    dCds10{l}=dCds{((l-1)*6)+1};
    dCds11{l}=dCds{((l-1)*6)+2};
    dCds20{l}=dCds{((l-1)*6)+3};
    dCds00{l}=dCds{((l-1)*6)+4};
    dCds02{l}=dCds{((l-1)*6)+5};
    dCds22{l}=dCds{((l-1)*6)+6};
  endfor
  % D
  dDds10=cell(size(s10));
  dDds11=cell(size(s11));
  dDds20=cell(size(s20));
  dDds00=cell(size(s00));
  dDds02=cell(size(s02));
  dDds22=cell(size(s22));
  for l=1:Ns
    dDds10{l}=dDds{((l-1)*6)+1};
    dDds11{l}=dDds{((l-1)*6)+2};
    dDds20{l}=dDds{((l-1)*6)+3};
    dDds00{l}=dDds{((l-1)*6)+4};
    dDds02{l}=dDds{((l-1)*6)+5};
    dDds22{l}=dDds{((l-1)*6)+6};
  endfor
  % Cap
  dCapds10=cell(size(s10));
  dCapds11=cell(size(s11));
  dCapds20=cell(size(s20));
  dCapds00=cell(size(s00)); 
  dCapds02=cell(size(s02));
  dCapds22=cell(size(s22));
  for l=1:Ns
    dCapds10{l}=dCapds{((l-1)*6)+1};
    dCapds11{l}=dCapds{((l-1)*6)+2};
    dCapds20{l}=dCapds{((l-1)*6)+3};
    dCapds00{l}=dCapds{((l-1)*6)+4};
    dCapds02{l}=dCapds{((l-1)*6)+5};
    dCapds22{l}=dCapds{((l-1)*6)+6};
  endfor
  % Dap
  dDapds10=cell(size(s10));
  dDapds11=cell(size(s11));
  dDapds20=cell(size(s20));
  dDapds00=cell(size(s00));
  dDapds02=cell(size(s02));
  dDapds22=cell(size(s22));
  for l=1:Ns
    dDapds10{l}=dDapds{((l-1)*6)+1};
    dDapds11{l}=dDapds{((l-1)*6)+2};
    dDapds20{l}=dDapds{((l-1)*6)+3};
    dDapds00{l}=dDapds{((l-1)*6)+4};
    dDapds02{l}=dDapds{((l-1)*6)+5};
    dDapds22{l}=dDapds{((l-1)*6)+6};
  endfor

  % Check the differentials of A,B,C,D,Cap,Dap with respect to s
  if x==1
    del=1e-8;
    tol=2.5*del;
  else
    del=1e-8;
    tol=del;
  endif
  dels=zeros(1,Ns);
  dels(1)=del/2;
  dAds10_max_err=zeros(size(dels));
  dAds11_max_err=zeros(size(dels));
  dAds20_max_err=zeros(size(dels));
  dAds00_max_err=zeros(size(dels));
  dAds02_max_err=zeros(size(dels));
  dAds22_max_err=zeros(size(dels));
  dBds10_max_err=zeros(size(dels));
  dBds11_max_err=zeros(size(dels));
  dBds20_max_err=zeros(size(dels));
  dBds00_max_err=zeros(size(dels));
  dBds02_max_err=zeros(size(dels));
  dBds22_max_err=zeros(size(dels));
  dCds10_max_err=zeros(size(dels));
  dCds11_max_err=zeros(size(dels));
  dCds20_max_err=zeros(size(dels));
  dCds00_max_err=zeros(size(dels));
  dCds02_max_err=zeros(size(dels));
  dCds22_max_err=zeros(size(dels));
  dDds10_max_err=zeros(size(dels));
  dDds11_max_err=zeros(size(dels));
  dDds20_max_err=zeros(size(dels));
  dDds00_max_err=zeros(size(dels));
  dDds02_max_err=zeros(size(dels));
  dDds22_max_err=zeros(size(dels));
  dCapds10_max_err=zeros(size(dels));
  dCapds11_max_err=zeros(size(dels));
  dCapds20_max_err=zeros(size(dels));
  dCapds00_max_err=zeros(size(dels));
  dCapds02_max_err=zeros(size(dels));
  dCapds22_max_err=zeros(size(dels));
  dDapds10_max_err=zeros(size(dels));
  dDapds11_max_err=zeros(size(dels));
  dDapds20_max_err=zeros(size(dels));
  dDapds00_max_err=zeros(size(dels));
  dDapds02_max_err=zeros(size(dels));
  dDapds22_max_err=zeros(size(dels));
  for l=1:Ns
    % s10
    [AP10,BP10,CP10,DP10,CapP10,DapP10]=...
      schurNSlattice2Abcd(s10+dels,s11,s20,s00,s02,s22);
    [AM10,BM10,CM10,DM10,CapM10,DapM10]=...
      schurNSlattice2Abcd(s10-dels,s11,s20,s00,s02,s22);
    dAds10_max_err(l)=max(max(abs(((AP10-AM10)/del)-dAds10{l})));
    if dAds10_max_err(l) > tol
      error("dAds10_max_err(%d) > %g",l,tol);
    endif
    dBds10_max_err(l)=max(abs(((BP10-BM10)/del)-dBds10{l}));
    if dBds10_max_err(l) > tol
      error("dBds10_max_err(%d) > %g",l,tol);
    endif
    dCds10_max_err(l)=max(abs(((CP10-CM10)/del)-dCds10{l}));
    if dCds10_max_err(l) > tol
      error("dCds10_max_err(%d) > %g",l,tol);
    endif
    dDds10_max_err(l)=max(abs(((DP10-DM10)/del)-dDds10{l}));
    if dDds10_max_err(l) > tol
      error("dDds10_max_err(%d) > %g",l,tol);
    endif
    dCapds10_max_err(l)=max(abs(((CapP10-CapM10)/del)-dCapds10{l}));
    if dCapds10_max_err(l) > tol
      error("dCapds10_max_err(%d) > %g",l,tol);
    endif
    dDapds10_max_err(l)=max(abs(((DapP10-DapM10)/del)-dDapds10{l}));
    if dDapds10_max_err(l) > tol
      error("dDapds10_max_err(%d) > %g",l,tol);
    endif
    % s11
    [AP11,BP11,CP11,DP11,CapP11,DapP11]=...
      schurNSlattice2Abcd(s10,s11+dels,s20,s00,s02,s22);
    [AM11,BM11,CM11,DM11,CapM11,DapM11]=...
      schurNSlattice2Abcd(s10,s11-dels,s20,s00,s02,s22);
    dAds11_max_err(l)=max(max(abs(((AP11-AM11)/del)-dAds11{l})));
    if dAds11_max_err(l) > tol
      error("dAds11_max_err(%d) > %g",l,tol);
    endif
    dBds11_max_err(l)=max(abs(((BP11-BM11)/del)-dBds11{l}));
    if dBds11_max_err(l) > tol
      error("dBds11_max_err(%d) > %g",l,tol);
    endif
    dCds11_max_err(l)=max(abs(((CP11-CM11)/del)-dCds11{l}));
    if dCds11_max_err(l) > tol
      error("dCds11_max_err(%d) > %g",l,tol);
    endif
    dDds11_max_err(l)=max(abs(((DP11-DM11)/del)-dDds11{l}));
    if dDds11_max_err(l) > tol
      error("dDds11_max_err(%d) > %g",l,tol);
    endif
    dCapds11_max_err(l)=max(abs(((CapP11-CapM11)/del)-dCapds11{l}));
    if dCapds11_max_err(l) > tol
      error("dCapds11_max_err(%d) > %g",l,tol);
    endif
    dDapds11_max_err(l)=max(abs(((DapP11-DapM11)/del)-dDapds11{l}));
    if dDapds11_max_err(l) > tol
      error("dDapds11_max_err(%d) > %g",l,tol);
    endif
    % s20
    [AP20,BP20,CP20,DP20,CapP20,DapP20]=...
      schurNSlattice2Abcd(s10,s11,s20+dels,s00,s02,s22);
    [AM20,BM20,CM20,DM20,CapM20,DapM20]=...
      schurNSlattice2Abcd(s10,s11,s20-dels,s00,s02,s22);
    dAds20_max_err(l)=max(max(abs(((AP20-AM20)/del)-dAds20{l})));
    if dAds20_max_err(l) > tol
      error("dAds20_max_err(%d) > %g",l,tol);
    endif
    dBds20_max_err(l)=max(abs(((BP20-BM20)/del)-dBds20{l}));
    if dBds20_max_err(l) > tol
      error("dBds20_max_err(%d) > %g",l,tol);
    endif
    dCds20_max_err(l)=max(abs(((CP20-CM20)/del)-dCds20{l}));
    if dCds20_max_err(l) > tol
      error("dCds20_max_err(%d) > %g",l,tol);
    endif
    dDds20_max_err(l)=max(abs(((DP20-DM20)/del)-dDds20{l}));
    if dDds20_max_err(l) > tol
      error("dDds20_max_err(%d) > %g",l,tol);
    endif
    dCapds20_max_err(l)=max(abs(((CapP20-CapM20)/del)-dCapds20{l}));
    if dCapds20_max_err(l) > tol
      error("dCapds20_max_err(%d) > %g",l,tol);
    endif
    dDapds20_max_err(l)=max(abs(((DapP20-DapM20)/del)-dDapds20{l}));
    if dDapds20_max_err(l) > tol
      error("dDapds20_max_err(%d) > %g",l,tol);
    endif
    % s00
    [AP00,BP00,CP00,DP00,CapP00,DapP00]=...
      schurNSlattice2Abcd(s10,s11,s20,s00+dels,s02,s22);
    [AM00,BM00,CM00,DM00,CapM00,DapM00]=...
      schurNSlattice2Abcd(s10,s11,s20,s00-dels,s02,s22);
    dAds00_max_err(l)=max(max(abs(((AP00-AM00)/del)-dAds00{l})));
    if dAds00_max_err(l) > tol
      error("dAds00_max_err(%d) > %g",l,tol);
    endif
    dBds00_max_err(l)=max(abs(((BP00-BM00)/del)-dBds00{l}));
    if dBds00_max_err(l) > tol
      error("dBds00_max_err(%d) > %g",l,tol);
    endif
    dCds00_max_err(l)=max(abs(((CP00-CM00)/del)-dCds00{l}));
    if dCds00_max_err(l) > tol
      error("dCds00_max_err(%d) > %g",l,tol);
    endif
    dDds00_max_err(l)=max(abs(((DP00-DM00)/del)-dDds00{l}));
    if dDds00_max_err(l) > tol
      error("dDds00_max_err(%d) > %g",l,tol);
    endif
    dCapds00_max_err(l)=max(abs(((CapP00-CapM00)/del)-dCapds00{l}));
    if dCapds00_max_err(l) > tol
      error("dCapds00_max_err(%d) > %g",l,tol);
    endif
    dDapds00_max_err(l)=max(abs(((DapP00-DapM00)/del)-dDapds00{l}));
    if dDapds00_max_err(l) > tol
      error("dDapds00_max_err(%d) > %g",l,tol);
    endif
    % s02
    [AP02,BP02,CP02,DP02,CapP02,DapP02]=...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02+dels,s22);
    [AM02,BM02,CM02,DM02,CapM02,DapM02]=...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02-dels,s22);
    dAds02_max_err(l)=max(max(abs(((AP02-AM02)/del)-dAds02{l})));
    if dAds02_max_err(l) > tol
      error("dAds02_max_err(%d) > %g",l,tol);
    endif
    dBds02_max_err(l)=max(abs(((BP02-BM02)/del)-dBds02{l}));
    if dBds02_max_err(l) > tol
      error("dBds02_max_err(%d) > %g",l,tol);
    endif
    dCds02_max_err(l)=max(abs(((CP02-CM02)/del)-dCds02{l}));
    if dCds02_max_err(l) > tol
      error("dCds02_max_err(%d) > %g",l,tol);
    endif
    dDds02_max_err(l)=max(abs(((DP02-DM02)/del)-dDds02{l}));
    if dDds02_max_err(l) > tol
      error("dDds02_max_err(%d) > %g",l,tol);
    endif
    dCapds02_max_err(l)=max(abs(((CapP02-CapM02)/del)-dCapds02{l}));
    if dCapds02_max_err(l) > tol
      error("dCapds02_max_err(%d) > %g",l,tol);
    endif
    dDapds02_max_err(l)=max(abs(((DapP02-DapM02)/del)-dDapds02{l}));
    if dDapds02_max_err(l) > tol
      error("dDapds02_max_err(%d) > %g",l,tol);
    endif
    % s22
    [AP22,BP22,CP22,DP22,CapP22,DapP22]=...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22+dels);
    [AM22,BM22,CM22,DM22,CapM22,DapM22]=...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22-dels);
    dAds22_max_err(l)=max(max(abs(((AP22-AM22)/del)-dAds22{l})));
    if dAds22_max_err(l) > tol
      error("dAds22_max_err(%d) > %g",l,tol);
    endif
    dBds22_max_err(l)=max(abs(((BP22-BM22)/del)-dBds22{l}));
    if dBds22_max_err(l) > tol
      error("dBds22_max_err(%d) > %g",l,tol);
    endif
    dCds22_max_err(l)=max(abs(((CP22-CM22)/del)-dCds22{l}));
    if dCds22_max_err(l) > tol
      error("dCds22_max_err(%d) > %g",l,tol);
    endif
    dDds22_max_err(l)=max(abs(((DP22-DM22)/del)-dDds22{l}));
    if dDds22_max_err(l) > tol
      error("dDds22_max_err(%d) > %g",l,tol);
    endif
    dCapds22_max_err(l)=max(abs(((CapP22-CapM22)/del)-dCapds22{l}));
    if dCapds22_max_err(l) > tol
      error("dCapds22_max_err(%d) > %g",l,tol);
    endif
    dDapds22_max_err(l)=max(abs(((DapP22-DapM22)/del)-dDapds22{l}));
    if dDapds22_max_err(l) > tol
      error("dDapds22_max_err(%d) > %g",l,tol);
    endif
    % Shift dels
    dels=shift(dels,1);
  endfor
endfor

%
% Test for 4 arguments: s10,s11,s20,s00 (with s02=-s20,s22=s00)
%
for x=1:3
  % Design filter transfer function
  if x==1
    N=20;dbap=0.1;dbas=80;fc=0.1;
    [n,d]=cheby2(N,dbas,2*fc);
  elseif x==2
    N=2;fc=0.1;
    [n,d]=butter(N,2*fc);
  else
    N=1;fc=0.1;
    [n,d]=butter(N,2*fc);
  endif

  % Convert filter transfer function to lattice form
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  Ns=length(s10);
  [A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00);

  % Check [A,B,C,D]
  [check_n,check_d]=Abcd2tf(A,B,C,D);
  if max(abs(check_n-n))/eps > 102.13
    error("max(abs(check_n-n))/eps > 102.13");
  endif
  if max(abs(check_d-d))/eps > 4096
    error("max(abs(check_d-d))/eps > 4096");
  endif

  % Check [A,B,Cap,Dap]
  [check_nap,check_dap]=Abcd2tf(A,B,Cap,Dap);
  if max(abs(fliplr(check_nap)-d))/eps > 2048
    error("max(abs(fliplr(check_nap)-d))/eps > 2048");
  endif
  if max(abs(check_dap-d))/eps > 4096
    error("max(abs(check_dap-d))/eps > 4096");
  endif

  % Calculate differentials of A,B,C,D,Cap,Dap with respect to s
  [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
    schurNSlattice2Abcd(s10,s11,s20,s00);
  % A
  dAds10=cell(size(s10));
  dAds11=cell(size(s11));
  dAds20=cell(size(s20));
  dAds00=cell(size(s00));
  for l=1:Ns
    dAds10{l}=dAds{((l-1)*4)+1};
    dAds11{l}=dAds{((l-1)*4)+2};
    dAds20{l}=dAds{((l-1)*4)+3};
    dAds00{l}=dAds{((l-1)*4)+4};
  endfor
  % B
  dBds10=cell(size(s10));
  dBds11=cell(size(s11));
  dBds20=cell(size(s20));
  dBds00=cell(size(s00));
  for l=1:Ns
    dBds10{l}=dBds{((l-1)*4)+1};
    dBds11{l}=dBds{((l-1)*4)+2};
    dBds20{l}=dBds{((l-1)*4)+3};
    dBds00{l}=dBds{((l-1)*4)+4};
  endfor
  % C
  dCds10=cell(size(s10));
  dCds11=cell(size(s11));
  dCds20=cell(size(s20));
  dCds00=cell(size(s00));
  for l=1:Ns
    dCds10{l}=dCds{((l-1)*4)+1};
    dCds11{l}=dCds{((l-1)*4)+2};
    dCds20{l}=dCds{((l-1)*4)+3};
    dCds00{l}=dCds{((l-1)*4)+4};
  endfor
  % D
  dDds10=cell(size(s10));
  dDds11=cell(size(s11));
  dDds20=cell(size(s20));
  dDds00=cell(size(s00));
  for l=1:Ns
    dDds10{l}=dDds{((l-1)*4)+1};
    dDds11{l}=dDds{((l-1)*4)+2};
    dDds20{l}=dDds{((l-1)*4)+3};
    dDds00{l}=dDds{((l-1)*4)+4};
  endfor
  % Cap
  dCapds10=cell(size(s10));
  dCapds11=cell(size(s11));
  dCapds20=cell(size(s20));
  dCapds00=cell(size(s00));
  for l=1:Ns
    dCapds10{l}=dCapds{((l-1)*4)+1};
    dCapds11{l}=dCapds{((l-1)*4)+2};
    dCapds20{l}=dCapds{((l-1)*4)+3};
    dCapds00{l}=dCapds{((l-1)*4)+4};
  endfor
  % Dap
  dDapds10=cell(size(s10));
  dDapds11=cell(size(s11));
  dDapds20=cell(size(s20));
  dDapds00=cell(size(s00));
  for l=1:Ns
    dDapds10{l}=dDapds{((l-1)*4)+1};
    dDapds11{l}=dDapds{((l-1)*4)+2};
    dDapds20{l}=dDapds{((l-1)*4)+3};
    dDapds00{l}=dDapds{((l-1)*4)+4};
  endfor

  % Check the differentials of A,B,C,D,Cap,Dap with respect to s
  if x==1
    del=1e-8;
    tol=2.5*del;
  else
    del=1e-8;
    tol=del;
  endif
  dels=zeros(1,Ns);
  dels(1)=del/2;
  dAds10_max_err=zeros(size(dels));
  dAds11_max_err=zeros(size(dels));
  dAds20_max_err=zeros(size(dels));
  dAds00_max_err=zeros(size(dels));
  dBds10_max_err=zeros(size(dels));
  dBds11_max_err=zeros(size(dels));
  dBds20_max_err=zeros(size(dels));
  dBds00_max_err=zeros(size(dels));
  dCds10_max_err=zeros(size(dels));
  dCds11_max_err=zeros(size(dels));
  dCds20_max_err=zeros(size(dels));
  dCds00_max_err=zeros(size(dels));
  dDds10_max_err=zeros(size(dels));
  dDds11_max_err=zeros(size(dels));
  dDds20_max_err=zeros(size(dels));
  dDds00_max_err=zeros(size(dels));
  dCapds10_max_err=zeros(size(dels));
  dCapds11_max_err=zeros(size(dels));
  dCapds20_max_err=zeros(size(dels));
  dCapds00_max_err=zeros(size(dels));
  dDapds10_max_err=zeros(size(dels));
  dDapds11_max_err=zeros(size(dels));
  dDapds20_max_err=zeros(size(dels));
  dDapds00_max_err=zeros(size(dels));
  for l=1:Ns
    % s10
    [AP10,BP10,CP10,DP10,CapP10,DapP10]=...
      schurNSlattice2Abcd(s10+dels,s11,s20,s00);
    [AM10,BM10,CM10,DM10,CapM10,DapM10]=...
      schurNSlattice2Abcd(s10-dels,s11,s20,s00);
    dAds10_max_err(l)=max(max(abs(((AP10-AM10)/del)-dAds10{l})));
    if dAds10_max_err(l) > tol
      error("dAds10_max_err(%d) > %g",l,tol);
    endif
    dBds10_max_err(l)=max(abs(((BP10-BM10)/del)-dBds10{l}));
    if dBds10_max_err(l) > tol
      error("dBds10_max_err(%d) > %g",l,tol);
    endif
    dCds10_max_err(l)=max(abs(((CP10-CM10)/del)-dCds10{l}));
    if dCds10_max_err(l) > tol
      error("dCds10_max_err(%d) > %g",l,tol);
    endif
    dDds10_max_err(l)=max(abs(((DP10-DM10)/del)-dDds10{l}));
    if dDds10_max_err(l) > tol
      error("dDds10_max_err(%d) > %g",l,tol);
    endif
    dCapds10_max_err(l)=max(abs(((CapP10-CapM10)/del)-dCapds10{l}));
    if dCapds10_max_err(l) > tol
      error("dCapds10_max_err(%d) > %g",l,tol);
    endif
    dDapds10_max_err(l)=max(abs(((DapP10-DapM10)/del)-dDapds10{l}));
    if dDapds10_max_err(l) > tol
      error("dDapds10_max_err(%d) > %g",l,tol);
    endif
    % s11
    [AP11,BP11,CP11,DP11,CapP11,DapP11]=...
      schurNSlattice2Abcd(s10,s11+dels,s20,s00);
    [AM11,BM11,CM11,DM11,CapM11,DapM11]=...
      schurNSlattice2Abcd(s10,s11-dels,s20,s00);
    dAds11_max_err(l)=max(max(abs(((AP11-AM11)/del)-dAds11{l})));
    if dAds11_max_err(l) > tol
      error("dAds11_max_err(%d) > %g",l,tol);
    endif
    dBds11_max_err(l)=max(abs(((BP11-BM11)/del)-dBds11{l}));
    if dBds11_max_err(l) > tol
      error("dBds11_max_err(%d) > %g",l,tol);
    endif
    dCds11_max_err(l)=max(abs(((CP11-CM11)/del)-dCds11{l}));
    if dCds11_max_err(l) > tol
      error("dCds11_max_err(%d) > %g",l,tol);
    endif
    dDds11_max_err(l)=max(abs(((DP11-DM11)/del)-dDds11{l}));
    if dDds11_max_err(l) > tol
      error("dDds11_max_err(%d) > %g",l,tol);
    endif
    dCapds11_max_err(l)=max(abs(((CapP11-CapM11)/del)-dCapds11{l}));
    if dCapds11_max_err(l) > tol
      error("dCapds11_max_err(%d) > %g",l,tol);
    endif
    dDapds11_max_err(l)=max(abs(((DapP11-DapM11)/del)-dDapds11{l}));
    if dDapds11_max_err(l) > tol
      error("dDapds11_max_err(%d) > %g",l,tol);
    endif
    % s20
    [AP20,BP20,CP20,DP20,CapP20,DapP20]=...
      schurNSlattice2Abcd(s10,s11,s20+dels,s00);
    [AM20,BM20,CM20,DM20,CapM20,DapM20]=...
      schurNSlattice2Abcd(s10,s11,s20-dels,s00);
    dAds20_max_err(l)=max(max(abs(((AP20-AM20)/del)-dAds20{l})));
    if dAds20_max_err(l) > tol
      error("dAds20_max_err(%d) > %g",l,tol);
    endif
    dBds20_max_err(l)=max(abs(((BP20-BM20)/del)-dBds20{l}));
    if dBds20_max_err(l) > tol
      error("dBds20_max_err(%d) > %g",l,tol);
    endif
    dCds20_max_err(l)=max(abs(((CP20-CM20)/del)-dCds20{l}));
    if dCds20_max_err(l) > tol
      error("dCds20_max_err(%d) > %g",l,tol);
    endif
    dDds20_max_err(l)=max(abs(((DP20-DM20)/del)-dDds20{l}));
    if dDds20_max_err(l) > tol
      error("dDds20_max_err(%d) > %g",l,tol);
    endif
    dCapds20_max_err(l)=max(abs(((CapP20-CapM20)/del)-dCapds20{l}));
    if dCapds20_max_err(l) > tol
      error("dCapds20_max_err(%d) > %g",l,tol);
    endif
    dDapds20_max_err(l)=max(abs(((DapP20-DapM20)/del)-dDapds20{l}));
    if dDapds20_max_err(l) > tol
      error("dDapds20_max_err(%d) > %g",l,tol);
    endif
    % s00
    [AP00,BP00,CP00,DP00,CapP00,DapP00]=...
      schurNSlattice2Abcd(s10,s11,s20,s00+dels);
    [AM00,BM00,CM00,DM00,CapM00,DapM00]=...
      schurNSlattice2Abcd(s10,s11,s20,s00-dels);
    dAds00_max_err(l)=max(max(abs(((AP00-AM00)/del)-dAds00{l})));
    if dAds00_max_err(l) > tol
      error("dAds00_max_err(%d) > %g",l,tol);
    endif
    dBds00_max_err(l)=max(abs(((BP00-BM00)/del)-dBds00{l}));
    if dBds00_max_err(l) > tol
      error("dBds00_max_err(%d) > %g",l,tol);
    endif
    dCds00_max_err(l)=max(abs(((CP00-CM00)/del)-dCds00{l}));
    if dCds00_max_err(l) > tol
      error("dCds00_max_err(%d) > %g",l,tol);
    endif
    dDds00_max_err(l)=max(abs(((DP00-DM00)/del)-dDds00{l}));
    if dDds00_max_err(l) > tol
      error("dDds00_max_err(%d) > %g",l,tol);
    endif
    dCapds00_max_err(l)=max(abs(((CapP00-CapM00)/del)-dCapds00{l}));
    if dCapds00_max_err(l) > tol
      error("dCapds00_max_err(%d) > %g",l,tol);
    endif
    dDapds00_max_err(l)=max(abs(((DapP00-DapM00)/del)-dDapds00{l}));
    if dDapds00_max_err(l) > tol
      error("dDapds00_max_err(%d) > %g",l,tol);
    endif
    % Shift dels
    dels=shift(dels,1);
  endfor
endfor

% Done
diary off
movefile schurNSlattice2Abcd_test.diary.tmp schurNSlattice2Abcd_test.diary;
