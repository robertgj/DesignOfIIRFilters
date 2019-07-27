% parallel_allpass_slb_exchange_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("parallel_allpass_slb_exchange_constraints_test.diary");
unlink("parallel_allpass_slb_exchange_constraints_test.diary.tmp");
diary parallel_allpass_slb_exchange_constraints_test.diary.tmp

format compact;

maxiter=2000 
verbose=true

%
% Filter specification
%
tol =    1.0000e-06
maxiter =  2000
polyphase = 0
Ra =  1
ma =  11
mb =  12
Rb =  1
td =  11.500
tdr = 0.04
fap =  0.17500
Wap =  1
dBap = 1
ftp =  0.20000
Wtp =  100
fas =  0.25000
Was =  10000
dBas = 50
fpp=0.18
pd=0;
pdr=0.002;
Wpp=1000

%
% Use the filters found by tarczynski_parallel_allpass_test.m
% and parallel_allpass_socp_mmse_test.m
%
Da0=[  1  0.564461 -0.305622 -0.241573  0.0256334  0.251493 ...
         -0.155998 -0.011535  0.113621 -0.139502   0.0465487  0.0320385]';
Db0=[  1  0.124107 -0.205172  0.18588   0.0410326  0.0645608 ...
         -0.290264  0.184923  0.10931  -0.222938   0.135349 ...
         -0.0251777 -0.0248722]';
Da1 = [ 1.0000000000,   0.4895604822,  -0.3519383156,  -0.2093377519, ... 
        0.0494248192,   0.2498319500,  -0.1680950881,  -0.0038201748, ... 
        0.1002324827,  -0.1483081550,   0.0693679888,   0.0357780753 ]';
Db1 = [ 1.0000000000,   0.1151374945,  -0.1498865592,   0.2153062435, ... 
       -0.0022596711,   0.0490775129,  -0.2650151665,   0.2017340265, ... 
        0.0814568819,  -0.2209100312,   0.1544171593,  -0.0418405288, ... 
       -0.0319856751 ]';

% Frequency vectors
n=1000;
nap=ceil(fap*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
K=2;
Ksq=K^2;

% Amplitude constraints
wa=(0:(n-1))*pi/n;
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Asqd=[0.9*ones(nap,1);zeros(n-nap,1)];
Asqdu=[0.9*ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];

% Group delay constraints
wt=(0:(ntp-1))*pi/n;
Wt=Wtp*ones(ntp,1);
Td=td*ones(ntp,1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);

% Desired pass-band phase response
npp=ceil(n*fpp/0.5)+1;
wp=(0:(npp-1))'*pi/n;
Pd=(pd*pi)-(td*wp);
Pdu=Pd+(pdr/2);
Pdl=Pd-(pdr/2);
Wp=Wpp*ones(npp,1);

% Convert Da0 and Db0 to vector form
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);

% Convert Da1 and Db1 to vector form
ab1=zeros(ma+mb,1);
[ab1(1:ma),Va,Qa]=tf2a(Da1);
[ab1((ma+1):end),Vb,Qb]=tf2a(Db1);

% Response of ab0
Asqab0=parallel_allpassAsq(wa,ab0,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
Tab0=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
Pab0=parallel_allpassP(wp,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase);

% Response of ab1
Asqab1=parallel_allpassAsq(wa,ab1,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
Tab1=parallel_allpassT(wt,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
Pab1=parallel_allpassP(wp,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase);

% Update constraints
vRab0=parallel_allpass_slb_update_constraints ...
        (Asqab0,Asqdu*Ksq,Asqdl*Ksq,Wa/Ksq,Tab0,Tdu,Tdl,Wt,Pab0,Pdu,Pdl,Wp,tol);
vSab1=parallel_allpass_slb_update_constraints ...
        (Asqab1,Asqdu*Ksq,Asqdl*Ksq,Wa/Ksq,Tab1,Tdu,Tdl,Wt,Pab1,Pdu,Pdl,Wp,tol);

% Show constraints
printf("vRab0 before exchange constraints:\n");
parallel_allpass_slb_show_constraints(vRab0,wa,Asqab0/Ksq,wt,Tab0,wp,Pab0);
printf("vSab1 before exchange constraints:\n");
parallel_allpass_slb_show_constraints(vSab1,wa,Asqab0/Ksq,wt,Tab0,wp,Pab0);

% Common strings
strd=sprintf("parallel_allpass_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tdr=%g,Wtp=%g",
             fap,dBap,Wap,fas,dBas,Was,tdr,Wtp);

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0/Ksq,Asqdu,Asqdl]), ...
     wa(vRab0.al)*0.5/pi,10*log10(Asqab0(vRab0.al)/Ksq),'*', ...
     wa(vRab0.au)*0.5/pi,10*log10(Asqab0(vRab0.au)/Ksq),'+');
axis([0,fap,-3,1]);
strMab0=sprintf(strM,"ab0");
title(strMab0);
xlabel("Frequency")
ylabel("Amplitude(dB)");
legend("Asqab0","Asqdu","Asqdl","location","northeast");
legend("boxoff");
print(sprintf(strd,"ab0A"),"-dpdflatex");
close

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0/Ksq,Asqdu,Asqdu+tol*ones(n,1)]), ...
     wa(vRab0.al)*0.5/pi,10*log10(Asqab0(vRab0.al)/Ksq),'*', ...
     wa(vRab0.au)*0.5/pi,10*log10(Asqab0(vRab0.au)/Ksq),'+');
