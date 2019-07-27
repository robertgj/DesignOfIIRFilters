% jacobi_Eta_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("jacobi_Eta_test.diary");
unlink("jacobi_Eta_test.diary.tmp");
diary jacobi_Eta_test.diary.tmp

tol=10*eps;

%{ 
  % JacobiEta.txt was created by the JacobiEta function in
  % elfun18v1_3 (https://github.com/ElsevierSoftwareX/SOFTX_2018_246)
  x=-1:0.1:1;
  k=0.1:0.1:0.9;
  eta=zeros(length(x),length(k));
  for m=1:length(x),
    for n=1:length(k),
      eta(m,n)=JacobiEta(x(m),k(n));
    endfor
  endfor
  save -ascii -double JacobiEta.txt eta
%}

load JacobiEta.txt

x=-1:0.1:1;
k=0.1:0.1:0.9;
z=zeros(size(JacobiEta));
for m=1:rows(JacobiEta),
  for n=1:columns(JacobiEta),
    eta(m,n)=jacobi_Eta(x(m),k(n));
    if abs(eta(m,n)-JacobiEta(m,n))>tol
      error("abs(eta(m,n)-JacobiEta(m,n))>tol,x=%f,k=%f",x(m),k(n));
    endif
  endfor
endfor

if max(max(abs(eta-JacobiEta)))>tol
  error("max(max(abs(eta-JacobiEta)))>tol");
endif

%{
  % jacobiEtaMoiseev.txt was created by the JacobiThetaEta function from
  % https://github.com/moiseevigor/elliptic
  x=-1:0.1:1;
  k=0.1:0.1:0.9;
  th=zeros(length(x),length(k));
  eta=zeros(length(x),length(k));
  for m=1:length(x),
    for n=1:length(k),
      [th_tmp,eta_tmp]=jacobiThetaEta(x(m),k(n)^2);
      th(m,n)=th_tmp;  
      eta(m,n)=eta_tmp;  
    endfor
  endfor
  save -ascii -double jacobiThetaMoiseev.txt th
  save -ascii -double jacobiEtaMoiseev.txt eta
%}

load jacobiEtaMoiseev.txt

x=-1:0.1:1;
k=0.1:0.1:0.9;
eta=zeros(size(jacobiEtaMoiseev));
for m=1:rows(jacobiEtaMoiseev),
  for n=1:columns(jacobiEtaMoiseev),
    eta(m,n)=jacobi_Eta(x(m),k(n));
    if abs(eta(m,n)-jacobiEtaMoiseev(m,n))>tol
      error("abs(eta(m,n)-jacobiEtaMoiseev(m,n))>tol,x=%f,k=%f",x(m),k(n));
    endif
  endfor
endfor

if max(max(abs(eta-jacobiEtaMoiseev)))>tol
  error("max(max(abs(eta-jacobiEtaMoiseev)))>tol");
endif

% Done
diary off
movefile jacobi_Eta_test.diary.tmp jacobi_Eta_test.diary;
