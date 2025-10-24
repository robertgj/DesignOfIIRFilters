% johanssonOneMlattice_slb_exchange_constraints_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("johanssonOneMlattice_slb_exchange_constraints_test.diary");
delete("johanssonOneMlattice_slb_exchange_constraints_test.diary.tmp");
diary johanssonOneMlattice_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=false

% Common strings
strf="johanssonOneMlattice_slb_exchange_constraints_test";
strt="Johansson One-M lattice exchange constraints";

% Band-stopfilter specification
fapl=0.15,fasl=0.175,fasu=0.2725,fapu=0.3
Wap=1,Was=1,delta_p=1e-6,delta_s=1e-6

% Frequencies
nf=2000
wa=(0:nf)'*pi/nf;
napl=ceil(fapl*nf/0.5)+1;
nasl=floor(fasl*nf/0.5)+1;
nasu=ceil(fasu*nf/0.5)+1;
napu=floor(fapu*nf/0.5)+1;
Ad=[ones(napl,1);zeros(napu-napl-1,1);ones(nf-napu+2,1)];
Adu=[ones(nasl-1,1); ...
     delta_s*ones(nasu-nasl+1,1); ...
     ones(nf-nasu+1,1)];
Adl=[(1-delta_p)*ones(napl,1); ...
     zeros(napu-napl-1,1); ...
     (1-delta_p)*ones(nf-napu+2,1)];
Wa=[Wap*ones(napl,1); ...
    zeros(nasl-napl-1,1); ...
    Was*ones(nasu-nasl+1,1); ...
    zeros(napu-nasu-1,1); ...
    Wap*ones(nf-napu+2,1)];

% Initial band-stop filter 
fM_0 = [ -0.02885  0   0.28846   0.48077];
a0_0 = [  1.00,  -0.57,   1.60,  -0.50, 0.73 ];
a1_0 = [  1.00,  -0.26,   0.64 ];

% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0_0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0_0),a0_0);
[k1_0,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1_0),a1_0);

% Update constraints
Azp_0=johanssonOneMlatticeAzp(wa,fM_0,k0_0,epsilon0,k1_0,epsilon1);
vR=johanssonOneMlattice_slb_update_constraints(Azp_0,Adu,Adl,Wa,tol);
for [v,k]=vR
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Al_0=johanssonOneMlatticeAzp(wa(vR.al),fM_0,k0_0,epsilon0,k1_0,epsilon1);
Au_0=johanssonOneMlatticeAzp(wa(vR.au),fM_0,k0_0,epsilon0,k1_0,epsilon1);

% Show constraints
johanssonOneMlattice_slb_show_constraints(vR,wa,Azp_0);

% Plot initial amplitude
fa=wa*0.5/pi;
subplot(211);
plot(fa,Azp_0,fa,Adu,fa,Adl,fa(vR.al),Al_0,"x",fa(vR.au),Au_0,"+");
axis([0 0.5 0.9 1.1]);
ylabel("Amplitude");
title(strcat(strt," initial response"));
subplot(212);
plot(fa,Azp_0,fa,Adu,fa,Adl,fa(vR.al),Al_0,"*",fa(vR.au),Au_0,"+");
axis([0 0.5 -0.1 0.1]);
ylabel("Amplitude");
xlabel("Frequency")
zticks([]);
print(strcat(strf,"_init"),"-dpdflatex");
close

% Exact result
fM_1 = [ -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443 ];
a0_1 = [  1.0000000000,  -0.5650802796,   1.6504647259,  -0.4790659039, ... 
          0.7284633026 ];
