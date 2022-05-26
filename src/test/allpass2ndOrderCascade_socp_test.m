% allpass2ndOrderCascade_socp_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

delete("allpass2ndOrderCascade_socp_test.diary");
delete("allpass2ndOrderCascade_socp_test.diary.tmp");
diary allpass2ndOrderCascade_socp_test.diary.tmp

tic;

verbose=false
tol=1e-6
maxiter=1000

% Lowpass filter specification for parallel all-pass filters
resp="complex"
ma=11;
mb=12;
td=(ma+mb)/2;
fp=0.15
Wp=2
fs=0.2
Ws=20
% Initial coefficients found by tarczynski_allpass2ndOrderCascade_test.m
tarczynski_allpass2ndOrderCascade_test_flat_delay_ab0_coef;
a0=ab0(1:ma);
b0=ab0((ma+1):end);

% Coefficient constraints
tau=0.001;

% Frequency vectors
n=1000;
w=pi*(0:(n-1))'/n;
np=ceil(fp*n/0.5)+1;
ns=floor(fs*n/0.5)+1;
Ad=[exp(-j*w(1:np)*td);zeros(n-np,1)];
W=[Wp*ones(np,1);zeros(ns-np-1,1);Ws*ones(n-ns+1,1)];

% Common strings
strf="allpass2ndOrderCascade_socp_test";

% Plot initial response
Da0=casc2tf(a0);
Da0=Da0(:);
Db0=casc2tf(b0);
Db0=Db0(:);
nplot=512;
[Ha0,wplot]=freqz(flipud(Da0),Da0,nplot);
Hb0=freqz(flipud(Db0),Db0,nplot);
Hab0=(Ha0+Hb0)/2;
Ha0p=allpass2ndOrderCascade(a0,wplot);
Hb0p=allpass2ndOrderCascade(b0,wplot);
Hab0p=(Ha0p+Hb0p)/2;
if max(abs(Hab0-Hab0p)) > 433*eps
  error("max(abs(Hab0-Hab0p)) > 433*eps");
endif
Ta0=grpdelay(flipud(Da0),Da0,nplot);
Tb0=grpdelay(flipud(Db0),Db0,nplot);
Tab0=(Ta0+Tb0)/2;
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf ...
    ("Parallel all-pass 2nd order cascade initial response : ma=%d,mb=%d",ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-1 td+1]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

% SOCP 
[a1,b1,socp_iter,func_iter,feasible]=allpass2ndOrderCascade_socp( ...
  a0,b0,tau,w,Ad,W,resp,maxiter,tol,verbose)
if !feasible
  error("a1,b1 infeasible");
endif

% Find transfer function
Da1=casc2tf(a1);
Da1=Da1(:);
Db1=casc2tf(b1);
Db1=Db1(:);
Dab1=conv(Da1,Db1);
Nab1=(conv(Da1,flipud(Db1))+conv(Db1,flipud(Da1)))/2;

% Find response
nplot=512;
[Ha1,wplot]=freqz(flipud(Da1),Da1,nplot);
Hb1=freqz(flipud(Db1),Db1,nplot);
Hab1=0.5*(Ha1+Hb1);
Ta1=grpdelay(flipud(Da1),Da1,nplot);
Tb1=grpdelay(flipud(Db1),Db1,nplot);
Tab1=0.5*(Ta1+Tb1);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Parallel all-pass 2nd order cascade : ma=%d,mb=%d",ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close
% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.2 -0.3 0.1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.2 td-1 td+1]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close
% Plot poles and zeros
subplot(111);
zplane(roots(Nab1),roots(Dab1));
title(strt);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%5.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ma=%d %% Order of filter A\n",ma);
fprintf(fid,"mb=%d %% Order of filter B\n",mb);
fprintf(fid,"tau=%3.1g %% Second order section stability parameter\n",tau);
fprintf(fid,"n=%d %% Number of frequency points\n",n);
fprintf(fid,"resp=%s %% Flat passband group delay or squared-magnitude\n",resp);
fprintf(fid,"fp=%5.3g %% Pass band edge\n",fp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"Wp=%d %% Pass band weight\n",Wp);
fprintf(fid,"fs=%5.3g %% Stop band edge\n",fs);
fprintf(fid,"Ws=%d %% Stop band weight\n",Ws);
fclose(fid);

% Save results
print_polynomial(a1,"a1");
print_polynomial(a1,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(b1,"b1");
print_polynomial(b1,"b1",strcat(strf,"_b1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));

save allpass2ndOrderCascade_socp_test.mat ...
     fp td Wp fs Ws ab0 a1 b1 Da1 Db1 Nab1 Dab1

% Done
toc;
diary off
movefile allpass2ndOrderCascade_socp_test.diary.tmp ...
         allpass2ndOrderCascade_socp_test.diary;
