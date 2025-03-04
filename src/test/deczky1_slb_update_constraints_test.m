% deczky1_slb_update_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("deczky1_slb_update_constraints_test.diary");
delete("deczky1_slb_update_constraints_test.diary.tmp");
diary deczky1_slb_update_constraints_test.diary.tmp


verbose=true
tol=1e-5

% Deczky3 Lowpass filter specification
fap=0.15,dBap=0.1,Wap=1,Wat=0.01
fas=0.3,dBas=60,Was=1
ftp=0.25,tp=6,tpr=0.025,Wtp=1
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("tp=%d,rtp=%g",tp,tpr));

% Initial coefficients
U=2,V=0,M=10,Q=6,R=1
x7 = [   0.0112122730, ...
        -0.9861004418,  -0.9861004336, ...
         0.9715772075,   0.9771125907,   0.9922923829,   1.5722087253, ... 
         1.6110573997, ...
         2.1121907965,   2.4859615633,   1.9044365672,   1.0364670361, ... 
         0.3501543945, ...
         0.4529386321,   0.6593886914,   0.9551538736, ...
         0.5786060583,   1.4735817876,   1.7176976492 ]';

% Frequency vectors
n=1000;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
wa=w;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Ad=[ones(nap,1); zeros(n-nap,1)];
Adu=[ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(ftp*n/0.5)+1;
wt=w(1:ntp);
Wt=Wtp*ones(size(wt));
Td=tp*ones(size(wt));
Tdu=(tp+(tpr/2))*ones(size(wt));
Tdl=(tp-(tpr/2))*ones(size(wt));

% Transition band amplitude derivative constraint frequencies
wx=w(nap:nas);

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);

% Response
A=iirA(w,x7,U,V,M,Q,R);
T=iirT(wt,x7,U,V,M,Q,R);
delAdelw=iirdelAdelw(wx,x7,U,V,M,Q,R);

% Constraints
vS=deczky1_slb_update_constraints(x7,U,V,M,Q,R, ...
                                  wa,Adu,Adl,Wa,wt,Tdu,Tdl,Wt,wx,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor

% Show constraints
deczky1_slb_show_constraints(vS,wa,A,wt,T,wx,delAdelw);

% Plot amplitude
fa=wa*0.5/pi;
strd=sprintf("deczky1_slb_update_constraints_test_%%s");
strM7=sprintf(strM,"x7");
subplot(211);
plot(fa,A,fa,Adu,fa,Adl,fa(vS.al),A(vS.al),"x",fa(vS.au),A(vS.au),"+");
axis([0 0.5 0.9 1.02]);
title(strM7);
ylabel("Amplitude");
subplot(212);
plot(fa,A,fa,Adu,fa,Adl,fa(vS.al),A(vS.al),"x",fa(vS.au),A(vS.au),"+");
axis([0 0.5 0 2e-2]);
ylabel("Amplitude");
xlabel("Frequency")
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
print(sprintf(strd,"x7T"),"-dpdflatex");
close

% Plot derivative of transition-band amplitude response
fx=wx*0.5/pi;
subplot(111);
plot(fx,delAdelw,fx(vS.ax),delAdelw(vS.ax),"x");
axis([fap fas]);
title(strM7);
ylabel("delAdelw");
xlabel("Frequency")
print(sprintf(strd,"x7X"),"-dpdflatex");
close

%
% Done
%
diary off
movefile deczky1_slb_update_constraints_test.diary.tmp ...
         deczky1_slb_update_constraints_test.diary;
