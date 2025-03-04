% schurOneMPAlattice_socp_mmse_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlattice_socp_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=2000
ftol=1e-9
ctol=ftol
verbose=false

% Low pass filter specification 
ma=11 % Allpass filter A denominator order
mb=12 % Allpass filter B denominator order
difference=false % Use sum of allpass filter ouptuts
fap=0.1 % Pass band amplitude response edge
dBap=0.5 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
fas=0.15 % Stop band amplitude response edge
dBas=40 % Stop band amplitude response ripple
Was=1e2 % Stop band amplitude response weight
ftp=0.125 % Pass band group delay response edge
td=11.86 % Pass band nominal group delay
tpr=0.15 % Pass band group delay response ripple
Wtp=1 % Pass band group delay response weight
fpp=0.125 % Pass band phase response edge
ppr=0.06 % Pass band phase response ripple(rad./pi)
Wpp=1 % Pass band phase response weight
fdp=fap % Pass band dAsqdw response edge
dpr=0.2; % Pass band dAsqdw response ripple
Wdp=0.1; % Pass band dAsqdw response weight

% Desired squared magnitude response
nplot=1000;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
wa=(0:(nplot-1))'*pi/nplot;
Asqd=[ones(nap,1);zeros(nplot-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(nplot-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(nplot-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+1,1)];

% Desired pass-band group delay response
ntp=ceil(nplot*ftp/0.5)+1;
wt=wa(1:ntp);
Td=td*ones(ntp,1);
Tdu=Td+(tpr*ones(ntp,1)/2);
Tdl=Td-(tpr*ones(ntp,1)/2);
Wt=Wtp*ones(ntp,1);

% Desired pass-band phase response
npp=ntp;
wp=wt;
Pd=-td*wp;
Pdu=Pd+(ppr*pi*ones(npp,1)/2);
Pdl=Pd-(ppr*pi*ones(npp,1)/2);
Wp=Wpp*ones(npp,1);

% Desired pass-band dAsqdw response
ndp=nap;
wd=wa(1:ndp);
Dd=zeros(size(wd));
Ddu=Dd+(dpr*ones(ndp,1)/2);
Ddl=Dd-(dpr*ones(ndp,1)/2);
Wd=Wdp*ones(ndp,1);

% Initial coefficients found by tarczynski_parallel_allpass_test.m
% (with fap=0.15, ftp=0.175 and fas=0.2)
D1_0 = [   1.0000000000,   0.6972798244,  -0.2975063565,  -0.3126561409, ... 
          -0.1822051754,   0.0540552622,   0.0875338601,  -0.1043232198, ... 
           0.1845967862,   0.0440769117,  -0.1321004467,   0.0451935897 ]';
D2_0 = [   1.0000000000,   0.1561448318,  -0.3135751143,   0.3178486637, ... 
           0.1300070569,   0.0784800776,  -0.0638101019,  -0.1841985776, ... 
           0.2692566922,  -0.0893427023,  -0.1362443329,   0.1339411887, ... 
          -0.0582212520 ]';

% Lattice decomposition of D1_0, D2_0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(D1_0),D1_0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(D2_0),D2_0);

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);
vS=[];

% SOCP
try
  [A1k,A2k,socp_iter,func_iter,feasible]= ...
    schurOneMPAlattice_socp_mmse(vS, ...
                                 A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                                 difference, ...
                                 k_u,k_l,k_active,dmax, ...
                                 wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                 wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                                 maxiter,ftol,ctol,verbose);
catch
  feasible=false;
end_try_catch
if !feasible
  error("A1k,A2k infeasible");
endif

% Find response
Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
T=schurOneMPAlatticeT(wt,A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
P=schurOneMPAlatticeP(wp,A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
D=schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0, ...
                           difference);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("td=%d,tpr=%g,Wtp=%g",td,tpr,Wtp));

