% iir_socp_slb_multiband_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

strf="iir_socp_slb_multiband_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-3;
ctol=1e-3;
maxiter=1000;
verbose=false;
nplot=1000;
npoints=700;

% Desired frequency response specification
fas1u=0.05;
fap1l=0.075;fap1u=0.100;
ftp1l=0.080;ftp1u=0.095;
fas2l=0.125;fas2u=0.150;
fap2l=0.175;fap2u=0.225;
ftp2l=0.185;ftp2u=0.215;
fas3l=0.25;
dBas1=20;dBap1=1;dBas2=dBas1;dBap2=dBap1;dBas3=dBas1;
Was1=1;Wap1=1;Was2=1;Wap2=1;Was3=1;
tp1=20;tpr1=2;tp2=15;tpr2=2;
Wtp1=0.001;Wtp2=0.001;

% Initial elliptic filter with lowpass to double bandpass transformation
n=5;fc=0.25;dBap=0.5;dBas=20;
[b0,a0]=ellip(n,dBap,dBas,2*fc);
phi=[fap1l fap1u fap2l fap2u];
p0=phi2p(phi);
[N0,D0]=tfp2g(b0,a0,p0,-1);

% Convert to gain-zero-pole form
[x0,U,V,M,Q]=tf2x(N0,D0);R=1;

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

Ad=[zeros(nap1l-1,1); ...
    ones(nap1u-nap1l+1,1); ...
    zeros(nap2l-nap1u-1,1); ...
    ones(nap2u-nap2l+1,1); ...
    zeros(npoints-nap2u,1)];
Adu=[(10^(-dBas1/20))*ones(nas1u,1); ...
     ones(nas2l-nas1u-1,1); ...
     (10^(-dBas2/20))*ones(nas2u-nas2l+1,1); ...
     ones(nas3l-nas2u-1,1); ...
     (10^(-dBas3/20))*ones(npoints-nas3l+1,1)];
