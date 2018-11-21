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
x0.a = [   0.0418768287,   0.1253136137,  -0.0092742932,  -0.2426909582, ... 
         0.0538014537,   0.5801324914,  -0.0097613656,  -0.0923803855, ... 
        -0.1924289439,   0.4564553540,   0.1606477612 ]';
x0.d = [   1.0000000000,   0.1908880861,   0.3413199220,   0.1571784725, ... 
        -0.0350985412,  -0.0660322625,   0.0534609864,  -0.0007309002, ... 
         0.0078723030,   0.0197733635,  -0.0047938982 ]';
x0.aa = [   0.0060379848,  -0.0040298808,  -0.0022741654,   0.0054309460, ... 
         -0.0009955357,  -0.0083507049,   0.0101126037,   0.0009513443, ... 
         -0.0122083759,   0.0080085776,   0.0118241834,  -0.0202323823, ... 
          0.0023860272,   0.0252928744,  -0.0242220753,  -0.0178278203, ... 
          0.0594428541,  -0.0330043116,  -0.1131026645,   0.3113778955, ... 
          0.5989316042,   0.3113778955,  -0.1131026645,  -0.0330043116, ... 
          0.0594428541,  -0.0178278203,  -0.0242220753,   0.0252928744, ... 
          0.0023860272,  -0.0202323823,   0.0118241834,   0.0080085776, ... 
         -0.0122083759,   0.0009513443,   0.0101126037,  -0.0083507049, ... 
         -0.0009955357,   0.0054309460,  -0.0022741654,  -0.0040298808, ... 
          0.0060379848 ]';
x0.ac = [   0.0113131768,  -0.0229066770,   0.0126781749,   0.0066503274, ... 
         -0.0099644240,  -0.0157655970,   0.0323348459,  -0.0068803943, ... 
         -0.0295630609,   0.0248947394,   0.0229263572,  -0.0503633393, ... 
          0.0174841615,   0.0413689350,  -0.0463887856,  -0.0222044025, ... 
          0.0861368796,  -0.0473847494,  -0.1104857626,   0.2904455150, ... 
          0.6296284888,   0.2904455150,  -0.1104857626,  -0.0473847494, ... 
          0.0861368796,  -0.0222044025,  -0.0463887856,   0.0413689350, ... 
          0.0174841615,  -0.0503633393,   0.0229263572,   0.0248947394, ... 
         -0.0295630609,  -0.0068803943,   0.0323348459,  -0.0157655970, ... 
         -0.0099644240,   0.0066503274,   0.0126781749,  -0.0229066770, ... 
          0.0113131768 ]';

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
Wtp=0.1 % Pass band delay weight
Wat=tol*tol; % Transition band weight
fas=0.31125 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=10 % Stop band amplitude weight

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
