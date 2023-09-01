% schurOneMPAlatticeEsq_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen

test_common;

delete("schurOneMPAlatticeEsq_test.diary");
delete("schurOneMPAlatticeEsq_test.diary.tmp");
diary schurOneMPAlatticeEsq_test.diary.tmp

tol=1e-6;

for m=1:2,

  schur_parallel_allpass_lattice_test_common;
  
  % Lattice decomposition
  [A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
  [A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

  A1rng=1:length(A1k);
  A2rng=(length(A1k)+1):(length(A1k)+length(A2k));

  % Alternative calculation of squared-error response
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

  if abs(EsqErrSum-Esq) > tol
    error("abs(EsqErrSum-Esq) > tol");
  endif

  % Find the gradients of Esq
  [Esq,gradEsq]=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                      difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  % Check the gradients of the squared-error response wrt A1k
  del=tol;
  NA1k=length(A1k);
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Esqk=zeros(size(A1k));
  for l=1:NA1k
    EsqkPdel2=schurOneMPAlatticeEsq(A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                    difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqkMdel2=schurOneMPAlatticeEsq(A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                    difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delk=circshift(delk,1);
    diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
  endfor
  if max(max(abs(diff_Esqk-gradEsq(A1rng)))) > 2*tol
    error("max(max(abs(diff_Esqk-gradEsq(A1rng)))) > 2*tol");
  endif

  % Check the gradients of the squared-error response wrt A2k
  del=tol;
  NA2k=length(A2k);
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Esqk=zeros(size(A2k));
  for l=1:NA2k
    EsqkPdel2= ...
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqkMdel2= ...
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delk=circshift(delk,1);
    diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
  endfor
  if max(max(abs(diff_Esqk-gradEsq(A2rng)))) > tol
    error("max(max(abs(diff_Esqk-gradEsq(A2rng)))) > tol");
  endif

  % Find diagHessEsq
  [Esq,gradEsq,diagHessEsq]=...
  schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  % Check the Hessian of the squared-error response wrt A1k
  del=tol;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(size(A1k));
  for l=1:NA1k
    [EsqkPdel2,gradEsqkPdel2]=...
      schurOneMPAlatticeEsq(A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqkMdel2,gradEsqkMdel2]= ...
      schurOneMPAlatticeEsq(A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delk=circshift(delk,1);
    diff_gradEsqk(l)=(gradEsqkPdel2(l)-gradEsqkMdel2(l))/del;
  endfor
  if max(max(abs(diff_gradEsqk-diagHessEsq(A1rng)))) > 20*tol
    error("max(max(abs(diff_gradEsqk-diagHessEsq(A1rng)))) > 20*tol");
  endif

  % Check the Hessian of the squared-error response wrt A2k
  del=tol;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(size(A2k));
  for l=1:NA2k
    [EsqkPdel2,gradEsqkPdel2]=...
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqkMdel2,gradEsqkMdel2]=...
      schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    
    delk=circshift(delk,1);
    diff_gradEsqk(l)=(gradEsqkPdel2(NA1k+l)-gradEsqkMdel2(NA1k+l))/del;
  endfor
  if max(max(abs(diff_gradEsqk-diagHessEsq(A2rng)))) > 20*tol
    error("max(max(abs(diff_gradEsqk-diagHessEsq(A2rng)))) > 20*tol");
  endif
endfor

% Done
diary off
movefile schurOneMPAlatticeEsq_test.diary.tmp schurOneMPAlatticeEsq_test.diary;
