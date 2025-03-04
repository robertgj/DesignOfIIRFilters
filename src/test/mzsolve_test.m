% mzsolve_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="mzsolve_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file("mzsolve");

% Sanity checks
r=mzsolve([]);
if ~isempty(r)
  error("Expected isempty(r) for []");
endif
r=mzsolve(1);
if ~isempty(r)
  error("Expected isempty(r) for 1");
endif
r=mzsolve([1]);
if ~isempty(r)
  error("Expected isempty(r) for [1]");
endif
try
  r=mzsolve([1 2*j 1]);
  error("mzsolve did not catch complex coefficients");
catch
  printf("mzsolve did catch complex coefficients\n");
end_try_catch

% Check leading(z^n) and trailing(z^1,1) zeros
r=mzsolve([bincoeff(6,0:6),0]);
if max(abs(r+[0;ones(6,1)])) > 2.1e-8
  error("r=mzsolve([bincoeff(6,0:6),0] :  max(abs(r+[0;ones(6,1)])) > 2.1e-8")
endif
r=mzsolve([0,bincoeff(6,0:6)]);
if max(abs(r+ones(6,1))) > 1.2e-16
  error("r=mzsolve([0,bincoeff(6,0:6)] :  max(abs(r+[ones(6,1)])) > 1.2e-16")
endif
r=mzsolve([0,bincoeff(6,0:6),0]);
if max(abs(r+[0;ones(6,1)])) > 2.1e-8
  error("r=mzsolve([0,bincoeff(6,0:6),0] :  max(abs(r+[0;ones(6,1)])) > 2.1e-8")
endif

%{
% Check sorting
p1=conv(conv([1,1-i],[1,1+i]),conv([1,-2-2*i],[1,-2+2*i]));
r1=mzsolve(p1);
rr1=roots(p1);
if max(abs(r1-rr1))>10*eps
  error("max(abs(r1-rr1))>10*eps");
endif
p2=conv(p1,conv(conv([1,-1-2*i],[1,-1+2*i]),conv([1,-3-2*i],[1,-3+2*i])));
r2=mzsolve(p2);
rr2=roots(p2);
if max(abs(r2-rr2))>100*eps
  error("max(abs(r2-rr2))>100*eps");
endif
%}

% Binomial coefficients
N=6;
r=mzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 1.2e-16
  error("r=mzsolve(bincoeff(6,0:6)) : max(abs(r+1)) > 1.2e-16");
endif

N=20;
r=mzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 2.076e-5
  error("r=mzsolve(bincoeff(20,0:20)) : max(abs(r+1)) > 2.076e-5");
endif

% Roots of -1
N=6;
r=mzsolve([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > eps
  error("r=mzsolve([1,zeros(1,5),1]) : max(abs(abs(r)-1)) > eps");
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("r=mzsolve([1,zeros(1,5),1]) : angle failed! > eps");
endif

N=20;
r=mzsolve([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > eps
  error("r=mzsolve([1,zeros(1,19),1]) : max(abs(abs(r)-1)) > eps");
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("r=mzsolve([1,zeros(1,19),1]) : angle failed! > eps");
endif

% Parallel allpass filter
D = [  1.0000000000,  -2.2443545374,   3.6828563678,  -3.7424738257, ... 
       2.9806683357,  -1.5676125569,   0.6649693575,  -0.1388429847, ... 
       0.0238205598,   0.0129159293,   0.0006995335 ]';
d=mzsolve(D)

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
