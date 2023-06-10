% schurNSPAlatticeT_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen

test_common;

delete("schurNSPAlatticeT_test.diary");
delete("schurNSPAlatticeT_test.diary.tmp");
diary schurNSPAlatticeT_test.diary.tmp

% Low pass filter
norder=5;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1024;
npass=floor(nplot*fpass/0.5);
[t,wplot]=delayz(n,d,nplot);
ncheck=2*npass;
tcheck=t(1:ncheck);
wcheck=wplot(1:ncheck);

% Alternative calculation
[Aap1,Aap2]=tf2pa(n,d);
tAap1=delayz(fliplr(Aap1),Aap1,nplot);
tAap2=delayz(fliplr(Aap2),Aap2,nplot);
tAap12=(tAap1+tAap2)/2;
tAap12check=tAap12(1:ncheck);

% Convert filter transfer function to Schur normalised-scaled lattice form
[A1s10,A1s11,A1s20,A1s00,A1s02,A1s22]=tf2schurNSlattice(fliplr(Aap1),Aap1);
[A2s10,A2s11,A2s20,A2s00,A2s02,A2s22]=tf2schurNSlattice(fliplr(Aap2),Aap2);
A1Ns=length(A1s20);
A2Ns=length(A2s20);

% Calculate the group delay response
T=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22);

% Check the group delay response
max_T_error=max(abs(tcheck-T));
if max_T_error > 272*eps
  error("max_T_error > 272*eps");
endif

% Check the group delay response
max_Tap12_error=max(abs(tAap12check-T));
if max_Tap12_error > 1636*eps
  error("max_Tap12_error > 1636*eps");
endif

% Calculate the gradients
[T,gradT]=...
  schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22);

% Check the gradients of the group delay wrt A1s
del=1e-6;
tol=del/5;
delA1s=zeros(size(A1s20));
delA1s(1)=del/2;
diff_TA1=zeros(ncheck,A1Ns*4);
for l=1:A1Ns
  % A1s20
  TA1s20P=schurNSPAlatticeT(wcheck,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22);
  TA1s20M=schurNSPAlatticeT(wcheck,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22);
  diff_TA1(:,1+((l-1)*4))=(TA1s20P-TA1s20M)/del;
  % A1s00
  TA1s00P=schurNSPAlatticeT(wcheck,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22);
  TA1s00M=schurNSPAlatticeT(wcheck,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22);
  diff_TA1(:,2+((l-1)*4))=(TA1s00P-TA1s00M)/del;
  % A1s02
  TA1s02P=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22);
  TA1s02M=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22);
  diff_TA1(:,3+((l-1)*4))=(TA1s02P-TA1s02M)/del;
  % A1s22
  TA1s22P=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                            A2s20,A2s00,A2s02,A2s22);
  TA1s22M=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                            A2s20,A2s00,A2s02,A2s22);
  diff_TA1(:,4+((l-1)*4))=(TA1s22P-TA1s22M)/del;
  % Shift delA1s
  delA1s=circshift(delA1s,1);
endfor
max_gradTA1_error=max(max(abs(diff_TA1-gradT(:,1:(A1Ns*4)))));
if max_gradTA1_error > tol
  error("max_gradTA1_error > tol");
endif

% Check the gradients of the group delay wrt A2s
del=1e-6;
tol=del/5;
delA2s=zeros(size(A2s20));
delA2s(1)=del/2;
diff_TA2=zeros(ncheck,A2Ns*4);
for l=1:A2Ns
  % A2s20
  TA2s20P=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20+delA2s,A2s00,A2s02,A2s22);
  TA2s20M=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20-delA2s,A2s00,A2s02,A2s22);
  diff_TA2(:,1+((l-1)*4))=(TA2s20P-TA2s20M)/del;
  % A2s00
  TA2s00P=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00+delA2s,A2s02,A2s22);
  TA2s00M=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00-delA2s,A2s02,A2s22);
  diff_TA2(:,2+((l-1)*4))=(TA2s00P-TA2s00M)/del;
  % A2s02
  TA2s02P=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02+delA2s,A2s22);
  TA2s02M=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02-delA2s,A2s22);
  diff_TA2(:,3+((l-1)*4))=(TA2s02P-TA2s02M)/del;
  % A2s22
  TA2s22P=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22+delA2s);
  TA2s22M=schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                            A2s20,A2s00,A2s02,A2s22-delA2s);
  diff_TA2(:,4+((l-1)*4))=(TA2s22P-TA2s22M)/del;
  % Shift delA2s
  delA2s=circshift(delA2s,1);
