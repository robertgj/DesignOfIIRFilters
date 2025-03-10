% iir_sqp_slb_fir_bandpass_test.m
% Design a minimum-phase FIR filter and find a complementary
% non-minimum-phase FIR filter. Compare it with a linear phase FIR
% filter designed by cl2bp.m

% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_fir_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=5000
ftol=1e-3
ctol=ftol
verbose=false

% Bandpass filter specification
% (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=1,Wap=1
fasl=0.05,fasu=0.25,dBas=36,Wasl=10,Wasu=5

% Initialise strings
strM=sprintf(
"%%s:fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g,Wasl=%%g,Wasu=%%g",
fapl,fapu,dBap,fasl,fasu,dBas);
strd=sprintf("%s_%%s_%%s",strf);

% Initial filter in gain-zero-pole vector form
U=2;V=0;M=28;Q=0;R=1;
x0=[ 0.005, -0.7, 0.7, 0.7*ones(1,14), pi*[(1:3)/80, (13:23)/24] ]';
strM0=sprintf(strM,"x0",Wasl,Wasu);
showZPplot(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0"),"-dpdflatex");
close

% Use minimum phase coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q,31/32,31/32);
dmax=0.01;

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

% Find the complementary filter
% Desired complementary response
Cd=sqrt(1-(Ad1.^2));
% Find initial FIR by windowing.
% (LPfapl+1-LPfapu in frequency domain implies odd length in time domain).
N=floor((1+U+V+M+Q)/2);
ci=(2*fapl*sinc(2*fapl*((-N):N))) - (2*fapu*sinc(2*fapu*((-N):N)));
ci(N+1)=ci(N+1)+1;
[c0,Uc,Vc,Mc,Qc]=tf2x(ci,1);
% Hack to fix real roots ?!?
c0((1+1):(1+U))=0;
% MMSE optimisation of the complementary response
% No constraints on real and complex zero radiuses (not minimum phase)
[xlc,xuc]=xConstraints(Uc,Vc,Mc,Qc);
ftol=1e-6
Wasl=8,Wasu=12
Wa=[Wasl*ones(nasl,1);ones(nasu-nasl,1);Wasu*ones(n-nasu,1)];
[c1,Ec1,opt_iter,func_iter,feasible] = ...
iir_sqp_mmse([],c0,xuc,xlc,dmax,Uc,Vc,Mc,Qc,R, ...
             wa,Cd,[],[],Wa,[],[],[],[],[], ...
             [],[],[],[],[],[],[],[],[],[], ...
             maxiter,ftol,ctol,verbose)
if ~feasible 
  error("c1 infeasible");
endif
% Plot complement response
strd=sprintf("%s_complementary_%%s",strf);
strC1=sprintf(strM,"c1(mmse)",Wasl,Wasu);
showZPplot(c1,Uc,Vc,Mc,Qc,R,strC1);
print(sprintf(strd,"c1pz"),"-dpdflatex");
close
showResponse(c1,Uc,Vc,Mc,Qc,R,strC1);
print(sprintf(strd,"c1"),"-dpdflatex");
close
% Show combined amplitude response
Ac1=iirA(wa,c1,Uc,Vc,Mc,Qc,R);
strd=sprintf("%s_combined_%%s",strf);
plot(wa*0.5/pi,20*log10(sqrt((Ad1.^2)+(Ac1.^2))));
ylabel("Combined response(dB)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"d1c1"),"-dpdflatex");
close

% A more accurate design of the complementary FIR filter is found
% with the real cepstrum or with Orchard's Newton-Raphson solution.
%{
% Compare with cl2bp filter
fapl=0.1;fapu=0.2;dBap=1;dBas=36;
wl=fapl*2*pi*0.8;
wu=fapu*2*pi*1.1;
up=10.^([-dBas, 0, -dBas]/20);
lo=[-1,1,-1].*10.^([-dBas, -dBap, -dBas]/20);
N=floor((1+U+V+M+Q)/2);
bcl = cl2bp(N,wl,wu,up,lo,512);
[cl0,Ucl,Vcl,Mcl,Qcl]=tf2x(bcl,1,ftol);
% Ensure max(abs(Acl0))<=1 (cl0(1) is the gain coefficient)
Acl0=iirA(wa,cl0,Ucl,Vcl,Mcl,Qcl,R,ftol);
cl0(1)=cl0(1)/max(abs(Acl0));
Acl0=Acl0/max(abs(Acl0));
% Find the complement to the cl2bp filter
Aclcd=sqrt(1-(Acl0.^2));
[xlcl,xucl]=xConstraints(Ucl,Vcl,Mcl,Qcl);
% First mmse pass
ftol=1e-6
Wasl=8,Wasu=12
Wa=[Wasl*ones(nasl,1);ones(nasu-nasl,1);Wasu*ones(n-nasu,1)];
[clc0,Eclc0,opt_iter,func_iter,feasible] = ...
iir_sqp_mmse([],c1,xucl,xlcl,dmax,Ucl,Vcl,Mcl,Qcl,R, ...
             wa,Aclcd,[],[],Wa,[],[],[],[],[], ...
             [],[],[],[],[],[],[],[],[],[], ...
             maxiter,ftol,ctol,verbose)
if ~feasible 
  error("clc0 (mmse) infeasible");
endif
% Second mmse pass
ftol=4e-8
Wasl=4,Wasu=2
Wa=[Wasl*ones(nasl,1);ones(nasu-nasl,1);Wasu*ones(n-nasu,1)];
[clc1,Eclc1,opt_iter,func_iter,feasible] = ...
iir_sqp_mmse([],clc0,xucl,xlcl,dmax,Ucl,Vcl,Mcl,Qcl,R, ...
             wa,Aclcd,[],[],Wa,[],[],[],[],[], ...
             [],[],[],[],[],[],[],[],[],[], ...
             maxiter,ftol,ctol,verbose)
if ~feasible 
  error("clc1 (mmse) infeasible");
endif

% Plot complement response
strd=sprintf("%s_complementary_%%s",strf);
showZPplot(clc1,Ucl,Vcl,Mcl,Qcl,R,"");
print(sprintf(strd,"clc1pz"),"-dpdflatex");
close
showResponse(clc1,Ucl,Vcl,Mcl,Qcl,R,"");
print(sprintf(strd,"clc1"),"-dpdflatex");
close
% Show combined amplitude response
Aclc1=iirA(wa,clc1,Ucl,Vcl,Mcl,Qcl,R);
strd=sprintf("%s_combined_%%s",strf);
plot(wa*0.5/pi,20*log10(sqrt((Acl0.^2)+(Aclc1.^2))));
ylabel("Combined response(dB)");
xlabel("Frequency");
grid("on");
print(sprintf(strd,"cl0clc1"),"-dpdflatex");
close
%}

% Save results
print_pole_zero(x1,U,V,M,Q,R,"x1",strcat(strf,"_x1_coef.m"));
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
print_pole_zero(c1,Uc,Vc,Mc,Qc,R,"c1",strcat(strf,"_c1_coef.m"));
                                
[Nd1,Dd1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(Nd1,"Nd1",strcat(strf,"_Nd1_coef.m"));
                 
[Nc1,Dc1]=x2tf(c1,Uc,Vc,Mc,Qc,R);
print_polynomial(Nc1,"Nc1",strcat(strf,"_Nc1_coef.m"));

% Done 
eval(sprintf(["save %s.mat U V M Q R ftol ctol ", ...
 "fapl fapu dBap Wap dBas Wasu Wasl x1 d1 Uc Vc Mc Qc c1"],strf));

diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
