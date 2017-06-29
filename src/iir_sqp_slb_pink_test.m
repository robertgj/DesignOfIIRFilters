% iir_sqp_slb_pink_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_sqp_slb_pink_test.diary");
unlink("iir_sqp_slb_pink_test.diary.tmp");
diary iir_sqp_slb_pink_test.diary.tmp

tic;

format compact;

tol_mmse=2e-5
tol_pcls=1e-5
maxiter=5000
verbose=false

% Initial filter from tarczynski_pink_test.m
if 1
  N0=[   0.0255743587   0.0278384489   0.0321476859   0.0361079952 ...
         0.0657889278   0.2319828340   0.0319161641  -0.0285660148 ...
        -0.0468650948  -0.0439578015  -0.0332308639   0.0133637638 ]';
  D0=[   1.0000000000  -0.0879376251  -0.1670765454  -0.1960898452 ...
        -0.1461189848  -0.1356729636   0.1032110433  -0.0102026181 ...
         0.0012949550  -0.0039114345  -0.0018552456  -0.0051358746 ]'; 
  fat=0.005;
  Ar=0.04;
  Wap=10;
  ftt=0.02;
  tp=4.78;  %tp=(length(N0-1))/2
  tpr=0.04;
else
  N0=[   0.0193294800   0.0205412539   0.0210639727   0.0204516760 ...
         0.0232849743   0.0273023287   0.0583173135   0.2274261525 ...
         0.0304900609  -0.0370176081  -0.0640675209  -0.0701325758 ...
        -0.0520478648  -0.0191991766   0.0133676549   0.0625648379 ]';
  D0=[   1.0000000000  -0.0768129058  -0.1776077315  -0.2334328873 ...
        -0.2267584763  -0.1674945147  -0.0474576211   0.0279826619 ...
         0.2958131622  -0.0645883873  -0.0097466778  -0.0097348873 ...
        -0.0020173246  -0.0072810002  -0.0023166255  -0.0047590610 ]';t
  fat=0.025;
  Ar=0.03;
  Wap=100;
  ftt=0.025;
  tp=6.8;
  tpr=0.04;
endif
[x0,U,V,M,Q]=tf2x(N0,D0);
R=1;

% Frequency vector
n=1000;
wd=(0:(n-1))'*pi/n;

% Pass-band amplitude
nat=floor(fat*n/0.5);
wa=wd(nat:end);
Ad=(0.1)./sqrt(0.5*wa/pi);
Wap=100;
Wa=Wap*ones(size(wa));
Adu=Ad*(1+(Ar/2));
Adl=Ad/(1+(Ar/2));

% Stop-band amplitude 
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Delay response
ntt=floor(ftt*n/0.5);
wt=wd(ntt:end);
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wtp=1;
Wt=Wtp*ones(size(wt));

% Phase
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Show initial response and constraints
if 0
  subplot(211);
  A0=iirA(wa,x0,U,V,M,Q,R);
  semilogx(wa*0.5/pi,20*log10(A0),'linestyle','-', ...
           wa*0.5/pi,20*log10(Ad),'linestyle','-.');
  strI=sprintf("Pink noise filter initial response : fat=%g,ftt=%g,tp=%g", ...
               fat,ftt,tp);
  title(strI);
  ylabel("Amplitude(dB)");
  legend("Tarczynski et al.","Desired");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  grid("on");
  subplot(212);
  T0=iirT(wt,x0,U,V,M,Q,R);
  plot(wt*0.5/pi,T0,'linestyle','-', ...
       wt*0.5/pi,Td,'linestyle','-.');
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  grid("on");
  strd=sprintf("iir_sqp_slb_pink_%%s_%%s");
  print(sprintf(strd,"init","x0"),"-dpdflatex");
  close
