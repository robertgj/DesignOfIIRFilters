% iir_sqp_slb_minimum_phase_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_minimum_phase_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-4
ctol=ftol/100
maxiter=10000
verbose=false

% Filter specifications
U=2,V=1,M=8,Q=4,R=2
fap=0.125
dBap=0.035
Wap=1
fas=0.25
dBas=50
Was=2

% Frequency vectors
n=1000;

% Amplitude constraints
nap=ceil(n*fap/0.5)+1;
wa=(0:(nap-1))'*pi/n;
Ad=ones(nap,1);
Adu=ones(nap,1);
Adl=(10^(-dBap/20))*ones(nap,1);
Wa=Wap*ones(nap,1);

% Stop-band amplitude constraints
nas=floor(n*fas/0.5);
ws=(nas:(n-1))'*pi/n;
Sd=zeros(n-nas,1);
Sdu=(10^(-dBas/20))*ones(n-nas,1);
Sdl=zeros(n-nas,1);
Ws=Was*ones(n-nas,1);

% Group delay constraints
wt=[];
Td=[];
Tdu=[];
Tdl=[];
Wt=[];

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Common strings for output plots
strP=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g", ...
             fap,dBap,Wap,fas,dBas,Was);

% Initial coefficients
x0=[ 0.004; ...
    -127/128;-127/128; ...
     0.6; ...
     127/128*ones(4,1); ...
     pi*(9:12)'/16; ...
     0.6;0.6; ...
     2*pi/3;pi/2];
strt=sprintf(strP,"x0");
showZPplot(x0,U,V,M,Q,R,strt);
zticks([]);
print(strcat(strf,"_initial_x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,strt);
zticks([]);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
hold off
close
showResponsePassBands(0,fap,-3,3,x0,U,V,M,Q,R,strt);
zticks([]);
print(strcat(strf,"_initial_x0pass"),"-dpdflatex");
hold off
close
            
% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q,255/256,255/256);
dmax=0.005;

% MMSE
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol,ctol,verbose);
if ~feasible 
  error("x1 infeasible");
endif

% PCLS
[d1,E,slb_iter,opt_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol,ctol,verbose)
if ~feasible 
  error("d1 infeasible");
endif
strt=sprintf(strP,"d1(pcls)");
nplot=n*2;
w=(0:nplot)'*pi/nplot;
A=iirA(w,d1,U,V,M,Q,R);
T=iirT(w,d1,U,V,M,Q,R);
subplot(211);
plot(0.5*w/pi,20*log10(A));
axis([0, 0.5, -80, 10]);
ylabel("Amplitude(dB)");
grid("on");
title(strt);
subplot(212);
plot(0.5*w/pi,T);
axis([0, 0.5 0 2*(U+M)]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(0,fap,-0.04,0.01,d1,U,V,M,Q,R,strt);
zticks([]);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
hold off
close
showZPplot(d1,U,V,M,Q,R,strt);
zticks([]);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

% Final amplitude at constraints
A=iirA(wa,d1,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
S=iirA(ws,d1,U,V,M,Q,R);
vSl=local_max(Sdl-S);
vSu=local_max(S-Sdu);
wAS=unique([wa(vAl);wa(vAu);ws(vSu);ws(vSl)]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol=%g %% Tolerance on relative coefficient update size\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%g %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%g %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%g %% Stop band amplitude weight\n",Was);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);

print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));

[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

eval(sprintf("save %s.mat U V M Q R ftol ctol fap dBap Wap fas dBas Was x0 d1", ...
             strf));

% Done 
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
