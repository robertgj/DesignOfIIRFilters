% GlAB_test.m
% Copyright (C) 2022 Robert G. Jenssen

% Check Equation 2.8 of "GENERALIZING THE KYP LEMMA TO MULTIPLE FREQUENCY
% INTERVALS", G. Pipeleers, T. Iwasaki and S. Hara,SIAM Journal on Control
% and Optimization, 2014, Vol. 52, No. 6, pp 3618-3638.
%
% !! NOTE THE TYPO IN THE ARTICLE FOR F1ZI !!
%

test_common;

delete("GlAB_test.diary");
delete("GlAB_test.diary.tmp");
diary GlAB_test.diary.tmp

% Define variables
m=3;n=4;
A=rand([n,n]);
B=rand([n,m]);
In=eye(n);
Im=eye(m);
Zn=zeros(n);
Zm=zeros(m);
Znm=zeros(n,m);
Zmn=zeros(m,n);

l=2;
Il=eye(l);
Znlm=zeros(n*l,m);
Zmln=zeros(m*l,n);
F1AB=[A,B;In,Znm];
F1ZI=[Zm,Im;Im,Zm];
G2AB=kron(Il,[In;Zmn])*[F1AB,Znlm] + kron(Il,[Znm;Im])*[Zmln,F1ZI];
if any(any(abs(G2AB-[A,B,Znm; ...
                     Zmn,Zm,Im; ...
                     In,Znm,Znm; ...
                     Zmn,Im,Zm])>eps))
  error("G2AB fails!");
endif

l=3;
Il=eye(l);
Znlm=zeros(n*l,m);
Zmln=zeros(m*l,n);
F2AB=[A*A,A*B,B;A,B,Znm;In,Znm,Znm];
F2ZI=[Zm,Zm,Im;Zm,Im,Zm;Im,Zm,Zm];
G3AB=kron(Il,[In;Zmn])*[F2AB,Znlm] + kron(Il,[Znm;Im])*[Zmln,F2ZI];
if any(any(abs(G3AB-[A*A,A*B,B,Znm; ...
                     Zmn,Zm,Zm,Im; ...
                     A,B,Znm,Znm; ...
                     Zmn,Zm,Im,Zm; ...
                     In,Znm,Znm,Znm; ...
                     Zmn,Im,Zm,Zm])>eps))
  error("G3AB fails!");
endif

% Done
diary off
movefile GlAB_test.diary.tmp GlAB_test.diary;
