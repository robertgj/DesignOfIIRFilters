% bincoeff_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("bincoeff_test.diary");
unlink("bincoeff_test.diary.tmp");
diary bincoeff_test.diary.tmp

n=20;
zplane(roots(bincoeff(n,0:n)));
grid on;
title(sprintf("roots(bincoeff(%d,0:%d))",n,n));
print("bincoeff_test_zeros","-dpdflatex");
close

% Done
diary off
movefile bincoeff_test.diary.tmp bincoeff_test.diary;
