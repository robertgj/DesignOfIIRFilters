% schurOneMPAlatticeEsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeEsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;
tol=1e-6;

for m=1:2,

  schur_parallel_allpass_lattice_test_common;

  %
  % Lattice decomposition
  %
  [A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
  [A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

  A1rng=1:length(A1k);
  A2rng=(length(A1k)+1):(length(A1k)+length(A2k));

  %
  % Alternative calculation of squared-error response
  %
  Ha1=freqz(flipud(Da1),Da1,wa);
  Hb1=freqz(flipud(Db1),Db1,wa);
  if difference
    Hab1=(Ha1-Hb1)/2;
  else
    Hab1=(Ha1+Hb1)/2;
  endif
  Asqab1=abs(Hab1).^2;

  PHa1=freqz(flipud(Da1),Da1,wp);
  PHb1=freqz(flipud(Db1),Db1,wp);
  if difference
    PHab1=(PHa1-PHb1)/2;
  else
    PHab1=(PHa1+PHb1)/2;
  endif
  Pab1=unwrap(arg(PHab1));

  Ta1=delayz(flipud(Da1),Da1,wt);
  Tb1=delayz(flipud(Db1),Db1,wt);
  Tab1=(Ta1+Tb1)/2;
  
  AsqErr=Wa.*((Asqab1-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end)))/2;
  TErr=Wt.*((Tab1-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(end-1))+TErr(2:end)))/2;
  PErr=Wp.*((Pab1-Pd).^2);  
  PErrSum=sum(diff(wp).*(PErr(1:(end-1))+PErr(2:end)))/2;
  EsqErrSum=AsqErrSum+TErrSum+PErrSum;
  
  % Find the squared-error
  Esq=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  abs_diff_Esq=abs(EsqErrSum-Esq);
  if verbose
    printf("abs_diff_Esq = %g*tol\n",abs_diff_Esq/tol);
  endif
  if abs_diff_Esq > tol/1e4
    error("abs_diffEsq > tol/1e4");
  endif

  %
  % Find the gradients of Esq
  %
  [Esq,gradEsq]=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  del=tol;
  NA1k=length(A1k);
  NA2k=length(A2k);
  NA12k=NA1k+NA2k;
  est_dEsqdk=zeros(1,NA12k);
  % Check the gradients of the squared-error response wrt A1k
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:NA1k
    EsqA1kP=schurOneMPAlatticeEsq(A1k+delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA1kM=schurOneMPAlatticeEsq(A1k-delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delA1k=circshift(delA1k,1);
    est_dEsqdk(l)=(EsqA1kP-EsqA1kM)/del;
  endfor
  % Check the gradients of the squared-error response wrt A2k
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=(NA1k+1):NA12k
    EsqA2kP=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delA2k,A2epsilon,A2p,...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA2kM=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delA2k,A2epsilon,A2p,...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delA2k=circshift(delA2k,1);
    est_dEsqdk(l)=(EsqA2kP-EsqA2kM)/del;
  endfor
  max_abs_diff_dEsqdk = max(abs(est_dEsqdk-gradEsq));
  if verbose
    printf("max_abs_diff_dEsqdk = %g*tol\n",max_abs_diff_dEsqdk/tol);
  endif
  if max_abs_diff_dEsqdk > tol
    error("max_abs_diff_dEsqdk > tol");
  endif

  %
  % Find diagHessEsq
  %
  [Esq,gradEsq,diagHessEsq]=...
    schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  del=tol;
  est_diagHessEsq=zeros(1,NA12k);
  % Check the diagonal of the Hessian of the squared-error response wrt A1k
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for l=1:NA1k
    [EsqA1kP,gradEsqA1kP]=...
      schurOneMPAlatticeEsq(A1k+delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA1kM,gradEsqA1kM]= ...
      schurOneMPAlatticeEsq(A1k-delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delA1k=circshift(delA1k,1);
    est_diagHessEsq(l)=(gradEsqA1kP(l)-gradEsqA1kM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error response wrt A2k
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for l=(NA1k+1):NA12k
    [EsqA2kP,gradEsqA2kP]=...
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delA2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA2kM,gradEsqA2kM]= ...
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delA2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delA2k=circshift(delA2k,1);
    est_diagHessEsq(l)=(gradEsqA2kP(l)-gradEsqA2kM(l))/del;
  endfor
  max_abs_diff_diagHessEsq = max(abs(est_diagHessEsq-diagHessEsq));
  if verbose
    printf("max_abs_diff_diagHessEsq = %g*tol\n",max_abs_diff_diagHessEsq/tol);
  endif
  if max_abs_diff_diagHessEsq > 20*tol
    error("max_abs_diff_diagHessEsq > 20*tol");
  endif

  %
  % Find hessEsq
  %
  [Esq,gradEsq,diagHessEsq,hessEsq]=...
    schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  
  % Check the Hessian of the squared error response
  if verbose
    printf("Estimating d2Esqdydx\n");
    tic;
  endif
  del=tol;
  est_d2Esqdydx=zeros(NA12k);
  % d2EsqdA1kdA1k (upper left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=1:length(A1k)
    for v=1:length(A1k)
      [EsqA1kP,gradEsqA1kP] = ...
        schurOneMPAlatticeEsq(A1k+delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqA1kM,gradEsqA1kM] = ...
        schurOneMPAlatticeEsq(A1k-delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delA1k=circshift(delA1k,1);
      est_d2Esqdydx(u,v) = (gradEsqA1kP(u)-gradEsqA1kM(u))/del;
    endfor
  endfor
  % d2EsqdA2kdA2k (lower right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [EsqA2kP,gradEsqA2kP] = ...
        schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delA2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqA2kM,gradEsqA2kM] = ...
        schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delA2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delA2k=circshift(delA2k,1);
      est_d2Esqdydx(u,v) = (gradEsqA2kP(u)-gradEsqA2kM(u))/del;
    endfor
  endfor
  % d2EsqdA1kdA2k (lower left)
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  for u=(length(A1k)+1):(length(A1k)+length(A2k))
    for v=1:length(A1k)
      [EsqA1kP,gradEsqA1kP] = ...
        schurOneMPAlatticeEsq(A1k+delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqA1kM,gradEsqA1kM] = ...
        schurOneMPAlatticeEsq(A1k-delA1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delA1k=circshift(delA1k,1);
      est_d2Esqdydx(u,v) = (gradEsqA1kP(u)-gradEsqA1kM(u))/del;
    endfor
  endfor
  % d2EsqdA2kdA1k (upper right)
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  for u=1:length(A1k)
    for v=(length(A1k)+1):(length(A1k)+length(A2k))
      [EsqA2kP,gradEsqA2kP] = ...
        schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delA2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqA2kM,gradEsqA2kM] = ...
        schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delA2k,A2epsilon,A2p, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delA2k=circshift(delA2k,1);
      est_d2Esqdydx(u,v) = (gradEsqA2kP(u)-gradEsqA2kM(u))/del;
    endfor
  endfor
  if verbose
    toc;
  endif
  max_abs_diff_d2Esqdydx = max(max(abs(est_d2Esqdydx-hessEsq)));
  if verbose
    printf("max_abs_diff_d2Esqdydx = %g*tol\n",
           max_abs_diff_d2Esqdydx/tol);
  endif
  if max_abs_diff_d2Esqdydx > 20*tol
    error("max_abs_diff_d2Esqdydx > 20*tol");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
