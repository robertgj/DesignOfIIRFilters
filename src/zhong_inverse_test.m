% zhong_inverse_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("zhong_inverse_test.diary");
unlink("zhong_inverse_test.diary.tmp");
diary zhong_inverse_test.diary.tmp

format long e

% First small matrix
N=1;
r=reprand(2*N*N);
A=hess(reshape(r(1:(N*N)),N,N)+j*reshape(r(((N*N)+1):(2*N*N)),N,N))';
B=zhong_inverse(A);
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
B=zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 1.4143*eps
  error("err_AB > 1.4143*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 2.2361*eps
  error("err_BA > 2.2361*eps");
endif

% Large matrix
N=100;
r=reprand(2*N*N);
A=hess(reshape(r(1:(N*N)),N,N)+j*reshape(r(((N*N)+1):(2*N*N)),N,N))';
B=zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 60*eps
  error("err_AB > 60*eps")
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 700*eps
  error("err_BA > 700*eps")
endif

% Done
diary off
movefile zhong_inverse_test.diary.tmp zhong_inverse_test.diary;
