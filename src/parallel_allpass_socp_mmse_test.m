% parallel_allpass_socp_mmse_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
test_common;

unlink("parallel_allpass_socp_mmse_test.diary");
unlink("parallel_allpass_socp_mmse_test.diary.tmp");
diary parallel_allpass_socp_mmse_test.diary.tmp

format compact

verbose=false
tol=1e-8
maxiter=2000
strf="parallel_allpass_socp_mmse_test";

% Initial coefficients found by tarczynski_parallel_allpass_test.m
Da0 = [   1.0000000000,   0.6972798665,  -0.2975063336,  -0.3126562447, ... 
         -0.1822052424,   0.0540552781,   0.0875338385,  -0.1043232331, ... 
          0.1845967625,   0.0440769201,  -0.1321004303,   0.0451935651 ]';
Db0 = [   1.0000000000,   0.1561448902,  -0.3135750868,   0.3178486046, ... 
          0.1300071229,   0.0784801583,  -0.0638101281,  -0.1841985576, ... 
          0.2692566953,  -0.0893426643,  -0.1362443194,   0.1339411607, ... 
         -0.0582212263 ]';

% Lowpass filter specification for parallel all-pass filters
polyphase=false
difference=false
Ra=1
Rb=1
ma=length(Da0)-1
mb=length(Db0)-1
fap=0.15
Wap=1
ftp=0.175
Wtp=5
td=(ma+mb)/2
tdr=0.04
fas=0.2
Was=1000
fpp=0.17
pd=0;
pdr=0.0008;
Wpp=1

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

% Desired pass-band phase response
npp=ceil(n*fpp/0.5)+1;
wp=(0:(npp-1))'*pi/n;
Pd=(pd*pi)-(td*wp);
Pdu=[];
Pdl=[];
Wp=Wpp*ones(npp,1);

% Linear constraints
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];
vS=[];

% SOCP
[ab1,socp_iter,func_iter,feasible]= ...
  parallel_allpass_socp_mmse(vS,ab0,abu,abl,Va,Qa,Ra,Vb,Qb,Rb, ...
                             polyphase,difference, ...
                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                             wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
if !feasible
  error("ab1 infeasible");
endif

% Find response
Asq1=parallel_allpassAsq(wa,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T1=parallel_allpassT(wt,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P1=parallel_allpassP(wp,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);

% Plot response
subplot(211);
plot(wa*0.5/pi,10*log10(Asq1));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel allpass : ma=%d,mb=%d,td=%g", ma,mb,td);
title(s);
subplot(212);
plot(wt*0.5/pi,T1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(311);
plot(wa*0.5/pi,10*log10(Asq1));
ylabel("Amplitude(dB)");
axis([0 max([fap,ftp,fpp]) -3 1]);
grid("on");
title(s);
subplot(312);
plot(wt*0.5/pi,T1);
ylabel("Group delay(samples)");
axis([0 max([fap,ftp,fpp]) td-(tdr/2) td+(tdr/2)]);
grid("on");
subplot(313);
plot(wp*0.5/pi,(P1+(wp*td)-pd)/pi);
ylabel("Phase(rad./pi)");
xlabel("Frequency");
axis([0 max([fap,ftp,fpp]) pd-(pdr/2) pd+(pdr/2)]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
[Na1,Da1]=a2tf(ab1(1:ma),Va,Qa,Ra);
[Nb1,Db1]=a2tf(ab1((ma+1):end),Vb,Qb,Rb);
Nab1=0.5*(conv(Na1,Db1)+conv(Nb1,Da1));
Dab1=conv(Da1,Db1);
subplot(111);
zplane(roots(Nab1),roots(Dab1));
title(s);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Na1),roots(Da1));
title(s);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Nb1),roots(Db1));
title(s);
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% Plot phase response of parallel filters
H1=freqz(Na1,Da1,wa);
Asq=freqz(Nb1,Db1,wa);
plot(wa*0.5/pi,[unwrap(arg(H1)) unwrap(arg(Asq))]+(wa*td));
s=sprintf(...
"Allpass phase response error from linear phase (-w*td): ma=%d,mb=%d,td=%g",...
ma,mb,td);
title(s);
ylabel("Linear phase error(rad.)");
xlabel("Frequency");
legend("A","B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
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
fprintf(fid,"fpp=%g %% Pass band phase response edge\n",fpp);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fprintf(fid,"pd=%g %% Pass band initial phase\n",pd);
fclose(fid);

% Save results
a1=ab1(1:ma);
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
b1=ab1((ma+1):end);
print_allpass_pole(b1,Vb,Qb,Rb,"b1");
print_allpass_pole(b1,Vb,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"));
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

% Done 
save parallel_allpass_socp_mmse_test.mat ...
     ma mb Ra Rb ab0 ab1 ...
     n fap Wap ftp Wtp fas Was td fpp pd pdr Wpp ...
     Na1 Da1 Nb1 Db1

diary off
movefile parallel_allpass_socp_mmse_test.diary.tmp ...
         parallel_allpass_socp_mmse_test.diary;
