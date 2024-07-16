% schurNSlatticeT_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurNSlatticeT_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2,

  schur_lattice_test_common;
  % Convert filter transfer function to Schur normalised-scaled lattice form
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  Ns=length(s10);

  %
  % Calculate the group delay response
  %
  T=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);

  % Check the group delay response
  t=delayz(n,d,wt);
  if max(abs(t-T)) > 4e6*eps
    error("max(abs(t-T)) > 4e6*eps");
  endif

  %
  % Calculate the gradients of the group delay response
  %
  [T,gradT]=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
  
  % Check the gradients of the group delay response wrt s
  del=1e-6;
  dels=zeros(size(s10));
  dels(1)=del/2;
  est_dTds=zeros(1,Ns*6);
  for l=1:Ns
    % s10
    Ts10P=schurNSlatticeT(wtc,s10+dels,s11,s20,s00,s02,s22);
    Ts10M=schurNSlatticeT(wtc,s10-dels,s11,s20,s00,s02,s22);
    est_dTds(1+((l-1)*6))=(Ts10P-Ts10M)/del;
    % s11
    Ts11P=schurNSlatticeT(wtc,s10,s11+dels,s20,s00,s02,s22);
    Ts11M=schurNSlatticeT(wtc,s10,s11-dels,s20,s00,s02,s22);
    est_dTds(2+((l-1)*6))=(Ts11P-Ts11M)/del;
    % s20
    Ts20P=schurNSlatticeT(wtc,s10,s11,s20+dels,s00,s02,s22);
    Ts20M=schurNSlatticeT(wtc,s10,s11,s20-dels,s00,s02,s22);
    est_dTds(3+((l-1)*6))=(Ts20P-Ts20M)/del;
    % s00
    Ts00P=schurNSlatticeT(wtc,s10,s11,s20,s00+dels,s02,s22);
    Ts00M=schurNSlatticeT(wtc,s10,s11,s20,s00-dels,s02,s22);
    est_dTds(4+((l-1)*6))=(Ts00P-Ts00M)/del;
    % s02
    Ts02P=schurNSlatticeT(wtc,s10,s11,s20,s00,s02+dels,s22);
    Ts02M=schurNSlatticeT(wtc,s10,s11,s20,s00,s02-dels,s22);
    est_dTds(5+((l-1)*6))=(Ts02P-Ts02M)/del;
    % s22
    Ts22P=schurNSlatticeT(wtc,s10,s11,s20,s00,s02,s22+dels);
    Ts22M=schurNSlatticeT(wtc,s10,s11,s20,s00,s02,s22-dels);
    est_dTds(6+((l-1)*6))=(Ts22P-Ts22M)/del;
    % Shift dels
    dels=circshift(dels,1);
  endfor
  if max(abs(est_dTds-gradT(ntc,:))) > del/20
    error("max(abs(est_dTds-gradT(ntc,:))) > del/20");
  endif

  %
  % Calculate the diagonal of the Hessian of the group delay response
  %
  [T,gradT,diagHessT]=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
  
  % Check the diagonal of the Hessian of the group delay response
  del=1e-6;
  dels=zeros(size(s10));
  dels(1)=del/2;
  est_diagd2Tds2=zeros(1,Ns*6);
  for l=1:Ns
    % s10
    [Ts10P,gradTs10P]=schurNSlatticeT(wtc,s10+dels,s11,s20,s00,s02,s22);
    [Ts10M,gradTs10M]=schurNSlatticeT(wtc,s10-dels,s11,s20,s00,s02,s22);
    lindex=(1+((l-1)*6));
    est_diagd2Tds2(lindex)=(gradTs10P(lindex)-gradTs10M(lindex))/del;
    % s11
    [Ts11P,gradTs11P]=schurNSlatticeT(wtc,s10,s11+dels,s20,s00,s02,s22);
    [Ts11M,gradTs11M]=schurNSlatticeT(wtc,s10,s11-dels,s20,s00,s02,s22);
    lindex=(2+((l-1)*6));
    est_diagd2Tds2(lindex)=(gradTs11P(lindex)-gradTs11M(lindex))/del;
    % s20
    [Ts20P,gradTs20P]=schurNSlatticeT(wtc,s10,s11,s20+dels,s00,s02,s22);
    [Ts20M,gradTs20M]=schurNSlatticeT(wtc,s10,s11,s20-dels,s00,s02,s22);
    lindex=(3+((l-1)*6));
    est_diagd2Tds2(lindex)=(gradTs20P(lindex)-gradTs20M(lindex))/del;
    % s00
    [Ts00P,gradTs00P]=schurNSlatticeT(wtc,s10,s11,s20,s00+dels,s02,s22);
    [Ts00M,gradTs00M]=schurNSlatticeT(wtc,s10,s11,s20,s00-dels,s02,s22);
    lindex=(4+((l-1)*6));
    est_diagd2Tds2(lindex)=(gradTs00P(lindex)-gradTs00M(lindex))/del;
    % s02
    [Ts02P,gradTs02P]=schurNSlatticeT(wtc,s10,s11,s20,s00,s02+dels,s22);
    [Ts02M,gradTs02M]=schurNSlatticeT(wtc,s10,s11,s20,s00,s02-dels,s22);
    lindex=(5+((l-1)*6));
    est_diagd2Tds2(lindex)=(gradTs02P(lindex)-gradTs02M(lindex))/del;
    % s22
    [Ts22P,gradTs22P]=schurNSlatticeT(wtc,s10,s11,s20,s00,s02,s22+dels);
    [Ts22M,gradTs22M]=schurNSlatticeT(wtc,s10,s11,s20,s00,s02,s22-dels);
    lindex=(6+((l-1)*6));
    est_diagd2Tds2(lindex)=(gradTs22P(lindex)-gradTs22M(lindex))/del;
    % Shift dels
    dels=circshift(dels,1);
  endfor
  if max(abs(est_diagd2Tds2-diagHessT(ntc,:))) > del/10
    error("max(abs(est_diagd2Tds2-diagHessT(ntc,:))) > del/10");
  endif

endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
