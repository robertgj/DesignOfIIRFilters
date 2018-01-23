% iir_frm_allpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iir_frm_allpass_test.diary");
unlink("iir_frm_allpass_test.diary.tmp");
diary iir_frm_allpass_test.diary.tmp

format compact

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use the filters found by tarczynski_frm_allpass_test.m
%
x0.R=2;
x0.r = [   1.0000000000,   0.1104966710,   0.4713157768,  -0.0511994380, ... 
          -0.0832913424,   0.0282017380,   0.0161840456,  -0.0225063380, ... 
           0.0236675404,  -0.0283777774,   0.0056513949 ]';
x0.aa = [  0.0020487647,   0.0058868810,  -0.0009935574,  -0.0054172515, ... 
           0.0037483714,   0.0088959581,  -0.0058045587,  -0.0080906254, ... 
           0.0100154463,   0.0024502235,  -0.0247595028,   0.0006534136, ... 
           0.0296618489,  -0.0154972939,  -0.0438137927,   0.0358371045, ... 
           0.0493723864,  -0.0845919778,  -0.0500724760,   0.3150351401, ... 
           0.5551259872,   0.3150351401,  -0.0500724760,  -0.0845919778, ... 
           0.0493723864,   0.0358371045,  -0.0438137927,  -0.0154972939, ... 
           0.0296618489,   0.0006534136,  -0.0247595028,   0.0024502235, ... 
           0.0100154463,  -0.0080906254,  -0.0058045587,   0.0088959581, ... 
           0.0037483714,  -0.0054172515,  -0.0009935574,   0.0058868810, ... 
           0.0020487647 ]';
x0.ac = [ -0.0058372532,  -0.0018606215,   0.0079382993,  -0.0012568145, ... 
          -0.0096958156,   0.0055582177,   0.0029550866,  -0.0110495541, ... 
           0.0067886150,  -0.0042692118,  -0.0215978853,   0.0226788373, ... 
           0.0154613645,  -0.0473124943,   0.0133169965,   0.0411349546, ... 
          -0.0702725903,   0.0139756752,   0.1124172311,  -0.2843372240, ... 
          -0.6361229534,  -0.2843372240,   0.1124172311,   0.0139756752, ... 
          -0.0702725903,   0.0411349546,   0.0133169965,  -0.0473124943, ... 
           0.0154613645,   0.0226788373,  -0.0215978853,  -0.0042692118, ... 
           0.0067886150,  -0.0110495541,   0.0029550866,   0.0055582177, ... 
          -0.0096958156,  -0.0012568145,   0.0079382993,  -0.0018606215, ... 
          -0.0058372532 ]';
fap=0.3; % Pass band edge
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2; % FIR masking filter delay

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check conversion
%
tol=25*eps;
% Convert to gain-pole-zero form
[xk,Vr,Qr,Rr,na,nc]=iir_frm_allpass_struct_to_vec(x0);
% Convert back to polynomial form
x1=iir_frm_allpass_vec_to_struct(xk,Vr,Qr,Rr,na,nc);
if max(abs(x1.r-x0.r)) > tol
  error("Expected max(abs(x1.r-x0.r)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif
if x0.R ~= Rr
  error("Expected x0.R==Rr");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[Asq,T,gradAsq,gradT]=iir_frm_allpass([],xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
if ~isempty(Asq) || ~isempty(T) || ~isempty(gradAsq) || ~isempty(gradT)
  error("~isempty(Asq) || ~isempty(T) || ~isempty(gradAsq) || ~isempty(gradT)");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check Asq and T response
%
% Compare with freqz
rM=[x0.r(1);kron(x0.r(2:end),[zeros((Rr*Mmodel)-1,1);1])];
if na>nc
  x0.ac=[zeros((na-nc)/2,1);x0.ac; zeros((na-nc)/2,1)];
elseif na<nc
  x0.aa=[zeros((nc-na)/2,1);x0.aa; zeros((nc-na)/2,1)];
endif
nM=([conv(flipud(rM),x0.aa+x0.ac);zeros(Mmodel*Dmodel,1)] + ...
    [zeros(Mmodel*Dmodel,1);conv(x0.aa-x0.ac,rM)])/2;
n=2048;
[Hp,w]=freqz(nM,rM,n);
Asqp=abs(Hp).^2;
[Asq,T]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
tolAsq=200*eps;
if max(abs(Asq-Asqp)) > tolAsq
  error("max(abs(Asq-Asqp)) > tolAsq (%d*eps)", ...
        ceil(max(abs(Asq-Asqp))/eps));
endif
nap=ceil(fap*n/0.5)+1;
Tp=grpdelay(nM,rM,n)-((Mmodel*Dmodel)+dmask);
Tp=Tp(1:nap);
T=T(1:nap);
tolT=307328*eps;
if max(abs(T-Tp)) > tolT
  error("max(abs(T(1:%d)-Tp(1:%d))) > tolT (%d*eps)", ...
        nap,nap,ceil(max(abs(T-Tp))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Asq
%
del=1e-6;
w=[0.5;1.1]*fap*n/0.5;
[Asq,T,gradAsq]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
Nxk=length(xk);
delxk=[del;zeros(Nxk-1,1)];
tolgradAsq=130*del;
for k=1:Nxk
  % Test gradient of amplitude response with respect to coefficients 
  [AsqD,TD,gradAsqD]=iir_frm_allpass(w,xk+delxk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
  approx_gradAsq=(AsqD-Asq)/del;
  diff_gradAsq=abs((gradAsq(:,k)-approx_gradAsq)./gradAsq(:,k));
  if 0
    printf("gradAsq(1,%d)=%f,diff_gradAsq(1)=%g\n",
           k,gradAsq(1,k),diff_gradAsq(1));
    printf("gradAsq(2,%d)=%f,diff_gradAsq(1)=%g\n",
           k,gradAsq(2,k),diff_gradAsq(2));
  endif
  if max(diff_gradAsq) > tolgradAsq
    error("max(diff_gradAsq)> tolgradAsq(k=%d)",k);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T
%
del=1e-6;
w=[0.5;1.1]*fap*n/0.5;
[Asq,T,gradAsq,gradT]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
Nxk=length(xk);
delxk=[del;zeros(Nxk-1,1)];
tolgradT=688.5*del;
for k=1:Nxk
  % Test gradient of phase response with respect to coefficients
  [AsqD,TD,gradAsqD,gradTD]= ...
    iir_frm_allpass(w,xk+delxk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
  approx_gradT=(TD-T)/del;
  diff_gradT=abs((gradT(:,k)-approx_gradT)./gradT(:,k));
  if 0
    printf("gradT(1,%d)=%f,diff_gradT(1)=%g\n",k,gradT(1,k),diff_gradT(1));
    printf("gradT(2,%d)=%f,diff_gradT(2)=%g\n",k,gradT(2,k),diff_gradT(2));
  endif
  if max(diff_gradT) > tolgradT
    error("max(diff_gradT)> tolgradT(k=%d)",k);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile iir_frm_allpass_test.diary.tmp iir_frm_allpass_test.diary;
