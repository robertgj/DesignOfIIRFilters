% parallel_allpass_delay_sqp_slb_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="parallel_allpass_delay_sqp_slb_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000

% Lowpass filter specification for parallel all-pass filters
ftol=1e-5
ctol=1e-7
n=1000;
R=1
DD=11
m=12
fap=0.15
dBap=0.04
Wap=1
fas=0.2
dBas=40
Was=50

% Initial coefficients found by tarczynski_parallel_allpass_delay_test.m
% with tarczynski_parallel_allpass_delay_flat_delay=false
tarczynski_parallel_allpass_delay_test_Da0_coef;

% Coefficient constraints
rho=0.99
dmax=0.005

% Convert coefficients to a vector
[a0,V,Q]=tf2a(Da0);
printf("Initial a0=[");printf("%g ",a0');printf("]'\n");

% Frequency vectors

% Desired squared magnitude response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Linear constraints
[al,au]=aConstraints(V,Q,rho);
vS=[];

% Find initial response
nplot=n;
Na0=0.5*(conv([zeros((DD),1);1],Da0(:))+[flipud(Da0(:));zeros((DD),1)]);
[Ha0,wplot]=freqz(Na0,Da0,nplot);
Ta0=delayz(Na0,Da0,nplot);

% Plot initial response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Initial parallel allpass and delay : m=%d,DD=%d", m,DD);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta0);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a0"),"-dpdflatex");
close
% Plot initial filter poles and zeros
subplot(111);
zplane(roots(Na0),roots(Da0));
title(strt);
print(strcat(strf,"_a0pz"),"-dpdflatex");
close

%
% PCLS pass
%
[a1,slb_iter,opt_iter,func_iter,feasible]= ...
  parallel_allpass_delay_slb(@parallel_allpass_delay_sqp_mmse, ...
                             a0,au,al,dmax,V,Q,R,DD, ...
                             wa,Asqd,Asqdu,Asqdl,Wa,[],[],[],[],[], ...
                             maxiter,ftol,ctol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find response
[Na1,Da1]=a2tf(a1,V,Q,R);
nplot=n;
Na1=0.5*(conv([zeros((DD),1);1],Da1(:))+[flipud(Da1(:));zeros((DD),1)]);
[Ha1,wplot]=freqz(Na1,Da1,nplot);
Ta1=delayz(Na1,Da1,nplot);
strt=sprintf("Parallel allpass and delay : m=%d,DD=%d,dBap=%4.2f,dBas=%4.1f", ...
             m,DD,dBap,dBas);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1"),"-dpdflatex");
close
% Plot response on separate axes
ax=plotyy(wplot(1:nap)*0.5/pi,20*log10(abs(Ha1(1:nap))),...
          wplot(nas:n)*0.5/pi,20*log10(abs(Ha1(nas:n))));
axis(ax(1),[0 0.5 -0.04 0.01]);
axis(ax(2),[0 0.5 -45 -40]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_a1dual"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 fap -0.1 0.1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 fap DD-1 DD+1]);
grid("on");
print(strcat(strf,"_a1pass"),"-dpdflatex");
close

% Plot phase response of filter
[Ha1ap,wplot]=freqz(flipud(Da1),Da1,nplot);
plot(wplot*0.5/pi,(unwrap(arg(Ha1ap))+(wplot*DD))/pi);
s=sprintf("All-pass phase response adjusted for delay DD=%d",DD);
title(s);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1phase"),"-dpdflatex");
close

% Plot filter poles and zeros
subplot(111);
zplane(roots(Na1),roots(Da1));
title(strt);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close

% PCLS amplitude and delay at local peaks
Asq=parallel_allpass_delayAsq(wa,a1,V,Q,R,DD);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=parallel_allpass_delayAsq(wAsqS,a1,V,Q,R,DD);
printf("a1:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("a1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m=%d %% Allpass filter denominator order\n",m);
fprintf(fid,"V=%d %% Allpass filter no. of real poles\n",V);
fprintf(fid,"Q=%d %% Allpass filter no. of complex poles\n",Q);
fprintf(fid,"R=%d %% Allpass filter decimation\n",R);
fprintf(fid,"DD=%d %% Parallel delay\n",DD);
fprintf(fid,"fap=%5.2f %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%5.2f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fas=%5.2f %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%5.2f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%g %% Stop band amplitude response weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fprintf(fid,"dmax=%f %% Constraint on coefficent step-size\n",dmax);
fclose(fid);

% Save results
print_allpass_pole(a1,V,Q,R,"a1");
print_allpass_pole(a1,V,Q,R,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));

eval(sprintf("save %s.mat dmax rho ftol ctol n fap dBap Wap fas dBas Was \
m DD R Da0 a1 Da1",strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
