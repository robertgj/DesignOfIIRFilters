% iir_frm_parallel_allpass_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_frm_parallel_allpass_socp_slb_test.diary");
unlink("iir_frm_parallel_allpass_socp_slb_test.diary.tmp");
diary iir_frm_parallel_allpass_socp_slb_test.diary.tmp

tic;

format compact
maxiter=5000
verbose=false
no_delay=true

%
% Initial filter is based on the filters found by
% tarczynski_frm_parallel_allpass_test.m
%
x0.r = [   1.0000000000,   0.1741638972,   0.5027502283,  -0.4761594584, ... 
          -0.1150929406,  -0.1383555445,   0.0867097934,   0.0603294613, ... 
           0.0313963054 ]';
x0.s = [   1.0000000000,  -0.0857111594,   0.1816666635,  -0.4144291285, ... 
           0.0072733463,  -0.0882460342,   0.1299448672,   0.0173169817 ]';
x0.aa = [   0.0054935301,  -0.0060642255,  -0.0492191135,  -0.0569589402, ... 
            0.0090954104,   0.0487256604,   0.0135358020,   0.0173002104, ... 
            0.0627478485,   0.0465409775,   0.1113837866,   0.3806625453, ... 
            0.4829154906,   0.1310970617,  -0.2272418254,  -0.1377008309, ... 
            0.0896744284,   0.0394989454,  -0.0843006560,  -0.0052605268, ... 
            0.1095521605,   0.0719179183,  -0.0151246472,  -0.0315187993, ... 
           -0.0088245744 ]';
x0.ac = [   0.0325757581,   0.0267193719,  -0.1016383423,  -0.1334713697, ... 
            0.0719353837,   0.1044203058,  -0.1224859003,  -0.0370596816, ... 
            0.2023003404,   0.0533322021,   0.0072373678,   0.4302371713, ... 
            0.5098593309,   0.0480425413,  -0.1977649513,  -0.1245580362, ... 
           -0.0358281145,   0.0559039370,   0.0560841995,  -0.0562044625, ... 
           -0.0085250089,   0.1000911935,   0.0220632373,  -0.0808465769, ... 
           -0.0500571556 ]';

n=500;
tol=1e-3 % Tolerance on coefficient update
ctol=tol/10 % Tolerance on constraints
mr=length(x0.r)-1 % Allpass model filter order 
ms=length(x0.s)-1 % Allpass model filter order
na=length(x0.aa) % Masking filter FIR length
nc=length(x0.ac) % Complementary masking filter FIR length
Mmodel=9 % Model filter decimation
Dmodel=0 % Desired model filter passband delay
dmask=0 % Nominal masking filter delay
Tnominal=0 % Nominal FRM filter delay
fap=0.3 % Pass band edge
dBap=0.02 % Pass band amplitude ripple
Wap=1 % Pass band weight
tpr=inf % Peak-to-peak pass band delay ripple
Wtp=0 % Pass band delay weight
Wat=1e-6 % Small transition band weight enables constraints
fas=0.31 % Stop band edge
dBas=40 % Stop band attenuation
Was=100 % Stop band amplitude weight
rho=31/32 % Stability constraint on pole radius

% Convert x0 to vector form
[x0k,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);

% Constraints on allpass pole radiuses
[rl,ru]=aConstraints(Vr,Qr,rho);
[sl,su]=aConstraints(Vs,Qs,rho);
xl=[rl(:);sl(:);-inf*ones(na+nc,1)];
xu=[ru(:);su(:); inf*ones(na+nc,1)];

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=nap;
Td=Tnominal*ones(ntp,1);
Tdu=Td+((tpr/2)*ones(ntp,1));
Tdl=Td-((tpr/2)*ones(ntp,1));
Wt=Wtp*ones(ntp,1);

% Common strings for output plots
if no_delay
  strT=sprintf("FRM parallel allpass %%s %%s:fap=%g,fas=%g,na=%d,nc=%d",
               fap,fas,na,nc);
else
  strT=sprintf("FRM parallel allpass %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,\
fas=%g,na=%d,nc=%d", Mmodel,Dmodel,fap,fas,na,nc);
endif
strF=sprintf("iir_frm_parallel_allpass_socp_slb_test_%%s_%%s");

% Plot the initial response
nplot=1024;
iir_frm_parallel_allpass_socp_slb_plot(x0,na,nc,Mmodel,Dmodel,dmask, ...
                                       nplot,fap,strT,strF,"initial");

%
% SOCP PCLS 
%
[d2k,slb_iter,opt_iter,func_iter,feasible] = ...
  iir_frm_parallel_allpass_slb(@iir_frm_parallel_allpass_socp_mmse, ...
                               x0k,xu,xl,Vr,Qr,Vs,Qs,na,nc,Mmodel, ...
                               w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
                               maxiter,tol,ctol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_parallel_allpass_vec_to_struct(d2k,Vr,Qr,Vs,Qs,na,nc);
% Plot the PCLS response
iir_frm_parallel_allpass_socp_slb_plot(d2,na,nc,Mmodel,Dmodel,dmask, ...
                                       nplot,fap,strT,strF,"pcls");

%
% PCLS amplitude at local peaks
%
Asq=iir_frm_parallel_allpass(w,d2k,Vr,Qr,Vs,Qs,na,nc,Mmodel);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
vAS=unique([vAl(:);vAu(:);1;nap;nas;n]);
AS=Asq(vAS);
printf("d2k:fAS=[ ");printf("%f ",w(vAS)'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",10*log10(AS'));printf(" ] (dB)\n");

%
% Save the results
%
fid=fopen("iir_frm_parallel_allpass_socp_slb_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% R model filter denominator order\n",length(x0.r)-1);
fprintf(fid,"ms=%d %% S model filter denominator order\n",length(x0.s)-1);
fprintf(fid,"na=%d %% FIR masking filter length (order+1)\n",na);
fprintf(fid,"nc=%d %% FIR complementary masking filter length (order+1)\n",nc);
fprintf(fid,"Mmodel=%d %% Model filter decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"tpr=%g %% Pass band delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band attenuation ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);
print_polynomial(d2.r,"r");
print_polynomial(d2.r,"r","iir_frm_parallel_allpass_socp_slb_test_r_coef.m");
print_polynomial(d2.s,"s");
print_polynomial(d2.s,"s","iir_frm_parallel_allpass_socp_slb_test_s_coef.m");
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa","iir_frm_parallel_allpass_socp_slb_test_aa_coef.m");
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac","iir_frm_parallel_allpass_socp_slb_test_ac_coef.m");
save iir_frm_parallel_allpass_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was rho tol

% Done
toc;
diary off
movefile iir_frm_parallel_allpass_socp_slb_test.diary.tmp  ...
         iir_frm_parallel_allpass_socp_slb_test.diary;
