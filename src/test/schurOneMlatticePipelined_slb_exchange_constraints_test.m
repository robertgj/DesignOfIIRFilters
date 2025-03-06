% schurOneMlatticePipelined_slb_exchange_constraints_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticePipelined_slb_exchange_constraints_test";

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
ftp=0.25,tp=6,tpr=0.005,Wtp=0.1
fpp=ftp,ppr=0.05,Wpp=0.1
fdp=0.1;dpr=0.1,Wdp=0.01

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
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(n2,d2);
kk2=k2(1:(length(k2)-1)).*k2(2:length(k2));
ck2=c2(2:length(k2)).*k2(2:length(k2));
Asq2=schurOneMlatticePipelinedAsq(wa,k2,epsilon2,c2,kk2,ck2);
T2=schurOneMlatticePipelinedT(wt,k2,epsilon2,c2,kk2,ck2);
P2=schurOneMlatticePipelinedP(wp,k2,epsilon2,c2,kk2,ck2);
uP2=(unwrap([P2,Pdu,Pdl])+(wp*tp))/pi;
D2=schurOneMlatticePipelineddAsqdw(wd,k2,epsilon2,c2,kk2,ck2);
         
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
[k7,epsilon7,p7,c7]=tf2schurOneMlattice(n7,d7);
kk7=k7(1:(length(k7)-1)).*k7(2:length(k7));
ck7=c7(2:length(k7)).*k7(2:length(k7));
Asq7=schurOneMlatticePipelinedAsq(wa,k7,epsilon7,c7,kk7,ck7);
T7=schurOneMlatticePipelinedT(wt,k7,epsilon7,c7,kk7,ck7);
P7=schurOneMlatticePipelinedP(wp,k7,epsilon7,c7,kk7,ck7);
uP7=(unwrap([P2,P7,Pdu,Pdl])+(wp*tp))/pi;
D7=schurOneMlatticePipelineddAsqdw(wd,k7,epsilon7,c7,kk7,ck7);

% Update constraints
vR2=schurOneMlatticePipelined_slb_update_constraints ...
      (Asq2,Asqdu,Asqdl,Wa,T2,Tdu,Tdl,Wt,P2,Pdu,Pdl,Wp,D2,Ddu,Ddl,Wd,tol);
vS7=schurOneMlatticePipelined_slb_update_constraints ...
      (Asq7,Asqdu,Asqdl,Wa,T7,Tdu,Tdl,Wt,P7,Pdu,Pdl,Wp,D7,Ddu,Ddl,Wd,tol);

% Show constraints
printf("vR2 before exchange constraints:\n");
schurOneMlatticePipelined_slb_show_constraints(vR2,w,Asq2,w,T2,w,P2,w,D2);
printf("vS7 before exchange constraints:\n");
schurOneMlatticePipelined_slb_show_constraints(vS7,w,Asq7,w,T7,w,P7,w,D7);

% Plot amplitude
strd=sprintf("%s_%%s",strf);
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tpr=%g,Wtp=%g",
             fap,dBap,Wap,fas,dBas,Was,tpr,Wtp);
