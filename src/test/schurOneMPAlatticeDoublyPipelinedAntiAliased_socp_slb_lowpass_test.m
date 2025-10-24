% schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test.m
%
% Design a low-pass filter implemented as a doubly-pipelined
% parallel all-pass Schur one-multiplier lattice in series with a
% parallel all-pass half-band anti-aliasing filter.
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

pkg load optim;

strf="schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-3
ctol=1e-7
maxiter=20000
verbose=false

% Reflection coefficient constraint
rho=127/128;
dmax=inf; % For compatibility with SQP

% Parallel all-pass filter order
ma=6;mb=7;

% Anti-aliasing filter order
maa=7;

% Low-pass filter specification (dBap=0.08,tpr=0.15,dpr=0.3 takes 20min!)
fap=0.1;dBap=0.1;Wap=1;Wat=0.01;
fas=0.175;dBas=60;Was=100;Was_wise=0.1;
fpp=fap;pp=0;ppr=0.002;Wpp=1;
ftp=fap;tp=15;tpr=0.2;Wtp=0.1;
fdp=fap;dpr=2;Wdp=0.1;
difference=false;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
npp=ceil(fpp*n/0.5)+1;
ndp=ceil(fdp*n/0.5)+1;

% Pass and transition band amplitudes of combined filters
wa=w;
Ad=[ones(nap,1);zeros(n-nap,1)];
Adu=[ones(nas-1,1);(10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];

% Phase response of combined filters
wp=w(1:npp);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));
% Phase response of z^-2
Pz2=(wp*2);

% Group delay of combined filters
wt=w(1:ntp);
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));
% Group delay response of z^-2
Tz2=2;

% dAsqdw response of combined filters
wd=w(1:ndp);
Dd=zeros(ndp,1);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Fixed odd-order half-band anti-aliasing filter
[Naa,Daa]=butter(maa,0.25*2);
[Aaa1,Aaa2]=tf2pa(Naa,Daa);
[Aaa1k0,Aaa1kepsilon0,Aaa1kp0,~]=tf2schurOneMlattice(flipud(Aaa1(:)),Aaa1(:));
[Aaa2k0,Aaa2kepsilon0,Aaa2kp0,~]=tf2schurOneMlattice(flipud(Aaa2(:)),Aaa2(:));
Aaa1k0=Aaa1k0(:);Aaa1kepsilon0=Aaa1kepsilon0(:);Aaa1kp0=Aaa1kp0(:);
Aaa2k0=Aaa2k0(:);Aaa2kepsilon0=Aaa2kepsilon0(:);Aaa2kp0=Aaa2kp0(:);
Aaa1kones=ones(size(Aaa1k0));
Aaa2kones=ones(size(Aaa2k0));
Aaa1k0(find(abs(Aaa1k0)<100*eps))=0;
Aaa2k0(find(abs(Aaa2k0)<100*eps))=0;
NAaa1k=length(Aaa1k0);
NAaa2k=length(Aaa2k0);
Haa=freqz(Naa,Daa,w);
Aaa=abs(Haa);
Paa=unwrap(arg(Haa));
Taa=delayz(Naa,Daa,w);
Adaa=Ad./Aaa;
Waaa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was_wise*ones(n-nas+1,1)];
Pdaa=((pp*pi)-(w*tp)) - Paa; 
Wpaa=[Wpp*ones(npp,1);zeros(n-npp,1)];
Tdaa=[tp*ones(ntp,1);zeros(n-ntp,1)] - Taa;
Wtaa=[Wtp*ones(ntp,1);zeros(n-ntp,1)];

% Sanity checks
Asqaap=schurOneMPAlatticeAsq(w,Aaa1k0,Aaa1kepsilon0,Aaa1kp0, ...
                             Aaa2k0,Aaa2kepsilon0,Aaa2kp0);
if max(abs(Asqaap-(abs(Haa).^2))) > 1000*eps
  error("max(abs(Asqaap-(abs(Haa).^2)))(%g*eps) > 1000*eps", ...
        max(abs(Asqaap-(abs(Haa).^2)))/eps);
endif
Taap=schurOneMPAlatticeT(w,Aaa1k0,Aaa1kepsilon0,Aaa1kp0, ...
                         Aaa2k0,Aaa2kepsilon0,Aaa2kp0);
