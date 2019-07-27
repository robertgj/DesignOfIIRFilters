% parallel_allpass_slb_update_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("parallel_allpass_slb_update_constraints_test.diary");
unlink("parallel_allpass_slb_update_constraints_test.diary.tmp");
diary parallel_allpass_slb_update_constraints_test.diary.tmp

format compact;

verbose=true
tol=1e-5

%
% Use the filters found by tarczynski_parallel_allpass_bandpass_hilbert_test.m
%
Da0 = [   1.0000000000,   0.3123079354,  -0.2317108438,   0.9181260586, ... 
          0.2492627390,  -0.1604453376,  -0.1449740884,   0.1991309068, ... 
          0.1424266816,  -0.7047805558,   0.0597938923,   0.1479724997, ... 
         -0.2887348192 ]';
Db0 = [   1.0000000000,  -0.2759072714,  -0.8959725116,   1.0579968251, ... 
          0.3672877136,  -0.4415731334,  -0.3552580282,   0.4705275516, ... 
          0.4602430859,  -0.8255136289,   0.0910399914,   0.3135264585, ... 
         -0.2785177818 ]';

% Filter specification
tol = 1e-06
maxiter = 2000
polyphase = false
difference = true
K=2
Ra = 1
ma = length(Da0)-1;
Rb = 1
mb = length(Db0)-1;
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.1
dBas=40
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=1000
Wasu=1000
ftpl=0.12
ftpu=0.18
td=16
tdr=td/400
Wtp=10
fppl=0.115
fppu=0.185
pd=1.5
pdr=1/5000
Wpp=2000

% Frequency vectors
n=1000;
wa=(0:(n-1))'*pi/n;

% Desired squared magnitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ksq=K^2;
Asqd=Ksq*[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=Ksq*[(10^(-dBas/10))*ones(nasl,1); ...
           (10^(-0.5*dBap/10))*ones(nasu-nasl-1,1); ...
           (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=Ksq*[zeros(napl-1,1);(10^(-dBap/10))*ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)]/Ksq;

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=td*ones(size(wt),1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pd*pi)-(td*wp);
Pdu=Pd+(pdr*pi/2);
Pdl=Pd-(pdr*pi/2);
Wp=Wpp*ones(nppu-nppl+1,1);

% Convert Da0 and Db0 to vector form
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);

% Response of ab0
Asqab0=parallel_allpassAsq(wa,ab0,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
Tab0=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
Pab0=parallel_allpassP(wp,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);

% Constraints
vS=parallel_allpass_slb_update_constraints ...
     (Asqab0,Asqdu,Asqdl,Wa,Tab0,Tdu,Tdl,Wt,Pab0,Pdu,Pdl,Wp,tol);
for [v,k]=vS
  printf("vS.%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Asql=Asqab0(vS.al);
Asqu=Asqab0(vS.au);
Tl=Tab0(vS.tl);
Tu=Tab0(vS.tu);
Pl=Pab0(vS.pl);
Pu=Pab0(vS.pu);

% Show constraints
parallel_allpass_slb_show_constraints(vS,wa,Asqab0/Ksq,wt,Tab0,wp,Pab0);

% Common strings
strd=sprintf("parallel_allpass_slb_update_constraints_test_%%s");
strM=sprintf("%%s:dBap=%g,dBas=%g,tdr=%f,pdr=%f",dBap,dBas,tdr,pdr);

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0,Asqdu,Asqdl]/Ksq), ...
     wa(vS.al)*0.5/pi,10*log10(Asql/Ksq),"x", ...
     wa(vS.au)*0.5/pi,10*log10(Asqu/Ksq),"+");
axis([fapl fapu -3*dBap dBap]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(sprintf(strM,"ab0 pass-band amplitude"));
legend("Asq","Asqdu","Asqdl","location","northeast");
legend("boxoff");
print(sprintf(strd,"pass_band_amplitude"),"-dpdflatex");
close

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0,Asqdu]/Ksq), ...
     wa(vS.al)*0.5/pi,10*log10(Asql/Ksq/Ksq),"x", ...
     wa(vS.au)*0.5/pi,10*log10(Asqu/Ksq),"+");
axis([0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(sprintf(strM,"ab0 stop-band amplitude"));
legend("Asq","Asqdu","location","northeast");
legend("boxoff");
print(sprintf(strd,"stop_band_amplitude"),"-dpdflatex");
close

% Plot group delay
plot(wt*0.5/pi,[Tab0,Tdu,Tdl], ...
     wt(vS.tl)*0.5/pi,Tl,"x",
     wt(vS.tu)*0.5/pi,Tu,"+");
axis([ftpl ftpu td-(2*tdr) td+(2*tdr)]);
ylabel("Group delay");
xlabel("Frequency")
strMdelay=sprintf(strM,"ab0 group delay");
title(strMdelay);
legend("Tab0","Tdu","Tdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"delay"),"-dpdflatex");
close

% Plot phase
plot(wp*0.5/pi,mod(([Pab0,Pdu,Pdl]+(td*wp))/pi,2), ...
     wp(vS.pl)*0.5/pi,mod((Pl+(td*wp(vS.pl)))/pi,2),"x",
     wp(vS.pu)*0.5/pi,mod((Pu+(td*wp(vS.pu)))/pi,2),"+");
axis([fppl fppu mod(pd-(5*pdr),2) mod(pd+(5*pdr),2)]);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency")
strMdelay=sprintf(strM,"ab0 phase");
title(strMdelay);
legend("Pab0","Pdu","Pdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"phase"),"-dpdflatex");
close

%
% Done
%
diary off
movefile parallel_allpass_slb_update_constraints_test.diary.tmp ...
         parallel_allpass_slb_update_constraints_test.diary;
