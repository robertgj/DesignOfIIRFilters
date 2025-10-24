% schurOneMPAlatticeDelay_socp_slb_lowpass_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

% Design a lowpass filter consisting of the parallel combination of a
% Schur one-multiplier lattice allpass filter and a delay.

test_common;

strf="schurOneMPAlatticeDelay_socp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=5000
verbose=false

for M=1:3,

  % Low pass filter specification
  difference=false
  n=1000 % Frequency points across the band
  if M==1,
    % As for parallel_allpass_delay_socp_slb_test.m
    tol=1e-5 % Tolerance on coefficient update vector
    ctol=1e-8 % Tolerance on constraints
    m=12 % Allpass filter denominator order
    DD=11 % Parallel delay
    fap=0.15 % Pass band amplitude response edge
    dBap=0.2 % Pass band amplitude response ripple
    Wap=1 % Pass band amplitude response weight
    Wat=0 % Transition band amplitude response weight
    fas=0.20 % Stop band amplitude response edge
    dBas=66 % Stop band amplitude response ripple
    Was=1000 % Stop band amplitude response weight
  elseif M==2
    tol=1e-6 % Tolerance on coefficient update vector
    ctol=1e-8 % Tolerance on constraints
    m=5 % Allpass filter denominator order
    DD=4 % Parallel delay
    fap=0.10 % Pass band amplitude response edge
    dBap=0.07 % Pass band amplitude response ripple
    Wap=0.1 % Pass band amplitude response weight
    Wat=0 % Transition band amplitude response weight
    fas=0.20 % Stop band amplitude response edge
    dBas=49.4 % Stop band amplitude response ripple
    Was=200 % Stop band amplitude response weight
  else
    tol=1e-6 % Tolerance on coefficient update vector
    ctol=1e-8 % Tolerance on constraints
    m=4 % Allpass filter denominator order
    DD=3 % Parallel delay
    fap=0.10 % Pass band amplitude response edge
    dBap=0.32 % Pass band amplitude response ripple
    Wap=1 % Pass band amplitude response weight
    Wat=0 % Transition band amplitude response weight
    fas=0.20 % Stop band amplitude response edge
    dBas=38.6 % Stop band amplitude response ripple
    Was=1000 % Stop band amplitude response weight
  endif

  % Initial all-pass filter
  Da0=allpass_delay_wise_lowpass(m,DD,fap,fas,Was);
  
  % Amplitude constraints
  wa=(0:(n-1))'*pi/n;
  nap=ceil(n*fap/0.5)+1;
  nas=floor(n*fas/0.5)+1;
  Asqd=[ones(nap,1); zeros(n-nap,1)];
  Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
  Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
  Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

  % Group delay constraints
  wt=[];Td=[];Tdu=[];Tdl=[];Wt=[];

  % Phase constraints
  wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

  % dAsqdw constraints
  wd=[];Dd=[];Ddu=[];Ddl=[];Wd=[];

  % Lattice decomposition of Da0
  A1k0=schurdecomp(Da0);
  A1epsilon0=ones(length(A1k0),1);
  A1p0=ones(length(A1k0),1);

  % Delay 
  A2k0=zeros(DD,1);
  A2epsilon=ones(DD,1);
  A2p=ones(DD,1);

  % Linear constraints
  dmax=inf;
  rho=127/128;
  k0=[A1k0(:);A2k0(:)];
  k_u=rho*ones(size(k0));
  k_l=-k_u;
  k_active=find(k0~=0);

  %
  % SOCP PCLS
  %
  try
    tic
    feasible=false;
    [A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
       schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                              A1k0,A1epsilon0,A1p0,A2k0,A2epsilon,A2p, ...
                              difference, ...
                              k_u,k_l,k_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp, ...
                              wd,Dd,Ddu,Ddl,Wd, ...
                              maxiter,tol,ctol,verbose);
    toc
  catch
    feasible=false;
    warning("Caught schurOneMPAlattice_slb() : %s", lasterr());
  end_try_catch
  if feasible == false
    error("A1k(pcls) infeasible");
  endif
  
  % Recalculate A1epsilon, A1p
  [A1epsilon,A1p]=schurOneMscale(A1k);
  A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';

  % Error
  Esq = schurOneMPAlatticeEsq(A1k,ones(size(A1k)),ones(size(A1k)), ...
                              zeros(DD,1),ones(DD,1),ones(DD,1),false, ...
                              wa,Asqd,Wa);
  printf("A1,A2,m=%d,DD=%d,Esq=%g\n",m,DD,Esq);

  % Amplitude and delay at local peaks
  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  vAl=local_max(Asqdl-Asq);
  vAu=local_max(Asq-Asqdu);
  wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
  AsqS=schurOneMPAlatticeAsq(wAsqS,A1k,A1epsilon,A1p, ...
                             A2k,A2epsilon,A2p,difference);
  printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

  % Plot response
  ax=plotyy(wa(1:nap)*0.5/pi,10*log10(Asq(1:nap)), ...
            wa(nas:end)*0.5/pi,10*log10(Asq(nas:end)));
  ylabel("Amplitude(dB)");
  xlabel("Frequency");
  if M==1
    axis(ax(1),[0 0.5 -dBap 0]);
    axis(ax(2),[0 0.5 -70 -62]);
  elseif M==2
    axis(ax(1),[0 0.5 -0.1 0]);
    axis(ax(2),[0 0.5 -54 -44]);
  else
    axis(ax(1),[0 0.5 -0.5 0]);
    axis(ax(2),[0 0.5 -40 -35]); 
  endif
  grid("on");
  strt=sprintf("Parallel all-pass filter and delay : m=%d, DD=%d",m, DD);
  title(strt);
