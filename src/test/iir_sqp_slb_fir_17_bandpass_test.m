% iir_sqp_slb_fir_17_bandpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
% Design a minimum-phase FIR filter with order 17.

test_common;

strf="iir_sqp_slb_fir_17_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=2500
ftol=1e-3
ctol=ftol
verbose=false

% Bandpass filter specification
% (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=3,Wap=1
fasl=0.05,fasu=0.25,dBas=24,Wasl=10,Wasu=5

% Initialise strings
strM=sprintf(
"%%s:fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g,Wasl=%%g,Wasu=%%g",
fapl,fapu,dBap,fasl,fasu,dBas);
strd=sprintf("%s_%%s_%%s",strf);

% Initial filter in gain-zero-pole vector form
U=2;V=0;M=14;Q=0;R=1;
x0=[ 0.03, 0.9*ones(1,U), 0.9*ones(1,M/2), pi*[[1 2]/80, (10:14)/10] ]';
strM0=sprintf(strM,"x0",Wasl,Wasu);
showResponse(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0pz"),"-dpdflatex");
close

% Use minimum phase coefficient constraints
dmax=0.05;
rho=1-ftol;
[xl,xu]=xConstraints(U,V,M,Q,rho,rho);

% Frequency points
n=1000;

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(n-napu,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(n-nasu+1,1)];
Adl=[zeros(napl-1,1); ...
     (10^(-dBap/20))*ones(napu-napl+1,1); ...
     zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity check
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
printf("nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("wa(nchk)*0.5/pi=[ ");printf("%6.4g ",wa(nchk)'*0.5/pi);printf("];\n");
printf("Ad(nchk)=[ ");printf("%6.4g ",Ad(nchk)');printf("];\n");
printf("Adu(nchk)=[ ");printf("%6.4g ",Adu(nchk)');printf("];\n");
printf("Adl(nchk)=[ ");printf("%6.4g ",Adl(nchk)');printf("];\n");
printf("Wa(nchk)=[ ");printf("%6.4g ",Wa(nchk)');printf("];\n");

% Stop-band amplitude response constraints unused
ws=[];Sd=[];Sdu=[];Sdl=[];Ws=[];

% Group delay constraints unused
wt=[];Td=[];Tdu=[];Tdl=[];Wt=[];

% Phase response constraints unused
wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% MMSE optimisation of the minimum phase FIR bandpass amplitude response
[x1,Ex1,opt_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose)
if ~feasible 
  error("x1 infeasible");
endif
% Plot x1 response
strd=sprintf("%s_mmse_%%s",strf);
strX1=sprintf(strM,"x1(mmse)",Wasl,Wasu);
showZPplot(x1,U,V,M,Q,R,strX1);
print(sprintf(strd,"x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strX1);
print(sprintf(strd,"x1"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-2*dBap,dBap,x1,U,V,M,Q,R,strX1);
print(sprintf(strd,"x1pass"),"-dpdflatex");
close

% PCLS optimisation of the minimum phase FIR bandpass amplitude response
[d1,Ed1,slb_iter,opt_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol,ctol,verbose)
if ~feasible 
  error("d1 infeasible");
endif

% Ensure d1 amplitude response is <=1
% (PCLS permits max(Ad1)==ftol. d1(1) is the gain coefficient.)
Ad1=iirA(wa,d1,U,V,M,Q,R,ftol);
d1(1)=d1(1)/max(abs(Ad1));
Ad1=Ad1/max(abs(Ad1));
if max(abs(Ad1))>1
  error("max(abs(Ad1))>1");
endif
% Plot d1 response
strd=sprintf("%s_pcls_%%s",strf);
strP1=sprintf(strM,"d1(pcls)",Wasl,Wasu);
showZPplot(d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"d1pz"),"-dpdflatex");
close
showResponse(d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"d1"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-2*dBap,dBap,d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"d1pass"),"-dpdflatex");
close

% Save results
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
b0=x2tf(x0,U,V,M,Q,R);
print_polynomial(b0,"b0",strcat(strf,"_b0_coef.m"));
b1=x2tf(d1,U,V,M,Q,R);
print_polynomial(b1,"b1",strcat(strf,"_b1_coef.m"));

eval(sprintf(["save %s.mat ", ...
 "U V M Q R ftol ctol fapl fapu dBap Wap dBas Wasu Wasl x1 d1 b1"], strf));

% Done 
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
