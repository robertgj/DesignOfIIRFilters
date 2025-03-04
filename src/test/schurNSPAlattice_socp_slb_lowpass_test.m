% schurNSPAlattice_socp_slb_lowpass_test.m
% Copyright (C) 2023-2025 Robert G. Jenssen

test_common;

strf="schurNSPAlattice_socp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=5000
ftol=1e-5
ctol=ftol/100
verbose=false

%
% Initial coefficients from tarczynski_parallel_allpass_test.m
%
tarczynski_parallel_allpass_test_flat_delay_Da0_coef;
tarczynski_parallel_allpass_test_flat_delay_Db0_coef;

% Lattice decomposition of Da0, Db0
[~,~,A1s20_0,A1s00_0,A1s02_0,A1s22_0] = tf2schurNSlattice(flipud(Da0),Da0);
[~,~,A2s20_0,A2s00_0,A2s02_0,A2s22_0] = tf2schurNSlattice(flipud(Db0),Db0);

%
% Band-pass filter specification for parallel all-pass filters
%
% Low pass filter specification
dmax=inf;
rho=0.999
n=800
difference=false
fap=0.125 % Pass band amplitude response edge
dBap=0.5 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
Wat=0.1 % Transition band amplitude response weight
fas=0.25 % Stop band amplitude response edge
dBas=50 % Stop band amplitude response ripple
Was=100 % Stop band amplitude response weight
ftp=0.175 % Pass band group delay response edge
tp=(length(Da0)-1+length(Db0)-1)/2 % Pass band nominal group delay
tpr=0.04 % Pass band group delay response ripple
Wtp=1 % Pass band group delay response weight
 
% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

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

% Linear constraints
sxx_0=[A1s20_0(:);A1s00_0(:);A1s02_0(:);A1s22_0(:); ...
       A2s20_0(:);A2s00_0(:);A2s02_0(:);A2s22_0(:)];
sxx_u=rho*ones(size(sxx_0));
sxx_l=-sxx_u;
sxx_active=find(sxx_0~=0);
sxx_symmetric=true;

%
% SOCP MMSE
%
try
  [A1s20_1,A1s00_1,A1s02_1,A1s22_1,A2s20_1,A2s00_1,A2s02_1,A2s22_1, ...
   socp_iter,func_iter,feasible] = ...
     schurNSPAlattice_socp_mmse([], ...
                                A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                                A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                                difference, ...
                                sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                                wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible = false;
end_try_catch
if ~feasible
  error("A1,A2(mmse) infeasible");
endif

%
% SOCP PCLS
%
try
  [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
   slb_iter,opt_iter,func_iter,feasible] = ...
     schurNSPAlattice_slb(@schurNSPAlattice_socp_mmse, ...
                          A1s20_1,A1s00_1,A1s02_1,A1s22_1, ...
                          A2s20_1,A2s00_1,A2s02_1,A2s22_1, ...
                          difference, ...
                          sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                          wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                          wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible = false;
end_try_catch
if ~feasible
  error("A1,A2(pcls) infeasible");
endif

% Check symmetry
if max(abs(A1s20+A1s02))>eps
  error("max(abs(A1s20+A1s02))>eps");
endif
if max(abs(A1s00-A1s22))>eps
  error("max(abs(A1s00-A1s22))>eps");
endif
if max(abs(A2s20+A2s02))>eps
  error("max(abs(A2s20+A2s02))>eps");
endif
if max(abs(A2s00-A2s22))>eps
  error("max(abs(A2s00-A2s22))>eps");
endif

% Calculate response
Asq=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
T=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                    A2s20,A2s00,A2s02,A2s22,difference);

% Plot response
subplot(211);
ax=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 -0.6 0.2]);
axis(ax(2),[0 0.5 -60 -40]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass lowpass : dBap=%g,dBas=%g",dBap,dBas);
title(strt);
subplot(212);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp-0.02 tp+0.02]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurNSPAlatticeAsq(wAsqS,A1s20,A1s00,A1s02,A1s22, ...
                         A2s20,A2s00,A2s02,A2s22,difference);
printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurNSPAlatticeT(wTS,A1s20,A1s00,A1s02,A1s22, ...
                     A2s20,A2s00,A2s02,A2s22,difference);
printf("A1,A2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Check transfer function
A1d=schurNSAPlattice2tf(A1s20,A1s00,A1s02,A1s22);
A2d=schurNSAPlattice2tf(A2s20,A2s00,A2s02,A2s22);
[N2,D2]=schurNSPAlattice2tf(A1s20,A1s02,A1s00,A1s22,A2s20,A2s02,A2s00,A2s22);
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  warning("max(abs((abs(HH).^2)-Asq))(%g*eps)>100*eps",
          max(abs((abs(HH).^2)-Asq))/eps);
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fclose(fid);

print_polynomial(A1s20,"A1s20");
print_polynomial(A1s20,"A1s20",strcat(strf,"_A1s20_coef.m"));
print_polynomial(A1s00,"A1s00");
print_polynomial(A1s00,"A1s00",strcat(strf,"_A1s00_coef.m"));

print_polynomial(A2s20,"A2s20");
print_polynomial(A2s20,"A2s20",strcat(strf,"_A2s20_coef.m"));
print_polynomial(A2s00,"A2s00");
print_polynomial(A2s00,"A2s00",strcat(strf,"_A2s00_coef.m"));

print_polynomial(A1d,"A1d");
print_polynomial(A1d,"A1d",strcat(strf,"_A1d_coef.m"));
print_polynomial(A2d,"A2d");
print_polynomial(A2d,"A2d",strcat(strf,"_A2d_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf("save %s.mat rho ftol ctol difference sxx_symmetric n \
fap dBap Wap Wat fas dBas Was ftp tp tpr Wtp \
Da0 Db0 A1s20 A1s00 A1s02 A1s22 A2s20 A2s00 A2s02 A2s22 A1d A2d N2 D2",strf));
        
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
