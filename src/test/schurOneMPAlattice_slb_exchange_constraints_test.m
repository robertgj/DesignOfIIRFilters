% schurOneMPAlattice_slb_exchange_constraints_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("schurOneMPAlattice_slb_exchange_constraints_test.diary");
delete("schurOneMPAlattice_slb_exchange_constraints_test.diary.tmp");
diary schurOneMPAlattice_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

% Low pass filter from parallel_allpass_socp_slb_flat_delay_test.m 
ma=11; % Allpass model filter A denominator order
mb=12; % Allpass model filter B denominator order
difference=false;
fap=0.15; % Pass band amplitude response edge
dBap=0.5; % Pass band amplitude response ripple
Wap=1; % Pass band amplitude response weight
fas=0.2; % Stop band amplitude response edge
dBas=41; % Stop band amplitude response ripple
Was=750; % Stop band amplitude response weight
ftp=0.175; % Pass band group delay response edge
td=(ma+mb)/2; % Pass band nominal group delay
tdr=0.04; % Pass band group delay response ripple
Wtp=1; % Pass band group delay response weight
fpp=0.175; % Pass band phase response edge
ppr=0.0016; % Pass band phase response ripple
Wpp=0.1; % Pass band phase response weight
fdp=fap % Pass band dAsqdw response edge
dpr=0.5; % Pass band dAsqdw response ripple
Wdp=0.1; % Pass band dAsqdw response weight

% Desired squared magnitude response
nplot=1000;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
wa=(0:(nplot-1))'*pi/nplot;
Asqd=[0.99*ones(nap,1);zeros(nplot-nap,1)];
Asqdu=[0.99*ones(nas-1,1);(10^(-dBas/10))*ones(nplot-nas+1,1)];
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

% Desired pass-band dAsqdw response
ndp=nap;
wd=wa(1:ndp);
Dd=zeros(size(wd));
Ddu=Dd+(dpr*ones(ndp,1)/2);
Ddl=Dd-(dpr*ones(ndp,1)/2);
Wd=Wdp*ones(ndp,1);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("td=%d,tdr=%g,Wtp=%g",td,tdr,Wtp));

% Initial coefficients found by tarczynski_parallel_allpass_test.m
Da0 = [  1.0000000000,   0.6972799348,  -0.2975063113,  -0.3126563765, ... 
        -0.1822053263,   0.0540552916,   0.0875338489,  -0.1043232804, ... 
         0.1845967341,   0.0440769557,  -0.1321004328,   0.0451935427 ]';
Db0 = [  1.0000000000,   0.1561449789,  -0.3135750674,   0.3178485356, ... 
         0.1300072034,   0.0784802475,  -0.0638101246,  -0.1841985892, ... 
         0.2692567260,  -0.0893425985,  -0.1362443439,   0.1339411525, ... 
        -0.0582212026 ]';
         
% Lattice decomposition of Da0, Db0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db0),Db0);

% Response for Da0,Db0
Asq0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference);
T0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                       difference);
P0=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                       difference);
D0=schurOneMPAlatticedAsqdw(wd,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                            difference);

% Low pass filter from parallel_allpass_socp_slb_flat_delay_test.m 
Da1 = [   1.0000000000,   0.3931432341,  -0.2660133321,  -0.0850275861, ... 
         -0.2707651069,  -0.0298153197,   0.1338823243,  -0.0589362474, ... 
          0.1650490792,   0.0296371262,  -0.1113859180,   0.0372881323 ]';
Db1 = [   1.0000000000,  -0.1344939785,  -0.0918734630,   0.4461033862, ... 
         -0.1115261080,   0.1180340147,   0.0396352218,  -0.2006006436, ... 
          0.2105512466,  -0.0838522576,  -0.1001537312,   0.1080994566, ... 
         -0.0610732672 ]';
% Lattice decomposition Da1,Db1
[A1k1,A1epsilon1,A1p1,~] = tf2schurOneMlattice(flipud(Da1),Da1);
[A2k1,A2epsilon1,A2p1,~] = tf2schurOneMlattice(flipud(Db1),Db1);
% Response for Da1,Db1
Asq1=schurOneMPAlatticeAsq(wa,A1k1,A1epsilon1,A1p1,A2k1,A2epsilon1,A2p1, ...
                           difference);
T1=schurOneMPAlatticeT(wt,A1k1,A1epsilon1,A1p1,A2k1,A2epsilon1,A2p1, ...
                       difference);
P1=schurOneMPAlatticeP(wp,A1k1,A1epsilon1,A1p1,A2k1,A2epsilon1,A2p1, ...
                       difference);
D1=schurOneMPAlatticedAsqdw(wd,A1k1,A1epsilon1,A1p1,A2k1,A2epsilon1,A2p1, ...
                            difference);

% Update constraints
vR0=schurOneMPAlattice_slb_update_constraints ...
      (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,P0,Pdu,Pdl,Wp,D0,Ddu,Ddl,Wd,tol);
vS1=schurOneMPAlattice_slb_update_constraints ...
      (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,P1,Pdu,Pdl,Wp,D1,Ddu,Ddl,Wd,tol);

% Show constraints
printf("vR0 before exchange constraints:\n");
schurOneMPAlattice_slb_show_constraints(vR0,wa,Asq0,wt,T0,wp,P0,wd,D0);
printf("vS1 before exchange constraints:\n");
schurOneMPAlattice_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1,wd,D1);

