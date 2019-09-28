% arccs_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("arccs_test.diary");
unlink("arccs_test.diary.tmp");
diary arccs_test.diary.tmp

k=0.05:0.05:0.95;
ur=(-0.85:0.1:0.85);
ui=(-0.85:0.1:0.85)';
u=[ur+(j*ui),ur-(j*ui)];
tol=5*eps;
for n=1:length(k),
  [snu,cnu]=ellipj(u,k(n)^2);
  csu=cnu./snu;
  uacs=zeros(size(u));
  erracs=zeros(size(u));
  for m=1:columns(u),
    for l=1:rows(u),
      [uacs(l,m),erracs(l,m)]=arccs(csu(l,m),k(n));
    endfor
  endfor
  if max(max(abs(uacs-u)))>tol
    error("max(max(abs(uacs-u)))>tol");
  endif
endfor

% Done
diary off
movefile arccs_test.diary.tmp arccs_test.diary;
