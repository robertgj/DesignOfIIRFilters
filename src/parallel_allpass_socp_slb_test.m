% parallel_allpass_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("parallel_allpass_socp_slb_test.diary");
unlink("parallel_allpass_socp_slb_test.diary.tmp");
diary parallel_allpass_socp_slb_test.diary.tmp

tic;

format compact
verbose=false
maxiter=2000

if 1
  % Initial coefficients found by tarczynski_parallel_allpass_test.m
  Da0 = [   1.0000000000,   0.0331304951,  -0.7339349053,   0.6814792581, ... 
            0.2853107764,  -0.3284984064 ]';
  Db0 = [   1.0000000000,  -0.5458089218,  -0.4196277845,   1.3137217521, ... 
           -0.2788635838,  -0.4153187918,   0.3450721543 ]';
  % Lowpass filter specification for parallel all-pass filters
  tol=1e-4
  ctol=7e-9
  n=1000;
  polyphase=false
  rho=0.999 
  Ra=1
  Rb=1
  ma=length(Da0)-1
  mb=length(Db0)-1
  fap=0.15
  dBap=0.05
  Wap=1
  ftp=0
  td=0
  tdr=0
  Wtp=0
  fas=0.17
  dBas=83
  Was=1000
else
  % Initial coefficients found by ellip and spectralfactor
  Da0 = [   1.000000000000000, -3.52653741783889,  6.37076364696818, ...
           -6.888440754452529,  4.70246190303224, -1.89603068554395, ...
            0.360607863409454 ]';
  Db0 = [   1.000000000000000, -2.95543063604004,  4.34596320868371, ...
           -3.603259582217770,  1.69528750483737, -0.35861660275546 ]';
  % Lowpass filter specification for parallel all-pass filters
  maxiter=1e5
  tol=1e-5
  ctol=1e-10
  n=1000;
  polyphase=false
  rho=0.999;
  Ra=1
  Rb=1
  ma=length(Da0)-1
  mb=length(Db0)-1
  fap=0.15
  dBap=0.02
  Wap=1
  ftp=0
  td=0
  tdr=0
  Wtp=0
  fas=0.17
  dBas=82.6
  Was=100
endif

% Convert coefficients to a vector
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

%
% Frequency vectors
%

% Desired squared magnitude response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:(n-1))'*pi/n;
A2d=[ones(nap,1);zeros(n-nap,1)];
A2du=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
A2dl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Desired pass-band group delay response
ntp=0;
wt=[];
Td=[];
Tdu=[];
Tdl=[];
Wt=[];

% Linear constraints
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Nab0=0.5*(conv(flipud(Da0),Db0)+conv(flipud(Db0),Da0));
Dab0=conv(Da0,Db0);
nplot=512;
[Hab0,wplot]=freqz(Nab0,Dab0,nplot);
Tab0=grpdelay(Nab0,Dab0,nplot);

% Common strings
strd=sprintf("parallel_allpass_socp_slb_%%s");

% Plot initial response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -100 5]);
grid("on");
strt=sprintf("Initial parallel allpass : ma=%d,mb=%d",ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"ab0"),"-dpdflatex");
close
% Plot initial poles and zeros
subplot(111);
zplane(roots(Nab0),roots(Dab0));
title(strt);
print(sprintf(strd,"ab0pz"),"-dpdflatex");
close

%
% PCLS pass
%
[ab1,slb_iter,opt_iter,func_iter,feasible]= ...
parallel_allpass_slb(@parallel_allpass_socp_mmse,ab0,abu,abl, ...
                     Va,Qa,Ra,Vb,Qb,Rb,polyphase, ...
                     wa,A2d,A2du,A2dl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                     maxiter,tol,ctol,verbose);
if !feasible
  error("ab1 infeasible");
endif

% Find overall filter polynomials
[Na1,Da1]=a2tf(ab1(1:ma),Va,Qa,Ra);
Da1=Da1(:);
[Nb1,Db1]=a2tf(ab1((ma+1):end),Vb,Qb,Rb);
Db1=Db1(:);
Nab1=(conv(flipud(Da1),Db1)+conv(flipud(Db1),Da1))/2;
Dab1=conv(Da1,Db1);

% Find response
nplot=512;
[Hab1,wplot]=freqz(Nab1,Dab1,nplot);
Tab1=grpdelay(Nab1,Dab1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -100 5]);
grid("on");
strt=sprintf("Parallel allpass : ma=%d,mb=%d,dBap=%4.2f,dBas=%4.1f",
             ma,mb,dBap,dBas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -2*dBap dBap]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) 0 50]);
grid("on");
print(sprintf(strd,"ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(Nab1),roots(Dab1));
title(strt);
print(sprintf(strd,"ab1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Na1),roots(Da1));
title("Allpass filter A");
print(sprintf(strd,"a1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Nb1),roots(Db1));
title("Allpass filter B");
print(sprintf(strd,"b1pz"),"-dpdflatex");
close

% Save the filter specification
fid=fopen("parallel_allpass_socp_slb_test.spec","wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ma=%d %% Allpass model filter A denominator order\n",ma);
fprintf(fid,"Va=%d %% Allpass model filter A no. of real poles\n",Va);
fprintf(fid,"Qa=%d %% Allpass model filter A no. of complex poles\n",Qa);
fprintf(fid,"Ra=%d %% Allpass model filter A decimation\n",Ra);
fprintf(fid,"mb=%d %% Allpass model filter B denominator order\n",mb);
fprintf(fid,"Vb=%d %% Allpass model filter B no. of real poles\n",Vb);
fprintf(fid,"Qb=%d %% Allpass model filter B no. of complex poles\n",Qb);
fprintf(fid,"Rb=%d %% Allpass model filter B decimation\n",Rb);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1","parallel_allpass_socp_slb_test_Da1_coef.m");
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1","parallel_allpass_socp_slb_test_Db1_coef.m");
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1","parallel_allpass_socp_slb_test_Nab1_coef.m");
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1","parallel_allpass_socp_slb_test_Dab1_coef.m");

% Done 
save parallel_allpass_socp_slb_test.mat ...
     n fap Wap fas Was ma mb Ra Rb ab0 ab1 Da1 Db1
toc;
diary off
movefile parallel_allpass_socp_slb_test.diary.tmp parallel_allpass_socp_slb_test.diary;
