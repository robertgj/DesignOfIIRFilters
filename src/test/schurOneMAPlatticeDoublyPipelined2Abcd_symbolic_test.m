% schurOneMAPlatticeDoublyPipelined2Abcd_symbolic_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% Create a symbolic description of the doubly pipelined Schur one-multiplier
% all-pass filter

test_common;

pkg load symbolic

strf="schurOneMAPlatticeDoublyPipelined2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

for N=6:7,

  %
  % Design a prototype lattice filter with no scaling by p or epsilon
  %
  dBas=40;fc=0.1;
  [n,d]=cheby2(N,dBas,2*fc);
  [k,~,~,~]=tf2schurOneMlattice(n,d);
  
  %
  % Build a state variable description of the allpass filter
  %
  [rapA,rapB,rapC,rapD,apA0,apAl] = schurOneMAPlatticeDoublyPipelined2Abcd(k); 
  rapAbcd=[[rapA,rapB];[rapC,rapD]];
  
  %
  % Define symbols
  %
  str_syms="";
  for l=1:N
    str_syms=strcat(str_syms,sprintf(" k%d ",l));
  endfor
  eval(sprintf("syms %s",str_syms));
  for l=1:N,
    assume(sprintf("k%d",l),"real");
  endfor

  apA=apA0;
  for l=1:N,
    apA=apA+eval(sprintf("k%d*apAl{l}",l));
  endfor
  for l=1:N,
    eval(sprintf("k%d=vpa(k(l));",l)); 
  endfor
  vapA=eval(apA);
  vapAbcd=[vapA,rapB;rapC,rapD];
  
  %
  % Sanity check
  %
  if any(any(vapAbcd~=rapAbcd))
    error("N=%d,any(any(vapAbcd~=rapAbcd))",N);
  endif
 
endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
