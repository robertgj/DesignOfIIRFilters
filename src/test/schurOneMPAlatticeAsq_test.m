% schurOneMPAlatticeAsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeAsq_test";

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
  % Find the squared amplitude
  %
  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the squared amplitude response
  Hab1=freqz(Nab1,Dab1,wa);
  Asqab1=abs(Hab1).^2;
  max_abs_diff_Asq = max(abs(Asqab1-Asq));
  if verbose
    printf("max_abs_diff_Asq = %g*tol\n",max_abs_diff_Asq/tol);
  endif
  if max_abs_diff_Asq > tol
    error("max_abs_diff_Asq > tol");
  endif

  %
  % Find the gradients of Asq
  %
  [Asq,gradAsq]=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                      A2k,A2epsilon,A2p,difference);
  
  % Check the gradients of the squared amplitude response
  est_dAsqdk=zeros(length(wa),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    AsqA1kP=schurOneMPAlatticeAsq(wa,A1k+delA1k,A1epsilon,A1p, ...
                                    A2k,A2epsilon,A2p,difference);
    AsqA1kM=schurOneMPAlatticeAsq(wa,A1k-delA1k,A1epsilon,A1p, ...
                                    A2k,A2epsilon,A2p,difference);
    delA1k=circshift(delA1k,1);
    est_dAsqdk(:,l)=(AsqA1kP-AsqA1kM)/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=1:length(A2k)
    AsqA2kP=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                    A2k+delA2k,A2epsilon,A2p,difference);
    AsqA2kM=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                    A2k-delA2k,A2epsilon,A2p,difference);
    delA2k=circshift(delA2k,1);
    est_dAsqdk(:,length(A1k)+l)=(AsqA2kP-AsqA2kM)/del;
  endfor
  max_abs_diff_dAsqdk = max(max(abs(est_dAsqdk-gradAsq)));
  if verbose
    printf("max_abs_diff_dAsqdk = %g*tol\n",max_abs_diff_dAsqdk/tol);
  endif
  if max_abs_diff_dAsqdk > tol
    error("max_abs_diff_dAsqdk > tol");
  endif

  %
  % Find diagHessAsq
  %
  [Asq,gradAsq,diagHessAsq]=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                                  A2k,A2epsilon,A2p,difference);

  % Check the diagonal of the Hessian of the squared amplitude response
  est_d2Asqdk2=zeros(length(wa),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    [AsqA1kP,gradAsqA1kP] = schurOneMPAlatticeAsq(wa,A1k+delA1k,A1epsilon,A1p,...
                                                  A2k,A2epsilon,A2p, ...
                                                  difference);
    [AsqA1kM,gradAsqA1kM] = schurOneMPAlatticeAsq(wa,A1k-delA1k,A1epsilon,A1p,...
                                                  A2k,A2epsilon,A2p, ...
                                                  difference);
    delA1k=circshift(delA1k,1);
    est_d2Asqdk2(:,l)=(gradAsqA1kP(:,l)-gradAsqA1kM(:,l))/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=(length(A1k)+1):(length(A1k)+length(A2k))
    [AsqA2kP,gradAsqA2kP] = schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,...
                                                  A2k+delA2k,A2epsilon,A2p, ...
                                                  difference);
    [AsqA2kM,gradAsqA2kM] = schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,...
                                                  A2k-delA2k,A2epsilon,A2p, ...
                                                  difference);
    delA2k=circshift(delA2k,1);
    est_d2Asqdk2(:,l) = (gradAsqA2kP(:,l)-gradAsqA2kM(:,l))/del;
  endfor
  max_abs_diff_d2Asqdk2 = max(max(abs(est_d2Asqdk2-diagHessAsq)));
  if verbose
    printf("max_abs_diff_d2Asqdk2 = %g*tol\n",max_abs_diff_d2Asqdk2/tol);
  endif
  if max_abs_diff_d2Asqdk2 > 200*tol
    error("max_abs_diff_d2Asqdk2 > 200*tol");
  endif

  %
  % Find hessAsq
  %
  [Asq,gradAsq,diagHessAsq,hessAsq] = ...
    schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                          A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the squared amplitude response
  if verbose
    printf("Estimating d2Asqdydx\n");
    tic;
  endif
  est_d2Asqdydx=zeros(length(wa), ...
                      length(A1k)+length(A2k),length(A1k)+length(A2k));
  del=tol*10;
  % d2AsqdA1kdA1k (upper left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=1:length(A1k)
    for v=1:length(A1k)
      [AsqA1kP,gradAsqA1kP]=schurOneMPAlatticeAsq(wa,A1k+delA1k,A1epsilon,A1p,...
                                                  A2k,A2epsilon,A2p, ...
                                                  difference);
      [AsqA1kM,gradAsqA1kM]=schurOneMPAlatticeAsq(wa,A1k-delA1k,A1epsilon,A1p,...
                                                  A2k,A2epsilon,A2p, ...
                                                  difference);
      delA1k=circshift(delA1k,1);
      est_d2Asqdydx(:,u,v) = (gradAsqA1kP(:,u)-gradAsqA1kM(:,u))/del;
    endfor
  endfor
  % d2AsqdA2kdA2k (lower right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [AsqA2kP,gradAsqA2kP] = schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,...
                                                    A2k+delA2k,A2epsilon,A2p, ...
                                                    difference);
      [AsqA2kM,gradAsqA2kM] = schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,...
                                                    A2k-delA2k,A2epsilon,A2p, ...
                                                    difference);
      delA2k=circshift(delA2k,1);
      est_d2Asqdydx(:,u,v) = (gradAsqA2kP(:,u)-gradAsqA2kM(:,u))/del;
    endfor
  endfor
  % d2AsqdA1kdA2k (lower left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=1:length(A1k)
      [AsqA1kP,gradAsqA1kP]=schurOneMPAlatticeAsq(wa,A1k+delA1k,A1epsilon,A1p,...
                                                  A2k,A2epsilon,A2p, ...
                                                  difference);
      [AsqA1kM,gradAsqA1kM]=schurOneMPAlatticeAsq(wa,A1k-delA1k,A1epsilon,A1p,...
                                                  A2k,A2epsilon,A2p, ...
                                                  difference);
      delA1k=circshift(delA1k,1);
      est_d2Asqdydx(:,u,v) = (gradAsqA1kP(:,u)-gradAsqA1kM(:,u))/del;
    endfor
  endfor
  % d2AsqdA2kdA1k (upper right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=1:length(A1k)
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [AsqA2kP,gradAsqA2kP] = schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,...
                                                    A2k+delA2k,A2epsilon,A2p, ...
                                                    difference);
      [AsqA2kM,gradAsqA2kM] = schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,...
                                                    A2k-delA2k,A2epsilon,A2p, ...
                                                    difference);
      delA2k=circshift(delA2k,1);
      est_d2Asqdydx(:,u,v) = (gradAsqA2kP(:,u)-gradAsqA2kM(:,u))/del;
    endfor
  endfor
  if verbose
    toc;
  endif
  max_abs_diff_d2Asqdydx = max(max(max(abs(est_d2Asqdydx-hessAsq))));
  if verbose
    printf("max_abs_diff_d2Asqdydx = %g*tol\n",
           max_abs_diff_d2Asqdydx/tol);
  endif
  if max_abs_diff_d2Asqdydx > 200*tol
    error("max_abs_diff_d2Asqdydx > 200*tol");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
