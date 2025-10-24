% directFIRnonsymmetric_slb_exchange_constraints_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetric_slb_exchange_constraints_test.diary");
delete("directFIRnonsymmetric_slb_exchange_constraints_test.diary.tmp");
diary directFIRnonsymmetric_slb_exchange_constraints_test.diary.tmp

maxiter=2000
tol=1e-8
verbose=true

% Low-pass filter specification from yalmip_kyp_lowpass_test.m
N=30;d=10;fap=0.1;Wap=1;Wat=0.0001;fas=0.2;Was=1000;
h0 = [  0.0008656281,  0.0021696544,  0.0015409094, -0.0044622917, ... 
       -0.0158159316, -0.0238564167, -0.0115295105,  0.0369399475, ... 
        0.1209482871,  0.2146857085,  0.2753128363,  0.2671184150, ... 
        0.1864131493,  0.0680195698, -0.0338776291, -0.0783792857, ... 
       -0.0609991209, -0.0114347624,  0.0303914254,  0.0408361994, ... 
        0.0229705268, -0.0030363605, -0.0182941274, -0.0172426361, ... 
       -0.0067422453,  0.0030663947,  0.0067934959,  0.0053367805, ... 
        0.0023609590,  0.0004446292, -0.0000798085 ];
N=length(h0)-1;
dBap=0.05; % Pass band amplitude response ripple
dBas=60; % Stop band amplitude response ripple
Was=750; % Stop band amplitude response weight
ftp=0.1; % Pass band group delay response edge
td=d; % Pass band nominal group delay
tdr=0.1; % Pass band group delay response ripple
Wtp=1; % Pass band group delay response weight
fpp=0.1; % Pass band phase response edge
ppr=0.01; % Pass band phase response ripple
Wpp=0.1; % Pass band phase response weight

% Desired squared magnitude response
nplot=1000;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
wa=(0:(nplot-1))'*pi/nplot;
Asqd=[1.01*ones(nap,1);zeros(nplot-nap,1)];
Asqdu=[1.01*ones(nas-1,1);(10^(-dBas/10))*ones(nplot-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(nplot-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+1,1)];

% Desired pass-band group delay response
ntp=ceil(nplot*ftp/0.5)+1;
wt=wa(1:ntp);
Td=td*ones(ntp,1);
Tdu=Td+(tdr*ones(ntp,1)/2);
Tdl=Td-(tdr*ones(ntp,1)/2);
Wt=Wtp*ones(ntp,1);

% Desired pass-band phase response
npp=ntp;
wp=wt;
Pd=-td*wp;
Pdu=Pd+(ppr*ones(npp,1)/2);
Pdl=Pd-(ppr*ones(npp,1)/2);
Wp=Wpp*ones(npp,1);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("td=%d,tdr=%g,Wtp=%g",td,tdr,Wtp));

% Response for h0
Asq0=directFIRnonsymmetricAsq(wa,h0);
T0=directFIRnonsymmetricT(wt,h0);
P0=directFIRnonsymmetricP(wp,h0);

% Low-pass filter specification from directFIRnonsymmetric_kyp_lowpass_test.m
h1 = [ -0.0051265021,  0.0016175177,  0.0105219803,  0.0112679516, ... 
       -0.0056422723, -0.0322885625, -0.0380873962,  0.0111538169, ... 
        0.1199640324,  0.2452471030,  0.3165455324,  0.2850385994, ... 
        0.1633589480,  0.0200527495, -0.0687888254, -0.0723906068, ... 
       -0.0200215870,  0.0308005828,  0.0417346601,  0.0166222841, ... 
       -0.0135491195, -0.0232109906, -0.0113637927,  0.0051353433, ... 
        0.0113227829,  0.0060896064, -0.0017160091, -0.0045556794, ... 
       -0.0022753072,  0.0007317681,  0.0013737808 ];

% Response for h1
Asq1=directFIRnonsymmetricAsq(wa,h1);
T1=directFIRnonsymmetricT(wt,h1);
P1=directFIRnonsymmetricP(wp,h1);

% Update constraints
vR0=directFIRnonsymmetric_slb_update_constraints ...
      (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,P0,Pdu,Pdl,Wp,tol);
vS1=directFIRnonsymmetric_slb_update_constraints ...
      (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,P1,Pdu,Pdl,Wp,tol);

