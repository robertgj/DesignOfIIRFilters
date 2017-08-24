% iir_frm_allpass_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_frm_allpass_socp_slb_test.diary");
unlink("iir_frm_allpass_socp_slb_test.diary.tmp");
diary iir_frm_allpass_socp_slb_test.diary.tmp

tic;

format compact

%
% Initial filter is based on the filters found by tarczynski_frm_allpass_test.m
%
x0.R = 1;
x0.r = [   1.0000000000,   0.1119538329,   0.4715915546,  -0.0522662339, ... 
          -0.0827533015,   0.0283153818,   0.0158847429,  -0.0223297825, ... 
           0.0236002446,  -0.0283428337,   0.0059108628 ]';
x0.aa = [  0.0020013514,   0.0060010949,  -0.0008109659,  -0.0052404857, ... 
           0.0035960175,   0.0086851476,  -0.0058982066,  -0.0079453842, ... 
           0.0102999232,   0.0027066095,  -0.0250248106,   0.0001510132, ... 
           0.0292980583,  -0.0151852904,  -0.0433773379,   0.0359614178, ... 
           0.0491054639,  -0.0850679193,  -0.0504296706,   0.3154368053, ... 
           0.5557791162,   0.3154368053,  -0.0504296706,  -0.0850679193, ... 
           0.0491054639,   0.0359614178,  -0.0433773379,  -0.0151852904, ... 
           0.0292980583,   0.0001510132,  -0.0250248106,   0.0027066095, ... 
           0.0102999232,  -0.0079453842,  -0.0058982066,   0.0086851476, ... 
           0.0035960175,  -0.0052404857,  -0.0008109659,   0.0060010949, ... 
           0.0020013514 ]';
x0.ac = [ -0.0065191785,  -0.0036044780,   0.0079417392,  -0.0019581996, ... 
          -0.0105852434,   0.0050606844,   0.0033458222,  -0.0103819888, ... 
           0.0060454505,  -0.0059570130,  -0.0252311697,   0.0219194468, ... 
           0.0130688954,  -0.0490885684,   0.0120225075,   0.0421511750, ... 
          -0.0695381828,   0.0129358718,   0.1101822902,  -0.2881028935, ... 
          -0.6372369481,  -0.2881028935,   0.1101822902,   0.0129358718, ... 
          -0.0695381828,   0.0421511750,   0.0120225075,  -0.0490885684, ... 
           0.0130688954,   0.0219194468,  -0.0252311697,  -0.0059570130, ... 
           0.0060454505,  -0.0103819888,   0.0033458222,   0.0050606844, ... 
          -0.0105852434,  -0.0019581996,   0.0079417392,  -0.0036044780, ... 
          -0.0065191785 ]';

%
% Filter specification
%
n=1000;
tol=2e-5
maxiter=5000
verbose=true
Mmodel=9 % Model filter decimation
Dmodel=9 % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2 % FIR masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
fap=0.3 % Pass band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.025 % Pass band delay weight
fas=0.3105 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=50 % Stop band amplitude weight
rho=31/32 % Stability constraint on pole radius

% Convert x0 to vector form
[x0k,Vr,Qr,Rr,na,nc]=iir_frm_allpass_struct_to_vec(x0);
[rl,ru]=aConstraints(Vr,Qr,rho);

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
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

% Common strings for output plots
strT=sprintf("FRM allpass/delay %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,\
Vr=%d,Qr=%d,Rr=%d,na=%d,nc=%d",Mmodel,Dmodel,fap,fas,Vr,Qr,Rr,na,nc);
strF=sprintf("iir_frm_allpass_socp_slb_test_%%s_%%s");

% Plot the initial response
iir_frm_allpass_socp_slb_plot(x0,na,nc,Mmodel,Dmodel, ...
                              w,fap,strT,strF,"initial");

%
% SOCP PCLS 
%
[d2k,slb_iter,opt_iter,func_iter,feasible] = ...
iir_frm_allpass_slb(@iir_frm_allpass_socp_mmse, ...
                    x0k,ru,rl,Vr,Qr,Rr,na,nc,Mmodel,Dmodel, ...
                    w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
                    maxiter,tol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_allpass_vec_to_struct(d2k,Vr,Qr,Rr,na,nc);
% Plot the PCLS response
iir_frm_allpass_socp_slb_plot(d2,na,nc,Mmodel,Dmodel,w,fap,strT,strF,"PCLS");

%
% Save the results
%
fid=fopen("iir_frm_allpass_socp_slb_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% Allpass model filter denominator order\n",length(x0.r)-1);
fprintf(fid,"R=%d %% Allpass model filter decimation factor\n",Rr);
fprintf(fid,"na=%d %% FIR masking filter length (order+1)\n",na);
fprintf(fid,"nc=%d %% FIR complementary masking filter length (order+1)\n",nc);
fprintf(fid,"Mmodel=%d %% Model filter decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"Tnominal=%g %% Nominal FRM filter group delay\n",Tnominal);
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
print_polynomial(d2.r,"r","iir_frm_allpass_socp_slb_test_r_coef.m");
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa","iir_frm_allpass_socp_slb_test_aa_coef.m");
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac","iir_frm_allpass_socp_slb_test_ac_coef.m");
save iir_frm_allpass_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was rho tol

% Done
toc;
diary off
movefile iir_frm_allpass_socp_slb_test.diary.tmp ...
       iir_frm_allpass_socp_slb_test.diary;
