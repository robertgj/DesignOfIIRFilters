% Serror_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("Serror_test.diary");
delete("Serror_test.diary.tmp");
diary Serror_test.diary.tmp

verbose=false;

% Initial filter
U=2;V=2;M=14;Q=6;R=2;
x0=[  8.1134e-05, ...
      1.2500e+00, -1.0066e+00, ...
      7.4383e-01,  7.4383e-01, ...
      1.0125e+00,  1.0125e+00,  1.0125e+00,  1.0286e+00, ...
      1.0179e+00,  1.0153e+00,  1.0142e+00, ...
      2.9992e+00,  2.9992e+00,  2.9992e+00,  1.5482e+00, ...
      2.0863e+00,  2.3510e+00,  2.5094e+00, ...
      7.3201e-01,  8.3655e-01,  8.3827e-01, ...
      1.9415e+00,  1.0314e+00,  1.6531e+00 ]';

% Design parameters
fas=0.2;Was=1e6;
n=1000;
nas=floor(fas*n/0.5)+1;
ws=pi*(nas:n-1)'/n;
Sd=zeros(n-nas,1);
Ws=Was*ones(n-nas,1);

% Internal initialisation
Mon2=M/2;                  % Number of conjugate zero pairs
Qon2=Q/2;                  % Number of conjugate pole pairs
N=1+U+V+M+Q;
% Avoid response singularities by moving poles and zeros off the unit circle
x0((1+1):(1+U))=x0((1+1):(1+U))/2;
x0((1+U+1):(1+U+V))=x0((1+U+1):(1+U+V))/2;
x0((1+U+V+1):(1+U+V+Mon2))=x0((1+U+V+1):(1+U+V+Mon2))/2;
x0((1+U+V+M+1):(1+U+V+M+Qon2))=x0((1+U+V+M+1):(1+U+V+M+Qon2))/2;

% Initialise response
[ErrorS, gradErrorS, hessErrorS] = ...
  iirE(x0,U,V,M,Q,R,[],[],[],ws,Sd,Ws,[],[],[],[],[],[]);

% Check hessErrorS is symmetric
if (hessErrorS-hessErrorS')>eps
  error("(hessErrorS-hessErrorS')>eps");
endif

% Small number for simple-minded gradient computation
del=1e-6;
tol=del;
if verbose
  printf("del=%g,tol=%g\n",del,tol);
endif
delk=zeros(size(x0));
delk(end)=del/2;
for k=1:length(x0),
  delk=circshift(delk,1);
  [ErrorSpdelk, gradErrorSpdelk] = ...
    iirE(x0+delk,U,V,M,Q,R,[],[],[],ws,Sd,Ws,[],[],[],[],[],[]);
  [ErrorSmdelk, gradErrorSmdelk] = ...
    iirE(x0-delk,U,V,M,Q,R,[],[],[],ws,Sd,Ws,[],[],[],[],[],[]);
  diff_ErrorS=(ErrorSpdelk-ErrorSmdelk)/del;
  if verbose
    printf("k=%d\ndiff_ErrorS=%g,gradErrorS(%d)=%g,error/tol=%g\n", ...
           k,diff_ErrorS,k,gradErrorS(k),abs(diff_ErrorS-gradErrorS(k))/tol);
  endif
  if abs(diff_ErrorS-gradErrorS(k))>tol
    error("abs(diff_ErrorS-gradErrorS(%d))(%g)>tol(%g)", ...
          k,abs(diff_ErrorS-gradErrorS(k)),tol);
  endif

  diff_gradErrorS=(gradErrorSpdelk-gradErrorSmdelk)/del;
  if verbose
    [max_err,i_max_err]=max(diff_gradErrorS-abs(hessErrorS(:,k)));
    printf("abs(diff_gradErrorS(%d)-hessErrorS(%d,%d))/tol=%g\n", ...
           i_max_err,i_max_err,k,max_err/tol);
  endif
  if max(abs(diff_gradErrorS-hessErrorS(:,k)))>tol
    error("max(abs(diff_gradErrorS-hessErrorS(all,%d)))(%g)>tol(%g)", ...
          k,max(abs(diff_gradErrorS-hessErrorS(:,k))),tol);
  endif
endfor

% Done
diary off
movefile Serror_test.diary.tmp Serror_test.diary;
