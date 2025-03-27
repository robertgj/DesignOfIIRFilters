% schurOneMlatticePipelined2tf_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="schurOneMAPlatticePipelined2tf_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fc=0.1;dBap=1;dBas=40;

verbose=false;

for N=1:8,

  %
  % Calculate Schur one-multiplier lattice coefficients
  %
  tol_eps=3*(N^2);
  tol_H=(N^6)*10;
  [n,d]=ellip(N,dBap,dBas,2*fc);
  [k,epsilon,c,kk,ck,S]=tf2schurOneMlatticePipelined(n,d);
  % Check Asq
  [H,w]=freqz(n,d,1024);
  Asq=schurOneMlatticePipelinedAsq(w,k,epsilon,c,kk,ck);
  if verbose
    printf("N=%d,max(abs((abs(H).^2))-Asq)*eps=(N^6)*%g*eps\n", ...
           N,max(abs((abs(H).^2))-Asq)/((N^6)*eps));
  endif
  if max(abs((abs(H).^2))-Asq) > tol_H*eps
    error("max(abs((abs(H).^2))-Asq)(%g*eps) > %g*eps", ...
          max(abs((abs(H).^2))-Asq)/eps,tol_H);
  endif
  % Check transfer function
  [nn,dd]=schurOneMlatticePipelined2tf(k,epsilon,c,kk,ck);
  if max(abs(n-nn)) > tol_eps*eps
    error("N=%d,max(abs(n-nn)) (%g*eps) > %g*eps",N,max(abs(n-nn))/eps,tol_eps);
  endif
  if max(abs(d-dd)) > tol_eps*eps
    error("N=%d,max(abs(d-dd)) (%g*eps) > %g*eps",N,max(abs(d-dd))/eps,tol_eps);
  endif

  % Check Schur one-multiplier lattice coefficients with epsilon=ones(size(k))
  tol_eps=tol_eps^2;
  epsilon_ones=ones(size(k));
  [k1,epsilon,c1,kk1,ck1,S,S1M]=tf2schurOneMlatticePipelined(nn,dd,epsilon_ones);
  [n1,d1]=schurOneMlatticePipelined2tf(k1,epsilon,c1,kk1,ck1);
  % Check Asq
  [H1,w]=freqz(n1,d1,1024);
  Asq1=schurOneMlatticePipelinedAsq(w,k1,epsilon,c1,kk1,ck1);
  if verbose
    printf("N=%d,max(abs((abs(H1).^2))-Asq1)*eps=(N^6)*%g*eps\n", ...
           N,max(abs((abs(H1).^2))-Asq1)/((N^6)*eps));
  endif
  if max(abs((abs(H1).^2))-Asq1) > 2*tol_H*eps
    error("max(abs((abs(H1).^2))-Asq1)(%g*eps) > %g*eps", ...
          max(abs((abs(H1).^2))-Asq1)/eps,2*tol_H);
  endif
  % Check transfer function
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