Adl=[zeros(nap1l-1,1); ...
     (10^(-dBap1/20))*ones(nap1u-nap1l+1,1); ...
     zeros(nap2l-nap1u-1,1); ...
     (10^(-dBap2/20))*ones(nap2u-nap2l+1,1); ...
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
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Lower amplitude pass-band:\n");
nchka=[nap1l-1,nap1l,nap1l+1,nap1u-1,nap1u,nap1u+1];
printf("nchka=[nap1l-1,nap1l,nap1l+1,nap1u-1,nap1u;nap1u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Middle amplitude stop-band:\n");
nchka=[nas2l-1,nas2l,nas2l+1,nas2u-1,nas2u,nas2u+1];
printf("nchka=[nas2l-1,nas2l,nas2l+1,nas2u-1,nas2u;nas2u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Upper amplitude pass-band:\n");
nchka=[nap2l-1,nap2l,nap2l+1,nap2u-1,nap2u,nap2u+1];
printf("nchka=[nap2l-1,nap2l,nap2l+1,nap2u-1,nap2u;nap2u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Upper amplitude stop-band:\n");
nchka=[nas3l-1,nas3l,nas3l+1];
printf("nchka=[nas3u-1,nas3u,nas3u+1];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)*0.5/pi');printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Group delay constraints
ntp1l=floor(npoints*ftp1l/0.5);
ntp1u=ceil(npoints*ftp1u/0.5);
ntp2l=floor(npoints*ftp2l/0.5);
ntp2u=ceil(npoints*ftp2u/0.5);
wt1=(ntp1l:ntp1u)'*pi/npoints;
wt2=(ntp2l:ntp2u)'*pi/npoints;
wt=[wt1;wt2];
Td=[tp1*ones(ntp1u-ntp1l+1,1);tp2*ones(ntp2u-ntp2l+1,1)];
Tdu=[(tp1+(tpr1/2))*ones(ntp1u-ntp1l+1,1);(tp2+(tpr2/2))*ones(ntp2u-ntp2l+1,1)];
Tdl=[(tp1-(tpr1/2))*ones(ntp1u-ntp1l+1,1);(tp2-(tpr2/2))*ones(ntp2u-ntp2l+1,1)];
Wt=[Wtp1*ones(ntp1u-ntp1l+1,1);Wtp2*ones(ntp2u-ntp2l+1,1)];

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
printf(["nchkt=[ntp1u-ntp1l+2,ntp1u-ntp1l+3, ...\n", ...
 "       ntp1u-ntp1l+1+ntp2u-ntp2l,ntp1u-ntp1l+1+ntp2u-ntp2l+1];"]);
printf("wt(nchkt)*0.5/pi=[");printf("%6.4g ",wt(nchkt)*0.5/pi');printf("];\n");
printf("Td(nchkt)=[ ");printf("%6.4g ",Td(nchkt)');printf("];\n");
printf("Tdu(nchkt)=[ ");printf("%6.4g ",Tdu(nchkt)');printf("];\n");
printf("Tdl(nchkt)=[ ");printf("%6.4g ",Tdl(nchkt)');printf("];\n");
printf("Wt(nchkt)=[ ");printf("%6.4g ",Wt(nchkt)');printf("];\n");

% Stop-band constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Linear constraints
dmax=inf;
rho=0.9999;
[xl,xu]=xConstraints(U,V,M,Q,rho);

% Plot initial filter
w=pi*(0:(nplot-1))'/nplot;
A0=iirA(w,x0,U,V,M,Q,R);
T0=iirT(w(10:end),x0,U,V,M,Q,R);
subplot(211)
plot(w*0.5/pi,20*log10(A0))
axis([0 0.5 -40 10])
ylabel("Amplitude (dB)");
grid("on");
subplot(212)
plot(w(10:end)*0.5/pi,T0);
axis([0 0.5 0 40]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial"),"-dpdflatex");
close

%
% SOCP MMSE pass
%
[x1,E2,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...
               ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt, ...
               wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("x1 (mmse) infeasible");
else
  printf("x1 (mmse) feasible socp_iter=%d\n",socp_iter);
endif

%
% Plot MMSE result
%
A1=iirA(w,x1,U,V,M,Q,R);
T1=iirT(w(10:end),x1,U,V,M,Q,R);
subplot(211)
plot(w*0.5/pi,20*log10(A1))
axis([0 0.5 -40 1])
ylabel("Amplitude (dB)");
grid("on");
subplot(212)
plot(w(10:end)*0.5/pi,T1);
axis([0 0.5 0 40]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse"),"-dpdflatex");
close

%
% SOCP PCLS pass
%
[x2,E2,slb_iter,opt_iter,func_iter,feasible] = ...
   iir_slb(@iir_socp_mmse,x1,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...
           ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
           maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("x2 (pcls) infeasible");
endif

%
% Plot PCLS result
%
A2=iirA(w,x2,U,V,M,Q,R);
T2=iirT(w(10:end),x2,U,V,M,Q,R);
subplot(211)
plot(w*0.5/pi,20*log10(A2))
axis([0 0.5 -40 10])
ylabel("Amplitude (dB)");
grid("on");
subplot(212)
plot(w(10:end)*0.5/pi,T2);
axis([0 0.5 0 40]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls"),"-dpdflatex");
close
% Passband
subplot(211)
nap1l=floor(nplot*fap1l/0.5);
nap1u=ceil(nplot*fap1u/0.5);
nap2l=floor(nplot*fap2l/0.5);
nap2u=ceil(nplot*fap2u/0.5);
wa1=(nap1l:nap1u)'*pi/nplot;
wa2=(nap2l:nap2u)'*pi/nplot;
A2_1=iirA(wa1,x2,U,V,M,Q,R);
A2_2=iirA(wa2,x2,U,V,M,Q,R);
ax=plotyy(wa1*0.5/pi,20*log10(A2_1),wa2*0.5/pi,20*log10(A2_2));
axis(ax(1),[0 0.5 -1 0.2])
axis(ax(2),[0 0.5 -1 0.2])
ylabel("Amplitude (dB)");
grid("on");
subplot(212)
ntp1l=floor(nplot*ftp1l/0.5);
ntp1u=ceil(nplot*ftp1u/0.5);
ntp2l=floor(nplot*ftp2l/0.5);
ntp2u=ceil(nplot*ftp2u/0.5);
wt1=(ntp1l:ntp1u)'*pi/nplot;
wt2=(ntp2l:ntp2u)'*pi/nplot;
T2_1=iirT(wt1,x2,U,V,M,Q,R);
T2_2=iirT(wt2,x2,U,V,M,Q,R);
ax=plotyy(wt1*0.5/pi,T2_1,wt2*0.5/pi,T2_2);
axis(ax(1),[0 0.5 18 22]);
axis(ax(2),[0 0.5 13 17]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_pass"),"-dpdflatex");
close
% Pole-zero plot
[Z2,P2,K2]=x2zp(x2,U,V,M,Q,R);
zplane(Z2,P2);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"nplot=%d %% Frequency points plotted across the band\n",nplot);
if 0
  fprintf(fid,"n=%d %% Elliptic low-pass prototype order\n",n);
  fprintf(fid,"fc=%g %% Elliptic low-pass prototype cut-off frequency\n",fc);
  fprintf(fid,"dBap=%g %% Elliptic low-pass prototype pass-band ripple\n",dBap);
  fprintf(fid,"dBas=%g %% Elliptic low-pass prototype stop-band ripple\n",dBas);
endif
fprintf(fid,"rho=%f %% Constraint on pole radius\n",rho);
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
print_polynomial(N0,"N0","%16.10f");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"),"%16.10f");
print_polynomial(D0,"D0","%16.10f");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"),"%16.10f");
print_pole_zero(x2,U,V,M,Q,R,"x1");
print_pole_zero(x2,U,V,M,Q,R,"x1",strcat(strf,"_x1_coef.m"));
print_pole_zero(x2,U,V,M,Q,R,"x2");
print_pole_zero(x2,U,V,M,Q,R,"x2",strcat(strf,"_x2_coef.m"));

[N2,D2]=x2tf(x2,U,V,M,Q,R);
print_polynomial(N2,"N2","%16.10f");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"),"%16.10f");
print_polynomial(D2,"D2","%16.10f");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"),"%16.10f");

eval(sprintf(["save %s.mat ", ...
 "ftol ctol maxiter verbose nplot npoints dmax rho ", ...
 "fas1u fap1l fap1u fas2l fas2u fap2l fap2u fas3l ", ...
 "dBas1 dBap1 dBas2 dBap2 dBas3 Was1 Wap1 Was2 Wap2 Was3 ", ...
 "ftp1l ftp1u ftp2l ftp2u tp1 tpr1 tp2 tpr2 Wtp1 Wtp2 ", ...
 "x0 U V M Q R x1 x2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
