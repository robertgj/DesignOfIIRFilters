% schurOneMlattice_socp_slb_lowpass_R2_alternate_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_R2_alternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=1e-7
maxiter=10000
verbose=false

% Lowpass filter specification (QEMU fails for dBap=0.05)
norder=12,R=2
fap=0.1,dBap=0.06,Wap=1,Wat=ftol
fas=0.2,dBas=60.5,Wasi=1e3,Was=1e6

% Squared-magnitude constraints
n=1000;
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Find initial filter
Adi=[ones(nap,1); zeros(n-nap,1)];
Wai=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Wasi*ones(n-nas+1,1)];
NDi=[0.1;zeros(norder+(norder/2),1)];
WISEJ([],norder,norder/2,R,wa,Adi,Wai);
tol=1e-9;
maxiter=10000;
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NDi,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Extract initial filter polynomials
N0=ND0(1:(norder+1));
D0=[1;kron(ND0((norder+2):end),[0;1])];

% Plot initial response
[H0,w]=freqz(N0,D0,1024);
N0=N0/max(abs(H0));
plot(w*0.5/pi,20*log10(abs(H0)))
ylabel("Amplitude(dB)");
axis([0 0.5 -120 10])
xlabel("Frequency");
grid("on");
strI=sprintf(["Schur one-multiplier lattice lowpass filter initial ", ...
              "response : fap=%g,fas=%g"],fap,fas);
title(strI);
zticks([]);
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
p_ones=ones(size(p0));

% Constraints on the coefficients
dmax=0; % For compatibility with SQP
rho=127/128;
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];
  
%
% SOCP PCLS
%
tic;
feasible=false;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                       k0,epsilon0,p_ones,c0,kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa, ...
                       [],[],[],[],[], ...
                       [],[],[],[],[], ...
                       [],[],[],[],[], ...
                       maxiter,ftol,ctol,verbose);
toc;
if ~feasible 
  error("k2p,c2p(pcls) infeasible");
endif
 
% Recalculate epsilon2, p2 and c2
[N2,D2]=schurOneMlattice2tf(k2p,epsilon0,ones(size(p0)),c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);

% Calculate response
Asq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
T2=schurOneMlatticeT(wa,k2,epsilon2,p2,c2);

% Check transfer function
H2=freqz(N2,D2,wa);
if max(abs((abs(H2))-sqrt(Asq2))) > 100*eps
  error("max(abs((abs(H2))-sqrt(Asq2)))(%g*eps) > 100*eps", ...
        max(abs((abs(H2))-sqrt(Asq2)))/eps);
endif

% Plot response
subplot(211)
ax=plotyy(wa(1:nap)*0.5/pi,10*log10(Asq2(1:nap)), ...
          wa(nas:end)*0.5/pi,10*log10(Asq2(nas:end)));
% Set axis
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 -0.08 0.02]);
axis(ax(2),[0 0.5 -66 -56]);
grid("on");
strP=sprintf(["Lowpass Schur one-multiplier R=2 filter : ", ...
 "fap=%g,dBap=%g,fas=%g,dBas=%g"],fap,dBap,fas,dBas);
title(strP);
ylabel("Amplitude(dB)");
grid("on");
subplot(212);
plot(wa*0.5/pi,T2);
axis([0 0.5 0 20]);
grid("on");
ylabel("Group-delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(N2),qroots(D2));
title(strP);
zticks([]);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Amplitude at local peaks
vAl=local_max(Asqdl-Asq2);
vAu=local_max(Asq2-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k2,epsilon2,p2,c2);
printf("k2,c2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k2,c2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on WISEJ convergence\n",tol);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"norder=%d %% Filter order\n",norder);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"%% length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"%% length(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",length(k0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasi=%g %% Amplitude stop band weight (initial filter)\n",Wasi);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf(["save %s.mat tol ftol ctol rho maxiter ", ...
              "norder fap dBap Wap Wat fas dBas Wasi Was ", ...
              "N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
