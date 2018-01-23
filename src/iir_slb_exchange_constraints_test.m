% iir_slb_exchange_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iir_slb_exchange_constraints_test.diary");
unlink("iir_slb_exchange_constraints_test.diary.tmp");
diary iir_slb_exchange_constraints_test.diary.tmp

format compact;

maxiter=2000
tol=1e-5
verbose=true

%%% Deczky3 Lowpass filter specification
%% Filter specifications
U=0,V=0,Q=6,M=10,R=1
fap=0.15,dBap=0.1,Wap=1
fas=0.3,dBas=50,Was=10
ftp=0.25,tp=6,tpr=0.01,Wtp=0.1

strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("tp=%d,rtp=%g,Wtp=%g",tp,tpr,Wtp));

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
wa=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
wt=(0:(ntp-1))'*pi/n;

% Amplitude constraints
Ad  = [ones(nap,1); zeros(n-nap,1)];
Adu = [ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
Adl = [(10^(-dBap/20))*ones(nap,1); zeros(n-nap,1)];
Wa  = [Wap*ones(nap,1); zeros(nas-nap-1,1); Was*ones(n-nas+1,1)];

% Stop-band response constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase response constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

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
fa=wa*0.5/pi;
strd=sprintf("iir_slb_exchange_constraints_test_%%s");
strM2=sprintf(strM,"x2");
subplot(211);
plot(fa,[Ax2,Adu,Adl], ...
     0.5*wa(vRx2.al)/pi,Ax2(vRx2.al),'*', ...
     0.5*wa(vRx2.au)/pi,Ax2(vRx2.au),'*');
axis([0,0.5,0.9,1.1]);
title(strM2);
ylabel("Amplitude");
subplot(212);
plot(fa,[Ax2,Adu,Adl], ...
     0.5*wa(vRx2.al)/pi,Ax2(vRx2.al),'*', ...
     0.5*wa(vRx2.au)/pi,Ax2(vRx2.au),'*');
axis([0,0.5,0,0.02]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x2A"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[Tx2,Tdu,Tdl], ...
     0.5*wt(vRx2.tu)/pi,Tx2(vRx2.tu),'*', ...
     0.5*wt(vRx2.tl)/pi,Tx2(vRx2.tl));
% axis([0 ftp 0 tp*2]);
title(strM2);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x2T"),"-dpdflatex");
close

% Exchange constraints
[vRx7,vSx7,exchanged] = ...
  iir_slb_exchange_constraints(vSx7,vRx2,x7,U,V,M,Q,R,wa,Adu,Adl, ...
                               ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,tol)

printf("vR after exchange constraints:\n");
iir_slb_show_constraints(vRx7,wa,Ax7,ws,Sx7,wt,Tx7,wp,Px7);

printf("vS after exchange constraints:\n");
iir_slb_show_constraints(vSx7,wa,Ax7,ws,Sx7,wt,Tx7,wp,Px7);

% Plot amplitude
fa=wa*0.5/pi;
strd=sprintf("iir_slb_exchange_constraints_test_%%s");
strM7=sprintf(strM,"x7");
subplot(211);
plot(fa,[Ax2,Ax7,Adu,Adl], ...
     0.5*wa(vRx2.al)/pi,Ax2(vRx2.al),'*',0.5*wa(vRx2.au)/pi,Ax2(vRx2.au),'+', ...
     0.5*wa(vSx7.al)/pi,Ax7(vSx7.al),'*',0.5*wa(vSx7.au)/pi,Ax7(vSx7.au),'+');
axis([0,0.5,10^(-2*dBap/20),10^(2*dBap/20)]);
title(strM7);
ylabel("Amplitude");
subplot(212);
plot(fa,[Ax2,Ax7,Adu,Adl], ...
     0.5*wa(vRx2.al)/pi,Ax2(vRx2.al),'*',0.5*wa(vRx2.au)/pi,Ax2(vRx2.au),'+', ...
     0.5*wa(vSx7.al)/pi,Ax7(vSx7.al),'*',0.5*wa(vSx7.au)/pi,Ax7(vSx7.au),'+');
% axis([0,0.5,0,10^(-2*dBas/20)]);
axis([0 0.5 0 2e-2]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x7A"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[Tx2,Tx7,Tdu,Tdl], ...
     0.5*wt(vRx2.tl)/pi,Tx2(vRx2.tl),'*',0.5*wt(vRx2.tu)/pi,Tx2(vRx2.tu),'+',
     0.5*wt(vSx7.tl)/pi,Tx7(vSx7.tl),'*',0.5*wt(vSx7.tu)/pi,Tx7(vSx7.tu),'+');
axis([0 ftp tp-(tpr*10) tp+(tpr*10)]);
title(strM7);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x7T"),"-dpdflatex");
close

diary off
movefile iir_slb_exchange_constraints_test.diary.tmp iir_slb_exchange_constraints_test.diary;
