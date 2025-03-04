% bincoeff_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="bincoeff_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

n=20;
zplane(roots(bincoeff(n,0:n)));
grid on;
title(sprintf("roots(bincoeff(%d,0:%d))",n,n));
print(strcat(strf,"_roots"),"-dpdflatex");
close
zplane(qzsolve(bincoeff(n,0:n)));
grid on;
axis([-1.1 -0.9 -0.1 0.1])
title(sprintf("qzsolve(bincoeff(%d,0:%d))",n,n));
print(strcat(strf,"_qzsolve"),"-dpdflatex");
close

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
