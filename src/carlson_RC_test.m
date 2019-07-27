% carlson_RC_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("carlson_RC_test.diary");
unlink("carlson_RC_test.diary.tmp");
diary carlson_RC_test.diary.tmp

tol=4*eps;

% Compare with example in Section 3 in "Computing Elliptic Integrals
% by Duplication", B.C. Carlson, Numerische Mathematik, 33, pp. 1-16,(1979)
if abs(pi-(2*carlson_RC(0,1,tol)))>tol
  error("abs(pi-(2*carlson_RC(0,1,tol)))>tol");
endif
if abs(pi-(4*carlson_RC(1,2,tol)))>tol
  error("abs(pi-(4*carlson_RC(1,2,tol)))>tol");
endif
if abs(pi-(6*carlson_RC(3,4,tol)))>tol
  error("abs(pi-(6*carlson_RC(3,4,tol)))>tol");
endif
if abs(log(2)-(2*carlson_RC(9,8)))>tol
  error("abs(log(2)-(2*carlson_RC(9,8)))>tol");
endif
if abs(log(2)-(3*carlson_RC(25,16)))>tol
  error("abs(log(2)-(2*carlson_RC(25,16)))>tol");
endif
if abs(log(10)-(18*carlson_RC(121,40)))>tol
  error("abs(log(10)-(2*carlson_RC(121,40)))>tol");
endif

% Compare with equations 4.9 etc in Section 4 in "Computing Elliptic Integrals
% by Duplication", B.C. Carlson, Numerische Mathematik, 33, pp. 1-16,(1979)

% ln
x=0.1;
if abs((log(x)/(x-1))-carlson_RC(((1+x)/2)^2,x))>tol
  error("x=%f:abs((log(x)/(x-1))-carlson_RC(((1+x)/2)^2,x))>tol",x);
endif
x=0.9999;
if abs((log(x)/(x-1))-carlson_RC(((1+x)/2)^2,x))>tol
  error("x=%f:abs((log(x)/(x-1))-carlson_RC(((1+x)/2)^2,x))>tol",x);
endif

% arcsin
x=1/sqrt(2);
if abs((asin(x)/x)-carlson_RC(1-(x^2),1))>tol
  error("x=%f:abs((asin(x)/x)-carlson_RC(1-(x^2),1))>tol",x);
endif

% arcsinh
x=(e-(1/e))/2;
if abs((asinh(x)/x)-carlson_RC(1+(x^2),1))>tol
  error("x=%f:abs((asinh(x)/x)-carlson_RC(1+(x^2),1))>tol",x);
endif
x=2;
if abs((asinh(x)/x)-carlson_RC(1+(x^2),1))>tol
  error("x=%f:abs((asinh(x)/x)-carlson_RC(1+(x^2),1))>tol",x);
endif

% arccos
x=sqrt(3)/2;
if abs((acos(x)/sqrt(1-(x^2)))-carlson_RC(x^2,1))>tol
  error("x=%f:abs((acos(x)/sqrt(1-(x^2)))-carlson_RC(x^2,1))>tol",x);
endif

% arccosh
x=(e+(1/e))/2;
if abs((acosh(x)/sqrt((x^2)-1))-carlson_RC(x^2,1))>tol
  error("x=%f:abs((acosh(x)/sqrt((x^2)-1))-carlson_RC(x^2,1))>tol",x);
endif

% arctan
x=1;
if abs((atan(x)/x)-carlson_RC(1,1+(x^2)))>tol
  error("x=%f:abs((atan(x)/x)-carlson_RC(1,1+(x^2)))>tol",x);
endif
x=1-sqrt(2);
if abs((atan(x)/x)-carlson_RC(1,1+(x^2)))>tol
  error("x=%f:abs((atan(x)/x)-carlson_RC(1,1+(x^2)))>tol",x);
endif

% arctanh
x=-(e-(1/e))/(e+(1/e));
if abs((atanh(x)/x)-carlson_RC(1,1-(x^2)))>tol
  error("x=%f:abs((atanh(x)/x)-carlson_RC(1,1-(x^2)))>tol",x);
endif

% arccot
x=cot(pi/8);
if abs(acot(x)-carlson_RC(x^2,(x^2)+1))>tol
  error("x=%f:abs(acot(x)-carlson_RC(x^2,(x^2)+1))>tol",x);
endif

% arccoth
x=(e+(1/e))/(e-(1/e));
if abs(acoth(x)-carlson_RC(x^2,(x^2)-1))>tol
  error("x=%f:abs(acoth(x)-carlson_RC(x^2,(x^2)-1))>tol",x);
endif
x=2;
if abs(acoth(x)-carlson_RC(x^2,(x^2)-1))>tol
  error("x=%f:abs(acoth(x)-carlson_RC(x^2,(x^2)-1))>tol",x);
endif

% Done
diary off
movefile carlson_RC_test.diary.tmp carlson_RC_test.diary;
