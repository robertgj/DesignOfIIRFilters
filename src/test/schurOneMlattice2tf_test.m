% schurOneMlattice2tf_test.m
% Copyright (C) 2022 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice2tf_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fc=0.1;dBap=1;dBas=40;

for N=1:12,

  tol_eps=100*N;
  
  % Calculate Schur one-multiplier lattice coefficients
  [n,d]=ellip(N,dBap,dBas,2*fc);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [nn,dd]=schurOneMlattice2tf(k,epsilon,p,c);
  if max(abs(n-nn)) > tol_eps*eps
    error("N=%d,max(abs(n-nn)) (%g*eps) > %g*eps",N,max(abs(n-nn))/eps,tol_eps);
  endif
  if max(abs(d-dd)) > tol_eps*eps
    error("N=%d,max(abs(d-dd)) (%g*eps) > %g*eps",N,max(abs(d-dd))/eps,tol_eps);
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