endfor
max_gradTA2_error=...
  max(max(abs(diff_TA2-gradT(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
if max_gradTA2_error > tol
  error("max_gradTA2_error > tol");
endif

% Calculate the diagonal of the Hessian
[T,gradT,diagHessT]=...
  schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22);

% Check the diagonal of the Hessian of the group delay wrt A1s
del=1e-6;
tol=del*20;
delA1s=zeros(size(A1s20));
delA1s(1)=del/2;
diff_gradTA1=zeros(ncheck,A1Ns*4);
for l=1:A1Ns
  % A1s20
  [TA1s20P,gradTA1s20P]=...
    schurNSPAlatticeT(wcheck,A1s20+delA1s,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22);
  [TA1s20M,gradTA1s20M]=...
    schurNSPAlatticeT(wcheck,A1s20-delA1s,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22);
  lindex=(1+((l-1)*4));
  diff_gradTA1(:,lindex)=(gradTA1s20P(:,lindex)-gradTA1s20M(:,lindex))/del;
  % A1s00
  [TA1s00P,gradTA1s00P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00+delA1s,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22);
  [TA1s00M,gradTA1s00M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00-delA1s,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22);
  lindex=(2+((l-1)*4));
  diff_gradTA1(:,lindex)=(gradTA1s00P(:,lindex)-gradTA1s00M(:,lindex))/del;
  % A1s02
  [TA1s02P,gradTA1s02P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02+delA1s,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22);
  [TA1s02M,gradTA1s02M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02-delA1s,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22);
  lindex=(3+((l-1)*4));
  diff_gradTA1(:,lindex)=(gradTA1s02P(:,lindex)-gradTA1s02M(:,lindex))/del;
  % A1s22
  [TA1s22P,gradTA1s22P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22+delA1s, ...
                      A2s20,A2s00,A2s02,A2s22);
  [TA1s22M,gradTA1s22M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22-delA1s, ...
                      A2s20,A2s00,A2s02,A2s22);
  lindex=(4+((l-1)*4));
  diff_gradTA1(:,lindex)=(gradTA1s22P(:,lindex)-gradTA1s22M(:,lindex))/del;
  % Shift delA1s
  delA1s=circshift(delA1s,1);
endfor
max_diagHessTA1_error=max(max(abs(diff_gradTA1-diagHessT(:,1:(A1Ns*4)))));
if max_diagHessTA1_error > tol
  error("max_diagHessTA1_error > tol");
endif

% Check the diagonal of the Hessian of the group delay wrt A2s
del=1e-6;
tol=del*20;
delA2s=zeros(size(A2s20));
delA2s(1)=del/2;
diff_gradTA2=zeros(ncheck,A2Ns*4);
for l=1:A2Ns
  % A2s20
  [TA2s20P,gradTA2s20P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20+delA2s,A2s00,A2s02,A2s22);
  [TA2s20M,gradTA2s20M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20-delA2s,A2s00,A2s02,A2s22);
  lindex=(1+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradTA2(:,lindex)=(gradTA2s20P(:,rindex)-gradTA2s20M(:,rindex))/del;
  % A2s00
  [TA2s00P,gradTA2s00P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00+delA2s,A2s02,A2s22);
  [TA2s00M,gradTA2s00M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00-delA2s,A2s02,A2s22);
  lindex=(2+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradTA2(:,lindex)=(gradTA2s00P(:,rindex)-gradTA2s00M(:,rindex))/del;
  % A2s02
  [TA2s02P,gradTA2s02P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02+delA2s,A2s22);
  [TA2s02M,gradTA2s02M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02-delA2s,A2s22);
  lindex=(3+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradTA2(:,lindex)=(gradTA2s02P(:,rindex)-gradTA2s02M(:,rindex))/del;
  % A2s22
  [TA2s22P,gradTA2s22P]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22+delA2s);
  [TA2s22M,gradTA2s22M]=...
    schurNSPAlatticeT(wcheck,A1s20,A1s00,A1s02,A1s22, ...
                      A2s20,A2s00,A2s02,A2s22-delA2s);
  lindex=(4+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradTA2(:,lindex)=(gradTA2s22P(:,rindex)-gradTA2s22M(:,rindex))/del;
  % Shift delA2s
  delA2s=circshift(delA2s,1);
endfor
max_diagHessTA2_error=...
  max(max(abs(diff_gradTA2-diagHessT(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
if max_diagHessTA2_error > tol
  error("max_diagHessTA2_error > tol");
endif

% Done
diary off
movefile schurNSPAlatticeT_test.diary.tmp schurNSPAlatticeT_test.diary;
