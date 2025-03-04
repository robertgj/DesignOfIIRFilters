% schurNSlatticeEsq_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurNSlatticeEsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2,

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  Ns=length(s10);

  %
  % Calculate the squared error response
  %
  Esq=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);

  % Check the squared error response (delayz is not accurate??)
  Asq=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
  T=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
  TErr=Wt.*((T-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
  absErrEsq=abs(AsqErrSum+TErrSum-Esq);
  if absErrEsq > eps
    error("abs(AsqErrSum+TErrSum-Esq)(%g*eps) > eps",absErrEsq/eps);
  endif

  %
  % Calculate the gradient of the squared error response
  %
  [Esq,gradEsq]=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);

  % Check the gradients of the squared error
  del=1e-6;
  tol=del;
  dels=zeros(size(s10));
  dels(1)=del/2;
  est_dEsqds=zeros(1,6*Ns);
  for l=1:Ns
    % s10
    EsqP=schurNSlatticeEsq(s10+dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    EsqM=schurNSlatticeEsq(s10-dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    est_dEsqds(1+((l-1)*6))=(EsqP-EsqM)/del;
    % s11
    EsqP=schurNSlatticeEsq(s10,s11+dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    EsqM=schurNSlatticeEsq(s10,s11-dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    est_dEsqds(2+((l-1)*6))=(EsqP-EsqM)/del;
    % s20
    EsqP=schurNSlatticeEsq(s10,s11,s20+dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    EsqM=schurNSlatticeEsq(s10,s11,s20-dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    est_dEsqds(3+((l-1)*6))=(EsqP-EsqM)/del;
    % s02
    EsqP=schurNSlatticeEsq(s10,s11,s20,s00+dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    EsqM=schurNSlatticeEsq(s10,s11,s20,s00-dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    est_dEsqds(4+((l-1)*6))=(EsqP-EsqM)/del;
    % s00
    EsqP=schurNSlatticeEsq(s10,s11,s20,s00,s02+dels,s22,wa,Asqd,Wa,wt,Td,Wt);
    EsqM=schurNSlatticeEsq(s10,s11,s20,s00,s02-dels,s22,wa,Asqd,Wa,wt,Td,Wt);
    est_dEsqds(5+((l-1)*6))=(EsqP-EsqM)/del;
    % s22
    EsqP=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22+dels,wa,Asqd,Wa,wt,Td,Wt);
    EsqM=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22-dels,wa,Asqd,Wa,wt,Td,Wt);
    est_dEsqds(6+((l-1)*6))=(EsqP-EsqM)/del;
    % Shift dels
    dels=circshift(dels,1);
  endfor
  max_gradEsq_error=max(abs(est_dEsqds-gradEsq));
  if max_gradEsq_error > tol 
    error("max(abs(est_dEsqds-gradEsq))(%g*tol) > tol",max_gradEsq_error/tol);
  endif

  %
  % Calculate the diagonal of the Hessian of the squared error response
  %
  [Esq,gradEsq,diagHessEsq]=...
    schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);

  % Check the diagonal of the Hessian of the squared error
  del=1e-6;
  tol=del*10;
  dels=zeros(size(s10));
  dels(1)=del/2;
  est_d2Esqds2=zeros(1,6*Ns);
  for l=1:Ns
    % s10
    [EsqP,gradEsqP]=...
        schurNSlatticeEsq(s10+dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    [EsqP,gradEsqM]=...         
      schurNSlatticeEsq(s10-dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    lindex=1+((l-1)*6);
    est_d2Esqds2(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
    % s11
    [EsqP,gradEsqP]=...
      schurNSlatticeEsq(s10,s11+dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    [EsqP,gradEsqM]=...             
      schurNSlatticeEsq(s10,s11-dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    lindex=2+((l-1)*6);
    est_d2Esqds2(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
    % s20
    [EsqP,gradEsqP]=...
      schurNSlatticeEsq(s10,s11,s20+dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    [EsqP,gradEsqM]=...                 
      schurNSlatticeEsq(s10,s11,s20-dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    lindex=3+((l-1)*6);
    est_d2Esqds2(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
    % s02
    [EsqP,gradEsqP]=...
      schurNSlatticeEsq(s10,s11,s20,s00+dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    [EsqP,gradEsqM]=...                     
      schurNSlatticeEsq(s10,s11,s20,s00-dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
    lindex=4+((l-1)*6);
    est_d2Esqds2(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
    % s00
    [EsqP,gradEsqP]=...
      schurNSlatticeEsq(s10,s11,s20,s00,s02+dels,s22,wa,Asqd,Wa,wt,Td,Wt);
    [EsqP,gradEsqM]=...                         
      schurNSlatticeEsq(s10,s11,s20,s00,s02-dels,s22,wa,Asqd,Wa,wt,Td,Wt);
    lindex=5+((l-1)*6);
    est_d2Esqds2(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
    % s22
    [EsqP,gradEsqP]=...
      schurNSlatticeEsq(s10,s11,s20,s00,s02,s22+dels,wa,Asqd,Wa,wt,Td,Wt);
    [EsqP,gradEsqM]=...                             
      schurNSlatticeEsq(s10,s11,s20,s00,s02,s22-dels,wa,Asqd,Wa,wt,Td,Wt);
    lindex=6+((l-1)*6);
    est_d2Esqds2(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
    % Shift dels
    dels=circshift(dels,1);
  endfor
  max_diagHessEsq_error=max(abs(est_d2Esqds2-diagHessEsq));
  if max_diagHessEsq_error > tol
    error("max_diagHessEsq_error(%g*tol) > tol",max_diagHessEsq_error/tol);
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
