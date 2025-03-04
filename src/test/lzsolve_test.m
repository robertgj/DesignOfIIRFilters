% lzsolve_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="lzsolve_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file("lzsolve");

% Sanity checks
r=lzsolve([]);
if ~isempty(r)
  error("Expected isempty(r) for []");
endif
r=lzsolve(1);
if ~isempty(r)
  error("Expected isempty(r) for 1");
endif
r=lzsolve([1]);
if ~isempty(r)
  error("Expected isempty(r) for [1]");
endif
try
  r=lzsolve([1 2*j 1]);
  error("lzsolve did not catch complex coefficients");
catch
  printf("lzsolve did catch complex coefficients\n");
end_try_catch

% Check leading(z^n) and trailing(z^1,1) zeros
r=lzsolve([bincoeff(6,0:6),0]);
if max(abs(r+[0;ones(6,1)])) > 3.1e-6
  error("r=lzsolve([bincoeff(6,0:6),0] :  max(abs(r+[0;ones(6,1)])) > 3.1e-6")
endif
r=lzsolve([0,bincoeff(6,0:6)]);
if max(abs(r+ones(6,1))) > 3.1e-6
  error("r=lzsolve([0,bincoeff(6,0:6)] :  max(abs(r+[ones(6,1)])) > 3.1e-6")
endif
r=lzsolve([0,bincoeff(6,0:6),0]);
if max(abs(r+[0;ones(6,1)])) > 3.1e-6
  error("r=lzsolve([0,bincoeff(6,0:6),0] :  max(abs(r+[0;ones(6,1)])) > 3.1e-6")
endif

%{
% Check sorting
p1=conv(conv([1,1-i],[1,1+i]),conv([1,-2-2*i],[1,-2+2*i]));
r1=lzsolve(p1);
rr1=roots(p1);
if max(abs(r1-rr1))>10*eps
  error("max(abs(r1-rr1))>10*eps");
endif
p2=conv(p1,conv(conv([1,-1-2*i],[1,-1+2*i]),conv([1,-3-2*i],[1,-3+2*i])));
r2=lzsolve(p2);
rr2=roots(p2);
if max(abs(r2-rr2))>100*eps
  error("max(abs(r2-rr2))>100*eps");
endif
%}

% Binomial coefficients
N=6;
r=lzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 3.1e-6
  error("r=lzsolve(bincoeff(6,0:6)) : max(abs(r+1)) > 3.1e-6");
endif

N=20;
r=lzsolve(bincoeff(N,0:N));
if max(abs(r+1)) > 0.039
  error("r=lzsolve(bincoeff(20,0:20)) : max(abs(r+1)) > 0.039");
endif

% Roots of -1
N=6;
r=lzsolve([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > eps
  error("r=lzsolve([1,zeros(1,5),1]) : max(abs(abs(r)-1)) > eps");
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("r=lzsolve([1,zeros(1,5),1]) : angle failed! > eps");
endif

N=20;
r=lzsolve([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > eps
  error("r=lzsolve([1,zeros(1,19),1]) : max(abs(abs(r)-1)) > eps");
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("r=lzsolve([1,zeros(1,19),1]) : angle failed! > eps");
endif

% Parallel allpass filter
D = [  1.0000000000,  -2.2443545374,   3.6828563678,  -3.7424738257, ... 
       2.9806683357,  -1.5676125569,   0.6649693575,  -0.1388429847, ... 
       0.0238205598,   0.0129159293,   0.0006995335 ]';
d=lzsolve(D)

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
