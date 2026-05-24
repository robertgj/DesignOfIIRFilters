% schurOneMlattice2Falternate_symbolic_test.m
% Copyright (C) 2026 Robert G. Jenssen
%
% Create a symbolic description of Schur one-multiplier filters.
% See schurOneMlattice2Falternate_test.m

test_common;

pkg load symbolic

strf="schurOneMlattice2Falternate_symbolic_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

%
% Design a prototype lattice filter with no scaling by p or epsilon
%

tol=10*eps;dBap=0.1;dBas=40;fc=0.1;

for N=1:7,
  
  [n,d]=cheby2(N,dBas,2*fc);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [rA,rB,rC,rD,rCap,rDap]=schurOneMlattice2Abcd(k,epsilon,p,c);
  rABCapDapCD=[rA,rB;rCap,rDap;rC,rD];

  % Sanity check
  [ntf,dtf]=Abcd2tf(rA,rB,rC,rD);
  if max(abs(ntf-n)) > tol
    error("max(abs(ntf-n)) > tol");
  endif
  if max(abs(dtf-d)) > tol
    error("max(abs(dtf-d)) > tol");
  endif
  [nap,dap]=Abcd2tf(rA,rB,rCap,rDap);
  if max(abs(fliplr(nap)-d)) > tol
    error("max(abs(fliplr(nap)-d)) > tol");
  endif
  if max(abs(dap-d)) > tol
    error("max(abs(dap-d)) > tol");
  endif
  
  %
  % Define symbols
  %
  str_syms="c0 ";
  for l=1:N
    str_syms=strcat(str_syms,sprintf(" E%d k%d p%d P%d c%d ",l,l,l,l,l));
  endfor
  eval(sprintf("syms %s P%d CS1 CS3",str_syms, N+1));
  assume("c0","real");
  for l=1:N,
    assume(sprintf("k%d",l),"real");
    % BUG : octave/symbolic/SymPy (???) thinks e%d is 2.7183..., not a symbol
    assume(sprintf("E%d",l),"integer");
    assume(sprintf("p%d",l),"real");
    assume(sprintf("c%d",l),"real");
  endfor
  for l=1:N,
    eval(sprintf("P%d=p%d;",l,l));
  endfor
  eval(sprintf("P%d=vpa(1.0);",N+1));
  CS1=vpa(circshift(eye(N+2),[0,1]));
  CS3=vpa(circshift(eye(N+2),[0,3]));
  
  % Modules 1 to N
  F1=eval(sprintf(["[[P1,zeros(1,N)];", ...
                   "[c0*P1,zeros(1,N)];", ...
                   "[zeros(N,1),eye(N)]];"]));
  for l=1:N,
    eval(sprintf(["F%d=[ [-k%d/P%d, 0, (1+(k%d*E%d))*P%d/P%d]; ...\n", ...
                  "      [1-(k%d*E%d), 0, k%d*P%d]; ...\n", ...
                  "      [0, 1, c%d*P%d] ];"], ...
                 2*l,l,l,l,l,l+1,l, ...
                 l,l,l,l+1, ...
                 l,l+1));
    eval(sprintf(["F%d=[ [F%d,zeros(3,N-1)]; ...\n", ...
                  "      [zeros(N-1,3),eye(N-1)] ];"], 2*l,2*l));
    if l < N
      eval(sprintf("F%d=CS1;\n",(2*l)+1));
    else
      eval(sprintf("F%d=CS3;\n",(2*l)+1));
    endif
  endfor

  % Generate the all-pass state variable description
  ABCapDapCD=F1;
  for l=2:((2*N)+1)
    eval(sprintf("ABCapDapCD=F%d*ABCapDapCD;",l));
  endfor

  %
  % Sanity check
  %
  
  % Evaluate symbolic version
  c0=vpa(c(1));
  for l=1:N,
    eval(sprintf("k%d=vpa(k(l));",l)); 
    eval(sprintf("E%d=vpa(epsilon(l));",l)); 
    eval(sprintf("p%d=vpa(p(l));",l)); 
    eval(sprintf("c%d=vpa(c(l+1));",l));
  endfor
  vABCapDapCD=double(eval(ABCapDapCD));
  
  if max(max(abs(vABCapDapCD-rABCapDapCD))) > tol
    error("N=%d,max(max(abs(vABCapDapCD-rABCapDapCD))) > tol",N);
  endif

  eval(sprintf("clear %s",str_syms));

endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
