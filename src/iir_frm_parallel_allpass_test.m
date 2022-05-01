% iir_frm_parallel_allpass_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

delete("iir_frm_parallel_allpass_test.diary");
delete("iir_frm_parallel_allpass_test.diary.tmp");
diary iir_frm_parallel_allpass_test.diary.tmp

verbose=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test filters from tarczynski_frm_parallel_allpass_test.m
%
Mmodel=9; % Model filter decimation
fap=0.3; % Pass band edge

x0.r = [   1.0000000000,   0.0152548265,   0.3369047973,  -0.0720063640, ... 
          -0.0623275062,   0.0216497701,   0.0061273303,   0.0050872513 ]';
x0.s = [   1.0000000000,  -0.0157427870,  -0.0460072484,   0.0150913792, ... 
           0.0146092568,  -0.0089586237,  -0.0042590136 ]';
x0.aa = [  0.0672226438,   0.0951633180,  -0.0217525997,  -0.0684695215, ... 
           0.0532301778,   0.0593447383,  -0.1048229488,  -0.0519936984, ... 
           0.3164756401,   0.4928594243,   0.2393081186,  -0.0359214791, ... 
          -0.0529166397,   0.0198644748,   0.0224053679,  -0.0077821030, ... 
          -0.0155583724 ]';
x0.ac = [  0.0804392040,   0.0605872204,  -0.0566156243,   0.0042741562, ... 
           0.0582098069,  -0.0713772012,   0.0016037600,   0.1317710814, ... 
          -0.2798047913,  -0.5979950395,  -0.2324594021,   0.1003061035, ... 
           0.0054709393,  -0.0447391809,   0.0300545384,   0.0010495082, ... 
          -0.0193520504 ]';

x1.r = [   1.0000000000,   0.0716439193,   0.2882456199,  -0.0378037610, ... 
          -0.0746563032,   0.0180859282,   0.0132854499,   0.0004626479 ]';
x1.s = [   1.0000000000,  -0.0205053128,  -0.0360375737,   0.0107440672, ... 
           0.0135176490,  -0.0076295261,  -0.0040572085 ]';
x1.aa = [  0.0217579620,   0.0041566926,  -0.0057850543,   0.0645023794, ... 
           0.0963147344,  -0.0244213730,  -0.0681691528,   0.0550634231, ... 
           0.0579963699,  -0.1206801988,  -0.0480509287,   0.3244851127, ... 
           0.4965876270,   0.2382704160,  -0.0333468732,  -0.0529140262, ... 
           0.0176269903,   0.0242263478,  -0.0081629144,  -0.0211947624, ... 
          -0.0006175377 ]';
x1.ac = [  0.0389711346,  -0.0027272586,  -0.0242825786,   0.0855782342, ... 
           0.0687019801,  -0.0705437129,   0.0051738618,   0.0699776378, ... 
          -0.0783512773,   0.0427291248,   0.1487143466,  -0.2991873472, ... 
          -0.5902344510,  -0.2179847456,   0.0867002471,   0.0013496737, ... 
          -0.0303762684,   0.0260602334,   0.0151122287 ]';

x2.r = [   1.0000000000,  -0.0601320468,   0.3292665743,  -0.0630708273, ... 
          -0.0735041428,   0.0272783831,   0.0048756099,   0.0072209928 ]';
x2.s = [   1.0000000000,  -0.0705755332,  -0.0338807898,   0.0165459159, ... 
           0.0137212523,  -0.0112756715,  -0.0020445031 ]';
x2.aa = [ -0.0001503960,   0.0241202844,   0.1082262721,   0.1182101097, ... 
          -0.0231661505,  -0.0798490787,   0.0577534913,   0.0678238963, ... 
          -0.1134595870,  -0.0604516998,   0.3035263104,   0.4635519452, ... 
           0.2172118061,  -0.0334320144,  -0.0411914941,   0.0144777994, ... 
           0.0124300516,   0.0032698945,  -0.0023607588 ]';
