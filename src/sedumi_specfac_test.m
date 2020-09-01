% sedumi_specfac_test.m
% See Section 3.2 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf
% See "On the Parameterization of Positive Real Sequences and MA Parameter
% Estimation",  Bogdan Dumitrescu, Ioan Tabus and Petre Stoica, IEEE
% Transactions on Signal Processing, Vol. 49, No. 11. pp. 2630-2639, Nov. 2001

test_common;

delete("sedumi_specfac_test.diary");
delete("sedumi_specfac_test.diary.tmp");
diary sedumi_specfac_test.diary.tmp

function [At,b,c,K] = specfac(b)
  % [At,b,c,K] = specfac(b)
  % Creates primal standard form for minimal phase spectral factorisation

  m = length(b);

  % Minimise sum((m-k)*X(k,k))
  c = vec(spdiags(((m-1):-1:0)',0,m,m));

  % Let e be all-1 and allocate space for A
  e = ones(m,1);
  At = sparse([],[],[],m^2,m,m*(m+1)/2);

  % sum(diag(X,k)) = b(k)
  for k = 1:m
    At(:,k) = vec(spdiags(e,k-1,m,m));
  endfor
  K.s = [m];
endfunction

pars.fid = 0;

b = [2; 0.2; -0.3];
[At,b,c,K] = specfac(b);
[x,y,info] = sedumi(At,b,c,K,pars);
printf("info.numerr = %d\n",info.numerr);
X=mat(x);
printf("X=mat(x) =\n [ ");
printf(" %7.4f %7.4f %7.4f\n   ",X);
printf(" ]\n");
printf("isdefinite(X) = %d\n",isdefinite(X));
printf("y = [ ");printf("%7.4f ",y');printf("]\n");

Z=mat(c-At*y);
ZZ=(Z+Z')/2;
printf("Z = mat(c-At*y) =\n [ ");
printf(" %7.4f %7.4f %7.4f\n   ",Z);
printf(" ]\n");
printf("ZZ=(Z+Z')/2 = \n [ ");
printf(" %7.4f %7.4f %7.4f\n   ",(Z+Z')/2);
printf(" ]\n");
printf("[eig(X), eigK(x,K), eig(ZZ)]' = \n");
printf("%7.4f %7.4f %7.4f\n",[eig(X), eigK(x,K), eig(ZZ)]');

% Done
diary off
movefile sedumi_specfac_test.diary.tmp sedumi_specfac_test.diary;
