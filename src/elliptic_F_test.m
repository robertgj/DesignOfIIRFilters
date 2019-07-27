% elliptic_F_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("elliptic_F_test.diary");
unlink("elliptic_F_test.diary.tmp");
diary elliptic_F_test.diary.tmp

function y=elliptic1_integrand(t,_k)
  persistent k
  persistent init_done=false
  if nargin==2
    k=_k;
    init_done=true;
  endif
  if ~init_done
    error("Not initialised");
  endif
  y=1/sqrt((1-(t^2))*(1-((k*t)^2)));
endfunction

tol=100*eps;

for p=0:0.1:(pi/2),
  for k=0:0.1:0.9,
    elliptic1_integrand(0,k);
    x=elliptic_F(p,k);
    q=quad(@elliptic1_integrand, 0, sin(p));
    if abs(elliptic_F(p,k)-q)>tol
      error("abs(elliptic_F(p,k)-q)>tol,(p=%3.1f,k=%3.1f)",p,k);
    endif
  endfor
endfor

% Done
diary off
movefile elliptic_F_test.diary.tmp elliptic_F_test.diary;