% Show constraints
printf("vR0 before exchange constraints:\n");
directFIRnonsymmetric_slb_show_constraints(vR0,wa,Asq0,wt,T0,wp,P0);
printf("vS1 before exchange constraints:\n");
directFIRnonsymmetric_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
strd=sprintf("directFIRnonsymmetric_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tdr=%g,Wtp=%g", ...
             fap,dBap,Wap,fas,dBas,Was,tdr,Wtp);
fa=wa*0.5/pi;
subplot(211);
plot(fa(1:nap),10*log10([Asq0(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([0,fap,-0.1,0.1]);
strM0=sprintf(strM,"0");
title(strM0);
ylabel("Amplitude(dB)");
subplot(212);
plot(fa(nas:end),10*log10([Asq0(nas:end),Asqdu(nas:end)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([fas,0.5,-80,-30]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
zticks([]);
print(sprintf(strd,"0Asq"),"-dpdflatex");
close

% Plot group delay
subplot(111);
ft=wt*0.5/pi;
plot(ft,[T0,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),"*", ...
     ft(vR0.tu),T0(vR0.tu),"+");
title(strM0);
ylabel("Delay(samples)");
xlabel("Frequency")
zticks([]);
print(sprintf(strd,"0T"),"-dpdflatex");
close

% Plot phase
subplot(111);
fp=wp*0.5/pi;
plot(fp,[P0-Pd,Pdu-Pd,Pdl-Pd], ...
     fp(vR0.pl),P0(vR0.pl)-Pd(vR0.pl),"*", ...
     fp(vR0.pu),P0(vR0.pu)-Pd(vR0.pu),"+");
title(strM0);
ylabel("Phase(rad.)");
xlabel("Frequency")
zticks([]);
print(sprintf(strd,"0P"),"-dpdflatex");
close

% Exchange constraints
[vR1,vS1,exchanged] = directFIRnonsymmetric_slb_exchange_constraints ...
                        (vS1,vR0,Asq1,Asqdu,Asqdl,T1,Tdu,Tdl,P1,Pdu,Pdl,tol);
printf("vR1 after exchange constraints:\n");
directFIRnonsymmetric_slb_show_constraints(vR1,wa,Asq1,wt,T1,wp,P1);
printf("vS1 after exchange constraints:\n");
directFIRnonsymmetric_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
subplot(211);
plot(fa(1:nap),10*log10([Asq0(1:nap),Asq1(1:nap), ...
                        Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+", ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),"*", ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),"+");
axis([0,fap,-0.1,0.1]);
strM1=sprintf(strM,"1");
title(strM1);
ylabel("Amplitude(dB)");
legend("Asq0","Asq1","Asqdu","Asqdu+tol","location","southwest");
legend("boxoff");
subplot(212);
plot(fa(nas:end), ...
     10*log10([Asq0(nas:end),Asq1(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(nplot-nas+1,1)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+", ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),"*", ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),"+");
axis([fas 0.5 -80 -30]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
zticks([]);
print(sprintf(strd,"1Asq"),"-dpdflatex");
close

% Plot group delay
subplot(111);
plot(ft,[T0,T1,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),"*", ...
     ft(vR0.tu),T0(vR0.tu),"+", ...
     ft(vS1.tl),T1(vS1.tl),"*", ...
     ft(vS1.tu),T1(vS1.tu),"+");
axis([0 ftp td-(tdr*2) td+(tdr*4)]);
title(strM1);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("T0","T1","Tdu","Tdl","location","northwest");
legend("boxoff");
zticks([]);
print(sprintf(strd,"1T"),"-dpdflatex");
close

% Plot phase
subplot(111);
plot(fp,[P0-Pd,P1-Pd,Pdu-Pd,Pdl-Pd], ...
     fp(vR0.pl),P0(vR0.pl)-Pd(vR0.pl),"*", ...
     fp(vR0.pu),P0(vR0.pu)-Pd(vR0.pu),"+", ...
     fp(vS1.pl),P1(vS1.pl)-Pd(vS1.pl),"*", ...
     fp(vS1.pu),P1(vS1.pu)-Pd(vS1.pu),"+");
axis([0 fpp -(ppr*6) +(ppr*6)]);
title(strM1);
ylabel("Phase(rad.)");
xlabel("Frequency")
legend("P0","P1","Pdu","Pdl","location","northwest");
legend("boxoff");
zticks([]);
print(sprintf(strd,"1P"),"-dpdflatex");
close

diary off
movefile directFIRnonsymmetric_slb_exchange_constraints_test.diary.tmp ...
         directFIRnonsymmetric_slb_exchange_constraints_test.diary;
