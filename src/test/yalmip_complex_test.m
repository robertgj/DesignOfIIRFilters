% yalmip_complex_test.m
%
% Solve the example in Section 4 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf
% with YALMIP. See https://yalmip.github.io/tutorial/complexproblems/

test_common;

delete("yalmip_complex_test.diary");
delete("yalmip_complex_test.diary.tmp");
diary yalmip_complex_test.diary.tmp

% The problem is to find a positive-definite Hermitian Toeplitz matrix Z such
% that the Frobenious norm of P-Z is minimized (P is a given complex matrix.)

% The matrix P is:
P = [4 1+2*i 3-i;1-2*i 3.5 0.8+2.3*i;3+i 0.8-2.3*i 4];

% We define a complex-valued Toeplitz matrix of the corresponding dimension:
Z = sdpvar(3,3,"toeplitz","complex")

% A complex Toeplitz matrix is not Hermitian, but we can make it Hermitian
% if we remove the imaginary part on the diagonal.
Z = Z-diag(imag(diag(Z)))*i;%sqrt(-1);

solvernames = {"sedumi", "sdpt3"};
for k = 1:length(solvernames)

  printf("\n\nUsing %s\n\n",solvernames{k});
  
  options = sdpsettings("verbose", 0, "solver", solvernames{k});

  % Minimizing the Frobenious norm of P-Z can be cast as minimizing the
  % Euclidean norm of the vectorized difference P(:)-Z(:). By using a Schur
  % complement, we see that this can be written as the following SDP.
  e = P(:)-Z(:)
  t = sdpvar(1,1);
  F = [Z>=0];
  F = [F, [t e';e eye(9)]>=0];
  diagnostics = optimize(F,t,options);
  diagnostics.info
  diagnostics.problem
  Z1 = value(Z)
  t1 = value(t)

  % The problem can be implemented more efficiently using a second order
  % cone constraint:
  e = Z(:)-P(:)
  t = sdpvar(1,1);
  F = [Z>=0];
  F = [F, cone(e,t)];
  diagnostics = optimize(F,t,options);
  diagnostics.info
  diagnostics.problem
  Z2 = value(Z)
  t2 = value(t)

  % ... with a second order cone constraint that we let YALMIP model
  % automatically
  e = Z(:)-P(:)
  F = [Z>=0];
  diagnostics = optimize(F,norm(e,2),options);
  diagnostics.info
  diagnostics.problem
  Z3 = value(Z)
  t3 = value(norm(e,2))

  % ... or by using a quadratic objective function:
  e = Z(:)-P(:)
  F = [Z>=0];
  diagnostics = optimize(F,e'*e,options);
  % Fails with YALMIP R20200930 and octave-6.1.0 :
  %  error: octave_base_value::function_value(): wrong type argument
  %                                              "<unknown type>"
  %  error: called from
  %      mtimes at line 524 column 13
  %
  % I replaced @sdpar/mtimes.m line 357 :
  %  allmt_xplusy = bsxfun(@plus,local_mt(:,testthese),mt_x);
  % with :
  %  allmt_xplusy = bsxfun("plus",local_mt(:,testthese),mt_x);
  diagnostics.info
  diagnostics.problem
  Z4 = value(Z)
  t4 = value(e'*e);
  if abs(imag(t4))>10*eps
    error("abs(imag(t4))(%g*eps)>10*eps",abs(imag(t4))/eps)
  endif
  t4=real(t4)
  
  % ... or by simply using the nonlinear operator framework which supports
  % matrix norms:
  F = [Z>=0];
  diagnostics = optimize(F,norm(P-Z,"fro"),options);
  diagnostics.info
  diagnostics.problem
  Z5 = value(Z)
  t5 = value(norm(P-Z,"fro"))
endfor

% Done
diary off
movefile yalmip_complex_test.diary.tmp yalmip_complex_test.diary;
