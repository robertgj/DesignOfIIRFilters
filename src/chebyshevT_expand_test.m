% chebyshevT_expand_test.m
%
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("chebyshevT_expand_test.diary");
delete("chebyshevT_expand_test.diary.tmp");
diary chebyshevT_expand_test.diary.tmp

try
  at=chebyshevT_expand();
catch
  printf("No arguments exception caught\n");
end_try_catch

at=chebyshevT_expand([]);
if ~isempty(at)
  error("~isempty(at)");
endif

at=chebyshevT_expand(2);
if norm(at-2)~=0
  error("norm(at-2)~=0");
endif

at=chebyshevT_expand(chebyshevT(2));
if norm(at-[0 0 1])~=0
  error("norm(at-[0 0 1])~=0");
endif

at=chebyshevT_expand(chebyshevT(3));
if norm(at-[0 0 0 1])~=0
  error("norm(at-[0 0 0 1])~=0");
endif

for n=1:28,
  bn=bincoeff(n,0:n);
  at=chebyshevT_expand(bn);
  print_polynomial(at,sprintf("at%02d",n),"%15.8g");
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  at=chebyshevT_expand(br);
  print_polynomial(at,sprintf("at%02d",n),"%15.8g");
endfor
  
% Done
diary off
movefile chebyshevT_expand_test.diary.tmp ...
         chebyshevT_expand_test.diary;
