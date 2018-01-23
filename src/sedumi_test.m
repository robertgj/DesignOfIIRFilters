% sedumi_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("sedumi_test.diary");
unlink("sedumi_test.diary.tmp");
diary sedumi_test.diary.tmp

format short e

% Build SeDuMi oct files (add '-address_sanitize' for sanitizer)
install_sedumi('-rebuild');
%
% Run some examples
fhandle=fopen("test.results","wt");
%
exname="nb.mat";
load(exname);
[x,y,info]=sedumi(At,b,c,K)
fprintf(fhandle,"For %s : x'*c=%11.8f,y'*b=%11.8f\n",exname,x'*c,y'*b);
%
exname="arch0.mat";
load(exname);
[x,y,info]=sedumi(At,b,c,K)
fprintf(fhandle,"For %s : x'*c=%11.8f,y'*b=%11.8f\n",exname,x'*c,y'*b);
%
fclose(fhandle);

% Done
diary off
movefile sedumi_test.diary.tmp sedumi_test.diary;
