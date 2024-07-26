% deczky3_piqp_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

pkg load piqp;

strf="deczky3_piqp_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

start=tic();

ftol=1e-3;
ctol=ftol/10;
maxiter=250;
verbose=false;

% Deczky3 Lowpass filter specification

% Filter specifications
U=0,V=0,Q=6,M=10,R=1
fap=0.15,dBap=0.2,Wap=1
fas=0.3,dBas=31,Was=1
ftp=0.25,tp=10,tpr=0.01,Wtp_mmse=0.5,Wtp_pcls=4

% Initial coefficients
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x0=[K,abs(z),angle(z),abs(p),angle(p)]';

% Frequency points
n=1000;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=ceil(n*fap/0.5)+1;
wa=w(1:nap);
Ad=ones(size(wa));
Adu=ones(size(wa));
Adl=(10^(-dBap/20))*ones(size(wa));
Wa=Wap*ones(size(wa));

% Stop-band amplitude constraints
nas=floor(n*fas/0.5)+1;
ws=w(nas:end);
Sd=zeros(size(ws));
Sdu=(10^(-dBas/20))*ones(size(ws));
Sdl=zeros(size(ws));
Ws=Was*ones(size(ws));

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=w(1:ntp);
Td=tp*ones(size(wt));
Tdu=(tp+(tpr/2))*ones(size(wt));
Tdl=(tp-(tpr/2))*ones(size(wt));
Wt_mmse=Wtp_mmse*ones(size(wt));
Wt_pcls=Wtp_pcls*ones(size(wt));

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Coefficient constraints
dmax=0.02;
[xl,xu]=xConstraints(U,V,M,Q);

% Initial response
strt=sprintf("Initial Deczky Ex. 3 : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
showResponse(x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strt)
print(strcat(strf,"_initial_x0pz"),"-dpdflatex");
close

% MMSE pass
printf("\nMMSE pass:\n");
[x1,E,piqp_iter,func_iter,feasible] = ...
  iir_piqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt_mmse,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("x1(mmse) infeasible");
endif

strt=sprintf("x1(mmse):fap=%g,Wap=%g,fas=%g,Was=%g,ftp=%g,tp=%g,Wtp\\_mmse=%g",
             fap,Wap,fas,Was,ftp,tp,Wtp_mmse);
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
close

% PCLS pass
printf("\nPCLS pass 1:\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_piqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt_pcls, ...
          wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("d1 (pcls) infeasible");
endif

strt=sprintf("d1(pcls):fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g,ftp=%g,tp=%g,\
tpr=%g,Wtp\\_pcls=%g",fap,dBap,Wap,fas,dBas,Was,ftp,tp,tpr,Wtp_pcls);
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
wAS=unique([wa(vAl);wa(vAu);wa(1);wa(end)]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

S=iirA(ws,d1,U,V,M,Q,R);
vSl=local_max(Sdl-S);
vSu=local_max(S-Sdu);
wSS=unique([ws(vSl);ws(vSu);ws(1);ws(end)]);
SS=iirA(wSS,d1,U,V,M,Q,R);
printf("d1:fSS=[ ");printf("%f ",wSS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:SS=[ ");printf("%f ",20*log10(SS'));printf(" ] (dB)\n");

T=iirT(wt,d1,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt(1);wt(end)]);
TS=iirT(wTS,d1,U,V,M,Q,R);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

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
fprintf(fid,"Wtp_mmse=%g %% Pass band group delay weight(MMSE pass)\n",Wtp_mmse);
fprintf(fid,"Wtp_pcls=%g %% Pass band group delay weight(PCLS pass)\n",Wtp_pcls);
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

eval(sprintf("save %s.mat U V M Q R ftol ctol fap dBap Wap fas dBas Was \
ftp tp tpr Wtp_mmse Wtp_pcls x1 d1",strf));

% Done
toc(start);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
