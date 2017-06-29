% deczky3_socp_bfgs_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("deczky3_socp_bfgs_test.diary");
unlink("deczky3_socp_bfgs_test.diary.tmp");
diary deczky3_socp_bfgs_test.diary.tmp

format compact

tol=1e-6
maxiter=2000
verbose=false

%
% Deczky3 Lowpass filter specification
%

% Filter specifications
U=0,V=0,Q=6,M=10,R=1
fap=0.15,dBap=0.1,Wap=1
fas=0.3,dBas=40,Was=10
ftp=0.25,tp=10,tpr=0.08,Wtp=0.2

% Initial coefficients
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x0=[K,abs(z),angle(z),abs(p),angle(p)]';

% Frequency points
n=1000;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Ad=[ones(nap,1); zeros(n-nap,1)];
Adu=[ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Stop-band amplitude constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+((tpr-tol)/2))*ones(ntp,1);
Tdl=(tp-((tpr-tol)/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

%
% MMSE pass
%
start_time=time();
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_socp_bfgs([],x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,tol,verbose);
if feasible == 0 
  error("x1(MMSE-BFGS) infeasible");
endif
strF=sprintf("deczky3_socp_bfgs_test_%%s");
strM=sprintf("Deczky Ex.3(MMSE-SOCP-BFGS):\
fap=%g,Wap=%g,fas=%g,Was=%g,ftp=%g,tp=%g,Wtp=%g",fap,Wap,fas,Was,ftp,tp,Wtp);
showResponse(x1,U,V,M,Q,R,strM);
print(sprintf(strF,"mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,x1,U,V,M,Q,R,strM);
print(sprintf(strF,"mmse_x1pass"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM);
print(sprintf(strF,"mmse_x1pz"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass:\n");
[d2,E,slb_iter,socp_iter,func_iter,feasible] = ...
  iir_slb(@iir_socp_bfgs,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol,verbose);
if feasible == 0 
  error("d2 (PCLS-BFGS) infeasible");
endif
printf("Deczky Ex.3 lowpass d2 (PCLS-SOCP-BFGS) feasible after %d seconds!\n",
       time()-start_time);
strP=sprintf("Deczky Ex.3(PCLS-BFGS):fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,\
Was=%g,ftp=%g,tp=%g,tpr=%g,Wtp=%g",fap,dBap,Wap,fas,dBas,Was,ftp,tp,tpr,Wtp);
showResponse(d2,U,V,M,Q,R,strP);
print(sprintf(strF,"pcls_d2"),"-dpdflatex");
close
showResponsePassBands(0,ftp,-2*dBap,dBap,d2,U,V,M,Q,R,strP);
print(sprintf(strF,"pcls_d2pass"),"-dpdflatex");
close
showZPplot(d2,U,V,M,Q,R,strP);
print(sprintf(strF,"pcls_d2pz"),"-dpdflatex");
close

%
% Final amplitude and delay at constraints
%
A=iirA(wa,d2,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa(nap);wa(nas)]);
AS=iirA(wAS,d2,U,V,M,Q,R);
printf("d2:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d2:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");
T=iirT(wt,d2,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt(ntp)]);
TS=iirT(wTS,d2,U,V,M,Q,R);
printf("d2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

%
% Save results
%
fid=fopen("deczky3_socp_bfgs_test.spec","wt");
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"tp=%d %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude weight\n",Was);
fclose(fid);

print_pole_zero(d2,U,V,M,Q,R,"d2");
print_pole_zero(d2,U,V,M,Q,R,"d2","deczky3_socp_bfgs_test_d2_coef.m");

[N2,D2]=x2tf(d2,U,V,M,Q,R);
print_polynomial(N2,"N2");
print_polynomial(N2,"N2","deczky3_socp_bfgs_test_N2_coef.m");
print_polynomial(D2,"D2");
print_polynomial(D2,"D2","deczky3_socp_bfgs_test_D2_coef.m");

save deczky3_socp_bfgs_test.mat U V M Q R x0 ...
     n tol maxiter fap dBap Wap fas dBas Was ftp tp tpr Wtp x1 d2 N2 D2

%
% Done
%
diary off
movefile deczky3_socp_bfgs_test.diary.tmp deczky3_socp_bfgs_test.diary;
