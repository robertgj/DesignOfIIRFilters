% chebychevU_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("chebychevU_test.diary");
unlink("chebychevU_test.diary.tmp");
diary chebychevU_test.diary.tmp

strf="chebychevU_test";

%
% Check Chebychev Type 2 polynomials
%
for n=1:12
  [Un,Unm1]=chebychevU(n);
  print_polynomial(Un,sprintf("U%d",n),"%6d");
  print_polynomial(Unm1,sprintf("U%d",n-1),"%6d");
endfor

%
% Check Chebychev Type 2 identities in the Appendix of "Equiripple
% Approximation of Half-Band FIR Filters", P. Zahradnik and M. Vlcek,
% IEEE Transactions on Circuits and Systems - II: Express Briefs,
% Vol. 56, No. 12, December 2009, pp. 941-945
%

n=40;
U=cell(1,n+1);
dU=cell(1,n+1);
d2U=cell(1,n+1);
for l=0:n,
  U{1+l}=chebychevU(l);
  dU{1+l}=polyder(chebychevU(l));
  d2U{1+l}=polyder(dU{1+l});
  U{1+l}=[zeros(1,n+1-length(U{1+l})),U{1+l}];
  dU{1+l}=[zeros(1,n+1-length(dU{1+l})),dU{1+l}];
  d2U{1+l}=[zeros(1,n+1-length(d2U{1+l})),d2U{1+l}];
endfor

%
% Check differential equation
%
for l=0:n,
  deqn=conv([-1,0,1],d2U{1+l})-conv([0,3,0],dU{1+l})+(l*(l+2)*[0,0,U{1+l}]);
  if any(deqn)
    error("Differential equation failed at l=%d",l);
  endif
endfor

% Equation 18
for l=2:n,
  if any((2*l*U{1+l-1})-dU{1+l}+dU{1+l-2})
    error("Equation 18 failed at l=%d",l);
  endif
endfor
% Equation 19
for l=1:floor(n/2),
  sU2m=zeros(1,n+1);
  for m=0:(l-1)
    sU2m=sU2m+((2*((2*m)+1))*U{1+(2*m)});
  endfor
  if any(dU{1+(2*l)-1}-sU2m)
    error("Equation 19 failed at l=%d",l);
  endif
endfor
% Equation 20
for l=1:floor(n/2),
  sU2m1=zeros(1,n+1);
  for m=1:l
    sU2m1=sU2m1+(4*m*U{1+(2*m)-1});
  endfor
  if any(dU{1+(2*l)}-sU2m1)
    error("Equation 20 failed at l=%d",l);
  endif
endfor
% Equation 21
for l=1:floor(n/2),
  sU2m1=U{1+1}; % U{1+(2*0)+1}, Ul=0 for l<=0
  for m=1:(l-1)
    sU2m1=sU2m1+(((2*m)+1)*(U{1+(2*m)+1}+U{1+(2*m)-1}));
  endfor
  if any(shift(dU{1+(2*l)-1},-1)-sU2m1)
    error("Equation 21 failed at l=%d",l);
  endif
endfor
% Equation 22
for l=1:floor(n/2),
  sU2m1=zeros(1,n+1);
  for m=1:l
    sU2m1=sU2m1+((2*m)*(U{1+(2*m)}+U{1+(2*m)-2}));
  endfor
  if any(shift(dU{1+(2*l)},-1)-sU2m1)
    error("Equation 22 failed at l=%d",l);
  endif
endfor
% Equation 23 (w^3 part)
for l=2:(floor(n/2)-2),
  if any((shift(d2U{1+(2*l)},-3)-shift(d2U{1+(2*l)},-5)- ...
          (3*shift(dU{1+(2*l)},-4)))+ ...
         (l*(l+1)*(U{1+(2*l)+3}+(3*U{1+(2*l)+1})+ ...
                   (3*U{1+(2*l)-1})+U{1+(2*l)-3})/2))
    error("Equation 23 (w^3 part) failed at l=%d",l);
  endif
endfor
% Equation 23 (-w*kp part)
for l=1:(floor(n/2)-1),
  if any((shift(d2U{1+(2*l)},-3)-shift(d2U{1+(2*l)},-1)+ ...
          (3*shift(dU{1+(2*l)},-2)))- ...
         (2*l*(l+1)*(U{1+(2*l)+1}+U{1+(2*l)-1})))
    error("Equation 23 (kp part) failed at l=%d",l);
  endif
endfor
% Equation 24 (kp part)
for l=1:(floor(n/2)-1),
  if any(dU{1+(2*l)}-shift(dU{1+(2*l)},-2)- ...
         (((l+1)*U{1+(2*l)-1})-(l*U{1+(2*l)+1})))
    error("Equation 24 (kp part) failed at l=%d",l);
  endif
endfor
% Equation 24 (v^2(1-v^2) part)
for l=2:(floor(n/2)-2),
  if any((4*shift(dU{1+(2*l)},-2))-(4*shift(dU{1+(2*l)},-4))- ...
         (((l+1)*(U{1+(2*l)+1}+(2*U{1+(2*l)-1})+U{1+(2*l)-3}))- ...
          (l*(U{1+(2*l)+3}+(2*U{1+(2*l)+1})+U{1+(2*l)-1}))))
    error("Equation 24 (v^2(1-v^2) part) failed at l=%d",l);
  endif
endfor
% Equation 25
for l=2:(floor(n/2)-2),
  if any((8*shift(U{1+(2*l)},-3))- ...
         (U{1+(2*l)+3}+(3*U{1+(2*l)+1})+(3*U{1+(2*l)-1})+U{1+(2*l)-3}))
    error("Equation 25 failed at l=%d",l);
  endif
endfor

% Identities for differentiation of U
for l=1:(n-1),
  if any(conv([-1,0,1],dU{1+l})- ...
         ([0,(l+2)*U{1+l},0]-[0,0,(l+1)*U{1+l+1}]))
    error("Equation differentiation failed at l=%d",l);
  endif
endfor
for l=1:(n-1),
  if any(conv([-1,0,1],dU{1+l})- ...
         ([0,U{1+l},0]-(((l+1)/2)*([0,0,U{1+l+1}]-[0,0,U{1+l-1}]))))
    error("Equation differentiation failed at l=%d",l);
  endif
endfor

% Identities for multiplication by powers of x
for l=1:(n-1),
  if any((2*shift(U{1+l},-1))-(U{1+l+1}+U{1+l-1}))
    error("Identity x*Ul failed at l=%d",l);
  endif
endfor
for l=2:(n-2),
  if any((4*shift(U{1+l},-2))-(U{1+l+2}+2*U{1+l}+U{1+l-2}))
    error("Identity (x^2)*Ul failed at l=%d",l);
  endif
endfor
for l=3:(n-3),
  if any((8*shift(U{1+l},-3))-(U{1+l+3}+3*U{1+l+1}+3*U{1+l-1}+U{1+l-3}))
    error("Identity (x^3)*Ul failed at l=%d",l);
  endif
endfor

% Done
diary off
movefile chebychevU_test.diary.tmp chebychevU_test.diary;
