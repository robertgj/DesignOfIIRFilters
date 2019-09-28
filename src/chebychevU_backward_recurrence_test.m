% chebychevU_backward_recurrence_test.m
%
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("chebychevU_backward_recurrence_test.diary");
unlink("chebychevU_backward_recurrence_test.diary.tmp");
diary chebychevU_backward_recurrence_test.diary.tmp

x=chebychevU_backward_recurrence(zeros(1,0));
if ~isempty(x)
  error("~isempty(x)");
endif

x=chebychevU_backward_recurrence(2);
if x~=2
  error("x~=2");
endif

x=chebychevU_backward_recurrence([1 0]);
if norm(x-[0 1])~=0
  error("norm(x-[0 1])~=0");
endif

x=chebychevU_backward_recurrence([0 1]);
if norm(x-[2 0])~=0
  error("norm(x-[2 0])~=0");
endif

x=chebychevU_backward_recurrence([1 2]);
if norm(x-[4 1])~=0
  error("norm(x-[4 1])~=0");
endif

x=chebychevU_backward_recurrence([1 2 3]);
if norm(x-[12 4 -2])~=0
  error("norm(x-[12 4 -2])~=0");
endif

for n=1:28,
  bn=bincoeff(n,0:n);
  at=chebychevU_expand(bn);
  if norm(bn-chebychevU_backward_recurrence(at))~=0
    error("norm(bn-chebychevU_backward_recurrence(at))~=0");
  endif
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  at=chebychevU_expand(br);
  if norm(br-chebychevU_backward_recurrence(at))>5e5*eps
    error("norm(br-chebychevU_backward_recurrence(at))>5e5*eps");
  endif
endfor
  
% Done
diary off
movefile chebychevU_backward_recurrence_test.diary.tmp ...
         chebychevU_backward_recurrence_test.diary;
