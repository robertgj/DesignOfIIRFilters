% elliptic_E_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("elliptic_E_test.diary");
delete("elliptic_E_test.diary.tmp");
diary elliptic_E_test.diary.tmp

function y=elliptic2_integrand(t,_k)
  persistent k
  persistent init_done=false
  if nargin==2
    k=_k;
    init_done=true;
  endif
  if ~init_done
    error("Not initialised");
  endif
  y=sqrt((1-((k*t)^2))/(1-(t^2)));
endfunction

tol=100*eps;

for p=0:0.1:(pi/2),
  for k=0:0.1:0.9,
    elliptic2_integrand(0,k);
    x=elliptic_E(p,k);
    q=quad(@elliptic2_integrand, 0, sin(p));
    if abs(elliptic_E(p,k)-q)>tol
      error("abs(elliptic_E(p,k)-q)>tol,(p=%3.1f,k=%3.1f)",p,k);
    endif
  endfor
endfor

% Done
diary off
movefile elliptic_E_test.diary.tmp elliptic_E_test.diary;
