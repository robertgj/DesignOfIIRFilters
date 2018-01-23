% polyphase_allpass_socp_slb_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("polyphase_allpass_socp_slb_test.diary");
unlink("polyphase_allpass_socp_slb_test.diary.tmp");
diary polyphase_allpass_socp_slb_test.diary.tmp

tic;

format compact
verbose=false
maxiter=2000
strf="polyphase_allpass_socp_slb_test";

% Initial coefficients found by tarczynski_polyphase_allpass_test.m
Da0 = [   1.0000000000,  -0.5678200774,  -0.7408092770,   0.2506942396, ... 
         -0.1668555458,   0.1742421827,  -0.3582634504,   0.2364365832, ... 
          0.5557294579,  -0.2129754175,  -0.1400950350,   0.0014345949 ]';
Db0 = [   1.0000000000,  -0.0685941087,  -1.1480265355,   0.0125362666, ... 
         -0.0223606303,   0.0606067077,  -0.2400513446,   0.0221246296, ... 
          0.7361372042,   0.0024401600,  -0.2799533185,  -0.0300497894 ]';

% Lowpass filter specification for polyphase combination of all-pass filters
tol=1e-4
ctol=1e-8
n=500;
polyphase=true
difference=false
rho=0.999
R=2
Ra=R
Rb=R
ma=length(Da0)-1
mb=length(Db0)-1
fap=0.24
dBap=0.001
Wap=1
ftp=0.24
td=(R*(ma+mb))/2
tdr=0.2
Wtp=0
fas=0.26
dBas=77
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
Da0R=[1;kron(Da0(2:end),[zeros(R-1,1);1])];
Db0R=[1;kron(Db0(2:end),[zeros(R-1,1);1])];
Nab0=(conv(flipud(Da0R),[Db0R;0])+conv([0;flipud(Db0R)],Da0R))/2;
Dab0=conv(Da0R,Db0R);
nplot=512;
[Hab0,wplot]=freqz(Nab0,Dab0,nplot);
Tab0=grpdelay(Nab0,Dab0,nplot);

% Plot initial response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Initial polyphase allpass : ma=%d,mb=%d", ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Group delay(samples)");
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
[Nb1,Db1]=a2tf(ab1((ma+1):end),Vb,Qb,Rb);
Nab1=([conv(Na1,Db1);0]+[0;conv(Nb1,Da1)])/2;
Dab1=conv(Da1,Db1);

% Find response
nplot=512;
[Hab1,wplot]=freqz(Nab1,Dab1,nplot);
Tab1=grpdelay(Nab1,Dab1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -90 5]);
grid("on");
strt=sprintf("Polyphase allpass : ma=%d,mb=%d,dBap=%5.3f,dBas=%d",
             ma,mb,dBap,dBas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband and stopband response detail
nplot=512;
nplot_ap=ceil(nplot*fap/0.5)+1;
nplot_as=floor(nplot*fas/0.5)+1;
ax=plotyy(wplot(1:nplot_ap)*0.5/pi,    20*log10(abs(Hab1(1:nplot_ap))),...
          wplot(nplot_as:nplot)*0.5/pi,20*log10(abs(Hab1(nplot_as:nplot))));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis(ax(1),[0, 0.5, -dBap/2000, dBap/10000]);
axis(ax(2),[0, 0.5, -80, -74]);
grid("on");
title(strt);
print(strcat(strf,"_ab1dual"),"-dpdflatex");
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

% Save the filter specification
fid=fopen("polyphase_allpass_socp_slb_test.spec","wt");
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
save polyphase_allpass_socp_slb_test.mat ...
    n fap Wap fas Was ma mb Ra Rb ab0 ab1 Da1 Db1
toc;
diary off
movefile polyphase_allpass_socp_slb_test.diary.tmp ...
         polyphase_allpass_socp_slb_test.diary;
