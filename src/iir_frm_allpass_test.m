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
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2; % FIR masking filter delay
nplot=1000;
w=(0:(nplot-1))'*pi/nplot;
fap=0.30; % Pass band edge
nap=(ceil(fap*nplot/0.5)+1);

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
Hp=freqz(nM,rM,w);
Asqp=abs(Hp).^2;
[Asq,T]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
if max(abs(Asq-Asqp)) > 500*eps
  error("Whole band max(abs(Asq-Asqp)) > 500*eps (%d*eps)", ...
        ceil(max(abs(Asq-Asqp))/eps));
endif
Tp=grpdelay(nM,rM,w)-((Mmodel*Dmodel)+dmask);
Tp=Tp(1:nap);
T=T(1:nap);
if max(abs(T-Tp)) > 3e5*eps
  error("Pass band max(abs(T-Tp)) > 3e5*eps (%d*eps)",ceil(max(abs(T-Tp))/eps));
endif
% Don't do whole band check on T

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Asq
%
del=1e-6;
[Asq,~,gradAsq]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
Nxk=length(xk);
delxk=[del;zeros(Nxk-1,1)];
approx_gradAsq=zeros(nplot,Nxk);
for k=1:Nxk
  % Test gradient of amplitude response with respect to coefficients 
  AsqP=iir_frm_allpass(w,xk+(delxk/2),Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
  AsqM=iir_frm_allpass(w,xk-(delxk/2),Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
  approx_gradAsq(:,k)=(AsqP-AsqM)/del;
  delxk=shift(delxk,1);
endfor
diff_gradAsq=approx_gradAsq-gradAsq;
% Pass band
if max(max(abs(diff_gradAsq(1:nap,:)))) > del/20;
  error("Pass band max(max(abs(diff_gradAsq)))(%g*del) > del/20", ...
        max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
% Whole band
if max(max(abs(diff_gradAsq))) > del/20;
  error("Whole band max(max(abs(diff_gradAsq)))(%g*del) > del/20",
        max(max(abs(diff_gradAsq)))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T
%
del=1e-6;
[~,T,~,gradT]=iir_frm_allpass(w,xk,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
Nxk=length(xk);
delxk=[del;zeros(Nxk-1,1)];
approx_gradT=zeros(nplot,Nxk);
for k=1:Nxk
  % Test gradient of phase response with respect to coefficients
  [~,TP]=iir_frm_allpass(w,xk+(delxk/2),Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
  [~,TM]=iir_frm_allpass(w,xk-(delxk/2),Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
  approx_gradT(:,k)=(TP-TM)/del;
  delxk=shift(delxk,1);
endfor
diff_gradT=approx_gradT-gradT;
% Pass band
if max(max(abs(diff_gradT(1:nap,:)))) > 40*del;
  error("Pass band max(max(abs(diff_gradT)))(%g*del) > 40*del", ...
        max(max(abs(diff_gradT(1:nap,:))))/del);
endif
% Don't do whole band check on gradT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile iir_frm_allpass_test.diary.tmp iir_frm_allpass_test.diary;
