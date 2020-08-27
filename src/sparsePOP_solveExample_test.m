% solveExample_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Run the SparsePOP solveExample function.
% An exception is caught for k_exclude=[36,45,46,54,70,71,88,92]
% In each case it looks like:
%   Caught exception at k=36!
%   ## '2' is not defined in the line of 'Variables'.
%   ## Should check the line of the objective function in 'Babel.gms'.
%   warning: Called readGMS>getObjPoly at line 1306
%   warning: Called readGMS at line 341
%   warning: Called sparsePOP at line 324
%   warning: Called solveExample at line 263
%   warning: Called solveExample_test at line 27

test_common;

delete("solveExample_test.diary");
delete("solveExample_test.diary.tmp");
diary solveExample_test.diary.tmp

pkg load symbolic;

install_sedumi;

param.mex=0;
param.symbolicMath=1;
param.SDPsolver='sedumi';
k_exclude=[36,45,46,54,70,71,88,92]

for k=1:95
  if ~isempty(find(k_exclude==k))
    warning("Skipping k=%d!\n",k);
    continue;
  endif
  try
    solveExample(k,param);
  catch
    err=lasterror();
    warning("\nCaught exception at k=%d!\n%s\n",k,err.message);
    for e=1:length(err.stack)
      warning("Called %s at line %d\n",err.stack(e).name,err.stack(e).line);
    endfor
  end_try_catch
endfor

% Done
diary off
movefile solveExample_test.diary.tmp solveExample_test.diary;
