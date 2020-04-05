% fixResultNaN_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("fixResultNaN_test.diary");
delete("fixResultNaN_test.diary.tmp");
diary fixResultNaN_test.diary.tmp


X=NaN
X=fixResultNaN(X)

X=[1 NaN 2]
X=fixResultNaN(X)

X=[1 NaN 2; NaN 3 4]
X=fixResultNaN(X)

X=ones(3,3,3);
X(1,1,1)=NaN;
X(3,2,1)=NaN;
X(1,2,3)=NaN;
X
X=fixResultNaN(X)

diary off
movefile fixResultNaN_test.diary.tmp fixResultNaN_test.diary;
