% complex_zhong_inverse_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("complex_zhong_inverse_test.diary");
delete("complex_zhong_inverse_test.diary.tmp");
diary complex_zhong_inverse_test.diary.tmp

check_octave_file("complex_zhong_inverse");

% First small matrix
N=1;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=complex_zhong_inverse(A);
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
B=complex_zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 3*eps
  error("err_AB > 3*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 2*eps
  error("err_BA > 2*eps");
endif

% Third small matrix
N=3;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=complex_zhong_inverse(A);
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
B=complex_zhong_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 40*eps
  error("err_AB > 40*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 600*eps
  error("err_BA > 600*eps");
endif

% Done
diary off
movefile complex_zhong_inverse_test.diary.tmp complex_zhong_inverse_test.diary;
