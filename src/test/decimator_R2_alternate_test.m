% decimator_R2_alternate_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Example of low-pass IIR decimator filter design using quasi-Newton
% optimisation with constraints on the coefficients.

test_common;

strf="decimator_R2_alternate_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
ftol_mmse=1e-5
ftol_pcls=1e-3
ctol=ftol_pcls/100
maxiter=10000

% Filter specifications (frequencies are normalised to the sample rate)
fap=0.10,dBap=0.3,Wap=1
ftp=0.125,tp=10,tpr=0.04,Wtp=0.5
fas=0.25,dBas=43,Was=2

% Initial filter guess
U=0,V=0,M=12,Q=6,R=2
x0=[0.0002, [1,1,1,1,1,1], (7:12)*pi/12, 0.75*[1,1,1], (1:3)*pi/6]';
printf("x0=[ ");printf("%f ",x0');printf("]'\n");

% Plot initial filter
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

% Coefficient constraints
dmax=0.05;
rho=0.999;
[xl,xu]=xConstraints(U,V,M,Q,rho);

% Frequency vector
n=1000;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=ceil(n*fap/0.5)+1;
wa=w(1:nap);
Ad=ones(size(wa));
Adu=ones(size(wa));
Adl=(10^(-dBap/20))*ones(size(wa));
Wa=Wap*ones(size(wa));

% Stop-band amplitude response constraints
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
Wt=Wtp*ones(size(wt));

% Phase response constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% MMSE pass
printf("\nFinding MMSE x1, Wap=%f,Was=%f,Wtp=%f\n", Wap, Was, Wtp);
feasible=false;
try
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol_mmse,ctol,verbose);
catch
end_try_catch
if feasible == 0 
  error("Alternate R=2 decimator x1 (MMSE) infeasible");
endif
printf("x1=[ ");printf("%f ",x1');printf("]'\n");

% Plot MMSE
strM=sprintf("x1(MMSE) : fap=%g,fas=%g,Was=%g,ftp=%g,tp=%g,Wtp=%g", ...
             fap,fas,Was,ftp,tp,Wtp);
showResponse(x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-0.4,0.2,x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM)
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close

% PCLS pass 1
printf("\nFinding PCLS d1, dBap=%f,Wap=%f,dBas=%f,Was=%f,tpr=%f,Wtp=%f\n", 
       dBap, Wap, dBas, Was, tpr, Wtp);
feasible=false;
try
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,ftol_pcls,ctol,verbose);
catch
end_try_catch
if feasible == 0 
  error("Alternate R=2 decimator d1 (PCLS) infeasible");
endif
printf("d1=[ ");printf("%f ",d1');printf("]'\n");

%
% PCLS amplitude and delay at local peaks
%
A=iirA(wa,d1,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nap,end])]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

S=iirA(ws,d1,U,V,M,Q,R);
vSl=local_max(Sdl-S);
vSu=local_max(S-Sdu);
wSS=unique([ws(vSl);ws(vSu);ws([1,end])]);
SS=iirA(wSS,d1,U,V,M,Q,R);
printf("d1:fSS=[ ");printf("%f ",wSS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:SS=[ ");printf("%f ",20*log10(SS'));printf(" ] (dB)\n");

T=iirT(wt,d1,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=iirT(wTS,d1,U,V,M,Q,R);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Plot PCLS
strP=sprintf(["d1(PCLS) : fap=%g,dBap=%g,fas=%g,dBas=%g,Was=%g,", ...
 "ftp=%g,tp=%g,tpr=%g,Wtp=%g"],fap,dBap,fas,dBas,Was,ftp,tp,tpr,Wtp);
showResponse(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-0.4,0.2,d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

% Additional plot
subplot(211);
A=iirA(w,d1,U,V,M,Q,R);
ax=plotyy(w*0.5/pi,20*log10(A),w*0.5/pi,20*log10(A));
axis(ax(1),[0 0.5 -0.4 0.1]);
axis(ax(2),[0 0.5 -65 -40]);
ylabel("Amplitude(dB)");
grid("on");
tstr=sprintf(["R=2 decimator alt. response : ", ...
 "fap=%g,dBap=%g,fas=%g,dBas=%d,tp=%d,tpr=%g"],fap,dBap,fas,dBas,tp,tpr);
title(tstr);
subplot(212);
T=iirT(wt,d1,U,V,M,Q,R);
plot(wt*0.5/pi,T)
axis([0 0.5 9.99 10.01]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1dual"),"-dpdflatex");
close

%
% Save results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol_mmse=%g %% Tolerance on MMSE relative coef. update\n", ...
        ftol_mmse);
fprintf(fid,"ftol_pcls=%g %% Tolerance on PCLS relative coef. update\n", ...
        ftol_pcls);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"dmax=%g %% Maximum coefficient step size\n",dmax);
fprintf(fid,"rho=%g %% Maximum pole radius\n",rho);
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

eval(sprintf(["save %s.mat n U V M Q R fap fas ftp tp ", ...
 "dBap dBas tpr Wap Was Wtp x0 x1 d1 ftol_mmse ftol_pcls ctol dmax rho"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
