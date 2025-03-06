% polyphase_allpass_socp_slb_flat_delay_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="polyphase_allpass_socp_slb_flat_delay_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000

% Initial coefficients found by tarczynski_polyphase_allpass_test.m
tarczynski_polyphase_allpass_test_flat_delay_Da0_coef;
tarczynski_polyphase_allpass_test_flat_delay_Db0_coef;

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
ftp=0.22
td=(R*(ma+mb))/2
tdr=0.08
Wtp=1
fas=0.28
dBas=60
Was=1

% Convert coefficients to a vector
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

%
% Frequency vectors
%

% Desired stop-band squared magnitude response
nas=floor(n*fas/0.5);
wa=(nas:(n-1))'*pi/n;
A2d=zeros(size(wa));
A2du=(10^(-dBas/10))*ones(size(wa));
A2dl=zeros(size(wa));
Wa=Was*ones(size(wa));

% Desired pass-band group delay response
ntp=ceil(n*ftp/0.5);
wt=(0:ntp)'*pi/n;;
Td=td*ones(size(wt));
Tdu=Td+(tdr*ones(size(wt))/2);
Tdl=Td-(tdr*ones(size(wt))/2);
Wt=Wtp*ones(size(wt));

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
Tab0=delayz(Nab0,Dab0,nplot);

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
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

%
% PCLS pass
%
feasible = false;
[ab1,slb_iter,opt_iter,func_iter,feasible]= ...
  parallel_allpass_slb(@parallel_allpass_socp_mmse,ab0,abu,abl, ...
                       1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                       wa,A2d,A2du,A2dl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
if ~feasible
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
Tab1=delayz(Nab1,Dab1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Polyphase allpass : ma=%d,mb=%d,td=%g,tdr=%g,dBas=%g",
             ma,mb,td,tdr,dBas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.25 -8e-6 0]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.25 td-(tdr/2) td+(tdr/2)]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
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

% Plot phase response of polyphase parallel filters
Ha=freqz(Na1,Da1,nplot);
Hb=freqz(Nb1,Db1,nplot);
plot(wplot*0.5/pi,(unwrap(arg(Ha))+(wplot*td))/pi, ...
     wplot*0.5/pi,(unwrap(arg(Hb))+(wplot*(td-1)))/pi);
strt=sprintf("Allpass phase response adjusted for linear phase : \
ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
ylabel("Linear phase error(rad./pi)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
legend("location","east");
text(0.02,-3.5,"Note: the filter B phase includes the polyphase delay")
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
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
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"td=%g %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band nominal group delay ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
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
save polyphase_allpass_socp_slb_flat_delay_test.mat ...
     n ftp td tdr Wtp fas dBas Was ma mb Ra Rb ab0 ab1 Da1 Db1
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));

