% schurOneMAPlattice_frm_slb_update_constraints_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_slb_update_constraints_test.diary");
unlink("schurOneMAPlattice_frm_slb_update_constraints_test.diary.tmp");
diary schurOneMAPlattice_frm_slb_update_constraints_test.diary.tmp

format compact;

verbose=true
tol=1e-5

%
% Initial filter is based on the filters found by tarczynski_frm_allpass_test.m
%
r0 = [    1.0000000000,   0.2459795566,   0.4610947857,  -0.1206398420, ... 
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
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
na=length(aa0);  % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0),r0);
u0=aa0((dmask+1):end);
v0=ac0((dmask+1):end);

%
% Filter specification
%
n=1000;
tol=1e-6
ctol=tol/10
fap=0.29 % Pass band edge
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
Wat=1 % Transition band amplitude weight
fas=0.3125 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=50 % Stop band amplitude weight
tp=(Mmodel*Dmodel)+dmask;
tpr=5 % Peak-to-peak pass band delay ripple
Wtp=0.05 % Pass band delay weight
pp=0 % Pass band zero-phase phase
ppr=0.02*pi % Peak-to-peak pass band phase ripple
Wpp=0.01 % Pass band phase weight

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:nap);
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

% Phase constraints
wp=w(1:nap);
Pd=zeros(nap,1);
Pdu=(ppr/2)*ones(nap,1);
Pdl=-Pdu;
Wp=Wpp*ones(nap,1);

% Response
[Asqk,Pk,Tk]=schurOneMAPlattice_frm(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);

% Constraints
vS=schurOneMAPlattice_frm_slb_update_constraints ...
     (Asqk,Asqdu,Asqdl,Wa,Tk(1:nap),Tdu,Tdl,Wt,Pk(1:nap),Pdu,Pdl,Wp,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor

% Show constraints
schurOneMAPlattice_frm_slb_show_constraints(vS,wa,Asqk,wt,Tk,wp,Pk);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("tp=%g,tpr=%g",tp,tpr));
strM=strcat(strM, sprintf("pp=%g,ppr=%g",pp,ppr));
strd=sprintf("schurOneMAPlattice_frm_slb_update_constraints_test_%%s");

% Plot amplitude
f=w*0.5/pi;
subplot(211);
plot(f,Asqk,f,Asqdu,f,Asqdl,f(vS.al),Asqk(vS.al),"x",f(vS.au),Asqk(vS.au),"+");
axis([0 fas 0.8 1.2]);
strM0=sprintf(strM,"x0k");
title(strM0);
ylabel("Amplitude");
subplot(212);
plot(f,Asqk,f,Asqdu,f,Asqdl,f(vS.al),Asqk(vS.al),"x",f(vS.au),Asqk(vS.au),"+");
axis([fap 0.5 0 2e-3]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x0A"),"-dpdflatex");
close

% Plot group delay
subplot(111);
plot(f(1:nap),Tk(1:nap),f(1:nap),Tdu,":",f(1:nap),Tdl,"-.", ...
     f(vS.tl),Tk(vS.tl),"x",f(vS.tu),Tk(vS.tu),"+");
axis([0 fap -(tpr*2) +(tpr*2)]);
title(strM0);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x0T"),"-dpdflatex");
close

% Plot phase
subplot(111);
plot(f(1:nap),Pk(1:nap),f(1:nap),Pdu,":",f(1:nap),Pdl,"-.", ...
     f(vS.pl),Pk(vS.pl),"x",f(vS.pu),Pk(vS.pu),"+");
axis([0 fap -(ppr*2) +(ppr*2)]);
title(strM0);
ylabel("Phase");
xlabel("Frequency")
print(sprintf(strd,"x0P"),"-dpdflatex");
close

%
% Done
%
diary off
movefile schurOneMAPlattice_frm_slb_update_constraints_test.diary.tmp ...
         schurOneMAPlattice_frm_slb_update_constraints_test.diary;
