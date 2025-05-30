% schurOneMAPlattice_frm_hilbert_socp_slb_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice_frm_hilbert_socp_slb_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;


%
% Filter specification
%
n=800
maxiter=2000
verbose=false

% Initial filter from tarczynski_frm_halfband_test.m
tarczynski_frm_halfband_test_r0_coef;
tarczynski_frm_halfband_test_aa0_coef;

ftol=75e-6
ctol=ftol
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=0.76 % Peak-to-peak pass band delay ripple
Wtp=0.02 % Pass band delay weight
ppr=0.002 % Peak-to-peak pass band phase ripple (rad./pi)
pp=-0.5 % Nominal passband phase (rad./pi, adjusted for delay)
Wpp=0.2 % Pass band phase weight

mr=length(r0)-1 % Model filter order
dmask=(length(aa0)-1)/2 % FIR masking filter delay(samples)
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay(samples)
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge

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
Pd=pp*pi*ones(size(wp));
Pdu=(pp*pi)+(ppr*pi/2)*ones(size(wp));
Pdl=(pp*pi)-(ppr*pi/2)*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Coefficient constraints
rho=127/128;
kuv_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

% Common strings
strt=sprintf(["FRM Hilbert %%s %%s : ", ...
 "Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d,tpr=%g,ppr=%g"],
             Mmodel,Dmodel,fap,fas,tp,tpr,ppr);

% Plot the initial response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"initial");

%
% FRM hilbert SOCP PCLS
%
try
  tic;
  feasible=false;
  [k2,u2,v2,slb_iter,socp_iter,func_iter,feasible] = ...
    schurOneMAPlattice_frm_hilbert_slb ...
      (@schurOneMAPlattice_frm_hilbert_socp_mmse, ...
       k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
       maxiter,ftol,ctol,verbose);
  toc;
catch
  feasible=false;
  warning("Caught schurOneMPAlattice_slb!");
end_try_catch
if feasible == false 
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
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points\n",n);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
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
fprintf(fid,"tp=%g %% Nominal FRM filter group delay\n",tp);
fprintf(fid,"tpr=tp/%g %% Peak-to-peak pass band delay ripple\n",tp/tpr);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"fps=%g %% Phase stop band edge\n",fps);
fprintf(fid,"pp=%g %% Nominal passband phase(rad./pi)(adjusted for delay)\n",pp);
fprintf(fid,"ppr=%g %% Peak-to-peak pass band phase ripple(rad./pi)\n",ppr);
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

eval(sprintf(["save %s.mat r0 k0 epsilon0 p0 u0 v0 k2 epsilon2 p2 u2 v2 ", ...
 "Mmodel Dmodel dmax rho ftol ctol fap fas dBap Wap ftp fts tp tpr Wtp ", ...
 "fpp fps pp ppr Wpp"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
