% schurOneMlattice2Abcd_symbolic_test.m
% Copyright (C) 2024-2026 Robert G. Jenssen
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
% Design a prototype lattice filter
%

tol_eps=20;dBap=0.1;dBas=40;fc=0.1;

for N=1:7,
  
  [n,d]=cheby2(N,dBas,2*fc);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [rA,rB,rC,rD,rCap,rDap] = schurOneMlattice2Abcd(k,epsilon,p,c);
  rABCapDapCD=[rA,rB;rCap,rDap;rC,rD];

  %
  % Define symbols
  %
  str_syms="c0 ";
  for l=1:N
    str_syms=strcat(str_syms,sprintf(" k%d E%d p%d c%d",l,l,l,l));
  endfor
  eval(sprintf("syms %s",str_syms));
  for l=1:N,
    assume(sprintf("k%d",l),"real"); 
    % BUG : octave/symbolic/SymPy (???) thinks e%d is 2.7183..., not a symbol
    assume(sprintf("E%d",l),"integer");
    assume(sprintf("p%d",l),"real");
    assume(sprintf("c%d",l),"real");
  endfor
  for l=1:N
    eval(sprintf("P%d=p%d;",l,l));
  endfor
  eval(sprintf("P%d=vpa(1);",N+1));
  
  
  % Modules 1 to N
  M0=[ [P1,zeros(1,N)]; ...
       [zeros(N,1),eye(N)] ];
  for l=1:N,
    eval(sprintf(["rM%d=[ [-k%d/P%d,    (1+(k%d*E%d))*P%d/P%d]; ...\n", ...
                  "       [1-(k%d*E%d), k%d*P%d] ];"], ...
                 l,l,l,l,l,l+1,l, l,l,l,l+1));
    eval(sprintf(["M%d=[[eye(%d-1),zeros(%d-1,2),zeros(%d-1,N-%d);]; ...\n", ...
                  "     [zeros(2,%d-1),rM%d,zeros(2,N-%d)]; ...\n", ...
                  "     [zeros(N-%d,%d-1),zeros(N-%d,2),eye(N-%d)]];"],
                 l,l,l,l,l, l,l,l, l,l,l,l));
  endfor
 
  ABCapDap=M0;
  for l=1:N
    eval(sprintf("ABCapDap=M%d*ABCapDap;",l));
  endfor
  
  for l=1:N
    eval(sprintf("C(%d)=c%d*P%d;",l,l-1,l));
  endfor
  eval(sprintf("D=c%d;",N));

  ABCapDapCD=[ABCapDap;[C,D]];
  
  % Output
  fhandle=fopen(sprintf("%s_N_%d.tex",strf,N),"wt");
  fprintf(fhandle,"\\\\ $%s$ \\\\",latex(ABCapDapCD));
  fclose(fhandle);

  %
  % Sanity checks.
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
  if max(max(abs(vABCapDapCD-rABCapDapCD)))>eps
    error("N=%d,max(max(abs(vABCapDapCD-rABCapDapCD)>eps))",N);
  endif
 
  eval(sprintf("clear %s",str_syms));

endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
