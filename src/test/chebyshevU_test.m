% chebyshevU_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("chebyshevU_test.diary");
delete("chebyshevU_test.diary.tmp");
diary chebyshevU_test.diary.tmp

strf="chebyshevU_test";

%
% Check Chebyshev Type 2 polynomials
%
for n=1:12
  [Un,Unm1]=chebyshevU(n);
  print_polynomial(Un,sprintf("U%d",n),"%6d");
  print_polynomial(Unm1,sprintf("U%d",n-1),"%6d");
endfor

%
% Check Chebyshev Type 2 identities in the Appendix of "Equiripple
% Approximation of Half-Band FIR Filters", P. Zahradnik and M. Vlcek,
% IEEE Transactions on Circuits and Systems - II: Express Briefs,
% Vol. 56, No. 12, December 2009, pp. 941-945
%

n=40;
U=cell(1,n+1);
dU=cell(1,n+1);
d2U=cell(1,n+1);
for l=0:n,
  U{1+l}=chebyshevU(l);
  dU{1+l}=polyder(chebyshevU(l));
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
  if any(circshift(dU{1+(2*l)-1},-1)-sU2m1)
    error("Equation 21 failed at l=%d",l);
  endif
endfor
% Equation 22
for l=1:floor(n/2),
  sU2m1=zeros(1,n+1);
  for m=1:l
    sU2m1=sU2m1+((2*m)*(U{1+(2*m)}+U{1+(2*m)-2}));
  endfor
  if any(circshift(dU{1+(2*l)},-1)-sU2m1)
    error("Equation 22 failed at l=%d",l);
  endif
endfor
% Equation 23 (w^3 part)
for l=2:(floor(n/2)-2),
  if any((circshift(d2U{1+(2*l)},-3)-circshift(d2U{1+(2*l)},-5)- ...
          (3*circshift(dU{1+(2*l)},-4)))+ ...
         (l*(l+1)*(U{1+(2*l)+3}+(3*U{1+(2*l)+1})+ ...
                   (3*U{1+(2*l)-1})+U{1+(2*l)-3})/2))
    error("Equation 23 (w^3 part) failed at l=%d",l);
  endif
endfor
% Equation 23 (-w*kp part)
for l=1:(floor(n/2)-1),
  if any((circshift(d2U{1+(2*l)},-3)-circshift(d2U{1+(2*l)},-1)+ ...
          (3*circshift(dU{1+(2*l)},-2)))- ...
         (2*l*(l+1)*(U{1+(2*l)+1}+U{1+(2*l)-1})))
    error("Equation 23 (kp part) failed at l=%d",l);
  endif
endfor
% Equation 24 (kp part)
for l=1:(floor(n/2)-1),
  if any(dU{1+(2*l)}-circshift(dU{1+(2*l)},-2)- ...
         (((l+1)*U{1+(2*l)-1})-(l*U{1+(2*l)+1})))
    error("Equation 24 (kp part) failed at l=%d",l);
  endif
endfor
% Equation 24 (v^2(1-v^2) part)
for l=2:(floor(n/2)-2),
  if any((4*circshift(dU{1+(2*l)},-2))-(4*circshift(dU{1+(2*l)},-4))- ...
         (((l+1)*(U{1+(2*l)+1}+(2*U{1+(2*l)-1})+U{1+(2*l)-3}))- ...
          (l*(U{1+(2*l)+3}+(2*U{1+(2*l)+1})+U{1+(2*l)-1}))))
    error("Equation 24 (v^2(1-v^2) part) failed at l=%d",l);
  endif
endfor
% Equation 25
for l=2:(floor(n/2)-2),
  if any((8*circshift(U{1+(2*l)},-3))- ...
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
  if any((2*circshift(U{1+l},-1))-(U{1+l+1}+U{1+l-1}))
    error("Identity x*Ul failed at l=%d",l);
  endif
endfor
for l=2:(n-2),
  if any((4*circshift(U{1+l},-2))-(U{1+l+2}+2*U{1+l}+U{1+l-2}))
    error("Identity (x^2)*Ul failed at l=%d",l);
  endif
endfor
for l=3:(n-3),
  if any((8*circshift(U{1+l},-3))-(U{1+l+3}+3*U{1+l+1}+3*U{1+l-1}+U{1+l-3}))
    error("Identity (x^3)*Ul failed at l=%d",l);
  endif
endfor

% Dirichlet kernel
N=6;
U2N=chebyshevU(2*N);
x=-1.1:0.01:1.1;
DN=-1+2*sum(cos(kron((0:N)',ones(1,length(x))).*kron(ones(N+1,1),x)));
if max(abs(DN-polyval(U2N,cos(x/2))))>6e3*eps
  error("max(abs(DN-polyval(U2N,cos(x/2))))>6e3*eps");
endif

% Plot
N=6;
x=-1.1:0.01:1.1;
yU=zeros(length(x),N+1);
U=cell(N+1);
for k=0:N,
  U{k+1}=chebyshevU(k);
  yU(:,k+1)=polyval(U{k+1},x);
endfor
plot(x,yU);
axis([-1 1.3 -2.2 2.2]);
grid("on");
title("Chebyshev polynomials of the second kind, \$U\_\{k\}\$");
legend("0","1","2","3","4","5","6");
legend("box","off","location","southeast");
zticks([]);
print(strcat(strf,"_Uk"),"-dpdflatex");

% Done
diary off
movefile chebyshevU_test.diary.tmp chebyshevU_test.diary;
