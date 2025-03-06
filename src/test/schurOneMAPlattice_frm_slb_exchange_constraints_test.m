% schurOneMAPlattice_frm_slb_exchange_constraints_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frm_slb_exchange_constraints_test.diary");
delete("schurOneMAPlattice_frm_slb_exchange_constraints_test.diary.tmp");
diary schurOneMAPlattice_frm_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

%
% Use the filters found by tarczynski_frm_allpass_test.m
%
r0 = [   1.0000000000,   0.2459795566,   0.4610947857,  -0.1206398420, ... 
        -0.0518355550,   0.0567634483,  -0.0264386549,   0.0246267271, ... 
        -0.0176437270,  -0.0008974729,   0.0056956381 ]';
aa0 = [  -0.0216588504,  -0.0114618315,   0.0302611209,  -0.0043408321, ... 
         -0.0274279593,   0.0062386856,   0.0166035962,  -0.0208670992, ... 
         -0.0036770815,   0.0566015372,   0.0039899993,  -0.0683299841, ... 
          0.0358708912,   0.0511704141,  -0.0490317610,  -0.0006425193, ... 
          0.0797439710,  -0.0690263959,  -0.1272015380,   0.2921723028, ... 
          0.6430650464,   0.2921723028,  -0.1272015380,  -0.0690263959, ... 
          0.0797439710,  -0.0006425193,  -0.0490317610,   0.0511704141, ... 
          0.0358708912,  -0.0683299841,   0.0039899993,   0.0566015372, ... 
         -0.0036770815,  -0.0208670992,   0.0166035962,   0.0062386856, ... 
         -0.0274279593,  -0.0043408321,   0.0302611209,  -0.0114618315, ... 
         -0.0216588504 ]';
ac0 = [  -0.0181078194,   0.0563970997,   0.1769164319,   0.0607733538, ... 
         -0.0221620117,  -0.0050415353,   0.0112963303,  -0.0009704899, ... 
         -0.0074583106,  -0.0391109460,   0.1410234146,   0.4815173162, ... 
          0.1799696079,  -0.0814357412,  -0.0115214971,   0.0590494998, ... 
         -0.0510521399,  -0.0105302211,   0.0627620289,  -0.0675640305, ... 
         -0.0255600918,  -0.0675640305,   0.0627620289,  -0.0105302211, ... 
         -0.0510521399,   0.0590494998,  -0.0115214971,  -0.0814357412, ... 
          0.1799696079,   0.4815173162,   0.1410234146,  -0.0391109460, ... 
         -0.0074583106,  -0.0009704899,   0.0112963303,  -0.0050415353, ... 
         -0.0221620117,   0.0607733538,   0.1769164319,   0.0563970997, ... 
         -0.0181078194 ]';
% Use the filters found by iir_frm_allpass_slb_socp_test.m
r1 = [    1.0000000000,  -0.0190983455,   0.4852180005,   0.0184457901, ... 
         -0.1107294715,   0.0002597931,   0.0399275510,   0.0123959065, ... 
         -0.0251932629,  -0.0022670138,   0.0034269976 ]';
aa1 = [  -0.0036773480,   0.0013707401,   0.0051674803,  -0.0073370335, ... 
         -0.0006206325,   0.0080979826,  -0.0044516748,  -0.0083206127, ... 
          0.0095194746,   0.0130342148,  -0.0168241675,  -0.0117669240, ... 
          0.0348589917,  -0.0055201310,  -0.0430346789,   0.0337747143, ... 
          0.0504846407,  -0.0843097555,  -0.0629252613,   0.3064790704, ... 
          0.5703148458,   0.3064790704,  -0.0629252613,  -0.0843097555, ... 
          0.0504846407,   0.0337747143,  -0.0430346789,  -0.0055201310, ... 
          0.0348589917,  -0.0117669240,  -0.0168241675,   0.0130342148, ... 
          0.0095194746,  -0.0083206127,  -0.0044516748,   0.0080979826, ... 
         -0.0006206325,  -0.0073370335,   0.0051674803,   0.0013707401, ... 
         -0.0036773480 ]';
