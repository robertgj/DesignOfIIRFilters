% mps_roots_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("mps_roots_test.diary");
delete("mps_roots_test.diary.tmp");
diary mps_roots_test.diary.tmp

% Load mpsolve and check for the presence of mps_roots()
pkg("load","mpsolve");
if exist("mps_roots") ~= 3
  error("mps_roots() not found!");
endif

% Binomial coefficients
N=6;
r=mps_roots(bincoeff(N,0:N),'u');
if 2*max(abs(r+1)) > eps
  error("r=mps_roots(bincoeff(6,0:6)) : max(abs(r+1)) > eps");
endif

N=20;
r=mps_roots(bincoeff(N,0:N),'u');
if 2*max(abs(r+1)) > eps
  error("r=mps_roots(bincoeff(20,0:20)) : max(abs(r+1)) > eps");
endif

% Roots of -1
N=6;
r=mps_roots([1,zeros(1,N-1),1],'u');
if 2*max(abs(abs(r)-1)) > eps
  error("r=mps_roots([1,zeros(1,5),1]) : max(abs(abs(r)-1)) > eps");
endif
if 8*max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N)) > eps
  error("r=mps_roots([1,zeros(1,5),1]) : angle failed! > eps");
endif

N=20;
r=mps_roots([1,zeros(1,N-1),1],'u');
if 2*max(abs(abs(r)-1)) > eps
  error("r=mps_roots([1,zeros(1,19),1]) : max(abs(abs(r)-1)) > eps");
endif
if 4*max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N)) > eps
  error("r=mps_roots([1,zeros(1,19),1]) : angle failed (%g)! > eps",
        8*max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))/eps);
endif

% Parallel allpass filter
D = [  1.0000000000,  -2.2443545374,   3.6828563678,  -3.7424738257, ... 
       2.9806683357,  -1.5676125569,   0.6649693575,  -0.1388429847, ... 
       0.0238205598,   0.0129159293,   0.0006995335 ]';
[x,U,V,M,Q]=tf2x(1,D);
R=1;
if any(abs(x((1+1):(1+U)))>=1) || ...
   any(abs(x((1+U+1):(1+U+V)))>=1) || ...
   any(abs(x((1+U+V+1):(1+U+V+(M/2))))>=1) || ...
   any(abs(x((1+U+V+M+1):(1+U+V+M+(Q/2))))>=1)
  error("roots >= 1");
endif
print_pole_zero(x,U,V,M,Q,R,"x","mps_roots_test_coef.m","%13.10f");

% Done
pkg("unload","mpsolve");
diary off
movefile mps_roots_test.diary.tmp mps_roots_test.diary;
