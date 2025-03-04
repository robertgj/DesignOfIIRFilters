% schurOneMPAlattice_socp_slb_multiband_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlattice_socp_slb_multiband_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000;
ftol=1e-4;
ctol=1e-6;
verbose=false;

nplot=1000;
npoints=nplot;
difference=true;

% From tarczynski_parallel_allpass_multiband_test.m:
tarczynski_parallel_allpass_multiband_test_Da0_coef;
tarczynski_parallel_allpass_multiband_test_Db0_coef;

% Implement the all-pass filters as Schur one-multiplier lattice filters
[A1k0,A1epsilon0,A1p0,A1c0]=tf2schurOneMlattice(fliplr(Da0),Da0);
[A2k0,A2epsilon0,A2p0,A2c0]=tf2schurOneMlattice(fliplr(Db0),Db0);

% Plot initial filter
w=(0:(nplot-1))'*pi/nplot;
Asq=schurOneMPAlatticeAsq(w,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                          difference);
T=schurOneMPAlatticeT(w,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                      difference);
subplot(211)
plot(w*0.5/pi,10*log10(Asq))
axis([0 0.5 -50 1])
ylabel("Amplitude(dB)");
grid("on");
subplot(212)
plot(w(10:end)*0.5/pi,T(10:end))
axis([0 0.5 0 40])
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial"),"-dpdflatex");
close

% Desired frequency response specification
fas1u=0.06;
fap1l=0.09;fap1u=0.10;
fas2l=0.13;fas2u=0.16;
fap2l=0.19;fap2u=0.22;
fas3l=0.25;
dBap=1;Wap=1;
dBas=33;Was=1;
tp=20;tpr=0.1;Wtp=0.01;

dBas1=dBas;dBap1=dBap;dBas2=dBas;dBap2=dBap;dBas3=dBas;
Was1=Was;Wap1=Wap;Was2=Was;Wap2=Wap;Was3=Was;
ftp1l=fap1l;ftp1u=fap1u;
ftp2l=fap2l;ftp2u=fap2u;
tp1=tp;tpr1=tpr;tp2=tp;tpr2=tpr;
Wtp1=Wtp;Wtp2=Wtp;

% Amplitude mask
fa=0.5*(0:(npoints-1))'/npoints;
wa=fa*2*pi;
nas1u=ceil(npoints*fas1u/0.5)+1;
nap1l=floor(npoints*fap1l/0.5)+1;
nap1u=ceil(npoints*fap1u/0.5)+1;
nas2l=floor(npoints*fas2l/0.5)+1;
nas2u=ceil(npoints*fas2u/0.5)+1;
nap2l=floor(npoints*fap2l/0.5)+1;
nap2u=ceil(npoints*fap2u/0.5)+1;
nas3l=floor(npoints*fas3l/0.5)+1;

Asqd=[zeros(nap1l-1,1); ...
      ones(nap1u-nap1l+1,1); ...
      zeros(nap2l-nap1u-1,1); ...
      ones(nap2u-nap2l+1,1); ...
      zeros(npoints-nap2u,1)];
Asqdu=[(10^(-dBas1/10))*ones(nas1u,1); ...
       ones(nas2l-nas1u-1,1); ...
       (10^(-dBas2/10))*ones(nas2u-nas2l+1,1); ...
       ones(nas3l-nas2u-1,1); ...
       (10^(-dBas3/10))*ones(npoints-nas3l+1,1)];
Asqdl=[zeros(nap1l-1,1); ...
       (10^(-dBap1/10))*ones(nap1u-nap1l+1,1); ...
       zeros(nap2l-nap1u-1,1); ...
       (10^(-dBap2/10))*ones(nap2u-nap2l+1,1); ...
       zeros(npoints-nap2u,1)];
Wa=[Was1*ones(nap1l-1,1); ...
    Wap1*ones(nap1u-nap1l+1,1); ...
    Was2*ones(nap2l-nap1u-1,1); ...
    Wap2*ones(nap2u-nap2l+1,1); ...
    Was3*ones(npoints-nap2u,1)];

