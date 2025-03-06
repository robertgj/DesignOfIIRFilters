% allpass2ndOrderCascade_socp_sqmag_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="allpass2ndOrderCascade_socp_sqmag_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;


verbose=false
tol=1e-8
maxiter=2000

% Lowpass filter specification for parallel all-pass filters
resp="sqmag"
ma=5;
mb=6;
td=(ma+mb)/2;
fp=0.15
Wp=1
fs=0.17
Ws=2000
  
% Initial coefficients found by tarczynski_allpass2ndOrderCascade_test.m
tarczynski_allpass2ndOrderCascade_test_ab0_coef;
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

% Plot initial response
Da0=casc2tf(a0);
Da0=Da0(:);
Db0=casc2tf(b0);
Db0=Db0(:);
nplot=4000;
[Ha0,wplot]=freqz(flipud(Da0),Da0,nplot);
Hb0=freqz(flipud(Db0),Db0,nplot);
Hab0=(Ha0+Hb0)/2;
Ha0p=allpass2ndOrderCascade(a0,wplot);
Hb0p=allpass2ndOrderCascade(b0,wplot);
Hab0p=(Ha0p+Hb0p)/2;
if max(abs(Hab0-Hab0p)) > 2000*eps
  error("max(abs(Hab0-Hab0p)) > 2000*eps");
endif
Ta0=delayz(flipud(Da0),Da0,nplot);
Tb0=delayz(flipud(Db0),Db0,nplot);
Tab0=(Ta0+Tb0)/2;
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf ...
("Parallel all-pass 2nd order cascade initial response (squared-magnitude) : \
ma=%d,mb=%d",ma,mb);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

% SOCP
try
  [a1,b1,socp_iter,func_iter,feasible] = ...
     allpass2ndOrderCascade_socp(a0,b0,tau,w,Ad,W,resp,maxiter,tol,verbose)
catch
  feasible = false;
end_try_catch
if ~feasible
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
nplot=2048;
[Ha1,wplot]=freqz(flipud(Da1),Da1,nplot);
Hb1=freqz(flipud(Db1),Db1,nplot);
Hab1=0.5*(Ha1+Hb1);
Ta1=delayz(flipud(Da1),Da1,nplot);
Tb1=delayz(flipud(Db1),Db1,nplot);
Tab1=0.5*(Ta1+Tb1);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -100 5]);
grid("on");
s=sprintf ...
("Parallel all-pass 2nd order cascade (squared-magnitude): ma=%d,mb=%d",ma,mb);
title(s);
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
axis([0 fp -0.1 0.1]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 fp]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close
% Plot poles and zeros
subplot(111);
zplane(qroots(Nab1),qroots(Dab1));
title(s);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close
% Dual plot
npp=ceil(fp*nplot/0.5)+1;
nsp=floor(fs*nplot/0.5)+1;
clf
subplot(211);
ax=plotyy(wplot(1:npp)*0.5/pi,20*log10(abs(Hab1(1:npp))), ...
          wplot(nsp:end)*0.5/pi,20*log10(abs(Hab1(nsp:end))));
axis(ax(1),[0 0.5 -0.1 0]);
axis(ax(2),[0 0.5 -90 -80]);
ylabel("Amplitude(dB)");
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1)
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1dual"),"-dpdflatex");
close

% Comparison with elliptic filter
fap=0.15;
fas=0.17;
dBap=0.02;
dBas=84;
[Nellip,Dellip]=ellip(ma+mb,dBap,dBas,fap*2);
Hellip=freqz(Nellip,Dellip,nplot);
Tellip=delayz(Nellip,Dellip,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hellip)));
ylabel("Pass-band amplitude(dB)");
axis([0 fap -dBap 0]);
grid("on");
st=sprintf("Order %d elliptic filter response : fap=%g,dBap=%g,fas=%g,dBas=%g",
           ma+mb,fap,dBap,fas,dBas);
title(st);
subplot(212);
plot(wplot*0.5/pi,20*log10(abs(Hellip)));
xlabel("Frequency");
ylabel("Stop-band amplitude(dB)");
axis([fas 0.5 -90 -80]);
grid("on");
print(strcat(strf,"_ellip"),"-dpdflatex");
close
% Dual plot
clf
subplot(111);
ax=plotyy(wplot(1:npp)*0.5/pi,20*log10(abs(Hellip(1:npp))), ...
          wplot(nsp:end)*0.5/pi,20*log10(abs(Hellip(nsp:end))));
axis(ax(1),[0 0.5 -0.025 0]);
axis(ax(2),[0 0.5 -84.06 -83.96]);
ylabel("Amplitude(dB)");
strt=sprintf("Order %d elliptic amplitude response plot : \
fap=%4.2f,dBap=%4.2f,fas=%4.2f,dBas=%2d",ma+mb,fap,dBap,fas,dBas);
title(strt);
grid("on");
print(strcat(strf,"_ellipdual"),"-dpdflatex");
close

% Pole zero plot
subplot(111);
zplane(qroots(Nellip),qroots(Dellip));
strt=sprintf("Order %d elliptic filter pole-zero plot : \
fap=%g,dBap=%g,fas=%g,dBas=%g",ma+mb,fap,dBap,fas,dBas);
print(strcat(strf,"_ellippz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%5.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ma=%d %% Order of filter A\n",ma);
fprintf(fid,"mb=%d %% Order of filter B\n",mb);
fprintf(fid,"tau=%3.1g %% Second order section stability parameter\n",tau);
fprintf(fid,"n=%d %% Number of frequency points\n",n);
fprintf(fid,"resp=\"%s\" %% Flat passband group delay or squared-magnitude\n",
            resp);
fprintf(fid,"fp=%5.3g %% Pass band edge\n",fp);
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
print_polynomial(Nellip,"Nellip");
print_polynomial(Nellip,"Nellip",strcat(strf,"_Nellip_coef.m"));
print_polynomial(Dellip,"Dellip");
print_polynomial(Dellip,"Dellip",strcat(strf,"_Dellip_coef.m"));

eval(sprintf("save %s.mat ...\n\
 fp Wp fs Ws dBap dBas ab0 a1 b1 Da1 Db1 Nab1 Dab1 Nellip Dellip",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
