% iir_frm_socp_slb_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
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
x0.a = [   0.0237825556,   0.1047462784,  -0.0043820630,  -0.2555892001, ... 
           0.0054366597,   0.5640519790,  -0.0077235342,  -0.0589841450, ... 
          -0.2478215779,   0.4956297205,   0.1584484992 ]';
x0.d = [   1.0000000000,   0.2144636538,   0.3814475491,   0.1380627386, ... 
          -0.0178239137,  -0.0031230801,   0.0538358763,   0.0243004110, ... 
           0.0244844029,   0.0145742814,  -0.0009531063 ]';
x0.aa = [  0.0031141646,  -0.0064818502,   0.0020563486,   0.0043352087, ... 
          -0.0051038622,  -0.0089709394,   0.0120926159,  -0.0005783996, ... 
          -0.0125156683,   0.0151710844,   0.0177873800,  -0.0318064635, ... 
           0.0061525525,   0.0342058928,  -0.0243912878,  -0.0207534084, ... 
           0.0612207675,  -0.0313484005,  -0.0842644531,   0.3174814033, ... 
           0.5763286644,   0.3174814033,  -0.0842644531,  -0.0313484005, ... 
           0.0612207675,  -0.0207534084,  -0.0243912878,   0.0342058928, ... 
           0.0061525525,  -0.0318064635,   0.0177873800,   0.0151710844, ... 
          -0.0125156683,  -0.0005783996,   0.0120926159,  -0.0089709394, ... 
          -0.0051038622,   0.0043352087,   0.0020563486,  -0.0064818502, ... 
           0.0031141646 ]';
x0.ac = [ -0.0068999574,  -0.0283076185,   0.0294378672,   0.0012786875, ... 
          -0.0277122475,  -0.0165429753,   0.0335884332,  -0.0081108913, ... 
          -0.0290018176,   0.0338605165,   0.0249828797,  -0.0580463893, ... 
           0.0196064048,   0.0506342484,  -0.0469439815,  -0.0221626625, ... 
           0.0866080737,  -0.0481977085,  -0.1183686192,   0.2874571679, ... 
           0.6380266694,   0.2874571679,  -0.1183686192,  -0.0481977085, ... 
           0.0866080737,  -0.0221626625,  -0.0469439815,   0.0506342484, ... 
           0.0196064048,  -0.0580463893,   0.0249828797,   0.0338605165, ... 
          -0.0290018176,  -0.0081108913,   0.0335884332,  -0.0165429753, ... 
          -0.0277122475,   0.0012786875,   0.0294378672,  -0.0283076185, ... 
          -0.0068999574 ]';

%
% Filter specification
%
n=400;
tol=1e-3
constraints_tol=tol/50
maxiter=5000
verbose=false
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
              maxiter,tol,constraints_tol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_vec_to_struct(d2k,U,V,M,Q,na,nc);
% Plot the PCLS response
iir_frm_socp_slb_plot ...
  (d2,na,nc,Mmodel,Dmodel,w,fap,strt,strcat(strf,"_%s_%s"),"pcls");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
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
print_polynomial(d2.a,"a",strcat(strf,"_a_coef.m"));
print_polynomial(d2.d,"d");
print_polynomial(d2.d,"d",strcat(strf,"_d_coef.m"));
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa",strcat(strf,"_aa_coef.m"));
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac",strcat(strf,"_ac_coef.m"));

save iir_frm_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was tol

% Done
toc;
diary off
movefile iir_frm_socp_slb_test.diary.tmp iir_frm_socp_slb_test.diary;
