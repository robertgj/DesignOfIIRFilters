% decimator_R2_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Example of low-pass IIR decimator filter design using quasi-Newton
% optimisation with constraints on the coefficients.

test_common;

strf="decimator_R2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
ftol_wise=1e-7
ftol_mmse=1e-5
ftol_pcls=1e-4
ctol=1e-5
maxiter=10000

% Filter specifications (frequencies are normalised to the sample rate)
U=0,V=0,M=10,Q=6,R=2
fap=0.10,dBap=0.2,Wap=2
fas=0.25,dBas=40,Was=1
ftp=0.125,tp=8,tpr=0.008,Wtp=1
  
% Initial filter guess
xi=[0.0001, [1,1,1,1,1], (8:12)*pi/12, 0.7*[1,1,1], (1:3)*pi/8]';

% Frequency points
n=1000;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);
dmax=0.05;

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Ad=[1./sinc(wa(1:nap)/2);zeros(n-nap,1)];
Adu=[(10^(dBap/40))*Ad(1:nap); ...
     (10^(dBap/40))*Ad(nap)*ones(nas-nap-1,1); ...
     (10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/40))*Ad(1:nap);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Stop-band amplitude response constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase response constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Initialise strings
strM=sprintf("%%s:fap=%g,fas=%g,Was=%%g,ftp=%g,tp=%g,Wtp=%%g",...
             fap,fas,ftp,tp);
strP=sprintf(["%%s:fap=%g,dBap=%%g,fas=%g,dBas=%%g,Was=%%g,", ...
 "ftp=%g,tp=%g,tpr=%%g,Wtp=%%g"],fap,fas,ftp,tp);

% Initial filter
[x0,Ex0]=xInitHd(xi,U,V,M,Q,R, ...
                 wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,maxiter,ftol_wise);
printf("x0=[ ");printf("%f ",x0');printf("]'\n");
strMI=sprintf("Initial decimator R=2 : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
showResponse(x0,U,V,M,Q,R,strMI);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x0,U,V,M,Q,R,strMI);
print(strcat(strf,"_initial_x0pass"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strMI)
print(strcat(strf,"_initial_x0pz"),"-dpdflatex");
close

% MMSE pass
printf("\nFinding MMSE x1, Wap=%f,Was=%f,Wtp=%f\n", Wap, Was, Wtp);
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol_mmse,ftol_mmse,verbose);
if feasible == 0 
  error("R=2 decimator x1 infeasible");
endif
printf("x1=[ ");printf("%f ",x1');printf("]'\n");
strM1=sprintf(strM,"x1",Was,Wtp);
showResponse(x1,U,V,M,Q,R,strM1);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-0.5,1.5,x1,U,V,M,Q,R,strM1);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM1)
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close

% PCLS pass 1
printf("\nFinding PCLS d1, dBap=%f,Wap=%f,dBas=%f,Was=%f,tpr=%f,Wtp=%f\n", 
       dBap, Wap, dBas, Was, tpr, Wtp);
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,ftol_pcls,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
  
strP1=sprintf(strP,"d1",dBap,dBas,Was,tpr,Wtp);
showResponse(d1,U,V,M,Q,R,strP1);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-0.5,1.5,d1,U,V,M,Q,R,strP1);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strP1);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

%
% PCLS amplitude and delay at local peaks
%
A=iirA(wa,d1,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");
T=iirT(wt,d1,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=iirT(wTS,d1,U,V,M,Q,R);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol_wise=%g %% Tolerance on WISE relative coef. update\n", ...
        ftol_wise);
fprintf(fid,"ftol_mmse=%g %% Tolerance on MMSE relative coef. update\n", ...
        ftol_mmse);
fprintf(fid,"ftol_pcls=%g %% Tolerance on PCLS relative coef. update\n", ...
        ftol_pcls);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"tp=%d %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude weight\n",Was);
fclose(fid);

print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

eval(sprintf(["save %s.mat n U V M Q R fap fas ftp tp dBap dBas tpr ", ...
 "Wap Was Wtp x0 x1 d1 ftol_wise ftol_mmse ftol_pcls ctol"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
