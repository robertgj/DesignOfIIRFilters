% sdpt3_maxcut_test.m
% The existing sqlpdemo.m fails for maxcut with feas=1. Check the fix.
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("sdpt3_maxcut_test.diary");
delete("sdpt3_maxcut_test.diary.tmp");
diary sdpt3_maxcut_test.diary.tmp

install_sdpt3;

%%******************************************************
%% graph: generate random adjacency matrix.
%%      
%%  B = graph(n,prob);
%%
%%  see maxcut.m 
%%
%% SDPT3: version 3.0 
%% Copyright (c) 1997 by
%% K.C. Toh, M.J. Todd, R.H. Tutuncu
%% Last modified: 2 Feb 01
%%******************************************************

function B = graph(n,prob);

  B = zeros(n,n);
  if nargin <= 1; prob = 0.5; end;
  for i = 1:n
    for j = i+1:n 
      r = rand(1); 
      if (r < prob); B(i,j) = 1; B(j,i) = 1;  end;
    end;
  end;
endfunction
%%======================================================

% Initialise the rand generator used by graph.m for consistent results
rand ("state", 0xDEADBEEF)
N = 10;
B = graph(N);

for feas=0:1
  [blk,At,C,b,X0,y0,Z0] = maxcut(B,feas,1);
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
movefile sdpt3_maxcut_test.diary.tmp sdpt3_maxcut_test.diary;
