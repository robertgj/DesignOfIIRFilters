% parallel_allpass_socp_slb_flat_delay_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("parallel_allpass_socp_slb_flat_delay_test.diary");
unlink("parallel_allpass_socp_slb_flat_delay_test.diary.tmp");
diary parallel_allpass_socp_slb_flat_delay_test.diary.tmp

tic;

format compact
verbose=false
maxiter=2000
strf="parallel_allpass_socp_slb_flat_delay_test";

% Initial coefficients found by tarczynski_parallel_allpass_test.m
Da0 = [   1.0000000000,   0.6972798665,  -0.2975063336,  -0.3126562447, ... 
         -0.1822052424,   0.0540552781,   0.0875338385,  -0.1043232331, ... 
          0.1845967625,   0.0440769201,  -0.1321004303,   0.0451935651 ]';
Db0 = [   1.0000000000,   0.1561448902,  -0.3135750868,   0.3178486046, ... 
          0.1300071229,   0.0784801583,  -0.0638101281,  -0.1841985576, ... 
          0.2692566953,  -0.0893426643,  -0.1362443194,   0.1339411607, ... 
         -0.0582212263 ]';

% Lowpass filter specification for parallel all-pass filters
tol=1e-4
ctol=tol/10
n=1000;
polyphase=false
difference=false
rho=127/128
Ra=1
Rb=1
ma=length(Da0)-1
mb=length(Db0)-1
fap=0.15
dBap=3
Wap=1
ftp=0.175
td=(ma+mb)/2
tdr=0.08
Wtp=1
fas=0.2
dBas=40
Was=1000

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
ntp=ceil(n*ftp/0.5)+1;
wt=wa(1:ntp);
Td=td*ones(ntp,1);
Tdu=Td+(tdr*ones(ntp,1)/2);
Tdl=Td-(tdr*ones(ntp,1)/2);
Wt=Wtp*ones(ntp,1);

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

% Plot initial response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -100 5]);
grid("on");
strt=sprintf("Initial parallel allpass : ma=%d,mb=%d", ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close
% Plot initial poles and zeros
subplot(111);
zplane(roots(Nab0),roots(Dab0));
title(strt);
print(strcat(strf,"_ab0pz"),"-dpdflatex");
close

%
% PCLS pass
%
[ab1,slb_iter,opt_iter,func_iter,feasible]= ...
parallel_allpass_slb(@parallel_allpass_socp_mmse,ab0,abu,abl, ...
                     Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
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
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("Parallel allpass : ma=%d,mb=%d,dBap=%4.2f,dBas=%4.1f,td=%g,tdr=%g",
             ma,mb,dBap,dBas,td,tdr);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
%axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) td-0.1 td+0.1]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(Nab1),roots(Dab1));
title(strt);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Na1),roots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
subplot(111);
zplane(roots(Nb1),roots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% Plot phase response of parallel filters
Ha=freqz(Na1,Da1,nplot);
Hb=freqz(Nb1,Db1,nplot);
plot(wplot*0.5/pi,unwrap(arg(Ha))+(wplot*td), ...
     wplot*0.5/pi,unwrap(arg(Hb))+(wplot*td));
strt=sprintf("Allpass phase response error from linear phase (-w*td): \
ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
ylabel("Linear phase error(rad.)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,".spec"),"wt");
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
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band nominal group delay ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
a1=[1;ab1(1:ma)];
print_pole_zero(a1,0,Va,0,Qa,Ra,"a1");
print_pole_zero(a1,0,Va,0,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
b1=[1;ab1((ma+1):end)];
print_pole_zero(b1,0,Vb,0,Qb,Rb,"b1");
print_pole_zero(b1,0,Vb,0,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

% Done 
save parallel_allpass_socp_slb_flat_delay_test.mat ...
     n fap Wap ftp Wtp fas Was td tdr ma mb Ra Rb ab0 ab1 Da1 Db1
toc;
diary off
movefile parallel_allpass_socp_slb_flat_delay_test.diary.tmp ...
         parallel_allpass_socp_slb_flat_delay_test.diary;
