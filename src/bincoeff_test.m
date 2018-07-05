% bincoeff_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("bincoeff_test.diary");
unlink("bincoeff_test.diary.tmp");
diary bincoeff_test.diary.tmp

n=20;
zplane(roots(bincoeff(n,0:n)));
grid on;
title(sprintf("roots(bincoeff(%d,0:%d))",n,n));
print("bincoeff_test_roots","-dpdflatex");
close
zplane(qzsolve(bincoeff(n,0:n)));
grid on;
axis([-1.1 -0.9 -0.1 0.1])
title(sprintf("qzsolve(bincoeff(%d,0:%d))",n,n));
print("bincoeff_test_qzsolve","-dpdflatex");
close

% Done
diary off
movefile bincoeff_test.diary.tmp bincoeff_test.diary;
