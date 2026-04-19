% yalmip_kyp_lofberg_dualize_test.m
% See : https://yalmip.github.io/tutorial/automaticdualization
%
% The example with this constraint does not seem to work as Lofberg expects:
%{
F = [sum(X) == 6+pi*t(1), diag(Y) == -2+exp(1)*t(2)]
F = [F, Y>=0, X>=0];
%}
% The equality constraints are ignored and SeDuMi finds X~0 and Y~0.
%
% Also octave declares that @sdpvar/assign is obsolete. It is replaced by
% warmstart which assigns a value to an @sdpvar, the reverse of the behaviour
% shown below.

test_common;

strf="yalmip_kyp_lofberg_dualize_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

X = sdpvar(30,30);
Y = sdpvar(3,3);
obj = trace(X)+trace(Y);

% Initial model constraints
printf("Initial model constraints:\n");
F = [X>=0, Y>=0, X(1,3)==9, Y(1,1)==X(2,2), sum(sum(X))+sum(sum(Y)) == 20]
printf("number of variables in F is %d\n",length(getvariables(F)));

% Dualized model constraints
printf("Dualized model constraints:\n");
[Fd,objd,primals] = dualize(F,obj)
printf("number of variables in Fd is %d\n",length(getvariables(Fd)));
printf("number of primals is %d (i.e.: X and Y)\n",length(primals));

% Run YALMIP/SeDuMi. By default YALMIP runs the dual model. In this case,
% the model is already dualised so do not let YALMIP convert back to the
% initial, larger, primal model.
printf("Running YALMIP/SeDuMi\n");
options=sdpsettings("solver","sedumi","dualize",false, "verbose",false);
diagnostics=optimize(Fd,-objd,options);
printf("Results:\n");
printf("info=%s\n",diagnostics.info)
printf("problem=%d\n",diagnostics.problem)
printf("obj=%6.3f\n",value(obj));
printf("objd=%6.3f\n",value(objd));
print_polynomial(value(recover(getvariables(F))),"F var.s","%11.4e");
print_polynomial(value(recover(getvariables(Fd))),"Fd var.s","%11.4e");

%
% Sanity checks
%

% Sanity check on primals
for i = 1:length(primals),
  assign(primals{i},dual(Fd(i)));
end
if max(max(abs(value(primals{1}-X)))) ~= 0
  error("max(max(abs(value(primals{1}-X)))) ~= 0");
endif
if max(max(abs(value(primals{2}-Y)))) ~= 0
  error("max(max(abs(value(primals{2}-Y)))) ~= 0");
endif

% Sanity check on objective and constraints
tol=1e-8;
if abs(value(objd-obj)) > tol
  error("abs(value(objd-obj)) > tol")
endif
if any(eigs(value(X),rows(X)) < 0)
  error("any(eigs(value(X),rows(X)) < 0)");
endif
if any(eigs(value(Y),rows(Y)) < 0)
  error("any(eigs(value(Y),rows(Y)) < 0)");
endif
if abs(value(X(1,3))-9) > tol
  error("abs(value(X(1,3))-9) > tol");
endif
if abs(value(X(2,2)-Y(1,1))) > tol
  error("abs(value(X(2,2)-Y(1,1))) > tol");
endif
if abs(sum(sum(value(X)))+sum(sum(value(Y)))-20) > tol
  error("abs(sum(sum(value(X)))+sum(sum(value(Y)))-20) > tol");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
