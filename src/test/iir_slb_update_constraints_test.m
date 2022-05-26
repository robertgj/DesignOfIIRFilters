% iir_slb_update_constraints_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("iir_slb_update_constraints_test.diary");
delete("iir_slb_update_constraints_test.diary.tmp");
diary iir_slb_update_constraints_test.diary.tmp


verbose=false;
tol=1e-5;

% Deczky3 Lowpass filter specification
U=0;V=0;Q=6;M=10;R=1;
fap=0.15;dBap=0.1;Wap=1;
fas=0.3;dBas=45;Was=1;
ftp=0.25;tp=6;tpr=0.025;Wtp=1;
fpp=0.25;pd=0;ppr=0.002;Wpp=0.001;
strM=sprintf("test parameters:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("tp=%d,rtp=%g,tol=%g",tp,tpr,tol));
printf("%s\n",strM);

% Initial coefficients (x7 from Deczky3_test.m)
x7 = [ 0.0095 ...
      -0.9707899 -0.8841912  0.6883779  0.9158562  2.2629943 ...
      -5.0822167  6.2522910  2.4789154 -2.3366191  0.4205817 ...
       0.4974948  0.6825980  0.0573631 ...
       1.2056808  1.8164313 -0.2724392 ]';

% Frequency vectors
n=1000;

% Pass-band amplitude constraints
nap=ceil(fap*n/0.5)+1;
wa=(0:nap)'*pi/n;
Ad  = ones(size(wa));
Adu = ones(size(wa));
Adl = (10^(-dBap/20))*ones(size(wa));
Wa=ones(size(wa));

% Stop-band amplitude constraints
nas=floor(fas*n/0.5)+1;
ws=(nas:n)'*pi/n;
Sd=zeros(size(ws));
Sdu=(10^(-dBas/20))*ones(size(ws));
Sdl=(10^(-(dBas+3)/20))*ones(size(ws));
Ws=Was*ones(size(ws));

% Group delay constraints
ntp=ceil(ftp*n/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Wt=Wtp*ones(size(wt));
Td=tp*ones(size(wt));
Tdu=(tp+(tpr/2))*ones(size(wt));
Tdl=(tp-(tpr/2))*ones(size(wt));

% Phase constraints
npp=ceil(fpp*n/0.5)+1;
wp=(0:(npp-1))'*pi/n;
Wp=Wpp*ones(size(wp));
Pd=pd-(tp*wp);
Pdu=Pd+(ppr/2);
Pdl=Pd-(ppr/2);

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);

% Response
w=(0:(n-1))'*pi/n;
AA=iirA(w,x7,U,V,M,Q,R);
A=iirA(wa,x7,U,V,M,Q,R);
S=iirA(ws,x7,U,V,M,Q,R);
T=iirT(wt,x7,U,V,M,Q,R);
P=iirP(wp,x7,U,V,M,Q,R);

% Constraints
vS=iir_slb_update_constraints(x7,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                              wp,Pdu,Pdl,Wp,tol);
for [v,k]=vS
  print_polynomial(v,k,"%4d");
endfor

% Show constraints
iir_slb_show_constraints(vS,wa,A,ws,S,wt,T,wp,P);

% Plot amplitude
f=w*0.5/pi;
fa=wa*0.5/pi;
fs=ws*0.5/pi;
AAdu=[ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
AAdl=[(10^(-dBap/20))*ones(nap,1); (10^(-(dBas+3)/20))*ones(n-nap,1)];
strd=sprintf("iir_slb_update_constraints_test_%%s");
strM7=sprintf(strM,"x7");
subplot(211);
plot(f,AA,f,AAdu,f,AAdl,fa(vS.al),A(vS.al),"x",fa(vS.au),A(vS.au),"+");
axis([0 0.5 0.9 1.02]);
title(strM7);
ylabel("Amplitude");
grid("on");
subplot(212);
plot(f,AA,f,AAdu,f,AAdl,fs(vS.sl),S(vS.sl),"x",fs(vS.su),S(vS.su),"+");
axis([0 0.5 0 2e-2]);
ylabel("Amplitude");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"x7A"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
subplot(111);
plot(ft,T,ft,Tdu,":",ft,Tdl,"-.",ft(vS.tl),T(vS.tl),"x",ft(vS.tu),T(vS.tu),"+");
axis([0 ftp tp-(tpr*0.6) tp+(tpr*0.6)]);
title(strM7);
ylabel("Delay(samples)");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"x7T"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
subplot(111);
plot(fp,P-Pd,fp,Pdu-Pd,":",fp,Pdl-Pd,"-.", ...
     fp(vS.pl),P(vS.pl)-Pd(vS.pl),"x",fp(vS.pu),P(vS.pu)-Pd(vS.pu),"+");
axis([0 fpp -ppr ppr]);
title(strM7);
ylabel("Phase(rad.)\n(Corrected for delay)");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"x7P"),"-dpdflatex");
close

%
% Done
%
diary off
movefile iir_slb_update_constraints_test.diary.tmp ...
         iir_slb_update_constraints_test.diary;
