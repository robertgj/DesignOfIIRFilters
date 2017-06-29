% parallel_allpass_delay_socp_mmse_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("parallel_allpass_delay_socp_mmse_test.diary");
unlink("parallel_allpass_delay_socp_mmse_test.diary.tmp");
diary parallel_allpass_delay_socp_mmse_test.diary.tmp

format compact

verbose=true
tol=1e-8
maxiter=2000

% Lowpass filter specification for parallel all-pass filters
R=1
D=11
m=12
fap=0.15
Wap=0
ftp=0.16
td=10.8;
Wtp=1
fas=0.2
Was=2000

% Coefficient constraints
rho=127/128;

% Initial coefficients found by tarczynski_parallel_allpass_delay_test.m
Da0 = [   1.0000000000,  -0.1379461634,   0.6508711770,   0.3435787722, ... 
          0.0871260589,  -0.0354868180,  -0.0404097040,  -0.0013520894, ... 
          0.0198918909,   0.0102233345,  -0.0088825402,  -0.0168505648, ... 
         -0.0040338574 ]';

% Convert coefficients to a vector
[a0,V,Q]=tf2a(Da0);
printf("Initial a0=[");printf("%g ",a0');printf("]'\n");

% Frequency vectors
n=1000;

% Desired squared magnitude response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)-1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[];
Asqdl=[];
Wa=[Wap*ones(nap,1);zeros(nas-nap,1);Was*ones(n-nas,1)];

% Desired pass-band group delay response
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=[];
Tdl=[];
Wt=Wtp*ones(ntp,1);

% Linear constraints
[al,au]=aConstraints(V,Q,rho);
vS=[];

% SOCP
[a1,socp_iter,func_iter,feasible]= ...
  parallel_allpass_delay_socp_mmse(vS,a0,au,al,inf,V,Q,R,D, ...
                                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                   maxiter,tol,inf,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find filter polynomials
[Na1,Da1]=a2tf(a1,V,Q,R);

% Find response
nplot=512;
[Ha1,wplot]=freqz(Na1,Da1,nplot);
Ta1=grpdelay(Na1,Da1,nplot);
Ha1=(Ha1+exp(-j*wplot*D))/2;
Ta1=(Ta1+D)/2;

% Plot response
strd=sprintf("parallel_allpass_delay_socp_mmse_%%s");
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel allpass : m=%d,D=%d,td=%g", m,D,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"a1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -1 1]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) td-1 td+1]);
grid("on");
print(sprintf(strd,"a1pass"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(Na1),roots(Da1));
title(s);
print(sprintf(strd,"a1pz"),"-dpdflatex");
close

% Plot phase response of filter
Ha1=freqz(Na1,Da1,nplot);
plot(wplot*0.5/pi,unwrap(arg(Ha1))+(wplot*td));
s=sprintf(...
"Allpass phase response error from linear phase (-w*td): m=%d,D=%d,td=%g",...
m,D,td);
title(s);
ylabel("Linear phase error(rad.)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"a1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen("parallel_allpass_delay_socp_mmse_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m=%d %% Allpass model filter denominator order\n",m);
fprintf(fid,"V=%d %% Allpass model filter no. of real poles\n",V);
fprintf(fid,"Q=%d %% Allpass model filter no. of complex poles\n",Q);
fprintf(fid,"R=%d %% Allpass model filter decimation\n",R);
fprintf(fid,"D=%d %% Parallel delay\n",D);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1","parallel_allpass_delay_socp_mmse_test_Da1_coef.m");

% Done 
save parallel_allpass_delay_socp_mmse_test.mat  ...
     n fap Wap ftp Wtp fas Was td m R D a0 a1 Da1

diary off
movefile parallel_allpass_delay_socp_mmse_test.diary.tmp parallel_allpass_delay_socp_mmse_test.diary;
