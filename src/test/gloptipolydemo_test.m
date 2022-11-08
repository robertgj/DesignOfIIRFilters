% gloptipolydemo_test.m
% Copyright (C) 2022 Robert G. Jenssen
% See:
% [1] "GloptiPoly 3 - moments, optimization and semidefinite programming",
% D. Henrion, J. B. Lasserre and Johan Lofberg,
% https://arxiv.org/pdf/0709.2559.pdf

test_common;

delete("gloptipolydemo_test.diary");
delete("gloptipolydemo_test.diary.tmp");
diary gloptipolydemo_test.diary.tmp

%{
% Notes on debugging:
%
% 1. Change options with:
        mset("verbose",true,"ranktol", 1e-8,"testol",1e-8,"pivotol",1e-8)
%
% 2. Set a breakpoint with:
        keyboard
%    or:
        dbstop("@msdp/msol")
%
% 3. The order of the solutions varies and each value varies
     within the tolerance.
%
% 4. @meas/mext.m makes a random combination of matrixes and then
%    calls a custom version of the builtin ordschur() called orderschur().
%    That function has a fixed tolerance of 1e-8 for deciding on Givens
%    rotations.
%}

pause("off");
gloptipolydemo

if x(1,1,1) > x(1,1,2)
  xa=double(x(1,:,1))
  xb=double(x(1,:,2))
else
  xa=double(x(1,:,2))
  xb=double(x(1,:,1))
endif

fhandle=fopen("test.results","wt");

fprintf(fhandle,"gloptipoly3 version %s\n",gloptipolyversion);
fprintf(fhandle,"status=%d\n",status);
fprintf(fhandle,"obj=%d\n",obj);
fprintf(fhandle,"xa=[%7.4f %7.4f]\n",xa(1), xa(2));
fprintf(fhandle,"xb=[%7.4f %7.4f]\n",xb(1), xb(2));

fclose(fhandle);

% Done
diary off
movefile gloptipolydemo_test.diary.tmp gloptipolydemo_test.diary;
