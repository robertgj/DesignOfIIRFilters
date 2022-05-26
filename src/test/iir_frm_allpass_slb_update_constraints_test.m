% iir_frm_allpass_slb_update_constraints_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("iir_frm_allpass_slb_update_constraints_test.diary");
delete("iir_frm_allpass_slb_update_constraints_test.diary.tmp");
diary iir_frm_allpass_slb_update_constraints_test.diary.tmp


verbose=true
tol=1e-5

%
% Use the filters found by tarczynski_frm_allpass_test.m
%
x0.R = 1;
x0.r = [   1.0000000000,   0.1111701595,   0.4712820723,  -0.0512805016, ... 
          -0.0836348855,   0.0288364356,   0.0159210683,  -0.0225225935, ... 
           0.0238732656,  -0.0284983899,   0.0059206039 ]';
x0.aa = [  0.0025077062,   0.0058072416,  -0.0007421407,  -0.0055606315, ... 
           0.0040763056,   0.0086813387,  -0.0058418127,  -0.0080984186, ... 
           0.0101746570,   0.0016145508,  -0.0245720071,   0.0002811194, ... 
           0.0298163129,  -0.0161047983,  -0.0436018451,   0.0360554548, ... 
           0.0491578998,  -0.0847490457,  -0.0492554433,   0.3149080798, ... 
           0.5554585515,   0.3149080798,  -0.0492554433,  -0.0847490457, ... 
           0.0491578998,   0.0360554548,  -0.0436018451,  -0.0161047983, ... 
           0.0298163129,   0.0002811194,  -0.0245720071,   0.0016145508, ... 
           0.0101746570,  -0.0080984186,  -0.0058418127,   0.0086813387, ... 
           0.0040763056,  -0.0055606315,  -0.0007421407,   0.0058072416, ... 
           0.0025077062 ]';
x0.ac = [ -0.0053954280,  -0.0022268914,   0.0077389437,  -0.0013056655, ... 
          -0.0095571878,   0.0056395569,   0.0028485881,  -0.0110688241, ... 
           0.0067042914,  -0.0034449590,  -0.0220966358,   0.0219303388, ... 
           0.0152287988,  -0.0466602405,   0.0130432437,   0.0412544031, ... 
          -0.0703443720,   0.0137981670,   0.1134886186,  -0.2850078130, ... 
          -0.6368691872,  -0.2850078130,   0.1134886186,   0.0137981670, ... 
          -0.0703443720,   0.0412544031,   0.0130432437,  -0.0466602405, ... 
           0.0152287988,   0.0219303388,  -0.0220966358,  -0.0034449590, ... 
           0.0067042914,  -0.0110688241,   0.0028485881,   0.0056395569, ... 
          -0.0095571878,  -0.0013056655,   0.0077389437,  -0.0022268914, ... 
          -0.0053954280 ]';
%
% Filter specification
%
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
fap=0.3; % Pass band edge
dBap=0.1; % Pass band amplitude ripple
Wap=1; % Pass band amplitude weight
tpr=2; % Pass band delay ripple
Wtp=1; % Pass band delay weight
fas=0.31; % Pass band edge
dBas=50; % Stop band amplitude ripple
Was=10; % Stop band amplitude weight

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
Td=zeros(nap,1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);

% Convert x0 to vector form
[x0k,Vr,Qr,Rr,na,nc]=iir_frm_allpass_struct_to_vec(x0);

% Response
[Asq,T]=iir_frm_allpass(w,x0k,Vr,Qr,Rr,na,nc,Mmodel,Dmodel);
T=T(1:nap);

% Constraints
vS=iir_frm_allpass_slb_update_constraints(Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Asql=Asq(vS.al);
Asqu=Asq(vS.au);
Tl=T(vS.tl);
Tu=T(vS.tu);

% Show constraints
iir_frm_allpass_slb_show_constraints(vS,w,Asq,T);

% Common strings
strd=sprintf("iir_frm_allpass_slb_update_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,tpr=%f",
             fap,dBap,fas,dBas,tpr);

% Plot amplitude
f=w*0.5/pi;
subplot(211)
plot(f(1:nap),10*log10([Asq(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     f(vS.al),10*log10(Asql),"x", ...
     f(vS.au),10*log10(Asqu),"+");
axis([0 fap -1 1]);
ylabel("Pass band(dB)");
legend("Asq","Asqdu","Asqdl","location","northwest");
legend("boxoff");
title(sprintf(strM,"x0k amplitude"));
subplot(212)
plot(f(nas:end),10*log10([Asq(nas:end),Asqdu(nas:end),Asqdu(nas:end)+tol]), ...
     f(vS.al),10*log10(Asql),"x", ...
     f(vS.au),10*log10(Asqu),"+");
axis([fas 0.5 -60 -30]);
ylabel("Stop band(dB)");
xlabel("Frequency");
legend("Asq","Asqdu","Asqdu+tol","location","northwest");
legend("boxoff");
print(sprintf(strd,"amplitude"),"-dpdflatex");
close

% Plot group delay
fp=f(1:nap);
subplot(111),plot(fp,T,fp,Tdu,fp,Tdl,fp(vS.tl),Tl,"x",fp(vS.tu),Tu,"+");
axis([0 fap -10 +25]);
ylabel("Delay(samples)");
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
movefile iir_frm_allpass_slb_update_constraints_test.diary.tmp ...
       iir_frm_allpass_slb_update_constraints_test.diary;
