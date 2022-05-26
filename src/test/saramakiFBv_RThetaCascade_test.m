% saramakiFBv_RThetaCascade_test.m
% Copyright (C) 2018,2021 Robert G. Jenssen

test_common;

delete("saramakiFBv_RThetaCascade_test.diary");
delete("saramakiFBv_RThetaCascade_test.diary.tmp");
diary saramakiFBv_RThetaCascade_test.diary.tmp

% Specify pass-band
dBap=0.1;
fp=0.15;
fs=0.25;

% Frequency transformation
wp=pi*fp;
w1=pi*fs;
w2=pi;
C=2/(cos(w1)-cos(w2));
D=-C*(cos(w1)+cos(w2));
zeta(1)=((2*C)+D-sqrt((((2*C)+D).^2)-4))/2;
zeta(2)=((2*C*cos(wp))+D-sqrt((((2*C*cos(wp))+D).^2)-4))/2;
v=linspace(zeta(1),zeta(2),10);
v=v(:);

for m=5:6,
  for n=1:(m-1),

    % Pole locations
    [b0,a0]=butter(n,2*fp,'high');
    [z0,p0,K0]=tf2zp(b0,a0);
    non2=floor(n/2);
    pr=1:2:((2*non2)-1);
    rk=abs(p0(pr));
    thk=abs(arg(p0(pr)));
    if mod(n,2)
      Rk=abs(p0(n));
    else
      Rk=0;
    endif

    % beta
    beta=zeros(1,n);
    rkr=1:2:((2*non2)-1);
    thkr=2:2:(2*non2);
    beta(rkr)=rk;
    beta(thkr)=thk;
    if mod(n,2)
      beta(n)=Rk;
    endif

    % Check FBv
    FBv=saramakiFBv_RThetaCascade(beta,n,m,v);
    F=(v.^(n-m)).*polyval(fliplr(a0),v)./polyval(a0,v);
    tol=2e-12;
    if max(abs(FBv-F)) > tol
      error("max(abs(FBv-F))(%g*tol,n=%d,m=%d) > tol",max(abs(FBv-F))/tol,n,m);
    endif

    % Check delFdelbeta
    tol=1e-8;
    del=1e-6;
    delk=[del,zeros(1,n-1)];
    [~,delFdelbeta]=saramakiFBv_RThetaCascade(beta,n,m,v);
    approx_delFdelbeta=zeros(size(delFdelbeta));
    for k=1:n
      Fpdelk=saramakiFBv_RThetaCascade(beta+(delk/2),n,m,v);
      Fmdelk=saramakiFBv_RThetaCascade(beta-(delk/2),n,m,v);
      delk=circshift(delk,1);
      approx_delFdelbeta(:,k)=(Fpdelk-Fmdelk)/del;
    endfor
    diff_approx=(approx_delFdelbeta-delFdelbeta)./delFdelbeta;
    if max(max(abs(diff_approx))) > tol
      printf("max(max(abs(diff_approx)))(%g*tol,n=%d,m=%d) > tol\n", ...
            max(max(abs(diff_approx)))/tol,n,m);
    endif

  endfor     
endfor

% Done
diary off
movefile saramakiFBv_RThetaCascade_test.diary.tmp ...
         saramakiFBv_RThetaCascade_test.diary;
