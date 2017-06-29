% deczky1_sqp_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("deczky1_sqp_test.diary");
unlink("deczky1_sqp_test.diary.tmp");
diary deczky1_sqp_test.diary.tmp

tic;

format compact

tol=2e-4
maxiter=2000
verbose=false


% Initial filter from tarczynski_deczky1_test.m
% Filter specifications
if 1
  fap=0.25,fas=0.3,ftp=0.25
  dBap=1,dBas=41,tp=9,tpr=1
  Wap=1,Wat=0.02,Was=50,Wtp=0.02
  U=2,V=0,M=10,Q=6,R=1
  x0 = [  0.0071968380, ...
         -2.8900839505,  -0.7825776503, ...
          1.6549787486,   1.5863117167,   0.9784331065,   0.9083105649, ... 
          0.8256166387, ...
          0.3430728023,   1.0362484707,   1.9073345090,   2.0951469038, ... 
          2.5122435368, ...
          0.9305833024,   0.6582614719,   0.4493947026, ...
          1.7258740760,   1.4754529602,   0.5764693828 ]';
else
  fap=0.25,fas=0.3,ftp=0.25
  dBap=0.7,dBas=36,tp=10,tpr=0.6
  Wap=1,Wat=0.01,Was=3,Wtp=0.02
  U=2,V=0,M=10,Q=12,R=1
  x0 = [ -0.0123356931, ...
          1.6637877187,  -0.7007850981, ...
          1.6378050656,   1.5447513803,   0.9591048321,   0.8145418689, ... 
          0.9287362063, ...
          0.5772288941,   1.1623261417,   1.9385840773,   2.2563057256, ... 
          2.7266182428, ...
          0.9123080546,   0.9300103221,   0.7713370513,   0.6698730111, ... 
          0.6104307357,   0.6226069860, ...
          2.7350042345,   1.6916837999,   1.4752704000,   1.1038431151, ... 
          0.2355046508,   0.6888642095 ]';
endif

% Strings
strM=sprintf("%%s:fap=%g,Wap=%g,fas=%g,Was=%g,ftp=%g,tp=%g,Wtp=%g",
             fap,Wap,fas,Was,ftp,tp,Wtp);
strP=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,ftp=%g,tp=%g,\
tpr=%g,Wtp=%g",fap,dBap,Wap,fas,dBas,Was,ftp,tp,tpr,Wtp);

% Frequency points
n=200;

% Coefficient constraints
dmax=0.1;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Ad=[ones(nap,1); zeros(n-nap,1)];
Adu=[ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

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

% Initial response
strd=sprintf("deczky1_sqp_initial_%%s");
strM0=sprintf("Initial Deczky Ex. 1 : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
showResponse(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"x0"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strM0)
print(sprintf(strd,"x0pz"),"-dpdflatex");
close

% MMSE pass 1
printf("\nMMSE pass 1:\n");
vS=iir_slb_set_empty_constraints();
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse(vS, ...
               x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol,verbose)
if feasible == 0 
  error("x1(mmse) infeasible");
endif
strd=sprintf("deczky1_sqp_mmse_%%s");
strM1=sprintf(strM,"x1(mmse)");
showZPplot(x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1pass"),"-dpdflatex");
close

% PCLS pass 1
printf("\nPCLS pass 1:\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt, ...
          wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
strd=sprintf("deczky1_sqp_pcls_%%s");
strP1=sprintf(strP,"d1(pcls)");
showZPplot(d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"d1pz"),"-dpdflatex");
close
showResponse(d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"d1"),"-dpdflatex");
close
showResponsePassBands(0,max(ftp,fap),-2*dBap,dBap,d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"d1pass"),"-dpdflatex");
close

% Final amplitude and delay at constraints
A=iirA(wa,d1,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa(nap);wa(nas)]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");
T=iirT(wt,d1,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt(ntp)]);
TS=iirT(wTS,d1,U,V,M,Q,R);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Save results
fid=fopen("deczky1_sqp_test.spec","wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"Wat=%g %% Transition band weight\n",Wat);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"tp=%d %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude weight\n",Was);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1","deczky1_sqp_test_d1_coef.m");
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1","deczky1_sqp_test_N1_coef.m");
print_polynomial(D1,"D1");
print_polynomial(D1,"D1","deczky1_sqp_test_D1_coef.m");

save deczky1_sqp_test.mat U V M Q R ...
     fap dBap Wap fas dBas Was ftp tp tpr Wtp x0 x1 d1

% Done
toc
diary off
movefile deczky1_sqp_test.diary.tmp deczky1_sqp_test.diary;
