% chebyshevU_expand_test.m
%
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("chebyshevU_expand_test.diary");
delete("chebyshevU_expand_test.diary.tmp");
diary chebyshevU_expand_test.diary.tmp

try
  au=chebyshevU_expand();
catch
  printf("No arguments exception caught\n");
end_try_catch

au=chebyshevU_expand([]);
if ~isempty(au)
  error("~isempty(au)");
endif

au=chebyshevU_expand(2);
if norm(au-2)~=0
  error("norm(au-2)~=0");
endif

au=chebyshevU_expand(chebyshevU(2));
if norm(au-[0 0 1])~=0
  error("norm(au-[0 0 1])~=0");
endif

au=chebyshevU_expand(chebyshevU(3));
if norm(au-[0 0 0 1])~=0
  error("norm(au-[0 0 0 1])~=0");
endif

for n=1:28,
  bn=bincoeff(n,0:n);
  au=chebyshevU_expand(bn);
  print_polynomial(au,sprintf("au%02d",n),"%15.8g");
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  au=chebyshevU_expand(br);
  print_polynomial(au,sprintf("au%02d",n),"%15.8g");
endfor
  
% Done
diary off
movefile chebyshevU_expand_test.diary.tmp ...
         chebyshevU_expand_test.diary;
