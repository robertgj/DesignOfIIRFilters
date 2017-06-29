% complex_lower_hessenberg_inverse_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("complex_lower_hessenberg_inverse_test.diary");
unlink("complex_lower_hessenberg_inverse_test.diary.tmp");
diary complex_lower_hessenberg_inverse_test.diary.tmp

% First small matrix
N=1;
r=reprand(2*N*N);
A=hess(reshape(r(1:(N*N)),N,N)+j*reshape(r(((N*N)+1):(2*N*N)),N,N))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > eps
  error("err_AB > eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > eps
  error("err_BA > eps");
endif

% Second small matrix
N=2;
r=reprand(2*N*N);
A=hess(reshape(r(1:(N*N)),N,N)+j*reshape(r(((N*N)+1):(2*N*N)),N,N))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 1.063*eps
  error("err_AB > 1.063*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 3*eps
  error("err_BA > 3*eps");
endif

% Large matrix
N=400;
r=reprand(2*N*N);
A=hess(reshape(r(1:(N*N)),N,N)+j*reshape(r(((N*N)+1):(2*N*N)),N,N))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))))/eps;
if err_AB > 11.1
  error("err_AB > 11.1*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))))/eps;
if err_BA > 922.6
  error("err_BA > 922.6*eps");
endif

% Done
diary off
movefile complex_lower_hessenberg_inverse_test.diary.tmp complex_lower_hessenberg_inverse_test.diary;
