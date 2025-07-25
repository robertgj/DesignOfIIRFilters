% schurOneMlattice_socp_slb_bandpass_hilbert_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_bandpass_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-4
ctol=ftol/100
maxiter=2000
verbose=false
dmax=0.1; % For compatibility with SQP
rho=0.999;

% Initial filter 
tarczynski_bandpass_hilbert_test_N0_coef;
tarczynski_bandpass_hilbert_test_D0_coef;

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0,S0,S1M0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);epsilon0=epsilon0(:);p0=p0(:);c0=c0(:);
p_ones=ones(size(k0));

% Band-pass hilbert filter specification
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
dBap=0.16,dBas=34,Wasl=100,Watl=0.001,Wap=1,Watu=0.001,Wasu=100
fppl=0.1,fppu=0.2,pp=1.5,ppr=0.002,Wpp=1
ftpl=0.1,ftpu=0.2,tp=12,tpr=0.2,Wtp=1
fdpl=0.1,fdpu=0.2,dp=0,dpr=0.8,Wdp=0.001

dBap=0.15,dBas=37,dpr=0.7

% Frequency points
n=1000;
f=0.5*(0:(n-1))'/n;
w=2*pi*f;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;

% Pass and transition band amplitudes
wa=w;
Ad=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqd=Ad.^2;
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity check
nachk=[1, ...
       nasl-1,nasl,nasl+1,napl-1,napl,napl+1, ...
       napu-1,napu,napu+1,nasu-1,nasu,nasu+1, ...
       n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Asqd(nachk)=[");printf("%g ",Asqd(nachk));printf(" ]\n");
printf("Asqdu(nachk)=[");printf("%g ",Asqdu(nachk));printf(" ]\n");
printf("Asqdl(nachk)=[");printf("%g ",Asqdl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Phase response
wp=w(nppl:nppu);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(ntpl:ntpu);
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response
wd=w(ndpl:ndpu);
Dd=dp*ones(size(wd));
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));

% Coefficient constraints
Nk=length(k0);
Nc=length(c0);
Nkc=Nk+Nc;
Rk=1:Nk;
Rc=(Nk+1):Nkc;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Calculate the initial response
H0f=freqz(N0,D0,wa);
Asq0f=abs(H0f).^2;
P0f=unwrap(arg(H0f(nppl:nppu)));
T0f=delayz(N0,D0,wt);
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
P0=schurOneMlatticeP(wp,k0,epsilon0,p_ones,c0);
T0=schurOneMlatticeT(wt,k0,epsilon0,p_ones,c0);
dAsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p_ones,c0);

%
% MMSE pass
%
printf("\nMMSE pass :\n");
feasible=false;
[k1,c1,opt_iter,func_iter,feasible] = schurOneMlattice_socp_mmse ...
  ([],k0,epsilon0,p_ones,c0,kc_u,kc_l,kc_active,dmax, ...
   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k1 (MMSE) infeasible");
endif

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[k2,c2,slb_iter,opt_iter,func_iter,feasible] = schurOneMlattice_slb ...
  (@schurOneMlattice_socp_mmse, ...
   k1,epsilon0,p_ones,c1,kc_u,kc_l,kc_active,dmax, ...
   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Recalculate epsilon, p and c
printf("\nBefore recalculating epsilon and c:\n");
print_polynomial(epsilon0,"epsilon0");
print_polynomial(c2,"c2");
printf("\n");
[N2,D2]=schurOneMlattice2tf(k2,epsilon0,p_ones,c2);
[k2r,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);
k2r=k2r(:);epsilon2=epsilon2(:);p2=p2(:);c2=c2(:);
if max(abs(k2-k2r))>1e5*eps
  error("max(abs(k2-k2r))(%g*eps)>1e5*eps",max(abs(k2-k2r))/eps);
endif

% Pole-zero plot
zplane(qroots(N2(:)),qroots(D2(:)));
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Calculate the response
Asq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
P2=schurOneMlatticeP(wp,k2,epsilon2,p2,c2);
T2=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
dAsqdw2=schurOneMlatticedAsqdw(wd,k2,epsilon2,p2,c2);

% Check amplitude of transfer function
H2=freqz(N2,D2,wa);
if max(abs((abs(H2).^2)-Asq2)) > 1e8*eps
  error("max(abs((abs(H2).^2)-Asq2))(%g*eps) > 1e8*eps", ...
        max(abs((abs(H2).^2)-Asq2))/eps);
endif

% Plot response
subplot(411);
ax=plotyy(wa*0.5/pi,10*log10(Asq2), ...
          wa*0.5/pi,10*log10(Asq2));
axis(ax(1),[0 0.5 -40 -35]);
axis(ax(2),[0 0.5 -0.2 0.05]);
grid("on");
strP=sprintf(["Bandpass hilbert response : ", ...
 "fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fasl,fapl,fapu,fasu,dBap,dBas,tp,tpr,ppr);
title(strP);
ylabel("Ampl.(dB)");
subplot(412);
plot(wp*0.5/pi,mod((unwrap([P2 Pdl Pdu])+(wp*tp))/pi,2));
axis([0 0.5 mod(pp,2)+(ppr*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(413);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+(tpr*[-1,1])]);
grid("on");
ylabel("Delay(samples)");
subplot(414);
plot(wd*0.5/pi,[dAsqdw2 Ddl Ddu]);
axis([0 0.5 dp+(0.4*[-1,1])]);
grid("on");
ylabel("dAsqdw");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save results
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2","%2d");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"dmax=%d %% SQP step-size constraint\n",dmax);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapl=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Watl=%g %% Amplitude lower transition band weight\n",Watl);
fprintf(fid,"Watu=%g %% Amplitude upper transition band weight\n",Watu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"fppl=%g %% Phase pass band lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Phase pass band upper edge\n",fppu);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdpl=%g %% dAsqdw pass band lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% dAsqdw pass band upper edge\n",fdpu);
fprintf(fid,"dpr=%g %% dAsqdw pass band peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% dAsqdw pass band weight\n",Wdp);
fclose(fid);

eval(strcat(sprintf("save %s.mat ftol ctol n ",strf), ...
            " fasl fapl fapu fasu dBap dBas Wasl Watl Wap Watu Wasu ", ...
            " fppl fppu pp ppr Wpp ftpl ftpu tp tpr Wtp fdpl fdpu dpr Wdp ", ...
            " N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
