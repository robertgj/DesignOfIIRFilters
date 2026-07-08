% complex_tridiagonal_inverse_test.m
%
% Copyright (C) 2026 Robert G. Jenssen

%{
Compile complex_tridiagonal_inverse.oct with:
mkoctfile -DTEST_COMPLEX_TRIDIAGONAL_INVERSE -Wall -O0 -ggdb3 \
  -o src/complex_tridiagonal_inverse.oct \
  src/schurOneMAPlatticeDoublyPipelined2H.cc
%}

test_common;

strf="complex_tridiagonal_inverse_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Sanity checks
c=1:3;d=1:4;e=1:3;
try
  complex_tridiagonal_inverse(c,d,e);
catch
  printf("Caught no output arguments!\n")
end_try_catch
try
  A=complex_tridiagonal_inverse(c,d);
catch
  printf("Caught insufficient input arguments!\n")
end_try_catch
try
  A=complex_tridiagonal_inverse(c,d,e,5);
catch
  printf("Caught too many input arguments!\n")
end_try_catch
try
  [A,B]=complex_tridiagonal_inverse(c,d,e);
catch
  printf("Incorrect number of output arguments!\n")
end_try_catch
try
  [A,B,C,D]=complex_tridiagonal_inverse(c,d,e);
catch
  printf("Incorrect number of output arguments!\n")
end_try_catch
try
  [A,B,C,D,E,F]=complex_tridiagonal_inverse(c,d,e);
catch
  printf("Incorrect number of output arguments!\n")
end_try_catch
try
  A=complex_tridiagonal_inverse(c,e,d);
catch
  printf("Incorrect length input arguments!\n")
end_try_catch

%
% Run for an nxn array 
%
tol=1e-10;
for n=2:50,

  % Initialise nxn array
  reprand();
  e=(reprand(1,n)+i*reprand(1,n))-0.5;
  d=(reprand(1,n)+i*reprand(1,n))-0.5;
  c=(reprand(1,n)+i*reprand(1,n))-0.5;
  A=zeros(n);
  A(1,[1:2])=[d(1),e(1)];
  for m=2:(n-1)
    A(m,[(m-1):(m+1)])=[c(m),d(m),e(m)];
  endfor
  A(n,[(n-1):n])=[c(n),d(n)];

  % Call complex_tridiagonal_inverse
  invA = complex_tridiagonal_inverse(c(2:n),d,e(1:(n-1)));

  % Sanity check on invA
  max_diff = max(max(abs((A*invA)-eye(n))));
  if max_diff > tol
    error("m=%d,max(max(abs((A*invA)-eye(n))))(%g*tol) > tol", ...
          m,max_diff/tol);
  endif
  max_diff = max(max(abs((invA*A)-eye(n))));
  if max_diff > tol
    error("m=%d,max(max(abs((invA*A)-eye(n))))(%g*tol) > tol", ...
          m,max_diff/tol);
  endif

endfor

%
% Try a Butterworth filter response
%
tol=100*eps;
norder=9;
ftest=0.1;
wtest=2*pi*ftest;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
[Aap1,Aap2]=tf2pa(n,d);
ftest=0.1;
wtest=2*pi*ftest;

% Lattice decomposition
[A1k,~,~,~] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,~,~,~] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Doubly pipelined state variable form where the Schur one-multiplier
% lattice has z^-1 replaced by z^-2 with an extra z^-2 delay. In other
% words, the response of the doubly pipelined filter is scaled by two
% in frequency.
[A1A,A1B,A1Cap,A1Dap,~,~]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[A2A,A2B,A2Cap,A2Dap,~,~]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);

% Calculate zI-A
NA1x=rows(A1A);
NA2x=rows(A2A);
zIminusA1A=(exp(j*wtest/2)*eye(NA1x))-A1A;
zIminusA2A=(exp(j*wtest/2)*eye(NA2x))-A2A;

% Calculate R with complex_tridiagonal_inverse()
PA1=zeros(NA1x,NA1x);
for l=1:2:NA1x, PA1(l+1,l)=1; PA1(l,l+1)=1; endfor
zPminusA1APA1=((exp(j*wtest/2)*eye(NA1x))-A1A)*PA1;
zeA1=diag(zPminusA1APA1, 1);
 dA1=diag(zPminusA1APA1, 0);
zcA1=diag(zPminusA1APA1,-1);
RA1=complex_tridiagonal_inverse(zcA1,dA1,zeA1);
RA1=PA1*RA1;
HRA1=A1Cap*RA1*A1B+A1Dap;

PA2=zeros(NA2x,NA2x);
for l=1:2:NA2x, PA2(l+1,l)=1; PA2(l,l+1)=1; endfor
zPminusA2APA2=((exp(j*wtest/2)*eye(NA2x))-A2A)*PA2;
zeA2=diag(zPminusA2APA2, 1);
 dA2=diag(zPminusA2APA2, 0);
zcA2=diag(zPminusA2APA2,-1);
RA2=complex_tridiagonal_inverse(zcA2,dA2,zeA2);
RA2=PA2*RA2;
HRA2=A2Cap*RA2*A2B+A2Dap;

% Compare R with inv()
max_diff=max(max(abs(inv(zIminusA1A)-RA1)));
if max_diff > tol
  error("max(max(abs(inv(zIminusA1A)-RA1)))(%g*eps) > tol", max_diff/eps);
endif
max_diff=max(max(abs(inv(zIminusA2A)-RA2)));
if max_diff > tol
  error("max(max(abs(inv(zIminusA2A)-RA2)))(%g*eps) > tol", max_diff/eps);
endif

% Compare zIminusA*R with I
max_diff=max(max(abs((zIminusA1A*RA1)-eye(NA1x))));
if max_diff > tol
  error("max(max(abs((zIminusA1A*RA1)-eye(NA1x))))(%g*eps) > tol",max_diff/eps);
endif
max_diff=max(max(abs((zIminusA2A*RA2)-eye(NA2x))));
if max_diff > tol
  error("max(max(abs((zIminusA2A*RA2)-eye(NA2x))))(%g*eps) > tol",max_diff/eps);
endif

% Compare R*zIminusA with I
max_diff=max(max(abs((RA1*zIminusA1A)-eye(NA1x))));
if max_diff > tol
  error("max(max(abs((RA1*zIminusA1A)-eye(NA1x))))(%g*eps) > tol",max_diff/eps);
endif
max_diff=max(max(abs((RA2*zIminusA2A)-eye(NA2x))));
if max_diff > tol
  error("max(max(abs((RA2*zIminusA2A)-eye(NA2x))))(%g*eps) > tol",max_diff/eps);
endif

% Compare filter responses at ftest
if exist("schurOneMAPlatticeDoublyPipelined2H") ~= 3
  error("schurOneMAPlatticeDoublyPipelined2H() is not an oct-file!");
endif

HA1=schurOneMAPlatticeDoublyPipelined2H(wtest/2,A1A,A1B,A1Cap,A1Dap);
HA2=schurOneMAPlatticeDoublyPipelined2H(wtest/2,A2A,A2B,A2Cap,A2Dap);

max_diff=abs(HA1+HA2-HRA1-HRA2);
if max_diff > tol
  error("abs(HA1+HA2-HRA1-HRA2)(%g*eps) > tol",max_diff/eps);
endif

printf("Done!\n")

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
