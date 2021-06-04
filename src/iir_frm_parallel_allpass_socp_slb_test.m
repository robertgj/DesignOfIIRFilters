% iir_frm_parallel_allpass_socp_slb_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("iir_frm_parallel_allpass_socp_slb_test.diary");
delete("iir_frm_parallel_allpass_socp_slb_test.diary.tmp");
diary iir_frm_parallel_allpass_socp_slb_test.diary.tmp

tic;

maxiter=5000
verbose=false
no_delay=true

%
% Initial filter is based on the filters found by
% tarczynski_frm_parallel_allpass_test.m
%
x0.r = [   1.0000000000,   0.0396288419,   0.0689449339,  -0.0599083283, ... 
          -0.0443715262,   0.0464932448,   0.0083651224,  -0.0368797662, ... 
           0.0284772499 ]';
x0.s = [   1.0000000000,  -0.0379497971,  -0.0557881330,   0.0528953056, ... 
           0.0352025577,  -0.0329553367,   0.0030875814,   0.0226264956 ]';
x0.aa = [  0.0076424743,  -0.0417429483,  -0.0106628625,   0.0396671916, ... 
           0.0028086712,  -0.0314888474,  -0.0071419210,   0.0354581624, ... 
           0.0226291348,  -0.0857253112,  -0.0310216201,   0.2845054072, ... 
           0.5515788984,   0.3465622566,  -0.0778337966,  -0.1050831801, ... 
           0.0755261035,   0.0355070134,  -0.0668385297,  -0.0029568348, ... 
           0.0575735016,  -0.0289068045,  -0.0385292014,   0.0530946408, ... 
           0.0360749498 ]';
x0.ac = [  0.0134787015,   0.0119985288,   0.0035842381,  -0.0197834718, ... 
          -0.0027008514,   0.0339977355,  -0.0228719263,  -0.0317359575, ... 
           0.0679644185,  -0.0148035833,  -0.1235813962,   0.2794053677, ... 
           0.6495424154,   0.2857478436,  -0.1318730607,  -0.0130106741, ... 
           0.0689169298,  -0.0407520453,  -0.0145078439,   0.0420606144, ... 
          -0.0177122024,  -0.0186597085,   0.0235847076,  -0.0045625927, ... 
          -0.0083567127 ]';
n=500;
tol=1e-3 % Tolerance on coefficient update
ctol=tol/40 % Tolerance on constraints
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
Was=20 % Stop band amplitude weight
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
strf="iir_frm_parallel_allpass_socp_slb_test";
if no_delay
  strt=sprintf("FRM parallel allpass %%s %%s:fap=%g,fas=%g,na=%d,nc=%d",
               fap,fas,na,nc);
else
  strt=sprintf("FRM parallel allpass %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,\
fas=%g,na=%d,nc=%d", Mmodel,Dmodel,fap,fas,na,nc);
endif

% Plot the initial response
nplot=1024;
iir_frm_parallel_allpass_socp_slb_plot ...
  (x0,na,nc,Mmodel,Dmodel,dmask,nplot,fap,strt,strcat(strf,"_%s_%s"),"initial");

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
iir_frm_parallel_allpass_socp_slb_plot ...
  (d2,na,nc,Mmodel,Dmodel,dmask,nplot,fap,strt,strcat(strf,"_%s_%s"),"PCLS");

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
fid=fopen(strcat(strf,".spec"),"wt");
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
print_polynomial(d2.r,"r",strcat(strf,"_r_coef.m"));
print_polynomial(d2.s,"s");
print_polynomial(d2.s,"s",strcat(strf,"_s_coef.m"));
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa",strcat(strf,"_aa_coef.m"));
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac",strcat(strf,"_ac_coef.m"));
save iir_frm_parallel_allpass_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was rho tol

% Done
toc;
diary off
movefile iir_frm_parallel_allpass_socp_slb_test.diary.tmp  ...
         iir_frm_parallel_allpass_socp_slb_test.diary;
