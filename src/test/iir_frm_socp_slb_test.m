% iir_frm_socp_slb_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen
% Design an FRM filter having an IIR model filter expressed in
% gain-pole-zero form and linear phase (ie: symmetric) masking filters.
% The squared-magnitude and group delay responses are PCLS optimised.
% The Wat weight is a hack that enables amplitude constraints in the
% transition band.

test_common;

delete("iir_frm_socp_slb_test.diary");
delete("iir_frm_socp_slb_test.diary.tmp");
diary iir_frm_socp_slb_test.diary.tmp

tic;


%
% Initial filter is based on the filters found by tarczynski_frm_iir_test.m
%
tarczynski_frm_iir_test_a_coef;
tarczynski_frm_iir_test_d_coef;
tarczynski_frm_iir_test_aa_coef;
tarczynski_frm_iir_test_ac_coef;

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
Wtp=0.001 % Pass band delay weight
Wat=tol*tol; % Transition band weight
fas=0.31125 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=20 % Stop band amplitude weight

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
% Compare to expected (allow for small variations from run to run!)
%
etol = 5e-8;
d2exp.a = [  0.0023872435,  -0.0002998516,  -0.0028178530,  -0.0006292835, ... 
             0.0075112808,   0.0007771227,  -0.0153793578,   0.0328696565, ... 
            -0.0275937942,   0.0088012491,   0.0051176032  ]';
if max(abs(d2exp.a-d2.a))>etol
  print_polynomial(d2.a,"a");
  print_polynomial(d2exp.a,"expa");
  error("max(abs(d2exp.a-d2.a))(%g*etol) > etol",
        max(abs(d2exp.a-d2.a))/etol);
endif

d2exp.d = [  1.0000000000,   0.3925483043,   0.7343625347,   0.2883931662, ... 
             0.0561892637,  -0.0084691690,  -0.0054392025,  -0.0010209218, ... 
            -0.0001136908,  -0.0000105375,  -0.0000006973 ]';
if max(abs(d2exp.d-d2.d))>etol
  print_polynomial(d2.d,"d");
  print_polynomial(d2exp.d,"expd");
  error("max(abs(d2exp.d-d2.d))(%g*etol) > etol",
        max(abs(d2exp.d-d2.d))/etol);
endif

d2exp.aa = [  0.1390307825,   0.1637722775,  -0.4624376812,   0.3001578566, ... 
              0.1315784307,  -0.1954580193,   0.0918906885,   0.2285812605, ... 
             -0.2582587245,  -0.0510615690,   0.4089339399,  -0.2772987421, ... 
             -0.2448363933,   0.4178081872,   0.0611968156,  -0.4873687979, ... 
              0.2932744964,   0.3733965821,  -0.3282092409,   0.5572050084, ... 
              0.2923220653,   0.5572050084,  -0.3282092409,   0.3733965821, ... 
              0.2932744964,  -0.4873687979,   0.0611968156,   0.4178081872, ... 
             -0.2448363933,  -0.2772987421,   0.4089339399,  -0.0510615690, ... 
             -0.2582587245,   0.2285812605,   0.0918906885,  -0.1954580193, ... 
              0.1315784307,   0.3001578566,  -0.4624376812,   0.1637722775, ... 
              0.1390307825  ]';
if max(abs(d2exp.aa-d2.aa))>etol
  print_polynomial(d2.aa,"aa");
  print_polynomial(d2exp.aa,"expaa");
  error("max(abs(d2exp.aa-d2.aa))(%g*etol) > etol",
        max(abs(d2exp.aa-d2.aa))/etol);
endif

d2exp.ac = [ -0.0029639740,  -0.0079292225,   0.0154038074,  -0.0064703235, ... 
             -0.0080891576,   0.0049463675,   0.0035094405,  -0.0104947353, ... 
              0.0014871843,   0.0217797981,   0.0002949507,  -0.0392881999, ... 
              0.0380337181,   0.0135031685,  -0.0446458306,   0.0177031304, ... 
              0.0624691923,  -0.0750983708,  -0.0832297850,   0.2924774451, ... 
              0.6087368404,   0.2924774451,  -0.0832297850,  -0.0750983708, ... 
              0.0624691923,   0.0177031304,  -0.0446458306,   0.0135031685, ... 
              0.0380337181,  -0.0392881999,   0.0002949507,   0.0217797981, ... 
              0.0014871843,  -0.0104947353,   0.0035094405,   0.0049463675, ... 
             -0.0080891576,  -0.0064703235,   0.0154038074,  -0.0079292225, ... 
             -0.0029639740 ]';
if max(abs(d2exp.ac-d2.ac))>etol
  print_polynomial(d2.ac,"ac");
  print_polynomial(d2exp.ac,"expac");
  error("max(abs(d2exp.ac-d2.ac))(%g*etol) > etol",
        max(abs(d2exp.ac-d2.ac))/etol);
endif


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
