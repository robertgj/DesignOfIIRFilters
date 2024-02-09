% schurOneMPAlatticeDelay_socp_slb_lowpass_test.m
% Copyright (C) 2024 Robert G. Jenssen

% Design a lowpass filter consisting of the parallel combination of a
% Schur one-multiplier lattice allpass filter and a delay.

test_common;

strf="schurOneMPAlatticeDelay_socp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

function Da0=schurOneMPAlatticeDelay_socp_slb_lowpass_init(m,DD,fap,fas)
  maxiter=5000;
  % Frequency points
  n=1000;
  fplot=0.5*(0:(n-1))'/n;
  wplot=2*pi*fplot;
  nap=ceil(fap*n/0.5)+1;
  nas=floor(fas*n/0.5)+1;
  Wap=1;
  Was=100;

  % Frequency vectors
  Ad=[ones(nap,1);zeros(n-nap,1)];
  Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
  Td=zeros(n,1);
  Wt=zeros(n,1);

  % Unconstrained minimisation
  R=1;
  polyphase=false;
  tol=1e-9;
  ai=[-0.9;zeros(m-1,1)];
  WISEJ_DA([],R,DD,polyphase,Ad,Wa,Td,Wt);
  opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
  [a0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_DA,ai,opt);
  if (INFO == 1)
    printf("Converged to a solution point.\n");
  elseif (INFO == 2)
    printf("Last relative step size was less that TolX.\n");
  elseif (INFO == 3)
    printf("Last relative decrease in function value was less than TolF.\n");
  elseif (INFO == 0)
    printf("Iteration limit exceeded.\n");
  elseif (INFO == -1)
    printf("Algorithm terminated by OutputFcn.\n");
  elseif (INFO == -3)
    printf("The trust region radius became excessively small.\n");
  else
    error("Unknown INFO value.\n");
  endif
  printf("Function value=%f\n", FVEC);
  printf("fminunc iterations=%d\n", OUTPUT.iterations);
  printf("fminunc successful=%d??\n", OUTPUT.successful);
  printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

  % Create the initial polynomials
  a0=a0(:);
  Da0=[1;kron(a0,[zeros(R-1,1);1])];
endfunction
  
maxiter=5000
verbose=false

for M=1:2,

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
  else
    tol=1e-6 % Tolerance on coefficient update vector
    ctol=1e-8 % Tolerance on constraints
    m=5 % Allpass filter denominator order
    DD=4 % Parallel delay
    fap=0.10 % Pass band amplitude response edge
    dBap=0.2 % Pass band amplitude response ripple
    Wap=1 % Pass band amplitude response weight
    Wat=0 % Transition band amplitude response weight
    fas=0.20 % Stop band amplitude response edge
    dBas=50 % Stop band amplitude response ripple
    Was=1000 % Stop band amplitude response weight
  endif
  
  Da0=schurOneMPAlatticeDelay_socp_slb_lowpass_init(m,DD,fap,fas);
  
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
  tic
  [A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                           A1k0,A1epsilon0,A1p0,A2k0,A2epsilon,A2p, ...
                           difference, ...
                           k_u,k_l,k_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
  if feasible == 0 
    error("A1k(pcls) infeasible");
  endif
  toc
  
  % Recalculate A1epsilon, A1p
  [A1epsilon,A1p]=schurOneMscale(A1k);
  A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';

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
  axis(ax(1),[0 0.5 -dBap 0]);
  if M==1
    axis(ax(2),[0 0.5 -70 -62]);
  else
    axis(ax(2),[0 0.5 -60 -40]);
  endif
  grid("on");
  strt=sprintf("Parallel all-pass filter and delay : m=%d, DD=%d",m, DD);
  title(strt);
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
  fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
  fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Wat=%d %% Transition pass band weight\n",Wat);
  fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
  fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
  fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
  fclose(fid);

  print_polynomial(A1k,"A1k");
  print_polynomial(A1k,"A1k",sprintf("%s_m_%d_A1k_coef.m",strf,m));
  print_polynomial(A1epsilon,"A1epsilon");
  print_polynomial(A1epsilon,"A1epsilon", ...
                   sprintf("%s_m_%d_A1epsilon_coef.m",strf,m),"%2d");
  print_polynomial(A1p,"A1p");
  print_polynomial(A1p,"A1p",sprintf("%s_m_%d_A1p_coef.m",strf,m));

  Da1=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
  print_polynomial(Da1,"Da1");
  print_polynomial(Da1,"Da1",sprintf("%s_m_%d_Da1_coef.m",strf,m));

  eval(sprintf("save %s_m_%d.mat ...\n\
   rho tol ctol difference n m DD ...\n\
   fap dBap Wap Wat fas dBas Was ...\n\
   Da0 A1k A1epsilon A1p Da1",strf,m));
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