% Sanity checks
printf("Lower amplitude stop-band:\n");
nchka=[nas1u-1,nas1u,nas1u+1];
printf("nchka=[nas1u-1,nas1u,nas1u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Lower amplitude pass-band:\n");
nchka=[nap1l-1,nap1l,nap1l+1,nap1u-1,nap1u,nap1u+1];
printf("nchka=[nap1l-1,nap1l,nap1l+1,nap1u-1,nap1u;nap1u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Middle amplitude stop-band:\n");
nchka=[nas2l-1,nas2l,nas2l+1,nas2u-1,nas2u,nas2u+1];
printf("nchka=[nas2l-1,nas2l,nas2l+1,nas2u-1,nas2u;nas2u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Upper amplitude pass-band:\n");
nchka=[nap2l-1,nap2l,nap2l+1,nap2u-1,nap2u,nap2u+1];
printf("nchka=[nap2l-1,nap2l,nap2l+1,nap2u-1,nap2u;nap2u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Upper amplitude stop-band:\n");
nchka=[nas3l-1,nas3l,nas3l+1];
printf("nchka=[nas3u-1,nas3u,nas3u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Group delay constraints
ntp1l=floor(npoints*ftp1l/0.5);
ntp1u=ceil(npoints*ftp1u/0.5);
ntp2l=floor(npoints*ftp2l/0.5);
ntp2u=ceil(npoints*ftp2u/0.5);
wt=[(ntp1l:ntp1u),(ntp2l:ntp2u)]'*pi/npoints;
Td=[tp1*ones(ntp1u-ntp1l+1,1);tp2*ones(ntp2u-ntp2l+1,1)];
Tdu=[(tp1+(tpr1/2))*ones(ntp1u-ntp1l+1,1);(tp2+(tpr2/2))*ones(ntp2u-ntp2l+1,1)];
Tdl=[(tp1-(tpr1/2))*ones(ntp1u-ntp1l+1,1);(tp2-(tpr2/2))*ones(ntp2u-ntp2l+1,1)];
Wt=[Wtp1*ones(ntp1u-ntp1l+1,1);Wtp2*ones(ntp2u-ntp2l+1,1)];

% Phase constraints
wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% dAsqdw constraints
wd=[];Dd=[];Ddu=[];Ddl=[];Wd=[];

% Sanity checks
printf("Lower delay pass-band:\n");
nchkt=[1,2,ntp1u-ntp1l,ntp1u-ntp1l+1];
printf("nchkt=[1,2,ntp1u-ntp1l,ntp1u-ntp1l+1];\n");
printf("wt(nchkt)*0.5/pi=[");printf("%6.4g ",wt(nchkt)*0.5/pi');printf("];\n");
printf("Td(nchkt)=[ ");printf("%6.4g ",Td(nchkt)');printf("];\n");
printf("Tdu(nchkt)=[ ");printf("%6.4g ",Tdu(nchkt)');printf("];\n");
printf("Tdl(nchkt)=[ ");printf("%6.4g ",Tdl(nchkt)');printf("];\n");
printf("Wt(nchkt)=[ ");printf("%6.4g ",Wt(nchkt)');printf("];\n");
printf("Upper delay pass-band:\n");
nchkt=[ntp1u-ntp1l+2,ntp1u-ntp1l+3, ...
       ntp1u-ntp1l+1+ntp2u-ntp2l,ntp1u-ntp1l+1+ntp2u-ntp2l+1];
printf("nchkt=[ntp1u-ntp1l+2,ntp1u-ntp1l+3, ...\n\
       ntp1u-ntp1l+1+ntp2u-ntp2l,ntp1u-ntp1l+1+ntp2u-ntp2l+1];");
printf("wt(nchkt)*0.5/pi=[");printf("%6.4g ",wt(nchkt)*0.5/pi');printf("];\n");
printf("Td(nchkt)=[ ");printf("%6.4g ",Td(nchkt)');printf("];\n");
printf("Tdu(nchkt)=[ ");printf("%6.4g ",Tdu(nchkt)');printf("];\n");
printf("Tdl(nchkt)=[ ");printf("%6.4g ",Tdl(nchkt)');printf("];\n");
printf("Wt(nchkt)=[ ");printf("%6.4g ",Wt(nchkt)');printf("];\n");

% Linear constraints
dmax=inf;
k0=[A1k0(:);A2k0(:)];
rho=255/256;
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

%
% SOCP MMSE pass
%
[A1kmmse,A2kmmse,socp_iter,func_iter,feasible] = ...
  schurOneMPAlattice_socp_mmse([],A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                               difference,k_u,k_l,k_active,dmax, ...
                               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                               wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                               maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("A1k,A2k(mmse) infeasible");
endif

%
% Plot MMSE result
%
Asq=schurOneMPAlatticeAsq(w,A1kmmse,A1epsilon0,A1p0,A2kmmse,A2epsilon0,A2p0, ...
                          difference);
T=schurOneMPAlatticeT(w,A1kmmse,A1epsilon0,A1p0,A2kmmse,A2epsilon0,A2p0, ...
                      difference);
subplot(211)
plot(w*0.5/pi,10*log10(Asq))
axis([0 0.5 -50 1])
ylabel("Amplitude(dB)");
grid("on");
subplot(212)
plot(w*0.5/pi,T)
axis([0 0.5 0 40])
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse"),"-dpdflatex");
close

%
% SOCP PCLS pass
%
[A1k,A2k,slb_iter,socp_iter,func_iter,feasible] = ...
schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                       A1kmmse,A1epsilon0,A1p0,A2kmmse,A2epsilon0,A2p0, ...
                       difference,k_u,k_l,k_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                       maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("A1k,A2k(pcls) infeasible");
endif

% Recalculate A1epsilon, A1p, A2epsilon and A2p
[A1epsilon,A1p]=schurOneMscale(A1k);
[A2epsilon,A2p]=schurOneMscale(A2k);
A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';
[A2epsilon,A2p]=schurOneMscale(A2k);
A2k=A2k(:)';A2epsilon=A2epsilon(:)';A2p=A2p(:)';

%
% Plot PCLS result
%
Asq=schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T=schurOneMPAlatticeT(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
subplot(211)
plot(w*0.5/pi,10*log10(Asq))
axis([0 0.5 -40 1])
ylabel("Amplitude(dB)");
grid("on");
subplot(212)
plot(w(10:end)*0.5/pi,T(10:end))
axis([0 0.5 0 50])
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls"),"-dpdflatex");
close
% Passband
subplot(211)
plot(w*0.5/pi,10*log10(Asq))
axis([0 0.5 -1.5 0.5])
ylabel("Amplitude(dB)");
grid("on");
subplot(212)
ax=plotyy(w(1+(ntp1l:ntp1u))*0.5/pi,T(1+(ntp1l:ntp1u)), ...
          w(1+(ntp2l:ntp2u))*0.5/pi,T(1+(ntp2l:ntp2u)));
axis(ax(1),[0 0.5 tp1-tpr1 tp1+tpr1]);
axis(ax(2),[0 0.5 tp2-tpr2 tp2+tpr2]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_pass"),"-dpdflatex");
close

% Check transfer function
A1d=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
A2d=schurOneMAPlattice2tf(A2k,A2epsilon,A2p);
[N2,D2]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  error("max(abs((abs(HH).^2)-Asq))(%g*eps) > 1000*eps",
        max(abs((abs(HH).^2)-Asq))/eps);
endif

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"nplot=%d %% Frequency points plotted across the band\n",nplot);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"ma=%d %% Order of the first all-pass filter\n",length(Da0)-1);
fprintf(fid,"mb=%d %% Order of the second all-pass filter\n",length(Db0)-1);
fprintf(fid,"fas1u=%g %% Amplitude stop band 1 upper edge\n",fas1u);
fprintf(fid,"fap1l=%g %% Amplitude pass band 1 lower edge\n",fap1l);
fprintf(fid,"fap1u=%g %% Amplitude pass band 1 upper edge\n",fap1u);
fprintf(fid,"fas2l=%g %% Amplitude stop band 2 lower edge\n",fas2l);
fprintf(fid,"fas2u=%g %% Amplitude stop band 2 upper edge\n",fas2u);
fprintf(fid,"fap2l=%g %% Amplitude pass band 2 lower edge\n",fap2l);
fprintf(fid,"fap2u=%g %% Amplitude pass band 2 upper edge\n",fap2u);
fprintf(fid,"fas3l=%g %% Amplitude stop band 3 lower edge\n",fas3l);
fprintf(fid,"dBas1=%g %% Amplitude stop band 1 attenuation\n",dBas1);
fprintf(fid,"dBap1=%g %% Amplitude pass band 1 peak-to-peak ripple\n",dBap1);
fprintf(fid,"dBas2=%g %% Amplitude stop band 2 attenuation\n",dBas2);
fprintf(fid,"dBap2=%g %% Amplitude pass band 2 peak-to-peak ripple\n",dBap2);
fprintf(fid,"dBas3=%g %% Amplitude stop band 3 attenuation\n",dBas3);
fprintf(fid,"Was1=%g %% Amplitude stop band 1 weight\n",Was1);
fprintf(fid,"Wap1=%g %% Amplitude pass band 1 weight\n",Wap1);
fprintf(fid,"Was2=%g %% Amplitude stop band 2 weight\n",Was2);
fprintf(fid,"Wap2=%g %% Amplitude pass band 2 weight\n",Wap2);
fprintf(fid,"Was3=%g %% Amplitude stop band 3 weight\n",Was3);
fprintf(fid,"ftp1l=%g %% Delay pass band 1 lower edge\n",ftp1l);
fprintf(fid,"ftp1u=%g %% Delay pass band 1 upper edge\n",ftp1u);
fprintf(fid,"ftp2l=%g %% Delay pass band 2 lower edge\n",ftp2l);
fprintf(fid,"ftp2u=%g %% Delay pass band 2 upper edge\n",ftp2u);
fprintf(fid,"tp1=%g %% Nominal pass band 1 filter group delay\n",tp1);
fprintf(fid,"tp2=%g %% Nominal pass band 2 filter group delay\n",tp2);
fprintf(fid,"tpr1=%g %% Delay pass band 1 peak-to-peak ripple\n",tpr1);
fprintf(fid,"tpr2=%g %% Delay pass band 2 peak-to-peak ripple\n",tpr2);
fprintf(fid,"Wtp1=%g %% Delay pass band 1 weight\n",Wtp1);
fprintf(fid,"Wtp2=%g %% Delay pass band 2 weight\n",Wtp2);
fclose(fid);

% Save results
print_polynomial(A1k0,"A1k0");
print_polynomial(A1k0,"A1k0",strcat(strf,"_A1k0_coef.m"));
print_polynomial(A1epsilon0,"A1epsilon0","%2d");
print_polynomial(A1epsilon0,"A1epsilon0", ...
                 strcat(strf,"_A1epsilon0_coef.m"),"%2d");
print_polynomial(A2k0,"A2k0");
print_polynomial(A2k0,"A2k0",strcat(strf,"_A2k0_coef.m"));
print_polynomial(A2epsilon0,"A2epsilon0","%2d");
print_polynomial(A2epsilon0,"A2epsilon0", ...
                 strcat(strf,"_A2epsilon0_coef.m"),"%2d");
print_polynomial(A1kmmse,"A1kmmse");
print_polynomial(A1kmmse,"A1kmmse",strcat(strf,"_A1kmmse_coef.m"));
print_polynomial(A2kmmse,"A2kmmse");
print_polynomial(A2kmmse,"A2kmmse",strcat(strf,"_A2kmmse_coef.m"));
print_polynomial(A1k,"A1k");
print_polynomial(A1k,"A1k",strcat(strf,"_A1k_coef.m"));
print_polynomial(A2k,"A2k");
print_polynomial(A2k,"A2k",strcat(strf,"_A2k_coef.m"));
print_polynomial(A1epsilon,"A1epsilon","%2d");
print_polynomial(A1epsilon,"A1epsilon",strcat(strf,"_A1epsilon_coef.m"),"%2d");
print_polynomial(A2epsilon,"A2epsilon","%2d");
print_polynomial(A2epsilon,"A2epsilon",strcat(strf,"_A2epsilon_coef.m"),"%2d");
print_polynomial(A1p,"A1p");
print_polynomial(A1p,"A1p",strcat(strf,"_A1p_coef.m"));
print_polynomial(A2p,"A2p");
print_polynomial(A2p,"A2p",strcat(strf,"_A2p_coef.m"));

print_polynomial(A1d,"A1d");
print_polynomial(A1d,"A1d",strcat(strf,"_A1d_coef.m"));
print_polynomial(A2d,"A2d");
print_polynomial(A2d,"A2d",strcat(strf,"_A2d_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf("save %s.mat \
ftol ctol maxiter verbose nplot npoints dmax rho \
fas1u fap1l fap1u fas2l fas2u fap2l fap2u fas3l \
dBas1 dBap1 dBas2 dBap2 dBas3 Was1 Wap1 Was2 Wap2 Was3 \
ftp1l ftp1u ftp2l ftp2u tp1 tpr1 tp2 tpr2 Wtp1 Wtp2 \
A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 A1kmmse A2kmmse \
A1k A1epsilon A1p A2k A2epsilon A2p A1d A2d N2 D2",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
