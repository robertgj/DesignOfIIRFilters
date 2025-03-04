% qzsolve_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("qzsolve_test.diary");
delete("qzsolve_test.diary.tmp");
diary qzsolve_test.diary.tmp

check_octave_file("qzsolve");

% Sanity checks
r=qzsolve([]);
if ~isempty(r)
  error("Expected isempty(r) for []");
endif
r=qzsolve(1);
if ~isempty(r)
  error("Expected isempty(r) for 1");
endif
r=qzsolve([1]);
if ~isempty(r)
  error("Expected isempty(r) for [1]");
endif
try
  r=qzsolve([1 2*j 1]);
  error("qzsolve did not catch complex coefficients");
catch
  printf("qzsolve did catch complex coefficients\n");
end_try_catch

% Check leading(z^n) and trailing(z^1,1) zeros
r=qzsolve([bincoeff(6,0:6),0]);
if max(abs(r+[0;ones(6,1)])) > 1e-5
  error("r=qzsolve([bincoeff(6,0:6),0] :  max(abs(r+[0;ones(6,1)])) > 1e-5")
endif
r=qzsolve([0,bincoeff(6,0:6)]);
if max(abs(r+ones(6,1))) > 1e-5
  error("r=qzsolve([0,bincoeff(6,0:6)] :  max(abs(r+[ones(6,1);0])) > 1e-5")
endif
r=qzsolve([0,bincoeff(6,0:6),0]);
if max(abs(r+[0;ones(6,1)])) > 1e-5
  error("r=qzsolve([0,bincoeff(6,0:6),0] :  max(abs(r+[0;ones(6,1)])) > 1e-5")
endif

% Check sorting
p1=conv(conv([1,1-i],[1,1+i]),conv([1,-2-2*i],[1,-2+2*i]));
r1=qroots(p1);
rr1=roots(p1);
if max(abs(r1-rr1))>10*eps
  error("max(abs(r1-rr1))>10*eps");
endif
p2=conv(p1,conv(conv([1,-1-2*i],[1,-1+2*i]),conv([1,-3-2*i],[1,-3+2*i])));
r2=qroots(p2);
rr2=roots(p2);
if max(abs(r2-rr2))>100*eps
  error("max(abs(r2-rr2))>100*eps");
endif

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
if max(abs(rr+1)) > 0.4032
  error("rr=roots(bincoeff(20,0:20)) : max(abs(rr+1)) > 0.4032");
endif
r=qzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 4.51e-2
  error("r=qzsolve(bincoeff(20,0:20)) : max(abs(r+1)) > 4.51e-2");
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
if max(abs(abs(rr)-1)) > 6*eps
  error("rr=roots([1,zeros(1,19),1]) : max(abs(abs(rr)-1)) > 6*eps");
endif
if max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))>2*eps
  error("rr=roots([1,zeros(1,19),1]) : angle failed! > 2*eps");
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
