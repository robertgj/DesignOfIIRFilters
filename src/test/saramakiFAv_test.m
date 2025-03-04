% saramakiFAv_test.m
% Copyright (C) 2018-2025 Robert G. Jenssen

test_common;

delete("saramakiFAv_test.diary");
delete("saramakiFAv_test.diary.tmp");
diary saramakiFAv_test.diary.tmp

% Specify stop-band
wc=pi*0.1;
ws=pi*0.2;
w1=0;
w2=wc;
C=2/(cos(w1)-cos(w2));
D=-C*(cos(w1)+cos(w2));
zeta(1)=-0.5*(-(2*C*cos(ws))-D-sqrt(((-2*C*cos(ws)-D).^2)-4));
zeta(2)=-0.5*(2*C-D-sqrt(((2*C-D).^2)-4));

% Specify alpha
n=10;
for m=8:9,
  v=linspace(zeta(1),zeta(2),100*floor(m/2));
  if mod(m,2)
    v=v(1:(end-1));
  endif
  v=v(:);
  alpha=linspace(zeta(1),zeta(2),2+floor(m/2));
  alpha=alpha(2:(end-1));
  F=saramakiFAv(alpha,n,m,v,zeta);
  vFmin=local_max(-F);
  % Check delFdelalpha
  tol=5e-8;
  del=1e-6;
  delk=[del,zeros(1,length(alpha)-1)];
  [~,delFdelalpha]=saramakiFAv(alpha,n,m,v(vFmin),zeta);
  approx_delFdelalpha=zeros(size(delFdelalpha));
  for k=1:length(alpha)
    Fpdelk=saramakiFAv(alpha+(delk/2),n,m,v(vFmin),zeta);
    Fmdelk=saramakiFAv(alpha-(delk/2),n,m,v(vFmin),zeta);
    delk=circshift(delk,1);
    approx_delFdelalpha(:,k)=(Fpdelk-Fmdelk)/del;
  endfor
  diff_approx=(approx_delFdelalpha-delFdelalpha)./delFdelalpha;
  if max(max(abs(diff_approx))) > tol
    error("max(max(abs(diff_approx))) > tol");
  endif
endfor     

% Done
diary off
movefile saramakiFAv_test.diary.tmp saramakiFAv_test.diary;
