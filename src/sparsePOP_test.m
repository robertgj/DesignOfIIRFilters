% sparsePOP_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen
%
% The Bex5_2_5.gms example requires the symbolic package


test_common;

delete("sparsePOP_test.diary");
delete("sparsePOP_test.diary.tmp");
diary sparsePOP_test.diary.tmp

pkg load symbolic;

param.mex=0;
param.symbolicMath=1;

solvernames={'sedumi','sdpt3'};

prname={'example1', ...
        'Rosenbrock(40,-1)', ...
        'randomwithEQ(20,2,4,4,3201)', ...
        'genMAXCUT(8,1)', ...
        'Bex5_2_5.gms'};

fid=fopen("sparsePOP_test_xVect.out","w");

for l=1:length(solvernames)

  fprintf(fid,"\nUsing %s\n",solvernames{l});
  param.SDPsolver=solvernames{l};

  for k=1:length(prname)
    
    fprintf(fid,"\nSolving %s:\n",prname{k});
    try
      [newparam,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo]= ...
        sparsePOP(prname{k},param);
    catch
      err=lasterror();
      warning("\nCaught exception for %s!\n",prname{k});
      for e=1:length(err.stack)
        warning("Called %s at line %d\n",err.stack(e).name,err.stack(e).line);
      endfor
      error(err.message);
    end_try_catch
   
    if strcmp(param.SDPsolver,'sedumi')
      fprintf(fid,"SDPsolverInfo.numerr=%d\n",SDPsolverInfo.numerr);
    else
      fprintf(fid,"SDPsolverInfo.termcode=%d\n",SDPsolverInfo.termcode);
    endif
    fprintf(fid,"SDPobjValue=%10.6f\n",SDPobjValue);
    fprintf(fid,"POP.xVect=\n",k);fprintf(fid," %10.6f \n", POP.xVect);
    printf("\n");
    
  endfor
endfor

fclose(fid);

% Done
diary off
movefile sparsePOP_test.diary.tmp sparsePOP_test.diary;
