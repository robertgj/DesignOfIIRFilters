% chebyshevT_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("chebyshevT_test.diary");
delete("chebyshevT_test.diary.tmp");
diary chebyshevT_test.diary.tmp

strf="chebyshevT_test";

%
% Check Chebyshev Type 1 polynomials
%
for n=1:12
  [Tn,Tnm1]=chebyshevT(n);
  print_polynomial(Tn,sprintf("T%d",n),"%6d");
  print_polynomial(Tnm1,sprintf("T%d",n-1),"%6d");
endfor

%
% Check Chebyshev Type 1 identities in Section VI of "Zolotarev
% Polynomials and Optimal FIR Filters", IEEE Transactions on
% Signal Processing, Vol. 47, No. 3, March 1999, pp. 717-730
%

n=40;
T=cell(1,n+1);
for l=0:n,
  T{1+l}=chebyshevT(l);
  T{1+l}=[zeros(1,n+3-length(T{1+l})),T{1+l}];
endfor

for l=1:(n-1),
  if any((2*shift(T{1+l},-1))-(T{1+l-1}+T{1+l+1}))
    error("l=1 identity failed");
  endif
endfor
for l=2:(n-2),
  if any((4*shift(T{1+l},-2))-(T{1+l-2}+(2*T{1+l})+T{1+l+2}))
    error("l=2 identity failed");
  endif
endfor
for l=3:(n-3),
  if any((8*shift(T{1+l},-3))-(T{1+l-3}+(3*T{1+l-1})+(3*T{1+l+1})+T{1+l+3}))
    error("l=3 identity failed");
  endif
endfor

% Done
diary off
movefile chebyshevT_test.diary.tmp chebyshevT_test.diary;
