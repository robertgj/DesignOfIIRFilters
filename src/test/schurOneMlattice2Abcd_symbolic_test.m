% schurOneMlattice2Abcd_symbolic_test.m
% Copyright (C) 2024 Robert G. Jenssen
%
% Create symbolic descriptions of Schur one-multiplier filters.

test_common;

pkg load symbolic

strf="schurOneMlattice2Abcd_symbolic_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Design a prototype lattice filter with no scaling by p or epsilon
%

tol_eps=20;dBap=0.1;dBas=40;fc=0.1;

for N=[1,2,3,6,7],
  
  [n,d]=cheby2(N,dBas,2*fc);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);

  %
  % Define symbols
  %
  str_syms="c0 ";
  for l=1:N
    str_syms=strcat(str_syms,sprintf(" E%d k%d c%d",l,l,l));
  endfor
  eval(sprintf("syms %s",str_syms));
  for l=1:N,
    assume(sprintf("c%d",l),"real");
    assume(sprintf("k%d",l),"real");
    % BUG : octave/symbolic/SymPy (???) thinks e%d is 2.7183..., not a symbol
    assume(sprintf("E%d",l),"integer");
  endfor

  % Modules 1 to Nk
  M0=eye(N+1);
  for l=1:N,
    eval(sprintf("rM%d=[[-k%d, 1+(k%d*E%d)];[1-(k%d*E%d),k%d]];",l,l,l,l,l,l,l));
    eval(sprintf("M%d=[[eye(%d-1),zeros(%d-1,2),zeros(%d-1,N-%d);]; ...\n\
                       [zeros(2,%d-1),rM%d,zeros(2,N-%d)]; ...\n\
                       [zeros(N-%d,%d-1),zeros(N-%d,2),eye(N-%d)]];",
                 l,l,l,l,l, l,l,l, l,l,l,l));
  endfor
 
  ABCapDap=M0;
  for l=1:N
    eval(sprintf("ABCapDap=M%d*ABCapDap;",l));
  endfor
  
  A=ABCapDap(1:N,1:N);
  B=ABCapDap(1:N,N+1);
  Cap=ABCapDap(N+1,1:N);
  Dap=ABCapDap(N+1,N+1);
  
  for l=0:(N-1)
    eval(sprintf("C(%d)=c%d;",l+1,l));
  endfor
  eval(sprintf("D=c%d;",N));
  ABCD=[A,B;C,D];

  %
  % Sanity checks.
  %
  
  % Conversion of original transfer functions. 
  [rA,rB,rC,rD,rCap,rDap] = schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
  
  % Evaluate symbolic version
  c0=vpa(c(1));
  for l=1:N,
    eval(sprintf("E%d=vpa(epsilon(l));",l)); 
    eval(sprintf("k%d=vpa(k(l));",l)); 
    eval(sprintf("c%d=vpa(c(l+1));",l));
  endfor

  vABCD=double(eval(ABCD(1:(N+1),1:(N+1))));
  if max(max(abs(vABCD-[rA,rB;rC,rD])))>eps
    error("N=%d,max(max(abs(vABCD-[rA,rB;rC,rD])>eps))",N);
  endif

  vABCapDap=double(eval(ABCapDap));
  if max(max(abs(vABCapDap-[rA,rB;rCap,rDap])))>eps
    error("N=%d,max(max(abs(vABCapDap-[rA,rB;rCap,rDap])>eps))");
  endif
 
  eval(sprintf("clear %s",str_syms));

endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
