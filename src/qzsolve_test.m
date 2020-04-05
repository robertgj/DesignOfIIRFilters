% qzsolve_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("qzsolve_test.diary");
delete("qzsolve_test.diary.tmp");
diary qzsolve_test.diary.tmp

check_octave_file("qzsolve");

% Binomial coefficients
N=6;
rr=roots(bincoeff(N,0:N));
if max(abs(rr+1)) > 3.56e-3
  error("rr=roots(bincoeff(6,0:6)) : max(abs(rr+1)) > 3.56e-3");
endif
r=qzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 5.536e-6
  error("r=qzsolve(bincoeff(6,0:6)) : max(abs(r+1)) > 5.536e-6");
endif

N=20;
rr=roots(bincoeff(N,0:N));
if max(abs(rr+1)) > 0.3934
  error("rr=roots(bincoeff(20,0:20)) : max(abs(rr+1)) > 0.3934");
endif
r=qzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 4.46e-2
  error("r=qzsolve(bincoeff(20,0:20)) : max(abs(r+1)) > 4.46e-2");
endif

% Roots of -1
N=6;
rr=roots([1,zeros(1,N-1),1]);
if max(abs(abs(rr)-1)) > 5.5*eps
  error("rr=roots([1,zeros(1,5),1]) : max(abs(abs(rr)-1)) > 5.5*eps");
endif
if max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("rr=roots([1,zeros(1,5),1]) : angle failed! > eps");
endif
r=qzsolve([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > eps
  error("r=qzsolve([1,zeros(1,5),1]) : max(abs(abs(r)-1)) > eps");
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("r=qzsolve([1,zeros(1,5),1]) : angle failed! > eps");
endif

N=20;
rr=roots([1,zeros(1,N-1),1]);
if max(abs(abs(rr)-1)) > 4*eps
  error("rr=roots([1,zeros(1,19),1]) : max(abs(abs(rr)-1)) > 4*eps");
endif
if max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("rr=roots([1,zeros(1,19),1]) : angle failed! > eps");
endif
r=qzsolve([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > eps
  error("r=qzsolve([1,zeros(1,19),1]) : max(abs(abs(r)-1)) > eps");
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("r=qzsolve([1,zeros(1,19),1]) : angle failed! > eps");
endif

% Parallel allpass filter
D = [  1.0000000000,  -2.2443545374,   3.6828563678,  -3.7424738257, ... 
       2.9806683357,  -1.5676125569,   0.6649693575,  -0.1388429847, ... 
       0.0238205598,   0.0129159293,   0.0006995335 ]';
if exist("mps_roots") == 3
  error("mps_roots() found!");
endif
[x,U,V,M,Q]=tf2x(1,D);
R=1;
if any(abs(x((1+1):(1+U)))>=1) || ...
   any(abs(x((1+U+1):(1+U+V)))>=1) || ...
   any(abs(x((1+U+V+1):(1+U+V+(M/2))))>=1) || ...
   any(abs(x((1+U+V+M+1):(1+U+V+M+(Q/2))))>=1)
  error("roots >= 1");
endif
print_pole_zero(x,U,V,M,Q,R,"x","qzsolve_test_coef.m","%13.10f");
  
% Done
diary off
movefile qzsolve_test.diary.tmp qzsolve_test.diary;
