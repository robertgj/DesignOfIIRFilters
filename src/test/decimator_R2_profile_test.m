% decimator_R2_profile_test.m
% Copyright (C) 2018,2020 Robert G. Jenssen

clear all
more off
set(0,'DefaultFigureVisible','off');
clf
close
page_screen_output(false);
suppress_verbose_help_message(true);

delete("decimator_R2_profile_test.diary");
delete("decimator_R2_profile_test.diary.tmp");
diary decimator_R2_profile_test.diary.tmp

tic;

verbose=false
tol_mmse=1e-5
tol_pcls=1e-4
ctol=1e-5
maxiter=10000

% Filter specifications (frequencies are normalised to the sample rate)
U=0,V=0,M=12,Q=6,R=2
fap=0.10,dBap=1,Wap=1
fas=0.25,dBas=40,Was=5
ftp=0.125,tp=10,tpr=0.02,Wtp=0.1

% Initial filter
x0=[ 0.000003, ...
     3.000000, 0.870594, 2.157462, 2.121797, 2.049648, 1.999908, ...
     3.141598, 1.911521, 1.883639, 2.186107, 2.511114, 2.828522, ...
     0.400373, 0.419078, 0.510494, ...
     0.359445, 1.050310, 1.696869 ]';

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
Adu=[Ad(1:(nas-1));(10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*Ad(1:nap);zeros(n-nap,1)];
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

% Initialise strings
strf="decimator_R2_profile_test";

% MMSE pass
printf("\nFinding MMSE x1, Wap=%f,Was=%f,Wtp=%f\n", Wap, Was, Wtp);
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol_mmse,verbose);
if feasible == 0 
  error("R=2 decimator x1 infeasible");
endif

% PCLS pass 1
printf("\nFinding PCLS d1, dBap=%f,Wap=%f,dBas=%f,Was=%f,tpr=%f,Wtp=%f\n", 
       dBap, Wap, dBas, Was, tpr, Wtp);
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol_pcls,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif

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
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));

% Done
diary off
movefile decimator_R2_profile_test.diary.tmp decimator_R2_profile_test.diary;
