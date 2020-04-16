% iir_slb_exchange_constraints_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("iir_slb_exchange_constraints_test.diary");
delete("iir_slb_exchange_constraints_test.diary.tmp");
diary iir_slb_exchange_constraints_test.diary.tmp


maxiter=2000;
tol=1e-5;
verbose=false;
printf("maxiter=%d,tol=%g,verbose=%d\n",maxiter,tol,verbose);

%% Deczky3 Lowpass filter specification
% Filter specifications
U=0;V=0;Q=6;M=10;R=1;
fap=0.15;dBap=0.1;Wap=1;
fas=0.3;dBas=50;Was=10;
ftp=0.25;tp=6;tpr=0.01;Wtp=0.1;
fpp=0.25;pd=0;ppr=0.002;Wpp=0.001;

strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("tp=%d,rtp=%g,Wtp=%g",tp,tpr,Wtp));
printf("%s\n",sprintf(strM,"Test parameters"));
       
%% Initial coefficients (x2 from deczky3_sqp_test.m)
x2 = [   0.0047292 ...
         0.9707886   0.9722610   1.4900880   1.4787074 ...
         1.6385223   2.6997190   2.0734450   1.3266238 ...
         0.8871379   0.3211754   0.8558549   0.6314615 ...
         0.5572139   0.9862460   0.7380218   0.3429478 ]';

%% Initial coefficients (x7 from deczky3_sqp_test.m)
x7 = [   0.0094386 ...
        -0.9707899  -0.8841912   0.6883779   0.9158562 ...
         2.2629943  -5.0822167   6.2522910   2.4789154 ...
        -2.3366191   0.4205817   0.4974948   0.6825980 ...
         0.0573631   1.2056808   1.8164313  -0.2724392 ]';

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
Sdl=(10^(-(dBas+6)/20))*ones(size(ws));
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

Ax2=iirA(wa,x2,U,V,M,Q,R);
Ax7=iirA(wa,x7,U,V,M,Q,R);
Sx2=iirA(ws,x2,U,V,M,Q,R);
Sx7=iirA(ws,x7,U,V,M,Q,R);
Tx2=iirT(wt,x2,U,V,M,Q,R);
Tx7=iirT(wt,x7,U,V,M,Q,R);
Px2=iirP(wp,x2,U,V,M,Q,R);
Px7=iirP(wp,x7,U,V,M,Q,R);

vRx2=iir_slb_update_constraints(x2,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                                ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                                wp,Pdu,Pdl,Wp,tol);
vSx7=iir_slb_update_constraints(x7,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                                ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                                wp,Pdu,Pdl,Wp,tol);

printf("vR before exchange constraints:\n");
iir_slb_show_constraints(vRx2,wa,Ax2,ws,Sx2,wt,Tx2,wp,Px2);

printf("vS before exchange constraints:\n");
iir_slb_show_constraints(vSx7,wa,Ax7,ws,Sx7,wt,Tx7,wp,Px7);