ac1 = [   0.0026398284,  -0.0024033377,  -0.0009245527,   0.0057392210, ... 
         -0.0062620018,   0.0010366829,   0.0078068424,  -0.0096921512, ... 
          0.0011490473,   0.0156921633,  -0.0178227247,  -0.0006969519, ... 
          0.0282113314,  -0.0333881034,   0.0024084035,   0.0491921939, ... 
         -0.0647158208,   0.0025859605,   0.1348701030,  -0.2732902769, ... 
         -0.6665377723,  -0.2732902769,   0.1348701030,   0.0025859605, ... 
         -0.0647158208,   0.0491921939,   0.0024084035,  -0.0333881034, ... 
          0.0282113314,  -0.0006969519,  -0.0178227247,   0.0156921633, ... 
          0.0011490473,  -0.0096921512,   0.0078068424,   0.0010366829, ... 
         -0.0062620018,   0.0057392210,  -0.0009245527,  -0.0024033377, ... 
          0.0026398284 ]';
%
% Filter specification
%
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dmask=(length(aa0)-1)/2 % FIR masking filter delay
fap=0.29; % Pass band edge
dBap=0.1; % Pass band amplitude ripple
Wap=1; % Pass band amplitude weight
fas=0.3125; % Pass band edge
dBas=50; % Stop band amplitude ripple
Was=10; % Stop band amplitude weight
tp=(Mmodel*Dmodel)+dmask % FRM filter nominal passband delay
tpr=0.5; % Pass band delay ripple
Wtp=0.05; % Pass band delay weight
pp=0 % FRM filter nominal passband phase
ppr=0.005*pi; % Pass band phase ripple
Wpp=0.01; % Pass band phase weight

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0),r0);
u0=aa0((dmask+1):end);
v0=ac0((dmask+1):end);
[k1,epsilon1,p1,~] = tf2schurOneMlattice(flipud(r1),r1);
u1=aa1((dmask+1):end);
v1=ac1((dmask+1):end);

% Frequency vectors
n=1000;
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];

% Group delay constraints
wt=wa(1:nap);
Wt=Wtp*ones(nap,1);
Td=zeros(nap,1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);

% Phase constraints
wp=wa(1:nap);
Wp=Wpp*ones(nap,1);
Pd=zeros(nap,1);
Pdu=Pd+(ppr/2);
Pdl=Pd-(ppr/2);

