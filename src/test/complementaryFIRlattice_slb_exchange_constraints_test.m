% complementaryFIRlattice_slb_exchange_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("complementaryFIRlattice_slb_exchange_constraints_test.diary");
delete("complementaryFIRlattice_slb_exchange_constraints_test.diary.tmp");
diary complementaryFIRlattice_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=1e-4
verbose=true

% Bandpass minimum-phase filter specification
Ud0=2;Vd0=0;Md0=14;Qd0=0;Rd0=1;
d0 = [   0.0920209477, ...
         0.9990000000,   0.5128855702, ...
         0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
        -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
         3.7000375301,   4.4072989555,   4.6685041037 ]';
[b0p,~]=x2tf(d0,Ud0,Vd0,Md0,Qd0,Rd0);
% Find lattice coefficients (b1 is scaled to |H|<=1 and returned as b)
[b0,bc0,k0,khat0]=complementaryFIRlattice(b0p(:));
k0=k0(:);
khat0=khat0(:);
Nk=length(k0);
% Frequency specifications
n=1024;
w=pi*(0:(n-1))'/n;
H0=freqz(b0,1,w);
P0=unwrap(arg(H0));
T0=delayz(b0,1,w);
fsl=0.05;fpl=0.1;fpu=0.2;fsu=0.25;
nsl=floor(n*fsl/0.5)+1;
npl=floor(n*fpl/0.5)+1;
npu=ceil(n*fpu/0.5)+1;
nsu=ceil(n*fsu/0.5)+1;
dBap=1;
dBas=30;
Wasl=100;Wap=1;Wasu=100;
tp=mean(T0(npl:npu));
tpr=1;
Wtp=0.01;
ppr=0.1;
Wpp=0.01;
% Squared-magnitude
wa=w;
Asq0=complementaryFIRlatticeAsq(wa,k0,khat0);
Asqd=[zeros(npl,1);ones(npu-npl,1);zeros(n-npu,1)];
Asqdu=[(10^(-dBas/10))*ones(nsl,1); ...
       ones(nsu-nsl,1); ...
       (10^(-dBas/10))*ones(n-nsu,1)];
Asqdl=[zeros(npl,1);(10^(-dBap/10))*ones(npu-npl,1);zeros(n-npu,1)];
Wa=[Wasl*ones(nsl,1); ...
    zeros(npl-nsl,1); ...
    Wap*ones(npu-npl,1); ...
    zeros(nsu-npu,1); ...
    Wasu*ones(n-nsu,1)];
% Delay
wt=w(npl:npu);
T0=complementaryFIRlatticeT(wt,k0,khat0);
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);
% Phase
wp=w(npl:npu);
P0=complementaryFIRlatticeP(wp,k0,khat0);
Pd=P0(1)+(tp*(wp(1)-wp));
Pdu=Pd+(ppr/2);
Pdl=Pd-(ppr/2);
Wp=Wpp*ones(length(wp),1);
         
% Coefficients from
% complementaryFIRlattice_socp_slb_bandpass_hilbert_test_k1_coef.m
k1 = [   0.9999999993,   0.9999999999,   0.9987097741,   0.9991009507, ... 
         1.0000000000,   1.0000000000,   0.9987473027,   0.9995621685, ... 
         0.9878925124,   0.9350003845,   0.9734067894,   0.9805643826, ... 
         0.8925526374,   0.9608338100,   0.9980857817,   0.9792929699, ... 
         0.1257408750 ]';
khat1 = [  -0.0324039009,   0.0176671468,   0.0605658486,   0.0537668873, ... 
            0.0035336035,  -0.0005284479,   0.0604145406,   0.0446914133, ... 
           -0.1587198964,  -0.3560982189,  -0.2313839125,   0.1989151079, ... 
            0.4519274572,   0.2790167406,  -0.0702888314,  -0.2052528749, ... 
            0.9920376363 ]';
Asq1=complementaryFIRlatticeAsq(wa,k1,khat1);
T1=complementaryFIRlatticeT(wt,k1,khat1);
P1=complementaryFIRlatticeP(wp,k1,khat1);

% Update constraints
vR0=complementaryFIRlattice_slb_update_constraints ...
      (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,P0,Pdu,Pdl,Wp,tol);
vS1=complementaryFIRlattice_slb_update_constraints ...
      (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,P1,Pdu,Pdl,Wp,tol);

% Show constraints
printf("vR0 before exchange constraints:\n");
complementaryFIRlattice_slb_show_constraints(vR0,w,Asq0,w,T0,w,P0);
printf("vS1 before exchange constraints:\n");
complementaryFIRlattice_slb_show_constraints(vS1,w,Asq1,w,T1,w,P1);

% Strings
strd=sprintf("complementaryFIRlattice_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fsl,fpl=%g,fpu=%g,fsu,dBap=%g,dBas=%g,tp=%g,tpr=%g,ppr=%g",
             fsl,fpl,fpu,fsu,dBap,dBas,tp,tpr,ppr);

% Plot amplitude
fa=wa*0.5/pi;
plot(fa,10*log10([Asq0,Asqdu,Asqdl]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([0,0.5,-35,0.25]);
strM0=sprintf(strM,"0");
title(strM0);
ylabel("Amplitude");
xlabel("Frequency")
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
print(sprintf(strd,"0T"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
plot(fp,[P0,Pdu,Pdl], ...
     fp(vR0.pl),P0(vR0.pl),"*", ...
     fp(vR0.pu),P0(vR0.pu),"+");
title(strM0);
ylabel("Phase");
xlabel("Frequency")
print(sprintf(strd,"0P"),"-dpdflatex");
close

% Exchange constraints
[vR1,vS1,exchanged] = complementaryFIRlattice_slb_exchange_constraints ...
                        (vS1,vR0,Asq1,Asqdu,Asqdl,T1,Tdu,Tdl,P1,Pdu,Pdl,tol);
printf("vR1 after exchange constraints:\n");
complementaryFIRlattice_slb_show_constraints(vR1,w,Asq1,w,T1,w,P1);
printf("vS1 after exchange constraints:\n");
complementaryFIRlattice_slb_show_constraints(vS1,w,Asq1,w,T1,w,P1);

% Plot amplitude
plot(fa,10*log10([Asq1,Asqdu,Asqdl]), ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),"*", ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),"+");
axis([0,0.5,-35,0.25]);
strM1=sprintf(strM,"1");
title(strM1);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"1Asq"),"-dpdflatex");
close

% Plot group delay
plot(ft,[T1,Tdu,Tdl], ...
     ft(vS1.tl),T1(vS1.tl),"*", ...
     ft(vS1.tu),T1(vS1.tu),"+");
title(strM1);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"1T"),"-dpdflatex");
close

% Plot phase
plot(fp,[P1,Pdu,Pdl], ...
     fp(vS1.pl),P1(vS1.pl),"*", ...
     fp(vS1.pu),P1(vS1.pu),"+");
title(strM1);
ylabel("Phase");
xlabel("Frequency")
print(sprintf(strd,"1P"),"-dpdflatex");
close

% Done
diary off
movefile complementaryFIRlattice_slb_exchange_constraints_test.diary.tmp ...
         complementaryFIRlattice_slb_exchange_constraints_test.diary;
