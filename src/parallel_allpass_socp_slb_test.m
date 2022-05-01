% parallel_allpass_socp_slb_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

delete("parallel_allpass_socp_slb_test.diary");
delete("parallel_allpass_socp_slb_test.diary.tmp");
diary parallel_allpass_socp_slb_test.diary.tmp

tic;

verbose=true
maxiter=1000
strf="parallel_allpass_socp_slb_test";

% Initial filter from tarczynski_parallel_allpass_test.m with flat_delay=false
tarczynski_parallel_allpass_test_Da0_coef;
tarczynski_parallel_allpass_test_Db0_coef;

% Lowpass filter specification
tol=1e-4
ctol=1e-10
% The default SeDuMi eps is 1e-8 which is insufficient for this example.
% Pass separate tolerances for the coefficient step and SeDuMi eps.
del.dtol=tol;
del.stol=ctol;
warning("Using coef. delta tolerance=%g, SeDuMi eps=%g\n",del.dtol,del.stol);
n=2000;
polyphase=false
difference=false
rho=0.999
K=10
Ksq=K^2;
Ra=1
Rb=1
ma=length(Da0)-1
mb=length(Db0)-1
fape=0.14
fap=0.15
dBap=0.02
Wap=1
Wape=Wap/4 % Extra passband weight increasing linearly from fape to fap
ftp=0
td=0
tdr=0
Wtp=0
fas=0.171
fase=0.18
dBas=84.02
Was_mmse=1e4
Wase=Was_mmse/4 % Extra passband weight decreasing linearly from fas to fase
Was_pcls=1e-6 % Do not attempt to minimise MMSE squared error

% Convert coefficients to a vector
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

%
% Frequency vectors
%

% Desired squared magnitude response
nape=floor(n*fape/0.5)+1;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
nase=ceil(n*fase/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa_mmse=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_mmse*ones(n-nas+1,1)];
Wae=[zeros(nape,1); ...
     Wape*((1:(nap-nape))'/(nap-nape)); ...
     zeros(nas-nap-1,1)
     Wase*(((nase-nas):-1:1)'/(nase-nas)); ...
     zeros(n-nase+1,1)];
Wa_mmse=Wa_mmse+Wae;
Wa_pcls=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_pcls*ones(n-nas+1,1)];

% Sanity checks
nchka=[nape-1,nape,nape+1,nap-1,nap,nap+1,nas-1,nas,nas+1,nase-1,nase,nase+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa_mmse(nchka)=[ ");printf("%6.4g ",Wa_mmse(nchka)');printf("];\n");
printf("Wae(nchka)=[ ");printf("%6.4g ",Wae(nchka)');printf("];\n");
printf("Wa_pcls(nchka)=[ ");printf("%6.4g ",Wa_pcls(nchka)');printf("];\n");

% Desired pass-band group delay response
wt=[];
Td=[];
Tdu=[];
Tdl=[];
Wt=[];

% Desired pass-band phase response
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

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
strt=sprintf("Parallel allpass initial response : ma=%d,mb=%d,fap=%g,fas=%g", ...
             ma,mb,fap,fas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Delay(samples)");
xlabel("Frequency");
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
% MMSE pass
%
printf("Starting MMSE pass\n");
[abm,opt_iter,func_iter,feasible]= ...
parallel_allpass_socp_mmse([],ab0,abu,abl, ...
                           K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                           wa,Asqd*Ksq,Asqdu*Ksq,Asqdl*Ksq,Wa_mmse/Ksq, ...
                           wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol,false);
if feasible
  printf("Found feasible MMSE abm=[ ");printf("%g ",abm(:)');printf("]';\n");
else
  error("MMSE infeasible");
endif

% Plot MMSE response
Asq_mmse=parallel_allpassAsq(wa,abm,1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
ax=plotyy(wa(1:nap)*0.5/pi,10*log10(Asq_mmse(1:nap)), ...
          wa(nas:end)*0.5/pi,10*log10(Asq_mmse(nas:end)));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.4 0]);
axis(ax(2),[0 0.5 -80 -40]);
strt=sprintf("Parallel allpass MMSE response : ma=%d,mb=%d,fap=%g,fas=%g", ...
             ma,mb,fap,fas);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_abmdual"),"-dpdflatex");
close

%
% PCLS pass
%
printf("Starting PCLS pass\n");
[ab1,slb_iter,opt_iter,func_iter,feasible]= ...
parallel_allpass_slb(@parallel_allpass_socp_mmse,abm,abu,abl, ...
                     K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                     wa,Asqd*Ksq,Asqdu*Ksq,Asqdl*Ksq,Wa_pcls/Ksq, ...
                     wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,del,ctol,verbose);
if feasible
  printf("Found feasible PCLS ab1=[ ");printf("%g ",ab1(:)');printf("]';\n");
else
  error("PCLS infeasible");
endif

% Find overall filter polynomials
[Na1,Da1]=a2tf(ab1(1:ma),Va,Qa,Ra);
Da1=Da1(:);
[Nb1,Db1]=a2tf(ab1((ma+1):end),Vb,Qb,Rb);
Db1=Db1(:);
Nab1=(conv(flipud(Da1),Db1)+conv(flipud(Db1),Da1))/2;
Dab1=conv(Da1,Db1);

% Find response
nplot=2048;
[Hab1,wplot]=freqz(Nab1,Dab1,nplot);
Tab1=grpdelay(Nab1,Dab1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -100 5]);
grid("on");
strt=sprintf("Parallel allpass PCLS response : \
ma=%d,mb=%d,fap=%4.2f,dBap=%4.2f,fas=%7.5f,dBas=%5.2f",ma,mb,fap,dBap,fas,dBas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
axis([0 0.5 0 100]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -0.04 0.01]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) 0 50]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot dual amplitude response
Asq=parallel_allpassAsq(wa,ab1,1,Va,Qa,Ra,Vb,Qb,Rb);
ax=plotyy(wa(1:nap)*0.5/pi,10*log10(Asq(1:nap)), ...
          wa(nas:end)*0.5/pi,10*log10(Asq(nas:end)));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.025 0]);
axis(ax(2),[0 0.5 -84.06 -83.96]);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1dual"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(Nab1),qroots(Dab1));
title(strt);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(Na1),qroots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(Nb1),qroots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% PCLS amplitude and delay at local peaks
Asq=parallel_allpassAsq(wa,ab1,1,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=parallel_allpassAsq(wAsqS,ab1,1,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
printf("d1:fAS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Save the filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ma=%d %% Allpass model filter A denominator order\n",ma);
fprintf(fid,"K=%g %% Scale factor\n",K);
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
fprintf(fid,"Was_mmse=%d %% Stop band amplitude response weight(MMSE)\n",
        Was_mmse);
fprintf(fid,"Was_pcls=%d %% Stop band amplitude response weight(PCLS)\n",
        Was_pcls);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
a1=ab1(1:ma);
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
b1=ab1((ma+1):end);
print_allpass_pole(b1,Vb,Qb,Rb,"b1");
print_allpass_pole(b1,Vb,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

% Done 
save parallel_allpass_socp_slb_test.mat ...
     n wa fap Wap fas Was_mmse Was_pcls ma mb K Va Qa Ra Vb Qb Rb ...
     ab0 abm ab1 Da1 Db1
toc;
diary off
movefile parallel_allpass_socp_slb_test.diary.tmp ...
         parallel_allpass_socp_slb_test.diary;
