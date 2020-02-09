% directFIRsymmetricA_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("directFIRsymmetricA_test.diary");
unlink("directFIRsymmetricA_test.diary.tmp");
diary directFIRsymmetricA_test.diary.tmp

tol=10*eps;
nplot=1024;

%
% Test sanity checks
%
try
  [A,C]=directFIRsymmetricA([1:5]);
catch
  printf("Not enough input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [A,C]=directFIRsymmetricA([1:5],[1:6],1,2);
catch
  printf("Too many input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [A,B,C]=directFIRsymmetricA([1:5],[1:6]);
catch
  printf("Too many output arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  A=directFIRsymmetricA([1:5],[]);
catch
  printf("Caught empty hM!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  A=directFIRsymmetricA([1:5],[1:9,8:-1:1],"www");
catch
  printf("Caught bad type!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  A=directFIRsymmetricA([1:5],[1:9,8:-1:1],"wwwww");
catch
  printf("Caught bad type!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
A=directFIRsymmetricA([],[1:5]);
if ~isempty(A)
  error("~isempty(A)");
endif

%
% Even order filter
%
M=25;fap=0.1;fas=0.2;Wap=1;Was=10;
h=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0],[Wap, Was]);
[H,wa]=freqz(h,1,nplot);
A=directFIRsymmetricA(wa,h(1:(M+1)));
if max(abs(abs(A)-abs(H)))>tol
  error("Even order : max(abs(abs(A)-abs(H)))(%g)>tol(%g)\n", ...
        max(abs(abs(A)-abs(H))),tol);
endif

%
% Odd order filter
%
M=25;fap=0.1;fas=0.2;Wap=1;Was=10;
h=remez((2*M)-1,[0 fap fas 0.5]*2,[1 1 0 0],[Wap, Was]);
[H,wa]=freqz(h,1,nplot);
A=directFIRsymmetricA(wa,h(1:M),"odd");
if max(abs(abs(A)-abs(H)))>tol
  error("Odd order : max(abs(abs(A)-abs(H)))(%g)>tol(%g)\n", ...
        max(abs(abs(A)-abs(H))),tol);
endif

% Done
diary off
movefile directFIRsymmetricA_test.diary.tmp directFIRsymmetricA_test.diary;
