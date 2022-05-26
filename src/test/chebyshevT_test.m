% chebyshevT_test.m
% Copyright (C) 2019-2021 Robert G. Jenssen

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
  if any((2*circshift(T{1+l},-1))-(T{1+l-1}+T{1+l+1}))
    error("l=1 identity failed");
  endif
endfor
for l=2:(n-2),
  if any((4*circshift(T{1+l},-2))-(T{1+l-2}+(2*T{1+l})+T{1+l+2}))
    error("l=2 identity failed");
  endif
endfor
for l=3:(n-3),
  if any((8*circshift(T{1+l},-3))-(T{1+l-3}+(3*T{1+l-1})+(3*T{1+l+1})+T{1+l+3}))
    error("l=3 identity failed");
  endif
endfor

% Check orthonormality at the Chebyshev nodes
tol=10.^[1,1,1,2,3,3,3,4,4,4,5];
for n=1:11,
  T=cell(1,n+1);
  for l=0:n,
    T{1+l}=chebyshevT(l);
  endfor
  xk=cos(pi*((0:n)+0.5)/(n+1));
  Tkxk=zeros(n+1,n+1);
  for l=0:n,
    Tkxk(l+1,:)=polyval(T{l+1},xk);
  endfor
  sumTlTm=zeros(n+1,n+1);
  for l=0:n,
    for m=0:n,
      sumTlTm(l+1,m+1)=sum(Tkxk(l+1,:).*Tkxk(m+1,:));
    endfor
  endfor
  sum_err=sum(sum(abs(sumTlTm-diag([n+1;ones(n,1)*(n+1)/2]))));
  if sum_err > tol(n)*eps
    error("sum_err(%g) > %g*eps",sum_err,tol(n));
  endif
endfor

% Plot
N=6;
x=-1.1:0.01:1.1;
yT=zeros(length(x),N+1);
T=cell(N+1);
for k=0:N,
  T{k+1}=chebyshevT(k);
  yT(:,k+1)=polyval(T{k+1},x);
endfor
plot(x,yT);
axis([-1 1.3 -1.1 1.1]);
grid("on");
title("Chebyshev polynomials of the first kind, \$T\_\{k\}\$");
legend("0","1","2","3","4","5","6");
legend("box","off","location","southeast");
print(strcat(strf,"_Tk"),"-dpdflatex");

% Done
diary off
movefile chebyshevT_test.diary.tmp chebyshevT_test.diary;
