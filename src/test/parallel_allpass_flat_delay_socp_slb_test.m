% parallel_allpass_flat_delay_socp_slb_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% Design an allpass filter in parallel with a delay with approximately flat
% passband delay response

test_common;

strf="parallel_allpass_flat_delay_socp_slb_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));
       
tic;

verbose=false
maxiter=2000

% Initial coefficients found by tarczynski_parallel_allpass_delay_test.m
% with tarczynski_parallel_allpass_delay_flat_delay=true
tarczynski_parallel_allpass_delay_test_flat_delay_Da0_coef;

% Lowpass filter specification for parallel all-pass filter and delay
tol=1e-4
ctol=1e-6
n=1000;
R=1
DD=11
m=12
fap=0.175
dBap=0.55
Wap=1
Wat=1
ftp=0.15
td=10.5
tdr=0.7
Wtp=1
fas=0.2
dBas=40
Was=100

% Coefficient constraints
rho=127/128

% Convert coefficients to a vector of poles
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
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Desired pass-band group delay response
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=Td+(tdr*ones(ntp,1)/2);
Tdl=Td-(tdr*ones(ntp,1)/2);
Wt=Wtp*ones(ntp,1);

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
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("Initial parallel allpass and delay : m=%d,DD=%d,td=%4.1f",m,DD,td);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 20]);
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
  parallel_allpass_delay_slb(@parallel_allpass_delay_socp_mmse, ...
                             a0,au,al,inf,V,Q,R,DD, ...
                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                             maxiter,tol,ctol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find response
[~,Da1]=a2tf(a1,V,Q,R);
Na1=0.5*(conv([zeros((DD),1);1],Da1(:))+[flipud(Da1(:));zeros((DD),1)]);
nplot=n;
[Ha1,wplot]=freqz(Na1,Da1,nplot);
Ta1=delayz(Na1,Da1,nplot);
strt=sprintf("Parallel allpass and delay : \
m=%d,DD=%d,dBap=%4.2f,td=%4.1f,dBas=%4.1f", m,DD,dBap,td,dBas);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ta1);
axis([0 0.5 0 20]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1"),"-dpdflatex");
close

% Plot response on separate axes
subplot(211);
ax=plotyy(wplot(1:nas)*0.5/pi,20*log10(abs(Ha1(1:nas))),...
          wplot(nas:n)*0.5/pi,20*log10(abs(Ha1(nas:n))));
axis(ax(1),[0 0.5 -0.6 0.2]);
axis(ax(2),[0 0.5 -50 -30]);
ylabel("Amplitude(dB)");
grid("on");
title(strt);
subplot(212);
plot(wplot(1:nap)*0.5/pi,Ta1(1:nap));
axis([0 0.5 10 11]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_a1dual"),"-dpdflatex");
close

% Plot allpass filter poles and zeros
subplot(111);
zplane(roots(Na1),roots(Da1));
title(strt);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close

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
fprintf(fid,"fap=%5.2f %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%5.2f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Wat=%d %% Transition band amplitude response weight\n",Wat);
fprintf(fid,"fas=%5.2f %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%5.2f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
fprintf(fid,"ftp=%5.2f %% Pass band group delay response edge\n",ftp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band nominal group delay ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"rho=%g %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_allpass_pole(a1,V,Q,R,"a1");
print_allpass_pole(a1,V,Q,R,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));

% Done 
eval(sprintf("save %s.mat ...\n\
     rho tol ctol n fap Wap Wat ftp Wtp fas Was td tdr m DD R Da0 a1 Da1",strf));

toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
