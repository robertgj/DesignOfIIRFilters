% bmisolver_test.m

test_common;

delete("bmisolver_test.diary");
delete("bmisolver_test.diary.tmp");
diary bmisolver_test.diary.tmp

% Test BMIsolver with random data:
% - For the spectral abscissa optimization problem, create a random problem
rand("seed",0xDEADBEEF);
p.A = rand(4,4); p.B = rand(4,2); p.C = rand(2,4);
k=1;
result{k++} = BMI_SOF_main(p)

%{
% BMIsolver can be tested by using data from COMPLeib.
%  COMPLeib can be downloaded at http://www.compleib.de/
%  Exampes: the spectral abscissa optimization problem can be tested by running
result{k++} = BMI_sof_compleib('AC1', 300, 1e-3, 1e-4)
%  The first argument is the problem name (defined in COMPLeib).
%  The second one is the maximum number of iterations
%  The third and the forth arguments are the tolerances of the search direction
%  and the objective value change.
%
% Similarly, 
%  a. Type
result{k++} = BMI_H2_compleib('AC1', 300, 1e-3, 1e-6)
%  for H2-optimization problem.
% 
%  b. Type
result{k++} = BMI_Hinf_compleib('AC1', 300, 1e-3, 1e-6)
%    for H-infinity problem.
%}
%  c. and type
result{k++} = BMI_H2Hinf_compleib('AC1', 4, 100, 1e-3, 1e-6)
%  for mixed H2/H-infinity optimization problem, where the second argurment is 
%  the H2-norm constrained level.

% Save
save bmisolver_test.mat result

% Done
diary off
movefile bmisolver_test.diary.tmp bmisolver_test.diary;
