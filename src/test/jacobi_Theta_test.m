% jacobi_Theta_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("jacobi_Theta_test.diary");
delete("jacobi_Theta_test.diary.tmp");
diary jacobi_Theta_test.diary.tmp

tol=10*eps;

%{ 
  % JacobiTheta.txt was created by the JacobiTheta function in
  % elfun18v1_3 (https://github.com/ElsevierSoftwareX/SOFTX_2018_246)
  x=-1:0.1:1;
  k=0.1:0.1:0.9;
  th=zeros(length(x),length(k));
  for m=1:length(x),
    for n=1:length(k),
      th(m,n)=JacobiTheta(x(m),k(n));
    endfor
  endfor
  save -ascii -double JacobiTheta.txt th

  % The following patch was required:

--- JacobiTheta.m.old	2019-07-04 00:04:24.327976192 +1000
+++ JacobiTheta.m	2019-07-04 00:13:56.065856277 +1000
@@ -1,6 +1,6 @@
 function result = JacobiTheta( X, K )
-%JACOBIETA Jacobi's Theta function.
-%   JACOBITHETA(X,K) is the Jacobi's Eta function of the elements of X and
+%JACOBITHETA Jacobi's Theta function.
+%   JACOBITHETA(X,K) is the Jacobi's Theta function of the elements of X and
 %   modulus K. X and K must all be real and the same size or any of them
 %   can be scalar.
 %
@@ -15,7 +15,13 @@
         error('Not enough input arguments.');
     end
     
-    result = ufun2(@jtheta, X, K);
+    if isnan(X) || isnan(K) || abs(K) > 1
+        result = NaN;
+        return
+    end
+    v = pi*X/2/elK(K);
+    q = elnome(K);
+    result = ufun2(@jtheta4, v, q);
     
 end
 
%}

load JacobiTheta.txt

x=(-1:0.1:1)';
k=0.1:0.1:0.9;
for n=1:length(k),
  th=jacobi_Theta(x,k(n));
  if max(abs(th-JacobiTheta(:,n)))>tol
    error("max(abs(th-JacobiTheta(_,%d)))(%g)>tol", ...
          n,max(abs(th-JacobiTheta(:,n))));
  endif
endfor

%{
  % jacobiThetaMoiseev.txt was created by the JacobiThetaEta function from
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

load jacobiThetaMoiseev.txt
x=(-1:0.1:1)';
k=0.1:0.1:0.9;
for n=1:length(k),
  th=jacobi_Theta(x,k(n));
  if max(abs(th-jacobiThetaMoiseev(:,n)))>tol
    error("max(abs(th-jacobiThetaMoiseev(_,%d)))(%g)>tol", ...
          n,max(abs(th-jacobiThetaMoiseev(:,n))));
  endif
endfor

% Done
diary off
movefile jacobi_Theta_test.diary.tmp jacobi_Theta_test.diary;

