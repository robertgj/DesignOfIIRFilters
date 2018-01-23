% schurNSlatticeAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurNSlatticeAsq_test.diary");
unlink("schurNSlatticeAsq_test.diary.tmp");
diary schurNSlatticeAsq_test.diary.tmp

tic;
verbose=true;

% R=2 bandpass filter from iir_sqp_slb_bandpass_test.m
fapl=0.1;fapu=0.2;fasl=0.05;ftpl=0.09;ftpu=0.21;
n = [   0.0119898572,   0.0055005262,   0.0227465629,   0.0227676952, ... 
        0.0477699159,   0.0346032386,   0.0300158271,   0.0007692638, ... 
       -0.0021264872,  -0.0305118086,  -0.0677680871,  -0.1021835628, ... 
       -0.0704487200,   0.0361830861,   0.1357812748,   0.1570834904, ... 
        0.0638315615,  -0.0390403107,  -0.0989222753,  -0.0714382761, ... 
       -0.0337487587 ]';
d = [   1.0000000000,   0.0000000000,   1.7122688809,   0.0000000000, ... 
        1.9398016652,   0.0000000000,   1.9464309420,   0.0000000000, ... 
        1.7222723403,   0.0000000000,   1.2656797602,   0.0000000000, ... 
        0.8103366569,   0.0000000000,   0.4372977468,   0.0000000000, ... 
        0.1983164681,   0.0000000000,   0.0654678098,   0.0000000000, ... 
        0.0147305592 ]';
nplot=1024;
ntpl=floor(nplot*ftpl/0.5);
ntpu=ceil(nplot*ftpu/0.5);
[h,wplot]=freqz(n,d,nplot);

% Convert filter transfer function to Schur normalised-scaled lattice form
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
Ns=length(s10);
[Asq,gradAsq,diagHessAsq]=schurNSlatticeAsq(wplot,s10,s11,s20,s00,s02,s22);

% Check the magnitude-squared response
if max(abs((abs(h).^2)-Asq)) > 32*eps
  error("max(abs((abs(h).^2)-Asq))(%g*eps) > 32*eps", ...
        max(abs((abs(h).^2)-Asq))/eps);
endif

% Check the gradients of the squared-magnitude wrt s
del=1e-6;
dels=zeros(size(s10));
dels(1)=del/2;
wtpl=wplot(ntpl);
diff_Asq=zeros(1,6*Ns);
for l=1:Ns
  % s10
  Asqs10P=schurNSlatticeAsq(wtpl,s10+dels,s11,s20,s00,s02,s22);
  Asqs10M=schurNSlatticeAsq(wtpl,s10-dels,s11,s20,s00,s02,s22);
  diff_Asq(1+((l-1)*6))=(Asqs10P-Asqs10M)/del;
  % s11
  Asqs11P=schurNSlatticeAsq(wtpl,s10,s11+dels,s20,s00,s02,s22);
  Asqs11M=schurNSlatticeAsq(wtpl,s10,s11-dels,s20,s00,s02,s22);
  diff_Asq(2+((l-1)*6))=(Asqs11P-Asqs11M)/del;
  % s20
  Asqs20P=schurNSlatticeAsq(wtpl,s10,s11,s20+dels,s00,s02,s22);
  Asqs20M=schurNSlatticeAsq(wtpl,s10,s11,s20-dels,s00,s02,s22);
  diff_Asq(3+((l-1)*6))=(Asqs20P-Asqs20M)/del;
  % s00
  Asqs00P=schurNSlatticeAsq(wtpl,s10,s11,s20,s00+dels,s02,s22);
  Asqs00M=schurNSlatticeAsq(wtpl,s10,s11,s20,s00-dels,s02,s22);
  diff_Asq(4+((l-1)*6))=(Asqs00P-Asqs00M)/del; 
  % s02
  Asqs02P=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02+dels,s22);
  Asqs02M=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02-dels,s22);
  diff_Asq(5+((l-1)*6))=(Asqs02P-Asqs02M)/del;
  % s22
  Asqs22P=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02,s22+dels);
  Asqs22M=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02,s22-dels);
  diff_Asq(6+((l-1)*6))=(Asqs22P-Asqs22M)/del;
  % Shift dels
  dels=shift(dels,1);
