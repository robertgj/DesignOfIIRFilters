% jacobi_Eta_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("jacobi_Eta_test.diary");
delete("jacobi_Eta_test.diary.tmp");
diary jacobi_Eta_test.diary.tmp

tol=10*eps;

%{ 
  % JacobiEta.txt was created by the JacobiEta function in
  % elfun18v1_3 (https://github.com/ElsevierSoftwareX/SOFTX_2018_246)
  x=-1:0.1:1;
  k=0.1:0.1:0.9;
  Eta=zeros(length(x),length(k));
  for m=1:length(x),
    for n=1:length(k),
      Eta(m,n)=JacobiEta(x(m),k(n));
    endfor
  endfor
  save -ascii -double JacobiEta.txt Eta
%}

load JacobiEta.txt

x=(-1:0.1:1)';
k=0.1:0.1:0.9;
for l=1:length(k),
  Eta=jacobi_Eta(x,k(l));
  if max(abs(Eta-JacobiEta(:,l)))>tol
    error("max(abs(Eta-JacobiEta(_,%d)))(%g)>tol", ...
          l,max(abs(Eta-JacobiEta(:,l))));
  endif
endfor

%{
  % jacobiEtaMoiseev.txt was created by the JacobiThetaEta function from
  % https://github.com/moiseevigor/elliptic
  x=-1:0.1:1;
  k=0.1:0.1:0.9;
  th=zeros(length(x),length(k));
  Eta=zeros(length(x),length(k));
  for m=1:length(x),
    for n=1:length(k),
      [th_tmp,Eta_tmp]=jacobiThetaEta(x(m),k(n)^2);
      th(m,n)=th_tmp;  
      Eta(m,n)=eta_tmp;  
    endfor
  endfor
  save -ascii -double jacobiThetaMoiseev.txt th
  save -ascii -double jacobiEtaMoiseev.txt Eta
%}

load jacobiEtaMoiseev.txt

x=(-1:0.1:1)';
k=0.1:0.1:0.9;
for l=1:length(k),
  Eta=jacobi_Eta(x,k(l));
  if max(abs(Eta-jacobiEtaMoiseev(:,l)))>tol
    error("max(abs(Eta-jacobiEtaMoiseev(_,%d)))(%g)>tol", ...
          l,max(abs(Eta-jacobiEtaMoiseev(:,l))));
  endif
endfor

% Done
diary off
movefile jacobi_Eta_test.diary.tmp jacobi_Eta_test.diary;
