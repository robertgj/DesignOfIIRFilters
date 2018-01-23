% schurNSPAlatticeAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurNSPAlatticeAsq_test.diary");
unlink("schurNSPAlatticeAsq_test.diary.tmp");
diary schurNSPAlatticeAsq_test.diary.tmp

tic;
verbose=true;

% Low pass filter
norder=5;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1024;
npass=floor(nplot*fpass/0.5);
[h,wplot]=freqz(n,d,nplot);
ncheck=2*npass;
hcheck=h(1:ncheck);
wcheck=wplot(1:ncheck);

% Alternative calculation
[Aap1,Aap2]=tf2pa(n,d);
hAap1=freqz(fliplr(Aap1),Aap1,nplot);
hAap2=freqz(fliplr(Aap2),Aap2,nplot);
hAap12=(hAap1+hAap2)/2;

% Convert filter transfer function to Schur normalised-scaled lattice form
[A1s10,A1s11,A1s20,A1s02,A1s00,A1s22]=tf2schurNSlattice(fliplr(Aap1),Aap1);
[A2s10,A2s11,A2s20,A2s02,A2s00,A2s22]=tf2schurNSlattice(fliplr(Aap2),Aap2);
A1Ns=length(A1s20);
A2Ns=length(A2s20);

% Calculate the magnitude response
Asq=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22,A2s20,A2s02,A2s00,A2s22);

% Check the magnitude-squared response
max_Asq_error=max(abs((abs(hcheck).^2)-Asq));
if max_Asq_error > 140*eps
  error("max_Asq_error(%g*eps) > 140*eps",max_Asq_error/eps);
endif

% Calculate the gradients
[Asq,gradAsq]=...
  schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22,A2s20,A2s02,A2s00,A2s22);

% Check the gradients of the squared-magnitude wrt A1s
del=1e-6;
tol=del/855.37;
delA1s=zeros(size(A1s20));
delA1s(1)=del/2;
diff_AsqA1=zeros(ncheck,A1Ns*4);
for l=1:A1Ns
  % A1s20
  AsqA1s20P=schurNSPAlatticeAsq(wcheck,A1s20+delA1s,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22);
  AsqA1s20M=schurNSPAlatticeAsq(wcheck,A1s20-delA1s,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22);
  diff_AsqA1(:,1+((l-1)*4))=(AsqA1s20P-AsqA1s20M)/del;
  % A1s02
  AsqA1s02P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02+delA1s,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22);
  AsqA1s02M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02-delA1s,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22);
  diff_AsqA1(:,2+((l-1)*4))=(AsqA1s02P-AsqA1s02M)/del;
  % A1s00
  AsqA1s00P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00+delA1s,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22);
  AsqA1s00M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00-delA1s,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22);
  diff_AsqA1(:,3+((l-1)*4))=(AsqA1s00P-AsqA1s00M)/del;
  % A1s22
  AsqA1s22P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22+delA1s, ...
                                A2s20,A2s02,A2s00,A2s22);
  AsqA1s22M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22-delA1s, ...
                                A2s20,A2s02,A2s00,A2s22);
  diff_AsqA1(:,4+((l-1)*4))=(AsqA1s22P-AsqA1s22M)/del;
  % Shift delA1s
  delA1s=shift(delA1s,1);
endfor
max_gradAsq_A1_error=max(max(abs(diff_AsqA1-gradAsq(:,1:(A1Ns*4)))));
if max_gradAsq_A1_error > tol
  error("max_gradAsq_A1_error(del/%g) > tol",del/max_gradAsq_A1_error);
endif

% Check the gradients of the squared-magnitude wrt A2s
del=1e-6;
tol=del/725;
delA2s=zeros(size(A2s20));
delA2s(1)=del/2;
diff_AsqA2=zeros(ncheck,A2Ns*4);
for l=1:A2Ns
  % A2s20
  AsqA2s20P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20+delA2s,A2s02,A2s00,A2s22);
  AsqA2s20M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20-delA2s,A2s02,A2s00,A2s22);
  diff_AsqA2(:,1+((l-1)*4))=(AsqA2s20P-AsqA2s20M)/del;
  % A2s02
  AsqA2s02P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02+delA2s,A2s00,A2s22);
  AsqA2s02M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02-delA2s,A2s00,A2s22);
  diff_AsqA2(:,2+((l-1)*4))=(AsqA2s02P-AsqA2s02M)/del;
  % A2s00
  AsqA2s00P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00+delA2s,A2s22);
  AsqA2s00M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00-delA2s,A2s22);
  diff_AsqA2(:,3+((l-1)*4))=(AsqA2s00P-AsqA2s00M)/del;
  % A2s22
  AsqA2s22P=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22+delA2s);
  AsqA2s22M=schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                                A2s20,A2s02,A2s00,A2s22-delA2s);
  diff_AsqA2(:,4+((l-1)*4))=(AsqA2s22P-AsqA2s22M)/del;
  % Shift delA2s
  delA2s=shift(delA2s,1);