% Response of k0,u0,v0
[Asq0,P0,T0]=schurOneMAPlattice_frm(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
P0=P0(1:nap);
T0=T0(1:nap);

% Response of k1,u1,v1
[Asq1,P1,T1]=schurOneMAPlattice_frm(w,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
P1=P1(1:nap);
T1=T1(1:nap);

% Update constraints
vR0=schurOneMAPlattice_frm_slb_update_constraints ...
       (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,P0,Pdu,Pdl,Wp,tol);
vS0=schurOneMAPlattice_frm_slb_update_constraints ...
       (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,P1,Pdu,Pdl,Wp,tol);

% Show constraints
printf("vR0 before exchange constraints:\n");
schurOneMAPlattice_frm_slb_show_constraints(vR0,wa,Asq0,wt,T0,wp,P0);
printf("vS0 before exchange constraints:\n");
schurOneMAPlattice_frm_slb_show_constraints(vS0,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
strd=sprintf("schurOneMAPlattice_frm_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tpr=%g,Wtp=%g",
             fap,dBap,Wap,fas,dBas,Was,tpr,Wtp);
f=w*0.5/pi;
subplot(211);
plot(f(1:nap),10*log10([Asq0(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     f(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     f(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([0,fap,-1,1]);
strM0=sprintf(strM,"Asq0");
title(strM0);
ylabel("Amplitude(dB)");
subplot(212);
plot(f(nas:end),10*log10([Asq0(nas:end),Asqdu(nas:end)]), ...
     f(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     f(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([fas,0.5,-60,-20]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"Asq0"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[T0,Tdu,Tdl],ft(vR0.tl),T0(vR0.tl),"*",ft(vR0.tu),T0(vR0.tu),"+");
axis([0 fap -(tpr*10) +(tpr*10)]);
title(strM0);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"T0"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
plot(fp,[P0,Pdu,Pdl],fp(vR0.pl),P0(vR0.pl),"*",fp(vR0.pu),P0(vR0.pu),"+");
axis([0 fap [-1 1]*(ppr*40/pi)]);
title(strM0);
ylabel("Phase(rad.)");
xlabel("Frequency")
print(sprintf(strd,"P0"),"-dpdflatex");
close

% Exchange constraints
[vR1,vS1,exchanged] = ...
schurOneMAPlattice_frm_slb_exchange_constraints ...
  (vS0,vR0,Asq1,Asqdu,Asqdl,T1,Tdu,Tdl,P1,Pdu,Pdl,tol);
printf("vR1 after exchange constraints:\n");
schurOneMAPlattice_frm_slb_show_constraints(vR1,wa,Asq1,wt,T1,wp,P1);
printf("vS1 after exchange constraints:\n");
schurOneMAPlattice_frm_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
subplot(211);
plot(f(1:nap),10*log10([Asq0(1:nap),Asq1(1:nap), ...
                 Asqdu(1:nap),Asqdl(1:nap)]), ...
     f(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     f(vR0.au),10*log10(Asq0(vR0.au)),"+", ...
     f(vS1.al),10*log10(Asq0(vS1.al)),"s", ...
     f(vS1.au),10*log10(Asq1(vS1.au)),"d");
axis([0,fap,-1,1]);
strM1=sprintf(strM,"Asq1");
title(strM1);
ylabel("Amplitude(dB)");
subplot(212);
plot(f(nas:end), ...
     10*log10([Asq0(nas:end),Asq1(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(n-nas+1,1)]), ...
     f(vR1.al),10*log10(Asq0(vR1.al)),"*", ...
     f(vR1.au),10*log10(Asq0(vR1.au)),"+", ...
     f(vS1.al),10*log10(Asq1(vS1.al)),"s", ...
     f(vS1.au),10*log10(Asq1(vS1.au)),"d");
axis([fas 0.5 -60 -20]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
legend("Asq0","Asq1","Asqdu","Asqdu+tol");
legend("location","north");
legend("boxoff");
print(sprintf(strd,"Asq1"),"-dpdflatex");
close

% Plot group delay
plot(ft,[T0,T1,Tdu,Tdl], ...
     ft(vR1.tl),T0(vR1.tl),"*",f(vR1.tu),T0(vR1.tu),"+", ...
     ft(vS1.tl),T1(vS1.tl),"s",f(vS1.tu),T1(vS1.tu),"d");
axis([0 fap -(tpr*10) +(tpr*10)]);
title(strM1);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("T0","T1","Tdu","Tdl");
legend("location","northwest");
legend("boxoff");
print(sprintf(strd,"T1"),"-dpdflatex");
close

% Plot phase
plot(fp,[P0,P1,Pdu,Pdl], ...
     fp(vR1.pl),P0(vR1.pl),"*",f(vR1.pu),P0(vR1.pu),"+", ...
     fp(vS1.pl),P1(vS1.pl),"s",f(vS1.pu),P1(vS1.pu),"d");
axis([0 fap [-1 1]*(ppr*40/pi)]);
title(strM1);
ylabel("Phase(rad.)");
xlabel("Frequency")
legend("P0","P1","Pdu","Pdl");
legend("location","northwest");
legend("boxoff");
print(sprintf(strd,"P1"),"-dpdflatex");
close

% Done
diary off
movefile schurOneMAPlattice_frm_slb_exchange_constraints_test.diary.tmp ...
         schurOneMAPlattice_frm_slb_exchange_constraints_test.diary;
