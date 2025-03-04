% chebyshevT_backward_recurrence_test.m
%
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("chebyshevT_backward_recurrence_test.diary");
delete("chebyshevT_backward_recurrence_test.diary.tmp");
diary chebyshevT_backward_recurrence_test.diary.tmp

x=chebyshevT_backward_recurrence(zeros(1,0));
if ~isempty(x)
  error("~isempty(x)");
endif

x=chebyshevT_backward_recurrence(2);
if x~=2
  error("x~=2");
endif

x=chebyshevT_backward_recurrence([1 0]);
if norm(x-[0 1])~=0
  error("norm(x-[0 1])~=0");
endif

x=chebyshevT_backward_recurrence([0 1]);
if norm(x-[1 0])~=0
  error("norm(x-[1 0])~=0");
endif

x=chebyshevT_backward_recurrence([1 2]);
if norm(x-[2 1])~=0
  error("norm(x-[2 1])~=0");
endif

x=chebyshevT_backward_recurrence([1 2 3]);
if norm(x-[6 2 -2])~=0
  error("norm(x-[6 2 -2])~=0");
endif

for n=1:28,
  bn=bincoeff(n,0:n);
  at=chebyshevT_expand(bn);
  if norm(bn-chebyshevT_backward_recurrence(at))~=0
    error("norm(bn-chebyshevT_backward_recurrence(at))~=0");
  endif
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  at=chebyshevT_expand(br);
  if norm(br-chebyshevT_backward_recurrence(at))>2e6*eps
    error("norm(br-chebyshevT_backward_recurrence(at))>2e6*eps");
  endif
endfor
  
% Done
diary off
movefile chebyshevT_backward_recurrence_test.diary.tmp ...
         chebyshevT_backward_recurrence_test.diary;
