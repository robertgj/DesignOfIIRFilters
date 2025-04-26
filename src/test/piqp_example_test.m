% piqp_example_test.m
% From https://predict-epfl.github.io/piqp/interfaces/matlab/getting_started
%
% PIQP solves problems like:
%   min w.r.t. x : 0.5*x'*P*x + c'*x 
%   s.t.         : A*x=b, G*x<=h, xlb<= x <= xub
% where P is symmetric and positive definite

test_common;

strf="piqp_example_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

pkg load piqp;

P = [6 0; 0 4];
c = [-1; -4];
A = [1 -2];
b = 1;
G = [1 -1; 2, 0];
h = [0.2; -1];
x_lb = [-1; -Inf];
x_ub = [1; Inf];
solver = piqp('dense');
%solver.update_settings('verbose', true, 'compute_timings', true);
solver.setup(P, c, A, b, G, h, x_lb, x_ub);
result = solver.solve();
tol=1e-10;
if any(abs(result.x-[-0.6;-0.8])>tol)
  error("result.x failed");
endif
if abs((0.5*result.x'*P*result.x)+(c'*result.x) - result.info.primal_obj)>tol
  error("Objective failed!");
endif
if any(abs(b-(A*result.x))>tol)
  error("Equality failed!");
endif
if any(h-(G*result.x)<-tol)
  error("Inequality failed!");
endif
if any(result.x-x_lb<-tol)
  error("Lower bound failed!");
endif
if any(x_ub-result.x<-tol)
  error("Upper bound failed!");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
