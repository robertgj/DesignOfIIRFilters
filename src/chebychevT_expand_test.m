% chebychevT_expand_test.m
%
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("chebychevT_expand_test.diary");
unlink("chebychevT_expand_test.diary.tmp");
diary chebychevT_expand_test.diary.tmp

try
  at=chebychevT_expand();
catch
  printf("No arguments exception caught\n");
end_try_catch

at=chebychevT_expand([]);
if ~isempty(at)
  error("~isempty(at)");
endif

at=chebychevT_expand(2);
if norm(at-2)~=0
  error("norm(at-2)~=0");
endif

at=chebychevT_expand(chebychevT(2));
if norm(at-[0 0 1])~=0
  error("norm(at-[0 0 1])~=0");
endif

at=chebychevT_expand(chebychevT(3));
if norm(at-[0 0 0 1])~=0
  error("norm(at-[0 0 0 1])~=0");
endif

for n=1:28,
  bn=bincoeff(n,0:n);
  at=chebychevT_expand(bn);
  print_polynomial(at,sprintf("at%02d",n),"%15.8g");
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  at=chebychevT_expand(br);
  print_polynomial(at,sprintf("at%02d",n),"%15.8g");
endfor
  
% Done
diary off
movefile chebychevT_expand_test.diary.tmp ...
         chebychevT_expand_test.diary;
