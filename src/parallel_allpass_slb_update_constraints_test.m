% parallel_allpass_slb_update_constraints_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("parallel_allpass_slb_update_constraints_test.diary");
unlink("parallel_allpass_slb_update_constraints_test.diary.tmp");
diary parallel_allpass_slb_update_constraints_test.diary.tmp

format compact;

verbose=true
tol=1e-5

%
% Use the filters found by tarczynski_frm_parallel_allpass_test.m
%
Da0=[  1.0000000000,   0.5644605415,  -0.3056222591,  -0.2415730335, ... 
       0.0256333874,   0.2514930770,  -0.1559975498,  -0.0115350049, ... 
       0.1136206749,  -0.1395015083,   0.0465486808,   0.0320384980 ]';
Db0=[  1.0000000000,   0.1241070032,  -0.2051723448,   0.1858795419, ... 
       0.0410325915,   0.0645608025,  -0.2902638241,   0.1849229645, ... 
       0.1093103052,  -0.2229380801,   0.1353491692,  -0.0251777039, ... 
      -0.0248722010 ]';

% Filter specification
tol = 1e-06
maxiter = 2000
polyphase = 0
Ra = 1
ma = 11
Rb = 1
mb = 12
td = 11.500
tdr = 0.04
fap = 0.17500
Wap = 1
dBap = 1
ftp = 0.20000
Wtp = 5
fas = 0.25000
Wat = 1
Was = 500
dBas = 50

% Frequency vectors
n=1000;
nap=ceil(fap*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Pass-band amplitude constraints
wa=(0:(n-1))*pi/n;
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];
Asqd=[0.9*ones(nap,1);zeros(n-nap,1)];
Asqdu=[0.9*ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];

% Group delay constraints
wt=(0:(ntp-1))*pi/n;
Wt=Wtp*ones(ntp,1);
Td=td*ones(ntp,1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);

% Convert Da0 and Db0 to vector form
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);

% Response of ab0
Asqab0=parallel_allpassAsq(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
Tab0=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase);

% Constraints
vS=parallel_allpass_slb_update_constraints ...
     (Asqab0,Asqdu,Asqdl,Wa,Tab0,Tdu,Tdl,Wt,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Asql=Asqab0(vS.al);
Asqu=Asqab0(vS.au);
Tl=Tab0(vS.tl);
Tu=Tab0(vS.tu);

% Show constraints
parallel_allpass_slb_show_constraints(vS,wa,Asqab0,wt,Tab0);

% Common strings
strd=sprintf("parallel_allpass_slb_update_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,tdr=%f",
             fap,dBap,fas,dBas,tdr);

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0,Asqdu,Asqdl]), ...
     wa(vS.al)*0.5/pi,10*log10(Asql),"x", ...
     wa(vS.au)*0.5/pi,10*log10(Asqu),"+");
axis([0 fap -3 1]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(sprintf(strM,"ab0 pass-band amplitude"));
legend("Asq","Asqdu","Asqdl","location","southwest");
legend("boxoff");
print(sprintf(strd,"pass_band_amplitude"),"-dpdflatex");
close

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10([Asqab0,Asqdu]), ...
     wa(vS.al)*0.5/pi,10*log10(Asql),"x", ...
     wa(vS.au)*0.5/pi,10*log10(Asqu),"+");
axis([fas 0.5 -60 -20]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(sprintf(strM,"ab0 stop-band amplitude"));
legend("Asq","Asqdu","location","northwest");
legend("boxoff");
print(sprintf(strd,"stop_band_amplitude"),"-dpdflatex");
close

% Plot group delay
plot(wt*0.5/pi,[Tab0,Tdu,Tdl], ...
     wt(vS.tl)*0.5/pi,Tl,"x",
     wt(vS.tu)*0.5/pi,Tu,"+");
axis([0 ftp 11.4 11.6]);
ylabel("Group delay");
xlabel("Frequency")
strMdelay=sprintf(strM,"ab0 group delay");
title(strMdelay);
legend("Tab0","Tdu","Tdl","location","northwest");
legend("boxoff");
print(sprintf(strd,"delay"),"-dpdflatex");
close

%
% Done
%
diary off
movefile parallel_allpass_slb_update_constraints_test.diary.tmp ...
         parallel_allpass_slb_update_constraints_test.diary;
