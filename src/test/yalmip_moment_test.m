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
fprintf(fhandle,"YALMIP nonconvex quadratic programming moment example\n");
yalmip("clear");
N=5;
Q=magic(N);
x=sdpvar(N,1);
Constraints=[-1<=x<=1];
Objective=x'*Q*x;
sedumi_eps=1e-6;
Options=sdpsettings("solver","moment","moment.order",3,"sedumi.eps",sedumi_eps);
sol=optimize(Constraints,Objective,Options);
% Analyze error flags
if sol.problem ~= 0
  fprintf(stderr,"\nSomething went wrong with moment! : %s \n", sol.info); 
endif

% Extract and display value
fprintf(fhandle,"sedumi_eps = %g\n",sedumi_eps);
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
Obj = -2*x1+x2-x3;
F = [x1*(4*x1-4*x2+4*x3-20)+x2*(2*x2-2*x3+9)+x3*(2*x3-13)+24>=0; ...
     4-(x1+x2+x3)>=0; ...
     6-(3*x2+x3)>=0; ...
     2>=x1>=0, ...
     x2>=0, ...
     3>=x3>=0];
sedumi_eps=1e-7;
Options=sdpsettings("sedumi.eps",sedumi_eps);
[sol,x,momentdata]=solvemoment(F,Obj,Options,4);
if sol.problem ~= 0
  fprintf(stderr,"\nSomething went wrong with solvemoment! : %s \n", sol.info); 
endif
sol
fprintf(fhandle,"sedumi_eps = %g\n",sedumi_eps);
for k=1:length(x)
  value(x{k})
  assign([x1;x2;x3],x{k});
  check(F)
  % To avoid -0.00 and 0.00 confusion!
  tol=1e-3;
  if abs(value(x1)) < tol, vx1=0; else vx1=value(x1); endif;
  if abs(value(x2)) < tol, vx2=0; else vx2=value(x2); endif;
  if abs(value(x3)) < tol, vx3=0; else vx3=value(x3); endif;
  fprintf(fhandle, ...
          "x1=%5.2f,x2=%5.2f,x3=%5.2f,Obj=%5.2f (expected Obj=-4)\n", ...
          vx1,vx2,vx3,value(Obj));
endfor

% Done
fclose(fhandle);
diary off
movefile yalmip_moment_test.diary.tmp yalmip_moment_test.diary;
