% schurOneMAPlattice_frm_hilbert_socp_slb_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_hilbert_socp_slb_test.diary");
unlink("schurOneMAPlattice_frm_hilbert_socp_slb_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbert_socp_slb_test.diary.tmp

tic;

format compact

%
% Filter specification
%
n=800
maxiter=2000
verbose=false

% Initial filter from tarczynski_frm_halfband_test.m
tol=75e-6
ctol=tol
r0 = [   1.0000000000,   0.4650421403,  -0.0756662210,   0.0125742228, ... 
         0.0030944722,  -0.0100384056 ]';
aa0 = [ -0.0022730568,   0.0037199326,   0.0049034950,  -0.0046329239, ... 
        -0.0086841885,   0.0062298648,   0.0122190261,   0.0017956534, ... 
        -0.0266708058,  -0.0137096895,   0.0360235999,   0.0362740186, ... 
        -0.0501721957,  -0.0810254219,   0.0522745514,   0.3115883684, ... 
         0.4475813048,   0.3115883684,   0.0522745514,  -0.0810254219, ... 
        -0.0501721957,   0.0362740186,   0.0360235999,  -0.0137096895, ... 
        -0.0266708058,   0.0017956534,   0.0122190261,   0.0062298648, ... 
        -0.0086841885,  -0.0046329239,   0.0049034950,   0.0037199326, ... 
        -0.0022730568 ]';
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=0.76 % Peak-to-peak pass band delay ripple
Wtp=0.01 % Pass band delay weight
ppr=0.004*pi/2 % Peak-to-peak pass band phase ripple
Wpp=0.1 % Pass band phase weight

mr=length(r0)-1 % Model filter order
dmask=(length(aa0)-1)/2 % FIR masking filter delay
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)

% Convert to Hilbert
rm1=ones(size(r0));
rm1(2:2:end)=-1;
[k0,epsilon0,p0,~]=tf2schurOneMlattice(flipud(r0).*rm1,r0.*rm1);
dmask=(length(aa0)-1)/2;
u0=aa0(1:2:(dmask+1));
um1=ones(size(u0));
um1(2:2:end)=-1;
u0=u0.*um1;
v0=aa0(2:2:dmask);
vm1=ones(size(v0));
vm1(2:2:end)=-1;
v0=v0.*vm1;

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=floor(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
wa=w(nap:nas);
Asqd=ones(size(wa));
Asqdu=Asqd;
Asqdl=10^(-dBap/10)*ones(size(wa));
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Tdu=(tpr/2)*ones(size(wt));
Tdl=-Tdu;
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=pp*ones(size(wp));
Pdu=pp+(ppr/2)*ones(size(wp));
Pdl=pp-(ppr/2)*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Coefficient constraints
rho=127/128;
kuv_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

% Common strings
strf="schurOneMAPlattice_frm_hilbert_socp_slb_test";
strt=sprintf("FRM Hilbert %%s %%s : \
Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d",Mmodel,Dmodel,fap,fas,tp);

% Plot the initial response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"initial");

%
% FRM hilbert SOCP PCLS
%
tic;
[k2,u2,v2,slb_iter,socp_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_hilbert_slb ...
    (@schurOneMAPlattice_frm_hilbert_socp_mmse, ...
     k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
     maxiter,tol,ctol,verbose);
toc;
if feasible == 0 
  error("k2,u2,v2(pcls) infeasible");
endif

% Recalculate epsilon2 and p2
[epsilon2,p2] = schurOneMscale(k2);

% Plot the response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k2,epsilon2,p2,u2,v2,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"PCLS", ...
   wa,Asqdu,Asqdl,wt,Tdu,Tdl,wp,Pdu,Pdl);

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points\n",n);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"Mmodel=%d %% Model filter decimation\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Desired model filter passband delay\n",Dmodel);
fprintf(fid,"mr=%d %% Model filter order\n",mr);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBap=%g %% Pass band amplitude ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band amplitude weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"fts=%g %% Delay stop band edge\n",fts);
fprintf(fid,"tp=%d %% Nominal FRM filter group delay\n",tp);
fprintf(fid,"tpr=tp/%g %% Peak-to-peak pass band delay ripple\n",tp/tpr);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"fps=%g %% Phase stop band edge\n",fps);
fprintf(fid,"pp=%g*pi %% Nominal passband phase (adjusted for delay)\n",pp/pi);
fprintf(fid,"ppr=pi/%g %% Peak-to-peak pass band phase ripple\n",pi/ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(u2,"u2");
print_polynomial(u2,"u2",strcat(strf,"_u2_coef.m"));
print_polynomial(v2,"v2");
print_polynomial(v2,"v2",strcat(strf,"_v2_coef.m"));

save schurOneMAPlattice_frm_hilbert_socp_slb_test.mat ...
     r0 k0 epsilon0 p0 u0 v0 k2 epsilon2 p2 u2 v2 ...
     Mmodel Dmodel dmax rho tol ctol ...
     fap fas dBap Wap ftp fts tp tpr Wtp fpp fps pp ppr Wpp 

% Done
toc;
diary off
movefile schurOneMAPlattice_frm_hilbert_socp_slb_test.diary.tmp ...
         schurOneMAPlattice_frm_hilbert_socp_slb_test.diary;
