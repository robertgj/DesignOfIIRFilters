% iir_sqp_slb_pink_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("iir_sqp_slb_pink_test.diary");
unlink("iir_sqp_slb_pink_test.diary.tmp");
diary iir_sqp_slb_pink_test.diary.tmp

tic;


tol_mmse=2e-5
tol_pcls=2e-5
ctol=tol_pcls
maxiter=5000
verbose=false
strf="iir_sqp_slb_pink_test";

% Initial pink noise filter from tarczynski_pink_test.m
N0 = [   0.0255459662,   0.0269736316,   0.0295493475,   0.0314939183, ... 
         0.0596527509,   0.2240662308,   0.0174942232,  -0.0489009505, ... 
        -0.0647646959,  -0.0502065090,  -0.0245054024,   0.0357782540 ]';
D0 = [   1.0000000000,  -0.1243860183,  -0.2257053221,  -0.2517078756, ... 
        -0.1613690470,  -0.1035971313,   0.2070769160,  -0.0314625645, ... 
        -0.0009048289,  -0.0058396626,  -0.0018478509,  -0.0060197822 ]';

% Filter specifications
fat=0.005;
AdBr=0.2;
Wap=10;
ftt=0.025;
tp=4.77;
tpr=0.02;
Wtp=1;
[x0,U,V,M,Q]=tf2x(N0,D0);
R=1;

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
  semilogx(wa*0.5/pi,20*log10(A0),'linestyle','-', ...
           wa*0.5/pi,20*log10(Ad),'linestyle','-.');
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
  plot(wt*0.5/pi,T0,'linestyle','-', ...
       wt*0.5/pi,Td,'linestyle','-.');
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  grid("on");
  print(strcat(strf,"_init_x0"),"-dpdflatex");
  close
else
  subplot(111);
  A0=iirA(wa,x0,U,V,M,Q,R);
  semilogx(wa*0.5/pi,20*log10(A0),'linestyle','-', ...
           wa*0.5/pi,20*log10(Ad),'linestyle','-.');
  axis([0.003 0.6 -20 5]);
  strt=sprintf("Pink noise filter initial amplitude response : \
fat=%g,ftt=%g,tp=%g",fat,ftt,tp);
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
               maxiter,tol_mmse,verbose)
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
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
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
          maxiter,tol_pcls,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
subplot(211);
Ad1=iirA(wa,d1,U,V,M,Q,R);
plot(wa*0.5/pi,20*log10([Ad1 Adu Adl])-20*log10([Ad Ad Ad]));
axis([0 0.5 -AdBr AdBr]);
grid("on");
strt=sprintf("Pink noise filter PCLS response : \
fat=%g,AdBr=%g,ftt=%g,tp=%g,tpr=%g",fat,AdBr,ftt,tp,tpr);
title(strt);
ylabel("Amplitude error(dB)");
subplot(212);
Td1=iirT(wt,d1,U,V,M,Q,R);
plot(wt*0.5/pi,[Td1 Tdu Tdl]);
axis([0 0.5 tp-tpr tp+tpr]);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
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
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol_mmse=%g %% Tolerance on coef. update (MMSE pass)\n",tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on coef. update (PCLS pass)\n",tol_pcls);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fat=%g %% Amplitude transition band width\n",fat);
fprintf(fid,"AdBr=%g %% Relative amplitude peak-to-peak ripple (dB)\n",AdBr);
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
     U V M Q R x0 d1 tol_mmse tol_pcls ctol n wd fat Ad AdBr ftt tp Td tpr

toc;

diary off
movefile iir_sqp_slb_pink_test.diary.tmp iir_sqp_slb_pink_test.diary;
