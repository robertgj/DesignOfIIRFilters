% p2n60_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Test case for estimate for time to decay to -60dB

test_common;

delete("p2n60_test.diary");
delete("p2n60_test.diary.tmp");
diary p2n60_test.diary.tmp

try
  n60=p2n60([1 1.1]);
catch
  printf("Caught problem in p2n60 : %s\n",lasterr());
end_try_catch

tol=1e-6;
fc=0.05;
[n,d]=ellip(3,1,40,2*fc);
n60=p2n60(d,tol)
y=filter(n,d,[1,zeros(1,1000)]);
nmax=local_max(abs(y));
n60min=nmax(min(find(abs(y(nmax(1:end))/y(nmax(1)))<0.001)))

fc=0.1;
[n,d]=butter(5,2*fc);
n60=p2n60(d)
y=filter(n,d,[1,zeros(1,1000)]);
nmax=local_max(abs(y));
n60min=nmax(min(find(abs(y(nmax(1:end))/y(nmax(1)))<0.001)))

fc=0.2;
[n,d]=cheby2(7,40,2*fc,'high');
n60=p2n60(d)
y=filter(n,d,[1,zeros(1,1000)]);
nmax=local_max(abs(y));
n60min=nmax(min(find(abs(y(nmax(1:end))/y(nmax(1)))<0.001)))

% Done
diary off
movefile p2n60_test.diary.tmp p2n60_test.diary;
