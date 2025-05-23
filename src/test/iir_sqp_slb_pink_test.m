% iir_sqp_slb_pink_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_pink_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=10000
ftol=2e-5
ctol=ftol
verbose=false

% Initial pink noise filter from tarczynski_pink_test.m
tarczynski_pink_test_D0_coef;
tarczynski_pink_test_N0_coef;
[x0,U,V,M,Q]=tf2x(N0,D0);
R=1;

% Filter specifications
fat=0.005;
AdBr=0.2;
Wap=20;
ftt=0.025;
tp=4.77;
tpr=0.02;
Wtp=1;

% Frequency vector
n=1000;
wd=(0:(n-1))'*pi/n;

% Pass-band amplitude
nat=floor(fat*n/0.5);
wa=wd(nat:end);
Ad=(0.1)./sqrt(0.5*wa/pi);
Wa=Wap*ones(size(wa));
Adu=Ad*(10^(0.5*AdBr/20));
Adl=Ad/(10^(0.5*AdBr/20));

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
  semilogx(wa*0.5/pi,20*log10(A0),"linestyle","-", ...
           wa*0.5/pi,20*log10(Ad),"linestyle","-.");
  strt=sprintf("Pink noise filter initial response : fat=%g,ftt=%g,tp=%g", ...
               fat,ftt,tp);
  title(strt);
  ylabel("Amplitude(dB)");
  legend("Tarczynski et al.","Desired");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  grid("on");
  subplot(212);
  T0=iirT(wt,x0,U,V,M,Q,R);
  plot(wt*0.5/pi,T0,"linestyle","-", ...
       wt*0.5/pi,Td,"linestyle","-.");
  ylabel("Delay(samples)");
  xlabel("Frequency");
  grid("on");
  print(strcat(strf,"_init_x0"),"-dpdflatex");
  close
else
  subplot(111);
  ni=floor(0.002*n/0.5);
  A0=iirA(wd(ni:end),x0,U,V,M,Q,R);
  semilogx(wd(ni:end)*0.5/pi,20*log10(A0),"linestyle","-", ...
           wa*0.5/pi,20*log10(Ad),"linestyle","-.");
  axis([0.001 0.6 -20 5]);
  strt=sprintf(["Pink noise filter initial amplitude response : ", ...
 "fat=%g,ftt=%g,tp=%g"],fat,ftt,tp);
  title(strt);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  legend("Tarczynski et al.","Desired");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_init_x0"),"-dpdflatex");
  close
endif
showZPplot(x0,U,V,M,Q,R,strt);
print(strcat(strf,"_init_x0pz"),"-dpdflatex");
close

% MMSE pass
printf("\nMMSE pass:\n");
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("x1 (mmse) infeasible");
endif
subplot(211);
Ax1=iirA(wa,x1,U,V,M,Q,R);
plot(wa*0.5/pi,20*log10([Ax1 Adu Adl])-20*log10([Ad Ad Ad]));
axis([0 0.5 -AdBr AdBr]);
grid("on");
strt=sprintf("Pink noise filter MMSE response : fat=%g, ftt=%g,tp=%g", ...
             fat,ftt,tp);
title(strt);
ylabel("Amplitude error(dB)");
subplot(212);
Tx1=iirT(wt,x1,U,V,M,Q,R);
plot(wt*0.5/pi,[Tx1 Tdu Tdl]);
axis([0 0.5 tp-tpr tp+tpr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_error_x1"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close

% PCLS pass
printf("\nPCLS pass:\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
[N1,D1]=x2tf(d1,U,V,M,Q,R);

% Plot results
subplot(211);
[H,w]=freqz(N1,D1,n);
ni=floor(0.002*n/0.5);
semilogx(w(ni:end)*0.5/pi,20*log10(abs(H(ni:end))));
axis([0.001 0.6 -20 10]);
strt=sprintf(["Pink noise filter response : ", ...
 "fat=%g,AdBr=%g,ftt=%g,tp=%g,tpr=%g"],fat,AdBr,ftt,tp,tpr);
title(strt);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
T=delayz(N1,D1,n);
semilogx(w(ni:end)*0.5/pi,T(ni:end));
axis([0.001 0.6 0 30]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close

% Plot amplitude and group delay error
subplot(211);
Ad1=iirA(wa,d1,U,V,M,Q,R);
plot(wa*0.5/pi,20*log10([Ad1 Adu Adl])-20*log10([Ad Ad Ad]));
axis([0 0.5 -AdBr AdBr]);
grid("on");
title(strt);
ylabel("Amplitude error(dB)");
subplot(212);
Td1=iirT(wt,d1,U,V,M,Q,R);
plot(wt*0.5/pi,[Td1 Tdu Tdl]);
axis([0 0.5 tp-tpr tp+tpr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_error_d1"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

% Coefficients
print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
print_pole_zero(x1,U,V,M,Q,R,"x1");
print_pole_zero(x1,U,V,M,Q,R,"x1",strcat(strf,"_x1_coef.m"));
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fat=%g %% Amplitude transition band width\n",fat);
fprintf(fid,"AdBr=%g %% Relative amplitude peak-to-peak ripple (dB)\n",AdBr);
fprintf(fid,"Wap=%g %% Amplitude weight\n",Wap);
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

eval(sprintf(["save %s.mat U V M Q R x0 d1 ftol ctol n wd ", ...
 "fat Ad AdBr ftt tp Td tpr"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
