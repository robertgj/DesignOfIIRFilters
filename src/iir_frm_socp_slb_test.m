% iir_frm_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen
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

format compact

%
% Initial filter is based on the filters found by tarczynski_frm_iir_test.m
%
x0.a = [   0.0167764585,   0.1088881694,   0.0000089591,  -0.2564808784, ... 
          -0.0120838451,   0.5742539304,   0.0029131547,  -0.0723385595, ... 
          -0.2450674010,   0.5110863294,   0.1522766320 ]';
x0.d = [   1.0000000000,   0.2022360090,   0.3940746880,   0.1200544657, ... 
          -0.0228300776,   0.0045729895,   0.0504127429,   0.0229445687, ... 
           0.0361252429,   0.0102913049,   0.0039434705 ]';
x0.aa = [  0.0031042717,  -0.0057984848,   0.0031002776,   0.0036966976, ... 
          -0.0055029586,  -0.0087160327,   0.0115457101,  -0.0008409106, ... 
          -0.0123904771,   0.0162950066,   0.0176897923,  -0.0333470258, ... 
           0.0058177661,   0.0349306948,  -0.0239908047,  -0.0200901198, ... 
           0.0606937591,  -0.0314210006,  -0.0780833560,   0.3181905273, ... 
           0.5669920509,   0.3181905273,  -0.0780833560,  -0.0314210006, ... 
           0.0606937591,  -0.0200901198,  -0.0239908047,   0.0349306948, ... 
           0.0058177661,  -0.0333470258,   0.0176897923,   0.0162950066, ... 
          -0.0123904771,  -0.0008409106,   0.0115457101,  -0.0087160327, ... 
          -0.0055029586,   0.0036966976,   0.0031002776,  -0.0057984848, ... 
           0.0031042717 ]';
x0.ac = [ -0.0095643857,  -0.0281807970,   0.0337747667,   0.0009139662, ... 
          -0.0306541128,  -0.0167508303,   0.0336338707,  -0.0077191127, ... 
          -0.0293545105,   0.0343483322,   0.0241930682,  -0.0587027497, ... 
           0.0187458649,   0.0508644059,  -0.0469972749,  -0.0212819548, ... 
           0.0863511416,  -0.0483624076,  -0.1187083736,   0.2881280944, ... 
           0.6378486542,   0.2881280944,  -0.1187083736,  -0.0483624076, ... 
           0.0863511416,  -0.0212819548,  -0.0469972749,   0.0508644059, ... 
           0.0187458649,  -0.0587027497,   0.0241930682,   0.0343483322, ... 
          -0.0293545105,  -0.0077191127,   0.0336338707,  -0.0167508303, ... 
          -0.0306541128,   0.0009139662,   0.0337747667,  -0.0281807970, ... 
          -0.0095643857 ]';

%
% Filter specification
%
n=400;
tol=2e-4
constraints_tol=tol/10
maxiter=5000
verbose=true
Mmodel=9 % Model filter decimation
Dmodel=7 % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2 % FIR masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask;
fap=0.3 % Pass band edge
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.05 % Pass band delay weight
Wat=tol*tol; % Transition band weight
fas=0.31125 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=50 % Stop band amplitude weight

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
strT=sprintf("FRM IIR/delay %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,\
U=%d,V=%d,M=%d,Q=%d,na=%d,nc=%d",Mmodel,Dmodel,fap,fas,U,V,M,Q,na,nc);
strF=sprintf("iir_frm_socp_slb_test_%%s_%%s");

% Plot initial response
iir_frm_socp_slb_plot(x0,na,nc,Mmodel,Dmodel,w,fap,strT,strF,"initial");

%
% SOCP PCLS 
%
[d2k,slb_iter,opt_iter,func_iter,feasible] = ...
  iir_frm_slb(@iir_frm_socp_mmse, ...
              x0k,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
              w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
              maxiter,tol,constraints_tol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_vec_to_struct(d2k,U,V,M,Q,na,nc);
% Plot the PCLS response
iir_frm_socp_slb_plot(d2,na,nc,Mmodel,Dmodel,w,fap,strT,strF,"pcls");

%
% Save the results
%
fid=fopen("iir_frm_socp_slb_test.spec","wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
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
print_polynomial(d2.a,"a","iir_frm_socp_slb_test_a_coef.m");
print_polynomial(d2.d,"d");
print_polynomial(d2.d,"d","iir_frm_socp_slb_test_d_coef.m");
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa","iir_frm_socp_slb_test_aa_coef.m");
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac","iir_frm_socp_slb_test_ac_coef.m");
save iir_frm_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was tol

% Done
toc;
diary off
movefile iir_frm_socp_slb_test.diary.tmp iir_frm_socp_slb_test.diary;
