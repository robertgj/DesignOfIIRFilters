% print_allpass_pole_test.m
% Copyright (C) 2018-2019 Robert G. Jenssen

test_common;

unlink("print_allpass_pole_test.diary");
unlink("print_allpass_pole_test.diary.tmp");
diary print_allpass_pole_test.diary.tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1);
R1=1;
R2=1;
if ~isempty(a1)
  error("~isempty(a1)");
endif
if V1~=0
  error("V1~=0");
endif
if Q1~=0
  error("Q1~=0");
endif
if isempty(a2)
  error("isempty(a2)");
endif
if V2~=1
  error("V2~=1");
endif
if Q2~=0
  error("Q2~=0");
endif
print_allpass_pole(a1,V1,Q1,R1,"a1","print_allpass_pole_test_N1_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2","print_allpass_pole_test_N1_a2_coef.m");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=3;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[b1,a1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=tf2x(b1,a1);
[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","print_allpass_pole_test_N3_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","print_allpass_pole_test_N3_a2_coef.m");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=5;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,k1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,k1);
[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
print_allpass_pole(a1,V1,Q1,R1,"a1","","%10.6f");
print_allpass_pole(a1,V1,Q1,R1,"a1", ...
                   "print_allpass_pole_test_N5_a1_coef.m","%10.6f");
print_allpass_pole(a2,V2,Q2,R2,"a2","","%10.6f");
print_allpass_pole(a2,V2,Q2,R2,"a2", ...
                   "print_allpass_pole_test_N5_a2_coef.m","%10.6f");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Done
diary off
movefile print_allpass_pole_test.diary.tmp print_allpass_pole_test.diary;
