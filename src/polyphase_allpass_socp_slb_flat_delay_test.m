% polyphase_allpass_socp_slb_flat_delay_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("polyphase_allpass_socp_slb_flat_delay_test.diary");
unlink("polyphase_allpass_socp_slb_flat_delay_test.diary.tmp");
diary polyphase_allpass_socp_slb_flat_delay_test.diary.tmp

tic;

format compact
verbose=false
maxiter=2000
strf="polyphase_allpass_socp_slb_flat_delay_test";

% Initial coefficients found by tarczynski_polyphase_allpass_test.m
Da0 = [   1.0000000000,  -0.0002121961,   0.0001202238,  -0.0000935560, ... 
          0.0000838474,  -0.0000779294,   0.0000749508,  -0.0000709944, ... 
          0.0000677135,  -0.0000656198,   0.0000704229,  -0.0001415160 ]';
Db0 = [   1.0000000000,   0.4963343295,  -0.1198744804,   0.0562556510, ... 
         -0.0320274025,   0.0197815475,  -0.0126424184,   0.0081407634, ... 
         -0.0051817103,   0.0032066263,  -0.0019030800,   0.0011987353 ]';

% Lowpass filter specification for polyphase combination of all-pass filters
tol=1e-4
ctol=1e-7
n=500;
polyphase=true
difference=false
rho=31/32
R=2
Ra=R
Rb=R
ma=length(Da0)-1
mb=length(Db0)-1
fap=0.22
dBap=5e-6
Wap=0
ftp=0.22
td=22.02 %(R*(ma+mb))/2
tdr=0.08
Wtp=1
fas=0.28
dBas=60
Was=500

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

% Phase response
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
axis([0 0.5 -100 5]);
grid("on");
strt=sprintf("Initial polyphase allpass : ma=%d,mb=%d", ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

%
% PCLS pass
%
[ab1,slb_iter,opt_iter,func_iter,feasible]= ...
parallel_allpass_slb(@parallel_allpass_socp_mmse,ab0,abu,abl, ...
                     Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                     wa,A2d,A2du,A2dl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                     wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
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
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Polyphase allpass : ma=%d,mb=%d,dBap=%g,dBas=%d,td=%g,tdr=%g",
             ma,mb,dBap,dBas,td,tdr);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -dBap 0]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) td-tdr td+tdr]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
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

% Plot phase response of polyphase parallel filters
Ha=freqz(Na1,Da1,nplot);
Hb=freqz(Nb1,Db1,nplot);
plot(wplot*0.5/pi,unwrap(arg(Ha))+(wplot*td), ...
     wplot*0.5/pi,unwrap(arg(Hb))+(wplot*(td-1)));
strt=sprintf("Allpass phase response error from linear phase (-w*td): \
ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
ylabel("Linear phase error(rad.)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
text(0.02,-3.5,"Note: the filter B phase includes the polyphase delay")
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
save polyphase_allpass_socp_slb_flat_delay_test.mat ...
     n fap Wap ftp Wtp fas Was td tdr ma mb Ra Rb ab0 ab1 Da1 Db1
toc;
diary off
movefile polyphase_allpass_socp_slb_flat_delay_test.diary.tmp ...
         polyphase_allpass_socp_slb_flat_delay_test.diary;