zticks([]);
  print(sprintf("%s_m_%d_response",strf,m),"-dpdflatex");
  close

  Da1=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
  Na1=0.5*(conv([zeros(1,(DD)),1],Da1)+[fliplr(Da1),zeros(1,(DD))]);
  [H,w]=freqz(Na1,Da1,wa);
  if max(abs(diff((abs(H).^2)-Asq)))>20*eps
    error("max(abs(diff((abs(H).^2)-Asq)))>20*eps");
  endif
  zplane(Na1,[zeros(1,length(Na1)-length(Da1)),Da1])
  title(strt);
  grid("on");
zticks([]);
  print(sprintf("%s_m_%d_pz",strf,m),"-dpdflatex");
  close
  
  %
  % Save the results
  %
  fid=fopen(sprintf("%s_m_%d_spec.m",strf,m),"wt");
  fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
  fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
  fprintf(fid,"n=%d %% Frequency points across the band\n",n);
  fprintf(fid,"m=%d %% Allpass filter order\n",m);
  fprintf(fid,"DD=%d %% Delay order \n",DD);
  fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
  fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
  fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
  fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Wat=%d %% Transition pass band weight\n",Wat);
  fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
  fprintf(fid,"dBas=%g %% amplitude stop band peak-to-peak ripple\n",dBas);
  fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
  fclose(fid);

  print_polynomial(A1k0,"A1k0");
  print_polynomial(A1k0,"A1k0",sprintf("%s_m_%d_A1k0_coef.m",strf,m));

  print_polynomial(A1k,"A1k");
  print_polynomial(A1k,"A1k",sprintf("%s_m_%d_A1k_coef.m",strf,m));
  
  print_polynomial(A1epsilon,"A1epsilon");
  print_polynomial(A1epsilon,"A1epsilon", ...
                   sprintf("%s_m_%d_A1epsilon_coef.m",strf,m),"%2d");
  
  print_polynomial(A1p,"A1p");
  print_polynomial(A1p,"A1p",sprintf("%s_m_%d_A1p_coef.m",strf,m));

  print_polynomial(Da1,"Da1");
  print_polynomial(Da1,"Da1",sprintf("%s_m_%d_Da1_coef.m",strf,m));
  
  print_polynomial(Na1,"Na1");
  print_polynomial(Na1,"Na1",sprintf("%s_m_%d_Na1_coef.m",strf,m));

  eval(sprintf(["save %s_m_%d.mat ...\n", ...
 "   rho tol ctol difference n m DD ...\n", ...
 "   fap dBap Wap Wat fas dBas Was ...\n", ...
 "   Da0 A1k A1epsilon A1p Na1 Da1"],strf,m));
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
