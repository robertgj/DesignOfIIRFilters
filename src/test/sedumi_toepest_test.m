% sedumi_toepest_test.m
% See Section 4 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf and "On the
% Parameterization of Positive Real Sequences and MA Parameter Estimation",
% Bogdan Dumitrescu, Ioan Tabus and Petre Stoica, IEEE Transactions on Signal
% Processing, Vol. 49, No. 11. pp. 2630-2639, November 2001.
% Compare the output of this script with Section 4 of the User Guide
% and the YALMIP tutorial at https://yalmip.github.io/tutorial/complexproblems

test_common;

delete("sedumi_toepest_test.diary");
delete("sedumi_toepest_test.diary.tmp");
diary sedumi_toepest_test.diary.tmp

function [At,b,c,K] = toepest(P)
  % [At,b,c,K] = toepest(P)
  % Creates dual standard form for Toeplitz-covariance estimation

  m = size(P,1);

  % Minimise y(m+1)
  b = [sparse(m,1); 1];

  % Let e be all-1 and allocate space for the A-matrix
  e = ones(m,1);
  K.q = [1 + m*(m+1)/2];
  K.xcomplex = 2:K.q(1);  % Norm-bound entries are complex valued
  At = sparse([],[],[],K.q(1) + m^2, m+1, 1 + 2*m^2);

  % constraints:
  % -y(m+1) >= norm( vec(P) - sum(y_i*Ti) ) (Qcone)
  % sum(y_i * Ti) is psd                    (Scone)
  At(:,1) = [sparse(2:(m+1),1,1,K.q(1),1); -vec(speye(m))];
  c = [0; diag(P)];
  firstk = m+2;
  for k = 1:(m-1)
    lastk = firstk + m - k - 1;
    Ti = spdiags(e, k, m, m);
    At(:, k+1) = [sqrt(2)*sparse(firstk:lastk, 1, 1, K.q(1), 1); -2*vec(Ti)];
    c = [c; sqrt(2)*diag(P,k)];
    firstk = lastk+1;
  endfor
  At(:, m+1) = [1; sparse(K.q(1) + (m^2)-1, 1)]; % "objective" variable y(m+1)
  c = [c; zeros(m^2,1)];                         % all-0 in the psd-part
  K.s = [m];
  K.scomplex = 1;                                % complex Hermitian PSD
  % y(2:m) complex, y(1) and y(m+1) real
  K.ycomplex = 2:m;
endfunction

pars.fid = 1;

% Solve the Toeplitz estimation problem
P = [4 1+2*i 3-i; 1-2*i 3.5 0.8+2.3*i; 3+i 0.8-2.3*i 4];
[At,b,c,K] = toepest(P);
[x,y,info] = sedumi(At,b,c,K,pars);
printf("info.numerr=%d\n",info.numerr);
z = c-At*y;
Z = mat(z(K.q+1:length(z)));
Z = (Z+Z')/2;
Z
eigK(z,K)'
[c'*x; b'*y]

% Restrict dual multipliers to be real
K.ycomplex = [];
[x2,y2,info] = sedumi(At,b,c,K,pars);
printf("info.numerr=%d\n",info.numerr);
Z
[c'*x2; b'*y2]
[b-At'*x b-At'*x2]

% Done
diary off
movefile sedumi_toepest_test.diary.tmp sedumi_toepest_test.diary;
