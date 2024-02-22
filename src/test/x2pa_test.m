% x2pa_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

delete("x2pa_test.diary");
delete("x2pa_test.diary.tmp");
diary x2pa_test.diary.tmp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1,0.001);
try
  [V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1,0.001);
catch
  printf("Caught %s\n",lasterror.message);
end_try_catch
try
  [a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1,0.001,0);
catch
  printf("Caught %s\n",lasterror.message);
end_try_catch
try
  [a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0);
catch
  printf("Caught %s\n",lasterror.message);
end_try_catch
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
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N1_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N1_a2_coef.m");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=2;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
try
  [a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
catch err
  printf("Expected failure : %s\n",err.message);
end_try_catch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=3;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
print_pole_zero(x1,U,V,M,Q,R,"x1");

[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
pa1=a2p(a1,V1,Q1);
pa2=a2p(a2,V2,Q2);
max_diff_p=max(abs(sort([pa1(:);pa2(:)])-sort(p1)));
if max_diff_p > 10*eps
  error("max_diff_p(%g*eps) > 10*eps",max_diff_p/eps);
endif

print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N3_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N3_a2_coef.m");
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=5;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
print_pole_zero(x1,U,V,M,Q,R,"x1");

[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
pa1=a2p(a1,V1,Q1);
pa2=a2p(a2,V2,Q2);
max_diff_p=max(abs(sort([pa1(:);pa2(:)])-sort(p1)));
if max_diff_p > 100*eps
  error("max_diff_p(%g*eps) > 100*eps",max_diff_p/eps);
endif

print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N5_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N5_a2_coef.m");
             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile x2pa_test.diary.tmp x2pa_test.diary;
