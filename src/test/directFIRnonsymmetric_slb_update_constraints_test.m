% directFIRnonsymmetric_slb_update_constraints_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetric_slb_update_constraints_test.diary");
delete("directFIRnonsymmetric_slb_update_constraints_test.diary.tmp");
diary directFIRnonsymmetric_slb_update_constraints_test.diary.tmp

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
dBap=0.02; % Pass band amplitude response ripple
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

% Update constraints
vR0=directFIRnonsymmetric_slb_update_constraints ...
      (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,P0,Pdu,Pdl,Wp,tol);

% Show constraints
printf("vR0 after update constraints:\n");
directFIRnonsymmetric_slb_show_constraints(vR0,wa,Asq0,wt,T0,wp,P0);

% Plot amplitude
strd=sprintf("directFIRnonsymmetric_slb_update_constraints_test_%%s");
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

% Done
diary off
movefile directFIRnonsymmetric_slb_update_constraints_test.diary.tmp ...
         directFIRnonsymmetric_slb_update_constraints_test.diary;
