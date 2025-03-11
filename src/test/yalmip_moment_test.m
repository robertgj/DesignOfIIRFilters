% yalmip_moment_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen
% See the examples at: https://yalmip.github.io/tutorial/momentrelaxations/ 
% and https://yalmip.github.io/example/nonconvexquadraticprogramming/
%
% !!! THE MOMENT AND SOLVEMOMENT EXAMPLES CAUSE NUMERICAL PROBLEMS IN SEDUMI !!!
% !!!                  THE RESULTS ARE UNRELIABLE                            !!!

test_common;

delete("yalmip_moment_test.diary");
delete("yalmip_moment_test.diary.tmp");
diary yalmip_moment_test.diary.tmp

fhandle=fopen("test.results","wt");

%
% YALMIP nonconvex quadratic programming moment example
%
fprintf(fhandle,"\nYALMIP nonconvex quadratic programming moment example\n");
yalmip("clear");
N=5;
Q=magic(N);
x=sdpvar(N,1);
Constraints=[-1<=x<=1];
Objective=x'*Q*x;
Options=sdpsettings("solver","moment","moment.order",3);
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
  fprintf(stderr,"\nSomething went wrong with moment! : %s \n", sol.info); 
endif

% Extract and display value
fprintf(fhandle,"value(sol.xoptimal{1}) = [ ");
fprintf(fhandle,"%5.2f ",value(sol.xoptimal{1})');
fprintf(fhandle,"]\n");
fprintf(fhandle,"value(sol.xoptimal{1})'*Q*value(sol.xoptimal{1}) = %5.2f\n", ...
        value(sol.xoptimal{1}'*Q*sol.xoptimal{1}));
fprintf(fhandle,"value(sol.xoptimal{2}) = [ ");
fprintf(fhandle,"%5.2f ",value(sol.xoptimal{2})');
fprintf(fhandle,"]\n");
fprintf(fhandle,"value(sol.xoptimal{2})'*Q*value(sol.xoptimal{2}) = %5.2f\n", ...
        value(sol.xoptimal{2}'*Q*sol.xoptimal{2}));

%
% YALMIP moment relaxation solvemoment example
%
fprintf(fhandle,"\nYALMIP moment relaxation solvemoment example\n");
yalmip("clear");
sdpvar x1 x2 x3
obj = -2*x1+x2-x3;
F = [x1*(4*x1-4*x2+4*x3-20)+x2*(2*x2-2*x3+9)+x3*(2*x3-13)+24>=0; ...
     4-(x1+x2+x3)>=0; ...
     6-(3*x2+x3)>=0; ...
     2>=x1>=0,x2>=0,3>=x3>=0]
[sol,x,momentdata] = solvemoment(F,obj,[],4);
if sol.problem ~= 0
  fprintf(stderr,"\nSomething went wrong with solvemoment! : %s \n", sol.info); 
endif
expected=cell(1,2);
expected{1}=[ 0.5000  0.0000  3.0000 ]';
expected{2}=[ 2.0000  0.0000  0.0000 ]';
for k=1:length(x)
  assign([x1;x2;x3],x{k});
  fprintf(fhandle,"For k=%d : \n",k);
  fprintf(fhandle,"obj = %5.2f\n",value(obj));
  % This test fails 1 or 2 times out of 50 !?!?!
  tol=1e-3;
  if norm(expected{k}-value(x{k}))>tol
    fprintf(stderr,"norm(expected{%d}(%g)-value(x{%d})(%g))(%g)>(%g)", ...
            k,expected{k},k,value(x{k}),norm(expected{k}-value(x{k})),tol);
  endif
endfor

% Done
fclose(fhandle);
diary off
movefile yalmip_moment_test.diary.tmp yalmip_moment_test.diary;
