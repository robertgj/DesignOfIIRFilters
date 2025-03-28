% schurOneMlatticeDoublyPipelined2Abcd_symbolic_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Create symbolic descriptions of doubly pipelined Schur one-multiplier
% all-pass filters. Note that c0 is shifted to "x5=c0*x3+c1*x7".

test_common;

pkg load symbolic

strf="schurOneMlatticeDoublyPipelined2Abcd_symbolic_test";
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

  % Modules 1 to Nk have Ns states.
  Ns=(3*N)+2;
  M0=[[0,1,zeros(1,Ns-1)];[1,zeros(1,Ns)];eye(Ns+1)];
  for l=1:N,
    if l==1,
      c0str="c0";
    else
      c0str="1";
    endif
    eval(sprintf(["rM=...\n", ...
 "      [[ 0,       -k%d,0,0,0,(1+E%d*k%d)];...\n", ...
 "       [%s,          0,0,0,0,        c%d];...\n", ...
 "       [ 0,(1-E%d*k%d),0,0,0,        k%d]];\n"],l,l,l,c0str,l,l,l,l));
    eval(sprintf(["M%d=...\n", ...
 "      [[eye((3*l)-2),zeros((3*l)-2,(3*(N-l))+7)];...\n", ...
 "       [zeros(3,(3*l)-2),rM,zeros(3,(3*(N-l))+1)];...\n", ...
 "       [zeros((3*(N-l))+4,(3*l)+1),eye((3*(N-l))+4)]];"],l));
  endfor
  
  % Final module
  eval(sprintf(["M%d=[eye(Ns-1),zeros(Ns-1,4);...\n", ...
 "                     zeros(3,Ns-1),[0,0,0,1;1,0,0,0;0,1,0,0]];\n"],N+1));
  
  Abcd=M0;
  for l=1:N+1
    eval(sprintf("Abcd=M%d*Abcd;",l));
  endfor
  
  %
  % Sanity checks.
  %
  
  % Conversion of original transfer functions. 
  [rA,rB,rC,rD,rAap,rBap,rCap,rDap] = ...
    schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c);
  
  % Evaluate symbolic version
  c0=vpa(c(1));
  for l=1:N,
    eval(sprintf("E%d=vpa(epsilon(l));",l)); 
    eval(sprintf("k%d=vpa(k(l));",l)); 
    eval(sprintf("c%d=vpa(c(l+1));",l));
  endfor

  vAbcd=double(eval(Abcd(1:(Ns+1),1:(Ns+1))));
  if max(max(abs(vAbcd-[rA,rB;rC,rD])))>eps
    error("N=%d,max(max(abs(vAbcd-[rA,rB;rC,rD])>eps))",N);
  endif

  v=setdiff(1:Ns,3*(1:N),"sorted");
  apAbcd=[[Abcd(v,v),Abcd(v,Ns+1)]; ...
          [Abcd(Ns+2,v),Abcd(Ns+2,Ns+1)]];
  vapAbcd=double(eval(apAbcd));
  if max(max(abs(vapAbcd-[rAap,rBap;rCap,rDap])))>eps
    error("N=%d,max(max(abs(vapAbcd-[rAap,rBap;rCap,rDap])>eps))");
  endif
 
  eval(sprintf("clear %s",str_syms));

endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
