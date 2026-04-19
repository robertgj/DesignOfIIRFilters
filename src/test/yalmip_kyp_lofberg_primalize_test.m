% yalmip_kyp_lofberg_primalize_test.m
% See : https://yalmip.github.io/tutorial/automaticdualization
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_lofberg_primalize_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

use_precalculated_times = true;

if use_precalculated_times

N = [ 10, 16, 25, 40, 63 100 ];

tic_time_F = [ 0.2360, 0.2410, 0.3265, 1.1887, 15.3911, 276.7329 ];
tic_time_Fp = [ 0.2079,   0.2616,   0.3221,   1.1406,  12.4290, 243.9443 ];
tic_time_Fp_remove_equal = ...
  [ 0.2059,   0.2119,   0.2888,   1.1138,  13.5459, 207.5645 ];

yalmip_time_F = [ 0.1583, 0.1395, 0.1487, 0.1539, 0.2031, 0.5200 ];
yalmip_time_Fp = [ 0.1386, 0.1352, 0.1382, 0.1437, 0.1550, 0.2336 ];
yalmip_time_Fp_remove_equal = ...
  [ 0.1400,   0.1406,   0.1790,   0.7230,   9.3247, 146.6200 ];

solver_time_F = ...
  [ 7.4116e-02, 9.9558e-02, 1.7585e-01, 1.0328e+00, 1.5186e+01, 2.7620e+02 ];
solver_time_Fp = ...
  [ 6.5574e-02, 1.2284e-01, 1.8011e-01, 9.9309e-01, 1.2270e+01, 2.4371e+02 ];
solver_time_Fp_remove_equal = ...
  [ 0.061393, 0.066016, 0.089246, 0.154125, 0.399499, 1.953708 ];

else
  
tol=1e-6;
options=sdpsettings("dualize","false","solver","sedumi","sedumi.eps",tol);
options_remove_equal = sdpsettings(options,"removeequalities",true);

N=sort([round(logspace(1,2,6))]);
t_F=zeros(size(N));
tic_time=zeros(size(N));
yalmip_time=zeros(size(N));
solver_time=zeros(size(N));
t_Fp=zeros(size(N));
yalmip_time_F=zeros(size(N));
solver_time_F=zeros(size(N));
tic_time_F=zeros(size(N));
t_Fp=zeros(size(N));
yalmip_time_Fp=zeros(size(N));
solver_time_Fp=zeros(size(N));
tic_time_Fp=zeros(size(N));
t_Fp_remove_equal=zeros(size(N));
yalmip_time_Fp_remove_equal=zeros(size(N));
solver_time_Fp_remove_equal=zeros(size(N));
tic_time_Fp_remove_equal=zeros(size(N));

