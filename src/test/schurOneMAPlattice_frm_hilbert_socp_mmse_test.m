% schurOneMAPlattice_frm_hilbert_socp_mmse_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice_frm_hilbert_socp_mmse_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;


%
% Initial filter from tarczynski_frm_halfband_test.m
%
r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
         0.0035706175,  -0.0098219303 ]';
aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
        -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
        -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
        -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
         0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
        -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
        -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
        -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
        -0.0019232288 ]';
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
% Filter specification
%
n=400
ftol=1e-10
ctol=ftol
maxiter=2000
verbose=true
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
dmask=2*length(v0); % FIR masking filter delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
Wap=2 % Pass band amplitude weight
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
Wtp=0.1 % Pass band delay weight
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-0.5 % Nominal passband phase (adjusted for delay)
Wpp=0.2 % Pass band phase weight

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
Asqdu=inf*ones(size(wa));
Asqdl=-Asqdu;
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Tdu=inf*ones(size(wt));
Tdl=-Tdu;
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=pp*pi*ones(size(wp));
Pdu=inf*ones(size(wp));
Pdl=-inf*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Coefficient constraints
rho=127/128;
kuv_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

% Common strings
strt=sprintf("FRM Hilbert %%s %%s : \
Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d",Mmodel,Dmodel,fap,fas,tp);

% Plot the initial response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"initial");

%
% FRM Hilbert SOCP MMSE
%
tic;
[k1,u1,v1,socp_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_hilbert_socp_mmse ...
    ([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
     maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("k1,u1,v1(mmse) infeasible");
endif

% Plot the response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k1,epsilon0,p0,u1,v1,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"MMSE");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points\n",n);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"Mmodel=%d %% Model filter decimation\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Desired model filter passband delay\n",Dmodel);
fprintf(fid,"mr=%d %% Model filter order\n",mr);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Wap=%g %% Pass band amplitude weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"fts=%g %% Delay stop band edge\n",fts);
fprintf(fid,"tp=%g %% Nominal FRM filter group delay\n",tp);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"fps=%g %% Phase stop band edge\n",fps);
fprintf(fid,"pp=%g %% Nominal passband phase (rad./pi,adj. for delay)\n",pp);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fclose(fid);

print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(u1,"u1");
print_polynomial(u1,"u1",strcat(strf,"_u1_coef.m"));
print_polynomial(v1,"v1");
print_polynomial(v1,"v1",strcat(strf,"_v1_coef.m"));

eval(sprintf("save %s.mat r0 u0 v0 k0 epsilon0 p0 k1 u1 v1 Mmodel Dmodel dmax \
rho ftol ctol fap fas Wap ftp fts tp Wtp fpp fps pp Wpp",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
