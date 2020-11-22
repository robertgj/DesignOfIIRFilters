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

% Run SeDuMi
[x,y,info] = sedumi(At,b,c,K);
if info.numerr==2
  error("info.numerr==2");
endif
X=mat(x);
[U,S,V]=svd(X);
h=V(:,1)/2;
% Sanity check
if abs(S(1)-(4*h'*X*h))>4*eps
  error("abs(S(1)-(4*h'*X*h))(%g*eps)>4*eps",abs(S(1)-(4*h'*X*h))/eps);
endif

% Check that the inverse filter 1/H(z) is stable
if max(abs(1./roots(h)))>=1
  error("max(abs(1./roots(h)))(%g)>=1",max(abs(1./roots(h))));
endif
zplane(roots(h));
title("Minimum phase filter zeros");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

% Plot response
[H,w]=freqz(h,1,1024);
plot(w*0.5/pi,20*log10(abs(H)))
title("Minimum phase filter response");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
axis([0 0.5 -50 10])
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save results
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

% Done
diary off
movefile sedumi_minphase_test.diary.tmp sedumi_minphase_test.diary;
