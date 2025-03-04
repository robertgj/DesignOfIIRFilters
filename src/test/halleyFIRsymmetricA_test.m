% halleyFIRsymmetricA_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("halleyFIRsymmetricA_test.diary");
delete("halleyFIRsymmetricA_test.diary.tmp");
diary halleyFIRsymmetricA_test.diary.tmp

strf="halleyFIRsymmetricA_test";

%
% Test sanity checks
%
try
  wx=halleyFIRsymmetricA([1:5]);
catch
  printf("Not enough input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  wx=halleyFIRsymmetricA([1:5],[1:6],1,2);
catch
  printf("Too many input arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  [wx,wy]=halleyFIRsymmetricA([1:5],[1:6]);
catch
  printf("Too many output arguments!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
try
  wx=halleyFIRsymmetricA([1:5],[]);
catch
  printf("Caught empty hM!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch;
wx=halleyFIRsymmetricA([],[1:5]);
if ~isempty(wx)
  error("~isempty(wx)");
endif

%
% Filter response
%
nplot=2^14;
nf=1024;
tol=25e-14;
use_remez_bandpass=true
use_selesnick_flat_lowpass=false
if use_remez_bandpass
  M=25;fasl=0.05;fapl=0.1;fapu=0.2;fasu=0.25;Wasl=10;Wap=1;Wasu=10;
  h=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[Wasl, Wap, Wasu]);
  hM=h(1:(M+1))(:);
elseif use_selesnick_flat_lowpass
  M=15;N=(2*M)+1;L=8;deltas=0.001;fas=0.2;
  hM=selesnickFIRsymmetric_flat_lowpass(N,L,deltas,fas,nf);
else
  M=20;fap=0.1;fas=0.2;Wap=1;Was=10;
  h=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0],[Wap, Was]);
  hM=h(1:(M+1))(:);
endif
f=(0:nf)'*0.5/nf;
w=f*2*pi;
A=directFIRsymmetricA(w,hM);
fplot=(0:nplot)'*0.5/nplot;
wplot=fplot*2*pi;
Aplot=directFIRsymmetricA(wplot,hM);
M1=(M:-1:1);
M1w=M1.*wplot;
sinM1w=sin(M1w);
dAplotdw=[-2*M1.*sinM1w,zeros(size(wplot))]*hM;

%
% Check peaks of filter response
%
nmax=local_max(A);
nmin=local_max(-A);
n=unique([nmax(:);nmin(:)]);
wx=halleyFIRsymmetricA(w(n),hM);
Awx=directFIRsymmetricA(wx,hM);
M1wx=M1.*wx;
sinM1wx=sin(M1wx);
dAwxdw=[-2*M1.*sinM1wx,zeros(size(wx))]*hM;
if norm(dAwxdw)>tol
  error("norm(dAwxdw)(%g)>tol(%g)",norm(dAwxdw),tol);
endif
plot(fplot,dAplotdw,wx*0.5/pi,dAwxdw,"*");
axis([0 0.501 -1e-8 1e-8]);
xlabel("Frequency");
ylabel("Gradient of Amplitude");
title("Example of peak-finding with Halley's method");
print(strcat(strf,"_peak"),"-dpdflatex");
close

%
% Find frequency at given amplitudes
%
if use_selesnick_flat_lowpass
  n1=1;
else
  Amaxtol=abs(max(A)-1)/2;
  n1p=find(A<(1+Amaxtol));
  n1m=find(A>(1-Amaxtol));
  n1i=intersect(n1m,n1p);
  n1=[n1i(find(diff(n1i)>1));n1i(end)];
endif
Amintol=abs(min(A))/2;
n0p=find(A<Amintol);
n0m=find(A>-Amintol);
n0i=intersect(n0m,n0p);
n0=[n0i(1);n0i(find(diff(n0i)>1));n0i(end)];
Ax=[ones(size(n1));zeros(size(n0))];
wx=halleyFIRsymmetricA(w([n1;n0]),hM,Ax);
Awx=directFIRsymmetricA(wx,hM);
if norm(Awx-Ax)>tol
  error("norm(Awx-Ax)(%g)>tol(%g)",norm(Awx-Ax),tol);
endif
if use_remez_bandpass
  subplot(311)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.00 0.06 -0.002 0.002])
  ylabel("Amplitude");
  title("Example of value finding on a band-pass filter with Halley's method");
  subplot(312)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.09 0.21 0.98 1.02])
  ylabel("Amplitude"); 
  subplot(313)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.22 0.501 -0.002 0.002])
  ylabel("Amplitude");
  xlabel("Frequency");
elseif use_selesnick_flat_lowpass
  subplot(211)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.0 0.05 0.98 1.02])
  ylabel("Amplitude");
  title("Example of value finding on a low-pass filter with Halley's method");
  subplot(212)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.15 0.501 -0.002 0.002])
  ylabel("Amplitude");
  xlabel("Frequency");
else
  subplot(211)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.0 0.11 0.999 1.001])
  ylabel("Amplitude");
  title("Example of value finding on a low-pass filter with Halley's method");
  subplot(212)
  plot(fplot,Aplot,wx*0.5/pi,Awx,"*");
  axis([0.18 0.501 -0.0001 0.0001])
  ylabel("Amplitude");
  xlabel("Frequency");
endif
print(strcat(strf,"_value"),"-dpdflatex");
close

% Done
diary off
movefile halleyFIRsymmetricA_test.diary.tmp halleyFIRsymmetricA_test.diary;
