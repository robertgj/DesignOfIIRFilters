% iir_frm_allpass_socp_slb_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("iir_frm_allpass_socp_slb_test.diary");
delete("iir_frm_allpass_socp_slb_test.diary.tmp");
diary iir_frm_allpass_socp_slb_test.diary.tmp

tic;


%
% Initial filter is based on the filters found by tarczynski_frm_allpass_test.m
%
x0.R=1;
x0.r=[   1.0000000000,   0.2459795566,   0.4610947857,  -0.1206398420, ... 
        -0.0518355550,   0.0567634483,  -0.0264386549,   0.0246267271, ... 
        -0.0176437270,  -0.0008974729,   0.0056956381 ]';
x0.aa=[ -0.0216588504,  -0.0114618315,   0.0302611209,  -0.0043408321, ... 
        -0.0274279593,   0.0062386856,   0.0166035962,  -0.0208670992, ... 
        -0.0036770815,   0.0566015372,   0.0039899993,  -0.0683299841, ... 
         0.0358708912,   0.0511704141,  -0.0490317610,  -0.0006425193, ... 
         0.0797439710,  -0.0690263959,  -0.1272015380,   0.2921723028, ... 
         0.6430650464,   0.2921723028,  -0.1272015380,  -0.0690263959, ... 
         0.0797439710,  -0.0006425193,  -0.0490317610,   0.0511704141, ... 
         0.0358708912,  -0.0683299841,   0.0039899993,   0.0566015372, ... 
        -0.0036770815,  -0.0208670992,   0.0166035962,   0.0062386856, ... 
        -0.0274279593,  -0.0043408321,   0.0302611209,  -0.0114618315, ... 
        -0.0216588504 ]';
x0.ac=[ -0.0181078194,   0.0563970997,   0.1769164319,   0.0607733538, ... 
        -0.0221620117,  -0.0050415353,   0.0112963303,  -0.0009704899, ... 
        -0.0074583106,  -0.0391109460,   0.1410234146,   0.4815173162, ... 
         0.1799696079,  -0.0814357412,  -0.0115214971,   0.0590494998, ... 
        -0.0510521399,  -0.0105302211,   0.0627620289,  -0.0675640305, ... 
        -0.0255600918,  -0.0675640305,   0.0627620289,  -0.0105302211, ... 
        -0.0510521399,   0.0590494998,  -0.0115214971,  -0.0814357412, ... 
         0.1799696079,   0.4815173162,   0.1410234146,  -0.0391109460, ... 
        -0.0074583106,  -0.0009704899,   0.0112963303,  -0.0050415353, ... 
        -0.0221620117,   0.0607733538,   0.1769164319,   0.0563970997, ... 
        -0.0181078194 ]';

%
% Filter specification
%
n=1000;
tol=2e-5
ctol=tol
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
Wtp=0.02 % Pass band delay weight
fas=0.3105 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=100 % Stop band amplitude weight
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
strt=sprintf("FRM allpass/delay %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,\
Vr=%d,Qr=%d,Rr=%d,na=%d,nc=%d",Mmodel,Dmodel,fap,fas,Vr,Qr,Rr,na,nc);
strf="iir_frm_allpass_socp_slb_test";

% Plot the initial response
iir_frm_allpass_socp_slb_plot(x0,na,nc,Mmodel,Dmodel, ...
                              w,fap,strt,strcat(strf,"_%s_%s"),"initial");

%
% SOCP PCLS 
%
[d2k,slb_iter,opt_iter,func_iter,feasible] = ...
iir_frm_allpass_slb(@iir_frm_allpass_socp_mmse, ...
                    x0k,ru,rl,Vr,Qr,Rr,na,nc,Mmodel,Dmodel, ...
                    w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
                    maxiter,tol,ctol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_allpass_vec_to_struct(d2k,Vr,Qr,Rr,na,nc);
% Plot the PCLS response
iir_frm_allpass_socp_slb_plot(d2,na,nc,Mmodel,Dmodel,w, ...
                              fap,strt,strcat(strf,"_%s_%s"),"PCLS");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
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
print_polynomial(d2.r,"r",strcat(strf,"_r_coef.m"));
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa",strcat(strf,"_aa_coef.m"));
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac",strcat(strf,"_ac_coef.m"));
save iir_frm_allpass_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was rho tol ctol

% Done
toc;
diary off
movefile iir_frm_allpass_socp_slb_test.diary.tmp ...
         iir_frm_allpass_socp_slb_test.diary;
