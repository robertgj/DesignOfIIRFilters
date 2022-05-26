% complementaryFIRdecomp_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("complementaryFIRdecomp_test.diary");
delete("complementaryFIRdecomp_test.diary.tmp");
diary complementaryFIRdecomp_test.diary.tmp

check_octave_file("complementaryFIRdecomp");

strf="complementaryFIRdecomp_test";
                                              
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
print_polynomial(brz,"brz",strcat(strf,"_brz_coef.m"),"%12.8f");
print_polynomial(brzc,"brzc",strcat(strf,"_brzc_coef.m"),"%12.8f");
print_polynomial(krz,"krz",strcat(strf,"_krz_coef.m"),"%12.8f");
print_polynomial(krzhat,"krzhat",strcat(strf,"_krzhat_coef.m"),"%12.8f");

% Extra test for order reduction
brze=[0;brz;0];
tol=10*eps
[brze,brzec,krze,krzehat]=complementaryFIRlattice(brze,tol,2^20);
% Save results
print_polynomial(brze,"brze",strcat(strf,"_brze_coef.m"),"%12.8f");
print_polynomial(brzec,"brzec",strcat(strf,"_brzec_coef.m"),"%12.8f");
print_polynomial(krze,"krze",strcat(strf,"_krze_coef.m"),"%12.8f");
print_polynomial(krzehat,"krzehat",strcat(strf,"_krzehat_coef.m"),"%12.8f");

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
print_polynomial(b17b,"b17b",strcat(strf,"_b17b_coef.m"),"%12.8f");
print_polynomial(b17bc,"b17bc",strcat(strf,"_b17bc_coef.m"),"%12.8f");
print_polynomial(k17b,"k17b",strcat(strf,"_k17b_coef.m"),"%12.8f");
print_polynomial(k17bhat,"k17bhat",strcat(strf,"_k17bhat_coef.m"),"%12.8f");

%
% Lowpass filter from cl2lp
%
hcl=cl2lp(M,0.5*pi,[1, 0.01],[0.95, -0.01],2^20);
hcl=hcl(:);
[hcl,hclc,kcl,kclhat]=complementaryFIRlattice(hcl);
% Save results
print_polynomial(hcl,"hcl",strcat(strf,"_hcl_coef.m"),"%12.8f");
print_polynomial(hclc,"hclc",strcat(strf,"_hclc_coef.m"),"%12.8f");
print_polynomial(kcl,"kcl",strcat(strf,"_kcl_coef.m"),"%12.8f");
print_polynomial(kclhat,"kclhat",strcat(strf,"_kclhat_coef.m"),"%12.8f");

% Done
diary off
movefile complementaryFIRdecomp_test.diary.tmp ...
         complementaryFIRdecomp_test.diary;
