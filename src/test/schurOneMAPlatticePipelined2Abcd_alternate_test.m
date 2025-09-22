% schurOneMAPlatticePipelined2Abcd_alternate_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Test cases for the pipelined Schur one-multiplier all-pass lattice filter
% shown in the algorithm in DesignOfIIRFilters.tex

test_common;

strf="schurOneMAPlatticePipelined2Abcd_alternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Various 
fc=0.05;
tol=200*eps;
for N=1:11
  printf("\nTesting N=%d\n",N);
  [n,d]=butter(N,2*fc);
  [k,epsilon,~,~]=tf2schurOneMlattice(n,d);

  % Filter transfer function with epsilon
  try
    [Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd_alternate(k,epsilon);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch

  [nap,dap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(flipud(nap(:))-dap(:))) > tol
    error("max(abs(flipud(nap(:))-dap(:))) > tol");
  endif 
  if max(abs(dap-d)) > tol
    error("max(abs(dap-d)) > tol");
  endif

  % Filter transfer function without epsilon
  try
    [Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd_alternate(k);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch

  [nap,dap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(flipud(nap(:))-dap(:))) > tol
    error("max(abs(flipud(nap(:))-dap(:))) > tol");
  endif 
  if max(abs(dap-d)) > tol
    error("max(abs(dap-d)) > tol");
  endif
  
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
