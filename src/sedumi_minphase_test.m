% sedumi_minphase_test.m
%
% DIMACS FILTER/minphase.mat.gz example provided by Jos Sturm.
% See http://archive.dimacs.rutgers.edu/Challenges/Seventh/Instances/

test_common;

delete("sedumi_minphase_test.diary");
delete("sedumi_minphase_test.diary.tmp");
diary sedumi_minphase_test.diary.tmp

strf="sedumi_minphase_test";

% Local version of DIMACS FILTER/minphase.mat example data
load sedumi_minphase_test_data.mat
b=b(:);
n=rows(b);
% Note that the change of sign of c gives inverse zeros of h
c=-vec(diag([(n-1):-1:0]));
At=zeros(n*n,n);
At(:,1)=vec(diag(ones(n,1)));
for k=2:n,
  At(:,k)=vec(diag(0.5*ones(n-k+1,1),k-1)+diag(0.5*ones(n-k+1,1),-k+1));
endfor
K.s=n;

% Run SeDuMi
[x,y,info] = sedumi(At,b,c,K);
if info.numerr==2
  error("info.numerr==2");
endif
% Check x and y
tol=2e-4;
if abs((c'*x)-(y'*b))>tol
  error("abs((c'*x)-(y'*b))(%g)>tol(%g)",abs((c'*x)-(y'*b)),tol);
endif

% Plot covariance response
r=[flipud(b(2:end));b]/4;
[R,w]=freqz(r,1,1024);
plot(w*0.5/pi,10*log10(abs(R)))
title("Minimum phase filter covariance");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
axis([0 0.5 -50 10])
print(strcat(strf,"_covariance"),"-dpdflatex");
close

% Calculate the impulse response
X=mat(x);
[U,S,V]=svd(X);
h=V(:,1)/2;
% Sanity check
if abs(S(1)-(4*h'*X*h))>4*eps
  error("abs(S(1)-(4*h'*X*h))(%g*eps)>4*eps",abs(S(1)-(4*h'*X*h))/eps);
endif

% Calculate correlation
rh=zeros(n,1);
for l=1:n
  rh(l)=4*h(l:n)'*h(1:(n-l+1));
endfor
if max(abs(rh-b))>(tol/10)
  error("max(abs(rh-b))(%g)>(tol/10)(%g)",max(abs(rh-b)),tol/10);
endif

% Check that the H(z) is minimum phase
if max(abs(qroots(h)))>=1
  error("max(abs(qroots(h)))(%g)>=1",max(abs(qroots(h))));
endif

% Plot impulse response
plot(h)
title("Minimum phase filter impulse response");
xlabel("Sample");
ylabel("Impulse response");
grid("on");
print(strcat(strf,"_impulse"),"-dpdflatex");
close

% Plot frequency response
[H,w]=freqz(h,1,1024);
plot(w*0.5/pi,20*log10(abs(H)))
title("Minimum phase filter response");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
axis([0 0.5 -50 10])
print(strcat(strf,"_response"),"-dpdflatex");
close
zplane(qroots(h));
title("Minimum phase filter zeros");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

% Compare frequency response and correlation response
if max(abs(H.*conj(H))-abs(R))>(tol/4)
  error("max(abs(H.*conj(H))-abs(R))(%g)>(tol/4)(%g)", ...
        max(abs(H.*conj(H))-abs(R)),tol/4);
endif

% Save results
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

% Done
diary off
movefile sedumi_minphase_test.diary.tmp sedumi_minphase_test.diary;