x2.ac = [ -0.0111387177,  -0.0256387289,   0.0360846013,   0.0363948704, ... 
          -0.0434588270,   0.0016787509,   0.0518445272,  -0.0612576125, ... 
          -0.0028956159,   0.1072846069,  -0.2858670655,  -0.6113458443, ... 
          -0.2508033867,   0.1119520835,   0.0013248466,  -0.0503331335, ... 
           0.0424807039,  -0.0059731960,  -0.0426654395,   0.0176812926, ... 
           0.0317718056 ]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check conversion
%
tol=6*eps;
% Convert to gain-pole-zero vector form
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);
% Convert back to polynomial form
x=iir_frm_parallel_allpass_vec_to_struct(xk,Vr,Qr,Vs,Qs,na,nc);
if max(abs(x.r-x0.r)) > tol
  error("Expected max(abs(x.r-x0.r)) <= tol");
endif
if max(abs(x.s-x0.s)) > tol
  error("Expected max(abs(x.s-x0.s)) <= tol");
endif
if max(abs(x.aa-x0.aa)) ~= 0
  error("Expected max(abs(x.aa-x0.aa)) == 0");
endif
if max(abs(x.ac-x0.ac)) ~= 0
  error("Expected max(abs(x.ac-x0.ac)) == 0");
endif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[Asq,T,gradAsq,gradT]=iir_frm_parallel_allpass([],xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
if ~(isempty(Asq) && isempty(T) && isempty(gradAsq) && isempty(gradT))
  error("Expected isempty(Asq)&&isempty(T)&&isempty(gradAsq)&&isempty(gradT)");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check x0.aa response
%
n=1000;
w=(0:(n-1))'*pi/n;
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);
xt=[x0.aa(:);0];
Asqaa=iir_frm_parallel_allpass(w,xt,0,0,0,0,na,1,Mmodel);
% Compare with freqz
Aaap=freqz(x0.aa,1,w);
Asqaap=abs(Aaap).^2;
tolAsqaa=13*eps;
if max(abs(Asqaa-Asqaap)) > tolAsqaa
  error("max(abs(Asqaa-Asqaap)) > tolAsqaa (%d*eps)",
        ceil(max(abs(Asqaa-Asqaap))/eps));
