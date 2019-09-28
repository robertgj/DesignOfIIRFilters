% iir_frm_socp_slb_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen
% Design an FRM filter having an IIR model filter expressed in
% gain-pole-zero form and linear phase (ie: symmetric) masking filters.
% The squared-magnitude and group delay responses are PCLS optimised.
% The Wat weight is a hack that enables amplitude constraints in the
% transition band.

test_common;

unlink("iir_frm_socp_slb_test.diary");
unlink("iir_frm_socp_slb_test.diary.tmp");
diary iir_frm_socp_slb_test.diary.tmp

tic;


%
% Initial filter is based on the filters found by tarczynski_frm_iir_test.m
%
x0.a = [   0.0565615322,   0.0099594175,  -0.0900439973,   0.0029955478, ... 
           0.2826218540,   0.5198093722,   0.2992207266,   0.0031561231, ... 
          -0.0956647886,   0.0368328761,   0.0350866630 ]';
x0.d = [   1.0000000000,   0.0045472078,  -0.0074361530,  -0.0095229381, ... 
          -0.0054180919,   0.0022465470,   0.0042617041,   0.0026666524, ... 
          -0.0001906549,  -0.0011727919,   0.0001506493 ]';
x0.aa = [   0.0159132271,  -0.0053493672,  -0.0098654877,   0.0090780962, ... 
            0.0023043245,  -0.0050293161,   0.0028686172,  -0.0052320592, ... 
            0.0059260556,   0.0016106450,  -0.0098886964,  -0.0029137911, ... 
            0.0182774198,   0.0038255911,  -0.0360602719,   0.0161249632, ... 
            0.0593386783,  -0.0761064649,  -0.0692775647,   0.3092899007, ... 
            0.5701401428,   0.3092899007,  -0.0692775647,  -0.0761064649, ... 
            0.0593386783,   0.0161249632,  -0.0360602719,   0.0038255911, ... 
            0.0182774198,  -0.0029137911,  -0.0098886964,   0.0016106450, ... 
            0.0059260556,  -0.0052320592,   0.0028686172,  -0.0050293161, ... 
            0.0023043245,   0.0090780962,  -0.0098654877,  -0.0053493672, ... 
            0.0159132271 ]';
x0.ac = [  -0.0249619232,  -0.0299042212,   0.0194400700,   0.0245372331, ... 
           -0.0243177365,  -0.0117173689,   0.0287901891,  -0.0054289914, ... 
           -0.0244408001,   0.0226354227,   0.0099626494,  -0.0327675702, ... 
            0.0142856469,   0.0282396025,  -0.0472859495,  -0.0037781419, ... 
            0.0757810742,  -0.0593773578,  -0.1021436807,   0.3077984880, ... 
            0.6218858261,   0.3077984880,  -0.1021436807,  -0.0593773578, ... 
            0.0757810742,  -0.0037781419,  -0.0472859495,   0.0282396025, ... 
            0.0142856469,  -0.0327675702,   0.0099626494,   0.0226354227, ... 
           -0.0244408001,  -0.0054289914,   0.0287901891,  -0.0117173689, ... 
           -0.0243177365,   0.0245372331,   0.0194400700,  -0.0299042212, ... 
           -0.0249619232 ]';

%
% Filter specification
%
n=800;
tol=1e-3
ctol=tol/200
maxiter=5000
verbose=false
Mmodel=9 % Model filter decimation
Dmodel=7 % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2 % FIR masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask;
fap=0.3 % Pass band edge
dBap=0.2 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.01 % Pass band delay weight
Wat=tol*tol; % Transition band weight
fas=0.31125 % Stop band edge
dBas=45 % Stop band amplitude ripple
Was=100 % Stop band amplitude weight

%
% Convert x0 to vector form
%
[x0k,U,V,M,Q,na,nc]=iir_frm_struct_to_vec(x0);
if rem(na,2) == 1
  una=(na+1)/2;
else
  una=na/2;
endif
if rem(nc,2) == 1
  unc=(nc+1)/2;
else
  unc=nc/2;
endif
if length(x0k) ~= (1+U+V+M+Q+una+unc)
  error("Expected length(x0k) == (1+U+V+M+Q+una+unc");
endif
[xl,xu]=xConstraints(U,V,M,Q);

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
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

%
% Common strings
%
strt=sprintf("FRM IIR/delay %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,\
U=%d,V=%d,M=%d,Q=%d,na=%d,nc=%d",Mmodel,Dmodel,fap,fas,U,V,M,Q,na,nc);
strf="iir_frm_socp_slb_test";

% Plot initial response
iir_frm_socp_slb_plot ...
  (x0,na,nc,Mmodel,Dmodel,w,fap,strt,strcat(strf,"_%s_%s"),"initial");

%
% SOCP PCLS 
%
[d2k,slb_iter,opt_iter,func_iter,feasible] = ...
  iir_frm_slb(@iir_frm_socp_mmse, ...
              x0k,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
              w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
              maxiter,tol,ctol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_vec_to_struct(d2k,U,V,M,Q,na,nc);
% Plot the PCLS response
iir_frm_socp_slb_plot ...
  (d2,na,nc,Mmodel,Dmodel,w,fap,strt,strcat(strf,"_%s_%s"),"PCLS");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"ma=%d %% IIR model filter numerator order\n",length(x0.a)-1);
fprintf(fid,"md=%d %% IIR model filter denominator order\n",length(x0.d)-1);
fprintf(fid,"na=%d %% FIR masking filter length (order+1)\n",na);
fprintf(fid,"nc=%d %% FIR complementary masking filter length (order+1)\n",nc);
fprintf(fid,"Mmodel=%d %% Model filter decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"Tnominal=%d %% FIR masking filter delay\n",Tnominal);
fprintf(fid,"fap=%g %% Pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"tpr=%g %% Pass band delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band delay weight\n",Wtp);
fprintf(fid,"Wat=%g %% Transition band amplitude weight\n",Wat);
fprintf(fid,"fas=%g %% Stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band attenuation ripple\n",dBas);
fprintf(fid,"fasA=%g %% Additional stop band edge\n",fas);
fprintf(fid,"dBasA=%d %% Additional stop band attenuation ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band weight\n",Was);
fclose(fid);

print_polynomial(d2.a,"a");
print_polynomial(d2.a,"a",strcat(strf,"_a_coef.m"));
print_polynomial(d2.d,"d");
print_polynomial(d2.d,"d",strcat(strf,"_d_coef.m"));
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa",strcat(strf,"_aa_coef.m"));
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac",strcat(strf,"_ac_coef.m"));

save iir_frm_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was tol ctol

% Done
toc;
diary off
movefile iir_frm_socp_slb_test.diary.tmp iir_frm_socp_slb_test.diary;
