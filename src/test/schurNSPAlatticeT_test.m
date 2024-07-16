% schurNSPAlatticeT_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurNSPAlatticeT_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2
  
  schur_lattice_test_common;

  % Convert filter transfer function to Schur normalised-scaled lattice form
  [~,~,A1s20,A1s00,A1s02,A1s22]=tf2schurNSlattice(flipud(Da1),Da1);
  [~,~,A2s20,A2s00,A2s02,A2s22]=tf2schurNSlattice(flipud(Db1),Db1);
  A1Ns=length(A1s20);
  A2Ns=length(A2s20);

  %
  % Calculate the group delay response
  %
  T=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                      difference);

  % Alternative calculation of group delay response
  Ta1=delayz(flipud(Da1),Da1,wt);
  Tb1=delayz(flipud(Db1),Db1,wt);
  Tab1=(Ta1+Tb1)/2;

  % Check the group delay response
  max_T_error=max(abs(Tab1-T));
  if max_T_error > 2e-10
    error("max_T_error > 2e-10");
  endif

  %
  % Calculate the gradients of the group delay response
  %
  [T,gradT]=schurNSPAlatticeT(wt, ...
                              A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                              difference);

  % Check the gradients of the group delay wrt A1s
  del=1e-6;
  tol=del/5;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  est_dTA1ds=zeros(length(wt),A1Ns*4);
  for l=1:A1Ns
    % A1s20
    TA1s20P=schurNSPAlatticeT(wt,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    TA1s20M=schurNSPAlatticeT(wt,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dTA1ds(:,l)=(TA1s20P-TA1s20M)/del;
    % A1s00
    TA1s00P=schurNSPAlatticeT(wt,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    TA1s00M=schurNSPAlatticeT(wt,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dTA1ds(:,A1Ns+l)=(TA1s00P-TA1s00M)/del;
    % A1s02
    TA1s02P=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    TA1s02M=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dTA1ds(:,(2*A1Ns)+l)=(TA1s02P-TA1s02M)/del;
    % A1s22
    TA1s22P=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    TA1s22M=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dTA1ds(:,(3*A1Ns)+l)=(TA1s22P-TA1s22M)/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_gradTA1_error=max(max(abs(est_dTA1ds-gradT(:,1:(A1Ns*4)))));
  if max_gradTA1_error > tol
    error("max_gradTA1_error > tol");
  endif

  % Check the gradients of the group delay wrt A2s
  del=1e-6;
  tol=del/5;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  est_dTA2ds=zeros(length(wt),A2Ns*4);
  for l=1:A2Ns
    % A2s20
    TA2s20P=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20+delA2s,A2s00,A2s02,A2s22,difference);
    TA2s20M=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20-delA2s,A2s00,A2s02,A2s22,difference);
    est_dTA2ds(:,l)=(TA2s20P-TA2s20M)/del;
    % A2s00
    TA2s00P=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00+delA2s,A2s02,A2s22,difference);
    TA2s00M=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00-delA2s,A2s02,A2s22,difference);
    est_dTA2ds(:,A2Ns+l)=(TA2s00P-TA2s00M)/del;
    % A2s02
    TA2s02P=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02+delA2s,A2s22,difference);
    TA2s02M=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02-delA2s,A2s22,difference);
    est_dTA2ds(:,(2*A2Ns)+l)=(TA2s02P-TA2s02M)/del;
    % A2s22
    TA2s22P=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22+delA2s,difference);
    TA2s22M=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22-delA2s,difference);
    est_dTA2ds(:,(3*A2Ns)+l)=(TA2s22P-TA2s22M)/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_gradTA2_error=...
    max(max(abs(est_dTA2ds-gradT(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_gradTA2_error > tol
    error("max_gradTA2_error > tol");
  endif

  %
  % Calculate the diagonal of the Hessian
  %
  [T,gradT,diagHessT]=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                                        A2s20,A2s00,A2s02,A2s22,difference);

  % Check the diagonal of the Hessian of the group delay wrt A1s
  del=1e-6;
  tol=del*20;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  est_d2TA1ds2=zeros(length(wt),A1Ns*4);
  for l=1:A1Ns
    % A1s20
    [TA1s20P,gradTA1s20P]=...
        schurNSPAlatticeT(wt,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    [TA1s20M,gradTA1s20M]=...
      schurNSPAlatticeT(wt,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=l;
    est_d2TA1ds2(:,lindex)=(gradTA1s20P(:,lindex)-gradTA1s20M(:,lindex))/del;
    % A1s00
    [TA1s00P,gradTA1s00P]=...
      schurNSPAlatticeT(wt,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    [TA1s00M,gradTA1s00M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=A1Ns+l;
    est_d2TA1ds2(:,lindex)=(gradTA1s00P(:,lindex)-gradTA1s00M(:,lindex))/del;
    % A1s02
    [TA1s02P,gradTA1s02P]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    [TA1s02M,gradTA1s02M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=(2*A1Ns)+l;
    est_d2TA1ds2(:,lindex)=(gradTA1s02P(:,lindex)-gradTA1s02M(:,lindex))/del;
    % A1s22
    [TA1s22P,gradTA1s22P]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    [TA1s22M,gradTA1s22M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=(3*A1Ns)+l;
    est_d2TA1ds2(:,lindex)=(gradTA1s22P(:,lindex)-gradTA1s22M(:,lindex))/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_diagHessTA1_error=max(max(abs(est_d2TA1ds2-diagHessT(:,1:(A1Ns*4)))));
  if max_diagHessTA1_error > tol
    error("max_diagHessTA1_error > tol");
  endif

  % Check the diagonal of the Hessian of the group delay wrt A2s
  del=1e-6;
  tol=del*20;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  est_d2TA2ds2=zeros(length(wt),A2Ns*4);
  for l=1:A2Ns
    % A2s20
    [TA2s20P,gradTA2s20P]=...
        schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20+delA2s,A2s00,A2s02,A2s22,difference);
    [TA2s20M,gradTA2s20M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20-delA2s,A2s00,A2s02,A2s22,difference);
    lindex=l;
    rindex=lindex+(A1Ns*4);
    est_d2TA2ds2(:,lindex)=(gradTA2s20P(:,rindex)-gradTA2s20M(:,rindex))/del;
    % A2s00
    [TA2s00P,gradTA2s00P]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00+delA2s,A2s02,A2s22,difference);
    [TA2s00M,gradTA2s00M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00-delA2s,A2s02,A2s22,difference);
    lindex=A2Ns+l;
    rindex=lindex+(A1Ns*4);
    est_d2TA2ds2(:,lindex)=(gradTA2s00P(:,rindex)-gradTA2s00M(:,rindex))/del;
    % A2s02
    [TA2s02P,gradTA2s02P]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02+delA2s,A2s22,difference);
    [TA2s02M,gradTA2s02M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02-delA2s,A2s22,difference);
    lindex=(2*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    est_d2TA2ds2(:,lindex)=(gradTA2s02P(:,rindex)-gradTA2s02M(:,rindex))/del;
    % A2s22
    [TA2s22P,gradTA2s22P]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22+delA2s,difference);
    [TA2s22M,gradTA2s22M]=...
      schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22-delA2s,difference);
    lindex=(3*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    est_d2TA2ds2(:,lindex)=(gradTA2s22P(:,rindex)-gradTA2s22M(:,rindex))/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_diagHessTA2_error=...
    max(max(abs(est_d2TA2ds2-diagHessT(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_diagHessTA2_error > tol
    error("max_diagHessTA2_error > tol");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
