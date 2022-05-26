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
opt_alpha=2.5;
F = (P>=eye(2))+(A'*P+P*A<=-2*alpha*P)+(alpha >= 0);
sol = optimize([F, P(:)<=100],-alpha);
pass = ismember(sol.problem,[0 3 4 5]); 
result = 'N/A';
if pass
  if norm(value(alpha)-opt_alpha)<=25e-3*norm(opt_alpha)
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
          Options.solver, sol.info); 
endif

% Extract and display value
fhandle=fopen("test.results","wt");
fprintf(fhandle,"sol.problem=%d,result=%s,value(alpha) = %g\n",
        sol.problem,result,value(alpha)');
fprintf(fhandle,"P(:)'=[");
fprintf(fhandle,"%6.4f ",value(P)(:)');
fprintf(fhandle,"]\n");
fprintf(fhandle,"(A'*P)+(P*A)+(2*alpha*P)(:)'=[");
fprintf(fhandle,"%6.4f ",value((A'*P)+(P*A)+(2*alpha*P))(:)');
fprintf(fhandle,"]\n");
fclose(fhandle);

% Done
diary off
movefile yalmip_bmitest_test.diary.tmp yalmip_bmitest_test.diary;