if max(abs(Taap(1:ntp)-Taa(1:ntp))) > 1000*eps
  error("max(abs(Taap-Taa))(%g*eps) > 1000*eps", ...
        max(abs(Taap(1:ntp)-Taa(1:ntp)))/eps);
endif

% Example sanity check
if 1
  [Nc2,Dc2]=butter(ma+mb,2*2*fap);
elseif 0
  [Nc2,Dc2]=cheby1(ma+mb,dBap,2*2*fap);
elseif 0
  [Nc2,Dc2]=cheby2(ma+mb,dBas,2*2*fap);
elseif 0
  [Nc2,Dc2]=ellip(ma+mb,dBap,dBas,2*2*fap);
endif
[Dac2,Dbc2]=tf2pa(Nc2,Dc2);
[A1kc2,~,~,~]=tf2schurOneMlattice(fliplr(Dac2),Dac2);
[A2kc2,~,~,~]=tf2schurOneMlattice(fliplr(Dbc2),Dbc2);
Asq0c2=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (wa,A1kc2,A2kc2,difference,Aaa1k0,Aaa2k0);
P0c2=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
       (wp,A1kc2,A2kc2,difference,Aaa1k0,Aaa2k0);
T0c2=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
       (wt,A1kc2,A2kc2,difference,Aaa1k0,Aaa2k0);
% Plot sanity check response
subplot(311)
plot(w*0.5/pi,20*log10([sqrt(Asq0c2),Ad]))
axis([0 0.5 -60 10])
grid("on")
tstr=sprintf("Lowpass sanity check response fap=%g,fas=%g,tp=%g,pp=%g", ...
             fap,fas,tp,pp);
title(tstr);
ylabel("Amplitude");
subplot(312)
plot(wp*0.5/pi,([P0c2,Pd]+(wp*tp))/pi)
axis([0 0.5 -1 1]);
grid("on")
ylabel("Phase(rad./$\\pi$)");
subplot(313)
plot(wt*0.5/pi,[T0c2,Td])
axis([0 0.5 0 20]);
grid("on")
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_sanity_check_response"),"-dpdflatex");
close

% Unconstrained minimisation with (1-z^(-1)) removed
tol=1e-8;
R=2;
polyphase=false;
difference=false;
abi=zeros(ma+mb,1);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
WISEJ_PA([],ma,mb,R,polyphase,difference,Adaa,Waaa,Tdaa,Wtaa,Pdaa,Wpaa);
[ab0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PA,abi,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -1)
  printf("Algorithm terminated by OutputFcn.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Extract the parallel denominator polynomials
ab0=ab0(:);
Da0=[1;ab0(1:ma)];
Db0=[1;ab0((ma+1):end)];
Da0R=[1;kron(Da0(2:end),[zeros(R-1,1);1])];
Db0R=[1;kron(Db0(2:end),[zeros(R-1,1);1])];
D0R=conv(Da0R,Db0R);
N0R=(conv(flipud(Da0R),Db0R)+conv(flipud(Db0R),Da0R))/2;

% Calculate initial response
Ha0=freqz(flipud(Da0R),Da0R,wa);
Hb0=freqz(flipud(Db0R),Db0R,wa);
H0c=(Ha0+Hb0)/2;
A0=abs(H0c).*Aaa;
P0=unwrap(arg(H0c(1:npp)))+Paa(1:npp);
Ta0=delayz(flipud(Da0R),Da0R,wt);
Tb0=delayz(flipud(Db0R),Db0R,wt);
T0c=(Ta0+Tb0)/2;
T0=T0c+Taa(1:ntp);

% Plot initial response
subplot(311)
[ax,ha,hs]=plotyy(wa(1:nap)*0.5/pi, 20*log10(A0(1:nap,:)), ...
                  wa(nap:end)*0.5/pi, 20*log10(A0(nap:end,:)));
% Copy line colour
hac=get(ha,"color");
set(hs,"color",hac);
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 -3 1]);
axis(ax(2),[0 0.5 -80 0]);
grid("on")
tstr=sprintf("Lowpass initial response : fap=%g,fas=%g,tp=%g",fap,fas,tp);
title(tstr);
ylabel("Amplitude(dB)");
subplot(312)
plot(wp*0.5/pi,(P0+(wp*tp))/pi)
axis([0 0.5 pp+0.004*[-1,1]])
grid("on")
ylabel("Phase(rad./$\\pi$)");
subplot(313)
plot(wt*0.5/pi,T0)
axis([0 0.5,tp+0.2*[-1,1]])
grid("on")
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Convert initial filter to parallel all-pass Schur one-multiplier lattice
[A1k0,~,~,~]=tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,~,~,~]=tf2schurOneMlattice(flipud(Db0),Db0);
A1k0=A1k0(:);
A2k0=A2k0(:);
NA1k=length(A1k0);
NA2k=length(A2k0);

