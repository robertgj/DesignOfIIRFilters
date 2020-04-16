% Aerror_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("Aerror_test.diary");
delete("Aerror_test.diary.tmp");
diary Aerror_test.diary.tmp

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
fap=0.1;Wap=1;
n=1000;
nap=ceil(fap*n/0.5)+1;
wa=pi*(0:(nap-1))'/n;
Ad=ones(nap,1);
Wa=Wap*ones(nap,1);

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
[ErrorA, gradErrorA, hessErrorA] = ...
  iirE(x0,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);

% Check hessErrorA is symmetric
if (hessErrorA-hessErrorA')>eps
  error("(hessErrorA-hessErrorA')>eps");
endif

% Small number for simple-minded gradient computation
del=1e-6;
tol=del/3;
if verbose
  printf("del=%g,tol=%g\n",del,tol);
endif
delk=zeros(size(x0));
delk(end)=del/2;
for k=1:length(x0),
  delk=shift(delk,1);
  [ErrorApdelk, gradErrorApdelk] = ...
    iirE(x0+delk,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);
  [ErrorAmdelk, gradErrorAmdelk] = ...
    iirE(x0-delk,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);
  diff_ErrorA=(ErrorApdelk-ErrorAmdelk)/del;
  if verbose
    printf("k=%d\ndiff_ErrorA=%g,gradErrorA(%d)=%g,error/tol=%g\n", ...
           k,diff_ErrorA,k,gradErrorA(k),abs(diff_ErrorA-gradErrorA(k))/tol);
  endif
  if abs(diff_ErrorA-gradErrorA(k))>tol
    error("abs(diff_ErrorA-gradErrorA(%d))(%g)>tol(%g)", ...
          k,abs(diff_ErrorA-gradErrorA(k)),tol);
  endif

  diff_gradErrorA=(gradErrorApdelk-gradErrorAmdelk)/del;
  if verbose
    [max_err,i_max_err]=max(diff_gradErrorA-abs(hessErrorA(:,k)));
    printf("abs(diff_gradErrorA(%d)-hessErrorA(%d,%d))/tol=%g\n", ...
           i_max_err,i_max_err,k,max_err/tol);
  endif
  if max(abs(diff_gradErrorA-hessErrorA(:,k)))>tol
    error("max(abs(diff_gradErrorA-hessErrorA(all,%d)))(%g)>tol(%g)", ...
          k,max(abs(diff_gradErrorA-hessErrorA(:,k))),tol);
  endif
endfor

% Done
diary off
movefile Aerror_test.diary.tmp Aerror_test.diary;
