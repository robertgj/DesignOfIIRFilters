% schurOneMAPlattice_frm_halfband_slb_update_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frm_halfband_slb_update_constraints_test.diary");
delete...
  ("schurOneMAPlattice_frm_halfband_slb_update_constraints_test.diary.tmp");
diary schurOneMAPlattice_frm_halfband_slb_update_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

%
% Filter from schurOneMAPlattice_frm_halfband_socp_slb_test.diary
%
k1=[  0.536636 -0.111334 0.0275265 -0.00920997 -0.00567939  ]';
p0=ones(size(k1));
epsilon0=[1,  1, -1, -1, 1 ]';
u1=[ -0.00545337 0.00618762 -0.0109289 0.0137402 -0.0264064 ...
      0.0334318 -0.0434561 0.0448541 0.451607  ]';
v1=[ 0.00369211 -0.00390894 0.00135012 0.00708067 -0.0169857 ...
     0.0413353 -0.0873232 0.312228  ]';

Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(k1); % Model filter order
na=(4*length(v1))+1;  % FIR masking filter length
dmask=2*length(v1); % FIR masking filter delay
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
fap=0.24 % Amplitude pass band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
ftp=0.24 % Delay pass band edge
tpr=0.4 % Peak-to-peak pass band delay ripple
Wtp=0.2 % Pass band delay weight
fas=0.26 % Amplitude stop band edge
dBas=45 % Stop band amplitude ripple
Was=100 % Stop band amplitude weight

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
wa=w;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(ftp*n/0.5)+1;
wt=w(1:ntp);
Td=zeros(ntp,1);
Tdu=(tpr/2)*ones(ntp,1);
Tdl=-Tdu;
Wt=Wtp*ones(ntp,1);

% Common strings
strd=sprintf("schurOneMAPlattice_frm_halfband_slb_update_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,ftp=%g,tpr=%g,Wtp=%g,\
,fas=%g,dBas=%g,Was=%g",fap,dBap,Wap,ftp,tpr,Wtp,fas,dBas,Was);

% Calculate frequency response
Asq1=schurOneMAPlattice_frm_halfbandAsq(wa,k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);
T1=schurOneMAPlattice_frm_halfbandT(wt,k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);

% Update constraints
vS=schurOneMAPlattice_frm_halfband_slb_update_constraints ...
     (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,tol);
for [vv,mm]=vS
  printf("%s=[ ",mm);printf("%d ",vv);printf("]\n");
endfor
Asql=schurOneMAPlattice_frm_halfbandAsq(wa(vS.al), ...
                                        k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);
Asqu=schurOneMAPlattice_frm_halfbandAsq(wa(vS.au), ...
                                        k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);
Tl=schurOneMAPlattice_frm_halfbandT(wt(vS.tl), ...
                                    k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);
Tu=schurOneMAPlattice_frm_halfbandT(wt(vS.tu), ...
                                    k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);

% Show constraints
schurOneMAPlattice_frm_halfband_slb_show_constraints(vS,wa,Asq1,wt,T1);

% Plot amplitude
fa=wa*0.5/pi;
strM1=sprintf(strM,"Asq(k1)");
subplot(211);
plot(fa,Asq1,fa,Asqdu,fa,Asqdl,fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
axis([0 0.5 0.95 1.05]);
title(strM1);
ylabel("Amplitude");
subplot(212);
plot(fa,Asq1,fa,Asqdu,fa,Asqdl,fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
axis([0 0.5 0 2e-4]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"Asq1"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
subplot(111);
plot(ft,T1,ft,Tdu,":",ft,Tdl,"-.",ft(vS.tl),Tl,"x",ft(vS.tu),Tu,"+");
axis([0 ftp -(tpr*2) +(tpr*2)]);
strM1=sprintf(strM,"T(k1)");
title(strM1);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"T1"),"-dpdflatex");
close

% Done
diary off
movefile schurOneMAPlattice_frm_halfband_slb_update_constraints_test.diary.tmp...
       schurOneMAPlattice_frm_halfband_slb_update_constraints_test.diary;
