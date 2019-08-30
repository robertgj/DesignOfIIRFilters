% chebychevP_test.m
% Check identities linking Chebychev Type 1 and Type 2 polynomials
% See : https://en.wikipedia.org/wiki/Chebyshev_polynomials#Relations_between_Chebyshev_polynomials_of_the_first_and_second_kinds
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("chebychevP_test.diary");
unlink("chebychevP_test.diary.tmp");
diary chebychevP_test.diary.tmp

strf="chebychevP_test";

n=40;

T=cell(1,n+1);
for l=1:n,
  T{1+l}=[chebychevT(l),0]-[0,0,chebychevU(l-1)]+[chebychevU(l-1),0,0];
  if any(T{1+l}-chebychevT(1+l))
    error("T{1+l} identity failed");
  endif
endfor

U=cell(1,n+1);
for l=2:(n+1),
  U{l}=[chebychevU(l-1),0]+chebychevT(l);
  if any(U{l}-chebychevU(l))
    error("U{l} identity failed");
  endif
endfor

T=cell(1,n);
for l=2:n,
  T{l}=(chebychevU(l)-[0,0,chebychevU(l-2)])/2;
  if any(T{l}-chebychevT(l))
    error("T{l} identity failed");
  endif
endfor

T=cell(1,n);
for l=2:n,
  T{l}=chebychevU(l)-[chebychevU(l-1),0];
  if any(T{l}-chebychevT(l))
    error("T{l} identity failed");
  endif
endfor

U=cell(1,n);
for l=1:2:n,
  U{l}=zeros(1,l+1);
  for m=1:2:l
    U{l}=U{l}+(2*[zeros(1,length(U{l})-m-1),chebychevT(m)]);
  endfor
  if any(U{l}-chebychevU(l))
    error("U{l} identity failed");
  endif
endfor

U=cell(1,n);
for l=2:2:n,
  U{l}=zeros(1,l+1);
  for m=0:2:l
    U{l}=U{l}+(2*[zeros(1,length(U{l})-m-1),chebychevT(m)]);
  endfor
  U{l}(end)=U{l}(end)-1;
  if any(U{l}-chebychevU(l))
    error("U{l} identity failed");
  endif
endfor

% Done
diary off
movefile chebychevP_test.diary.tmp chebychevP_test.diary;
