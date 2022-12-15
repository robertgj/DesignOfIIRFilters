% kyp_symbolic_frequency_transformation_test.m
% Copyright (C) 2022 Robert G. Jenssen
%
% Try to verify Lemmas etc. in "Generalization of Kalman-Yakubovic-Popov Lemma
% for Restricted Frequency Inequalities", T. Iwasaki and S. Hara, Proceedings
% of the American Control Conference, Denver Colorado, June 4-6, 2003,
% pp. 3828--3833.

test_common;

strf="kyp_symbolic_frequency_transformation_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

pkg load symbolic

%{
% 1. The following commented out section takes several minutes
% 2. isAlways() uses a feature deprecated in SymPy V1.10.1.
%    From Symbolic pkg v3.0.1:
%
% <stdin>:22: SymPyDeprecationWarning: 
%
%  non-Expr objects in a Matrix is deprecated. Matrix represents
%  a mathematical matrix. To represent a container of non-numeric
%  entities, Use a list of lists, TableForm, NumPy array, or some
%  other data structure instead.
%
%  See:
% https://docs.sympy.org/latest/explanation/active-deprecations.html#deprecated-non-expr-in-matrix
%
%  for details.
%
%  This has been deprecated since SymPy version 1.9. It
%  will be removed in a future version of SymPy.

%
% Lemma 2
%
syms w a b c d A11 A12 A21 A22 B1 B2 real
A=[A11,A12;A21,A22];
B=[B1;B2];
I=eye(2);
G=inv((d*I)+(c*A));
Ac=((b*I)+(a*A))*G;
Bc=((a*d)-(b*c))*G*B;
Cc=G;
Dc=-c*G*B;
s=j*w;
T=(b-(d*s))/((c*s)-a);
H=inv((T*I)-A)*B;
Hc=(Cc*inv((s*I)-Ac)*Bc)+Dc;
isAlways(H==Hc);
if ~all(ans)
  error("H==Hc failed");
endif
clear w a b c d A11 A12 A21 A22 B1 B2
%}

%
% Lemma 3
%
syms p q r s w real
J=[1,0;0,j];
F=[p,q;r,s];
N=J'*F*J*exp(j*w);
eval(N'*[0,1;1,0]*N)
clear p q r s w

%
% Lemma 5
%
syms B p q r s w real
J=[1,0;0,j];
F=[p,q;r,s];
N=J'*F*J*exp(j*w);
U=N'*[-1,B;1,B]*N;
detReJUJp=factor(det(real(expand(J*U*J'))))
clear B p q r s w

%
% Lemma 6 : Low-pass case
%
syms G real
K=[[1,-1];[1,1]]/sqrt(2);
Phi=K'*[0,1;1,0]*K
Psi=[[0,1];[1,-G]];
J=[[1,0];[0,j]];
invJK=2*((J*[1,-1;1,1])^(-1)); % invJK is scaled by sqrt(2)
Psi_o=real(factor(expand(invJK'*Psi*invJK)))/2
clear G

%
% Lemma 6 : High-pass case
%
syms G real
K=[[1,-1];[1,1]]/sqrt(2);
Psi=[[0,-1];[-1,G]];
J=[[1,0];[0,j]];
invJK=2*((J*[1,-1;1,1])^(-1)); % invJK is scaled by sqrt(2)
Psi_o=real(factor(expand(invJK'*Psi*invJK)))/2
clear G

%
% Lemma 6 : Band-pass case
%
syms wc ww w1 w2 real
K=[[1,-1];[1,1]]/sqrt(2);
Psi=[[0,e^(j*wc)];[e^(-j*wc),-2*cos(ww)]];
J=[[1,0];[0,j]];
invJK=[[1,-j];[-1,-j]]; % invJK is scaled by sqrt(2)
wc=(w2+w1)/2;
ww=(w2-w1)/2;
Psi_o=factor(eval(real((invJK'*Psi*invJK)/2)))
clear wc ww w1 w2

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