% Calculate the initial response of combined correction and anti-aliasing filters
Asq0s=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
        (wa,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
A0s=sqrt(Asq0s);
P0s=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
      (wp,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
T0s=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
      (wt,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);

% Sanity check. Adjust for extra z^2 in schurOneMPAlatticeDoublyPipelined
tol=1e-12;
if max(abs(A0s-A0)) > tol
  error("max(abs(A0s-A0))(%g) > %g", ...
        max(abs(A0s-A0)),tol);
endif
if max(abs((P0s+Pz2)-P0)) > tol
  error("max(abs((P0s+Pz2)-P0))(%g) > %g", ...
        max(abs((P0s+Pz2)-P0)),tol);
endif
if max(abs((T0s-Tz2)-T0)) > tol
  error("max(abs((T0s-Tz2)-T0))(%g) > %g", ...
        max(abs((T0s-Tz2)-T0)),tol);
endif

%
% Coefficient constraints
%
k_u=rho*ones(NA1k+NA2k+NAaa1k+NAaa2k,1);
k_l=-k_u;
k_active=find(abs([A1k0;A2k0;Aaa1k0;Aaa2k0]) > 10*eps);

%
% MMSE pass
%
printf("\nMMSE pass :\n");
feasible=false;
[A1k1,A2k1,Aaa1k1,Aaa2k1,socp_iter,func_iter,feasible]= ...
  schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse ...
    ([], ...
     A1k0,A2k0,difference,Aaa1k0,Aaa2k0,k_u,k_l,k_active,dmax, ...
     wa,Ad.^2,Adu.^2,Adl.^2,Wa, ...
     wt,Td+Tz2,Tdu+Tz2,Tdl+Tz2,Wt, ...
     wp,Pd-Pz2,Pdu-Pz2,Pdl-Pz2,Wp, ...
     wd,Dd,Ddu,Ddl,Wd, ...
     maxiter,ftol,ctol,verbose);
if feasible == 0
  error("MMSE infeasible");
endif

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[A1k2,A2k2,Aaa1k2,Aaa2k2,slb_iter,socp_iter,func_iter,feasible]= ...
  schurOneMPAlatticeDoublyPipelinedAntiAliased_slb ...
    (@schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse, ...
     A1k1,A2k1,difference,Aaa1k1,Aaa2k1,k_u,k_l,k_active,dmax, ...
     wa,Ad.^2,Adu.^2,Adl.^2,Wa, ...
     wt,Td+Tz2,Tdu+Tz2,Tdl+Tz2,Wt, ...
     wp,Pd-Pz2,Pdu-Pz2,Pdl-Pz2,Wp, ...
     wd,Dd,Ddu,Ddl,Wd, ...
     maxiter,ftol,ctol,verbose);
if feasible == 0
  error("PCLS infeasible");
endif

% Calculate PCLS response
Asq2=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
       (wa,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);
A2=sqrt(Asq2);
P2=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
     (wp,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);
T2=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
     (wt,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);
dAsqdw2=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
          (wd,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);

% Plot PCLS response
subplot(311)
[ax,ha,hs]=plotyy(wa(1:nap)*0.5/pi,   20*log10([A2,Adl,Adu])(1:nap,:), ...
                  wa(nap:end)*0.5/pi, 20*log10([A2,Adl,Adu])(nap:end,:));
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 -0.15 0.05]);
axis(ax(2),[0 0.5 -70 -50]);
grid("on")
tstr=sprintf("Lowpass PCLS response : fap=%g,dBap=%g,tp=%g,fas=%g,dBas=%g", ...
             fap,dBap,tp,fas,dBas);
