% johanssonOneMlattice_socp_slb_bandstop_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("johanssonOneMlattice_socp_slb_bandstop_test.diary");
delete("johanssonOneMlattice_socp_slb_bandstop_test.diary.tmp");
diary johanssonOneMlattice_socp_slb_bandstop_test.diary.tmp

script_id=tic;

maxiter=2000
tol=1e-7
ctol=2e-8
verbose=false

% Band-stopfilter specification
fapl=0.15,fasl=0.2,fasu=0.25,fapu=0.3
Wap=1,Was=10,delta_p=1e-3,delta_s=1e-6

% Common strings
strf="johanssonOneMlattice_socp_slb_bandstop_test";
strt=sprintf...
  ("%%s:fapl=%g,fasl=%g,fasu=%g,fapu=%g,delta_p=%g,delta_s=%g,Wap=%g,Was=%g",
   fapl,fasl,fasu,fapu,delta_p,delta_s,Wap,Was);

% Band-stop filter from johansson_cascade_allpass_bandstop_test.m
johansson_cascade_allpass_bandstop_test_bsA0_coef;
johansson_cascade_allpass_bandstop_test_bsA1_coef;
johansson_cascade_allpass_bandstop_test_f1_coef;
fM_0=f1(1:(length(f1)+1)/2);

% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0_0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(bsA0),bsA0);
[k1_0,epsilon1,~,~]=tf2schurOneMlattice(fliplr(bsA1),bsA1);

% Frequencies
nf=2000
wa=(0:nf)'*pi/nf;
napl=ceil(fapl*nf/0.5)+1;
nasl=floor(fasl*nf/0.5)+1;
nasu=ceil(fasu*nf/0.5)+1;
napu=floor(fapu*nf/0.5)+1;
Ad=[ones(napl,1);zeros(napu-napl-1,1);ones(nf-napu+2,1)];
Adu=[ones(nasl-1,1); ...
     delta_s*ones(nasu-nasl+1,1)-ctol; ...
     ones(nf-nasu+1,1)];
Adl=[(1-delta_p)*ones(napl,1); ...
     zeros(napu-napl-1,1)+ctol; ...
     (1-delta_p)*ones(nf-napu+2,1)];
Wa=[Wap*ones(napl,1); ...
    zeros(nasl-napl-1,1); ...
    Was*ones(nasu-nasl+1,1); ...
    zeros(napu-nasu-1,1); ...
    Wap*ones(nf-napu+2,1)];
nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...
         nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];
printf("nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...\n");
printf("       nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];\n");
printf("nchk=[");printf("%d ",nchk(1:7));printf(" ... \n");
printf("        ");printf("%d ",nchk(8:end));printf("];\n");
printf("wa(nchk)=[ ");printf("%g ",wa(nchk(1:7))*0.5/pi);printf(" ... \n");
printf("             ");printf("%g ",wa(nchk(8:end))*0.5/pi);printf("]*2*pi;\n");
printf("Ad(nchk)=[ ");printf("%d ",Ad(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Ad(nchk(8:end)));printf("];\n");
printf("Adu(nchk)=[");printf("%d ",Adu(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Adu(nchk(8:end)));printf("];\n");
printf("Adl(nchk)=[ ");printf("%d ",Adl(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Adl(nchk(8:end)));printf("];\n");
printf("Wa(nchk)=[ ");printf("%d ",Wa(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Wa(nchk(8:end)));printf("];\n");

% Plot initial response
strt=sprintf ("Johansson one-multiplier lattice band-stop filter SOCP \
%%s response : fapl=%g,fasl=%g,fasu=%g,fapu=%g",fapl,fasl,fasu,fapu);
Azp_0=johanssonOneMlatticeAzp(wa,fM_0,k0_0,epsilon0,k1_0,epsilon1);
ax=plotyy(wa*0.5/pi,Azp_0,wa(nasl:nasu)*0.5/pi,Azp_0(nasl:nasu));
axis(ax(1),[0 0.5 1-0.000005 1]);
axis(ax(2),[0 0.5 0 0.000005]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
title(sprintf(strt,"initial"));
print(strcat(strf,"_init"),"-dpdflatex");
close

% Constraints on the coefficients
dmax=0
rho=127/128
fM_0=fM_0(:);
k0_0=k0_0(:);
k1_0=k1_0(:);
fMk_0=[fM_0;k0_0;k1_0];
fMk_u=[10*ones(size(fM_0));rho*ones(size(k0_0));rho*ones(size(k1_0))];
fMk_l=-fMk_u;
fMk_active=find(fMk_0~=0);

%
% SOCP PCLS pass
%
run_id=tic;
[fM,k0,k1,slb_iter,opt_iter,func_iter,feasible] = ...
  johanssonOneMlattice_slb(@johanssonOneMlattice_socp_mmse, ...
                           fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
                           fMk_u,fMk_l,fMk_active,dmax, ...
                           wa,Ad,Adu,Adl,Wa,maxiter,tol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("fM,k0,k1(mmse) infeasible");
endif

strt=sprintf ("Johansson one-multiplier lattice band-stop filter SOCP \
%%s response : fapl=%g,fasl=%g,fasu=%g,fapu=%g",fapl,fasl,fasu,fapu);
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
ax=plotyy(wa*0.5/pi,Azp,wa(nasl:nasu)*0.5/pi,Azp(nasl:nasu));
axis(ax(1),[0 0.5 1-delta_p 1]);
axis(ax(2),[0 0.5 0 delta_s]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
title(sprintf(strt,"PCLS"));
print(strcat(strf,"_pcls"),"-dpdflatex");
close

%
% PCLS amplitude and delay at local peaks
%
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
vAl=local_max(Adl-Azp);
vAu=local_max(Azp-Adu);
wAzpS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AzpS=johanssonOneMlatticeAzp(wAzpS,fM,k0,epsilon0,k1,epsilon1);
printf("fMk0k1:fAzpS=[ ");printf("%g ",wAzpS'*0.5/pi);printf(" ] (fs==1)\n");
printf("fMk0k1:AzpS=[ ");printf("%g ",AzpS');printf(" ]\n");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nf=%d %% Frequency points across the band\n",nf);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"delta_p=%d %% Amplitude pass band peak ripple\n",delta_p);
fprintf(fid,"delta_s=%d %% Amplitude stop band peak ripple\n",delta_s);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

f=fM(:);
f=[f;f((end-1):-1:1)];
print_polynomial(f,"f");
print_polynomial(f,"f",strcat(strf,"_f_coef.m"));
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(epsilon0,"epsilon0");
print_polynomial(epsilon0,"epsilon0",strcat(strf,"_epsilon0_coef.m"));
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(epsilon1,"epsilon1");
print_polynomial(epsilon1,"epsilon1",strcat(strf,"_epsilon1_coef.m"));
save johanssonOneMlattice_socp_slb_bandstop_test.mat fapl fasl fasu fapu ...
     delta_p Wap delta_s Was dmax rho tol ctol fM k0 epsilon0 k1 epsilon1

% Done
toc(script_id);
diary off
movefile johanssonOneMlattice_socp_slb_bandstop_test.diary.tmp ...
         johanssonOneMlattice_socp_slb_bandstop_test.diary;
