% schurNSPAlatticeP_test.m
% Copyright (C) 2023-2025 Robert G. Jenssen

test_common;

strf="schurNSPAlatticeP_test";

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
  % Calculate the phase response
  %
  P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                      difference);

  % Alternative calculation of phase response
  Ha1=freqz(flipud(Da1),Da1,wt);
  Hb1=freqz(flipud(Db1),Db1,wt);
  if difference
    Hab1=(Ha1-Hb1)/2;
  else
    Hab1=(Ha1+Hb1)/2;
  endif
  Pab1=H2P(Hab1);

  % Check the phase response
  max_P_error=max(abs(Pab1-P));
  if max_P_error > 100*eps
    error("max_P_error > 100*eps");
  endif

  %
  % Calculate the gradients of the phase response
  %
  [P,gradP]=schurNSPAlatticeP(wt, ...
                              A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                              difference);

  % Check the gradients of the phase wrt A1s
  del=1e-6;
  tol=del/100;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  est_dPA1ds=zeros(length(wt),A1Ns*4);
  for l=1:A1Ns
    % A1s20
    PA1s20P=schurNSPAlatticeP(wt,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    PA1s20M=schurNSPAlatticeP(wt,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dPA1ds(:,l)=(PA1s20P-PA1s20M)/del;
    % A1s00
    PA1s00P=schurNSPAlatticeP(wt,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    PA1s00M=schurNSPAlatticeP(wt,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dPA1ds(:,A1Ns+l)=(PA1s00P-PA1s00M)/del;
    % A1s02
    PA1s02P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    PA1s02M=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dPA1ds(:,(2*A1Ns)+l)=(PA1s02P-PA1s02M)/del;
    % A1s22
    PA1s22P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    PA1s22M=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                              A2s20,A2s00,A2s02,A2s22,difference);
    est_dPA1ds(:,(3*A1Ns)+l)=(PA1s22P-PA1s22M)/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_gradPA1_error=max(max(abs(est_dPA1ds-gradP(:,1:(A1Ns*4)))));
  if max_gradPA1_error > tol
    error("max_gradPA1_error > tol");
  endif

  % Check the gradients of the phase wrt A2s
  del=1e-6;
  tol=del/100;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  est_dPA2ds=zeros(length(wt),A2Ns*4);
  for l=1:A2Ns
    % A2s20
    PA2s20P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20+delA2s,A2s00,A2s02,A2s22,difference);
    PA2s20M=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20-delA2s,A2s00,A2s02,A2s22,difference);
    est_dPA2ds(:,l)=(PA2s20P-PA2s20M)/del;
    % A2s00
    PA2s00P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00+delA2s,A2s02,A2s22,difference);
    PA2s00M=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00-delA2s,A2s02,A2s22,difference);
    est_dPA2ds(:,A2Ns+l)=(PA2s00P-PA2s00M)/del;
    % A2s02
    PA2s02P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02+delA2s,A2s22,difference);
    PA2s02M=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02-delA2s,A2s22,difference);
    est_dPA2ds(:,(2*A2Ns)+l)=(PA2s02P-PA2s02M)/del;
    % A2s22
    PA2s22P=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22+delA2s,difference);
    PA2s22M=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                              A2s20,A2s00,A2s02,A2s22-delA2s,difference);
    est_dPA2ds(:,(3*A2Ns)+l)=(PA2s22P-PA2s22M)/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_gradPA2_error=...
    max(max(abs(est_dPA2ds-gradP(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_gradPA2_error > tol
    error("max_gradPA2_error > tol");
  endif

  %
  % Calculate the diagonal of the Hessian
  %
  [P,gradP,diagHessP]=schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                                        A2s20,A2s00,A2s02,A2s22,difference);

  % Check the diagonal of the Hessian of the phase wrt A1s
  del=1e-6;
  tol=del/50;
  delA1s=zeros(size(A1s20));
  delA1s(1)=del/2;
  est_d2PA1ds2=zeros(length(wt),A1Ns*4);
  for l=1:A1Ns
    % A1s20
    [PA1s20P,gradPA1s20P]=...
        schurNSPAlatticeP(wt,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                          A2s20,A2s00,A2s02,A2s22,difference);
    [PA1s20M,gradPA1s20M]=...
      schurNSPAlatticeP(wt,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=l;
    est_d2PA1ds2(:,lindex)=(gradPA1s20P(:,lindex)-gradPA1s20M(:,lindex))/del;
    % A1s00
    [PA1s00P,gradPA1s00P]=...
      schurNSPAlatticeP(wt,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    [PA1s00M,gradPA1s00M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=A1Ns+l;
    est_d2PA1ds2(:,lindex)=(gradPA1s00P(:,lindex)-gradPA1s00M(:,lindex))/del;
    % A1s02
    [PA1s02P,gradPA1s02P]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    [PA1s02M,gradPA1s02M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=(2*A1Ns)+l;
    est_d2PA1ds2(:,lindex)=(gradPA1s02P(:,lindex)-gradPA1s02M(:,lindex))/del;
    % A1s22
    [PA1s22P,gradPA1s22P]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    [PA1s22M,gradPA1s22M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                        A2s20,A2s00,A2s02,A2s22,difference);
    lindex=(3*A1Ns)+l;
    est_d2PA1ds2(:,lindex)=(gradPA1s22P(:,lindex)-gradPA1s22M(:,lindex))/del;
    % Shift delA1s
    delA1s=circshift(delA1s,1);
  endfor
  max_diagHessPA1_error=max(max(abs(est_d2PA1ds2-diagHessP(:,1:(A1Ns*4)))));
  if max_diagHessPA1_error > tol
    error("max_diagHessPA1_error > tol");
  endif

  % Check the diagonal of the Hessian of the phase wrt A2s
  del=1e-6;
  tol=del/50;
  delA2s=zeros(size(A2s20));
  delA2s(1)=del/2;
  est_d2PA2ds2=zeros(length(wt),A2Ns*4);
  for l=1:A2Ns
    % A2s20
    [PA2s20P,gradPA2s20P]=...
        schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                          A2s20+delA2s,A2s00,A2s02,A2s22,difference);
    [PA2s20M,gradPA2s20M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20-delA2s,A2s00,A2s02,A2s22,difference);
    lindex=l;
    rindex=lindex+(A1Ns*4);
    est_d2PA2ds2(:,lindex)=(gradPA2s20P(:,rindex)-gradPA2s20M(:,rindex))/del;
    % A2s00
    [PA2s00P,gradPA2s00P]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00+delA2s,A2s02,A2s22,difference);
    [PA2s00M,gradPA2s00M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00-delA2s,A2s02,A2s22,difference);
    lindex=A2Ns+l;
    rindex=lindex+(A1Ns*4);
    est_d2PA2ds2(:,lindex)=(gradPA2s00P(:,rindex)-gradPA2s00M(:,rindex))/del;
    % A2s02
    [PA2s02P,gradPA2s02P]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02+delA2s,A2s22,difference);
    [PA2s02M,gradPA2s02M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02-delA2s,A2s22,difference);
    lindex=(2*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    est_d2PA2ds2(:,lindex)=(gradPA2s02P(:,rindex)-gradPA2s02M(:,rindex))/del;
    % A2s22
    [PA2s22P,gradPA2s22P]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22+delA2s,difference);
    [PA2s22M,gradPA2s22M]=...
      schurNSPAlatticeP(wt,A1s20,A1s00,A1s02,A1s22, ...
                        A2s20,A2s00,A2s02,A2s22-delA2s,difference);
    lindex=(3*A2Ns)+l;
    rindex=lindex+(A1Ns*4);
    est_d2PA2ds2(:,lindex)=(gradPA2s22P(:,rindex)-gradPA2s22M(:,rindex))/del;
    % Shift delA2s
    delA2s=circshift(delA2s,1);
  endfor
  max_diagHessPA2_error=...
    max(max(abs(est_d2PA2ds2-diagHessP(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
  if max_diagHessPA2_error > tol
    error("max_diagHessPA2_error > tol");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary;"));
