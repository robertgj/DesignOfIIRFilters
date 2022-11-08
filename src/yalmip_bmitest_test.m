% yalmip_bmitest_test.m
%
% From YALMIP/yalmiptest.m, function bmitest 

test_common;

delete("yalmip_bmitest_test.diary");
delete("yalmip_bmitest_test.diary.tmp");
diary yalmip_bmitest_test.diary.tmp

yalmip('clear')

A = [-1 2;-3 -4];
P = sdpvar(2,2);
alpha = sdpvar(1,1);
opt_alpha=-2.4316701;
F = (P>=eye(2))+(A'*P+P*A<=2*alpha*P)+(alpha<=0);
options = sdpsettings('solver','bmibnb','bmibnb.maxiter','1000');
sol = optimize([F P(:)<=100],alpha,options);
pass = ismember(sol.problem,[0 3 4 5]); 
if pass
  if norm(value(alpha)-opt_alpha)<=1e-7
    result = 'Correct';
  else
    result = 'Incorrect';
  end
else
  result = 'N/A';
end

% Analyze error flags
if sol.problem ~= 0
  fprintf(stderr,"\nSomething went wrong with %s! : %s \n", ...
          options.solver, sol.info); 
endif

% Extract and display value
fhandle=fopen("test.results","wt");
fprintf(fhandle,"sol.problem=%d,result=%s,value(alpha) = %7.4f\n",
        sol.problem,result,value(alpha)');
fprintf(fhandle,"P(:)'=[");
fprintf(fhandle,"%7.4f ",value(P(:)'));
fprintf(fhandle,"]\n");
if ~isdefinite(value(P-eye(2)))
  fprintf(fhandle,"P-eye(2) is not positive definite");
endif
if ~isdefinite(value((-2*alpha*P)-(A'*P+P*A)))
  fprintf(fhandle,"(-2*alpha*P)-(A'*P+P*A) is not positive definite");
endif
fclose(fhandle);

% Done
diary off
movefile yalmip_bmitest_test.diary.tmp yalmip_bmitest_test.diary;
