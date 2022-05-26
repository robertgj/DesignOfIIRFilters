% iirP_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("iirP_test.diary");
delete("iirP_test.diary.tmp");
diary iirP_test.diary.tmp

del=1e-5;
tol=1e-9;

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
P=iirP([],x0,U,V,M,Q,R);
if ~isempty(P)
  error("Expected P=[]");
endif
[P,gradP]=iirP([],x0,U,V,M,Q,R);
if ~(isempty(P) && isempty(gradP))
  error("Expected P=[] and gradP=[]");
endif
[P,gradP,hessP]=iirP([],x0,U,V,M,Q,R);
if ~(isempty(P) && isempty(gradP) && isempty(hessP))
  error("Expected P=[] and gradP=[] and hessP=[]");
endif
P=iirP(0.1,0,0,0,0,0,1);
if abs(P)>eps
  error("Expected P==0");
endif
[P,gradP]=iirP(0.1,0,0,0,0,0,1);
if abs(P)>eps || any(gradP)
  error("Expected P==0 and gradP==0");
endif
[P,gradP,hessP]=iirP(0.1,0,0,0,0,0,1);
if abs(P)>eps || any(gradP) || any(any(hessP))
  error("Expected P==0, gradP==0 and hessP==0");
endif
[P,gradP,hessP]=iirP(0.1,[1, 0],0,1,0,0,2);
if abs(P)>eps || any(gradP) || any(any(hessP))
  error("Expected P==0, gradP==0 and hessP==0");
endif
[P,gradP,hessP]=iirP(0.1,[1, 0, pi],0,0,0,2,2);
if abs(P)>eps || any(gradP) || any(any(hessP))
  error("Expected P==0, gradP==0 and hessP==0");
endif

for R=1:3,
  [B,A]=x2tf(x0,U,V,M,Q,R);
  H=freqz(B,A,w);
  H=H(:);
  BAP=unwrap(arg(H));

  % Use iirP to find phase
  P=iirP(w,x0,U,V,M,Q,R);

  % Note that arg(K) is included in the amplitude
  if max(abs(BAP-P-arg(x0(1))))> 1000*eps
    error("R=%d,max(abs(BAP-P)) > 1000*eps",R);
  endif

  % Use iirP to find phase in restricted frequency range
  [P,gradP,hessP]=iirP(wc,x0,U,V,M,Q,R);
  
  % Check hessP is symmetric
  for n=1:nc
    if ~issymmetric(reshape(hessP(n,:,:),N,N),eps)
      error("hessP not symmetric at n=%d",n);
    endif
  endfor
  
  % Find approximate values of gradients and Hessian of phase
  gradPD=zeros(nc,N);
  hessPD=zeros(nc,N,N);
  delk=zeros(1,N);
  delk(end)=del/2;
  for k=1:N
    delk=circshift(delk,1);
    [PDpdelk,gradPDpdelk]=iirP(wc,x0+delk,U,V,M,Q,R);
    [PDmdelk,gradPDmdelk]=iirP(wc,x0-delk,U,V,M,Q,R);
    gradPD(:,k)=(PDpdelk-PDmdelk)/del;
    hessPD(:,k,:)=(gradPDpdelk-gradPDmdelk)/del;
  endfor
  
  % Compare gradP to the approximation 
  max_err_gradP=max(max(abs(gradPD-gradP)));
  if max_err_gradP>tol*10
    error("R=%d,max_err_gradP(%g)>tol(%g)",R,max_err_gradP,tol*10);
  endif

  % Compare hessP to the approximation
  err_hessP=abs(hessPD-hessP);
  max_err_hessP=max(max(max(abs(hessPD-hessP))));
  hessP_tol=[1,2,200]*tol;
  if max_err_hessP>hessP_tol(R)
    warning("R=%d,max_err_hessP(%g)>tol(%g)",R,max_err_hessP,hessP_tol(R));
  endif

endfor

% Done
diary off
movefile iirP_test.diary.tmp iirP_test.diary;
