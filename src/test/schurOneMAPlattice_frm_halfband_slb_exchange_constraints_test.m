% schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.diary");
delete...
  ("schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.diary.tmp");
diary schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=5e-6
verbose=true

%
% Filter from tarczynski_frm_halfband_test.m
%
r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
         0.0035706175,  -0.0098219303 ]';
aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
        -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
        -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
        -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
         0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
        -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
        -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
        -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
        -0.0019232288 ]';
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
na=length(aa0);  % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay
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

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,~,~] = tf2schurOneMlattice(flipud(r0),r0);
p0=ones(size(k0));
u0=aa0(1:2:dmask+1);
v0=aa0(2:2:dmask);

%
% Filter from schurOneMAPlattice_frm_halfband_socp_slb_test.diary
%
k1=[  0.536636 -0.111334 0.0275265 -0.00920997 -0.00567939  ]';
u1=[ -0.00545337 0.00618762 -0.0109289 0.0137402 -0.0264064 ...
      0.0334318 -0.0434561 0.0448541 0.451607  ]';
v1=[ 0.00369211 -0.00390894 0.00135012 0.00708067 -0.0169857 ...
     0.0413353 -0.0873232 0.312228  ]';

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
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("tp=%d,tpr=%g,Wtp=%g",tp,tpr,Wtp));

% Calculate frequency response
Asq0=schurOneMAPlattice_frm_halfbandAsq(wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
T0=schurOneMAPlattice_frm_halfbandT(wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Asq1=schurOneMAPlattice_frm_halfbandAsq(wa,k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);
T1=schurOneMAPlattice_frm_halfbandT(wt,k1,epsilon0,p0,u1,v1,Mmodel,Dmodel);

% Update constraints
vR0=schurOneMAPlattice_frm_halfband_slb_update_constraints ...
      (Asq0,Asqdu,Asqdl,Wa,T0,Tdu,Tdl,Wt,tol);
vS1=schurOneMAPlattice_frm_halfband_slb_update_constraints ...
      (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,tol);

% Show constraints
printf("vR0 before exchange constraints:\n");
schurOneMAPlattice_frm_halfband_slb_show_constraints(vR0,wa,Asq0,wt,T0);
printf("vS1 before exchange constraints:\n");
schurOneMAPlattice_frm_halfband_slb_show_constraints(vS1,wa,Asq1,wt,T1);

% Plot amplitude
strd=sprintf(["schurOneMAPlattice_frm_halfband_", ...
 "slb_exchange_constraints_test_%%s"]);
strM=sprintf(["%%s:fap=%g,dBap=%g,Wap=%g,ftp=%g,tpr=%g,Wtp=%g,", ...
 ",fas=%g,dBas=%g,Was=%g"],fap,dBap,Wap,ftp,tpr,Wtp,fas,dBas,Was);
fa=wa*0.5/pi;
subplot(211);
plot(fa(1:nap),10*log10([Asq0(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([0,fap,-0.25,0.25]);
strM0=sprintf(strM,"Asq0");
title(strM0);
ylabel("Amplitude");
subplot(212);
plot(fa(nas:end),10*log10([Asq0(nas:end),Asqdu(nas:end)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+");
axis([fas,0.5,-60,-30]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
print(sprintf(strd,"Asq0"),"-dpdflatex");
close

% Plot group delay
ft=wt*0.5/pi;
plot(ft,[T0,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),"*", ...
     ft(vR0.tu),T0(vR0.tu),"+");
strM0=sprintf(strM,"T0");
title(strM0);
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"T0"),"-dpdflatex");
close

% Exchange constraints
[vR2,vS1,exchanged]=schurOneMAPlattice_frm_halfband_slb_exchange_constraints...
                      (vS1,vR0,Asq1,Asqdu,Asqdl,T1,Tdu,Tdl,tol);
printf("exchanged=%d\n",exchanged);
printf("vR2 after exchange constraints:\n");
schurOneMAPlattice_frm_halfband_slb_show_constraints(vR2,wa,Asq1,wt,T1);
printf("vS1 after exchange constraints:\n");
schurOneMAPlattice_frm_halfband_slb_show_constraints(vS1,wa,Asq1,wt,T1);

% Plot amplitude
subplot(211);
plot(fa(1:nap),10*log10([Asq0(1:nap),Asq1(1:nap), ...
                         Asqdu(1:nap),Asqdl(1:nap)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+", ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),"*", ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),"+");
axis([0,fap,-0.25,0.25]);
strM1=sprintf(strM,"Asq1");
title(strM1);
ylabel("Amplitude");
subplot(212);
plot(fa(nas:end), ...
     10*log10([Asq0(nas:end),Asq1(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(n-nas+1,1)]), ...
     fa(vR0.al),10*log10(Asq0(vR0.al)),"*", ...
     fa(vR0.au),10*log10(Asq0(vR0.au)),"+", ...
     fa(vS1.al),10*log10(Asq1(vS1.al)),"*", ...
     fa(vS1.au),10*log10(Asq1(vS1.au)),"+");
axis([fas 0.5 -60 -20]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
legend("Asq0","Asq1","Asqdu","Asqdu+tol","location","northeast");
legend("boxoff");
print(sprintf(strd,"Asq1"),"-dpdflatex");
close

% Plot group delay
plot(ft,[T0,T1,Tdu,Tdl], ...
     ft(vR0.tl),T0(vR0.tl),"*",ft(vR0.tu),T0(vR0.tu),"+", ...
     ft(vS1.tl),T1(vS1.tl),"*",ft(vS1.tu),T1(vS1.tu),"+");
axis([0 0.25 -(tpr*2) +(tpr*4)]);
strM1=sprintf(strM,"T1");
title(strM1);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("T0","T1","Tdu","Tdl","location","northeast");
legend("boxoff");
print(sprintf(strd,"T1"),"-dpdflatex");
close

diary off
movefile schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.diary.tmp...
       schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.diary;