else
  subplot(111);
  A0=iirA(wa,x0,U,V,M,Q,R);
  semilogx(wa*0.5/pi,20*log10(A0),'linestyle','-', ...
           wa*0.5/pi,20*log10(Ad),'linestyle','-.');
  axis([0.003 0.6 -20 5]);
  strI=sprintf("Pink noise filter initial amplitude response : \
fat=%g,ftt=%g,tp=%g",fat,ftt,tp);
  title(strI);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  legend("Tarczynski et al.","Desired");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  grid("on");
  strd=sprintf("iir_sqp_slb_pink_%%s_%%s");
  print(sprintf(strd,"init","x0"),"-dpdflatex");
  close
endif
showZPplot(x0,U,V,M,Q,R,strI);
print(sprintf(strd,"init","x0pz"),"-dpdflatex");
close

% MMSE pass
printf("\nMMSE pass:\n");
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol_mmse,verbose)
if feasible == 0 
  error("x1 (mmse) infeasible");
endif
subplot(211);
Ax1=iirA(wa,x1,U,V,M,Q,R);
plot(wa*0.5/pi,20*log10([Ax1 Adu Adl])-20*log10([Ad Ad Ad]));
axis([0 0.5 -20*log10(1+Ar) 20*log10(1+Ar)]);
grid("on");
strM=sprintf("Pink noise filter MMSE response : fat=%g, ftt=%g,tp=%g", ...
             fat,ftt,tp);
title(strM);
ylabel("Amplitude error(dB)");
subplot(212);
Tx1=iirT(wt,x1,U,V,M,Q,R);
plot(wt*0.5/pi,[Tx1 Tdu Tdl]);
axis([0 0.5 tp-tpr tp+tpr]);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"mmse","x1"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM);
print(sprintf(strd,"mmse","x1pz"),"-dpdflatex");
close

% PCLS pass
printf("\nPCLS pass:\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol_pcls,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
subplot(211);
Ad1=iirA(wa,d1,U,V,M,Q,R);
plot(wa*0.5/pi,20*log10([Ad1 Adu Adl])-20*log10([Ad Ad Ad]));
axis([0 0.5 -20*log10(1+Ar) 20*log10(1+Ar)]);
grid("on");
strP=sprintf("Pink noise filter PCLS response : \
fat=%g,Ar=%g,ftt=%g,tp=%g,tpr=%g",fat,Ar,ftt,tp,tpr);
title(strP);
ylabel("Amplitude error(dB)");
subplot(212);
Td1=iirT(wt,d1,U,V,M,Q,R);
plot(wt*0.5/pi,[Td1 Tdu Tdl]);
axis([0 0.5 tp-tpr tp+tpr]);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"pcls","d1"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strP);
print(sprintf(strd,"pcls","d1pz"),"-dpdflatex");
close

% Coefficients
print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0","iir_sqp_slb_pink_test_x0_coef.m");
print_pole_zero(x1,U,V,M,Q,R,"x1");
print_pole_zero(x1,U,V,M,Q,R,"x1","iir_sqp_slb_pink_test_x1_coef.m");
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1","iir_sqp_slb_pink_test_d1_coef.m");
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1","iir_sqp_slb_pink_test_N1_coef.m");
print_polynomial(D1,"D1");
print_polynomial(D1,"D1","iir_sqp_slb_pink_test_D1_coef.m");

% Filter specification
fid=fopen("iir_sqp_slb_pink_test.spec","wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol_mmse=%g %% Tolerance on coef. update (MMSE pass)\n",tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on coef. update (PCLS pass)\n",tol_pcls);
fprintf(fid,"fat=%g %% Amplitude transition band width\n",fat);
fprintf(fid,"Ar=%g %% Relative amplitude peak-to-peak ripple\n",Ar);
fprintf(fid,"Wap=%d %% Amplitude weight\n",Wap);
fprintf(fid,"ftt=%g %% Group delay transition band width\n",ftt);
fprintf(fid,"tp=%g %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Filter group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Filter group delay weight\n",Wtp);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);

% Done
save iir_sqp_slb_pink_test.mat ...
     U V M Q R x0 d1 tol_mmse tol_pcls n wd fat Ad Ar ftt tp Td tpr

toc;

diary off
movefile iir_sqp_slb_pink_test.diary.tmp iir_sqp_slb_pink_test.diary;
