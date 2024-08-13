% yalmip_test.m
% Copyright (C) 2020-2024 Robert G. Jenssen

% YALMIP assumes MATLAB linprog. OctaveForge optim linprog is not compatible.

test_common;

strf="yalmip_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Run YALMIP yalmiptest.m script
solvers={'scs-direct','scs-indirect','sedumi','sdpt3'};
for k=1:length(solvers)
  yalmiptest(sdpsettings('solver',solvers{k}),true);
endfor

% Required by SparsePOP
pkg load symbolic

% Define variables
x = sdpvar(10,1);

% Define constraints 
Constraints = [sum(x) <= 10, x(1) == 0, 0.5 <= x(2) <= 1.5];
for i = 1 : 7
  Constraints = [Constraints, x(i) + x(i+1) <= x(i+2) + x(i+3)];
end

% Define an objective
Objective = x'*x+norm(x,1);

% Run some examples
fhandle=fopen("test.results","wt");
solvers={'scs-direct','scs-indirect','sdpt3','sedumi','sparsepop'};
for k=1:length(solvers)
  if strcmp(solvers{k},'sparsepop')
    pkg('load','symbolic');
  endif
  
  % Set some options for YALMIP and solver
  options = sdpsettings('verbose',1,'solver',solvers{k});

  % Solve the problem
  try
    sol = optimize(Constraints,Objective,options);
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
  if sol.problem == 0
    % Extract and display value
    solution = value(x)
    fprintf(fhandle,"For %s : solution = [ ",solvers{k});
    fprintf(fhandle,"%9.6f ",solution(:)');
    fprintf(fhandle,"]\n");
  else
    display('Something went wrong!');
    sol.info
    yalmiperror(sol.problem)
  endif
endfor
fclose(fhandle);

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
