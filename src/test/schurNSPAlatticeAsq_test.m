% schurNSPAlatticeAsq_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen

test_common;

strf="schurNSPAlatticeAsq_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

for m=1:2

  schur_parallel_allpass_lattice_test_common;

  % Alternative calculation of squared-amplitude response
  Ha1=freqz(flipud(Da1),Da1,wa);
  Hb1=freqz(flipud(Db1),Db1,wa);
  if difference
    Hab1=(Ha1-Hb1)/2;
  else
    Hab1=(Ha1+Hb1)/2;
  endif

  % Convert filter transfer function to Schur normalised-scaled lattice form
  [~,~,A1s20,A1s00,A1s02,A1s22]=tf2schurNSlattice(flipud(Da1),Da1);
  [~,~,A2s20,A2s00,A2s02,A2s22]=tf2schurNSlattice(flipud(Db1),Db1);
  A1Ns=length(A1s20);
  A2Ns=length(A2s20);

  % Calculate the squared-amplitude response
  Asq=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                          difference);
  
  % Check the squared-amplitude response
  max_Asq_error=max(abs((abs(Hab1).^2)-Asq));
  if max_Asq_error > 100*eps
    error("max_Asq_error > 100*eps");
  endif

  % Calculate the gradients
  [Asq,gradAsq] = ...
    schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                        difference);

  % Check the gradients of the squared-amplitude wrt A1s
  del=1e-6;
  tol=del/100;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  diff_AsqA1=zeros(length(wa),A1Ns*4);
  for l=1:A1Ns
    % A1s20
    AsqA1s20P=schurNSPAlatticeAsq(wa,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    AsqA1s20M=schurNSPAlatticeAsq(wa,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    diff_AsqA1(:,l)=(AsqA1s20P-AsqA1s20M)/del;
    % A1s00
    AsqA1s00P=schurNSPAlatticeAsq(wa,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    AsqA1s00M=schurNSPAlatticeAsq(wa,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    diff_AsqA1(:,A1Ns+l)=(AsqA1s00P-AsqA1s00M)/del;
    % A1s02
    AsqA1s02P=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    AsqA1s02M=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    diff_AsqA1(:,(2*A1Ns)+l)=(AsqA1s02P-AsqA1s02M)/del;
    % A1s22
    AsqA1s22P=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    AsqA1s22M=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                                  A2s20,A2s00,A2s02,A2s22,difference);
    diff_AsqA1(:,(3*A1Ns)+l)=(AsqA1s22P-AsqA1s22M)/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_gradAsqA1_error=max(max(abs(diff_AsqA1-gradAsq(:,1:(A1Ns*4)))));
  if max_gradAsqA1_error > tol
    error("max_gradAsqA1_error > tol");
  endif

  % Check the gradients of the squared-amplitude wrt A2s
  del=1e-6;
  tol=del/100;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  diff_AsqA2=zeros(length(wa),A2Ns*4);
  for l=1:A2Ns
    % A2s20
    AsqA2s20P=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20+delA2s,A2s00,A2s02,A2s22,difference);
    AsqA2s20M=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20-delA2s,A2s00,A2s02,A2s22,difference);
    diff_AsqA2(:,l)=(AsqA2s20P-AsqA2s20M)/del;
    % A2s00
    AsqA2s00P=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00+delA2s,A2s02,A2s22,difference);
    AsqA2s00M=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00-delA2s,A2s02,A2s22,difference);
    diff_AsqA2(:,A2Ns+l)=(AsqA2s00P-AsqA2s00M)/del;
    % A2s02
    AsqA2s02P=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02+delA2s,A2s22,difference);
    AsqA2s02M=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02-delA2s,A2s22,difference);
    diff_AsqA2(:,(2*A2Ns)+l)=(AsqA2s02P-AsqA2s02M)/del;
    % A2s22
    AsqA2s22P=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22+delA2s,difference);
    AsqA2s22M=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                                  A2s20,A2s00,A2s02,A2s22-delA2s,difference);
    diff_AsqA2(:,(3*A2Ns)+l)=(AsqA2s22P-AsqA2s22M)/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_gradAsqA2_error=...
    max(max(abs(diff_AsqA2-gradAsq(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_gradAsqA2_error > tol
    error("max_gradAsqA2_error > tol");
  endif

  % Calculate the diagonal of the Hessian
  [Asq,gradAsq,diagHessAsq]= ...
    schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);

  % Check the diagonal of the Hessian of the squared-amplitude wrt A1s
  del=1e-6;
  tol=del/40;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  diff_gradAsqA1=zeros(length(wa),A1Ns*4);
  for l=1:A1Ns
    % A1s20
    [AsqA1s20P,gradAsqA1s20P]=...
      schurNSPAlatticeAsq(wa,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    [AsqA1s20M,gradAsqA1s20M]=...
      schurNSPAlatticeAsq(wa,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    lindex=l;
    diff_gradAsqA1(:,lindex)=...
      (gradAsqA1s20P(:,lindex)-gradAsqA1s20M(:,lindex))/del;
    % A1s00
    [AsqA1s00P,gradAsqA1s00P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    [AsqA1s00M,gradAsqA1s00M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    lindex=A1Ns+l;
    diff_gradAsqA1(:,lindex)=...
      (gradAsqA1s00P(:,lindex)-gradAsqA1s00M(:,lindex))/del;
    % A1s02
    [AsqA1s02P,gradAsqA1s02P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    [AsqA1s02M,gradAsqA1s02M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    lindex=(2*A1Ns)+l;
    diff_gradAsqA1(:,lindex)= ...
    (gradAsqA1s02P(:,lindex)-gradAsqA1s02M(:,lindex))/del;
    % A1s22
    [AsqA1s22P,gradAsqA1s22P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    [AsqA1s22M,gradAsqA1s22M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    lindex=(3*A1Ns)+l;
    diff_gradAsqA1(:,lindex)= ...
      (gradAsqA1s22P(:,lindex)-gradAsqA1s22M(:,lindex))/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_diagHessAsqA1_error= ...
    max(max(abs(diff_gradAsqA1-diagHessAsq(:,1:(A1Ns*4)))));
  if max_diagHessAsqA1_error > tol
    error("max_diagHessAsqA1_error > tol");
  endif

  % Check the diagonal of the Hessian of the squared-amplitude wrt A2s
  del=1e-6;
  tol=del/40;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  diff_gradAsqA2=zeros(length(wa),A2Ns*4);
  for l=1:A2Ns
    % A2s20
    [AsqA2s20P,gradAsqA2s20P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20+delA2s,A2s00,A2s02,A2s22,difference);
    [AsqA2s20M,gradAsqA2s20M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20-delA2s,A2s00,A2s02,A2s22,difference);
    lindex=l;
    rindex=lindex+(A1Ns*4);
    diff_gradAsqA2(:,lindex)= ...
      (gradAsqA2s20P(:,rindex)-gradAsqA2s20M(:,rindex))/del;
    % A2s00
    [AsqA2s00P,gradAsqA2s00P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00+delA2s,A2s02,A2s22,difference);
    [AsqA2s00M,gradAsqA2s00M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00-delA2s,A2s02,A2s22,difference);
    lindex=A2Ns+l;
    rindex=lindex+(A1Ns*4);
    diff_gradAsqA2(:,lindex)= ...
      (gradAsqA2s00P(:,rindex)-gradAsqA2s00M(:,rindex))/del;
    % A2s02
    [AsqA2s02P,gradAsqA2s02P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02+delA2s,A2s22,difference);
    [AsqA2s02M,gradAsqA2s02M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02-delA2s,A2s22,difference);
    lindex=(2*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    diff_gradAsqA2(:,lindex)= ...
      (gradAsqA2s02P(:,rindex)-gradAsqA2s02M(:,rindex))/del;
    % A2s22
    [AsqA2s22P,gradAsqA2s22P]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22+delA2s,difference);
    [AsqA2s22M,gradAsqA2s22M]=...
      schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22-delA2s,difference);
    lindex=(3*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    diff_gradAsqA2(:,lindex)= ...
      (gradAsqA2s22P(:,rindex)-gradAsqA2s22M(:,rindex))/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_diagHessAsqA2_error=...
    max(max(abs(diff_gradAsqA2-diagHessAsq(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_diagHessAsqA2_error > tol
    error("max_diagHessAsqA2_error > tol");
  endif

endfor

% Done
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary;",strf,strf));
