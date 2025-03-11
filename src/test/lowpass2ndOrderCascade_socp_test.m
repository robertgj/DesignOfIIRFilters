% lowpass2ndOrderCascade_socp_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("lowpass2ndOrderCascade_socp_test.diary");
delete("lowpass2ndOrderCascade_socp_test.diary.tmp");
diary lowpass2ndOrderCascade_socp_test.diary.tmp

tic;


verbose=false
tol=1e-6
maxiter=2000
limit_cycle=false;

% Deczky example 3 filter specification
tau=0.1 % Stability parameter for second order sections
td=10 % Pass band group delay
fpass=0.15 % Pass band edge
Wpass=1 % Pass band weight
fstop=0.3 % Stop band edge
Wstop=100 % Stop band weight
dBstop=80 % Stop band attenuation

% Initial coefficients
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x0deczky=[K,abs(z),angle(z),abs(p),angle(p)]';
U=0;V=0;Q=6;M=10;R=1;
[x0.a,x0.d]=x2tf(x0deczky,U,V,M,Q,R);

% Frequency vectors
n=400;
npass=ceil(n*fpass/0.5)+1;
nstop=floor(n*fstop/0.5)+1;
w=(0:(n-1))'*pi/n;
Hd=[exp(-j*w(1:npass)*td);10^(-dBstop/20)*ones(n-npass,1)];
W=[Wpass*ones(npass,1);zeros(nstop-npass-1,1);Wstop*ones(n-nstop+1,1)];
% Check
w([npass,nstop])*0.5/pi
W([npass,npass+1,nstop-1,nstop])

% SOCP loop
[x1,socp_iter,feasible] = lowpass2ndOrderCascade_socp ...
  (x0,tau,w,Hd,W,npass,nstop,"complex",limit_cycle,maxiter,tol,verbose);
if feasible == 0 
  error("x1 infeasible");
endif

% Calculate response
nplot=512;
[h,wplot]=freqz(x1.a, x1.d, nplot);
t=delayz(x1.a, x1.d, nplot);

% Common strings for output plots
strf="lowpass2ndOrderCascade_socp_test";
strt=sprintf("Deczky ex.3,SOCP,td=%d,fpass=%g,fstop=%g,Wstop=%d,dBstop=%d", ...
             td,fpass,fstop,Wstop,dBstop);

% Plot overall response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(h)))
axis([0, 0.5, -80, 10]);
ylabel("Amplitude(dB)");
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,t)
axis([0, 0.5, 0, 20]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_x1"),"-dpdflatex");
close
% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(h)))
axis([0, fpass, -1, 1]);
ylabel("Amplitude(dB)");
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,t)
axis([0, fpass, td-0.25, td+0.25]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_x1pass"),"-dpdflatex");
close
% Plot poles and zeros
subplot(111);
zplane(qroots(x1.a),qroots(x1.d))
title(strt);
print(strcat(strf,"_x1pz"),"-dpdflatex");
close

% Alternative response for squared magnitude in both the pass and stop bands
[x1_sqm,socp_iter,feasible]=lowpass2ndOrderCascade_socp ...
  (x0,tau,w,Hd,W,npass,nstop,"sqmag",limit_cycle,maxiter,tol,verbose);
if feasible == 0 
  error("x1_sqm infeasible");
endif
% Find response
nplot=512;
h_sqm=freqz(x1_sqm.a, x1_sqm.d, nplot);
t_sqm=delayz(x1_sqm.a, x1_sqm.d, nplot);
% Plot response
sqm_strt= ...
sprintf("Deczky ex.3,SOCP Sq.Mag.,td=%d,fpass=%g,fstop=%g,Wstop=%d,dBstop=%d", ...
        td,fpass,fstop,Wstop,dBstop);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(h_sqm)))
axis([0, 0.5, -80, 10]);
ylabel("Amplitude(dB)");
grid("on");
title(sqm_strt);
subplot(212);
plot(wplot*0.5/pi,t_sqm)
axis([0, 0.5, 0, 20]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_x1sqm"),"-dpdflatex");
close
% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(h_sqm)))
axis([0, fpass, -0.01, 0.01]);
ylabel("Amplitude(dB)");
grid("on");
title(sqm_strt);
subplot(212);
plot(wplot*0.5/pi,t_sqm)
axis([0, fpass, td-1, td+1]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_x1sqmpass"),"-dpdflatex");
close
% Plot poles and zeros
subplot(111);
zplane(qroots(x1_sqm.a),qroots(x1_sqm.d))
title(sqm_strt);
print(strcat(strf,"_x1sqmpz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%5.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"mn=%d %% Numerator order (mn+1 coefficients)\n",length(x1.a)-1);
fprintf(fid,"mr=%d %% Denominator order (mr coefficients)\n",length(x1.d)-1);
fprintf(fid,"tau=%3.1g %% Second order section stability parameter\n",tau);
fprintf(fid,"n=%d %% Number of frequency points\n",n);
fprintf(fid,"td=%d %% Pass band group delay\n",td);
fprintf(fid,"fpass=%5.3g %% Pass band edge\n",fpass);
fprintf(fid,"Wpass=%d %% Pass band weight\n",Wpass);
fprintf(fid,"fstop=%5.3g %% Stop band edge\n",fstop);
fprintf(fid,"Wstop=%d %% Stop band weight\n",Wstop);
fprintf(fid,"dBstop=%d %% Stop band attenuation\n",dBstop);
fclose(fid);

% Show transfer function polynomials
print_polynomial(x1.a,"x1.a");
print_polynomial(x1.a,"a",strcat(strf,"_a_coef.m"));
print_polynomial(x1.d,"x1.d");
print_polynomial(x1.d,"d",strcat(strf,"_d_coef.m"));

% Done
toc;
diary off
movefile lowpass2ndOrderCascade_socp_test.diary.tmp ...
         lowpass2ndOrderCascade_socp_test.diary;
