% herrmannFIRsymmetric_flat_lowpass_test.m
% Copyright (C) 2020-2024 Robert G. Jenssen

test_common;

delete("herrmannFIRsymmetric_flat_lowpass_test.diary");
delete("herrmannFIRsymmetric_flat_lowpass_test.diary.tmp");
diary herrmannFIRsymmetric_flat_lowpass_test.diary.tmp

strf="herrmannFIRsymmetric_flat_lowpass_test";

nplot=500;
tol=1e-9;

M=100;K=101;
try
  [hM,a]=herrmannFIRsymmetric_flat_lowpass(M,K,"Xxxxxxx");
catch
  printf("Caught exception : %s\n",lasterr());
end_try_catch

M=100;K=100;
try
  [hM,a]=herrmannFIRsymmetric_flat_lowpass(M,K,"Xxxxxxx");
catch
  printf("Caught exception : %s\n",lasterr());
end_try_catch

w=pi*(0:nplot)'/nplot;
x=(1-cos(w))/2;

for M=18:19,
  for K=11:12,
    
    [hM,a,haM]=herrmannFIRsymmetric_flat_lowpass(M,K);
    if norm(hM-haM)>tol
      error("M=%d,K=%d,norm(hM-haM)(%g)>tol(%g)",M,K,norm(hM-haM),tol);
    endif

    AM=directFIRsymmetricA(w,hM);
    xx=x.^(0:M);
    Aa=xx*a';
    if norm(AM-Aa)>40*tol
      error("M=%d,K=%d,norm(AM-Aa)(%g)>40*tol(%g)",M,K,norm(AM-Aa),40*tol);
    endif

    [~,ar]=herrmannFIRsymmetric_flat_lowpass(M,K,"rajagopal");
    if a~=ar
      error("M=%d,K=%d,a~=ar",M,K);
    endif
    
    [~,af]=herrmannFIRsymmetric_flat_lowpass(M,K,"forwards");
    if a~=af
      error("M=%d,K=%d,a~=af",M,K);
    endif
    
    [~,ab]=herrmannFIRsymmetric_flat_lowpass(M,K,"backwards");
    if a~=ab
      error("M=%d,K=%d,a~=ab",M,K);
    endif

    eval(sprintf("aM%2dK%2d=a;",M,K));
    print_polynomial(a,sprintf("aM%2dK%2d",M,K),"%12d");
    print_polynomial(a,sprintf("aM%2dK%2d",M,K), ...
                     sprintf("%s_aM%2dK%2d_coef.m",strf,M,K),"%12d");

    eval(sprintf("hM%2dK%2d=hM;",M,K));
    print_polynomial(hM,sprintf("hM%2dK%2d",M,K),"%15.12f");
    print_polynomial(hM,sprintf("hM%2dK%2d",M,K), ...
                     sprintf("%s_hM%2dK%2d_coef.m",strf,M,K),"%15.12f");

  endfor
endfor

% Reproduce Herrmann Figure 1
M=10;
AK=zeros(length(w),M);
for K=1:M,
  [~,a]=herrmannFIRsymmetric_flat_lowpass(M,K);
  xx=x.^(0:M);
  AK(:,K)=xx*a';
endfor
plot(x,AK);
grid("on");
text(0.9,0.8,"K=1");
text(0.1,0.1,"K=10");
axis([-0.05 1.05 -0.05 1.05])
xlabel("x");
ylabel("$P\_{M,K}\\left(x\\right)$");
title("$P\_{M,K}\\left(x\\right)$ for $M=10$ and $K=1,\\hdots,M$");
print(strcat(strf,"_M_10_K_1_M"),"-dpdflatex");
close

%
% Save results
%
save herrmannFIRsymmetric_flat_lowpass_test.mat ...
     nplot tol hM18K11 aM18K11 hM18K12 aM18K12 hM19K11 aM19K11 hM19K12 aM19K12 


%
% Done
%
diary off
movefile herrmannFIRsymmetric_flat_lowpass_test.diary.tmp ...
         herrmannFIRsymmetric_flat_lowpass_test.diary;

