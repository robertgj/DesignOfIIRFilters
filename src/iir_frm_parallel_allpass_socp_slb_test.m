% iir_frm_parallel_allpass_socp_slb_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

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
x0.r = [   1.0000000000,   0.0057957496,   0.4876446181,  -0.6064448505, ... 
          -0.0732464764,  -0.1813289594,   0.0825292010,   0.0402271769, ... 
           0.0231089807 ]';
x0.s = [   1.0000000000,  -0.3152347372,   0.3294588078,  -0.5882345551, ... 
           0.1018987408,  -0.1447755809,   0.1262117625,   0.0047961907 ]';
x0.aa = [   0.0167724708,   0.0233295319,  -0.0304553674,  -0.0791348942, ... 
           -0.0300527180,   0.0229121992,  -0.0139077644,  -0.0168328428, ... 
            0.0287721451,  -0.0703480761,  -0.1551090222,   0.1342882334, ... 
            0.5192009081,   0.4232988444,   0.0323482352,  -0.0592102153, ... 
            0.0920814112,   0.0687033643,  -0.0653685794,  -0.0454978647, ... 
            0.0577556352,   0.0763396415,   0.0407261969,   0.0180471815, ... 
            0.0078340271 ]';
x0.ac = [   0.0525817988,   0.0684670023,  -0.0954106925,  -0.1826399952, ... 
            0.0534406622,   0.1410656372,  -0.1362339594,  -0.1008011221, ... 
            0.1728895402,  -0.0379083588,  -0.2693408810,   0.1621993880, ... 
            0.5475956821,   0.3636701555,   0.1069084491,  -0.0213955482, ... 
           -0.0478810661,   0.0921216362,   0.1125651484,  -0.1033147587, ... 
           -0.0985112180,   0.1149169855,   0.1186773674,  -0.0143883282, ... 
           -0.0361929652 ]';
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
  (d2,na,nc,Mmodel,Dmodel,dmask,nplot,fap,strt,strcat(strf,"_%s_%s"),"pcls");

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
