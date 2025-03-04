% yalmip_kyp_rantzer_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% See "Proof of Theorem 2" :
% "On the Kalman-Yakubovich-Popov Lemma for Positive Systems", Anders Rantzer,
% IEEE Trans. on  Automatic Control, Vol. 61, No. 5, May 2016

test_common;

strf="yalmip_kyp_rantzer_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Low-pass Chebyshev Type-2 filter specification
%
N=5;fas=0.2;dBas=40;
[n0,d0]=cheby2(N,dBas,fas);  

[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);
[A,b,c,d]=schurOneMlattice2Abcd(k0,epsilon0,p0,c0);

AB=[A,b;eye(N),zeros(N,1)];
CD=[[c,d];zeros(1,N),1];
Phi=[-1,0;0,1];
sedumi_eps=1e-7;

%
% Use YALMIP to solve for a constraint on the maximum amplitude response
%
tol=60*sedumi_eps;
epsilon_sq=sdpvar(1,1,"full","real");
P=sdpvar(N,N,"symmetric","real");
Theta=(CD')*[[1,0];[0,-epsilon_sq]]*CD;
F=((AB')*kron(Phi,P)*AB)+Theta;
Constraints=[F<=-sedumi_eps];
Objective=epsilon_sq;
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
if ~isdefinite(-value(P))
  error("P not negative semi-definite");
endif
if ~isdefinite(-value(F))
  error("F not negative semi-definite");
endif
if abs(value(epsilon_sq)-1)>tol
  error("abs(value(epsilon_sq)-1)>tol");
endif

%
% Convert to continuous-time
%

% Try to reuse P
invApI=inv(A+eye(N));
Ah=(A-eye(N))*invApI;
bh=2*invApI*b;
ABh=[Ah,bh;eye(N),zeros(N,1)];
Phih=[0,1;1,0];
S=[invApI,-invApI*b;zeros(1,N),1];
vThetah=(S')*((CD')*[[1,0];[0,-value(epsilon_sq)]]*CD)*S;
vFh=((ABh')*kron(Phih,(-value(P)/2))*ABh)+vThetah;
if ~isdefinite(-vFh)
  error("vFh not negative semi-definite");
endif

% Try to re-calculate P
tol=200*sedumi_eps;
epsilonh_sq=sdpvar(1,1,"full","real");
Ph=sdpvar(N,N,"symmetric","real");
Thetah=(S')*((CD')*[[1,0];[0,-epsilonh_sq]]*CD)*S;
Fh=((ABh')*kron(Phih,Ph)*ABh)+Thetah;
Constraints=[Fh<=-sedumi_eps];
Objective=epsilonh_sq;
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
if ~isdefinite(value(Ph))
  error("Ph not positive semi-definite");
endif
if ~isdefinite(-value(Fh))
  error("Fh not negative semi-definite");
endif
if abs(value(epsilonh_sq)-1)>tol
  error("abs(value(epsilonh_sq)-1)>tol");
endif
if max(max(abs(abs(0.5*value(P)./value(Ph))-1))) > 0.12
  error("max(max(abs(abs(0.5*value(P)./value(Ph))-1)))>0.12");
endif

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
