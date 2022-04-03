% iirT_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("iirT_test.diary");
delete("iirT_test.diary.tmp");
diary iirT_test.diary.tmp

del=1e-5;
tol=1e-8;

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
T=iirT([],x0,U,V,M,Q,R);
if ~isempty(T)
  error("Expected T=[]");
endif
[T,gradT]=iirT([],x0,U,V,M,Q,R);
if ~(isempty(T) && isempty(gradT))
  error("Expected T=[] and gradT=[]");
endif
[T,gradT,hessT]=iirT([],x0,U,V,M,Q,R);
if ~(isempty(T) && isempty(gradT) && isempty(hessT))
  error("Expected T=[] and gradT=[] and hessT=[]");
endif
T=iirT(0.1,0,0,0,0,0,1);
if abs(T)>eps
  error("Expected T==0");
endif
[T,gradT]=iirT(0.1,0,0,0,0,0,1);
if abs(T)>eps || any(gradT)
  error("Expected T==0 and gradT==0");
endif
[T,gradT,hessT]=iirT(0.1,0,0,0,0,0,1);
if abs(T)>eps || any(gradT) || any(any(hessT))
  error("Expected T==0, gradT==0 and hessT==0");
endif
[T,gradT,hessT]=iirT(0.1,[1, 0],0,1,0,0,2);
if abs(T)>eps || any(gradT) || any(any(hessT))
  error("Expected T==0, gradT==0 and hessT==0");
endif
[T,gradT,hessT]=iirT(0.1,[1, 0, pi],0,0,0,2,2);
if abs(T)>eps || any(gradT) || any(any(hessT))
  error("Expected T==0, gradT==0 and hessT==0");
endif

for R=1:3,
  [B,A]=x2tf(x0,U,V,M,Q,R);
  BAT=grpdelay(B,A,Nw);
  BAT=BAT(:);

  % Use iirT to find delay
  T=iirT(w,x0,U,V,M,Q,R);
  T_tol=tol./[100,30,1];
  if max(abs(BAT-T))> T_tol(R)
    error("R=%d,max(abs(BAT-T)) > %g",R,T_tol(R));
  endif

  % Use iirT to find delay in restricted frequency range
  [T,gradT,hessT]=iirT(wc,x0,U,V,M,Q,R);
  
  % Check hessT is symmetric
  for n=1:nc
    if ~issymmetric(reshape(hessT(n,:,:),N,N),eps)
      error("hessT not symmetric at n=%d",n);
    endif
  endfor
  
  % Find approximate values of gradients and Hessian of delay
  gradTD=zeros(nc,N);
  hessTD=zeros(nc,N,N);
  delk=zeros(1,N);
  delk(end)=del/2;
  for k=1:N
    delk=circshift(delk,1);
    [TDpdelk,gradTDpdelk]=iirT(wc,x0+delk,U,V,M,Q,R);
    [TDmdelk,gradTDmdelk]=iirT(wc,x0-delk,U,V,M,Q,R);
    gradTD(:,k)=(TDpdelk-TDmdelk)/del;
    hessTD(:,k,:)=(gradTDpdelk-gradTDmdelk)/del;
  endfor
  
  % Compare gradT to the approximation 
  max_err_gradT=max(max(abs(gradTD-gradT)));
  gradT_tol=[10,10,50]*tol;
  if max_err_gradT>gradT_tol
    error("R=%d,max_err_gradT(%g)>tol(%g)",R,max_err_gradT,gradT_tol);
  endif

  % Compare hessT to the approximation
  err_hessT=abs(hessTD-hessT);
  max_err_hessT=max(max(max(abs(hessTD-hessT))));
  hessT_tol=[1,2,2000]*tol;
  if max_err_hessT>hessT_tol(R)
    warning("R=%d,max_err_hessT(%g)>tol(%g)",R,max_err_hessT,hessT_tol(R));
  endif

endfor

% Done
diary off
movefile iirT_test.diary.tmp iirT_test.diary;
