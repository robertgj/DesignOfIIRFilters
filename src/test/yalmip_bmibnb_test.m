% yalmip_bmibnb_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen
% See the examples at: https://yalmip.github.io/tutorial/globaloptimization/

test_common;

delete("yalmip_bmibnb_test.diary");
delete("yalmip_bmibnb_test.diary.tmp");
diary yalmip_bmibnb_test.diary.tmp

fhandle=fopen("test.results","wt");

%
% YALMIP globaloptimization examples
%
fprintf(fhandle,"\nYALMIP globaloptimization examples\n");
yalmip('clear')
x = sdpvar(1,1);
y = sdpvar(1,1);
t = sdpvar(1,1);
A0 = [-10 -0.5 -2;-0.5 4.5 0;-2 0 0];
A1 = [9 0.5 0;0.5 0 -3 ; 0 -3 -1];
A2 = [-1.8 -0.1 -0.4;-0.1 1.2 -1;-0.4 -1 0];
K12 = [0 0 2;0 -5.5 3;2 3 0];
F = [x>=-0.5, x<=2, y>=-3, y<=7];
F = [F, A0+x*A1+y*A2+x*y*K12-t*eye(3)<=0];
options = sdpsettings('solver','bmibnb');
optimize(F,t,options);
fprintf(fhandle,"value(t)=%7.4f\n",value(t));

yalmip('clear')
A = [-1 2;-3 -4];B = [1;1];
P = sdpvar(2,2);
K = sdpvar(1,2);
F = [P>=0, (A+B*K)'*P+P*(A+B*K) <= -eye(2)-K'*K];
F = [F, -0.1 <= K <= 0.1];
options = sdpsettings('solver','bmibnb');
optimize(F,trace(P),options);
fprintf(fhandle,"value(trace(P))=%7.4f\n",value(trace(P)));

%{
% Alternatively (Unfortunately, this causes warnings of numerical instability)
yalmip('clear')
A = [-1 2;-3 -4];B = [1;1];
P = sdpvar(2,2);
K = sdpvar(1,2);
F = [P>=0, [(-eye(2) - ((A+B*K)'*P+P*(A+B*K))), K';K, 1] >= 0];
F = [F, K >= -0.1 , K <= 0.1];
options = sdpsettings('solver','bmibnb');
optimize(F,trace(P),options);
fprintf(fhandle,"value(trace(P))=%7.4f\n",value(trace(P)));
%}

yalmip('clear');
A = [-1 2;-3 -4];
t = sdpvar(1,1);
P = sdpvar(2,2);
%{
% This fails:
F = [P>=eye(2), A'*P+P*A <= -2*t*P];
F = [F, t >= 0];
%}
F = [P>=0, trace(P)==1, A'*P+P*A <= -2*t*P];
F = [F,  t >= 0];
options = sdpsettings('solver','bmibnb');
optimize(F,-t,options);
fprintf(fhandle,"value(-t)=%7.4f\n",value(-t));
% Alternatively
F = [P>=0, trace(P)==1, A'*P+P*A <= -2*t*P];
F = [F,  t >= 0];
F = [F, trace(A'*P+P*A)<=-2*t]
optimize(F,-t,options);
fprintf(fhandle,"value(-t)=%7.4f\n",value(-t));
% With Schur complement
F = [P>=0,A'*P+P*A <= -2*t*P, t >= 0];
F = [F, trace(P)==1];
F = [F, trace(A'*P+P*A)<=-2*t];
F = [F, [-A'*P-P*A P*t;P*t P*t/2] >= 0];
optimize(F,-t,options);
fprintf(fhandle,"value(-t)=%7.4f\n",value(-t));
% Specifying cuts
F = [P>=0,A'*P+P*A <= -2*t*P,100 >= t >= 0];
F = [F, trace(P)==1];
F = [F, trace(A'*P+P*A)<=-2*t];
F = [F, cut([-A'*P-P*A P*t;P*t P*t/2]>=0)];
optimize(F,-t,options);
fprintf(fhandle,"value(-t)=%7.4f\n",value(-t));

%
% YALMIP nonconvexquadraticprogramming example
%
yalmip('clear');
N=5;
Q=magic(N);
x=sdpvar(N,1);
Constraints=[-1<=x<=1];
Objective=x'*Q*x;
Options=sdpsettings('solver','bmibnb');
fprintf(fhandle,"\nYALMIP nonconvexquadraticprogramming bmibnb example\n");
try
  sol=optimize(Constraints,Objective,Options);
catch
  err=lasterror();
  for e=1:length(err.stack)
    fprintf(stderr, ...
            "Called %s at %s : %d\n", ...
            err.stack(e).name,err.stack(e).file,err.stack(e).line);
  endfor
  error(err.message);
end_try_catch

% Analyze error flags
if sol.problem ~= 0
  fprintf(fhandle,"\nSomething went wrong with %s! : %s \n", ...
          Options.solver, sol.info); 
endif

% Extract and display value
fprintf(fhandle,"For %s : \n",Options.solver);
fprintf(fhandle,"value(x) = [ ");
fprintf(fhandle,"%7.4f ",value(x)');
fprintf(fhandle,"]\n");
if abs(imag(value(x'*Q*x))) > 100*eps
  fprintf(fhandle,"abs(imag(value(x'*Q*x))) (%g) > 100*eps\n",
          abs(imag(value(x'*Q*x))));
endif
fprintf(fhandle,"real(value(x'*Q*x)) = %7.4f\n",real(value(x'*Q*x)));

% Done
fclose(fhandle);
diary off
movefile yalmip_bmibnb_test.diary.tmp yalmip_bmibnb_test.diary;