fa=wa*0.5/pi;
subplot(211);
plot(fa(1:nap),10*log10([Asq2(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+");
axis([0,fap,-0.25,0.25]);
grid("on");
strM2=sprintf(strM,"2");
title(strM2);
ylabel("Amplitude(dB)");
subplot(212);
plot(fa(nas:end),10*log10([Asq2(nas:end),Asqdu(nas:end)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+");
axis([fas,0.5,-60,-30]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"Asq2"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[T2,Tdu,Tdl], ft(vR2.tl),T2(vR2.tl),"*", ft(vR2.tu),T2(vR2.tu),"+");
grid("on");
title(strM2);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"T2"),"-dpdflatex");
close

% Plot phase error
fp=wp*0.5/pi;
plot(fp,uP2, fp(vR2.pl),uP2(vR2.pl,1),"*", fp(vR2.pu),uP2(vR2.pu,1),"+");
grid("on");
title(strM2);
ylabel("Phase error(Rad./pi)");
xlabel("Frequency")
print(sprintf(strd,"P2"),"-dpdflatex");
close

% Plot dAsqdw
fd=wd*0.5/pi;
plot(fd,[D2,Ddu,Ddl], fd(vR2.dl),D2(vR2.dl),"*", fd(vR2.du),D2(vR2.du),"+");
grid("on");
title(strM2);
ylabel("dAsqdw");
xlabel("Frequency")
print(sprintf(strd,"D2"),"-dpdflatex");
close

% Exchange constraints
[vR7,vS7,exchanged] = schurOneMlatticePipelined_slb_exchange_constraints ...
                        (vS7,vR2,Asq7,Asqdu,Asqdl,T7,Tdu,Tdl, ...
                         P7,Pdu,Pdl,D7,Ddu,Ddl,tol);
printf("vR7 after exchange constraints:\n");
schurOneMlatticePipelined_slb_show_constraints(vR7,w,Asq7,w,T7,w,P7,w,D7);
printf("vS7 after exchange constraints:\n");
schurOneMlatticePipelined_slb_show_constraints(vS7,w,Asq7,w,T7,w,P7,w,D7);

% Plot amplitude
subplot(211);
plot(fa(1:nap),10*log10([Asq2(1:nap),Asq7(1:nap), ...
                         Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+", ...
     fa(vS7.al),10*log10(Asq7(vS7.al)),"*", ...
     fa(vS7.au),10*log10(Asq7(vS7.au)),"+");
axis([0,fap,-0.25,0.25]);
legend("Asq2","Asq7","Asqdu","Asqdu+tol")
legend("boxoff")
legend("location","northwest");
grid("on");
strM7=sprintf(strM,"7");
title(strM7);
ylabel("Amplitude(dB)");
subplot(212);
plot(fa(nas:end), ...
     10*log10([Asq2(nas:end),Asq7(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(n-nas+1,1)]), ...
     fa(vR2.al),10*log10(Asq2(vR2.al)),"*", ...
     fa(vR2.au),10*log10(Asq2(vR2.au)),"+", ...
     fa(vS7.al),10*log10(Asq7(vS7.al)),"*", ...
     fa(vS7.au),10*log10(Asq7(vS7.au)),"+");
axis([fas 0.5 -60 -30]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"Asq7"),"-dpdflatex");
close

% Plot group delay
plot(ft,[T2,T7,Tdu,Tdl], ...
     ft(vR2.tl),T2(vR2.tl),"*",ft(vR2.tu),T2(vR2.tu),"+", ...
     ft(vS7.tl),T7(vS7.tl),"*",ft(vS7.tu),T7(vS7.tu),"+");
%axis([0 ftp tp-(tpr*2) tp+(tpr*4)]);
grid("on");
title(strM7);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("T2","T7","Tdu","Tdl")
legend("location","northwest");
legend("boxoff");
print(sprintf(strd,"T7"),"-dpdflatex");
close

% Plot phase
plot(fp,uP7, ...
     fp(vR2.pl),uP7(vR2.pl,1),"*", fp(vR2.pu),uP7(vR2.pu,1),"+", ...
     fp(vS7.pl),uP7(vS7.pl,2),"*", fp(vS7.pu),uP7(vS7.pu,2),"+");
%axis([0 fpp (ppr*2) (ppr*4)]);
grid("on");
title(strM7);
ylabel("Phase error(Rad./pi)");
xlabel("Frequency")
legend("P2","P7","Pdu","Pdl")
legend("location","southwest");
legend("boxoff");
print(sprintf(strd,"P7"),"-dpdflatex");
close

% Plot dAsqdw
plot(fd,[D2,D7,Ddu,Ddl], ...
     fd(vR2.dl),D2(vR2.dl),"*",fd(vR2.du),D2(vR2.du),"+", ...
     fd(vS7.dl),D7(vS7.dl),"*",fd(vS7.du),D7(vS7.du),"+");
%axis([0 fdp -dpr dpr]);
grid("on");
title(strM7);
ylabel("dAsqdw");
xlabel("Frequency")
legend("D2","D7","Ddu","Ddl")
legend("location","northwest");
legend("boxoff");
print(sprintf(strd,"D7"),"-dpdflatex");
close

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
