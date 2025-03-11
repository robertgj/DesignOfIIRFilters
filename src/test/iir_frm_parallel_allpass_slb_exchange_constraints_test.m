% iir_frm_parallel_allpass_slb_exchange_constraints_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("iir_frm_parallel_allpass_slb_exchange_constraints_test.diary");
delete("iir_frm_parallel_allpass_slb_exchange_constraints_test.diary.tmp");
diary iir_frm_parallel_allpass_slb_exchange_constraints_test.diary.tmp


maxiter=2000
verbose=true

%
% Filter specification
%
tol=5e-6 % Tolerance
Mmodel=9 % Model filter decimation
Dmodel=9.5 % Desired model filter passband delay
dmask=8.5 % FIR masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask % FRM filter nominal passband delay
fap=0.3 % Pass band edge
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=2 % Pass band delay ripple
Wtp=1 % Pass band delay weight
fas=0.31 % Pass band edge
dBas=50 % Stop band amplitude ripple
Was=10 % Stop band amplitude weight
rho=31/32 % Stability constraint on pole radius

%
% Use the filters found by tarczynski_frm_parallel_allpass_test.m
% and iir_frm_parallel_allpass_socp_slb_test.m
%
x0.r = [   1.0000000000,   0.0687358216,   0.0855437933,  -0.0174399668, ... 
          -0.0366839553,   0.0144496404,   0.0131725795,  -0.0099170638, ... 
          -0.0031769115,   0.0053198933,  -0.0026824698 ]';
x0.s = [   1.0000000000,  -0.0680450245,  -0.1381045880,   0.0366101568, ... 
           0.0668728144,  -0.0314494591,  -0.0305757140,   0.0237886387, ... 
           0.0114346106,  -0.0147371573 ]';
x0.aa = [ -0.0071806601,  -0.0111146351,  -0.0109144496,   0.1239779284, ... 
           0.3230846185,   0.2475172559,  -0.0709904817,  -0.1142124000, ... 
           0.1015559817,   0.0800090219,  -0.1272089598,  -0.0357266636, ... 
           0.2309683284,   0.2450065016,   0.0906854219,   0.0317841844, ... 
          -0.0021928715,  -0.0354373358,  -0.0029412121,   0.0281502110, ... 
          -0.0124706890,  -0.0337218615,  -0.0125735117,  -0.0152868067, ... 
          -0.0188286414 ]';
x0.ac = [  0.0096159359,   0.0119195016,  -0.0427343461,   0.1200196215, ... 
           0.4010275645,   0.2421175468,  -0.1361030937,  -0.0310289205, ... 
           0.1379491738,  -0.0714231993,  -0.0290442079,   0.1226598480, ... 
          -0.1269371072,  -0.2785779754,  -0.0271727061,   0.0391037212, ... 
          -0.0406810276,   0.0457841475,   0.0281880889,  -0.0421869262, ... 
           0.0088100575,   0.0406679333,  -0.0086870521,   0.0061513233, ... 
           0.0279183095 ]';
x1.r = [   1.0000000000,   0.1172274845,   0.0006587448,  -0.0010408683, ... 
          -0.0101607468,   0.0019687350,   0.0047755869,  -0.0013637430, ... 
          -0.0016278191,   0.0011733077,  -0.0005436203 ]';
x1.s = [   1.0000000000,  -0.1420041086,  -0.0930822656,   0.0163831482, ... 
           0.0582208493,  -0.0133293838,  -0.0295210745,   0.0073989338, ... 
           0.0110799401,  -0.0062302462 ]';
x1.aa = [ -0.0485477032,  -0.0469019429,  -0.0249527657,   0.1126529760, ... 
           0.3771800297,   0.3359292664,  -0.0520587490,  -0.1537153933, ... 
           0.0995036116,   0.1224363825,  -0.1273859074,  -0.0629436519, ... 
           0.2073882642,   0.1875726376,   0.0585354945,   0.0694974064, ... 
           0.0514620541,  -0.0322503517,   0.0086377480,   0.0571301083, ... 
          -0.0111384463,  -0.0491244529,  -0.0138176456,  -0.0349334368, ... 
          -0.0338983479 ]';
x1.ac = [ -0.0589061492,   0.0303485616,  -0.0178790241,   0.0697273761, ... 
           0.5065935598,   0.4460696371,  -0.1531609595,  -0.1199026998, ... 
           0.2615014365,  -0.0933603761,  -0.1319109974,   0.1654547899, ... 
          -0.0313746990,  -0.1610304820,   0.1257336724,   0.0445732621, ... 
          -0.0971670410,   0.1399455734,   0.0274841286,  -0.1389260014, ... 
           0.0188387130,   0.1028091412,  -0.0095393138,   0.0366570570, ... 
           0.0722738008 ]';

% Frequency vectors
n=1000;
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];

% Group delay constraints
Wt=Wtp*ones(nap,1);
Td=Tnominal*ones(nap,1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);

% Convert x0 and x1 to vector form
[x0k,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);
[x1k,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x1);

% Response of x0k
[Asqx0,Tx0]=iir_frm_parallel_allpass(w,x0k,Vr,Qr,Vs,Qs,na,nc,Mmodel);
Tx0=Tx0(1:nap);

% Response of x1k
[Asqx1,Tx1]=iir_frm_parallel_allpass(w,x1k,Vr,Qr,Vs,Qs,na,nc,Mmodel);
Tx1=Tx1(1:nap);

