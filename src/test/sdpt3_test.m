% sdpt3_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("sdpt3_test.diary");
delete("sdpt3_test.diary.tmp");
diary sdpt3_test.diary.tmp

% Run some examples
fhandle=fopen("test.results","wt");

% Example data with block diagonal structure.  
C{1} = sparse([ 0 0; 0 0]); 
C{2} = sparse([ 1 2 1;2 1 0; 1 0 1]);
At{1,1} = sparse([ 1 0; 0 1]); 
At{1,2} = sparse([ 1 0; 0 0]); 
At{1,3} = sparse([ 0 1; 1 0]); 
At{1,4} = sparse([ 0 0; 0 1]); 
At{2,1} = sparse([ 0 0 0; 0 1 0; 0 0 1]); 
At{2,2} = sparse([ 1 0 1; 0 0 0; 1 0 1]);
At{2,3} = sparse([ 0 2 0; 2 0 -1; 0 -1 0]); 
At{2,4} = sparse([ 0 0 0; 0 5 0; 0 0 5]); 
b = [1; 1; 1; 1];
blk{1,1} = 's'; blk{1,2} = [2]; 
blk{2,1} = 's'; blk{2,2} = [3]; 
[obj,X,y,Z,info,runhist] = sdpt3(blk,At,C,b);
fprintf(fhandle,"For %s : termcode=%d, b'*y=%9.5f, gap=%8.3g\n",
        "block diagonal",info.termcode,b'*y,info.gap);

%{
This fails with the message:
error: reshape: can't reshape 62901x1 array to 5x12580 array
error: called from
    read_sdpa at line 133 column 3
    src/test/sdpt3_test.m at line 34 column 14

% Example in SDPA format
exname="theta3.dat-s";
[blk,At,C,b] = read_sdpa(exname); 
[obj,X,y,Z,info,runhist] = sdpt3(blk,At,C,b);
fprintf(fhandle,"For %s : termcode=%d, b'*y=%9.5f, gap=%8.3g\n",
        exname,info.termcode,b'*y,info.gap);
%}

% Example in SeDuMi format
exname="hamming_7_5_6.mat";
[blk,At,C,b] = read_sedumi(exname); 
[obj,X,y,Z,info,runhist] = sdpt3(blk,At,C,b);
fprintf(fhandle,"For %s : termcode=%d, b'*y=%9.5f, gap=%8.3g\n",
        exname,info.termcode,b'*y,info.gap);

%
fclose(fhandle);

% Done
diary off
movefile sdpt3_test.diary.tmp sdpt3_test.diary;
