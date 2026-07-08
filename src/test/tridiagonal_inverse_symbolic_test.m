% tridiagonal_inverse_symbolic_test.m
%
% Find the LU decomposition of a tridiagonal system, A=L*U:
%  _                    _     _               _   _                    _ 
%  |d(1) e(1)            |   |1                |  |u(1) e(1)            |
%  |c(2) d(2)  .         |   |l(2) 1           |  |     u(2)  .         |
%  |       .   .         | = |     l(3) 1      |  |       .   .         |
%  |       .   .  e(n-1) |   |         .  .    |  |           .  e(n-1) |
%  |_        c(n) d(n)  _|   |_         l(n) 1_|  |_             u(n)  _|
%
% Then invert L and U to find A^{-1}=U^{-1}*L^{-1}. See:
% [1] Section 4.3,"Matrix Calculations",3rd Edn,Golub and Van Loan
% [2] Section 9.6,"Accuracy and Stability of Numerical Algorithms",2002,Higham
%
% Copyright (C) 2026 Robert G. Jenssen

test_common;

pkg load symbolic

strf="tridiagonal_inverse_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

for n=2:5,

  clear e d c l u
  
  e=sym("e",[1,n-1]);
  d=sym("d",[1,n]);
  c=sym("c",[1,n]);
  l=sym("l",[1,n]);
  u=sym("u",[1,n]);

  u(1)=d(1);
  for m=2:n,
    l(m)=c(m)/u(m-1);
    u(m)=d(m)-(l(m)*e(m-1));
  endfor
  display(l(2:end));
  display(u);

  % If I try to solve invL=L\eye(n) now I get:
  %{
    Error: Python exception: PolynomialError: 1/(-c2*e1/d1 + d2) contains an
                             element of the set of generators.
  %}

  % Find inverses of L and U
  clear l u
  l=sym("l",[1,n]);
  u=sym("u",[1,n]);
  L=eye(n)+diag(l(2:n),-1)
  invL=L\eye(n)
  U=diag(u)+diag(e,1)
  invU=U\eye(n)
  
  if any(any((invL*L)-eye(n)))
    error("any(any((invL*L)-eye(n)))");
  endif
  if any(any((L*invL)-eye(n)))
    error("any(any((L*invL)-eye(n)))");
  endif

  if any(any((invU*U)-eye(n)))
    error("any(any((invU*U)-eye(n)))");
  endif
  if any(any((U*invU)-eye(n)))
    error("any(any((U*invU)-eye(n)))");
  endif

endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