% Update constraints
vRx0=iir_frm_parallel_allpass_slb_update_constraints ...
       (Asqx0,Asqdu,Asqdl,Wa,Tx0,Tdu,Tdl,Wt,tol);
vSx1=iir_frm_parallel_allpass_slb_update_constraints ...
       (Asqx1,Asqdu,Asqdl,Wa,Tx1,Tdu,Tdl,Wt,tol);

% Show constraints
printf("vRx0 before exchange constraints:\n");
iir_frm_parallel_allpass_slb_show_constraints(vRx0,w,Asqx0,Tx0);
printf("vSx1 before exchange constraints:\n");
iir_frm_parallel_allpass_slb_show_constraints(vSx1,w,Asqx1,Tx1);

% Plot amplitude
strd=sprintf("iir_frm_parallel_allpass_slb_exchange_constraints_test_%%s");
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,tpr=%g,Wtp=%g", ...
             fap,dBap,Wap,fas,dBas,Was,tpr,Wtp);
f=w*0.5/pi;
subplot(211);
plot(f(1:nap),10*log10([Asqx0(1:nap),Asqdu(1:nap),Asqdl(1:nap)]), ...
     f(vRx0.al),10*log10(Asqx0(vRx0.al)),"*", ...
     f(vRx0.au),10*log10(Asqx0(vRx0.au)),"+");
axis([0,fas,-1,1]);
strMx0=sprintf(strM,"x0");
title(strMx0);
ylabel("Amplitude(dB)");
subplot(212);
plot(f(nas:end),10*log10([Asqx0(nas:end),Asqdu(nas:end), ...
                            Asqdu(nas:end)+tol*ones(n-nas+1,1)]), ...
     f(vRx0.al),10*log10(Asqx0(vRx0.al)),"*", ...
     f(vRx0.au),10*log10(Asqx0(vRx0.au)),"+");
axis([fap,0.5,-60,-20]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
legend("Asqx0","Asqdu","tol","location","northeast");
legend("boxoff");
print(sprintf(strd,"x0A"),"-dpdflatex");
close

% Plot group delay
ft=w(1:nap)*0.5/pi;
plot(ft,[Tx0(1:nap),Tdu,Tdl], ...
     ft(vRx0.tl),Tx0(vRx0.tl),"*", ...
     ft(vRx0.tu),Tx0(vRx0.tu),"+");
title(strMx0);
axis([0,fap,90,100])
ylabel("Delay(samples)");
xlabel("Frequency")
print(sprintf(strd,"x0T"),"-dpdflatex");
close

% Exchange constraints
[vRx1,vSx1,exchanged] = ...
iir_frm_parallel_allpass_slb_exchange_constraints ...
  (vSx1,vRx0,Asqx1,Asqdu,Asqdl,Tx1,Tdu,Tdl,tol);
printf("vRx1 after exchange constraints:\n");
iir_frm_parallel_allpass_slb_show_constraints(vRx1,w,Asqx1,Tx1);
printf("vSx1 after exchange constraints:\n");
iir_frm_parallel_allpass_slb_show_constraints(vSx1,w,Asqx1,Tx1);

% Plot amplitude
subplot(211);
plot(f(1:nap),10*log10([Asqx0(1:nap),Asqx1(1:nap), ...
                 Asqdu(1:nap),Asqdl(1:nap)]), ...
     f(vRx0.al),10*log10(Asqx0(vRx0.al)),"*", ...
     f(vRx0.au),10*log10(Asqx0(vRx0.au)),"+", ...
     f(vSx1.al),10*log10(Asqx1(vSx1.al)),"*", ...
     f(vSx1.au),10*log10(Asqx1(vSx1.au)),"+");
axis([0,fas,-1,1]);
strMx1=sprintf(strM,"x1");
title(strMx1);
ylabel("Amplitude(dB)");
subplot(212);
plot(f(nas:end), ...
     10*log10([Asqx0(nas:end),Asqx1(nas:end),Asqdu(nas:end), ...
               Asqdu(nas:end)+tol*ones(n-nas+1,1)]), ...
     f(vRx0.al),10*log10(Asqx0(vRx0.al)),"*", ...
     f(vRx0.au),10*log10(Asqx0(vRx0.au)),"+", ...
     f(vSx1.al),10*log10(Asqx1(vSx1.al)),"*", ...
     f(vSx1.au),10*log10(Asqx1(vSx1.au)),"+");
axis([fap 0.5 -60 -10]);
ylabel("Amplitude(dB)");
xlabel("Frequency")
legend("Asqx0","Asqx1","Asqdu","tol","location","northeast");
legend("boxoff");
print(sprintf(strd,"x1A"),"-dpdflatex");
close

% Plot group delay
plot(ft,[Tx0(1:nap),Tx1(1:nap),Tdu,Tdl], ...
     ft(vRx0.tl),Tx0(vRx0.tl),"*",f(vRx0.tu),Tx0(vRx0.tu),"+", ...
     ft(vSx1.tl),Tx1(vSx1.tl),"*",f(vSx1.tu),Tx1(vSx1.tu),"+");
axis([0 fap 90 100])
title(strMx1);
ylabel("Delay(samples)");
xlabel("Frequency")
legend("Tx0","Tx1","Tdu","Tdl","location","northeast");
legend("boxoff");
print(sprintf(strd,"x1T"),"-dpdflatex");
close

diary off
movefile iir_frm_parallel_allpass_slb_exchange_constraints_test.diary.tmp iir_frm_parallel_allpass_slb_exchange_constraints_test.diary;
