% schurOneMAPlatticeDoublyPipelined2Abcd_symbolic_test .m
% Copyright (C) 2022-2026 Robert G. Jenssen
%
% Create a symbolic description of the doubly pipelined Schur one-multiplier
% all-pass filter

test_common;

pkg load symbolic

strf="schurOneMAPlatticeDoublyPipelined2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

for N=1:5,

  %
  % Design a prototype lattice filter with no scaling by p or epsilon
  %
  dBas=40;fc=0.1;
  [~,d]=cheby2(N,dBas,2*fc);
  [k,~,~,~]=tf2schurOneMlattice(flipud(d(:)),d(:));
  
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
 
  %
  % Repeat with permuted version of the state transition matrix, apA
  %
  eval(sprintf("syms %s",str_syms));
  for l=1:N,
    assume(sprintf("k%d",l),"real");
  endfor
  P=zeros(size(apA));
  for l=1:2:rows(apA),
    P(l:(l+1),l:(l+1))=[[0,1];[1,0]];
  endfor

  apA=apA0;
  for l=1:N,
    apA=apA+eval(sprintf("k%d*apAl{l}",l));
  endfor
  for l=1:N,
    eval(sprintf("k%d=vpa(k(l));",l)); 
  endfor
  vapA=eval(apA);
  [~,dP]=Abcd2tf(P*vapA*P,rapB,rapC,rapD);
  dP=dP(1:2:((2*N)+1));

  % Alternatively
  apA=apA0*P;
  for l=1:N,
    apA=apA+eval(sprintf("k%d*apAl{l}*P",l));
  endfor
  for l=1:N,
    eval(sprintf("k%d=vpa(k(l));",l)); 
  endfor
  vapA=eval(apA);
  [~,dP]=Abcd2tf(P*vapA,rapB,rapC,rapD);
  dP=dP(1:2:((2*N)+1));
  
  %
  % Sanity check
  %
  if any(d~=dP)
    error("N=%d,any(d~=dP)(%g*eps) > 2*eps",N,max(abs(d-dP))/eps);
  endif
  
endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
