% directFIRantisymmetricA_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="directFIRantisymmetricA_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

nplot=1024;
atol=10*eps;
gtol=1e-8;

%
% Test sanity checks
%
try
  [A,C]=directFIRantisymmetricA([1:5]);
catch
  printf("Not enough input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [A,C]=directFIRantisymmetricA([1:5],[1:6],1,2);
catch
  printf("Too many input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [A,B,C]=directFIRantisymmetricA([1:5],[1:6]);
catch
  printf("Too many output arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  A=directFIRantisymmetricA([1:5],[]);
catch
  printf("Caught empty hM!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  A=directFIRantisymmetricA([1:5],[1:9,8:-1:1],"www");
catch
  printf("Caught bad type!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  A=directFIRantisymmetricA([1:5],[1:9,8:-1:1],"wwwww");
catch
  printf("Caught bad type!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
A=directFIRantisymmetricA([],[1:5]);
if ~isempty(A)
  error("~isempty(A)");
endif

%
% Even order filter
%
disp("Testing even order filter");
M=20;fap=0.1;fas=0.2;
h=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0]);
h=h.*[ones(M,1);0;-ones(M,1)];
[H,wa]=freqz(h,1,nplot);
hM=h(1:M);
A=directFIRantisymmetricA(wa,hM);
if max(abs(A-abs(H)))>atol
  error("Even order : max(abs(A-abs(H)))(%g)>atol(%g)\n", ...
        max(abs(A-abs(H))),atol);
endif
% Check gradient
[A,gradA]=directFIRantisymmetricA(wa,hM);
del=1e-6;
delh=zeros(size(hM));
delh(1)=del/2;
est_dAdx=zeros(length(wa),length(hM));
for l=1:length(hM)
  AP=directFIRantisymmetricA(wa,hM+delh);
  AM=directFIRantisymmetricA(wa,hM-delh);
  delh=circshift(delh,1);
  est_dAdx(:,l)=(AP-AM)/del;
endfor
if max(max(abs(est_dAdx-gradA))) > gtol
  error("max(max(abs(est_dAdx-gradA)))(%g*gtol) > gtol", ...
        max(max(abs(est_dAdx-gradA)))/gtol);
endif
% Check gradient with freqz
Rtest=1:200;
[A,gradA]=directFIRantisymmetricA(wa(Rtest),hM);
delh=zeros(size(h));
delh(1)=del/2;
est_dAdx=zeros(length(Rtest),length(hM));
for l=1:length(hM)
  HP=freqz(h+delh,1,wa(Rtest));
  HM=freqz(h-delh,1,wa(Rtest));
  delh=circshift(delh,1);
  est_dAdx(:,l)=2*(abs(HP)-abs(HM))/del;
endfor
if max(max(abs(est_dAdx-gradA))) > gtol
  error("max(max(abs(est_dAdx-gradA)))(%g*gtol) > gtol", ...
        max(max(abs(est_dAdx-gradA)))/gtol);
endif

%
% Odd order filter
%
disp("Testing odd order filter");
h(M+1)=[];
[H,wa]=freqz(h,1,nplot);
A=directFIRantisymmetricA(wa,hM,"odd");
if max(abs(A-abs(H)))>atol
  error("Odd order : max(abs(A-abs(H)))(%g)>atol(%g)\n", ...
        max(abs(A-abs(H))),atol);
endif
% Check gradient
[A,gradA]=directFIRantisymmetricA(wa,hM,"odd");
del=1e-6;
delh=zeros(size(hM));
delh(1)=del/2;
est_dAdx=zeros(length(wa),length(hM));
for l=1:length(hM)
  AP=directFIRantisymmetricA(wa,hM+delh,"odd");
  AM=directFIRantisymmetricA(wa,hM-delh,"odd");
  delh=circshift(delh,1);
  est_dAdx(:,l)=(AP-AM)/del;
endfor
if max(max(abs(est_dAdx-gradA))) > gtol
  error("max(max(abs(est_dAdx-gradA)))(%g*gtol) > gtol", ...
        max(max(abs(est_dAdx-gradA)))/gtol);
endif

% Check gradient with freqz
Rtest=1:200;
[A,gradA]=directFIRantisymmetricA(wa(Rtest),hM,"odd");
delh=zeros(size(h));
delh(1)=del/2;
est_dAdx=zeros(length(Rtest),length(hM));
for l=1:length(hM)
  HP=freqz(h+delh,1,wa(Rtest));
  HM=freqz(h-delh,1,wa(Rtest));
  delh=circshift(delh,1);
  est_dAdx(:,l)=2*(abs(HP)-abs(HM))/del;
endfor
if max(max(abs(est_dAdx-gradA))) > 5*gtol
  error("max(max(abs(est_dAdx-gradA)))(%g*gtol) > 5*gtol", ...
        max(max(abs(est_dAdx-gradA)))/gtol);
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
