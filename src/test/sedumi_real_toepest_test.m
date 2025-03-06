% sedumi_real_toepest_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen
%
% See Section 4 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf
% Compare the output of this script with Section 4 of the User Guide
% and the YALMIP tutorial at https://yalmip.github.io/tutorial/complexproblems
%
% This script attempts to solve this problem with a real representation of the
% complex matrix. The problem to be solved is:
%   given           P, n-by-n Hermitian
%   minimise        t
%   subject to      ||Z-P||F<=t (Frobenius norm)
%                   Z is Toeplitz Hermitian
%                   Z is positive definite
% where Z is represented by the vector z=[x1 x2 ... xn y2 ... yn] and the
% Frobenius norm is ||A||F = sqrt(sum(diag(A'*A))) = sqrt(sum(sum(abs(A).^2)))

test_common;

delete("sedumi_real_toepest_test.diary");
delete("sedumi_real_toepest_test.diary.tmp");
diary sedumi_real_toepest_test.diary.tmp

function [At,b,c,K] = real_toepest(P)
  % [At,b,c,K] = real_toepest(P)
  % Creates real dual standard form for Toeplitz-covariance estimation

  N=rows(P);

  % Calculate the A-matrix for the quadratic inequality
  A=zeros((2*N)-1,2*N);
  A(1:N,1)=ones(N,1);
  l=N;
  m=2;
  for k=(N-1):-1:1
    A(l+(1:k),m)=sqrt(2)*ones(k,1);
    l=l+k;
    m=m+1;
  endfor
  for k=(N-1):-1:1
    A(l+(1:k),m)=sqrt(2)*ones(k,1);
    l=l+k;
    m=m+1;
  endfor

  % Convert P to vector form
  p=zeros(N*N,1);
  p(1:N)=diag(P);
  l=N;
  for k=1:(N-1)
    p((l+1):(l+N-k))=sqrt(2)*real(diag(P,k));
    l=l+N-k;
  endfor
  for k=1:(N-1)
    p((l+1):(l+N-k))=sqrt(2)*imag(diag(P,k));
    l=l+N-k;
  endfor

  % Construct real semi-definite constraint matrixes with Z=X+jY -> [X,Y;-Y,X]
  Fx=cell(N,1);
  Fx{1}=diag(ones(N,1));
  for k=2:N
    Fx{k}=diag(ones(N-k+1,1),k-1)+diag(ones(N-k+1,1),-(k-1));
  endfor
  Fy=cell(N-1,1);
  for k=2:N
    Fy{k-1}=diag(ones(N-k+1,1),k-1)-diag(ones(N-k+1,1),-(k-1));
  endfor
  F=cell((2*N),1);
  F{1}=[Fx{1},zeros(size(Fx{1}));zeros(size(Fx{1})),Fx{1}];
  for k=1:N
    F{k}=[Fx{k},zeros(size(Fx{k}));zeros(size(Fx{k})),Fx{k}];
  endfor
  for k=2:N
    F{N+k-1}=[zeros(size(Fy{k-1})),Fy{k-1};-Fy{k-1},zeros(size(Fy{k-1}))];
  endfor
  F{2*N}=zeros(size(F{1}));
  vecF=zeros(rows(F{1})*columns(F{1}),2*N);
  for k=1:(2*N)
    vecF(:,k)=vec(F{k});
  endfor

  % Set up the SeDuMi problem
  b=[zeros((2*N)-1,1); 1];
  At=-[b';A;vecF]';
  b=-b;
  c=[0;-p;zeros(rows(vecF),1)];
  K.q=1+rows(A);
  K.s=2*N;
endfunction
  
% Solve the Toeplitz estimation problem
P=[4 1+2*i 3-i; 1-2*i 3.5 0.8+2.3*i; 3+i 0.8-2.3*i 4];
[At,b,c,K]=real_toepest(P);
pars.fid=0;
[x,y,info]=sedumi(At,b,c,K,pars);
printf("info.dinf=%d\n",info.dinf);
printf("info.pinf=%d\n",info.pinf);
printf("info.numerr=%d\n",info.numerr);

% Extract Z and t from y
z=y(1:(end-1));
t=y(end);
Z=toeplitz([z(1);z(2:rows(P))+j*z((rows(P)+1):end)]);
print_polynomial(z,"z","%6.4f");
printf("norm(Z-P,\"fro\")=%6.4f\n",norm(Z-P,"fro"));

% Sanity checks
if abs(norm(Z-P,"fro")+(x'*c))>2e-10
  error("abs(norm(Z-P,\"fro\")+(x'*c))>2e-10");
endif
if abs(norm(Z-P,"fro")-t)>4e-10
  error("abs(norm(Z-P,\"fro\")-t)>4e-10");
endif
if ~isdefinite(Z)
  error("Z is not positive definite");
endif
if ~ishermitian(Z)
  error("Z is not Hermitian");
endif

% Done
diary off
movefile sedumi_real_toepest_test.diary.tmp sedumi_real_toepest_test.diary;
