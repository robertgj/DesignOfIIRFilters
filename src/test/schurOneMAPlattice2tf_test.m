% schurOneMAPlattice2tf_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice2tf_test.diary");
delete("schurOneMAPlattice2tf_test.diary.tmp");
diary schurOneMAPlattice2tf_test.diary.tmp

% From tarczynski_frm_hilbert_test.m
r0 = [  1.0000000000,  0,  0.4654027371,  0, -0.0749201995,  0, ...
        0.0137121216,  0,  0.0035706175,  0, -0.0098219303 ];
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(fliplr(r0),r0);

% Check arguments
r0AP_1=schurOneMAPlattice2tf(k0);
if max(abs(r0-r0AP_1))>eps
  error("max(abs(r0-r0AP_1))>eps");
endif
r0AP_2=schurOneMAPlattice2tf(k0,ones(size(k0)));
if max(abs(r0-r0AP_2))>eps
  error("max(abs(r0-r0AP_2))>eps");
endif
r0AP_2e=schurOneMAPlattice2tf(k0,epsilon0);
if max(abs(r0-r0AP_2e))>eps
  error("max(abs(r0-r0AP_2e))>eps");
endif
r0AP_3=schurOneMAPlattice2tf(k0,epsilon0,p0);
if max(abs(r0-r0AP_3))>eps
  error("max(abs(r0-r0AP_3))>eps");
endif
r0AP_4=schurOneMAPlattice2tf(k0,epsilon0,p0,1);
if max(abs(r0-r0AP_4))>eps
  error("max(abs(r0-r0AP_4))>eps");
endif

% Calculate Schur one-multiplier lattice FRM halfband filter coefficients
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(fliplr(r0),r0);
r0AP=schurOneMAPlattice2tf(k0,epsilon0,p0);
if max(abs(diff(r0-r0AP))) > eps
  error("max(abs(diff(r0-r0AP))) > eps");
endif

% Calculate Schur one-multiplier lattice FRM Hilbert filter coefficients
rm1=zeros(1,length(r0));
rm1(1:4:end)=1;
rm1(3:4:end)=-1;
[k0m1,epsilon0m1,p0m1,c0m1]=tf2schurOneMlattice(fliplr(r0).*rm1,r0.*rm1);
r0APm1=schurOneMAPlattice2tf(k0m1,epsilon0m1,p0m1);
if max(abs(diff((r0.*rm1)-r0APm1))) > eps
  error("max(abs(diff((r0.*rm1)-r0APm1))) > eps");
endif

% Check conversion of halfband allpass model lattice filter 
% Expect H0==1
H0=sum(fliplr(r0))/sum(r0);
if abs(H0-1) > eps
  error("abs(H0-1) > eps");
endif
% Expect H0AP==1
k0=schurdecomp(r0);
r0AP=schurOneMAPlattice2tf(k0,ones(1,length(k0)),ones(1,length(k0)));
H0AP=sum(flipud(r0AP(:)))/sum(r0AP);
if abs(H0AP-1) > eps
  error("abs(H0AP-1) > eps");
endif

% Check conversion of Hilbert allpass model lattice filter 
% Expect H0m1==-1
H0m1=sum(fliplr(r0).*rm1)/sum(r0.*rm1);
if abs(H0m1+1) > eps
  error("abs(H0m1+1) > eps");
endif
% Expect H0APm1==1
k0APm1=schurdecomp(r0.*rm1);
r0APm1=schurOneMAPlattice2tf(k0APm1,ones(1,length(k0)),ones(1,length(k0)));
H0APm1=sum(fliplr(r0APm1))/sum(r0APm1);
if abs(H0APm1-1) > eps
  error("abs(H0APm1-1) > eps");
endif

% Done
diary off
movefile schurOneMAPlattice2tf_test.diary.tmp schurOneMAPlattice2tf_test.diary;
