% schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.diary");
delete...
  ("schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

%
% Filter from tarczynski_frm_halfband_test.m
%
r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
         0.0035706175,  -0.0098219303 ]';
aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
        -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
        -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
        -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
         0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
        -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
        -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
        -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
        -0.0019232288 ]';
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
na=length(aa0);  % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay
fap=0.02 % Amplitude pass band edge
fas=0.48 % Amplitude stop band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
ftp=0.05 % Delay pass band edge
fts=0.45 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
tpr=0.4 % Peak-to-peak pass band delay ripple
Wtp=0.2 % Pass band delay weight
fpp=0.05 % Phase pass band edge
fps=0.45 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)
ppr=0.002*pi % Peak-to-peak pass band phase ripple
Wpp=0.2 % Pass band phase weight

% Calculate Schur one-multiplier lattice FRM Hilbert filter coefficients
rm1=ones(length(r0),1);
rm1(2:2:end)=-1;
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0).*rm1,r0.*rm1);
um1=ones((dmask/2)+1,1);
um1(2:2:end)=-1;
u0=aa0(1:2:(dmask+1)).*um1;
vm1=um1(1:(dmask/2));
v0=aa0(2:2:dmask).*vm1;

%
% Filter from tarczynski_frm_hilbert_test.m
%
r1 = [   1.0000000000,  -0.2601535016,  -0.0585423666,  -0.0138388212, ... 
        -0.0058161583,   0.0009139294 ]';
u1 = [  -0.0087030511,   0.0141455165,  -0.0185956688,   0.0261090002, ... 
        -0.0319048413,   0.0363169770,  -0.0436616121,   0.0472945986, ... 
         0.4468293109 ]';
v1 = [   0.0003832266,   0.0017197905,  -0.0046597683,   0.0135556644, ... 
        -0.0252428888,   0.0484350620,  -0.0964367347,   0.3154148817 ]';
