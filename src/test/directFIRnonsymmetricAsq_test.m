% directFIRnonsymmetricAsq_test.m
% Copyright (C) 2021-2026 Robert G. Jenssen

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
h =   [  0.0024629409,  0.0043299063,  0.0008282373, -0.0115481441, ... 
        -0.0278864843, -0.0325179405, -0.0066048486,  0.0572758926, ... 
         0.1445170633,  0.2220942579,  0.2561794255,  0.2318957749, ... 
         0.1611645154,  0.0739876834,  0.0009749025, -0.0403275948, ... 
        -0.0484701847, -0.0329188013, -0.0072304664,  0.0156129560, ... 
         0.0262868789,  0.0218829195,  0.0071201577, -0.0082811653, ... 
        -0.0156301553, -0.0126116904, -0.0037676802,  0.0039725804, ... 
         0.0065852969,  0.0047851743,  0.0018073130 ];
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
