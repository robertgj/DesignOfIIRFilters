% schurOneMlattice2tf_test.m
% Copyright (C) 2022-2024 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice2tf_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fc=0.1;dBap=1;dBas=40;

for N=1:12,

  % Calculate Schur one-multiplier lattice coefficients
  tol_eps=3*(N^2);
  [n,d]=ellip(N,dBap,dBas,2*fc);
  [k,epsilon,p,c,S]=tf2schurOneMlattice(n,d);
  [nn,dd]=schurOneMlattice2tf(k,epsilon,p,c);
  if max(abs(n-nn)) > tol_eps*eps
    error("N=%d,max(abs(n-nn)) (%g*eps) > %g*eps",N,max(abs(n-nn))/eps,tol_eps);
  endif
  if max(abs(d-dd)) > tol_eps*eps
    error("N=%d,max(abs(d-dd)) (%g*eps) > %g*eps",N,max(abs(d-dd))/eps,tol_eps);
  endif

  % Check Schur one-multiplier lattice coefficients with epsilon=ones(size(k))
  tol_eps=tol_eps^2;
  epsilon_ones=ones(size(k));
  [k1,epsilon,p,c1,S,S1M]=tf2schurOneMlattice(nn,dd,epsilon_ones);
  [n1,d1]=schurOneMlattice2tf(k1,epsilon,p,c1);
  if epsilon ~= epsilon_ones
    error("epsilon ~= epsilon_ones");
  endif
  if max(abs(n-n1)) > tol_eps*eps
    error("N=%d,max(abs(n-n1)) (%g*eps) > %g*eps",N,max(abs(n-n1))/eps,tol_eps);
  endif
  if max(abs(d-d1)) > tol_eps*eps
    error("N=%d,max(abs(d-d1)) (%g*eps) > %g*eps",N,max(abs(d-d1))/eps,tol_eps);
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
