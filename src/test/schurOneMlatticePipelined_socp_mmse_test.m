% schurOneMlatticePipelined_socp_mmse_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticePipelined_socp_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=2000
ftol=1e-6
ctol=ftol
verbose=false

% Low pass filter specification
N=10 % Filter order
fap=0.1 % Pass band amplitude response edge
dBap=0.5 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
fas=0.15 % Stop band amplitude response edge
dBas=40 % Stop band amplitude response ripple
Was=1e4 % Stop band amplitude response weight
td=7 % Pass band nominal group delay
tdr=2 % Pass band group delay response ripple
ftp=0.125 % Pass band group delay response edge
Wtp=0.1 % Pass band group delay response weight
fpp=0.125 % Pass band phase response edge
ppr=0.2 % Pass band phase response ripple(rad./pi)
Wpp=0.01 % Pass band phase response weight
fdp=0.05 % Pass band dAsqdw response edge
dpr=0.8 % Pass band dAsqdw response ripple(rad./pi)
Wdp=0.01 % Pass band dAsqdw response weight

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
Tdu=Td+(tdr*ones(ntp,1)/2);
Tdl=Td-(tdr*ones(ntp,1)/2);
Wt=Wtp*ones(ntp,1);

% Desired pass-band phase response
npp=ceil(nplot*fpp/0.5)+1;
wp=wa(1:npp);
Pd=-td*wp;
Pdu=Pd+(ppr*pi*ones(npp,1)/2);
Pdl=Pd-(ppr*pi*ones(npp,1)/2);
Wp=Wpp*ones(npp,1);

% Desired pass-band dAsqdw response
ndp=ceil(nplot*fdp/0.5)+1;
wd=wa(1:ndp);
Dd=zeros(ndp,1);
Ddu=Dd+(dpr*ones(ndp,1)/2);
Ddl=Dd-(dpr*ones(ndp,1)/2);
Wd=Wdp*ones(ndp,1);

% Initial coefficients
[N0,D0]=butter(10,2*fap);

% Lattice decomposition
[k0,epsilon0,c0,kk0,ck0] = tf2schurOneMlatticePipelined(N0,D0);

% Linear constraints
dmax=inf;
rho=127/128
Nk=length(k0);
Nc=length(c0);
Nkk=length(kk0);
Nck=length(ck0);
kc0=[k0(:);c0(:);kk0(:);ck0(:)];
Nkc=length(kc0);
kc_u=[rho*ones(size(k0(:))); ...
      10*ones(size(c0(:))); ...
      rho*ones(size(kk0(:))); ...
      10*ones(size(ck0(:)))];
kc_l=-kc_u;
kc_active=find([k0(:);c0(:);kk0(:);ck0(:)]);
vS=[];

% SOCP
try
  [k1,c1,kk1,ck1,socp_iter,func_iter,feasible]= ...
    schurOneMlatticePipelined_socp_mmse(vS, ...
                                 k0,epsilon0,c0,kk0,ck0, ...
                                 kc_u,kc_l,kc_active,dmax, ...
                                 wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                 wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                                 maxiter,ftol,ctol,verbose);
catch
  feasible=false;
end_try_catch
if ~feasible
  error("k1 infeasible");
endif

% Find response
Asq=schurOneMlatticePipelinedAsq(wa,k1,epsilon0,c1,kk1,ck1);
T=schurOneMlatticePipelinedT(wt,k1,epsilon0,c1,kk1,ck1);
P=schurOneMlatticePipelinedP(wp,k1,epsilon0,c1,kk1,ck1);
dAsqdw=schurOneMlatticePipelineddAsqdw(wd,k1,epsilon0,c1,kk1,ck1);

% Find N1,D1
[A1,B1,C1,dd1]=schurOneMlatticePipelined2Abcd(k1,epsilon0,c1,kk1,ck1);
[N1,D1]=Abcd2tf(A1,B1,C1,dd1);
D1=D1(1:(N+1));
% Check response
H1=freqz(N1,D1,wa);
max_diff_Asq=max(abs((abs(H1).^2)-Asq));
if max_diff_Asq>5e-12
  error("max(abs((abs(H1).^2)-Asq))(%g)>5e-12",max_diff_Asq);
endif
% Check eigenvalues
[A1c,B1c,C1c,dd1c]=tf2Abcd(N1,D1);
diff_eigs_rows_A1=abs(sort(eigs(A1,rows(A1)))-sort(eigs(A1c,rows(A1c))));
if max(diff_eigs_rows_A1) > 5e-13
  error("max(diff_eigs_rows_A1)(%g)>5e-13",max(diff_eigs_rows_A1));
endif

% Plot response
subplot(311);
plot(wa*0.5/pi,10*log10(Asq));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
s=sprintf("Pipelined Schur one-multiplier allpass : td=%g", td);
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
axis([0 0.5 td-tdr td+tdr]);
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(411);
plot(wa*0.5/pi,10*log10(Asq));
ylabel("Amplitude(dB)");
axis([0 max([fap,ftp,fpp,fdp]) -1 1 ]);
grid("on");
title(s);
subplot(412);
plot(wp*0.5/pi,(P+(wp*td))/pi);
axis([0 max([fap,ftp,fpp,fdp]) [-1 1]*ppr/2 ]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(413);
plot(wt*0.5/pi,T-td);
ylabel("Delay error(samples)");
axis([0 max([fap,ftp,fpp,fdp]) [-1 1]*tdr/2 ]);
grid("on");
subplot(414);
plot(wd*0.5/pi,dAsqdw);
ylabel("dAsqdw");
xlabel("Frequency");
axis([0 max([fap,ftp,fpp,fdp]) [-1 1]*dpr/2 ]);
grid("on");
zticks([]);
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nplot=%d %% Frequency points across the band\n",nplot);
fprintf(fid,"N=%d %% Filter order\n",N);
fprintf(fid,"fap=%f %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%f %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"fas=%f %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"Was=%f %% Stop band amplitude response weight\n",Was);
fprintf(fid,"ftp=%f %% Pass band group delay response edge\n",ftp);
fprintf(fid,"td=%f %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%f %% Pass band group delay response ripple\n",tdr);
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
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(c1,"c1");
print_polynomial(c1,"c1",strcat(strf,"_c1_coef.m"));
print_polynomial(kk1,"kk1");
print_polynomial(kk1,"kk1",strcat(strf,"_kk1_coef.m"));
print_polynomial(ck1,"ck1");
print_polynomial(ck1,"ck1",strcat(strf,"_ck1_coef.m"));
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

eval(sprintf(strcat("save %s.mat ftol ctol rho nplot N N0 D0 ", ...
                    " fap dBap Wap fas dBas Was ", ...
                    " ftp td tdr Wtp fpp ppr Wpp fdp dpr Wdp ", ...
                    " k1 c1 kk1 ck1 A1 B1 C1 dd1 N1 D1"), strf));

% Done 
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
