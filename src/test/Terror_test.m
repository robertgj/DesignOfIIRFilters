% Terror_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("Terror_test.diary");
delete("Terror_test.diary.tmp");
diary Terror_test.diary.tmp

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
ftp=0.1;Wtp=0.2;td=16;
n=1000;
ntp=ceil(ftp*n/0.5)+1;
wt=pi*(0:(ntp-1))'/n;
Td=td*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

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
[ErrorT, gradErrorT, hessErrorT] = ...
  iirE(x0,U,V,M,Q,R,[],[],[],[],[],[],wt,Td,Wt,[],[],[]);

% Check hessErrorT is symmetric
if (hessErrorT-hessErrorT')>eps
  error("(hessErrorT-hessErrorT')>eps");
endif

% Small number for simple-minded gradient computation
del=1e-6;
tol=del/50;
if verbose
  printf("del=%g,tol=%g\n",del,tol);
endif
delk=zeros(size(x0));
delk(end)=del/2;
for k=1:length(x0),
  delk=circshift(delk,1);
  [ErrorTpdelk, gradErrorTpdelk] = ...
    iirE(x0+delk,U,V,M,Q,R,[],[],[],[],[],[],wt,Td,Wt,[],[],[]);
  [ErrorTmdelk, gradErrorTmdelk] = ...
    iirE(x0-delk,U,V,M,Q,R,[],[],[],[],[],[],wt,Td,Wt,[],[],[]);
  diff_ErrorT=(ErrorTpdelk-ErrorTmdelk)/del;
  if verbose
    printf("k=%d,diff_ErrorT=%g,gradErrorT(%d)=%g,error/tol=%g\n", ...
           k,diff_ErrorT,k,gradErrorT(k),abs(diff_ErrorT-gradErrorT(k))/tol);
  endif
  if abs(diff_ErrorT-gradErrorT(k))>tol
    error("abs(diff_ErrorT-gradErrorT(%d))(%g)>tol(%g)", ...
          k,abs(diff_ErrorT-gradErrorT(k)),tol);
  endif

  diff_gradErrorT=(gradErrorTpdelk-gradErrorTmdelk)/del;
  if verbose
    [max_err,i_max_err]=max(diff_gradErrorT-abs(hessErrorT(:,k)));
    printf("abs(diff_gradErrorT(%d)-hessErrorT(%d,%d))/tol=%g\n", ...
           i_max_err,i_max_err,k,max_err/tol);
  endif
  if max(abs(diff_gradErrorT-hessErrorT(:,k)))>tol
    error("max(abs(diff_gradErrorT-hessErrorT(all,%d)))(%g)>tol(%g)", ...
          k,max(abs(diff_gradErrorT-hessErrorT(:,k))),tol);
  endif
endfor

% Done
diary off
movefile Terror_test.diary.tmp Terror_test.diary;
