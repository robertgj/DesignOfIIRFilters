% directFIRnonsymmetricP_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetricP_test.diary");
delete("directFIRnonsymmetricP_test.diary.tmp");
diary directFIRnonsymmetricP_test.diary.tmp

%
% Test sanity checks
%
try
  [P,C]=directFIRnonsymmetricP([1:5]);
catch
  printf("Not enough input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [P,C]=directFIRnonsymmetricP([1:5],[1:6],1);
catch
  printf("Too many input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [P,B,C]=directFIRnonsymmetricP([1:5],[1:6]);
catch
  printf("Too many output arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  P=directFIRnonsymmetricP([1:5],[]);
catch
  printf("Caught empty h!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
P=directFIRnonsymmetricP([],[1:5]);
if ~isempty(P)
  error("~isempty(P)");
endif

%
% FIR filter from yalmip_kyp_lowpass_test.m
%
fap=0.1;
h = [  0.0008656281,  0.0021696544,  0.0015409094, -0.0044622917, ... 
      -0.0158159316, -0.0238564167, -0.0115295105,  0.0369399475, ... 
       0.1209482871,  0.2146857085,  0.2753128363,  0.2671184150, ... 
       0.1864131493,  0.0680195698, -0.0338776291, -0.0783792857, ... 
      -0.0609991209, -0.0114347624,  0.0303914254,  0.0408361994, ... 
       0.0229705268, -0.0030363605, -0.0182941274, -0.0172426361, ... 
      -0.0067422453,  0.0030663947,  0.0067934959,  0.0053367805, ... 
       0.0023609590,  0.0004446292, -0.0000798085 ];
h=h(:)';
N=length(h)-1;
nplot=1000;
nap=ceil(fap*nplot/0.5)+1;
[H,w]=freqz(h,1,nplot);
argH=unwrap(arg(H(1:nap)));

% Check P
P=directFIRnonsymmetricP(w(1:nap),h);
tol=10*eps;
if max(abs(P-argH))>tol
  error("max(abs(P-argH))(%g)>tol(%g)\n",max(abs(P-argH)),tol);
endif

% Check gradP
[P,gradP]=directFIRnonsymmetricP(w(1:nap),h);
del=1e-6;
gradargH=zeros(nap,N+1);
delh=[del/2,zeros(1,N)];
for k=1:(N+1)
  Hhpdelh=freqz(h+delh,1,w(1:nap));
  Hhmdelh=freqz(h-delh,1,w(1:nap));
  gradargH(:,k)=(unwrap(arg(Hhpdelh)-arg(Hhmdelh)))/del;
  delh=circshift(delh,1);
endfor  
if max(max(abs(gradargH-gradP))) > (del/800)
  error("max(max(abs(gradargH-gradP)))(%g) > (del/800)(%g)", ...
        max(max(abs(gradargH-gradP))),del/800);
endif

% Done
diary off
movefile directFIRnonsymmetricP_test.diary.tmp ...
         directFIRnonsymmetricP_test.diary;
