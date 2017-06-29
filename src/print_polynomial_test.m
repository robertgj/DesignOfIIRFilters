% print_polynomial_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("print_polynomial_test.diary");
unlink("print_polynomial_test.diary.tmp");
diary print_polynomial_test.diary.tmp

[N1,D1]=butter(8,0.1*2);

print_polynomial(N1,"N1");
print_polynomial(N1,"N1","print_polynomial_test.coef.1");
print_polynomial(N1,"N1","print_polynomial_test.coef.2","%12.5e");

diary off
movefile print_polynomial_test.diary.tmp print_polynomial_test.diary;
