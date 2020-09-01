% sedumi_rls_test.m
% See Section 3.1 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf and Theorem 3.1
% of "ROBUST SOLUTIONS TO LEAST-SQUARES PROBLEMS WITH UNCERTAIN DATA"
% LAURENT EL GHAOUI AND HERVE LEBRET, SIAM J. MATRIX ANAL. APPL.
% Vol. 18, No. 4, pp. 1035-1064, October 1997

test_common;

delete("sedumi_rls_test.diary");
delete("sedumi_rls_test.diary.tmp");
diary sedumi_rls_test.diary.tmp

function [At,b,c,K] = rls(P,q)
  % [At,b,c,K] = rls(P,q)
  % Creates dual standard form for robust least squares problem "Pu=q"

  [m,n] = size(P);

  % Minimise y_1 + y_2
  b = -sparse([1;1;zeros(n,1)]);

  % (y_1, q-P*y_3) in Qcone1
  At = sparse([-1, zeros(1,1+n); ...
               zeros(m,2), P]);
  c = [0;q];
  K.q = [1+m];

  % (y_2, (1,y_3)) in Qcone2
  At = [At ; 0, -1, zeros(1,n); ...
             zeros(1,2+n); ...
             zeros(n,2), -eye(n)];
  c = sparse([c; 0; 1; zeros(n,1)]);
  K.q = [K.q, 2+n];
endfunction

pars.fid = 0;

% Solve the robust least-squares problem of the form:
%            minimise y_1+y_2
%            subject to norm(Ax+b)<y_1 and norm([x;1])<y_2
P = [3 1 4; 0 1 1; -2 5 3; 1 4 5];
q = [0; 2; 1; 3];
[At,b,c,K] = rls(P,q);
[x,y,info] = sedumi(At,b,c,K,pars);
printf("info.numerr=%d\n",info.numerr);
printf("y = [ ");printf("%7.4f ",y');printf("]\n");
printf("[eigK(x,K), eigK(c-At*y,K)]'=\n");
printf("%7.4f %7.4f\n",[eigK(x,K), eigK(c-At*y,K)]');
printf("x'*(c-At*y)=%10.3g\n",x'*(c-At*y));

% Add constraint y_3(1)<=-0.1
a1 = zeros(1,length(y));
a1(3) = 1;
At = [a1;At];
c = [-0.1; c];
K.l=1;
[x,y,info] = sedumi(At,b,c,K,pars);
printf("info.numerr=%d\n",info.numerr);
printf("y = [ ");printf("%7.4f ",y');printf("]\n");
printf("eigK(c-At*y,K)'=[ \n");
printf("%7.4f ",eigK(c-At*y,K)');
printf("]\n");

% Done
diary off
movefile sedumi_rls_test.diary.tmp sedumi_rls_test.diary;
