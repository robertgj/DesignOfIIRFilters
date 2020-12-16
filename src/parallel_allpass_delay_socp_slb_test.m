% parallel_allpass_delay_socp_slb_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("parallel_allpass_delay_socp_slb_test.diary");
delete("parallel_allpass_delay_socp_slb_test.diary.tmp");
diary parallel_allpass_delay_socp_slb_test.diary.tmp

tic;

verbose=false
maxiter=2000
strf="parallel_allpass_delay_socp_slb_test";

parallel_allpass_delay_flat_delay=false

% Lowpass filter specification for parallel all-pass filters
tol=1e-5
ctol=1e-8
n=1000;
R=1
DD=11
m=12
fap=0.15
dBap=0.5
Wap=1
ftp=0.15
td=10.7
tdr=1
fas=0.2
Was=100000

% Initial coefficients found by tarczynski_parallel_allpass_delay_test.m
if parallel_allpass_delay_flat_delay
  Wtp=10
  dBas=43
  Da0 = [  1.0000000000,  -0.1379461810,   0.6508711210,   0.3435786241, ... 
           0.0871260134,  -0.0354868923,  -0.0404095573,  -0.0013519392, ... 
           0.0198920703,   0.0102236269,  -0.0088821745,  -0.0168506164, ... 
          -0.0040333833 ]';
else
  Wtp=0
  dBas=66
  Da0 = [  1.0000000000,  -0.5293611377,   0.3581368348,   0.1868795745, ... 
           0.0310949260,  -0.0570094736,  -0.0702446896,  -0.0383080635, ... 
          -0.0002494299,   0.0199925321,   0.0203357943,   0.0113714592, ... 
           0.0034482822 ]';
endif

% Coefficient constraints
rho=127/128

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
ylabel("Delay(samples)");
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
  parallel_allpass_delay_slb(@parallel_allpass_delay_socp_mmse, ...
                             a0,au,al,inf,V,Q,R,DD, ...
                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                             maxiter,tol,ctol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find response
[Na1,Da1]=a2tf(a1,V,Q,R);
nplot=n;
[Ha1,wplot]=freqz(flipud(Da1),Da1,nplot);
Ta1=grpdelay(flipud(Da1),Da1,nplot);
Ha1=(Ha1+exp(-j*wplot*DD))/2;
Ta1=(Ta1+DD)/2;
strt=sprintf("Parallel allpass and delay : m=%d,DD=%d,dBap=%4.2f,dBas=%4.1f", ...
             m,DD,dBap,dBas);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
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
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.6 0.1]);
axis(ax(2),[0 0.5 -70 -63]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_a1dual"),"-dpdflatex");
close

% Plot allpass filter poles and zeros
subplot(111);
zplane(roots(flipud(Da1)),roots(Da1));
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
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
if parallel_allpass_delay_flat_delay
  fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
  fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
  fprintf(fid,"tdr=%g %% Pass band nominal group delay ripple\n",tdr);
  fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
endif
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_allpass_pole(a1,V,Q,R,"a1");
print_allpass_pole(a1,V,Q,R,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));

% Done 
save parallel_allpass_delay_socp_slb_test.mat ...
     rho tol ctol n fap Wap ftp Wtp fas Was td tdr m DD R Da0 a1 Da1
toc;
diary off
movefile parallel_allpass_delay_socp_slb_test.diary.tmp ...
         parallel_allpass_delay_socp_slb_test.diary;
