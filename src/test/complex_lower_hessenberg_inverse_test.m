% complex_lower_hessenberg_inverse_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("complex_lower_hessenberg_inverse_test.diary");
delete("complex_lower_hessenberg_inverse_test.diary.tmp");
diary complex_lower_hessenberg_inverse_test.diary.tmp

check_octave_file("complex_lower_hessenberg_inverse");

% First small matrix
N=1;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 10*eps
  error("err_AB > 10*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 10*eps
  error("err_BA > 10*eps");
endif

% Second small matrix
N=2;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 4*eps
  error("err_AB > 4*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 4*eps
  error("err_BA > 4*eps");
endif

% Third small matrix
N=3;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))))/eps;
if err_AB > 5
  error("err_AB > 5*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))))/eps;
if err_BA > 5
  error("err_BA > 5*eps");
endif

% Large matrix
N=400;
r=reprand(2*N,N);
A=hess(r(1:N,:)+j*r((N+1):(2*N),:))';
B=complex_lower_hessenberg_inverse(A);
err_AB=max(max(abs((A*B)-eye(N))));
if err_AB > 20*eps
  error("err_AB > 20*eps");
endif
err_BA=max(max(abs((B*A)-eye(N))));
if err_BA > 2e3*eps
  error("err_BA > 2e3*eps");
endif

% Done
diary off
movefile complex_lower_hessenberg_inverse_test.diary.tmp ...
         complex_lower_hessenberg_inverse_test.diary;
