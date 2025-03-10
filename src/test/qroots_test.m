% qroots_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="qroots_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file("qroots");

rtol=1e-3;
if exist("qroots") == 3
  qtol=1e-6;
else
  qtol=rtol;
endif

% Sanity checks
r=qroots([]);
if ~isempty(r)
  error("Expected isempty(r) for []");
endif
r=qroots(1);
if ~isempty(r)
  error("Expected isempty(r) for 1");
endif
r=qroots([1]);
if ~isempty(r)
  error("Expected isempty(r) for [1]");
endif
try
  r=qroots([1 2*j 1]);
  error("qroots did not catch complex coefficients");
catch
  printf("qroots did catch complex coefficients\n");
end_try_catch

% Check leading(z^n) and trailing(z^1,1) zeros
r=qroots([bincoeff(6,0:6),0]);
if max(abs(r+[ones(6,1);0])) > 6*qtol
  error("max(abs(r+[ones(6,1);0]))(%g*qtol) > 6*qtol", ...
        max(abs(r+[ones(6,1);0]))/qtol);
endif
r=qroots([0,bincoeff(6,0:6)]);
if max(abs(r+ones(6,1))) > 6*qtol
  error("max(abs(r+[ones(6,1)]))(%g*qtol) > 6*qtol", ...
        max(abs(r+ones(6,1)))/qtol);
endif
r=qroots([0,bincoeff(6,0:6),0]);
if max(abs(r+[ones(6,1);0])) > 6*qtol
  error("max(abs(r+[ones(6,1);0]))(%g*qtol) > 6*qtol", ...
        max(abs(r+[ones(6,1);0]))/qtol);
endif

% Check sorting
p1=conv(conv([1,1-i],[1,1+i]),conv([1,-2-2*i],[1,-2+2*i]));
r1=qroots(p1);
rr1=roots(p1);
if max(abs(r1-rr1))>10*eps
  error("max(abs(r1-rr1))(%g*eps)>10*eps",max(abs(r1-rr1))/eps);
endif
p2=conv(p1,conv(conv([1,-1-2*i],[1,-1+2*i]),conv([1,-3-2*i],[1,-3+2*i])));
r2=qroots(p2);
rr2=roots(p2);
if max(abs(r2-rr2))>100*eps
  error("max(abs(r2-rr2))(%g*eps)>100*eps",max(abs(r2-rr2))/eps);
endif

% Binomial coefficients
N=6;
rr=roots(bincoeff(N,0:N));
if max(abs(rr+1)) > N*rtol
  error("max(abs(rr+1))(%g*rtol) > %d*rtol",max(abs(rr+1))/rtol,N);
endif
r=qroots(bincoeff(N,0:N));
if max(abs(r+1)) > N*qtol
  error("max(abs(r+1))(%g*qtol) > %d*qtol",max(abs(r+1))/qtol,N);
endif

N=20;
if exist("qroots") == 3
  r=qroots(bincoeff(N,0:N));
  if max(abs(r+1)) > 5e4*qtol
    error("max(abs(r+1))(%g*qtol) > 5e4*qtol",max(abs(r+1))/qtol);
  endif
endif

% Roots of -1
N=6;
rr=roots([1,zeros(1,N-1),1]);
if max(abs(abs(rr)-1)) > N*eps
  error("max(abs(rr)-1))(%g*eps) > %d*eps",max(abs(r)-1)/eps,N);
endif
if max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("angle failed! (%g*eps)", ...
        max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))/eps);
endif
r=qroots([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > N*eps
  error("max(abs(abs(r)-1))(%g*eps) > N*eps", max(abs(abs(r)-1))/eps);
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>eps
  error("angle failed! (%g*eps)", ...
        max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))/eps);
endif

N=20;
rr=roots([1,zeros(1,N-1),1]);
if max(abs(abs(rr)-1)) > 6*eps
  error("max(abs(abs(rr)-1))(%g*eps) > 6*eps", max(abs(abs(rr)-1))/eps);
endif
if max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))>2*eps
  error("angle failed! (%g*eps)", ...
        max(abs((sort((arg(rr')/pi)))-(-(N-1):2:(N-1))/N))/eps);
endif
r=qroots([1,zeros(1,N-1),1]);
if max(abs(abs(r)-1)) > N*eps
  error("max(abs(abs(r)-1))(%g*eps) > N*eps", max(abs(abs(r)-1))/eps);
endif
if max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))>N*eps
  error("angle failed! > (%g*eps)", ...
        max(abs((sort((arg(r')/pi)))-(-(N-1):2:(N-1))/N))/eps);
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
print_pole_zero(x,U,V,M,Q,R,"x",strcat(strf,"_coef.m"),"%13.10f");
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
