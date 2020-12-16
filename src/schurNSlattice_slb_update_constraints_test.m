% schurNSlattice_slb_update_constraints_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("schurNSlattice_slb_update_constraints_test.diary");
delete("schurNSlattice_slb_update_constraints_test.diary.tmp");
diary schurNSlattice_slb_update_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

%
% Deczky3 Lowpass filter specification
%
%
U=0;V=0;Q=6;M=10;R=1;
fap=0.15,dBap=0.1,Wap=1
fas=0.3,dBas=50,Was=10
ftp=0.25,tp=6,tpr=0.01,Wtp=0.1

% Frequency vectors
n=1000;
w=(0:(n-1))'*pi/n;
wa=w;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;

% Amplitude constraints
Asqd  = [ones(nap,1); zeros(n-nap,1)];
Asqdu = [ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl = [(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa  = [Wap*ones(nap,1); zeros(nas-nap-1,1); Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:ntp);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("tp=%d,rtp=%g",tp,tpr));

% Subsequent coefficients (x7 from deczky3_sqp_test.m)
x7 = [   0.0094386, ...
        -0.9707899, -0.8841912,  0.6883779,  0.9158562, ...
         2.2629943, -5.0822167,  6.2522910,  2.4789154, ...
        -2.3366191,  0.4205817,  0.4974948,  0.6825980, ...
         0.0573631,  1.2056808,  1.8164313, -0.2724392 ]';
n7 = [   0.0094386,  0.0065386, -0.0315270, -0.0503352, ...
         0.0482319,  0.2586755,  0.4212899,  0.4009821, ...
         0.2396240,  0.0849734,  0.0141555 ]';
d7 = [   1.0000,    -0.13379,    0.60136,   -0.14925, ...
         0.12649,   -0.013017,   0.00037947, 0, ...
         0,           0,         0 ]';
[s10_7,s11_7,s20_7,s00_7,s02_7,s22_7]=tf2schurNSlattice(n7,d7);
Asq=schurNSlatticeAsq(wa,s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);
T=schurNSlatticeT(wt,s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);

% Update constraints
vS=schurNSlattice_slb_update_constraints ...
     (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Asql=schurNSlatticeAsq(wa(vS.al),s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);
Asqu=schurNSlatticeAsq(wa(vS.au),s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);
Tl=schurNSlatticeT(wt(vS.tl),s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);
Tu=schurNSlatticeT(wt(vS.tu),s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);

% Show constraints
schurNSlattice_slb_show_constraints(vS,w,Asq,w,T);

% Plot amplitude
fa=wa*0.5/pi;
strd=sprintf("schurNSlattice_slb_update_constraints_test_%%s");
strM7=sprintf(strM,"7");
subplot(211);
plot(fa,Asq,fa,Asqdu,fa,Asqdl,fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
axis([0 0.5 0.8 1.02]);
title(strM7);
ylabel("Amplitude");
subplot(212);
plot(fa,Asq,fa,Asqdu,fa,Asqdl,fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
axis([0 0.5 0 2e-4]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"Asq7"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
subplot(111);
plot(ft,T,ft,Tdu,":",ft,Tdl,"-.",ft(vS.tl),Tl,"x",ft(vS.tu),Tu,"+");
axis([0 ftp tp-(tpr*2) tp+(tpr*2)]);
title(strM7);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"T7"),"-dpdflatex");
close

% Done
diary off
movefile schurNSlattice_slb_update_constraints_test.diary.tmp ...
       schurNSlattice_slb_update_constraints_test.diary;
