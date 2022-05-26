% allpass2ndOrderCascadeDelay_socp_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

test_common;

delete("allpass2ndOrderCascadeDelay_socp_test.diary");
delete("allpass2ndOrderCascadeDelay_socp_test.diary.tmp");
diary allpass2ndOrderCascadeDelay_socp_test.diary.tmp

tic;


verbose=false
tol=1e-6
maxiter=2000

% Initial coefficients found by tarczynski_allpass_phase_shift_test.m
tarczynski_allpass_phase_shift_test_Da0_coef;
a0=tf2casc(Da0);

% Lowpass filter specification for parallel all-pass filter and delay
ma=length(a0)
D=10
td=D
fap=0.15
Wap=1
fas=0.2
Was=10
Was_sqm=200

% Coefficient constraints
tau=0.05;

% Frequency vectors
n=500;
% Desired complex frequency response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:n-1)'*pi/n;
Ad=[exp(-j*wa(1:nap)*td);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Wa_sqm=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_sqm*ones(n-nas+1,1)];

% Common strings
strf="allpass2ndOrderCascadeDelay_socp_test";

% Plot initial response
nplot=512;
[Ha0,wplot]=freqz(flipud(Da0(:)),Da0(:),nplot);
Ha0p=allpass2ndOrderCascade(a0,wplot);
Hab0=(Ha0+exp(-j*wplot*D))/2;
Ta0=grpdelay(flipud(Da0(:)),Da0(:),nplot);
Tab0=(Ta0+D)/2;
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf ...
("Parallel delay and 2nd order all-pass initial response : ma=%d,D=%d,td=%g",
 ma,D,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-1 td+1]);
grid("on");
print(strcat(strf,"_a0"),"-dpdflatex");
close
% Plot phase response
subplot(111);
plot(wplot*0.5/pi,rem(unwrap(arg(Ha0))+(wplot*D),2*pi));
s=sprintf("Initial 2nd order all-pass phase adjusted for delay D=%g",D);
title(s);
ylabel("Phase(rad.)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a0phase"),"-dpdflatex");
close

% SOCP, optimise delay response
[a1,socp_iter,func_iter,feasible]=allpass2ndOrderCascadeDelay_socp ...
   (a0,D,tau,wa,Ad,Wa,"complex",maxiter,tol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find transfer function
Da1=casc2tf(a1);
Da1=Da1(:);
Nab1=([flipud(Da1);zeros(D,1)] + [zeros(D,1);Da1])/2;

% Find response
nplot=512;
[Hab1,wplot]=freqz(Nab1,Da1,nplot);
Tab1=grpdelay(Nab1,Da1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel delay and 2nd order all-pass : ma=%d,D=%d,td=%g",
          ma,D,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 25]);
grid("on");
print(strcat(strf,"_a1"),"-dpdflatex");
close
% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 fap -0.2 0.2]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 fap td-2 td+2]);
grid("on");
print(strcat(strf,"_a1pass"),"-dpdflatex");
close
% Plot poles and zeros
subplot(111);
zplane(roots(Nab1),roots(Da1));
title(s);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close

% SOCP, optimise squared-magnitude response
[a1sqm,socp_iter,func_iter,feasible]=allpass2ndOrderCascadeDelay_socp ...
   (a0,D,tau,wa,Ad,Wa_sqm,"sqmag",maxiter,tol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find transfer function
Da1sqm=casc2tf(a1sqm);
Da1sqm=Da1sqm(:);
Nab1sqm=([flipud(Da1sqm);zeros(D,1)] + [zeros(D,1);Da1sqm])/2;

% Find response
nplot=512;
[Hab1sqm,wplot]=freqz(Nab1sqm,Da1sqm,nplot);
Tab1sqm=grpdelay(Nab1sqm,Da1sqm,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1sqm)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel delay and 2nd order all-pass squared-magnitude: ma=%d,D=%d",
          ma,D);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1sqm);
axis([0 0.5 0 25]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1sqm"),"-dpdflatex");
close
% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1sqm)));
ylabel("Amplitude(dB)");
axis([0 fap -1 0.5]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1sqm);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 fap 0 25]);
grid("on");
print(strcat(strf,"_a1sqmpass"),"-dpdflatex");
close
% Plot poles and zeros
subplot(111);
zplane(roots(Nab1sqm),roots(Da1sqm));
title(s);
print(strcat(strf,"_a1sqmpz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Number of frequency points\n",n);
fprintf(fid,"tol=%5.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"tau=%3.1g %% Second order section stability parameter\n",tau);
fprintf(fid,"ma=%d %% Order of allpass filter\n",ma);
fprintf(fid,"D=%d %% Parallel delay in samples\n",D);
fprintf(fid,"td=%d %% Nominal filter group delay in samples\n",td);
fprintf(fid,"fap=%5.3g %% Pass band edge\n",fap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"fas=%5.3g %% Stop band edge\n",fas);
fprintf(fid,"Was=%d %% Stop band weight (complex response)\n",Was);
fprintf(fid,"Was_sqm=%d %% Stop band weight (squared-magnitude)\n",Was_sqm);
fclose(fid);

% Save results
print_polynomial(a1,"a1");
print_polynomial(a1,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(a1sqm,"a1sqm");
print_polynomial(a1sqm,"a1sqm",strcat(strf,"_a1sqm_coef.m"));
print_polynomial(Da1sqm,"Da1sqm");
print_polynomial(Da1sqm,"Da1sqm",strcat(strf,"_Da1sqm_coef.m"));

save allpass2ndOrderCascadeDelay_socp_test.mat ...
     fap Wap fas Was Was_sqm td D Da0 a0 a1 Da1 a1sqm Da1sqm

% Done
toc;
diary off
movefile allpass2ndOrderCascadeDelay_socp_test.diary.tmp ...
         allpass2ndOrderCascadeDelay_socp_test.diary;
