% iir_frm_parallel_allpass_slb_update_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iir_frm_parallel_allpass_slb_update_constraints_test.diary");
unlink("iir_frm_parallel_allpass_slb_update_constraints_test.diary.tmp");
diary iir_frm_parallel_allpass_slb_update_constraints_test.diary.tmp


verbose=true
tol=1e-5

%
% Use the filters found by tarczynski_frm_parallel_allpass_test.m
%
x0.r = [  1.0000000000,   0.0152548265,   0.3369047973,  -0.0720063640, ... 
         -0.0623275062,   0.0216497701,   0.0061273303,   0.0050872513 ]';
x0.s = [  1.0000000000,  -0.0157427870,  -0.0460072484,   0.0150913792, ... 
          0.0146092568,  -0.0089586237,  -0.0042590136 ]';
x0.aa = [ 0.0672226438,   0.0951633180,  -0.0217525997,  -0.0684695215, ... 
          0.0532301778,   0.0593447383,  -0.1048229488,  -0.0519936984, ... 
          0.3164756401,   0.4928594243,   0.2393081186,  -0.0359214791, ... 
         -0.0529166397,   0.0198644748,   0.0224053679,  -0.0077821030, ... 
         -0.0155583724 ]';
x0.ac = [ 0.0804392040,   0.0605872204,  -0.0566156243,   0.0042741562, ... 
          0.0582098069,  -0.0713772012,   0.0016037600,   0.1317710814, ... 
         -0.2798047913,  -0.5979950395,  -0.2324594021,   0.1003061035, ... 
          0.0054709393,  -0.0447391809,   0.0300545384,   0.0010495082, ... 
         -0.0193520504 ]';

%
% Filter specification
%
tol=1e-5
mr=7 % Allpass model filter order 
ms=6 % Allpass model filter order
na=17 % Masking filter FIR length
nc=17 % Complementary masking filter FIR length
Mmodel=9 % Model filter decimation
Dmodel=(mr+ms)/2 % Desired model filter passband delay
dmask=4.5 % Nominal masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask;
fap=0.3 % Pass band edge
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band weight
tpr=2 % Peak-to-peak pass band delay ripple
Wtp=0.025 % Pass band delay weight
fas=0.31 % Stop band edge
dBas=40 % Stop band attenuation
Was=50 % Stop band amplitude weight

% Frequency vectors
n=1000;
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];

% Group delay constraints
Wt=Wtp*ones(nap,1);
Td=Tnominal*ones(nap,1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);

% Convert x0 to vector form
[x0k,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);

% Response
[Asq,T]=iir_frm_parallel_allpass(w,x0k,Vr,Qr,Vs,Qs,na,nc,Mmodel);
T=T(1:nap);

% Constraints
vS=iir_frm_parallel_allpass_slb_update_constraints ...
    (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Asql=Asq(vS.al);
Asqu=Asq(vS.au);
Tl=T(vS.tl);
Tu=T(vS.tu);

% Show constraints
iir_frm_parallel_allpass_slb_show_constraints(vS,w,Asq,T);

% Common strings
strd=sprintf("iir_frm_parallel_allpass_slb_update_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,tpr=%f",
             fap,dBap,fas,dBas,tpr);

% Plot amplitude
f=w*0.5/pi;
subplot(211)
plot(f(1:nap),10*log10([Asq(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     f(vS.al),10*log10(Asql),"x", ...
     f(vS.au),10*log10(Asqu),"+");
axis([0 fap -1 1]);
ylabel("Pass band");
title(sprintf(strM,"x0k amplitude"));
subplot(212)
plot(f(nas:end),10*log10([Asq(nas:end),Asqdu(nas:end)]), ...
     f(vS.al),10*log10(Asql),"x", ...
     f(vS.au),10*log10(Asqu),"+");
axis([fas 0.5 -60 -20]);
ylabel("Stop band");
xlabel("Frequency");
print(sprintf(strd,"amplitude"),"-dpdflatex");
close

% Plot group delay
fp=f(1:nap);
subplot(111),plot(fp,T,fp,Tdu,fp,Tdl,fp(vS.tl),Tl,"x",fp(vS.tu),Tu,"+");
axis([0 fap 60 75]);
ylabel("Group delay");
xlabel("Frequency")
strMdelay=sprintf(strM,"x0k delay");
title(strMdelay);
legend("T","Tdu","Tdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"delay"),"-dpdflatex");
close

%
% Done
%
diary off
movefile iir_frm_parallel_allpass_slb_update_constraints_test.diary.tmp iir_frm_parallel_allpass_slb_update_constraints_test.diary;
