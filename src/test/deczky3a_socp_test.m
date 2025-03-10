% deczky3a_socp_test.m

% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="deczky3a_socp_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=2e-5
ctol=ftol
verbose=false

% Deczky3 Lowpass filter specification
U=0,V=0,Q=6,M=10,R=1
fap=0.15,dBap=0.2,Wap=1
fas=0.3,dBas=50,Was=2
ftp=0.25,tp=10,tpr=0.8,Wtp=0.1

% Deczky example 3 initial coefficients
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x0=[K,abs(z),angle(z),abs(p),angle(p)]';

% Frequency vectors
n=500;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude pass-band constraints
nap=ceil(n*fap/0.5)+1;
wa=(0:(nap-1))'*pi/n;
Ad=ones(nap,1);
Adu=ones(nap,1);
Adl=(10^(-dBap/20))*ones(nap,1);
Wa=Wap*ones(nap,1);

% Amplitude stop-band constraints
nas=floor(n*fas/0.5);
ws=(nas:(n-1))'*pi/n;
Sd=zeros(n-nas,1);
Sdu=(10^(-dBas/20))*ones(n-nas,1);
Sdl=zeros(n-nas,1); 
Ws=Was*ones(n-nas,1);

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Common strings for output plots
strM=sprintf("%%s:fap=%g,Wap=%%g,fas=%g,Was=%%g,tp=%g,Wtp=%%g",fap,fas,tp);
strP=sprintf(["%%s:fap=%g,dBap=%g,Wap=%%g,fas=%g,dBas=%g,Was=%%g,tp=%g,", ...
 "tpr=%%g"],fap,dBap,fas,dBas,tp);

% SOCP MMSE
[x1,E,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse([],x0,xu,xl,inf,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("x1(mmse) infeasible");
endif
strt=sprintf(strM,"x1(mmse)",Wap,Was,Wtp);
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
close

% SOCP PCLS 
[d2,E,slb_iter,socp_iter,func_iter,feasible]= ...
  iir_slb(@iir_socp_mmse,x1,xu,xl,inf,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("d2(pcls) infeasible");
endif
strt=sprintf(strP,"d2(pcls)",Wap,Was,tpr);
showZPplot(d2,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d2pz"),"-dpdflatex");
close
showResponse(d2,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d2"),"-dpdflatex");
close
showResponsePassBands(0,max(ftp,fap),-2*dBap,dBap,d2,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d2pass"),"-dpdflatex");
close

% Final amplitude and delay at constraints
A=iirA(wa,d2,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
S=iirA(ws,d2,U,V,M,Q,R);
vSl=local_max(Sdl-S);
vSu=local_max(S-Sdu);
wAS=unique([wa(vAl);wa(vAu);ws(vSl);ws(vSu)]);
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

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol=%g %% Tolerance on relative coefficient update size\n",ftol);
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
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);

[N2,D2]=x2tf(d2,U,V,M,Q,R);
print_pole_zero(d2,U,V,M,Q,R,"d2",strcat(strf,"_d2_coef.m"));
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));
if verbose
  print_pole_zero(d2,U,V,M,Q,R,"d2");
  print_polynomial(N2,"N2");
  print_polynomial(D2,"D2");
endif

eval(sprintf(["save %s.mat U V M Q R ", ...
 "n ftol ctol fap dBap Wap fas dBas Was ftp tp tpr Wtp x1 d2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
