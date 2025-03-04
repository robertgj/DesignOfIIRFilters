% sedumi_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("sedumi_test.diary");
delete("sedumi_test.diary.tmp");
diary sedumi_test.diary.tmp

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
%{
exname="control07.mat";
load(exname);
[x,y,info]=sedumi(At,b,c,K)
fprintf(fhandle,"For %s : x'*c=%11.8f,y'*b=%11.8f\n",exname,x'*c,y'*b);
%
exname="trto3.mat";
load(exname);
[x,y,info]=sedumi(At,b,c,K)
fprintf(fhandle,"For %s : x'*c=%11.8f,y'*b=%11.8f\n",exname,x'*c,y'*b);
%
exname="OH_2Pi_STO-6GN9r12g1T2.mat";
load(exname);
[x,y,info]=sedumi(At,b,c,K)
fprintf(fhandle,"For %s : x'*c=%11.8f,y'*b=%11.8f\n",exname,x'*c,y'*b);
%}
fclose(fhandle);

% Done
diary off
movefile sedumi_test.diary.tmp sedumi_test.diary;
