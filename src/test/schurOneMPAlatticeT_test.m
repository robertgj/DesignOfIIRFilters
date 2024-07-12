% schurOneMPAlatticeT_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeT_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;
tol=1e-7;

for m=1:2
  
  schur_parallel_allpass_lattice_test_common;
  
  %
  % Lattice decomposition
  %
  [A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
  [A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

  A1rng=1:length(A1k);
  A2rng=(length(A1k)+1):(length(A1k)+length(A2k));

  %
  % Find the group delay
  %
  T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the group delay response
  Tab1=delayz(Nab1,Dab1,wt);
  max_abs_diff_T = max(abs(Tab1-T));
  if verbose
    printf("max_abs_diff_T = %g*tol\n",max_abs_diff_T/tol);
  endif
  if max_abs_diff_T > 2*tol
    error("max_abs_diff_T > 2*tol");
  endif

  %
  % Find the gradients of T
  %
  [T,gradT]=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p, ...
                                A2k,A2epsilon,A2p,difference);
  
  % Check the gradients of the group delay response
  est_dTdk=zeros(length(wt),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    TA1kP=schurOneMPAlatticeT(wt,A1k+delA1k,A1epsilon,A1p, ...
                              A2k,A2epsilon,A2p,difference);
    TA1kM=schurOneMPAlatticeT(wt,A1k-delA1k,A1epsilon,A1p, ...
                              A2k,A2epsilon,A2p,difference);
    delA1k=circshift(delA1k,1);
    est_dTdk(:,l)=(TA1kP-TA1kM)/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=1:length(A2k)
    TA2kP=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p, ...
                              A2k+delA2k,A2epsilon,A2p,difference);
    TA2kM=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p, ...
                              A2k-delA2k,A2epsilon,A2p,difference);
    delA2k=circshift(delA2k,1);
    est_dTdk(:,length(A1k)+l)=(TA2kP-TA2kM)/del;
  endfor
  max_abs_diff_dTdk = max(max(abs(est_dTdk-gradT)));
  if verbose
    printf("max_abs_diff_dTdk = %g*tol\n",max_abs_diff_dTdk/tol);
  endif
  if max_abs_diff_dTdk > tol
    error("max_abs_diff_dTdk > tol");
  endif

  %
  % Find diagHessT
  %
  [T,gradT,diagHessT] = ...
    schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the diagonal of the Hessian of the group delay response
  est_d2Tdk2=zeros(length(wt),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    [TA1kP,gradTA1kP] = schurOneMPAlatticeT(wt,A1k+delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
    [TA1kM,gradTA1kM] = schurOneMPAlatticeT(wt,A1k-delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
    delA1k=circshift(delA1k,1);
    est_d2Tdk2(:,l)=(gradTA1kP(:,l)-gradTA1kM(:,l))/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=(length(A1k)+1):(length(A1k)+length(A2k))
    [TA2kP,gradTA2kP] = schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,...
                                            A2k+delA2k,A2epsilon,A2p, ...
                                            difference);
    [TA2kM,gradTA2kM] = schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,...
                                            A2k-delA2k,A2epsilon,A2p, ...
                                            difference);
    delA2k=circshift(delA2k,1);
    est_d2Tdk2(:,l) = (gradTA2kP(:,l)-gradTA2kM(:,l))/del;
  endfor
  max_abs_diff_d2Tdk2 = max(max(abs(est_d2Tdk2-diagHessT)));
  if verbose
    printf("max_abs_diff_d2Tdk2 = %g*tol\n",max_abs_diff_d2Tdk2/tol);
  endif
  if max_abs_diff_d2Tdk2 > 10*tol
    error("max_abs_diff_d2Tdk2 > 10*tol");
  endif

  %
  % Find hessT
  %
  [T,gradT,diagHessT,hessT] = ...
    schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the group delay response
  if verbose
    printf("Estimating d2Tdydx\n");
    tic;
  endif
  est_d2Tdydx=zeros(length(wt), ...
                    length(A1k)+length(A2k),length(A1k)+length(A2k));
  del=tol*10;
  % d2TdA1kdA1k (upper left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=1:length(A1k)
    for v=1:length(A1k)
      [TA1kP,gradTA1kP]=schurOneMPAlatticeT(wt,A1k+delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      [TA1kM,gradTA1kM]=schurOneMPAlatticeT(wt,A1k-delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      delA1k=circshift(delA1k,1);
      est_d2Tdydx(:,u,v) = (gradTA1kP(:,u)-gradTA1kM(:,u))/del;
    endfor
  endfor
  % d2TdA2kdA2k (lower right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [TA2kP,gradTA2kP] = schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,...
                                                    A2k+delA2k,A2epsilon,A2p, ...
                                                    difference);
      [TA2kM,gradTA2kM] = schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,...
                                              A2k-delA2k,A2epsilon,A2p, ...
                                              difference);
      delA2k=circshift(delA2k,1);
      est_d2Tdydx(:,u,v) = (gradTA2kP(:,u)-gradTA2kM(:,u))/del;
    endfor
  endfor
  % d2TdA1kdA2k (lower left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=1:length(A1k)
      [TA1kP,gradTA1kP]=schurOneMPAlatticeT(wt,A1k+delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      [TA1kM,gradTA1kM]=schurOneMPAlatticeT(wt,A1k-delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      delA1k=circshift(delA1k,1);
      est_d2Tdydx(:,u,v) = (gradTA1kP(:,u)-gradTA1kM(:,u))/del;
    endfor
  endfor
  % d2TdA2kdA1k (upper right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=1:length(A1k)
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [TA2kP,gradTA2kP] = schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,...
                                              A2k+delA2k,A2epsilon,A2p, ...
                                              difference);
      [TA2kM,gradTA2kM] = schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,...
                                              A2k-delA2k,A2epsilon,A2p, ...
                                              difference);
      delA2k=circshift(delA2k,1);
      est_d2Tdydx(:,u,v) = (gradTA2kP(:,u)-gradTA2kM(:,u))/del;
    endfor
  endfor
  if verbose
    toc;
  endif
  max_abs_diff_d2Tdydx = max(max(max(abs(est_d2Tdydx-hessT))));
  if verbose
    printf("max_abs_diff_d2Tdydx = %g*tol\n",
           max_abs_diff_d2Tdydx/tol);
  endif
  if max_abs_diff_d2Tdydx > 10*tol
    error("max_abs_diff_d2Tdydx > 10*tol");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