endfor
max_gradAsq_A2_error=...
  max(max(abs(diff_AsqA2-gradAsq(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
if max_gradAsq_A2_error > tol
  error("max_gradAsq_A2_error(del/%g) > tol",del/max_gradAsq_A2_error);
endif

% Calculate the diagonal of the Hessian
[Asq,gradAsq,diagHessAsq]=...
  schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22,A2s20,A2s02,A2s00,A2s22);

% Check the diagonal of the Hessian of the squared-magnitude wrt A1s
del=1e-6;
tol=del/217.58;
delA1s=zeros(size(A1s20));
delA1s(1)=del/2;
diff_gradAsqA1=zeros(ncheck,A1Ns*4);
for l=1:A1Ns
  % A1s20
  [AsqA1s20P,gradAsqA1s20P]=...
    schurNSPAlatticeAsq(wcheck,A1s20+delA1s,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22);
  [AsqA1s20M,gradAsqA1s20M]=...
    schurNSPAlatticeAsq(wcheck,A1s20-delA1s,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22);
  lindex=(1+((l-1)*4));
  diff_gradAsqA1(:,lindex)=(gradAsqA1s20P(:,lindex)-gradAsqA1s20M(:,lindex))/del;
  % A1s02
  [AsqA1s02P,gradAsqA1s02P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02+delA1s,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22);
  [AsqA1s02M,gradAsqA1s02M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02-delA1s,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22);
  lindex=(2+((l-1)*4));
  diff_gradAsqA1(:,lindex)=(gradAsqA1s02P(:,lindex)-gradAsqA1s02M(:,lindex))/del;
  % A1s00
  [AsqA1s00P,gradAsqA1s00P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00+delA1s,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22);
  [AsqA1s00M,gradAsqA1s00M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00-delA1s,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22);
  lindex=(3+((l-1)*4));
  diff_gradAsqA1(:,lindex)=(gradAsqA1s00P(:,lindex)-gradAsqA1s00M(:,lindex))/del;
  % A1s22
  [AsqA1s22P,gradAsqA1s22P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22+delA1s, ...
                        A2s20,A2s02,A2s00,A2s22);
  [AsqA1s22M,gradAsqA1s22M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22-delA1s, ...
                        A2s20,A2s02,A2s00,A2s22);
  lindex=(4+((l-1)*4));
  diff_gradAsqA1(:,lindex)=(gradAsqA1s22P(:,lindex)-gradAsqA1s22M(:,lindex))/del;
  % Shift delA1s
  delA1s=shift(delA1s,1);
endfor
max_diagHessAsq_A1_error=max(max(abs(diff_gradAsqA1-diagHessAsq(:,1:(A1Ns*4)))));
if max_diagHessAsq_A1_error > tol
  error("max_diagHessAsq_A1_error(del/%g) > tol",del/max_diagHessAsq_A1_error);
endif

% Check the diagonal of the Hessian of the squared-magnitude wrt A2s
del=1e-6;
tol=del/125;
delA2s=zeros(size(A2s20));
delA2s(1)=del/2;
diff_gradAsqA2=zeros(ncheck,A2Ns*4);
for l=1:A2Ns
  % A2s20
  [AsqA2s20P,gradAsqA2s20P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20+delA2s,A2s02,A2s00,A2s22);
  [AsqA2s20M,gradAsqA2s20M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20-delA2s,A2s02,A2s00,A2s22);
  lindex=(1+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradAsqA2(:,lindex)=(gradAsqA2s20P(:,rindex)-gradAsqA2s20M(:,rindex))/del;
  % A2s02
  [AsqA2s02P,gradAsqA2s02P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02+delA2s,A2s00,A2s22);
  [AsqA2s02M,gradAsqA2s02M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02-delA2s,A2s00,A2s22);
  lindex=(2+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradAsqA2(:,lindex)=(gradAsqA2s02P(:,rindex)-gradAsqA2s02M(:,rindex))/del;
  % A2s00
  [AsqA2s00P,gradAsqA2s00P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00+delA2s,A2s22);
  [AsqA2s00M,gradAsqA2s00M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00-delA2s,A2s22);
  lindex=(3+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradAsqA2(:,lindex)=(gradAsqA2s00P(:,rindex)-gradAsqA2s00M(:,rindex))/del;
  % A2s22
  [AsqA2s22P,gradAsqA2s22P]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22+delA2s);
  [AsqA2s22M,gradAsqA2s22M]=...
    schurNSPAlatticeAsq(wcheck,A1s20,A1s02,A1s00,A1s22, ...
                        A2s20,A2s02,A2s00,A2s22-delA2s);
  lindex=(4+((l-1)*4));
  rindex=lindex+(A1Ns*4);
  diff_gradAsqA2(:,lindex)=(gradAsqA2s22P(:,rindex)-gradAsqA2s22M(:,rindex))/del;
  % Shift delA2s
  delA2s=shift(delA2s,1);
endfor
max_diagHessAsq_A2_error=...
  max(max(abs(diff_gradAsqA2-diagHessAsq(:,((A1Ns*4)+1):((A1Ns+A2Ns)*4)))));
if max_diagHessAsq_A2_error > tol
  error("max_diagHessAsq_A2_error(del/%g) > tol",del/max_diagHessAsq_A2_error);
endif

% Done
toc;
if verbose
endif
diary off
movefile schurNSPAlatticeAsq_test.diary.tmp schurNSPAlatticeAsq_test.diary;
