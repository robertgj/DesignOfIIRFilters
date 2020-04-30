% parallel_allpass_delay_sqp_slb_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("parallel_allpass_delay_sqp_slb_test.diary");
delete("parallel_allpass_delay_sqp_slb_test.diary.tmp");
diary parallel_allpass_delay_sqp_slb_test.diary.tmp

tic;

verbose=false
maxiter=2000
strf="parallel_allpass_delay_sqp_slb_test";

% Lowpass filter specification for parallel all-pass filters
tol=1e-5
ctol=1e-7
n=500;
R=1
DD=11
m=12
fap=0.15
dBap=0.04
Wap=1
fas=0.2
dBas=43
Was=50

% Initial coefficients found by tarczynski_parallel_allpass_delay_test.m
Da0 = [   1.0000000000,  -0.5220973842,   0.3616272734,   0.1867311869, ... 
          0.0318266239,  -0.0498503285,  -0.0543925688,  -0.0165336258, ... 
          0.0215871327,   0.0367003807,   0.0300048879,   0.0153328172, ... 
          0.0043648415 ]';

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
[Ha0,wplot]=freqz(flipud(Da0),Da0,nplot);
Ta0=grpdelay(flipud(Da0),Da0,nplot);
Ha0=(Ha0+exp(-j*wplot*DD))/2;
Ta0=(Ta0+DD)/2;

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
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a0"),"-dpdflatex");
close
% Plot initial allpass poles and zeros
subplot(111);
zplane(roots(flipud(Da0)),roots(Da0));
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
                             maxiter,tol,ctol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find response
[Na1,Da1]=a2tf(a1,V,Q,R);
nplot=n;
[Ha1,wplot]=freqz(flipud(Da1),Da1,nplot);
Ta1=grpdelay(flipud(Da1),Da1,nplot);
Ha1D=(Ha1+exp(-j*wplot*DD))/2;
Ta1D=(Ta1+DD)/2;
strt=sprintf("Parallel allpass and delay : m=%d,DD=%d,dBap=%4.2f,dBas=%4.1f", ...
             m,DD,dBap,dBas);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1D)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta1D);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1"),"-dpdflatex");
close
% Plot response on separate axes
ax=plotyy(wplot(1:nap)*0.5/pi,20*log10(abs(Ha1D(1:nap))),...
          wplot(nas:n)*0.5/pi,20*log10(abs(Ha1D(nas:n))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
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
plot(wplot*0.5/pi,20*log10(abs(Ha1D)));
ylabel("Amplitude(dB)");
axis([0 fap -0.1 0.1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta1D);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 fap DD-1 DD+1]);
grid("on");
print(strcat(strf,"_a1pass"),"-dpdflatex");
close

% Plot phase response of filter
plot(wplot*0.5/pi,unwrap(arg(Ha1))+(wplot*DD));
s=sprintf("All-pass phase response adjusted for delay DD=%d",DD);
title(s);
ylabel("Phase(rad.)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1phase"),"-dpdflatex");
close

% Plot allpass filter poles and zeros
subplot(111);
zplane(roots(flipud(Da1)),roots(Da1));
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
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m=%d %% Allpass filter denominator order\n",m);
fprintf(fid,"V=%d %% Allpass filter no. of real poles\n",V);
fprintf(fid,"Q=%d %% Allpass filter no. of complex poles\n",Q);
fprintf(fid,"R=%d %% Allpass filter decimation\n",R);
fprintf(fid,"DD=%d %% Parallel delay\n",DD);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fprintf(fid,"dmax=%f %% Constraint on coefficent step-size\n",dmax);
fclose(fid);

% Save results
print_allpass_pole(a1,V,Q,R,"a1");
print_allpass_pole(a1,V,Q,R,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));

% Done 
save parallel_allpass_delay_sqp_slb_test.mat ...
     dmax rho tol ctol n fap dBap Wap fas dBas Was m DD R Da0 a1 Da1
toc;
diary off
movefile parallel_allpass_delay_sqp_slb_test.diary.tmp ...
         parallel_allpass_delay_sqp_slb_test.diary;
