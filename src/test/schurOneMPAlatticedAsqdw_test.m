% schurOneMPAlatticedAsqdw_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticedAsqdw_test";

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
  % Find the squared amplitude
  %
  wdmany=(0:((length(wd)*200)-1))'*pi/(length(wd)*200);
  dAsqdw = ...
    schurOneMPAlatticedAsqdw(wdmany, ...
                             A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the squared amplitude response
  Asq = ...
    schurOneMPAlatticeAsq(wdmany,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  est_dAsqdw=diff(Asq)/(wdmany(2)-wdmany(1));
  ave_dAsqdw=(dAsqdw(1:(end-1))+dAsqdw(2:end))/2;
  max_abs_diff_dAsqdw = max(abs(est_dAsqdw-ave_dAsqdw));
  if verbose
    printf("max_abs_diff_dAsqdw = %g*tol\n",max_abs_diff_dAsqdw/tol);
  endif
  if max_abs_diff_dAsqdw > 400*tol
    error("max_abs_diff_dAsqdw > 400*tol");
  endif

  %
  % Find the gradients of dAsqdw
  %
  [dAsqdw,graddAsqdw]=schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                               A2k,A2epsilon,A2p,difference);
  
  % Check the gradients of the squared amplitude response
  est_ddAsqdwdk=zeros(length(wd),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    dA1kAsqdwP=schurOneMPAlatticedAsqdw(wd,A1k+delA1k,A1epsilon,A1p, ...
                                        A2k,A2epsilon,A2p,difference);
    dA1kAsqdwM=schurOneMPAlatticedAsqdw(wd,A1k-delA1k,A1epsilon,A1p, ...
                                        A2k,A2epsilon,A2p,difference);
    delA1k=circshift(delA1k,1);
    est_ddAsqdwdk(:,l)=(dA1kAsqdwP-dA1kAsqdwM)/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=1:length(A2k)
    dA2kAsqdwP=schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                        A2k+delA2k,A2epsilon,A2p,difference);
    dA2kAsqdwM=schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                        A2k-delA2k,A2epsilon,A2p,difference);
    delA2k=circshift(delA2k,1);
    est_ddAsqdwdk(:,length(A1k)+l)=(dA2kAsqdwP-dA2kAsqdwM)/del;
  endfor
  max_abs_diff_ddAsqdwdk = max(max(abs(est_ddAsqdwdk-graddAsqdw)));
  if verbose
    printf("max_abs_diff_ddAsqdwdk = %g*tol\n",max_abs_diff_ddAsqdwdk/tol);
  endif
  if max_abs_diff_ddAsqdwdk > tol
    error("max_abs_diff_ddAsqdwdk > tol");
  endif

  %
  % Find diagHessdAsqdw
  %
  [dAsqdw,graddAsqdw,diagHessdAsqdw] = ...
    schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                             A2k,A2epsilon,A2p,difference);

  % Check the diagonal of the Hessian of the squared amplitude response
  est_d2dAsqdwdk2=zeros(length(wd),length(A1k)+length(A2k));
  del=tol*10;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:length(A1k)
    [dA1kAsqdwP,graddA1kAsqdwP] = ...
        schurOneMPAlatticedAsqdw(wd,A1k+delA1k,A1epsilon,A1p, ...
                                 A2k,A2epsilon,A2p,difference);
    [dA1kAsqdwM,graddA1kAsqdwM] = ...
      schurOneMPAlatticedAsqdw(wd,A1k-delA1k,A1epsilon,A1p, ...
                               A2k,A2epsilon,A2p,difference);
    delA1k=circshift(delA1k,1);
    est_d2dAsqdwdk2(:,l)=(graddA1kAsqdwP(:,l)-graddA1kAsqdwM(:,l))/del;
  endfor
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=(length(A1k)+1):(length(A1k)+length(A2k))
    [dA2kAsqdwP,graddA2kAsqdwP] = ...
        schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                 A2k+delA2k,A2epsilon,A2p,difference);
    [dA2kAsqdwM,graddA2kAsqdwM] = ...
      schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                               A2k-delA2k,A2epsilon,A2p,difference);
    delA2k=circshift(delA2k,1);
    est_d2dAsqdwdk2(:,l) = (graddA2kAsqdwP(:,l)-graddA2kAsqdwM(:,l))/del;
  endfor
  max_abs_diff_d2dAsqdwdk2 = max(max(abs(est_d2dAsqdwdk2-diagHessdAsqdw)));
  if verbose
    printf("max_abs_diff_d2dAsqdwdk2 = %g*tol\n",max_abs_diff_d2dAsqdwdk2/tol);
  endif
  if max_abs_diff_d2dAsqdwdk2 > 200*tol
    error("max_abs_diff_d2dAsqdwdk2 > 200*tol");
  endif

  %
  % Find hessdAsqdw
  %
  [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
    schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                             A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the squared amplitude response
  est_d2dAsqdwdydx=zeros(length(wd), ...
                      length(A1k)+length(A2k),length(A1k)+length(A2k));
  del=tol*10;
  % d2dAsqdwdA1kdA1k (upper left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=1:length(A1k)
    for v=1:length(A1k)
      [dA1kAsqdwP,graddA1kAsqdwP] = ...
          schurOneMPAlatticedAsqdw(wd,A1k+delA1k,A1epsilon,A1p, ...
                                   A2k,A2epsilon,A2p,difference);
      [dA1kAsqdwM,graddA1kAsqdwM] = ...
        schurOneMPAlatticedAsqdw(wd,A1k-delA1k,A1epsilon,A1p, ...
                                 A2k,A2epsilon,A2p,difference);
      delA1k=circshift(delA1k,1);
      est_d2dAsqdwdydx(:,u,v) = (graddA1kAsqdwP(:,u)-graddA1kAsqdwM(:,u))/del;
    endfor
  endfor
  % d2dAsqdwdA2kdA2k (lower right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [dA2kAsqdwP,graddA2kAsqdwP] = ...
          schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                   A2k+delA2k,A2epsilon,A2p,difference);
      [dA2kAsqdwM,graddA2kAsqdwM] = ...
        schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                 A2k-delA2k,A2epsilon,A2p,difference);
      delA2k=circshift(delA2k,1);
      est_d2dAsqdwdydx(:,u,v) = (graddA2kAsqdwP(:,u)-graddA2kAsqdwM(:,u))/del;
    endfor
  endfor
  % d2dAsqdwdA1kdA2k (lower left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=1:length(A1k)
      [dA1kAsqdwP,graddA1kAsqdwP] = ...
          schurOneMPAlatticedAsqdw(wd,A1k+delA1k,A1epsilon,A1p, ...
                                   A2k,A2epsilon,A2p,difference);
      [dA1kAsqdwM,graddA1kAsqdwM] = ...
        schurOneMPAlatticedAsqdw(wd,A1k-delA1k,A1epsilon,A1p, ...
                                 A2k,A2epsilon,A2p,difference);
      delA1k=circshift(delA1k,1);
      est_d2dAsqdwdydx(:,u,v) = (graddA1kAsqdwP(:,u)-graddA1kAsqdwM(:,u))/del;
    endfor
  endfor
  % d2dAsqdwdA2kdA1k (upper right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=1:length(A1k)
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [dA2kAsqdwP,graddA2kAsqdwP] = ...
          schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                   A2k+delA2k,A2epsilon,A2p,difference);
      [dA2kAsqdwM,graddA2kAsqdwM] = ...
        schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p, ...
                                 A2k-delA2k,A2epsilon,A2p,difference);
      delA2k=circshift(delA2k,1);
      est_d2dAsqdwdydx(:,u,v) = (graddA2kAsqdwP(:,u)-graddA2kAsqdwM(:,u))/del;
    endfor
  endfor
  max_abs_diff_d2dAsqdwdydx = max(max(max(abs(est_d2dAsqdwdydx-hessdAsqdw))));
  if verbose
    printf("max_abs_diff_d2dAsqdwdydx = %g*tol\n",
           max_abs_diff_d2dAsqdwdydx/tol);
  endif
  if max_abs_diff_d2dAsqdwdydx > 200*tol
    error("max_abs_diff_d2dAsqdwdydx > 200*tol");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
