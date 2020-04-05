% chebyshevU_backward_recurrence_test.m
%
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("chebyshevU_backward_recurrence_test.diary");
delete("chebyshevU_backward_recurrence_test.diary.tmp");
diary chebyshevU_backward_recurrence_test.diary.tmp

x=chebyshevU_backward_recurrence(zeros(1,0));
if ~isempty(x)
  error("~isempty(x)");
endif

x=chebyshevU_backward_recurrence(2);
if x~=2
  error("x~=2");
endif

x=chebyshevU_backward_recurrence([1 0]);
if norm(x-[0 1])~=0
  error("norm(x-[0 1])~=0");
endif

x=chebyshevU_backward_recurrence([0 1]);
if norm(x-[2 0])~=0
  error("norm(x-[2 0])~=0");
endif

x=chebyshevU_backward_recurrence([1 2]);
if norm(x-[4 1])~=0
  error("norm(x-[4 1])~=0");
endif

x=chebyshevU_backward_recurrence([1 2 3]);
if norm(x-[12 4 -2])~=0
  error("norm(x-[12 4 -2])~=0");
endif

for n=1:28,
  bn=bincoeff(n,0:n);
  at=chebyshevU_expand(bn);
  if norm(bn-chebyshevU_backward_recurrence(at))~=0
    error("norm(bn-chebyshevU_backward_recurrence(at))~=0");
  endif
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  at=chebyshevU_expand(br);
  if norm(br-chebyshevU_backward_recurrence(at))>5e5*eps
    error("norm(br-chebyshevU_backward_recurrence(at))>5e5*eps");
  endif
endfor
  
% Done
diary off
movefile chebyshevU_backward_recurrence_test.diary.tmp ...
         chebyshevU_backward_recurrence_test.diary;