% Plot amplitude
w=(0:(n-1))'*pi/n;
f=w*0.5/pi;
AAx2=iirA(w,x2,U,V,M,Q,R);
AAdu = [ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
AAdl = [(10^(-dBap/20))*ones(nap,1); (10^(-(dBas+6)/20))*ones(n-nap,1)];
fa=wa*0.5/pi;
strd=sprintf("iir_slb_exchange_constraints_test_%%s");
strM2=sprintf(strM,"x2");
subplot(211);
plot(f,[AAx2,AAdu,AAdl], ...
     fa(vRx2.al),Ax2(vRx2.al),'*', ...
     fa(vRx2.au),Ax2(vRx2.au),'+');
axis([0,0.5,0.9,1.1]);
title(strM2);
ylabel("Amplitude");
subplot(212);
fs=ws*0.5/pi;
plot(f,[AAx2,AAdu,AAdl], ...
     fs(vRx2.sl),Sx2(vRx2.sl),'*', ...
     fs(vRx2.su),Sx2(vRx2.su),'+');
axis([0,0.5,0,0.02]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x2A"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[Tx2,Tdu,Tdl], ...
     ft(vRx2.tu),Tx2(vRx2.tu),'+', ...
     ft(vRx2.tl),Tx2(vRx2.tl),'*');
title(strM2);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x2T"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
plot(fp,[Px2-Pd,Pdu-Pd,Pdl-Pd], ...
     fp(vRx2.pu),Px2(vRx2.pu)-Pd(vRx2.pu),'+', ...
     fp(vRx2.pl),Px2(vRx2.pl)-Pd(vRx2.pl),'*');
title(strM2);
ylabel("Phase(rad.)\n(Corrected for delay)");
xlabel("Frequency")
print(sprintf(strd,"x2P"),"-dpdflatex");
close

% Exchange constraints
[vRx7,vSx7,exchanged] = ...
iir_slb_exchange_constraints(vSx7,vRx2,x7,U,V,M,Q,R, ...
                             wa,Adu,Adl,ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,tol);

printf("vR after exchange constraints:\n");
iir_slb_show_constraints(vRx7,wa,Ax7,ws,Sx7,wt,Tx7,wp,Px7);

printf("vS after exchange constraints:\n");
iir_slb_show_constraints(vSx7,wa,Ax7,ws,Sx7,wt,Tx7,wp,Px7);

% Plot amplitude
AAx7=iirA(w,x7,U,V,M,Q,R);
strM7=sprintf(strM,"x7");
subplot(211);
plot(f,[AAx2,AAx7,AAdu,AAdl], ...
     fa(vRx2.al),Ax2(vRx2.al),'*',fa(vRx2.au),Ax2(vRx2.au),'+', ...
     fa(vSx7.al),Ax7(vSx7.al),'*',fa(vSx7.au),Ax7(vSx7.au),'+');
axis([0,0.5,10^(-10*dBap/20),10^(2*dBap/20)]);
title(strM7);
ylabel("Amplitude");
subplot(212);
plot(f,[AAx2,AAx7,AAdu,AAdl], ...
     fs(vRx2.sl),Sx2(vRx2.sl),'*',fs(vRx2.su),Sx2(vRx2.su),'+', ...
     fs(vSx7.sl),Sx7(vSx7.sl),'*',fs(vSx7.su),Sx7(vSx7.su),'+');
axis([0 0.5 0 2e-2]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x7A"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[Tx2,Tx7,Tdu,Tdl], ...
     ft(vRx2.tl),Tx2(vRx2.tl),'*',ft(vRx2.tu),Tx2(vRx2.tu),'+',
     ft(vSx7.tl),Tx7(vSx7.tl),'*',ft(vSx7.tu),Tx7(vSx7.tu),'+');
axis([0 ftp tp-(2*tpr) tp+(2*tpr)]);
title(strM7);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x7T"),"-dpdflatex");
close

% Plot phase
plot(fp,[Px2-Pd,Px7-Pd,Pdu-Pd,Pdl-Pd], ...
     fp(vRx2.pl),Px2(vRx2.pl)-Pd(vRx2.pl),'*', ...
     fp(vRx2.pu),Px2(vRx2.pu)-Pd(vRx2.pu),'+', ...
     fp(vSx7.pl),Px7(vSx7.pl)-Pd(vSx7.pl),'*', ...
     fp(vSx7.pu),Px7(vSx7.pu)-Pd(vSx7.pu),'+');
axis([0 fpp -ppr ppr]);
title(strM2);
ylabel("Phase(rad.)\n(Corrected for delay)");
xlabel("Frequency")
print(sprintf(strd,"x7P"),"-dpdflatex");
close

diary off
movefile iir_slb_exchange_constraints_test.diary.tmp ...
         iir_slb_exchange_constraints_test.diary;
