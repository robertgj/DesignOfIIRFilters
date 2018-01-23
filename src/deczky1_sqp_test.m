% deczky1_sqp_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("deczky1_sqp_test.diary");
unlink("deczky1_sqp_test.diary.tmp");
diary deczky1_sqp_test.diary.tmp

tic;

format compact

tol=2e-4
ctol=tol
maxiter=2000
verbose=false

% Initial filter from tarczynski_deczky1_test.m
% Filter specifications
if 1
  fap=0.25,fas=0.3,ftp=0.25
  dBap=1,dBas=41,tp=9,tpr=1
  Wap=1,Wat=0.02,Was=50,Wtp=0.02
  U=2,V=0,M=10,Q=6,R=1
  x0 = [  0.0089246099, ...
         -1.6983334070,  -1.4198229400, ...
          1.6379644123,   1.5738900106,   0.9774087047,   0.9048931379, ... 
          0.8170264595, ...
          0.3421146572,   1.0333529676,   1.9056293108,   2.0813761609, ... 
          2.4705991917, ...
          0.9322535650,   0.6589433156,   0.4371466775, ...
          1.7291383648,   1.4944539264,   0.5877826891 ]';
else
  fap=0.25,fas=0.3,ftp=0.25
  dBap=0.7,dBas=36,tp=10,tpr=0.6
  Wap=1,Wat=0.01,Was=3,Wtp=0.02
  U=2,V=0,M=10,Q=12,R=1
  x0 = [  0.0096307241, ...
         -2.0108044299,  -0.8522348083, ...
         -0.8094940215,   0.6367473364, ...
          1.6317494473,   1.5705628412,   0.9688395358,   1.0519109568, ... 
          0.8439736013, ...
          0.3413540938,   1.0315258727,   1.9178149472,   2.3946818875, ... 
          2.2364571431, ...
          0.9596658981,   0.9418758118,   0.7709161721,   0.6644064469, ... 
          0.6372961041, ...
          2.3796201153,   1.6886079109,   1.4416816983,   1.0214511556, ... 
          0.5418324312 ]';
endif

% Strings
strM=sprintf("%%s:fap=%g,Wap=%g,fas=%g,Was=%g,ftp=%g,tp=%g,Wtp=%g",
             fap,Wap,fas,Was,ftp,tp,Wtp);
strP=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,ftp=%g,tp=%g,\
tpr=%g,Wtp=%g",fap,dBap,Wap,fas,dBas,Was,ftp,tp,tpr,Wtp);
strf="deczky1_sqp_test";

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
strt=sprintf("Initial Deczky Ex. 1 : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
showResponse(x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strt)
print(strcat(strf,"_initial_x0pz"),"-dpdflatex");
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
strt=sprintf(strM,"x1(mmse)");
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
close

% PCLS pass 1
printf("\nPCLS pass 1:\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt, ...
          wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
strt=sprintf(strP,"d1(pcls)");
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close
showResponse(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(0,max(ftp,fap),-2*dBap,dBap,d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
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
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
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
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

save deczky1_sqp_test.mat U V M Q R ...
     tol ctol fap dBap Wap fas dBas Was ftp tp tpr Wtp x0 x1 d1

% Done
toc
diary off
movefile deczky1_sqp_test.diary.tmp deczky1_sqp_test.diary;
