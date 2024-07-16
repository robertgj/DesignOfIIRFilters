% schurNSPAlatticeEsq_test.m
% Copyright (C) 2023-2024 Robert G. Jenssen

test_common;

strf="schurNSPAlatticeEsq_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

for x=1:2

  schur_lattice_test_common;

  % Convert filter transfer function to Schur normalised-scaled lattice form
  [~,~,A1s20,A1s00,A1s02,A1s22]=tf2schurNSlattice(flipud(Da1),Da1);
  [~,~,A2s20,A2s00,A2s02,A2s22]=tf2schurNSlattice(flipud(Db1),Db1);
  A1Ns=length(A1s20);
  A2Ns=length(A2s20);

  %
  % Calculate the squared-error response
  %
  Esq=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  
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

  % Check the squared-error response
  tol=1e-8;
  if abs(EsqErrSum-Esq) > tol
    error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > tol");
  endif

  %
  % Calculate the gradients of the squared-error
  %
  [Esq,gradEsq] = ...
    schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  % Check the gradients of the squared-error wrt A1s
  del=1e-6;
  tol=del*4;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  est_dEsqA1ds=zeros(1,A1Ns*4);
  for l=1:A1Ns
    % A1s20
    EsqA1s20P=schurNSPAlatticeEsq(A1s20+delA1s,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA1s20M=schurNSPAlatticeEsq(A1s20-delA1s,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA1ds(l)=(EsqA1s20P-EsqA1s20M)/del;
    % A1s00
    EsqA1s00P=schurNSPAlatticeEsq(A1s20,A1s00+delA1s,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA1s00M=schurNSPAlatticeEsq(A1s20,A1s00-delA1s,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA1ds(A1Ns+l)=(EsqA1s00P-EsqA1s00M)/del;
    % A1s02
    EsqA1s02P=schurNSPAlatticeEsq(A1s20,A1s00,A1s02+delA1s,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA1s02M=schurNSPAlatticeEsq(A1s20,A1s00,A1s02-delA1s,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA1ds((2*A1Ns)+l)=(EsqA1s02P-EsqA1s02M)/del;
    % A1s22
    EsqA1s22P=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22+delA1s, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA1s22M=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22-delA1s, ...
                                  A2s20,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA1ds((3*A1Ns)+l)=(EsqA1s22P-EsqA1s22M)/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_gradEsqA1_error=max(max(abs(est_dEsqA1ds-gradEsq(1:(A1Ns*4)))));
  if verbose
    printf("max_gradEsqA1_error = %g*tol\n",max_gradEsqA1_error/tol);
  endif
  if max_gradEsqA1_error > tol
    error("max_gradEsqA1_error > tol");
  endif

  % Check the gradients of the squared-error wrt A2s
  del=1e-6;
  tol=del*4;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  est_dEsqA2ds=zeros(1,A2Ns*4);
  for l=1:A2Ns
    % A2s20
    EsqA2s20P=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20+delA2s,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA2s20M=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20-delA2s,A2s00,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA2ds(l)=(EsqA2s20P-EsqA2s20M)/del;
    % A2s00
    EsqA2s00P=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00+delA2s,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA2s00M=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00-delA2s,A2s02,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA2ds(A2Ns+l)=(EsqA2s00P-EsqA2s00M)/del;
    % A2s02
    EsqA2s02P=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02+delA2s,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA2s02M=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02-delA2s,A2s22, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA2ds((2*A2Ns)+l)=(EsqA2s02P-EsqA2s02M)/del;
    % A2s22
    EsqA2s22P=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22+delA2s, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqA2s22M=schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22-delA2s, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    est_dEsqA2ds((3*A2Ns)+l)=(EsqA2s22P-EsqA2s22M)/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_gradEsqA2_error=...
    max(max(abs(est_dEsqA2ds-gradEsq(((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_gradEsqA2_error > tol
    error("max_gradEsqA2_error > tol");
  endif

  %
  % Calculate the diagonal of the Hessian of the squared-error
  %
  [Esq,gradEsq,diagHessEsq]= ...
    schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  % Check the diagonal of the Hessian of the squared-error wrt A1s
  del=1e-6;
  tol=del*50;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  est_d2EsqA1ds2=zeros(1,A1Ns*4);
  for l=1:A1Ns
    % A1s20
    [EsqA1s20P,gradEsqA1s20P]=...
        schurNSPAlatticeEsq(A1s20+delA1s,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA1s20M,gradEsqA1s20M]=...
      schurNSPAlatticeEsq(A1s20-delA1s,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=l;
    est_d2EsqA1ds2(lindex)=(gradEsqA1s20P(lindex)-gradEsqA1s20M(lindex))/del;
    % A1s00
    [EsqA1s00P,gradEsqA1s00P]=...
      schurNSPAlatticeEsq(A1s20,A1s00+delA1s,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA1s00M,gradEsqA1s00M]=...
      schurNSPAlatticeEsq(A1s20,A1s00-delA1s,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=A1Ns+l;
    est_d2EsqA1ds2(lindex)=(gradEsqA1s00P(lindex)-gradEsqA1s00M(lindex))/del;
    % A1s02
    [EsqA1s02P,gradEsqA1s02P]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02+delA1s,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA1s02M,gradEsqA1s02M]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02-delA1s,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=(2*A1Ns)+l;
    est_d2EsqA1ds2(lindex)=(gradEsqA1s02P(lindex)-gradEsqA1s02M(lindex))/del;
    % A1s22
    [EsqA1s22P,gradEsqA1s22P]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22+delA1s, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA1s22M,gradEsqA1s22M]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22-delA1s, ...
                          A2s20,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=(3*A1Ns)+l;
    est_d2EsqA1ds2(lindex)=(gradEsqA1s22P(lindex)-gradEsqA1s22M(lindex))/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_diagHessEsqA1_error=max(max(abs(est_d2EsqA1ds2-diagHessEsq(1:(A1Ns*4)))));
  if max_diagHessEsqA1_error > tol
    error("max_diagHessEsqA1_error > tol");
  endif

  % Check the diagonal of the Hessian of the squared-error wrt A2s
  del=1e-6;
  tol=del*50;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  est_d2EsqA2ds2=zeros(1,A2Ns*4);
  for l=1:A2Ns
    % A2s20
    [EsqA2s20P,gradEsqA2s20P]=...
        schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                            A2s20+delA2s,A2s00,A2s02,A2s22, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA2s20M,gradEsqA2s20M]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20-delA2s,A2s00,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=l;
    rindex=lindex+(A1Ns*4);
    est_d2EsqA2ds2(lindex)=(gradEsqA2s20P(rindex)-gradEsqA2s20M(rindex))/del;
    % A2s00
    [EsqA2s00P,gradEsqA2s00P]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00+delA2s,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA2s00M,gradEsqA2s00M]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00-delA2s,A2s02,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=A2Ns+l;
    rindex=lindex+(A1Ns*4);
    est_d2EsqA2ds2(lindex)=(gradEsqA2s00P(rindex)-gradEsqA2s00M(rindex))/del;
    % A2s02
    [EsqA2s02P,gradEsqA2s02P]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02+delA2s,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA2s02M,gradEsqA2s02M]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02-delA2s,A2s22, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=(2*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    est_d2EsqA2ds2(lindex)=(gradEsqA2s02P(rindex)-gradEsqA2s02M(rindex))/del;
    % A2s22
    [EsqA2s22P,gradEsqA2s22P]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22+delA2s, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqA2s22M,gradEsqA2s22M]=...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22-delA2s, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    lindex=(3*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    est_d2EsqA2ds2(lindex)=(gradEsqA2s22P(rindex)-gradEsqA2s22M(rindex))/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_diagHessEsqA2_error=...
    max(max(abs(est_d2EsqA2ds2-diagHessEsq(((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_diagHessEsqA2_error > tol
    error("max_diagHessEsqA2_error > tol");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
