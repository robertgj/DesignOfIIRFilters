% iirA_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("iirA_test.diary");
delete("iirA_test.diary.tmp");
diary iirA_test.diary.tmp

del=1e-5;
tol=1e-7;

% Define the filter
U=2;V=2;M=20;Q=8;R=1;
N=1+U+V+M+Q;
x0=[ -0.0089234, ...
      0.5000000, -0.5000000, ...
      0.5000000, -0.5000000, ...
     -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
      0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
      0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
      1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
     -0.9698147, -0.8442244,  0.4511337,  0.4242641,  ...
      1.8917946,  1.7780303,  1.2325954,  0.7853982 ];

% Frequencies
Nw=512;
w=(0:(Nw-1))'*pi/Nw;
fc=0.06;
nc=ceil(fc*Nw/0.5)+1;
wc=w(1:nc);

% Simple cases
A=iirA([],x0,U,V,M,Q,R);
if ~isempty(A)
  error("Expected A=[]");
endif
[A,gradA]=iirA([],x0,U,V,M,Q,R);
if ~(isempty(A) && isempty(gradA))
  error("Expected A=[] and gradA=[]");
endif
[A,gradA,hessA]=iirA([],x0,U,V,M,Q,R);
if ~(isempty(A) && isempty(gradA) && isempty(hessA))
  error("Expected A=[] and gradA=[] and hessA=[]");
endif
A=iirA(0.1,0,0,0,0,0,1);
if abs(A)>eps
  error("Expected A==0");
endif
[A,gradA]=iirA(0.1,0,0,0,0,0,1);
if abs(A)>eps || any(gradA)
  error("Expected A==0 and gradA==0");
endif
[A,gradA,hessA]=iirA(0.1,0,0,0,0,0,1);
if abs(A)>eps || any(gradA) || any(any(hessA))
  error("Expected A==0, gradA==0 and hessA==0");
endif
[A,gradA,hessA]=iirA(0.1,[1, 0],0,1,0,0,2);
if abs(A-1)>eps||any(abs(gradA-[1,0])>eps)||any(any(abs(hessA-zeros(2))>eps))
  error("Expected A==1, gradA==[1,0] and hessA==zeros(2)");
endif
[A,gradA,hessA]=iirA(0.1,[1, 0, pi],0,0,0,2,2);
if abs(A-1)>eps||any(abs(gradA-[1,0,0])>eps)||any(any(abs(hessA-zeros(3))>eps))
  error("Expected A==1, gradA==[1,0,0] and hessA==zeros(3)");
endif

for R=1:3,
  [B,A]=x2tf(x0,U,V,M,Q,R);
  H=freqz(B,A,w);
  H=H(:);

  % Check amplitude from iirA
  A=iirA(w,x0,U,V,M,Q,R);
  if max(abs(abs(A)-abs(H)))> tol/1000
    error("R=%d,max(abs(abs(A)-abs(H))) > tol(%g)",R,tol/1000);
  endif

  % Use iirA to find amplitude in restricted frequency range
  [A,gradA,hessA]=iirA(wc,x0,U,V,M,Q,R);
  
  % Check hessA is symmetric
  for n=1:nc
    if ~issymmetric(reshape(hessA(n,:,:),N,N),eps)
      error("hessA not symmetric at n=%d",n);
    endif
  endfor
  
  % Find approximate values of gradients and Hessian of amplitude
  gradAD=zeros(nc,N);
  hessAD=zeros(nc,N,N);
  delk=zeros(1,N);
  delk(end)=del/2;
  for k=1:N
    delk=shift(delk,1);
    [ADpdelk,gradADpdelk]=iirA(wc,x0+delk,U,V,M,Q,R);
    [ADmdelk,gradADmdelk]=iirA(wc,x0-delk,U,V,M,Q,R);
    gradAD(:,k)=(ADpdelk-ADmdelk)/del;
    hessAD(:,k,:)=(gradADpdelk-gradADmdelk)/del;
  endfor
  
  % Compare gradA to the approximation 
  max_err_gradA=max(max(abs(gradAD-gradA)));
  if max_err_gradA>tol
    error("R=%d,max_err_gradA(%g)>tol(%g)",R,max_err_gradA,tol);
  endif

  % Compare hessA to the approximation
  err_hessA=abs(hessAD-hessA);
  max_err_hessA=max(max(max(abs(hessAD-hessA))));
  hessA_tol=[1,1,100]*tol;
  if max_err_hessA>hessA_tol(R)
    error("R=%d,max_err_hessA(%g)>tol(%g)",R,max_err_hessA,hessA_tol(R));
  endif

endfor

% Done
diary off
movefile iirA_test.diary.tmp iirA_test.diary;
