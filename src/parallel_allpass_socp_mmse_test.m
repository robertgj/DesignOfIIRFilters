% parallel_allpass_socp_mmse_test.m
% Copyright (C) 2017 Robert G. Jenssen
test_common;

unlink("parallel_allpass_socp_mmse_test.diary");
unlink("parallel_allpass_socp_mmse_test.diary.tmp");
diary parallel_allpass_socp_mmse_test.diary.tmp

format compact

verbose=false
tol=1e-8
maxiter=2000

% Initial coefficients found by tarczynski_parallel_allpass_test.m
Da0 = [   1.0000000000,   0.6972799348,  -0.2975063113,  -0.3126563765, ... 
         -0.1822053263,   0.0540552916,   0.0875338489,  -0.1043232804, ... 
          0.1845967341,   0.0440769557,  -0.1321004328,   0.0451935427 ]';
Db0 = [   1.0000000000,   0.1561449789,  -0.3135750674,   0.3178485356, ... 
          0.1300072034,   0.0784802475,  -0.0638101246,  -0.1841985892, ... 
          0.2692567260,  -0.0893425985,  -0.1362443439,   0.1339411525, ... 
         -0.0582212026 ]';

% Lowpass filter specification for parallel all-pass filters
polyphase=false
Ra=1
Rb=1
ma=length(Da0)-1
mb=length(Db0)-1
fap=0.15
Wap=1
ftp=0.175
Wtp=5
td=(ma+mb)/2
fas=0.2
Was=1000

% Coefficient constraints
rho=31/32;

% Convert coefficients to a vector
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

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
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];
vS=[];

% SOCP
[ab1,socp_iter,func_iter,feasible]= ...
  parallel_allpass_socp_mmse(vS,ab0,abu,abl,Va,Qa,Ra,Vb,Qb,Rb,polyphase, ...
                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                             maxiter,tol,verbose);
if !feasible
  error("ab1 infeasible");
endif

% Find overall filter polynomials
[Na1,Da1]=a2tf(ab1(1:ma),Va,Qa,Ra);
[Nb1,Db1]=a2tf(ab1((ma+1):end),Vb,Qb,Rb);
Nab1=0.5*(conv(Na1,Db1)+conv(Nb1,Da1));
Dab1=conv(Da1,Db1);

% Find response
nplot=512;
[Hab1,wplot]=freqz(Nab1,Dab1,nplot);
Tab1=grpdelay(Nab1,Dab1,nplot);

% Plot response
strd=sprintf("parallel_allpass_socp_mmse_%%s");
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel allpass : ma=%d,mb=%d,td=%g", ma,mb,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(sprintf(strd,"ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -3 1]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) td-0.1 td+0.1]);
grid("on");
print(sprintf(strd,"ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(Nab1),roots(Dab1));
title(s);
print(sprintf(strd,"ab1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Na1),roots(Da1));
title(s);
print(sprintf(strd,"a1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Nb1),roots(Db1));
title(s);
print(sprintf(strd,"b1pz"),"-dpdflatex");
close

% Plot phase response of parallel filters
H1=freqz(Na1,Da1,nplot);
Asq=freqz(Nb1,Db1,nplot);
plot(wplot*0.5/pi,[unwrap(arg(H1)) unwrap(arg(Asq))]+(wplot*td));
s=sprintf(...
"Allpass phase response error from linear phase (-w*td): ma=%d,mb=%d,td=%g",...
ma,mb,td);
title(s);
ylabel("Linear phase error(rad.)");
xlabel("Frequency");
legend("A","B","location","northwest");
legend("boxoff");
grid("on");
print(sprintf(strd,"ab1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen("parallel_allpass_socp_mmse_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
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
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1","parallel_allpass_socp_mmse_test_Da1_coef.m");
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1","parallel_allpass_socp_mmse_test_Db1_coef.m");
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1","parallel_allpass_socp_mmse_test_Nab1_coef.m");
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1","parallel_allpass_socp_mmse_test_Dab1_coef.m");

% Done 
save parallel_allpass_socp_mmse_test.mat ...
     n fap Wap ftp Wtp fas Was td ma mb Ra Rb ab0 ab1 Na1 Da1 Nb1 Db1

diary off
movefile parallel_allpass_socp_mmse_test.diary.tmp parallel_allpass_socp_mmse_test.diary;
