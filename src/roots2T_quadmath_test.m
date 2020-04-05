% roots2T_quadmath_test.m
%
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("roots2T_quadmath_test.diary");
delete("roots2T_quadmath_test.diary.tmp");
diary roots2T_quadmath_test.diary.tmp

try
  x=roots2T();
catch
  printf("No arguments exception caught!\n");
end_try_catch

x=roots2T_quadmath([]);
if ~isempty(x)
  error("~isempty(x)");
endif

x=roots2T_quadmath(zeros(1,0));
if ~isempty(x)
  error("~isempty(x)");
endif

x=roots2T_quadmath(1);
if norm(x-[-1 1])~=0
  error("norm(x-[-1 1])~=0");
endif

x=roots2T_quadmath([1 1]);
if norm(x-[3 -4 1])~=0
  error("norm(x-[3 -4 1])~=0");
endif

n=28;
for l=1:n
  bn=bincoeff(l,0:l);
  rn=-1*ones(1,l);
  at=roots2T_quadmath(rn);
  ae=chebyshevT_expand(bn);
  if norm(abs(diff(at./ae)))~=0
    error("norm(abs(diff(at./ae)))~=0");
  endif
endfor

n=16;
tol=1e6*eps;
rand("seed",0xdeadbeef);
for l=1:n
  rr=rand(1,l);
  at=roots2T_quadmath(rr);
  br=1;
  for m=1:l
    br=conv(br,[1 -rr(m)]);
  endfor
  ae=chebyshevT_expand(br);
  if norm(abs(diff(at./ae)))>tol
    error("norm(abs(diff(at./ae)))(%g)>%f*eps", ...
          norm(abs(diff(at./ae))),tol/eps);
  endif
endfor

% Done
diary off
movefile roots2T_quadmath_test.diary.tmp roots2T_quadmath_test.diary;