endif
nap=ceil(n*fap/0.5)+1;
[Asqaa,Taa]=iir_frm_parallel_allpass(w(1:nap),xt,0,0,0,0,na,1,Mmodel);
% BUG in grpdelay: grpdelay(x0.aa,1,w(1:nap)) FAILS!
Taap=grpdelay(x0.aa(:),1,n);
Taap=Taap(1:nap);
tolTaa=68*eps;
if max(abs(Taa-Taap)) > tolTaa
  error("max(abs(Taa-Taap)) > tolTaa (%d*eps)",ceil(max(abs(Taa-Taap))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check model filter response
%
n=1000;
w=(0:(n-1))'*pi/n;
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);
xt=[xk(1:(Vr+Qr+Vs+Qs));1;0];
[Asqm,Tm]=iir_frm_parallel_allpass(w,xt,Vr,Qr,Vs,Qs,1,1,Mmodel);
% Compare with freqz
rM=[x0.r(1);kron(x0.r(2:end),[zeros(Mmodel-1,1);1])];
sM=[x0.s(1);kron(x0.s(2:end),[zeros(Mmodel-1,1);1])];
Hmp=freqz(conv(flipud(rM),sM)+conv(flipud(sM),rM),2*conv(rM,sM),w);
Asqmp=abs(Hmp).^2;
tolAsqm=175*eps;
if max(abs(Asqm-Asqmp)) > tolAsqm
  error("max(abs(Asqm-Asqmp)) > tolAsqm (%d*eps)",
        ceil(max(abs(Asqm-Asqmp))/eps));
endif
Tmp=grpdelay(conv(flipud(rM),sM)+conv(flipud(sM),rM),2*conv(rM,sM),n);
nap=ceil(n*fap/0.5)+1;
napM=(ceil(n*fap/0.5)/Mmodel)+1;
Tm=Tm(1:napM);
Tmp=Tmp(1:napM);
tolTm=2000*eps;
if max(abs(Tm-Tmp)) > tolTm
  error("max(abs(Tm-Tmp)) > tolTm (%d*eps)",ceil(max(abs(Tm-Tmp))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check complementary model filter response
%
n=1000;
w=(0:(n-1))'*pi/n;
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);
xt=[xk(1:(Vr+Qr+Vs+Qs));0;1];
[Asqmc,Tmc]=iir_frm_parallel_allpass(w,xt,Vr,Qr,Vs,Qs,1,1,Mmodel);
% Compare with freqz
rM=[x0.r(1);kron(x0.r(2:end),[zeros(Mmodel-1,1);1])];
sM=[x0.s(1);kron(x0.s(2:end),[zeros(Mmodel-1,1);1])];
Hmcp=freqz(conv(flipud(rM),sM)-conv(flipud(sM),rM),2*conv(rM,sM),w);
Asqmcp=abs(Hmcp).^2;
tolAsqmc=212*eps;
if max(abs(Asqmc-Asqmcp)) > tolAsqmc
  error("max(abs(Asqmc-Asqmcp)) > tolAsqmc (%d*eps)",
        ceil(max(abs(Asqmc-Asqmcp))/eps));
endif
Tmcp=grpdelay(conv(flipud(rM),sM)-conv(flipud(sM),rM),2*conv(rM,sM),n);
nap=ceil(n*fap/0.5)+1;
napM=(ceil(n*fap/0.5)/Mmodel)+1;
Tmc=Tmc(40:napM);
Tmcp=Tmcp(40:napM);
tolTmc=1696*eps;
if max(abs(Tmc-Tmcp)) > tolTmc
  error("max(abs(Tmc-Tmcp)) > tolTmc (%d*eps)",ceil(max(abs(Tmc-Tmcp))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response na==nc
%
n=1000;
w=(0:(n-1))'*pi/n;
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);
[Asq,T]=iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
% Check squared-magnitude response
rM=[x0.r(1);kron(x0.r(2:end),[zeros(Mmodel-1,1);1])];
sM=[x0.s(1);kron(x0.s(2:end),[zeros(Mmodel-1,1);1])];
numfrm=(conv(conv(flipud(rM),x0.aa+x0.ac),sM) + ...
        conv(conv(flipud(sM),x0.aa-x0.ac),rM))/2;
denfrm=conv(rM,sM);
Hp=freqz(numfrm,denfrm,w);
Asqp=abs(Hp).^2;
tolAsq=122*eps;
if max(abs(Asq-Asqp)) > tolAsq
  error("max(abs(Asq-Asqp)) > tolAsq (%d*eps)",ceil(max(abs(Asq-Asqp))/eps));
endif
% Check group delay response
Tp=grpdelay(numfrm,denfrm,n);
nap=ceil(n*fap/0.5)+1;
napM=(ceil(n*fap/0.5)/Mmodel)+1;
T=T(1:napM);
Tp=Tp(1:napM);
tolT=2000*eps;
if max(abs(T-Tp)) > tolT
  error("max(abs(T-Tp)) > tolT (%d*eps)",ceil(max(abs(T-Tp))/eps));
endif
% Check squared-magnitude and group delay response gradients
wap=2*pi*fap/8;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm_parallel_allpass(wap,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
del=1e-7;
tol_gradAsq=del/10;
tol_gradT=del*4;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm_parallel_allpass(wap,xk+(delxk/2),Vr,Qr,Vs,Qs,na,nc,Mmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm_parallel_allpass(wap,xk-(delxk/2),Vr,Qr,Vs,Qs,na,nc,Mmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
          k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=circshift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response na>nc
%
n=1024;
w=(0:(n-1))'*pi/n;
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x1);
[Asq,T]=iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
% Compare with freqz
rM=[x1.r(1);kron(x1.r(2:end),[zeros(Mmodel-1,1);1])];
sM=[x1.s(1);kron(x1.s(2:end),[zeros(Mmodel-1,1);1])];
ac1=[x1.ac;zeros(length(x1.aa)-length(x1.ac),1)];
numfrm=(conv(conv(flipud(rM),x1.aa+ac1),sM) + ...
        conv(conv(flipud(sM),x1.aa-ac1),rM))/2;
denfrm=conv(rM,sM);
Hp=freqz(numfrm,denfrm,w);
Asqp=abs(Hp).^2;
tolAsq=177*eps;
if max(abs(Asq-Asqp)) > tolAsq
  error("max(abs(Asq-Asqp)) > tolAsq (%d*eps)",ceil(max(abs(Asq-Asqp))/eps));
endif
Tp=grpdelay(numfrm,denfrm,n);
nap=ceil(n*fap/0.5)+1;
napM=(ceil(n*fap/0.5)/Mmodel)+1;
T=T(1:napM);
Tp=Tp(1:napM);
tolT=1000*eps;
if max(abs(T-Tp)) > tolT
  error("max(abs(T-Tp)) > tolT (%d*eps)",ceil(max(abs(T-Tp))/eps));
endif
% Check squared-magnitude and group delay response gradients
wap=2*pi*fap/8;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm_parallel_allpass(wap,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
del=1e-7;
tol_gradAsq=del/10;
tol_gradT=del*5;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm_parallel_allpass(wap,xk+(delxk/2),Vr,Qr,Vs,Qs,na,nc,Mmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm_parallel_allpass(wap,xk-(delxk/2),Vr,Qr,Vs,Qs,na,nc,Mmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
          k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=circshift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response na<nc
%
n=1024;
w=(0:(n-1))'*pi/n;
[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x2);
[Asq,T]=iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
% Compare with freqz
rM=[x2.r(1);kron(x2.r(2:end),[zeros(Mmodel-1,1);1])];
sM=[x2.s(1);kron(x2.s(2:end),[zeros(Mmodel-1,1);1])];
aa2=[x2.aa;zeros(length(x2.ac)-length(x2.aa),1)];
numfrm=(conv(conv(flipud(rM),aa2+x2.ac),sM) + ...
        conv(conv(flipud(sM),aa2-x2.ac),rM))/2;
denfrm=conv(rM,sM);
Hp=freqz(numfrm,denfrm,w);
Asqp=abs(Hp).^2;
tolAsq=1000*eps;
if max(abs(Asq-Asqp)) > tolAsq
  error("max(abs(Asq-Asqp)) > tolAsq (%d*eps)",ceil(max(abs(Asq-Asqp))/eps));
endif
Tp=grpdelay(numfrm,denfrm,n);
nap=ceil(n*fap/0.5)+1;
napM=(ceil(n*fap/0.5)/Mmodel)+1;
T=T(1:napM);
Tp=Tp(1:napM);
tolT=1000*eps;
if max(abs(T-Tp)) > tolT
  error("max(abs(T-Tp)) > tolT (%d*eps)",ceil(max(abs(T-Tp))/eps));
endif
% Check squared-magnitude and group delay response gradients
wap=2*pi*fap/8;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm_parallel_allpass(wap,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
del=1e-7;
tol_gradAsq=del/10;
tol_gradT=del*5;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm_parallel_allpass(wap,xk+(delxk/2),Vr,Qr,Vs,Qs,na,nc,Mmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm_parallel_allpass(wap,xk-(delxk/2),Vr,Qr,Vs,Qs,na,nc,Mmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
          k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=circshift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile iir_frm_parallel_allpass_test.diary.tmp ...
         iir_frm_parallel_allpass_test.diary;
