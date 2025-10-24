% schurOneMlatticePipelined_slb_update_constraints_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticePipelined_slb_update_constraints_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

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
fpp=ftp,ppr=0.0002,Wpp=0.1
fdp=0.1;dpr=0.08,Wdp=0.01

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

% Phase constraints
npp=ceil(n*fpp/0.5)+1;
wp=w(1:npp);
Pd=-tp*wp;
Pdu=Pd+(ppr*pi*ones(npp,1)/2);
Pdl=Pd-(ppr*pi*ones(npp,1)/2);
Wp=Wpp*ones(npp,1);

% dAsqdw constraints
ndp=ceil(n*fdp/0.5)+1;
wd=w(1:ndp);
Dd=zeros(ndp,1);
Ddu=Dd+(dpr*ones(ndp,1)/2);
Ddl=Dd-(dpr*ones(ndp,1)/2);
Wd=Wdp*ones(ndp,1);

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
[k7,epsilon7,c7,kk7,ck7]=tf2schurOneMlatticePipelined(n7,d7);
Asq7=schurOneMlatticePipelinedAsq(wa,k7,epsilon7,c7,kk7,ck7);
T7=schurOneMlatticePipelinedT(wt,k7,epsilon7,c7,kk7,ck7);
P7=schurOneMlatticePipelinedP(wp,k7,epsilon7,c7,kk7,ck7);
uP7=(unwrap([P7,Pdu,Pdl])+(wp*tp))/pi;
D7=schurOneMlatticePipelineddAsqdw(wd,k7,epsilon7,c7,kk7,ck7);

% Update constraints
vS=schurOneMlatticePipelined_slb_update_constraints ...
     (Asq7,Asqdu,Asqdl,Wa,T7,Tdu,Tdl,Wt,P7,Pdu,Pdl,Wp,D7,Ddu,Ddl,Wd,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Asql=schurOneMlatticePipelinedAsq(wa(vS.al),k7,epsilon7,c7,kk7,ck7);
Asqu=schurOneMlatticePipelinedAsq(wa(vS.au),k7,epsilon7,c7,kk7,ck7);
Tl=schurOneMlatticePipelinedT(wt(vS.tl),k7,epsilon7,c7,kk7,ck7);
Tu=schurOneMlatticePipelinedT(wt(vS.tu),k7,epsilon7,c7,kk7,ck7);
Pl=schurOneMlatticePipelinedP(wp(vS.pl),k7,epsilon7,c7,kk7,ck7);
Pu=schurOneMlatticePipelinedP(wp(vS.pu),k7,epsilon7,c7,kk7,ck7);
Dl=schurOneMlatticePipelineddAsqdw(wd(vS.dl),k7,epsilon7,c7,kk7,ck7);
Du=schurOneMlatticePipelineddAsqdw(wd(vS.du),k7,epsilon7,c7,kk7,ck7);

% Show constraints
schurOneMlatticePipelined_slb_show_constraints(vS,w,Asq7,w,T7,w,P7,w,D7);

% Plot amplitude
fa=wa*0.5/pi;
strd=sprintf("%s_%%s",strf);
strM7=sprintf(strM,"7");
subplot(211);
plot(fa,Asq7,fa,Asqdu,fa,Asqdl,fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
axis([0 0.5 0.8 1.2]);
title(strM7);
ylabel("Amplitude");
grid("on");
subplot(212);
plot(fa,Asq7,fa,Asqdu,fa,Asqdl,fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
axis([0 0.5 0 2e-4]);
ylabel("Amplitude");
xlabel("Frequency")
grid("on");
zticks([]);
print(sprintf(strd,"Asq7"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
subplot(111);
plot(ft,T7,ft,Tdu,":",ft,Tdl,"-.",ft(vS.tl),Tl,"x",ft(vS.tu),Tu,"+");
title(strM7);
ylabel("Delay(samples)");
xlabel("Frequency")
grid("on");
zticks([]);
print(sprintf(strd,"T7"),"-dpdflatex");
close

% Plot phase error
fp=wp*0.5/pi;
plot(fp,uP7, fp(vS.pl),uP7(vS.pl,1),'*', fp(vS.pu),uP7(vS.pu,1),'+');
title(strM7);
ylabel("Phase error(Rad./pi)");
xlabel("Frequency")
grid("on");
zticks([]);
print(sprintf(strd,"P7"),"-dpdflatex");
close

% Plot dAsqdw
fd=wd*0.5/pi;
plot(fd,[D7,Ddu,Ddl], fd(vS.dl),D7(vS.dl),'*',fd(vS.du),D7(vS.du),'+');
grid("on");
title(strM7);
ylabel("dAsqdw");
xlabel("Frequency")
legend("D7","Ddu","Ddl")
legend("location","northwest");
legend("boxoff");
zticks([]);
print(sprintf(strd,"D7"),"-dpdflatex");
close

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