axis([fas,0.5,-60,-20]);
xlabel("Frequency")
ylabel("Amplitude(dB)");
legend("Asqab0","Asqdu","Asqdu+tol","location","northeast");
legend("boxoff");
print(sprintf(strd,"ab0S"),"-dpdflatex");
close

% Plot group delay
plot(wt*0.5/pi,[Tab0,Tdu,Tdl], ...
     wt(vRab0.tl)*0.5/pi,Tab0(vRab0.tl),'*', ...
     wt(vRab0.tu)*0.5/pi,Tab0(vRab0.tu),'+');
title(strMab0);
axis([0,ftp,11.4 11.6])
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"ab0T"),"-dpdflatex");
close

% Plot phase
plot(wp*0.5/pi,([Pab0,Pdu,Pdl]+(wp*td)-pd)/pi, ...
     wp(vRab0.pl)*0.5/pi,(Pab0(vRab0.pl)+(wp(vRab0.pl)*td)-pd)/pi,'*', ...
     wp(vRab0.pu)*0.5/pi,(Pab0(vRab0.pu)+(wp(vRab0.pu)*td)-pd)/pi,'+');
title(strMab0);
axis([0 fpp -pdr pdr])
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency")
print(sprintf(strd,"ab0P"),"-dpdflatex");
close

% Exchange constraints
[vRab1,vSab1,exchanged] = ...
parallel_allpass_slb_exchange_constraints ...
  (vSab1,vRab0,Asqab1,Asqdu*Ksq,Asqdl*Ksq,Tab1,Tdu,Tdl,Pab1,Pdu,Pdl,tol);
printf("vRab1 after exchange constraints:\n");
parallel_allpass_slb_show_constraints(vRab1,wa,Asqab1/Ksq,wt,Tab1,wp,Pab1);
printf("vSab1 after exchange constraints:\n");
parallel_allpass_slb_show_constraints(vSab1,wa,Asqab1/Ksq,wt,Tab1,wp,Pab1);

% Plot passband amplitude
plot(wa*0.5/pi,10*log10([Asqab0/Ksq,Asqab1/Ksq,Asqdu,Asqdl]), ...
     wa(vRab0.al)*0.5/pi,10*log10(Asqab0(vRab0.al)/Ksq),'*', ...
     wa(vRab0.au)*0.5/pi,10*log10(Asqab0(vRab0.au)/Ksq),'+', ...
     wa(vSab1.al)*0.5/pi,10*log10(Asqab1(vSab1.al)/Ksq),'*', ...
     wa(vSab1.au)*0.5/pi,10*log10(Asqab1(vSab1.au)/Ksq),'+');
axis([0,fap,-3,1]);
strMab1=sprintf(strM,"ab1");
title(strMab1);
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("Asqab0","Asqab1","Asqdu","Asqdl","location","northeast");
legend("boxoff");
print(sprintf(strd,"ab1A"),"-dpdflatex");
close

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0/Ksq,Asqab1/Ksq,Asqdu,Asqdu+tol*ones(n,1)]), ...
     wa(vRab0.al)*0.5/pi,10*log10(Asqab0(vRab0.al)/Ksq),'*', ...
     wa(vRab0.au)*0.5/pi,10*log10(Asqab0(vRab0.au)/Ksq),'+', ...
     wa(vSab1.al)*0.5/pi,10*log10(Asqab1(vSab1.al)/Ksq),'*', ...
     wa(vSab1.au)*0.5/pi,10*log10(Asqab1(vSab1.au)/Ksq),'+');
axis([fas,0.5,-60,-10]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("Asqab0","Asqab1","Asqdu","Asqdu+tol","location","northeast");
legend("boxoff");
print(sprintf(strd,"ab1S"),"-dpdflatex");
close

% Plot group delay
plot(wt*0.5/pi,[Tab0,Tab1,Tdu,Tdl], ...
     wt(vRab0.tl)*0.5/pi,Tab0(vRab0.tl),'*', ...
     wt(vRab0.tu)*0.5/pi,Tab0(vRab0.tu),'+', ...
     wt(vSab1.tl)*0.5/pi,Tab1(vSab1.tl),'*', ...
     wt(vSab1.tu)*0.5/pi,Tab1(vSab1.tu),'+');
axis([0,ftp,11.4,11.6])
title(strMab1);
ylabel("Group delay");
xlabel("Frequency")
legend("Tab0","Tab1","Tdu","Tdl","location","southwest");
legend("boxoff");
print(sprintf(strd,"ab1T"),"-dpdflatex");
close

% Plot phase
plot(wp*0.5/pi,([Pab0,Pab1,Pdu,Pdl]+(wp*td)-pd)/pi, ...
     wp(vRab0.pl)*0.5/pi,(Pab0(vRab0.pl)+(wp(vRab0.pl)*td)-pd)/pi,'*', ...
     wp(vRab0.pu)*0.5/pi,(Pab0(vRab0.pu)+(wp(vRab0.pu)*td)-pd)/pi,'+', ...
     wp(vSab1.pl)*0.5/pi,(Pab1(vSab1.pl)+(wp(vSab1.pl)*td)-pd)/pi,'*', ...
     wp(vSab1.pu)*0.5/pi,(Pab1(vSab1.pu)+(wp(vSab1.pu)*td)-pd)/pi,'+');
title(strMab0);
axis([0 fpp -pdr pdr])
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency")
legend("Pab0","Pab1","Pdu","Pdl","location","southwest");
print(sprintf(strd,"ab1P"),"-dpdflatex");
close

diary off
movefile parallel_allpass_slb_exchange_constraints_test.diary.tmp ...
         parallel_allpass_slb_exchange_constraints_test.diary;
