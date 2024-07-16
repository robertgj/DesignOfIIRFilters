% schurOneMPAlatticeP_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeP_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;
tol=1e-7;

for x=1:2
  
  schur_lattice_test_common;
  
  %
  % Lattice decomposition
  %
  [A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
  [A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

  A1rng=1:length(A1k);
  A2rng=(length(A1k)+1):(length(A1k)+length(A2k));

  %
  % Find the phase
  %
  P=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the phase response
  Hnd=freqz(n,d,wp);
  Pnd=unwrap(arg(Hnd));
  max_abs_diff_P = max(abs(Pnd-P));
  if verbose
    printf("max_abs_diff_P = %g*tol\n",max_abs_diff_P/tol);
  endif
  if max_abs_diff_P > tol/10
    error("max_abs_diff_P > tol/10");
  endif

  %
  % Find the gradients of P
  %
  [P,gradP]=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                                A2k,A2epsilon,A2p,difference);
  
  % Check the gradients of the phase response
  est_dPdk=zeros(length(wp),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    PA1kP=schurOneMPAlatticeP(wp,A1k+delA1k,A1epsilon,A1p, ...
                              A2k,A2epsilon,A2p,difference);
    PA1kM=schurOneMPAlatticeP(wp,A1k-delA1k,A1epsilon,A1p, ...
                              A2k,A2epsilon,A2p,difference);
    delA1k=circshift(delA1k,1);
    est_dPdk(:,l)=(PA1kP-PA1kM)/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=1:length(A2k)
    PA2kP=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                              A2k+delA2k,A2epsilon,A2p,difference);
    PA2kM=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                              A2k-delA2k,A2epsilon,A2p,difference);
    delA2k=circshift(delA2k,1);
    est_dPdk(:,length(A1k)+l)=(PA2kP-PA2kM)/del;
  endfor
  max_abs_diff_dPdk = max(max(abs(est_dPdk-gradP)));
  if verbose
    printf("max_abs_diff_dPdk = %g*tol\n",max_abs_diff_dPdk/tol);
  endif
  if max_abs_diff_dPdk > tol/10
    error("max_abs_diff_dPdk > tol/10");
  endif

  %
  % Find diagHessP
  %
  [P,gradP,diagHessP]=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                                          A2k,A2epsilon,A2p,difference);

  % Check the diagonal of the Hessian of the phase response
  est_d2Pdk2=zeros(length(wp),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    [PA1kP,gradPA1kP] = schurOneMPAlatticeP(wp,A1k+delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
    [PA1kM,gradPA1kM] = schurOneMPAlatticeP(wp,A1k-delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
    delA1k=circshift(delA1k,1);
    est_d2Pdk2(:,l)=(gradPA1kP(:,l)-gradPA1kM(:,l))/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=(length(A1k)+1):(length(A1k)+length(A2k))
    [PA2kP,gradPA2kP] = schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,...
                                            A2k+delA2k,A2epsilon,A2p, ...
                                            difference);
    [PA2kM,gradPA2kM] = schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,...
                                            A2k-delA2k,A2epsilon,A2p, ...
                                            difference);
    delA2k=circshift(delA2k,1);
    est_d2Pdk2(:,l) = (gradPA2kP(:,l)-gradPA2kM(:,l))/del;
  endfor
  max_abs_diff_d2Pdk2 = max(max(abs(est_d2Pdk2-diagHessP)));
  if verbose
    printf("max_abs_diff_d2Pdk2 = %g*tol\n",max_abs_diff_d2Pdk2/tol);
  endif
  if max_abs_diff_d2Pdk2 > tol
    error("max_abs_diff_d2Pdk2 > tol");
  endif

  %
  % Find hessP
  %
  [P,gradP,diagHessP,hessP] = ...
    schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                        A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the phase response
  if verbose
    printf("Estimating d2Pdydx\n");
    tic;
  endif
  est_d2Pdydx=zeros(length(wp), ...
                      length(A1k)+length(A2k),length(A1k)+length(A2k));
  del=tol*10;
  % d2PdA1kdA1k (upper left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=1:length(A1k)
    for v=1:length(A1k)
      [PA1kP,gradPA1kP]=schurOneMPAlatticeP(wp,A1k+delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      [PA1kM,gradPA1kM]=schurOneMPAlatticeP(wp,A1k-delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      delA1k=circshift(delA1k,1);
      est_d2Pdydx(:,u,v) = (gradPA1kP(:,u)-gradPA1kM(:,u))/del;
    endfor
  endfor
  % d2PdA2kdA2k (lower right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [PA2kP,gradPA2kP] = schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,...
                                              A2k+delA2k,A2epsilon,A2p, ...
                                              difference);
      [PA2kM,gradPA2kM] = schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,...
                                              A2k-delA2k,A2epsilon,A2p, ...
                                              difference);
      delA2k=circshift(delA2k,1);
      est_d2Pdydx(:,u,v) = (gradPA2kP(:,u)-gradPA2kM(:,u))/del;
    endfor
  endfor
  % d2PdA1kdA2k (lower left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=1:length(A1k)
      [PA1kP,gradPA1kP]=schurOneMPAlatticeP(wp,A1k+delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      [PA1kM,gradPA1kM]=schurOneMPAlatticeP(wp,A1k-delA1k,A1epsilon,A1p,...
                                            A2k,A2epsilon,A2p, ...
                                            difference);
      delA1k=circshift(delA1k,1);
      est_d2Pdydx(:,u,v) = (gradPA1kP(:,u)-gradPA1kM(:,u))/del;
    endfor
  endfor
  % d2PdA2kdA1k (upper right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=1:length(A1k)
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [PA2kP,gradPA2kP] = schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,...
                                              A2k+delA2k,A2epsilon,A2p, ...
                                              difference);
      [PA2kM,gradPA2kM] = schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,...
                                              A2k-delA2k,A2epsilon,A2p, ...
                                              difference);
      delA2k=circshift(delA2k,1);
      est_d2Pdydx(:,u,v) = (gradPA2kP(:,u)-gradPA2kM(:,u))/del;
    endfor
  endfor
  if verbose
    toc;
  endif
  max_abs_diff_d2Pdydx = max(max(max(abs(est_d2Pdydx-hessP))));
  if verbose
    printf("max_abs_diff_d2Pdydx = %g*tol\n",
           max_abs_diff_d2Pdydx/tol);
  endif
  if max_abs_diff_d2Pdydx > tol
    error("max_abs_diff_d2Pdydx > tol");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
