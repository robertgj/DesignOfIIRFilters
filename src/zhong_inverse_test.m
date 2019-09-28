% zhong_inverse_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("zhong_inverse_test.diary");
unlink("zhong_inverse_test.diary.tmp");
diary zhong_inverse_test.diary.tmp

% First small matrix
N=1;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
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
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > eps
  error("err_AB > eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 2*eps
  error("err_BA > 2*eps");
endif

% Third small matrix
N=3;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 5*eps
  error("err_AB > 5*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 5*eps
  error("err_BA > 5*eps");
endif

% Large matrix
N=100;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 40*eps
  error("err_AB > 40*eps")
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 300*eps
  error("err_BA > 300*eps")
endif

% Done
diary off
movefile zhong_inverse_test.diary.tmp zhong_inverse_test.diary;
