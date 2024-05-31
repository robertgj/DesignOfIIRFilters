% schurOneMPAlatticeDelay_socp_slb_lowpass_flat_delay_test.m
% Copyright (C) 2024 Robert G. Jenssen

% Design a lowpass filter consisting of the parallel combination of a
% Schur one-multiplier lattice allpass filter and a delay and having an
% approximately flat pass-band delay.

test_common;

strf="schurOneMPAlatticeDelay_socp_slb_lowpass_flat_delay_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

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
    fap=0.1 % Pass band amplitude response edge
    dBap=0.00001 % Pass band amplitude response ripple
    Wap=1 % Pass band amplitude response weight
    Wat=0 % Transition band amplitude response weight
    fas=0.20 % Stop band amplitude response edge
    dBas=50 % Stop band amplitude response ripple
    Was=1000 % Stop band amplitude response weight
    td=DD % Nominal pass band delay
    tdr=0.04 % Pass band delay peak-to-peak ripple
    ftp=0.1 % Pass band delay response edge
    Wtp=10 % Pass band delay weight
  else
    tol=1e-6 % Tolerance on coefficient update vector
    ctol=1e-8 % Tolerance on constraints
    m=5 % Allpass filter denominator order
    DD=4 % Parallel delay
    fap=0.10 % Pass band amplitude response edge
    dBap=0.001 % Pass band amplitude response ripple
    Wap=1 % Pass band amplitude response weight
    Wat=0 % Transition band amplitude response weight
    fas=0.25 % Stop band amplitude response edge
    dBas=40 % Stop band amplitude response ripple
    Was=200 % Stop band amplitude response weight
    td=DD % Nominal pass band delay
    tdr=1 % Pass band delay peak-to-peak ripple
    ftp=fap % Pass band delay response edge
    Wtp=10 % Pass band delay weight
  endif

  % Amplitude constraints
  wa=(0:(n-1))'*pi/n;
  nap=ceil(n*fap/0.5)+1;
  nas=floor(n*fas/0.5)+1;
  Asqd=[ones(nap,1); zeros(n-nap,1)];
  Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
  Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
  Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

  % Group delay constraints
  ntp=floor(ftp*n/0.5)+1;
  wt=wa(1:ntp);
  Td=td*ones(ntp,1);
  Tdu=(td+(tdr/2))*ones(ntp,1);
  Tdl=(td-(tdr/2))*ones(ntp,1);
  Wt=Wtp*ones(ntp,1);

  % Phase constraints
  wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

  % Initial all-pass filter
  Da0=schurOneMPAlatticeDelay_wise_lowpass(m,DD,fap,fas,Was,td,ftp,Wtp);
  
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
                              wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
    toc
  catch
    feasible=false;
    warning("Caught schurOneMPAlattice_slb() : %s", lasterr().message);
  end_try_catch
  if feasible == false
    error("A1k(pcls) infeasible");
  endif
  
  % Recalculate A1epsilon, A1p
  [A1epsilon,A1p]=schurOneMscale(A1k);
  A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';

  % Amplitude at local peaks
  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  vAl=local_max(Asqdl-Asq);
  vAu=local_max(Asq-Asqdu);
  wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
  AsqS=schurOneMPAlatticeAsq(wAsqS,A1k,A1epsilon,A1p, ...
                             A2k,A2epsilon,A2p,difference);
  printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

  % Delay at local peaks
  T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  vTl=local_max(Tdl-T);
  vTu=local_max(T-Tdu);
  wTS=unique([wt(vTl);wt(vTu);wt([1,ntp])]);
  TS=schurOneMPAlatticeT(wTS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  printf("A1,A2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("A1,A2:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");
  T=schurOneMPAlatticeT(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  
  % Plot response
  subplot(211);
  ax=plotyy(wa(1:nas)*0.5/pi,10*log10(Asq(1:nas)), ...
            wa(nas:end)*0.5/pi,10*log10(Asq(nas:end)));
  if M==1
    axis(ax(1),[0 0.5 dBap*[-1 1]]);
    axis(ax(2),[0 0.5 -dBas+(10*[-1 1])]);
  else
    axis(ax(1),[0 0.5 dBap*[-1 1]]);
    axis(ax(2),[0 0.5 -50 -30]);
  endif
  strt=sprintf("Parallel all-pass filter and delay : m=%d,DD=%d,td=%g",m,DD,td);
  title(strt);
  grid("on");
  ylabel("Amplitude(dB)");
  subplot(212);
  plot(wa(1:nas)*0.5/pi,T(1:nas));
  axis([0 0.5 td-tdr td+tdr]);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s_m_%d_response",strf,m),"-dpdflatex");
  close

  Da1=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
  Na1=0.5*(conv([zeros(1,DD),1],Da1)+[fliplr(Da1),zeros(1,DD)]);
  [H,w]=freqz(Na1,Da1,wa);
  if max(abs(diff((abs(H).^2)-Asq)))>100*eps
    error("max(abs(diff((abs(H).^2)-Asq)))>100*eps");
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
  fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
  fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Wat=%d %% Transition pass band weight\n",Wat);
  fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
  fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
  fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
  fprintf(fid,"ftp=%g %% Amplitude stop band edge\n",ftp);
  fprintf(fid,"td=%g %% Nominal pass band delay\n",td);
  fprintf(fid,"tdr=%g %% Delay pass band peak-to-peak ripple\n",tdr);
  fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
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

  Da1=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
  print_polynomial(Da1,"Da1");
  print_polynomial(Da1,"Da1",sprintf("%s_m_%d_Da1_coef.m",strf,m));

  eval(sprintf("save %s_m_%d.mat ...\n\
   rho tol ctol difference n m DD ...\n\
   fap dBap Wap Wat fas dBas Was ftp td tdr Wtp ...\n\
   Da0 A1k A1epsilon A1p Da1",strf,m));
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
