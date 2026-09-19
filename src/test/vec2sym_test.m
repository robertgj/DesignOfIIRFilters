% vec2sym_test.m

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="vec2sym_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

try
  vec2sym([],0);
catch
  warning("vec2sym([],0)")
end_try_catch

try
  vec2sym([],1);
catch
  warning("vec2sym([],1)")
end_try_catch

try
  S=vec2sym([],0);
  if ~isempty(S)
    error("~isempty(S)");
  endif
catch
  warning("S=vec2sym([],0)")
end_try_catch

try
  S=vec2sym([],1);
catch
  warning("S=vec2sym([],1)")
end_try_catch

try
  S=vec2sym([1],0);
catch
  warning("S=vec2sym([1],0)")
end_try_catch
  
try
  S=vec2sym([10],1);
catch
  warning("S=vec2sym([100],1)")
end_try_catch
  
try
  S=vec2sym(1:10,1);
  if ~issymmetric(S)
    error("~issymmetric(S)");
  endif
catch
  warning("S=vec2sym(v,1)")
end_try_catch

try
  S=vec2sym(1:10,4);
  if ~issymmetric(S)
    error("~issymmetric(S)");
  endif
catch
  warning("S=vec2sym(v,4)")
end_try_catch
  
try
  S=vec2sym(1:15,5);
  if ~issymmetric(S)
    error("~issymmetric(S)");
  endif
catch
  warning("S=vec2sym(v,5)")
end_try_catch
  
try
  S=vec2sym(1:55,10);
  if ~issymmetric(S)
    error("~issymmetric(S)");
  endif
  SS=  [  1    2    4    7   11   16   22   29   37   46 ;
          2    3    5    8   12   17   23   30   38   47 ;
          4    5    6    9   13   18   24   31   39   48 ;
          7    8    9   10   14   19   25   32   40   49 ;
         11   12   13   14   15   20   26   33   41   50 ;
         16   17   18   19   20   21   27   34   42   51 ;
         22   23   24   25   26   27   28   35   43   52 ;
         29   30   31   32   33   34   35   36   44   53 ;
         37   38   39   40   41   42   43   44   45   54 ;
         46   47   48   49   50   51   52   53   54   55 ];
  if any(vec(S-SS))
    error("any(vec(S-SS))");
  endif
catch
  warning("S=vec2sym(v,10)")
end_try_catch
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"),"f");
