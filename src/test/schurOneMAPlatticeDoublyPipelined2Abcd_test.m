% schurOneMAPlatticeDoublyPipelined2Abcd_test.m
% Copyright (C) 2022-2026 Robert G. Jenssen
%
% Create a state variable description of the doubly pipelined Schur
% one-multiplier all-pass filter

test_common;

strf="schurOneMAPlatticeDoublyPipelined2Abcd_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

for N=1:7,

  %
  % Design a prototype lattice filter with no scaling by p or epsilon
  %
  dBas=40;fc=0.1;
  [n,d]=cheby2(N,dBas,2*fc);
  [k,~,~,~]=tf2schurOneMlattice(n,d);
  [~,~,~,~,rapA,rapB,rapC,rapD]=schurOneMlatticeDoublyPipelined2Abcd(k);
  rapAbcd=[rapA,rapB;rapC,rapD];
  
  %
  % Build a state variable description of the allpass filter
  %
  [vapA,vapB,vapC,vapD,vapA0,vapAl] = schurOneMAPlatticeDoublyPipelined2Abcd(k); 
  vapAbcd=[[vapA,vapB];[vapC,vapD]];
  vapA0l=vapA0;
  for l=1:length(vapAl),
    vapA0l=vapA0l+(k(l)*vapAl{l});
  endfor
  [~,dap]=Abcd2tf(vapA,vapB,vapC,vapD);
  dap=dap(1:2:((2*N)+1));
  
  %
  % Sanity checks
  %
  if any(any(vapAbcd~=rapAbcd))
    error("N=%d,any(any(vapAbcd~=rapAbcd))",N);
  endif
  if any(any(vapA0l~=rapA))
    error("N=%d,any(any(vapA0l~=rapA))",N);
  endif
  if any(d~=dap)
    error("N=%d,any(d~=dap)(%g*eps) > eps",N,max(abs(d-dap))/eps);
  endif

endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
