% complementaryFIRdecomp_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("complementaryFIRdecomp_test.diary");
unlink("complementaryFIRdecomp_test.diary.tmp");
diary complementaryFIRdecomp_test.diary.tmp

format long e

fstr="complementaryFIRdecomp_test_%s_coef.m";
                                              
%
% Lowpass filter specification
%
fap=0.1;fas=0.25;
M=15;N=(2*M)+1;
brz=remez(2*M,2*[0 fap fas 0.5],[1 1 0 0]);
brz=brz(:);
tol=40*eps;
[brz,brzc,krz,krzhat]=complementaryFIRlattice(brz,tol);
% Save results
print_polynomial(brz,"brz",sprintf(fstr,"brz"),"%12.8f");
print_polynomial(brzc,"brzc",sprintf(fstr,"brzc"),"%12.8f");
print_polynomial(krz,"krz",sprintf(fstr,"krz"),"%12.8f");
print_polynomial(krzhat,"krzhat",sprintf(fstr,"krzhat"),"%12.8f");

% Extra test for order reduction
brze=[0;brz;0];
tol=10*eps
[brze,brzec,krze,krzehat]=complementaryFIRlattice(brze,tol,2^20);
% Save results
print_polynomial(brze,"brze",sprintf(fstr,"brze"),"%12.8f");
print_polynomial(brzec,"brzec",sprintf(fstr,"brzec"),"%12.8f");
print_polynomial(krze,"krze",sprintf(fstr,"krze"),"%12.8f");
print_polynomial(krzehat,"krzehat",sprintf(fstr,"krzehat"),"%12.8f");

%
% Minimum-phase bandpass filter from iir_sqp_slb_fir_17_bandpass_test.m
%
Ud1=2;Vd1=0;Md1=14;Qd1=0;Rd1=1;
d1 = [   0.0920209477, ...
         0.9990000000,   0.5128855702, ...
         0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
        -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
         3.7000375301,   4.4072989555,   4.6685041037 ]';
[b17b,~]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
b17b=b17b(:);
[b17b,b17bc,k17b,k17bhat]=complementaryFIRlattice(b17b);
% Save results
print_polynomial(b17b,"b17b",sprintf(fstr,"b17b"),"%12.8f");
print_polynomial(b17bc,"b17bc",sprintf(fstr,"b17bc"),"%12.8f");
print_polynomial(k17b,"k17b",sprintf(fstr,"k17b"),"%12.8f");
print_polynomial(k17bhat,"k17bhat",sprintf(fstr,"k17bhat"),"%12.8f");

%
% Lowpass filter from cl2lp
%
hcl=cl2lp(M,0.5*pi,[1, 0.01],[0.95, -0.01],2^20);
hcl=hcl(:);
[hcl,hclc,kcl,kclhat]=complementaryFIRlattice(hcl);
% Save results
print_polynomial(hcl,"hcl",sprintf(fstr,"hcl"),"%12.8f");
print_polynomial(hclc,"hclc",sprintf(fstr,"hclc"),"%12.8f");
print_polynomial(kcl,"kcl",sprintf(fstr,"kcl"),"%12.8f");
print_polynomial(kclhat,"kclhat",sprintf(fstr,"kclhat"),"%12.8f");

% Done
diary off
movefile complementaryFIRdecomp_test.diary.tmp ...
         complementaryFIRdecomp_test.diary;