rm1=ones(length(r1),1);
rm1(2:2:end)=-1;
[k1,epsilon1,p1,~] = tf2schurOneMlattice(flipud(r1).*rm1,r1.*rm1);
um1=ones(length(u1),1);
um1(2:2:end)=-1;
u1=u1.*um1;
vm1=ones(length(v1),1);
vm1(2:2:end)=-1;
v1=v1.*vm1;

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=floor(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
wa=w(nap:nas);
Asqd=ones(length(wa),1);
Asqdu=Asqd;
Asqdl=10^(-dBap/10)*ones(length(wa),1);
Wa=Wap*ones(length(wa),1);

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(length(wt),1);
Tdu=(tpr/2)*ones(length(wt),1);
Tdl=-Tdu;
Wt=Wtp*ones(length(wt),1);

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=zeros(length(wp),1);
Pdu=pp+(ppr/2)*ones(length(wp),1);
Pdl=pp-(ppr/2)*ones(length(wp),1);
Wp=Wpp*ones(length(wp),1);

% Common strings
strMa=sprintf("%%s:fap=%g,fas=%g,dBap=%g,Wap=%g,",fap,fas,dBap,Wap);
strMt=sprintf("%%s:ftp=%g,fts=%g,tp=%d,tpr=%g,Wtp=%g",ftp,fts,tp,tpr,Wtp);
strMp=sprintf("%%s:fpp=%g,fps=%g,ppr=%g*pi,Wpp=%g,",fpp,fps,ppr/pi,Wpp);
strd=sprintf("schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test_%%s");

% Calculate frequency response
Asq0=schurOneMAPlattice_frm_hilbertAsq(wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
T0=schurOneMAPlattice_frm_hilbertT(wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
P0=schurOneMAPlattice_frm_hilbertP(wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Asq1=schurOneMAPlattice_frm_hilbertAsq(wa,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
T1=schurOneMAPlattice_frm_hilbertT(wt,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
P1=schurOneMAPlattice_frm_hilbertP(wp,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);

% Update constraints
vR0=schurOneMAPlattice_frm_hilbert_slb_update_constraints ...
      (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,P0,Pdu,Pdl,Wp,tol);
vS1=schurOneMAPlattice_frm_hilbert_slb_update_constraints ...
      (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,P1,Pdu,Pdl,Wp,tol);

% Show constraints
printf("vR0 before exchange constraints:\n");
schurOneMAPlattice_frm_hilbert_slb_show_constraints(vR0,wa,Asq0,wt,T0,wp,P0);
printf("vS1 before exchange constraints:\n");
schurOneMAPlattice_frm_hilbert_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
strd=sprintf("schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test_%%s");
fa=wa*0.5/pi;
plot(fa,10*log10([Asq0,Asqdu,Asqdl]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),'*', ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),'+');
%axis([0,0.5,-1,1]);
strMa0=sprintf(strMa,"Asq0");
title(strMa0);
ylabel("Amplitude(dB)");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"Asq0"),"-dpdflatex");
close

% Plot zero-phase group delay
ft=wt*0.5/pi;
plot(ft,[T0,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),'*', ...
     ft(vR0.tu),T0(vR0.tu),'+');
strMt=sprintf("T0:ftp=%g,fts=%g,tp=%d,tpr=%g,Wtp=%g",ftp,fts,tp,tpr,Wtp);
strMt0=sprintf(strMt,"T0");
title(strMt0);
ylabel("Zero-phase group delay");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"T0"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
plot(fp,[P0,Pdu,Pdl]/pi, ...
     fp(vR0.pl),P0(vR0.pl)/pi,'*', ...
     fp(vR0.pu),P0(vR0.pu)/pi,'+');
strMp0=sprintf(strMp,"P0");
title(strMp0);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"P0"),"-dpdflatex");
close

% Exchange constraints
[vR2,vS1,exchanged]=schurOneMAPlattice_frm_hilbert_slb_exchange_constraints...
                      (vS1,vR0,Asq1,Asqdu,Asqdl,T1,Tdu,Tdl,P1,Pdu,Pdl,tol);
printf("exchanged=%d\n",exchanged);
printf("vR2 after exchange constraints:\n");
schurOneMAPlattice_frm_hilbert_slb_show_constraints(vR2,wa,Asq1,wt,T1,wp,P1);
printf("vS1 after exchange constraints:\n");
schurOneMAPlattice_frm_hilbert_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
plot(fa,10*log10([Asq0,Asq1,Asqdu,Asqdl]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),'*', ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),'+', ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),'*', ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),'+');
%axis([0,0.5,-1,1]);
strMa1=sprintf(strMa,"Asq1");
title(strMa1);
ylabel("Amplitude(dB)");
xlabel("Frequency")
legend("Asq0","Asq1","Asqdu","Asqdl","location","south");
legend("boxoff");
print(sprintf(strd,"Asq1"),"-dpdflatex");
close

% Plot zero-phase group delay
plot(ft,[T0,T1,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),'*',ft(vR0.tu),T0(vR0.tu),'+', ...
     ft(vS1.tl),T1(vS1.tl),'*',ft(vS1.tu),T1(vS1.tu),'+');
%axis([0 0.5 -2 ]);
strMt1=sprintf(strMt,"T1");
title(strMt1);
ylabel("Zero-phase group delay");
xlabel("Frequency")
legend("T0","T1","Tdu","Tdl","location","north");
legend("boxoff");
print(sprintf(strd,"T1"),"-dpdflatex");
close

% Plot phase
plot(fp,[P0,P1,Pdu,Pdl], ...
     fp(vR0.pl),P0(vR0.pl),'*',fp(vR0.pu),P0(vR0.pu),'+', ...
     fp(vS1.pl),P1(vS1.pl),'*',fp(vS1.pu),P1(vS1.pu),'+');
%axis([0 0.5 -2 ]);
strMp1=sprintf(strMp,"P1");
title(strMp1);
ylabel("Zero-phase group delay");
xlabel("Frequency")
legend("P0","P1","Pdu","Pdl","location","north");
legend("boxoff");
print(sprintf(strd,"P1"),"-dpdflatex");
close

diary off
movefile schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.diary.tmp...
       schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.diary;