endfor
if max(abs(diff_Asq-gradAsq(ntpl,:))) > del/760.37
  error("max(abs(diff_Asq-gradAsq(ntpl,:)))(del/%g) > del/760.37", ...
        del/max(abs(diff_Asq-gradAsq(ntpl,:))));
endif

% Check the diagonal of the Hessian of the squared-magnitude wrt s
del=1e-6;
dels=zeros(size(s10));
dels(1)=del/2;
wtpl=wplot(ntpl);
diff_gradAsq=zeros(1,6*Ns);
for l=1:Ns
  % s10
  [Asqs10P,gradAsqs10P]=schurNSlatticeAsq(wtpl,s10+dels,s11,s20,s00,s02,s22);
  [Asqs10M,gradAsqs10M]=schurNSlatticeAsq(wtpl,s10-dels,s11,s20,s00,s02,s22);
  lindex=(1+((l-1)*6));
  diff_gradAsq(lindex)=(gradAsqs10P(lindex)-gradAsqs10M(lindex))/del;
  % s11
  [Asqs11P,gradAsqs11P]=schurNSlatticeAsq(wtpl,s10,s11+dels,s20,s00,s02,s22);
  [Asqs11M,gradAsqs11M]=schurNSlatticeAsq(wtpl,s10,s11-dels,s20,s00,s02,s22);
  lindex=(2+((l-1)*6));
  diff_gradAsq(lindex)=(gradAsqs11P(lindex)-gradAsqs11M(lindex))/del;
  % s20
  [Asqs20P,gradAsqs20P]=schurNSlatticeAsq(wtpl,s10,s11,s20+dels,s00,s02,s22);
  [Asqs20M,gradAsqs20M]=schurNSlatticeAsq(wtpl,s10,s11,s20-dels,s00,s02,s22);
  lindex=(3+((l-1)*6));
  diff_gradAsq(lindex)=(gradAsqs20P(lindex)-gradAsqs20M(lindex))/del;
  % s00
  [Asqs00P,gradAsqs00P]=schurNSlatticeAsq(wtpl,s10,s11,s20,s00+dels,s02,s22);
  [Asqs00M,gradAsqs00M]=schurNSlatticeAsq(wtpl,s10,s11,s20,s00-dels,s02,s22);
  lindex=(4+((l-1)*6));
  diff_gradAsq(lindex)=(gradAsqs00P(lindex)-gradAsqs00M(lindex))/del;
  % s02
  [Asqs02P,gradAsqs02P]=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02+dels,s22);
  [Asqs02M,gradAsqs02M]=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02-dels,s22);
  lindex=(5+((l-1)*6));
  diff_gradAsq(lindex)=(gradAsqs02P(lindex)-gradAsqs02M(lindex))/del;
  % s22
  [Asqs22P,gradAsqs22P]=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02,s22+dels);
  [Asqs22M,gradAsqs22M]=schurNSlatticeAsq(wtpl,s10,s11,s20,s00,s02,s22-dels);
  lindex=(6+((l-1)*6));
  diff_gradAsq(lindex)=(gradAsqs22P(lindex)-gradAsqs22M(lindex))/del;
  % Shift dels
  dels=shift(dels,1);
endfor
if max(abs(diff_gradAsq-diagHessAsq(ntpl,:))) > del/214.82
  error("max(abs(diff_gradAsq-diagHessAsq(ntpl,:)))(del/%g) > del/214.82", ...
       del/max(abs(diff_gradAsq-diagHessAsq(ntpl,:))));
endif

% Done
toc;
diary off
movefile schurNSlatticeAsq_test.diary.tmp schurNSlatticeAsq_test.diary;