title(tstr);
ylabel("Amplitude(dB)");
subplot(312)
plot(wp*0.5/pi,([(P2+Pz2),Pd,Pdu,Pdl]+(wp*tp))/pi)
axis([0 0.5 pp+ppr*[-1,1]])
grid("on")
ylabel("Phase(rad./$\\pi$)");
subplot(313)
plot(wt*0.5/pi,[(T2-Tz2),Td,Tdu,Tdl])
axis([0 0.5,tp+tpr*[-1,1]])
grid("on")
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Convert to transfer functions
[AA1k2,BA1k2,CA1k2,DA1k2] = schurOneMAPlatticeDoublyPipelined2Abcd(A1k2);
[~,DA1k2]=Abcd2tf(AA1k2,BA1k2,CA1k2,DA1k2);
[AA2k2,BA2k2,CA2k2,DA2k2] = schurOneMAPlatticeDoublyPipelined2Abcd(A2k2);
[~,DA2k2]=Abcd2tf(AA2k2,BA2k2,CA2k2,DA2k2);
DAaa1k2=schurOneMAPlattice2tf(Aaa1k2);
DAaa2k2=schurOneMAPlattice2tf(Aaa2k2);
Naa2=(conv(fliplr(DAaa1k2),DAaa2k2)+conv(fliplr(DAaa2k2),DAaa1k2))/2;
Daa2=conv(DAaa1k2,DAaa2k2);                        
N2=conv((conv(fliplr(DA1k2),DA2k2)+conv(fliplr(DA2k2),DA1k2))/2,Naa2);
D2=conv(conv(DA1k2,DA2k2),Daa2);
% Sanity check
H2c=freqz(N2,D2,wa);
if max(abs(Asq2-(abs(H2c).^2))) > 100*eps
  error("max(abs(Asq2-(abs(H2c).^2)))(%g*eps) > 100*eps", ...
        max(abs(Asq2-(abs(H2c).^2)))/eps);
endif
T2c=delayz(N2,D2,wt);
if max(abs(T2-T2c)) > 1000*eps
  error("max(abs(T2-T2c))(%g*eps) > 1000*eps", ...
        max(abs(T2-T2c))/eps);
endif

% Save results
print_polynomial(A1k2,"A1k2");
print_polynomial(A1k2,"A1k2",strcat(strf,"_A1k2_coef.m"));
print_polynomial(A2k2,"A2k2");
print_polynomial(A2k2,"A2k2",strcat(strf,"_A2k2_coef.m"));

print_polynomial(Aaa1k2,"Aaa1k2");
print_polynomial(Aaa1k2,"Aaa1k2",strcat(strf,"_Aaa1k2_coef.m"));
print_polynomial(Aaa2k2,"Aaa2k2");
print_polynomial(Aaa2k2,"Aaa2k2",strcat(strf,"_Aaa2k2_coef.m"));

print_polynomial(DA1k2,"DA1k2");
print_polynomial(DA1k2,"DA1k2",strcat(strf,"_DA1k2_coef.m"));
print_polynomial(DA2k2,"DA2k2");
print_polynomial(DA2k2,"DA2k2",strcat(strf,"_DA2k2_coef.m"));

print_polynomial(DAaa1k2,"DAaa1k2");
print_polynomial(DAaa1k2,"DAaa1k2",strcat(strf,"_DAaa1k2_coef.m"));
print_polynomial(DAaa2k2,"DAaa2k2");
print_polynomial(DAaa2k2,"DAaa2k2",strcat(strf,"_DAaa2k2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Constraint on reflection coefficients\n",rho);
fprintf(fid,"ma=%d %% Order of all-pass filter 1\n",ma); 
fprintf(fid,"mb=%d %% Order of all-pass filter 2\n",mb); 
fprintf(fid,"maa=%d %% Order of anti-aliasing filter\n",maa); 
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"dBas=%g %% Amplitude stop band peak ripple(dB)\n",dBas);
fprintf(fid,"Was_wise=%g %% Initial amplitude stop band weight\n",Was_wise);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"fpp=%g %% Pass band phase upper edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fprintf(fid,"ftp=%g %% Pass band group delay upper edge\n",ftp);
fprintf(fid,"tp=%g %% Pass band group delay(samples)\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdp=%g %% Pass band dAsqdw upper edge\n",fpp);
fprintf(fid,"dpr=%g %% Pass band dAsqdw peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw weight\n",Wpp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol ma mb maa n ", ...
              "fap dBap Wap fas dBas Was_wise Was ", ...
              "fpp pp ppr Wpp ftp tp tpr Wtp fdp dpr Wdp ", ...
              "ab0 Da0 Db0 A1k0 A2k0 Aaa1k0 Aaa2k0 A1k2 A2k2 Aaa1k2 Aaa2k2 ", ...
              "DA1k2 DA2k2 Naa2 Daa2 N2 D2"], ...
              strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
