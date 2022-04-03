% directFIRnonsymmetricAsq_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetricAsq_test.diary");
delete("directFIRnonsymmetricAsq_test.diary.tmp");
diary directFIRnonsymmetricAsq_test.diary.tmp

%
% Test sanity checks
%
try
  [Asq,C]=directFIRnonsymmetricAsq([1:5]);
catch
  printf("Not enough input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [Asq,C]=directFIRnonsymmetricAsq([1:5],[1:6],1);
catch
  printf("Too many input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [Asq,B,C]=directFIRnonsymmetricAsq([1:5],[1:6]);
catch
  printf("Too many output arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  Asq=directFIRnonsymmetricAsq([1:5],[]);
catch
  printf("Caught empty h!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
Asq=directFIRnonsymmetricAsq([],[1:5]);
if ~isempty(Asq)
  error("~isempty(Asq)");
endif

%
% FIR filter from yalmip_kyp_lowpass_test.m
%
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
[H,w]=freqz(h,1,nplot);
absH2=abs(H).^2;

% Check Asq
Asq=directFIRnonsymmetricAsq(w,h);
if any(Asq<0)
  error("any(Asq<0)");
endif
tol=5*eps;
if max(abs(Asq-absH2))>tol
  error("max(abs(Asq-absH2))(%g)>tol(%g)\n",max(abs(Asq-absH2)),tol);
endif

% Check gradAsq
[Asq,gradAsq]=directFIRnonsymmetricAsq(w,h);
del=1e-6;
gradHdelh2=zeros(nplot,N+1);
delh=[del/2,zeros(1,N)];
for k=1:(N+1)
  Hhpdelh=freqz(h+delh,1,w);
  Hhmdelh=freqz(h-delh,1,w);
  gradHdelh2(:,k)=((abs(Hhpdelh).^2)-(abs(Hhmdelh).^2))/del;
  delh=circshift(delh,1);
endfor  
if max(max(abs(gradHdelh2-gradAsq))) > (del/100)
  error("max(max(abs(gradHdelh2-gradAsq)))(%g) > (del/100)(%g)", ...
        max(max(abs(gradHdelh2-gradAsq))),del/100);
endif

% Done
diary off
movefile directFIRnonsymmetricAsq_test.diary.tmp ...
         directFIRnonsymmetricAsq_test.diary;
