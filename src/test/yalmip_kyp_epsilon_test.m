% yalmip_kyp_epsilon_test.m
% Copyright (C) 2022-2026 Robert G. Jenssen
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
[H0,w]=freqz(n0,d0,1000);
max_Asq=max(abs(H0).^2);

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
tol=1e-7;
sedumi_eps=1e-7;

%
% Use YALMIP to solve for a constraint on the maximum amplitude response
%
epsilon_max_sq=sdpvar(1,1,"full","real");
P_max=sdpvar(N,N,"symmetric","real");
Theta_max=(CD')*[[1,0];[0,-epsilon_max_sq]]*CD;
F_max=((AB')*kron(Phi,P_max)*AB)+Theta_max;
Constraints=[F_max<=-tol];
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
err_epsilon_max=abs(sqrt(value(epsilon_max_sq))-Yscale);
if err_epsilon_max>10*tol
  error("abs(sqrt(value(epsilon_max_sq))-(Yscale^2))(%g*tol)>10*tol",
        err_epsilon_max/tol);
endif

% Show overall epsilon
fid=fopen(strcat(strf,"_epsilon_max.m"),"wt");
fprintf(fid,"epsilon_max=%10.8f\n",sqrt(value(epsilon_max_sq)));
fclose(fid);

%
% Use YALMIP to solve for a constraint on the stop band amplitude response
%
epsilon_s_sq=sdpvar(1,1,"full","real");
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
c_s=2*cos(2*pi*fas);
Psi_s=[0,-1;-1,c_s];
Theta_s=(CD')*[[1,0];[0,-epsilon_s_sq]]*CD;
F_s=((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + Theta_s;
Constraints=[F_s<=-tol, Q_s>=0];
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
if min(eigs(value(Q_s))) < -tol
  warning("Q_s not positive semi-definite, min. eigenvalue is %g",
          min(eigs(value(Q_s))));
endif
if min(eigs(-value(F_s))) < -tol
  warning("F_s not negative semi-definite, max. eigenvalue is %g",
          min(eigs(-value(F_s))));
endif
err_epsilon_s=abs(sqrt(value(epsilon_s_sq))-(Yscale/(10^(dBas/20))));
if err_epsilon_s > 10*tol
  error(["abs(sqrt(value(epsilon_s_sq))-", ...
         "(Yscale/10^(dBas/20)))(%g*tol) > 10*tol"], err_epsilon_s/tol);
endif

% Show stop band epsilon
fid=fopen(strcat(strf,"_epsilon_s.m"),"wt");
fprintf(fid,"epsilon_s=%10.8f\n",sqrt(value(epsilon_s_sq)));
fclose(fid);

%
% Use YALMIP to solve for a constraint on the response real part
%
epsilon_r=sdpvar(1,1,"full","real");
P_r=sdpvar(N,N,"symmetric","real");
Theta_r=(CD')*[[0,1];[1,-2*epsilon_r]]*CD;
F_r=((AB')*kron(Phi,P_r)*AB) + Theta_r;
Constraints=[F_r<=-tol];
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
if abs(value(epsilon_r)-Yscale) > 100*tol
  error("abs(value(epsilon_r)-Yscale)(%g*tol) > 100*tol", ...
        abs(value(epsilon_r)-Yscale));
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