a1_1 = [  1.0000000000,  -0.2594839587,   0.6383172372 ];
[k0_1,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0_1),a0_1);
[k1_1,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1_1),a1_1);
Azp_1=johanssonOneMlatticeAzp(wa,fM_1,k0_1,epsilon0,k1_1,epsilon1);
vS=johanssonOneMlattice_slb_update_constraints(Azp_1,Adu,Adl,Wa,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Al_1=johanssonOneMlatticeAzp(wa(vS.al),fM_1,k0_1,epsilon0,k1_1,epsilon1);
Au_1=johanssonOneMlatticeAzp(wa(vS.au),fM_1,k0_1,epsilon0,k1_1,epsilon1);

% Show constraints
printf("vR before exchange constraints:\n");
johanssonOneMlattice_slb_show_constraints(vR,wa,Azp_0);
printf("vS before exchange constraints:\n");
johanssonOneMlattice_slb_show_constraints(vS,wa,Azp_1);

% Plot amplitude
fa=wa*0.5/pi;
subplot(211);
plot(fa,[Azp_0,Azp_1,Adu,Adl], ...
     fa(vR.al),Azp_0(vR.al),"*",fa(vR.au),Azp_0(vR.au),"+", ...
     fa(vS.al),Azp_1(vS.al),"o",fa(vS.au),Azp_1(vS.au),"s");
axis([0,0.5,0.9,1.1]);
strt_1=strcat(strt," (before)");
title(strt_1);
ylabel("Amplitude");
legend("Azp_0","Azp_1","Adu","Adl");
legend("location","southeast");
legend("left");
legend("boxoff");
subplot(212);
plot(fa,[Azp_0,Azp_1,Adu,Adl], ...
     fa(vR.al),Azp_0(vR.al),"*",fa(vR.au),Azp_0(vR.au),"+", ...
     fa(vS.al),Azp_1(vS.al),"o",fa(vS.au),Azp_1(vS.au),"s");
axis([0,0.5,-0.1,0.2]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
legend("Azp_0","Azp_1","Adu","Adl");
legend("location","southeast");
legend("left");
legend("boxoff");
zticks([]);
print(strcat(strf,"_vRvS"),"-dpdflatex");
close

% Exchange constraints
[vR_2,vS_2,exchanged] = ...
  johanssonOneMlattice_slb_exchange_constraints(vS,vR,Azp_1,Adu,Adl,tol);
printf("vR after exchange constraints:\n");
johanssonOneMlattice_slb_show_constraints(vR_2,wa,Azp_1);
printf("vS after exchange constraints:\n");
johanssonOneMlattice_slb_show_constraints(vS_2,wa,Azp_1);

% Plot amplitude
subplot(211);
plot(fa,[Azp_0,Azp_1,Adu,Adl], ...
     fa(vR_2.al),Azp_0(vR_2.al),"*",fa(vR_2.au),Azp_0(vR_2.au),"+", ...
     fa(vS_2.al),Azp_1(vS_2.al),"o",fa(vS_2.au),Azp_1(vS_2.au),"s");
axis([0,0.5,0.9,1.1]);
strt_2=strcat(strt," (after)");
title(strt_2);
ylabel("Amplitude");
legend("Azp_0","Azp_1","Adu","Adl");
legend("location","southeast");
legend("left");
legend("boxoff");
subplot(212);
plot(fa,[Azp_0,Azp_1,Adu,Adl], ...
     fa(vR_2.al),Azp_0(vR_2.al),"*",fa(vR_2.au),Azp_0(vR_2.au),"+", ...
     fa(vS_2.al),Azp_1(vS_2.al),"o",fa(vS_2.au),Azp_1(vS_2.au),"s");
axis([0 0.5 -0.1 0.2]);
ylabel("Amplitude");
xlabel("Frequency")
legend("Azp_0","Azp_1","Adu","Adl");
legend("location","southeast");
legend("left");
legend("boxoff");
zticks([]);
print(strcat(strf,"_vRvS_2"),"-dpdflatex");
close

% Done
diary off
movefile johanssonOneMlattice_slb_exchange_constraints_test.diary.tmp ...
         johanssonOneMlattice_slb_exchange_constraints_test.diary;