Nrep=3;
k=0;
for n=N,

  k=k+1;
  
  randn("seed", 0xdeadbeef);
  A = randn(n);A = A - max(real(eig(A)))*eye(n)*1.5; % Stable dynamics
  B = randn(n,1);
  C = randn(1,n);

  t = sdpvar(1,1);
  P = sdpvar(n,n);
  obj = t;
  F = [kyp(A,B,P,blkdiag(C'*C,-t)) <= 0]
  % Do this here rather than after the first optimize!
  [Fp,objp] = primalize(F,-obj);Fp

  for nrep=1:Nrep,

    tic;
    diagnostics_F = optimize(F,obj,options)
    tic_time_F(k) = tic_time_F(k)+toc();
    if diagnostics_F.problem
      error("diagnostics_F reports problem: %s", diagnostics_F.info);
    endif
    t_F(k) = t_F(k)+value(t);
    yalmip_time_F(k) = yalmip_time_F(k) + diagnostics_F.yalmiptime;
    solver_time_F(k) = solver_time_F(k) + diagnostics_F.solvertime;

    tic;
    diagnostics_Fp = optimize(Fp,objp,options)
    tic_time_Fp(k) = tic_time_Fp(k)+toc();
    if diagnostics_Fp.problem
      error("diagnostics_Fp reports problem: %s", diagnostics_Fp.info);
    endif
    t_Fp(k) = t_Fp(k)+value(t);
    yalmip_time_Fp(k) = yalmip_time_Fp(k) + diagnostics_Fp.yalmiptime;
    solver_time_Fp(k) = solver_time_Fp(k) + diagnostics_Fp.solvertime;

    tic;
    diagnostics_Fp_remove_equal = optimize(Fp,objp,options_remove_equal)
    tic_time_Fp_remove_equal(k) = tic_time_Fp_remove_equal(k)+toc();
    if diagnostics_Fp_remove_equal.problem
      error("diagnostics_Fp_remove_equal reports problem: %s", ...
            diagnostics_Fp_remove_equal.info);
    endif
    t_Fp_remove_equal(k) = t_Fp_remove_equal(k)+value(t);
    yalmip_time_Fp_remove_equal(k) = ...
      yalmip_time_Fp_remove_equal(k) + diagnostics_Fp_remove_equal.yalmiptime;
    solver_time_Fp_remove_equal(k) = ...
      solver_time_Fp_remove_equal(k) + diagnostics_Fp_remove_equal.solvertime;

    % Sanity check on t
    if abs(t_F(k) - t_Fp(k)) > 100*tol
      error("abs(t_F(%d) - t_Fp(%d))(%g*tol) > 100*tol", ...
            k,k,abs(t_F(k) - t_Fp(k))/tol);
    endif
    if abs(t_F(k) - t_Fp_remove_equal(k)) > tol
      error("abs(t_F(%d) - t_Fp_remove_equal(%d))(%g*tol) > 100*tol", ...
            k,k,abs(t_F(k) - t_Fp(k))/tol);
    endif
    
  endfor

  t_F(k)=t_F(k)/Nrep;
  yalmip_time_F(k)=yalmip_time_F(k)/Nrep;
  solver_time_F(k)=solver_time_F(k)/Nrep;
  tic_time_F(k)=tic_time_F(k)/Nrep;
  t_Fp(k)=t_Fp(k)/Nrep;
  yalmip_time_Fp(k)=yalmip_time_Fp(k)/Nrep;
  solver_time_Fp(k)=solver_time_Fp(k)/Nrep;
  tic_time_Fp(k)=tic_time_Fp(k)/Nrep;
  t_Fp_remove_equal(k)=t_Fp_remove_equal(k)/Nrep;
  yalmip_time_Fp_remove_equal(k)=yalmip_time_Fp_remove_equal(k)/Nrep;
  solver_time_Fp_remove_equal(k)=solver_time_Fp_remove_equal(k)/Nrep;
  tic_time_Fp_remove_equal(k)=tic_time_Fp_remove_equal(k)/Nrep;

  printf("\n n=%d,Nrep=%d : F  Fp  Fp_remove_equal\n",n,Nrep);
  printf("Objective : %8.6f %8.6f %8.6f \n", ...
         t_F(k), t_Fp(k), t_Fp_remove_equal(k));
  printf("yalmip_time %7.4f %7.4f %7.4f \n", ...
         yalmip_time_F(k), yalmip_time_Fp(k), yalmip_time_Fp_remove_equal(k));
  printf("solver_time %7.4f %7.4f %7.4f \n", ...
         solver_time_F(k), solver_time_Fp(k), solver_time_Fp_remove_equal(k));
  printf("tic_time %7.4f %7.4f %7.4f \n", ...
         tic_time_F(k), tic_time_Fp(k), tic_time_Fp_remove_equal(k));

  % Make a LaTeX table for solution time
  fid=fopen(sprintf("%s_n_%d_solution_time.tab",strf,n),"wt");
  fprintf(fid,"Objective (n=%d,Nrep=%d) & %8.6f & %8.6f & %8.6f \\\\\n", ...
          n, Nrep, t_F(k), t_Fp(k), t_Fp_remove_equal(k));
  fprintf(fid,"yalmip_time & %7.4f & %7.4f & %7.4f \\\\\n", ...
          yalmip_time_F(k), yalmip_time_Fp(k), yalmip_time_Fp_remove_equal(k));
  fprintf(fid,"solver_time & %7.4f & %7.4f & %7.4f \\\\\n", ...
          solver_time_F(k), solver_time_Fp(k), solver_time_Fp_remove_equal(k));
  fprintf(fid,"tic_time & %7.4f & %7.4f & %7.4f \\\\\n", ...
          tic_time_F(k), tic_time_Fp(k), tic_time_Fp_remove_equal(k));
  fclose(fid);
  
endfor

[P_tic_time_F, S_tic_time_F] = polyfit (log(N), log(tic_time_F), 2)
[P_tic_time_Fp, S_tic_time_Fp] = polyfit (log(N), log(tic_time_Fp), 2)
[P_tic_time_Fp_remove_equal, S_tic_time_Fp_remove_equal] = ...
  polyfit (log(N), log(tic_time_Fp_remove_equal), 2)

[P_yalmip_time_F, S_yalmip_time_F] = polyfit (log(N), log(yalmip_time_F), 2)
[P_yalmip_time_Fp, S_yalmip_time_Fp] = polyfit (log(N), log(yalmip_time_Fp), 2)
[P_yalmip_time_Fp_remove_equal, S_yalmip_time_Fp_remove_equal] = ...
  polyfit (log(N), log(yalmip_time_Fp_remove_equal), 2)

[P_solver_time_F, S_solver_time_F] = polyfit (log(N), log(solver_time_F), 2)
[P_solver_time_Fp, S_solver_time_Fp] = polyfit (log(N), log(solver_time_Fp), 2)
[P_solver_time_Fp_remove_equal, S_solver_time_Fp_remove_equal] = ...
  polyfit (log(N), log(solver_time_Fp_remove_equal), 2)

eval(sprintf(["save %s.mat tol N Nrep ", ...
              " tic_time_F tic_time_Fp tic_time_Fp_remove_equal ", ...
              " yalmip_time_F yalmip_time_Fp yalmip_time_Fp_remove_equal ", ...
              " solver_time_F solver_time_Fp solver_time_Fp_remove_equal "], ...
             strf));

endif

% Plot results
loglog(N,tic_time_F,"o", ...
       N,tic_time_Fp,"s", ...
       N,tic_time_Fp_remove_equal,"d");
xlabel("N");
ylabel("tic time(s)");
grid("on");
legend("Primal","Dual","Dual(removeequalities)");
legend("boxoff");
legend("location","northwest");
print(strcat(strf,"_tic_time"),"-dpdflatex");
close;

loglog(N,yalmip_time_F,"o", ...
       N,yalmip_time_Fp,"s", ...
       N,yalmip_time_Fp_remove_equal,"d");
xlabel("N");
ylabel("yalmip time(s)");
grid("on");
legend("Primal","Dual","Dual(removeequalities)");
legend("boxoff");
legend("location","northwest");
print(strcat(strf,"_yalmip_time"),"-dpdflatex");
close;

loglog(N,solver_time_F,"o", ...
       N,solver_time_Fp,"s", ...
       N,solver_time_Fp_remove_equal,"d");
xlabel("N");
ylabel("solver time(s)");
grid("on");
legend("Primal","Dual","Dual(removeequalities)");
legend("boxoff");
legend("location","northwest");
print(strcat(strf,"_solver_time"),"-dpdflatex");
close;

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
