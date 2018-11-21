% saramakiFBv_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("saramakiFBv_test.diary");
unlink("saramakiFBv_test.diary.tmp");
diary saramakiFBv_test.diary.tmp

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

    % B
    [b0,a0]=butter(n,2*fp,'high');
    [sos0,g0]=tf2sos(b0,a0);
    non2=floor(n/2);
    B=sos0(1:non2,5:6)'(:)';
    if mod(n,2)
      B=[B,-sos0(end,5)];
    endif

    % Check FBv
    FBv=saramakiFBv(B,n,m,v);
    F=(v.^(n-m)).*polyval(fliplr(a0),v)./polyval(a0,v);
    tol=2e-12;
    if max(abs(FBv-F)) > tol
      error("max(abs(FBv-F))(%g,n=%d,m=%d) > tol",max(abs(FBv-F)),n,m);
    endif

    % Check delFdelB
    tol=1e-9;
    del=1e-6;
    delk=[del,zeros(1,n-1)];
    [~,delFdelB]=saramakiFBv(B,n,m,v);
    approx_delFdelB=zeros(size(delFdelB));
    for k=1:n
      Fpdelk=saramakiFBv(B+(delk/2),n,m,v);
      Fmdelk=saramakiFBv(B-(delk/2),n,m,v);
      delk=shift(delk,1);
      approx_delFdelB(:,k)=(Fpdelk-Fmdelk)/del;
    endfor
    diff_approx=(approx_delFdelB-delFdelB)./delFdelB;
    if max(max(abs(diff_approx))) > tol
      error("max(max(abs(diff_approx)))(%g,n=%d,m=%d) > tol", ...
            max(max(abs(diff_approx))),n,m);
    endif

  endfor     
endfor

% Done
diary off
movefile saramakiFBv_test.diary.tmp saramakiFBv_test.diary;
