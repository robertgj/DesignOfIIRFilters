% sparsePOP_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("sparsePOP_test.diary");
unlink("sparsePOP_test.diary.tmp");
diary sparsePOP_test.diary.tmp

compileSparsePOP;

param.relaxOrder=3;
param.mex=1;
prname={'example1', 'Rosenbrock(40,-1)'}
fid=fopen("sparsePOP_test_xVect.out","w");
for k=1:length(prname)
  [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo]= ...
    sparsePOP(prname{k},param);
  fprintf(fid,"\nk=%d\nPOP.xVect=\n",k);fprintf(fid," %10.6f \n", POP.xVect);
endfor
fclose(fid);

% Done
diary off
movefile sparsePOP_test.diary.tmp sparsePOP_test.diary;
