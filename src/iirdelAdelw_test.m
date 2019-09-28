% iirdelAdelw_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iirdelAdelw_test.diary");
unlink("iirdelAdelw_test.diary.tmp");
diary iirdelAdelw_test.diary.tmp


% Simple case 
[delAdelw,graddelAdelw]=iirdelAdelw(0.1,0,0,0,0,0,1);
if (delAdelw ~= 0) || (graddelAdelw ~= 0)
  error("Expected delAdelw==0 and graddelAdelw==0");
endif
  
% Define the filter
U=2;V=2;M=20;Q=8;R=1;
x0=[  0.0089234, ...
      0.5000000, -0.5000000,  ...
      0.5000000, -0.5000000,  ...
     -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
      0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
      0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
      1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
     -0.9698147, -0.8442244,  0.4511337,  0.4242641,  ...
      1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';

% Check empty frequency
delAdelw=iirdelAdelw([],x0,U,V,M,Q,R);
if !isempty(delAdelw)
  error("Expected delAdelw=[]");
endif

% Check R
try
  delAdelw=iirdelAdelw([],x0,U,V,M,Q,2);
catch
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch

%
% Find iirdelAdelw
%
n=513;
w=(1:(n-1))*pi/n;
delAdelw=iirdelAdelw(w,x0,U,V,M,Q,R);

% Compare with an approximation calculated with iirA
Aw=iirA(w,x0,U,V,M,Q,1);
del=1e-6;
AwPdelon2=iirA(w+(del/2),x0,U,V,M,Q,1);
AwMdelon2=iirA(w-(del/2),x0,U,V,M,Q,1);
approx_delAdelw=(AwPdelon2-AwMdelon2)/del;
max_diff_delAdelw=max(abs((approx_delAdelw-delAdelw)./delAdelw));
tol=5.1e-8;
if max_diff_delAdelw > tol
  error("max_diff_delAdelw(=%f) > tol(=%f)",max_diff_delAdelw,tol);
endif

%
% Find graddelAdelw
%
wc=2*pi*0.19;
[delAdelw,graddelAdelw]=iirdelAdelw(wc,x0,U,V,M,Q,R);
% Calculated values
del2AdelwdelK=graddelAdelw(1);
del2AdelwdelR0=graddelAdelw((1+1):(1+U));
del2AdelwdelRp=graddelAdelw((1+U+1):(1+U+V));
Mon2=M/2;
del2Adelwdelr0=graddelAdelw((1+U+V+1):(1+U+V+Mon2));
del2Adelwdeltheta0=graddelAdelw((1+U+V+Mon2+1):(1+U+V+M));
Qon2=Q/2;
del2Adelwdelrp=graddelAdelw((1+U+V+M+1):(1+U+V+M+Qon2));
del2Adelwdelthetap=graddelAdelw((1+U+V+M+Qon2+1):(1+U+V+M+Q));

% Compare with an approximation calculated with iirdelAdelw
K=x0(1);
R0=x0((1+1):(1+U))';
Rp=x0((1+U+1):(1+U+V))';
r0=x0((1+U+V+1):(1+U+V+Mon2))';
theta0=x0((1+U+V+Mon2+1):(1+U+V+M))';
rp=x0((1+U+V+M+1):(1+U+V+M+Qon2))';
thetap=x0((1+U+V+M+Qon2+1):(1+U+V+M+Q))';
del=1e-7;

% del2AdelwdelK
tolK=del/5000;
[delAdelwD,graddelAdelwD]=...
  iirdelAdelw(wc,[K+del,R0,Rp,r0,theta0,rp,thetap],U,V,M,Q,R);
approx_del2AdelwdelK=(delAdelwD-delAdelw)/del;
diff_del2AdelwdelK=del2AdelwdelK-approx_del2AdelwdelK;
if abs(diff_del2AdelwdelK/del2AdelwdelK) > tolK
  error("del2AdelwdelK=%f, approx=%f, diff=%f\n",
        del2AdelwdelK,approx_del2AdelwdelK,diff_del2AdelwdelK);
endif

% Real zeros
tolR0=2.2*del;
for k=1:U
  delk=[zeros(1,k-1),del,zeros(1,(U-k))];

  % del2AdelwdelR0
  [delAdelwD,graddelAdelwD]=...
    iirdelAdelw(wc,[K,R0+delk,Rp,r0,theta0,rp,thetap],U,V,M,Q,R);
  approx_del2AdelwdelR0k=(delAdelwD-delAdelw)/del;
  diff_del2AdelwdelR0k=del2AdelwdelR0(k)-approx_del2AdelwdelR0k;
  if abs(diff_del2AdelwdelR0k/del2AdelwdelR0(k)) > tolR0
    error("del2AdelwdelR0(%d)=%f, approx=%f, diff=%f\n",...
          k,del2AdelwdelR0(k),approx_del2AdelwdelR0k,diff_del2AdelwdelR0k);
  endif
endfor

% Real poles
tolRp=5*del;
for k=1:V
  delk=[zeros(1,k-1) del zeros(1,(V-k))];

  % del2AdelwdelRp
  [delAdelwD,graddelAdelwD]=...
    iirdelAdelw(wc,[K,R0,Rp+delk,r0,theta0,rp,thetap],U,V,M,Q,R);
  approx_del2AdelwdelRpk=(delAdelwD-delAdelw)/del;
  diff_del2AdelwdelRpk=del2AdelwdelRp(k)-approx_del2AdelwdelRpk;
  if abs(diff_del2AdelwdelRpk/del2AdelwdelRp(k)) > tolRp
    error("del2AdelwdelRp(%d)=%f, approx=%f, diff=%f\n",...
          k,del2AdelwdelRp(k),approx_del2AdelwdelRpk,diff_del2AdelwdelRpk);
  endif
endfor

% Conjugate zeros
tolr0=16*del;
toltheta0=103*del;
for k=1:Mon2
  delk=[zeros(1,k-1) del zeros(1,(Mon2-k))];

  % del2Adelwdelr0
  [delAdelwD,graddelAdelwD]=...
    iirdelAdelw(wc,[K,R0,Rp,r0+delk,theta0,rp,thetap],U,V,M,Q,R);
  approx_del2Adelwdelr0k=(delAdelwD-delAdelw)/del;
  diff_del2Adelwdelr0k=del2Adelwdelr0(k)-approx_del2Adelwdelr0k;
  if abs(diff_del2Adelwdelr0k/del2Adelwdelr0(k)) > tolr0
    error("del2Adelwdelr0(%d)=%f, approx=%f, diff=%f\n",...
          k,del2Adelwdelr0(k),approx_del2Adelwdelr0k,diff_del2Adelwdelr0k);
  endif

  % del2Adelwdeltheta0
  [delAdelwD,graddelAdelwD]=...
    iirdelAdelw(wc,[K,R0,Rp,r0,theta0+delk,rp,thetap],U,V,M,Q,R);
  approx_del2Adelwdeltheta0k=(delAdelwD-delAdelw)/del;
  diff_del2Adelwdeltheta0k=del2Adelwdeltheta0(k)-approx_del2Adelwdeltheta0k;
  if abs(diff_del2Adelwdeltheta0k/del2Adelwdeltheta0(k)) > toltheta0
    error("del2Adelwdeltheta0(%d)=%f, approx=%f, diff=%f\n",...
          k,del2Adelwdeltheta0(k),approx_del2Adelwdeltheta0k, ...
          diff_del2Adelwdeltheta0k);
  endif
endfor

% Conjugate poles
tolrp=14*del;
tolthetap=14*del;
for k=1:Qon2
  delk=[zeros(1,k-1) del zeros(1,(Qon2-k))];

  % del2Adelwdelrp
  [delAdelwD,graddelAdelwD]=...
    iirdelAdelw(wc,[K,R0,Rp,r0,theta0,rp+delk,thetap],U,V,M,Q,R);
  approx_del2Adelwdelrpk=(delAdelwD-delAdelw)/del;
  diff_del2Adelwdelrpk=del2Adelwdelrp(k)-approx_del2Adelwdelrpk;
  if abs(diff_del2Adelwdelrpk/del2Adelwdelrp(k)) > tolrp
    error("del2Adelwdelrp(%d)=%f, approx=%f, diff=%f\n",...
          k,del2Adelwdelrp(k),approx_del2Adelwdelrpk,diff_del2Adelwdelrpk);
  endif

  % del2Adelwdelthetap
  [delAdelwD,graddelAdelwD]=...
    iirdelAdelw(wc,[K,R0,Rp,r0,theta0,rp,thetap+delk],U,V,M,Q,R);
  approx_del2Adelwdelthetapk=(delAdelwD-delAdelw)/del;
  diff_del2Adelwdelthetapk=del2Adelwdelthetap(k)-approx_del2Adelwdelthetapk;
  if abs(diff_del2Adelwdelthetapk/del2Adelwdelthetap(k)) > tolthetap
    error("del2Adelwdelthetap(%d)=%f, approx=%f, diff=%f\n",...
          k,del2Adelwdelthetap(k),approx_del2Adelwdelthetapk, ...
          diff_del2Adelwdelthetapk);
  endif
endfor

%
% Find del2Adelw2
%
[~,~,del2Adelw2]=iirdelAdelw(w,x0,U,V,M,Q,R);
% Compare with an approximation
del=1e-6;
delAdelwPdelon2=iirdelAdelw(w+(del/2),x0,U,V,M,Q,R);
delAdelwMdelon2=iirdelAdelw(w-(del/2),x0,U,V,M,Q,R);
approx_del2Adelw2=(delAdelwPdelon2-delAdelwMdelon2)/del;
max_diff_del2Adelw2=max(abs((approx_del2Adelw2-del2Adelw2)./del2Adelw2));
tol=6e-8;
if max_diff_del2Adelw2 > tol
  error("max_diff_del2Adelw2(=%f) > tol(=%f)",max_diff_del2Adelw2,tol);
endif

% Done
diary off
movefile iirdelAdelw_test.diary.tmp iirdelAdelw_test.diary;
