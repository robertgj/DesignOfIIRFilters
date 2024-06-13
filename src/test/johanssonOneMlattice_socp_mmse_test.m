% johanssonOneMlattice_socp_mmse_test.m
% Copyright (C) 2019-2024 Robert G. Jenssen

test_common;

strf="johanssonOneMlattice_socp_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
verbose=true
ftol=1e-6
ctol=ftol

% Band-stopfilter specification
fapl=0.15,fasl=0.2,fasu=0.25,fapu=0.3
Wap=1,Was=1,delta_p=1e-6,delta_s=1e-6

% Band-stop filter from johansson_cascade_allpass_bandstop_test.m
fM_0 = [ -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443 ];
a0 = [    1.0000000000,  -0.5650802796,   1.6504647259,  -0.4790659039, ... 
          0.7284633026 ];
a1 = [    1.0000000000,  -0.2594839587,   0.6383172372 ];

% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0_0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0),a0);
[k1_0,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1),a1);

% Frequencies
nf=2000
wa=(0:nf)'*pi/nf;
napl=ceil(fapl*nf/0.5)+1;
nasl=floor(fasl*nf/0.5)+1;
nasu=ceil(fasu*nf/0.5)+1;
napu=floor(fapu*nf/0.5)+1;
Ad=[ones(napl,1);zeros(napu-napl-1,1);ones(nf-napu+2,1)];
Adu=[ones(nasl-1,1); ...
     delta_s*ones(nasu-nasl+1,1); ...
     ones(nf-nasu+1,1)];
Adl=[(1-delta_p)*ones(napl,1); ...
     zeros(napu-napl-1,1); ...
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
Azp=johanssonOneMlatticeAzp(wa,fM_0,k0_0,epsilon0,k1_0,epsilon1);
ax=plotyy(wa*0.5/pi,Azp,wa(nasl:nasu)*0.5/pi,Azp(nasl:nasu));
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
fMk_0_u=[10*ones(size(fM_0));rho*ones(size(k0_0));rho*ones(size(k1_0))];
fMk_0_l=-fMk_0_u;
fMk_0=[fM_0;k0_0;k1_0];
fMk_0_active=find(fMk_0~=0);

%
% SQP MMSE
%
tic;
[fM,k0,k1,opt_iter,func_iter,feasible] = ...
  johanssonOneMlattice_socp_mmse([],fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
                                 fMk_0_u,fMk_0_l,fMk_0_active,dmax, ...
                                 wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("fM,k0,k1(mmse) infeasible");
endif

% Plot MMSE response
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
ax=plotyy(wa*0.5/pi,Azp,wa(nasl:nasu)*0.5/pi,Azp(nasl:nasu));
axis(ax(1),[0 0.5 1-0.000005 1]);
axis(ax(2),[0 0.5 0 0.000005]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
title(sprintf(strt,"MMSE"));
print(strcat(strf,"_mmse"),"-dpdflatex");
close

% Amplitude and delay at local peaks
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
vAl=local_max(-Azp);
vAu=local_max(Azp);
wAzpS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AzpS=johanssonOneMlatticeAzp(wAzpS,fM,k0,epsilon0,k1,epsilon1);
printf("fM,k0,k1:fAzpS=[ ");printf("%f ",wAzpS'*0.5/pi);
printf(" ] (fs==1)\n");
printf("fM,k0,k1:AzpS=[ ");printf("%f ",20*log10(AzpS'));
printf(" ] (dB)\n");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"nf=%d %% Frequency points across the band\n",nf);
fprintf(fid,"length(fM_0)=%d %% distinct FIR coefficients\n",length(fM_0));
fprintf(fid,"length(k0)=%d %% Num. all-pass k0 coefficients\n",length(k0));
fprintf(fid,"length(k1)=%d %% Num. all-pass k1 coefficients\n",length(k1));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude lower pass band edge\n",fapl);
fprintf(fid,"fasl=%g %% Amplitude lower stop band edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude upper stop band edge\n",fasu);
fprintf(fid,"fapu=%g %% Amplitude upper pass band edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);
print_polynomial(fM,"fM");
print_polynomial(fM,"fM",strcat(strf,"_fM_coef.m"));
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));

eval(sprintf("save %s.mat fM_0 k0_0 epsilon0 k1_0 epsilon1 \
fapl fasl fasu fapu Wap Was dmax rho ftol fM k0 k1",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