% Plot response
subplot(311);
plot(wa*0.5/pi,10*log10(Asq));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
s=sprintf("Parallel Schur one-multiplier allpass : ma=%d,mb=%d,td=%g", ma,mb,td);
title(s);
subplot(312);
plot(wp*0.5/pi,(P+(wp*td))/pi);
axis([0 0.5 ppr*[-1,1]]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 td-tpr td+tpr]);
grid("on");
print(strcat(strf,"_A12"),"-dpdflatex");
close

% Plot passband response
subplot(411);
plot(wa*0.5/pi,10*log10(Asq));
ylabel("Amplitude(dB)");
axis([0 max([fap,ftp,fpp,fdp]) -3 1]);
grid("on");
title(s);
subplot(412);
plot(wp*0.5/pi,(P+(wp*td))/pi);
axis([0 max([fap,ftp,fpp,fdp]) ppr*[-1,1]]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(413);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
axis([0 max([fap,ftp,fpp,fdp]) td-tpr td+tpr]);
grid("on");
subplot(414);
plot(wd*0.5/pi,D);
ylabel("dAsqdw");
xlabel("Frequency");
axis([0 max([fap,ftp,fpp,fdp]) -dpr dpr]);
grid("on");
print(strcat(strf,"_A12pass"),"-dpdflatex");
close

% Plot poles and zeros
[N12,D12]=schurOneMPAlattice2tf(A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0, ...
                                difference);
subplot(111);
zplane(qroots(N12),qroots(D12));
title(s);
print(strcat(strf,"_A12pz"),"-dpdflatex");
close
A1d=schurOneMAPlattice2tf(A1k,A1epsilon0,A1p0);
subplot(111);
zplane(qroots(flipud(A1d(:))),qroots(A1d(:)));
title(s);
print(strcat(strf,"_A1pz"),"-dpdflatex");
close
subplot(111);
A2d=schurOneMAPlattice2tf(A2k,A2epsilon0,A2p0);
zplane(qroots(flipud(A2d(:))),qroots(A2d(:)));
title(s);
print(strcat(strf,"_A2pz"),"-dpdflatex");
close

% Plot phase response of parallel filters
D1=schurOneMAPlattice2tf(A1k,A1epsilon0,A1p0);
D2=schurOneMAPlattice2tf(A2k,A2epsilon0,A2p0);
H1=freqz(flipud(D1(:)),D1(:),wa);
H2=freqz(flipud(D2(:)),D2(:),wa);
plot(wa*0.5/pi,[unwrap(arg(H1)), unwrap(arg(H2))]+(wa*td))
s=sprintf(...
"Allpass phase response error from linear phase (-w*td): ma=%d,mb=%d,td=%g",...
ma,mb,td);
title(s);
ylabel("Phase response(rad.)\n(Corrected for delay)");
xlabel("Frequency");
legend("A","B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_A1A2phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"nplot=%d %% Frequency points across the band\n",nplot);
fprintf(fid,"ma=%d %% Allpass filter A denominator order\n",ma);
fprintf(fid,"mb=%d %% Allpass filter B denominator order\n",mb);
fprintf(fid,"fap=%f %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%f %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fas=%f %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%f %% Stop band amplitude response weight\n",Was);
fprintf(fid,"ftp=%f %% Pass band group delay response edge\n",ftp);
fprintf(fid,"td=%f %% Pass band nominal group delay\n",td);
fprintf(fid,"tpr=%f %% Pass band group delay response ripple\n",tpr);
fprintf(fid,"Wtp=%f %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"fpp=%f %% Pass band phase response edge\n",fpp);
fprintf(fid,"ppr=%f %% Pass band phase peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%f %% Pass band phase response weight\n",Wpp);
fprintf(fid,"fdp=%f %% Pass band dAsqdw response edge\n",fdp);
fprintf(fid,"dpr=%f %% Pass band dAsqdw peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%f %% Pass band dAsqdw response weight\n",Wdp);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf("save %s.mat ftol nplot ma mb fap dBap Wap fas dBas Was ftp td tpr \
Wtp fpp ppr Wpp fdp dpr Wdp rho D1_0 D2_0 A1k A2k D1 D2",strf));

% Done 
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
