% johanssonOneMlattice_slb_update_constraints_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("johanssonOneMlattice_slb_update_constraints_test.diary");
delete("johanssonOneMlattice_slb_update_constraints_test.diary.tmp");
diary johanssonOneMlattice_slb_update_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

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
fM = [ -0.03,  -0.00,   0.30,   0.50 ];
a0 = [  1.00,  -0.57,   1.60,  -0.50, 0.73 ];
a1 = [  1.00,  -0.26,   0.64 ];

% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0),a0);
[k1,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1),a1);

% Update constraints
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
vS=johanssonOneMlattice_slb_update_constraints(Azp,Adu,Adl,Wa,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Al=johanssonOneMlatticeAzp(wa(vS.al),fM,k0,epsilon0,k1,epsilon1);
Au=johanssonOneMlatticeAzp(wa(vS.au),fM,k0,epsilon0,k1,epsilon1);

% Show constraints
johanssonOneMlattice_slb_show_constraints(vS,wa,Azp);

% Plot amplitude
fa=wa*0.5/pi;
subplot(211);
plot(fa,Azp,fa,Adu,fa,Adl,fa(vS.al),Al,"x",fa(vS.au),Au,"+");
axis([0 0.5 0.9 1.1]);
ylabel("Amplitude");
subplot(212);
plot(fa,Azp,fa,Adu,fa,Adl,fa(vS.al),Al,"x",fa(vS.au),Au,"+");
axis([0 0.5 -0.1 0]);
ylabel("Amplitude");
xlabel("Frequency")
zticks([]);
print("johanssonOneMlattice_slb_update_constraints_test_Azp0","-dpdflatex");
close

% Done
diary off
movefile johanssonOneMlattice_slb_update_constraints_test.diary.tmp ...
         johanssonOneMlattice_slb_update_constraints_test.diary;
