% iir_frm_allpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

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
x0.r = [   1.0000000000,   0.4797039469,  -0.0952293157,   0.0234316280, ... 
          -0.0148019916,  -0.0286461615  ]';
x0.aa = [  0.0039687893,   0.0046484014,  -0.0019924493,  -0.0057602779, ... 
           0.0058603123,   0.0080426278,  -0.0064371551,  -0.0068839536, ... 
           0.0101006225,  -0.0030284916,  -0.0232423732,   0.0043648957, ... 
           0.0305889177,  -0.0210316446,  -0.0426558609,   0.0374740535, ... 
           0.0474180060,  -0.0852987336,  -0.0428490990,   0.3136060129, ... 
           0.5500685753,   0.3136060129,  -0.0428490990,  -0.0852987336, ... 
           0.0474180060,   0.0374740535,  -0.0426558609,  -0.0210316446, ... 
           0.0305889177,   0.0043648957,  -0.0232423732,  -0.0030284916, ... 
           0.0101006225,  -0.0068839536,  -0.0064371551,   0.0080426278, ... 
           0.0058603123,  -0.0057602779,  -0.0019924493,   0.0046484014, ... 
           0.0039687893  ]';
x0.ac = [ -0.0012823741,   0.0123963985,   0.0087717066,  -0.0108502001, ... 
           0.0021511768,   0.0188344411,  -0.0126850737,  -0.0149731143, ... 
           0.0236878713,  -0.0000961275,  -0.0067406786,   0.0353386720, ... 
           0.0033390571,  -0.0320724784,   0.0450742492,   0.0163880350, ... 
          -0.0876590879,   0.0484253604,   0.1217305747,  -0.2839684289, ... 
          -0.6161027476,  -0.2839684289,   0.1217305747,   0.0484253604, ... 
          -0.0876590879,   0.0163880350,   0.0450742492,  -0.0320724784, ... 
           0.0033390571,   0.0353386720,  -0.0067406786,  -0.0000961275, ... 
           0.0236878713,  -0.0149731143,  -0.0126850737,   0.0188344411, ... 
           0.0021511768,  -0.0108502001,   0.0087717066,   0.0123963985, ... 
          -0.0012823741 ]';
fap=0.3; % Pass band edge
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2; % FIR masking filter delay

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check conversion
%
tol=2.5*eps;
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
tolAsq=131*eps;
if max(abs(Asq-Asqp)) > tolAsq
  error("max(abs(Asq-Asqp)) > tolAsq (%d*eps)", ...
        ceil(max(abs(Asq-Asqp))/eps));
endif
nap=ceil(fap*n/0.5)+1;
Tp=grpdelay(nM,rM,n)-((Mmodel*Dmodel)+dmask);
Tp=Tp(1:nap);
T=T(1:nap);
tolT=2962*eps;
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
