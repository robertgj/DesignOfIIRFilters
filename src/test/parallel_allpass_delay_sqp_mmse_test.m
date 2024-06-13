% parallel_allpass_delay_sqp_mmse_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="parallel_allpass_delay_sqp_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=true
ftol=1e-4
ctol=1e-8
maxiter=2000

% Lowpass filter specification for parallel all-pass filters
R=1
DD=11
m=12
fap=0.15
Wap=1
Wat=0
ftp=0.175
td=DD
Wtp=0
fas=0.2
Was=1

% Coefficient constraints
rho=127/128;
dmax=0.05

% Initial coefficients found by tarczynski_parallel_allpass_delay_test.m
Da0 = [   1.0000000000,  -0.5220966564,   0.3616274121,   0.1867305290, ... 
          0.0318254621,  -0.0498514036,  -0.0543930474,  -0.0165333545, ... 
          0.0215879166,   0.0367012865,   0.0300055775,   0.0153331903, ... 
          0.0043649745 ]';

% Convert coefficients to a vector
[a0,V,Q]=tf2a(Da0);
printf("Initial a0=[");printf("%g ",a0');printf("]'\n");

% Frequency vectors
n=1000;

% Desired squared magnitude response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[];
Asqdl=[];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap,1);Was*ones(n-nas,1)];

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

% SQP
[a1,sqp_iter,func_iter,feasible]= ...
  parallel_allpass_delay_sqp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...
                                  wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                  maxiter,ftol,ctol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find filter polynomials
[Na1,Da1]=a2tf(a1,V,Q,R);

% Find response
nplot=512;
[Ha1,wplot]=freqz(Na1,Da1,nplot);
Ta1=delayz(Na1,Da1,nplot);
Ha1=(Ha1+exp(-j*wplot*DD))/2;
Ta1=(Ta1+DD)/2;

% Plot response
strd=sprintf("%s_%%s",strf);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel allpass : m=%d,DD=%d", m,DD);
title(s);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"a1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 fap -3 1]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 fap 0 2*DD]);
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
[Ha1,wplot]=freqz(Na1,Da1,nplot);
plot(wplot*0.5/pi,(unwrap(arg(Ha1))+(wplot*DD))/pi);
s=sprintf(...
"Allpass phase response error from linear phase (-w*DD): m=%d,DD=%d",m,DD);
title(s);
ylabel("Linear phase error/pi");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"a1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m=%d %% Allpass model filter denominator order\n",m);
fprintf(fid,"V=%d %% Allpass model filter no. of real poles\n",V);
fprintf(fid,"Q=%d %% Allpass model filter no. of complex poles\n",Q);
fprintf(fid,"R=%d %% Allpass model filter decimation\n",R);
fprintf(fid,"DD=%d %% Parallel delay\n",DD);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"Wap=%g %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"Wtp=%g %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"Was=%g %% Stop band amplitude response weight\n",Was);
fprintf(fid,"rho=%g %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_allpass_pole(a1,V,Q,R,"a1");
print_allpass_pole(a1,V,Q,R,"a1",strcat(strf,"_a1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));

eval(sprintf("save %s.mat n fap Wap ftp Wtp fas Was td m R DD a0 a1 Da1 ",strf));

% Done 
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
