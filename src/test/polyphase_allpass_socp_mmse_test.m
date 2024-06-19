% polyphase_allpass_socp_mmse_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="polyphase_allpass_socp_mmse_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));


verbose=true

% Initial coefficients found by tarczynski_polyphase_allpass_test.m
Da0 = [   1.0000000000,  -0.0002135795,   0.0001187213,  -0.0000936667, ... 
          0.0000824972,  -0.0000769381,   0.0000730337,  -0.0000697784, ... 
          0.0000663975,  -0.0000642384,   0.0000693792,  -0.0001412838 ]';
Db0 = [   1.0000000000,   0.4963316187,  -0.1198749572,   0.0562537917, ... 
         -0.0320259192,   0.0197795181,  -0.0126415985,   0.0081394843, ... 
         -0.0051805297,   0.0032053536,  -0.0019025918,   0.0011977681 ]';

% Lowpass filter specification for polyphase all-pass filters
ftol=1e-7
ctol=ftol
maxiter=2000
polyphase=true
difference=false
R=2
ma=length(Da0)-1
mb=length(Db0)-1
fap=0.22
Wap=1
ftp=0.22
td=(R*(ma+mb))/2
Wtp=3
fas=0.28
Was=1000
K=2
Ksq=K^2;

% Coefficient constraints
rho=31/32;

% Convert coefficients to a vector
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
Ra=R;
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);
Rb=R;
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

% Frequency vectors
n=1000;

% Desired pass-band squared magnitude response
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
A2d=[ones(nap,1);zeros(n-nap,1)];
A2du=[];
A2dl=[];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Desired pass-band group delay response
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=[];
Tdl=[];
Wt=Wtp*ones(ntp,1);

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
vS=[];

% SOCP
[ab1,socp_iter,func_iter,feasible]= ...
  parallel_allpass_socp_mmse(vS,ab0,abu,abl,K,Va,Qa,Ra,Vb,Qb,Rb, ...
                             polyphase,difference, ...
                             wa,A2d*Ksq,A2du*Ksq,A2dl*Ksq,Wa/Ksq, ...
                             wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                             maxiter,ftol,ctol,verbose);
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
Tab1=delayz(Nab1,Dab1,nplot);

% Common strings
strt=sprintf("Polyphase allpass : ma=%d,mb=%d,td=%g", ma,mb,td);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-0.5 td+0.5]);
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -1e-4 1e-4]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) td-0.2 td+0.2]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(Nab1),qroots(Dab1));
title(strt);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(Na1),qroots(Da1));
title(strt);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(Nb1),qroots(Db1));
title(strt);
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% Plot the phase response error of polyphase component filters.
% The z^-1 polyphase delay is included in the response of filter B.
Ha=freqz(Na1,Da1,nplot);
Hb=freqz(Nb1,Db1,nplot);
plot(wplot*0.5/pi,[unwrap(arg(Ha)),(unwrap(arg(Hb))-wplot)]+(wplot*td));
s=sprintf(...
"Allpass phase response error from linear phase (-w*td): ma=%d,mb=%d,td=%g",...
ma,mb,td);
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
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
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
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

% Done 
save polyphase_allpass_socp_mmse_test.mat ...
     n fap Wap ftp Wtp fas Was td ma mb Ra Rb ab0 ab1 Da1 Db1
eval(sprintf("save %s.mat fM_0 k0_0 epsilon0 k1_0 epsilon1 \
fapl fasl fasu fapu Wap Was dmax rho ftol fM k0 k1",strf));

diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
