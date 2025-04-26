% iir_socp_slb_lowpass_test.m
% Copyright (C) 2018-2025 Robert G. Jenssen

test_common;

pkg load optim;

strf="iir_socp_slb_lowpass_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

tic

tol=1e-4
ctol=1e-4
maxiter=2000
verbose=false

%
% Filter specifications
%
R=1;
N=15
fap=0.15
dBap=1
Wap=1
Wat=0.001
ftp=0.15
tp=10
tpr=0.2
Wtp=0.05
Wtt=0.001
fas=0.2
dBas=40
Was=45
  
% Frequency vectors
n=1000;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=ceil((n*fap)/0.5)+1;
wa=w(1:nap);
Ad=ones(size(wa));
Adu=ones(size(wa));
Adl=(10^(-dBap/20))*ones(size(wa));
Wa=Wap*ones(size(wa));

% Stop-band amplitude constraints
nas=floor((n*fas)/0.5)+1;
ws=w(nas:end);
Sd=zeros(size(ws));
Sdu=(10^(-dBas/20))*ones(size(ws));
Sdl=zeros(size(ws));
Ws=Was*ones(size(ws));

% Group delay constraints
ntp=ceil((n*ftp)/0.5)+1;
if 1
  % Limit transition band peaks
  ntp=ceil(n*ftp/0.5)+1;
  wt=w(1:(nas-1));
  Td=tp*ones(size(wt));
  Tdu=[(tp+(tpr/2))*ones(ntp,1);(tp*2)*ones(nas-1-ntp,1)];
  Tdl=[(tp-(tpr/2))*ones(ntp,1);zeros(nas-1-ntp,1)];
  Wt=[Wtp*ones(ntp,1);Wtt*ones(nas-1-ntp,1)];
else
  ntp=ceil(n*ftp/0.5)+1;
  wt=w(1:ntp);
  Td=tp*ones(size(wt));
  Tdu=(tp+(tpr/2))*ones(size(wt));
  Tdl=(tp-(tpr/2))*ones(size(wt));
  Wt=Wtp*ones(size(wt));
endif

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

%
% Use unconstrained optimisation to find an initial filter
%
% Initial coefficients
[ni,di]=butter(N,2*fap);
% Desired frequency response
Hda=[ones(nap,1);zeros(n-nap,1)];
Wda=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];
Hdt=tp*ones(n,1);
Wdt=[Wtp*ones(ntp,1);zeros(n-ntp,1)];
ndi=[ni,di(2:end)]';
WISEJ_ND([],N,N,R,Hda,Wda,Hdt,Wdt);
[nd0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_ND,ndi);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Convert initial filter to gain-pole-zero form
n0=nd0(1:(N+1));
d0=[1;nd0((N+2):end)];
[x0,U,V,M,Q]=tf2x(n0,d0);

% Sanity check
[H0,w0]=freqz(n0,d0,1024);
A0=iirA(w0,x0,U,V,M,Q,R);
if max(abs(abs(H0)-A0)) > 1e-10
  error("max(abs(abs(H0)-A0)) > 1e-10");
endif

% Plot initial response
strt=sprintf("x0:fap=%g,ftp=%g,tp=%g,fas=%g",fap,ftp,tp,fas);
showResponse(x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_x0pass"),"-dpdflatex");
close

% Initial cost
E0=iirE(x0,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);
printf("E0=%g\n",E0);

%
% Coefficient constraints
%
dmax=0.02;
rho=127/128;
[xl,xu]=xConstraints(U,V,M,Q,rho);

%
% PCLS pass
%
feasible=false;
try
  [d1,E,slb_iter,socp_iter,func_iter,feasible] = ...
     iir_slb(@iir_socp_mmse,x0,xu,xl,dmax,U,V,M,Q,R, ...
             wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
             wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
             maxiter,tol,ctol,verbose)
catch
end_try_catch;
if ~feasible
 error("d1 infeasible");
endif
strt=sprintf(["d1(PCLS):fap=%g,dBap=%g,ftp=%g,tp=%g,tpr=%g,fas=%g", ...
              "dBas=%g,Was=%g"],fap,dBap,ftp,tp,tpr,fas,dBas,Was);
showResponse(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

% Final pass-band amplitude at constraints
A=iirA(wa,d1,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu)]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

% Final stop-band amplitude at constraints
S=iirA(ws,d1,U,V,M,Q,R);
vSl=local_max(Sdl-S);
vSu=local_max(S-Sdu);
wSS=unique([ws(vSu);ws(vSl)]);
SS=iirA(wSS,d1,U,V,M,Q,R);
printf("d1:fSS=[ ");printf("%f ",wSS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:SS=[ ");printf("%f ",20*log10(SS'));printf(" ] (dB)\n");

% Final group-delay at constraints
T=iirT(wt,d1,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu)]);
TS=iirT(wTS,d1,U,V,M,Q,R);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Constraint on pole radius\n",rho);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude weight\n",Wap);
fprintf(fid,"Wat=%d %% Transition band amplitude weight\n",Wat);
fprintf(fid,"ftp=%g %% Pass band group-delay response edge\n",ftp);
fprintf(fid,"tp=%d %% Pass band group-delay\n",tp);
fprintf(fid,"tpr=%d %% Pass band amplitude peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group-delay weight\n",Wtp);
fprintf(fid,"Wtt=%d %% Transition band group-delay weight\n",Wtt);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude weight\n",Was);
fclose(fid);
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Done
toc;
eval([sprintf("save %s.mat ",strf),"N U V M Q R tol ctol rho dmax ", ...
      "fap dBap Wap ftp tp tpr Wtp fas dBas Was ni di x0 d1 N1 D1"]);

diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
