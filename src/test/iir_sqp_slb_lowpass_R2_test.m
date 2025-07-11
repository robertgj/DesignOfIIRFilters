% iir_sqp_slb_lowpass_R2_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Example of SQP optimisation of a low-pass IIR R=2 filter
% with constraints on the pole locations and on the amplitude response.

test_common;

strf="iir_sqp_slb_lowpass_R2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
ftol_wise=1e-7
ftol_mmse=1e-5
ftol_pcls=1e-4
ctol=1e-4
maxiter=20000

% Filter specifications (dBap=0.05,dBas=58 fails under QEMU)
U=0,V=0,M=12,Q=6,R=2
fap=0.1,dBap=0.06,Wap=1,Wat=0
fas=0.15,dBas=53,Was=1

% Initial filter guess
xi=[0.001, [1,1,1,1,1,1], (7:12)*pi/12, 0.8*[1,1,1], (1:3)*pi/4]';

% Frequency points
n=1000;
f=(0:(n-1))'*0.5/n;
w=2*pi*f;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);
dmax=0.05;

% Amplitude constraints
wa=w;
Ad=[ones(nap,1);zeros(n-nap,1)];
Adu=[ones(nas-1,1);(10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Stop-band amplitude response constraints
ws=[];Sd=[];Sdu=[];Sdl=[];Ws=[];

% Group delay constraints
wt=[];Td=[];Tdu=[];Tdl=[];Wt=[];

% Phase response constraints
wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Initial filter
[x0,Ex0]=xInitHd(xi,U,V,M,Q,R,wa,Ad,Wa, ...
                 ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp, ...
                 maxiter,ftol_wise);
printf("x0=[ ");printf("%f ",x0');printf("]'\n");

% Plot initial response
A0=iirA(wa,x0,U,V,M,Q,R);
plot(wa*0.5/pi,20*log10(abs(A0)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -120 10]);
grid("on");
strI=sprintf(["Initial low-pass IIR filter : ", ...
              "U=%d,V=%d,M=%d,Q=%d,R=%d,fap=%g,fas=%g"],U,V,M,Q,R,fap,fas);
title(strI);
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% MMSE pass 1
feasible=false;
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...
                ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol_pcls,ctol,verbose)
if ~feasible
  error("x1 (mmse) infeasible");
endif
printf("x1=[ ");printf("%f ",x1);printf("]\n");

% PCLS pass 1
feasible=false;
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...
          ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol_pcls,ctol,verbose)
if ~feasible 
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

% Plot response
subplot(211)
[ax,h1,h2]=plotyy(wa*0.5/pi,20*log10(abs(A)),wa*0.5/pi,20*log10(abs(A)));
ylabel("Amplitude(dB)");
axis(ax(1),[0 0.5 -0.08 0.02]);
axis(ax(2),[0 0.5 -70 -45]);
grid("on");
strP=sprintf(["Low-pass IIR filter : U=%d,V=%d,M=%d,Q=%d,R=%d,", ...
              "fap=%g,dBap=%g,fas=%g,dBas=%g,ctol=%g"], ...
             U,V,M,Q,R,fap,dBap,fas,dBas,ctol);
title(strP);
subplot(212)
T=iirT(wa,d1,U,V,M,Q,R);
plot(wa*0.5/pi,T);
axis([0 0.5 0 30])
grid("on");
ylabel("Group-delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Plot pole-zero
showZPplot(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

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
fprintf(fid,"Wat=%d %% Transition band weight\n",Wat);
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

eval(sprintf(["save %s.mat n U V M Q R fap fas dBap dBas Wap Wat Was ", ...
              "xi x0 x1 d1 N1 D1 ftol_wise ftol_mmse ftol_pcls ctol"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
