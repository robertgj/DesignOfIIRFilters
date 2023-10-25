% yalmip_sdp_ellipsoid_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% See Section 8.3 of "Introduction to Semidefinite Programming (SDP)",
% Robert M. Freud
%
% With SeDuMi, YALMIP warns:
%   "Objective c'x-sum logdet(P_i) has been changed to
%    c'x-sum det(P_i)^(1/(2^ceil(log2(length(P_i))))).
%    This is not an equivalent transformation.
%    You should use SDPT3 which supports MAXDET terms
%    See the MAXDET section in the manual for details."

test_common;

strf = "yalmip_sdp_ellipsoid_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

%
% Find a minimum ellipsoid with YALMIP
%
tol=1e-8;
N=10; % N-d space
k=50; % k points
c=cell(1,k);
rand("seed", 0xdeadc0de);
for l=1:k,
  c{l}=rand(N,1);
endfor
y=sdpvar(N,1,"full","real");
M=sdpvar(N,N,"symmetric","real");
Objective=-2*log(det(M));
Constraints=[M>=0];
K=cell(1,k);
for l=1:k,
  K{l}=[[eye(N),(M*c{l}-y)];[(M*c{l}-y)',1]];
  Constraints=[Constraints,K{l}>=0];
endfor
Options=sdpsettings("solver","sdpt3");

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
  error("\nSomething went wrong with YALMIP! : %s \n", sol.info); 
endif

% Extract values
z=inv(value(M))*value(y);
R=value(M)^2;
for l=1:k,
  Ec(l)=(c{l}-z)'*R*(c{l}-z);
endfor
if abs(max(Ec)-1)>tol
  error("abs(max(Ec)-1)>tol");
endif

print_polynomial(z,"z","%10.6f");
print_polynomial(z,"z",sprintf("%s_z.m",strf),"%10.6f");

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
