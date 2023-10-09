% yalmip_kyp_epsilon_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% If I use the direct form cheby2 state space system then in each case I get the
% message:
%  "The coefficient matrix is not full row rank, numerical problems may occur.
%
% With the Schur One-Multiplier filter [A,b;c,d] implementation I get
% a warning that F_s is not negative semi-definite.

test_common;

strf="yalmip_kyp_epsilon_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Low-pass Chebyshev Type-2 filter specification
%
N=5;fas=0.2;dBas=40;
[n0,d0]=cheby2(N,dBas,fas);  

if 1
  % I get a warning that F_s is not negative semi-definite.
  [k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);
  [A,b,c,d]=schurOneMlattice2Abcd(k0,epsilon0,p0,c0);
elseif 0
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
  [A,b,c,d]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
elseif 0
  % I get SeDuMi failure with numerical problems
  [A,b,c,d]=tf2Abcd(n0,d0);
elseif 0
  % I get the message: "The coefficient matrix is not full row
  %                     rank, numerical problems may occur."
  [A,b,c,d]=cheby2(N,dBas,fas);
endif

AB=[A,b;eye(N),zeros(N,1)];
Yscale=pi;
CD=[[c,d]*Yscale;zeros(1,N),1];
Phi=[-1,0;0,1];
sedumi_eps=1e-7;

%
% Use YALMIP to solve for a constraint on the maximum amplitude response
%
tol=60*sedumi_eps;
epsilon_max_sq=sdpvar(1,1,"full","real");
P_max=sdpvar(N,N,"symmetric","real");
Theta_max=(CD')*[[1,0];[0,-epsilon_max_sq]]*CD;
F_max=((AB')*kron(Phi,P_max)*AB)+Theta_max;
Constraints=[F_max<=-sedumi_eps];
Objective=epsilon_max_sq;
Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
try
  sol=optimize(Constraints,Objective,Options);
catch
  errmsg=lasterr();
  error("YALMIP caught : %s",errmsg.message);
end_try_catch
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~isdefinite(-value(F_max))
  error("F_max not negative semi-definite");
endif
if abs(value(epsilon_max_sq)-(Yscale^2))>tol
  error("abs(value(epsilon_max_sq)-(Yscale^2))>tol");
endif

% Show overall epsilon
fid=fopen(strcat(strf,"_epsilon_max.m"),"wt");
fprintf(fid,"epsilon_max=%10.8f\n",sqrt(value(epsilon_max_sq)));
fclose(fid);

%
% Use YALMIP to solve for a constraint on the stop band amplitude response
%
tol=sedumi_eps;
epsilon_s_sq=sdpvar(1,1,"full","real");
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
c_s=2*cos(2*pi*fas);
Psi_s=[0,-1;-1,c_s];
Theta_s=(CD')*[[1,0];[0,-epsilon_s_sq]]*CD;
F_s=((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + Theta_s;
Constraints=[F_s<=-sedumi_eps, Q_s>=0];
Objective=epsilon_s_sq;
Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
try
  sol=optimize(Constraints,Objective,Options);
catch
  errmsg=lasterr();
  error("YALMIP caught : %s",errmsg.message);
end_try_catch
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~isdefinite(value(Q_s))
  warning("Q_s not positive semi-definite, min. eigenvalue is %g",
          min(eigs(value(Q_s))));
endif
if ~isdefinite(-value(F_s))
  warning("F_s not negative semi-definite, max. eigenvalue is %g",
          max(eigs(value(F_s))));
endif
if abs(value(epsilon_s_sq)-(Yscale/(10^(dBas/20)))^2) > tol
  error("abs(value(epsilon_s_sq)-(Yscale/10^(dBas/20))^2) > tol");
endif

% Show stop band epsilon
fid=fopen(strcat(strf,"_epsilon_s.m"),"wt");
fprintf(fid,"epsilon_s=%10.8f\n",sqrt(value(epsilon_s_sq)));
fclose(fid);

%
% Use YALMIP to solve for a constraint on the response real part
%
tol=30*sedumi_eps;
epsilon_r=sdpvar(1,1,"full","real");
P_r=sdpvar(N,N,"symmetric","real");
Theta_r=(CD')*[[0,1];[1,-2*epsilon_r]]*CD;
F_r=((AB')*kron(Phi,P_r)*AB) + Theta_r;
Constraints=[F_r<=-sedumi_eps,epsilon_r>=0];
Objective=epsilon_r;
Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
try
  sol=optimize(Constraints,Objective,Options);
catch
  errmsg=lasterr();
  error("YALMIP caught : %s",errmsg.message);
end_try_catch
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~isdefinite(-value(F_r))
  error("F_r not negative semi-definite");
endif
if abs(value(epsilon_r)-Yscale) > tol
  error("abs(value(epsilon_r)-Yscale) > tol");
endif

% Show real part epsilon
fid=fopen(strcat(strf,"_epsilon_r.m"),"wt");
fprintf(fid,"epsilon_r=%10.8f\n",value(epsilon_r));
fclose(fid);

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
