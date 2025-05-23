% schurNSlattice_slb_exchange_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurNSlattice_slb_exchange_constraints_test.diary");
delete("schurNSlattice_slb_exchange_constraints_test.diary.tmp");
diary schurNSlattice_slb_exchange_constraints_test.diary.tmp


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
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("tp=%d,rtp=%g,Wtp=%g",tp,tpr,Wtp));

% Initial coefficients (x2 from deczky3_sqp_test.m)
x2 = [   0.0047292, ...
         0.9707886,  0.9722610,  1.4900880,  1.4787074, ...
         1.6385223,  2.6997190,  2.0734450,  1.3266238, ...
         0.8871379,  0.3211754,  0.8558549,  0.6314615, ...
         0.5572139,  0.9862460,  0.7380218,  0.3429478 ]';
n2 = [   0.0047292, -0.0142164,  0.0221330, -0.0178004, ...
         0.0021981,  0.0046432,  0.0122404, -0.0136580, ...
         0.0120291,  0.0283533,  0.0549156 ]';
d2 = [   1.000000,  -2.928407,   4.296174,  -3.757870, ...
         2.030882,  -0.635972,   0.090686,   0.000000, ...
         0.000000,   0.000000,   0.000000 ]';
[s10_2,s11_2,s20_2,s00_2,s02_2,s22_2]=tf2schurNSlattice(n2,d2);
Asq2=schurNSlatticeAsq(wa,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
T2=schurNSlatticeT(wt,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
         
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
Asq7=schurNSlatticeAsq(wa,s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);
T7=schurNSlatticeT(wt,s10_7,s11_7,s20_7,s00_7,s02_7,s22_7);

% Update constraints
vR2=schurNSlattice_slb_update_constraints ...
      (Asq2,Asqdu,Asqdl,Wa,T2,Tdu,Tdl,Wt,tol);
vS7=schurNSlattice_slb_update_constraints ...
      (Asq7,Asqdu,Asqdl,Wa,T7,Tdu,Tdl,Wt,tol);

% Show constraints
printf("vR2 before exchange constraints:\n");
schurNSlattice_slb_show_constraints(vR2,w,Asq2,w,T2);
printf("vS7 before exchange constraints:\n");
schurNSlattice_slb_show_constraints(vS7,w,Asq7,w,T7);

% Plot amplitude
strd=sprintf("schurNSlattice_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tpr=%g,Wtp=%g", ...
             fap,dBap,Wap,fas,dBas,Was,tpr,Wtp);
fa=wa*0.5/pi;
subplot(211);
plot(fa(1:nap),10*log10([Asq2(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+");
axis([0,fap,-0.25,0.25]);
strM2=sprintf(strM,"2");
title(strM2);
ylabel("Amplitude");
subplot(212);
plot(fa(nas:end),10*log10([Asq2(nas:end),Asqdu(nas:end)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+");
axis([fas,0.5,-60,-30]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"2Asq"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[T2,Tdu,Tdl], ...
     ft(vR2.tl),T2(vR2.tl),"*", ...
     ft(vR2.tu),T2(vR2.tu),"+");
title(strM2);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"2T"),"-dpdflatex");
close

% Exchange constraints
[vR7,vS7,exchanged] = schurNSlattice_slb_exchange_constraints ...
                        (vS7,vR2,Asq7,Asqdu,Asqdl,T7,Tdu,Tdl,tol);
printf("vR7 after exchange constraints:\n");
schurNSlattice_slb_show_constraints(vR7,w,Asq7,w,T7);
printf("vS7 after exchange constraints:\n");
schurNSlattice_slb_show_constraints(vS7,w,Asq7,w,T7);

% Plot amplitude
subplot(211);
plot(fa(1:nap),10*log10([Asq2(1:nap),Asq7(1:nap), ...
                        Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+", ...
     fa(vS7.al),10*log10(Asq7(vS7.al)),"*", ...
     fa(vS7.au),10*log10(Asq7(vS7.au)),"+");
axis([0,fap,-0.25,0.25]);
strM7=sprintf(strM,"7");
title(strM7);
ylabel("Amplitude");
subplot(212);
plot(fa(nas:end), ...
     10*log10([Asq2(nas:end),Asq7(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(n-nas+1,1)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+", ...
     fa(vS7.al),10*log10(Asq7(vS7.al)),"*", ...
     fa(vS7.au),10*log10(Asq7(vS7.au)),"+");
axis([fas 0.5 -60 -30]);
ylabel("Amplitude");
xlabel("Frequency")
legend("Asq2","Asq7","Asqdu","Asqdu+tol","location","north");
legend("boxoff");
print(sprintf(strd,"7Asq"),"-dpdflatex");
close

% Plot group delay
plot(ft,[T2,T7,Tdu,Tdl], ...
     ft(vR2.tl),T2(vR2.tl),"*",ft(vR2.tu),T2(vR2.tu),"+", ...
     ft(vS7.tl),T7(vS7.tl),"*",ft(vS7.tu),T7(vS7.tu),"+");
axis([0 ftp tp-(tpr*2) tp+(tpr*4)]);
title(strM7);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("T2","T7","Tdu","Tdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"7T"),"-dpdflatex");
close

diary off
movefile schurNSlattice_slb_exchange_constraints_test.diary.tmp ...
       schurNSlattice_slb_exchange_constraints_test.diary;
