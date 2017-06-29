% iir_slb_update_constraints_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_slb_update_constraints_test.diary");
unlink("iir_slb_update_constraints_test.diary.tmp");
diary iir_slb_update_constraints_test.diary.tmp

format compact;

verbose=true
tol=1e-5

% Deczky3 Lowpass filter specification
U=0,V=0,Q=6,M=10,R=1
fap=0.15,dBap=0.1,Wap=1
fas=0.3,dBas=60,Was=1
ftp=0.25,tp=6,tpr=0.025,Wtp=1

strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("tp=%d,rtp=%g",tp,tpr));

% Initial coefficients (x7 from Deczky3_test.m)
x7 = [ 0.0094386 ...
      -0.9707899 -0.8841912  0.6883779  0.9158562  2.2629943 ...
      -5.0822167  6.2522910  2.4789154 -2.3366191  0.4205817 ...
       0.4974948  0.6825980  0.0573631 ...
       1.2056808   1.8164313  -0.2724392 ]';

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
Wa=ones(n,1);

% Stop-band amplitude constraints
ws = [];
Ws = [];
Sd  = [];
Sdu = [];
Sdl = [];

% Group delay constraints
Wt=ones(ntp,1);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);

% Phase constraints
Wp=[];
wp=[];
Pd=[];
Pdu=[];
Pdl=[];

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);

% Response
A=iirA(wa,x7,U,V,M,Q,R);
S=[];
T=iirT(wt,x7,U,V,M,Q,R);
P=[];

% Constraints
vS=iir_slb_update_constraints(x7,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                              wp,Pdu,Pdl,Wp,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor

% Show constraints
iir_slb_show_constraints(vS,wa,A,ws,S,wt,T,wp,P);

% Plot amplitude
fa=wa*0.5/pi;
strd=sprintf("iir_slb_update_constraints_test_%%s");
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
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x7T"),"-dpdflatex");
close

%
% Done
%
diary off
movefile iir_slb_update_constraints_test.diary.tmp iir_slb_update_constraints_test.diary;
