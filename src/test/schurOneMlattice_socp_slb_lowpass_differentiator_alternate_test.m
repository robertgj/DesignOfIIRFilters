% schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=ftol/100
maxiter=20000
verbose=false

% 1-1/z correction filter from tarczynski_lowpass_differentiator_alternate_test.m
tarczynski_lowpass_differentiator_alternate_test_D0_coef;
tarczynski_lowpass_differentiator_alternate_test_N0_coef;

% Correction filter order
nN=length(N0)-1;

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);c0=c0(:);p0=p0(:);c0=c0(:);

% Low-pass differentiator filter specification
if 0
  % This works but takes 5min and gives inconsistent results:
  %{
  k2a = [  -0.5391690632,   0.6858968187,  -0.4340954598,  -0.1493468959, ... 
            0.5250688588,  -0.4839162209,   0.1561802681,   0.1856245357, ... 
           -0.2406294636,   0.1243024675,  -0.0272620462 ]';

  k2b = [  -0.5392644470,   0.6855561590,  -0.4338242976,  -0.1493646069, ... 
            0.5250765726,  -0.4839270671,   0.1562907778,   0.1856631152, ... 
           -0.2407842496,   0.1244404972,  -0.0273035626 ]';
  %}
  fap=0.18;fas=0.3;
  Arp=0.004;Art=0.004;Ars=0.004;Wap=1;Wat=0.0001;Was=1;
  ftp=fap;tp=length(N0)-2;tpr=0.01;Wtp=1;
  fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
else
  fap=0.18;fas=0.3;
  Arp=0.005;Art=Arp;Ars=Arp;Wap=1;Wat=0.0001;Was=1;
  ftp=fap;tp=length(N0)-2;tpr=0.01;Wtp=1;
  fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
endif

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
ntp=ceil(ftp*n/0.5);
npp=ceil(fpp*n/0.5);

% Pass and transition band amplitudes
wa=w;
Azm1=2*sin(wa/2);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones((nas-nap-1),1);(Ars/2)*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-1-nap,1)];
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Group delay
wt=w(1:ntp);
Tzm1=0.5;
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response
wd=[];
Dzm1=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Coefficient constraints
dmax=0.1; % For compatibility with SQP
rho=127/128;
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Calculate the initial response
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0=sqrt(Asq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0) + Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0) + Tzm1;

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[k2,c2,slb_iter,opt_iter,func_iter,feasible] = schurOneMlattice_slb ...
  (@schurOneMlattice_socp_mmse, ...
   k0,epsilon0,p0,c0,kc_u,kc_l,kc_active,dmax, ...
   wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
   wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
   wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
   wd,(Dd./Dzm1),(Ddu./Dzm1),(Ddl./Dzm1),Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Calculate the overall response
Asq2=schurOneMlatticeAsq(wa,k2,epsilon0,p0,c2);
A2=sqrt(Asq2).*Azm1;
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
P2=schurOneMlatticeP(wp,k2,epsilon0,p0,c2) + Pzm1;
T2=schurOneMlatticeT(wt,k2,epsilon0,p0,c2) + Tzm1;

% Plot response error
subplot(311);
[ax,ha,hs]=plotyy ...
             (wa(1:nap)*0.5/pi, ...
              ([A2(1:nap),Adl(1:nap),Adu(1:nap)])-Ad(1:nap), ...
              wa(nas:end)*0.5/pi, ...
              [A2(nas:end),[Adl(nas:end),Adu(nas:end)]]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
if 0
  axis(ax(1),[0 0.5 Arp*[-1,1]]);
  axis(ax(2),[0 0.5 Ars*[-1,1]]);
else
  axis(ax(1),[0 0.5 0.004*[-1,1]]);
  axis(ax(2),[0 0.5 0.004*[-1,1]]);
endif
strP=sprintf(["Differentiator PCLS : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+(ppr*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+(tpr*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_error_response"),"-dpdflatex");
close

% Pole-zero plot
[N2,D2]=schurOneMlattice2tf(k2,epsilon0,p0,c2);
zplane(qroots(conv(N2,[1,-1])),qroots(D2));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq2)) > 100*eps
  error("max(abs((abs(HH).^2)-Asq2)) > 100*eps");
endif

% Save results
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
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
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol n fap fas Arp Ars tp tpr pp ppr ", ...
 "Wap Wat Was Wtp Wpp N0 D0 k0 epsilon0 p0 c0 k2 c2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
