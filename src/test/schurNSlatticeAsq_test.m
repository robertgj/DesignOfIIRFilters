% schurNSlatticeAsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurNSlatticeAsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2,

  schur_lattice_test_common;

  % Convert filter transfer function to Schur normalised-scaled lattice form
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  Ns=length(s10);

  %
  % Calculate the magnitude squared response
  %
  [Asq,gradAsq,diagHessAsq]=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);

  % Check the magnitude-squared response
  h=freqz(n,d,wa);
  if max(abs((abs(h).^2)-Asq)) > 1e4*eps
    error("max(abs((abs(h).^2)-Asq))(%g*eps) > 1e4*eps", ...
          max(abs((abs(h).^2)-Asq))/eps);
  endif

  % Check the gradients of the squared-magnitude wrt s
  del=1e-6;
  dels=zeros(size(s10));
  dels(1)=del/2;
  est_dAsqds=zeros(1,6*Ns);
  for l=1:Ns
    % s10
    Asqs10P=schurNSlatticeAsq(wac,s10+dels,s11,s20,s00,s02,s22);
    Asqs10M=schurNSlatticeAsq(wac,s10-dels,s11,s20,s00,s02,s22);
    est_dAsqds(1+((l-1)*6))=(Asqs10P-Asqs10M)/del;
    % s11
    Asqs11P=schurNSlatticeAsq(wac,s10,s11+dels,s20,s00,s02,s22);
    Asqs11M=schurNSlatticeAsq(wac,s10,s11-dels,s20,s00,s02,s22);
    est_dAsqds(2+((l-1)*6))=(Asqs11P-Asqs11M)/del;
    % s20
    Asqs20P=schurNSlatticeAsq(wac,s10,s11,s20+dels,s00,s02,s22);
    Asqs20M=schurNSlatticeAsq(wac,s10,s11,s20-dels,s00,s02,s22);
    est_dAsqds(3+((l-1)*6))=(Asqs20P-Asqs20M)/del;
    % s00
    Asqs00P=schurNSlatticeAsq(wac,s10,s11,s20,s00+dels,s02,s22);
    Asqs00M=schurNSlatticeAsq(wac,s10,s11,s20,s00-dels,s02,s22);
    est_dAsqds(4+((l-1)*6))=(Asqs00P-Asqs00M)/del; 
    % s02
    Asqs02P=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02+dels,s22);
    Asqs02M=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02-dels,s22);
    est_dAsqds(5+((l-1)*6))=(Asqs02P-Asqs02M)/del;
    % s22
    Asqs22P=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02,s22+dels);
    Asqs22M=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02,s22-dels);
    est_dAsqds(6+((l-1)*6))=(Asqs22P-Asqs22M)/del;
    % Shift dels
    dels=circshift(dels,1);
  endfor
  if max(abs(est_dAsqds-gradAsq(nac,:))) > del/600
    error("max(abs(est_dAsqds-gradAsq(nac,:)))(del/%g) > del/600", ...
          del/max(abs(est_dAsqds-gradAsq(nac,:))));
  endif

  % Check the diagonal of the Hessian of the squared-magnitude wrt s
  del=1e-6;
  dels=zeros(size(s10));
  dels(1)=del/2;
  est_d2Asqds2=zeros(1,6*Ns);
  for l=1:Ns
    % s10
    [Asqs10P,gradAsqs10P]=schurNSlatticeAsq(wac,s10+dels,s11,s20,s00,s02,s22);
    [Asqs10M,gradAsqs10M]=schurNSlatticeAsq(wac,s10-dels,s11,s20,s00,s02,s22);
    lindex=(1+((l-1)*6));
    est_d2Asqds2(lindex)=(gradAsqs10P(lindex)-gradAsqs10M(lindex))/del;
    % s11
    [Asqs11P,gradAsqs11P]=schurNSlatticeAsq(wac,s10,s11+dels,s20,s00,s02,s22);
    [Asqs11M,gradAsqs11M]=schurNSlatticeAsq(wac,s10,s11-dels,s20,s00,s02,s22);
    lindex=(2+((l-1)*6));
    est_d2Asqds2(lindex)=(gradAsqs11P(lindex)-gradAsqs11M(lindex))/del;
    % s20
    [Asqs20P,gradAsqs20P]=schurNSlatticeAsq(wac,s10,s11,s20+dels,s00,s02,s22);
    [Asqs20M,gradAsqs20M]=schurNSlatticeAsq(wac,s10,s11,s20-dels,s00,s02,s22);
    lindex=(3+((l-1)*6));
    est_d2Asqds2(lindex)=(gradAsqs20P(lindex)-gradAsqs20M(lindex))/del;
    % s00
    [Asqs00P,gradAsqs00P]=schurNSlatticeAsq(wac,s10,s11,s20,s00+dels,s02,s22);
    [Asqs00M,gradAsqs00M]=schurNSlatticeAsq(wac,s10,s11,s20,s00-dels,s02,s22);
    lindex=(4+((l-1)*6));
    est_d2Asqds2(lindex)=(gradAsqs00P(lindex)-gradAsqs00M(lindex))/del;
    % s02
    [Asqs02P,gradAsqs02P]=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02+dels,s22);
    [Asqs02M,gradAsqs02M]=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02-dels,s22);
    lindex=(5+((l-1)*6));
    est_d2Asqds2(lindex)=(gradAsqs02P(lindex)-gradAsqs02M(lindex))/del;
    % s22
    [Asqs22P,gradAsqs22P]=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02,s22+dels);
    [Asqs22M,gradAsqs22M]=schurNSlatticeAsq(wac,s10,s11,s20,s00,s02,s22-dels);
    lindex=(6+((l-1)*6));
    est_d2Asqds2(lindex)=(gradAsqs22P(lindex)-gradAsqs22M(lindex))/del;
    % Shift dels
    dels=circshift(dels,1);
  endfor
  if max(abs(est_d2Asqds2-diagHessAsq(nac,:))) > del/214.82
    error("max(abs(est_d2Asqds2-diagHessAsq(nac,:)))(del/%g) > del/214.82", ...
          del/max(abs(est_d2Asqds2-diagHessAsq(nac,:))));
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