% Plot amplitude
strd=sprintf("schurOneMPAlattice_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tdr=%g,Wtp=%g",
             fap,dBap,Wap,fas,dBas,Was,tdr,Wtp);
fa=wa*0.5/pi;
subplot(211);
plot(fa(1:nap),10*log10([Asq0(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),'*', ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),'+');
axis([0,fap,-4,1]);
strM0=sprintf(strM,"0");
title(strM0);
ylabel("Amplitude(dB)");
subplot(212);
plot(fa(nas:end),10*log10([Asq0(nas:end),Asqdu(nas:end)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),'*', ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),'+');
axis([fas,0.5,-60,-30]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"0Asq"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[T0,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),'*', ...
     ft(vR0.tu),T0(vR0.tu),'+');
title(strM0);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"0T"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
plot(fp,[P0-Pd,Pdu-Pd,Pdl-Pd], ...
     fp(vR0.pl),P0(vR0.pl)-Pd(vR0.pl),'*', ...
     fp(vR0.pu),P0(vR0.pu)-Pd(vR0.pu),'+');
title(strM0);
ylabel("Phase(rad.)");
xlabel("Frequency")
print(sprintf(strd,"0P"),"-dpdflatex");
close

% Plot dAsqdw
fd=wd*0.5/pi;
plot(fd,[D0-Dd,Ddu-Dd,Ddl-Dd], ...
     fd(vR0.dl),D0(vR0.dl)-Dd(vR0.dl),'*', ...
     fd(vR0.du),D0(vR0.du)-Dd(vR0.du),'+');
title(strM0);
ylabel("dAsqdw");
xlabel("Frequency")
print(sprintf(strd,"0D"),"-dpdflatex");
close

% Exchange constraints
[vR1,vS1,exchanged] = schurOneMPAlattice_slb_exchange_constraints ...
                        (vS1,vR0, ...
                         Asq1,Asqdu,Asqdl,T1,Tdu,Tdl,P1,Pdu,Pdl,D1,Ddu,Ddl,tol);
printf("vR1 after exchange constraints:\n");
schurOneMPAlattice_slb_show_constraints(vR1,wa,Asq1,wt,T1,wp,P1,wd,D1);
printf("vS1 after exchange constraints:\n");
schurOneMPAlattice_slb_show_constraints(vS1,wa,Asq1,wt,T1,wp,P1,wd,D1);

% Plot amplitude
subplot(211);
plot(fa(1:nap),10*log10([Asq0(1:nap),Asq1(1:nap), ...
                        Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),'*', ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),'+', ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),'*', ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),'+');
axis([0,fap,-4,1]);
strM1=sprintf(strM,"1");
title(strM1);
ylabel("Amplitude(dB)");
legend("Asq0","Asq1","Asqdu","Asqdu+tol","location","southwest");
legend("boxoff");
subplot(212);
plot(fa(nas:end), ...
     10*log10([Asq0(nas:end),Asq1(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(nplot-nas+1,1)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),'*', ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),'+', ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),'*', ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),'+');
axis([fas 0.5 -60 -30]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"1Asq"),"-dpdflatex");
close

% Plot group delay
plot(ft,[T0,T1,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),'*', ...
     ft(vR0.tu),T0(vR0.tu),'+', ...
     ft(vS1.tl),T1(vS1.tl),'*', ...
     ft(vS1.tu),T1(vS1.tu),'+');
axis([0 ftp td-(tdr*2) td+(tdr*4)]);
title(strM1);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("T0","T1","Tdu","Tdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"1T"),"-dpdflatex");
close

% Plot phase
plot(fp,[P0-Pd,P1-Pd,Pdu-Pd,Pdl-Pd], ...
     fp(vR0.pl),P0(vR0.pl)-Pd(vR0.pl),'*',
     fp(vR0.pu),P0(vR0.pu)-Pd(vR0.pu),'+', ...
     fp(vS1.pl),P1(vS1.pl)-Pd(vS1.pl),'*',
     fp(vS1.pu),P1(vS1.pu)-Pd(vS1.pu),'+');
axis([0 fpp -(ppr*2) +(ppr*2)]);
title(strM1);
ylabel("Phase(rad.)");
xlabel("Frequency")
legend("P0","P1","Pdu","Pdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"1P"),"-dpdflatex");
close

% Plot dAsqdw
plot(fd,[D0-Dd,D1-Dd,Ddu-Dd,Ddl-Dd], ...
     fd(vR0.dl),D0(vR0.dl)-Dd(vR0.dl),'*',
     fd(vR0.du),D0(vR0.du)-Dd(vR0.du),'+', ...
     fd(vS1.dl),D1(vS1.dl)-Dd(vS1.dl),'*',
     fd(vS1.du),D1(vS1.du)-Dd(vS1.du),'+');
axis([0 fdp -(dpr*8) +(dpr*4)]);
title(strM1);
ylabel("dAsqdw");
xlabel("Frequency")
legend("D0","D1","Ddu","Ddl","location","northwest");
legend("boxoff");
print(sprintf(strd,"1D"),"-dpdflatex");
close

diary off
movefile schurOneMPAlattice_slb_exchange_constraints_test.diary.tmp ...
         schurOneMPAlattice_slb_exchange_constraints_test.diary;
