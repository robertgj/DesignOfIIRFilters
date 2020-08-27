% sdpt3_maxcut_test.m.m
% The existing sqlpdemo.m fails for maxcut with feas=1. Check the fix.
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("sdpt3_maxcut_test.m.diary");
delete("sdpt3_maxcut_test.m.diary.tmp");
diary sdpt3_maxcut_test.m.diary.tmp

install_sdpt3;

for feas=0:1
  N = 10;
  B = graph(N);
  [blk,At,C,b,X0,y0,Z0] = maxcut(B,1);
  for vers = [1 2];
    printf('Running maxcut with vers=%d, feas=%d\n',vers,feas);
    OPTIONS.vers = vers;
    try
      [obj,X,y,Z,infoall,runhist] = sqlp(blk,At,C,b,OPTIONS,X0,y0,Z0); 
    catch
      warning("\nCaught exception %s\n",lasterr);
    end_try_catch
  endfor
endfor

% Done
diary off
movefile sdpt3_maxcut_test.m.diary.tmp sdpt3_maxcut_test.m.diary;
