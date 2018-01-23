% print_polynomial_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("print_polynomial_test.diary");
unlink("print_polynomial_test.diary.tmp");
diary print_polynomial_test.diary.tmp

[N1,D1]=butter(8,0.1*2);

print_polynomial(N1,"N1");
print_polynomial(N1,"N1","print_polynomial_test.coef.1");
print_polynomial(N1,"N1","print_polynomial_test.coef.2","%12.5e");

X=-0.5:0.1:0.5;
print_polynomial(X,"X",10);
print_polynomial(X,"X","print_polynomial_test.coef.3");
print_polynomial(X,"X","print_polynomial_test.coef.4",10);
try
  print_polynomial(X,"X",1);
catch
  printf("FAIL print_polynomial(X,\"X\",1);\n");
end_try_catch
try
  print_polynomial(X,"X","print_polynomial_test.coef.5",1);
catch
  printf("FAIL print_polynomial(X,\"X\",\"print_polynomial_test.coef.5\",1);\n");
end_try_catch

diary off
movefile print_polynomial_test.diary.tmp print_polynomial_test.diary;
