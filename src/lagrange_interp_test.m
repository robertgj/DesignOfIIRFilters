% lagrange_interp_test.m
%
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("lagrange_interp_test.diary");
unlink("lagrange_interp_test.diary.tmp");
diary lagrange_interp_test.diary.tmp

strf="lagrange_interp_test";

%
% Test sanity checks
%
% Refusing to extrapolate
try
  xk=1:10;
  fk=xk.^2;
  x=0.5:1:9;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% Refusing to extrapolate
try
  xk=1:10;
  fk=(xk.^2);
  x=1.5:1:11;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% any(size(xk)~=size(fk))
try
  xk=1:10;
  fk=[(xk.^2)';20];
  x=1.5:1:8;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% all(size(xk)~=1)
try
  xk=[1,10;2,7];
  fk=(xk.^2);
  x=1.5:1:3;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% max(size(xk))<2)
try
  xk=1;
  fk=(xk.^2);
  x=1;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% any(diff(xk)==0)
try
  xk=[0,0,1];
  fk=(xk.^2);
  x=1;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% all(size(x)~=1)
try
  xk=1:7;
  fk=(xk.^2);
  x=[1.5,2;1,10];
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% any(size(wk)~=size(xk))
try
  xk=1:7;
  fk=(xk.^2);
  x=1:6;
  wk=[1,2;4,6];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% any(size(wk)~=size(xk))
try
  xk=1:7;
  fk=(xk.^2);
  x=1:6;
  wk=(1:4)';
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% any(size(wk)~=size(xk))
try
  xk=1:7;
  fk=(xk.^2);
  x=1:6;
  wk=xk';
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% All fk the same
try
  xk=1:7;
  fk=pi*ones(size(xk));
  x=1:6;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch
% Linear interpolation
try
  xk=[1 60];
  fk=xk*2;
  x=1:60;
  wk=[];
  f=lagrange_interp(xk,fk,wk,x);
catch
  err=lasterror();
  printf("Caught error: %s\n",err.message);
end_try_catch

%
% Berrut and Trefethen example, Figure 5.1, n=20,
%

%
% Chebyshev type 2 nodes
%
n=20;
xk=cos(pi*(0:n)'/n);
fun=@(x) (abs(x)+(x/2)-(x.^2));
fk=fun(xk);
wk=[1/2; ones(n-1,1); 1/2].*(-1).^((0:n)');
x=linspace(-1,1,101)';
f=lagrange_interp(xk,fk,wk,x);
% Check f
if norm(f-fun(x))>0.1
  error("norm(f-fun(x)(%g)>0.1",norm(f-fun(x)));
endif
% Check w
[f,w]=lagrange_interp(xk,fk,wk,x);
if w~=wk
  error("w~=wk");
endif
% Check p
[f,w,p]=lagrange_interp(xk,fk,wk,x);
if norm(f-polyval(p,x))>1e-8
  error("norm(f-polyval(p,x))(%g)>1e-8",norm(f-polyval(p,x)));
endif

% Make plot
subplot(211)
plot(x,f,xk,fk,'o');
title(sprintf("Berrut and Trefethen : n=%d, Chebyshev type 2 node spacing",n));
ylabel("Interpolated f");
subplot(212)
plot(x,f-fun(x),xk,zeros(size(xk)),'o');
ylabel("f-fun(x)");
print(sprintf("%s_n_20_Chebyshev_2",strf),"-dpdflatex");
close

% Check w
[f,w]=lagrange_interp(xk,fk,[],x);
if std(w./wk)>1e-10
  error("std(w./wk)(%g)>1e-10",std(w./wk));
endif
print_polynomial(w,"w",sprintf("%s_n_%2d_Chebyshev_2_w_coef.m",strf,n),"%15.8f");
% Check p
[f,w,p]=lagrange_interp(xk,fk,[],x);
if norm(f-polyval(p,x))>1e-8
  error("norm(f-polyval(p,x))(%g)>1e-8",norm(f-polyval(p,x)));
endif
print_polynomial(p,"p",sprintf("%s_n_%2d_Chebyshev_2_p_coef.m",strf,n),"%15.8f");

% Try a large number of interpolation points (calculation of w and p fails)
n=1000;
xk=cos(pi*(0:n)'/n);
fk=fun(xk);
wk=[1/2; ones(n-1,1); 1/2].*(-1).^((0:n)');
x=linspace(-1,1,5001)';
f=lagrange_interp(xk,fk,wk,x);
if norm(f-fun(x))>1e-2
  error("norm(f-fun(x))(%g)>1e-2",norm(f-fun(x)));
endif
if max(abs(f-fun(x)))>1e-3
  error("norm(f-fun(x))(%g)>1e-3",max(abs(f-fun(x))));
endif

%
% Interpolation with linear spacing fails
%
n=20;
xk=linspace(-1,1,n+1)';
fk=fun(xk);
wk=((-1).^((0:n)).*bincoeff(n,0:n))';
x=linspace(-1,1,101)';
f=lagrange_interp(xk,fk,wk,x);
if norm(f-fun(x))>0.1
  warning("norm(f-fun(x))(%g)>0.1",norm(f-fun(x)));
endif
[f,w]=lagrange_interp(xk,fk,[],x);
if std(w./wk)>1e-13
  error("std(w./wk)(%g)>1e-13",std(w./wk));
endif
% Make plot
subplot(111)
plot(x,f,xk,fk,'o');
title(sprintf("Berrut and Trefethen : n=%d, linear node spacing",n));
ylabel("Interpolated f");
print(sprintf("%s_n_20_linear",strf),"-dpdflatex");
close

%
% Chebyshev type 1 nodes
%
n=20;
xk=cos((((2*(0:n))+1)*pi)/((2*n)+2));
fk=fun(xk);
wk=((-1).^((0:n))).*sin((((2*(0:n))+1)*pi)/((2*n)+2));
x=linspace(-0.9,0.9,101)';
f=lagrange_interp(xk,fk,wk,x);
% Check f
if norm(f-fun(x))>0.1
  error("norm(f-fun(x))(%g)>0.1",norm(f-fun(x)));
endif
% Check w
[f,w]=lagrange_interp(xk,fk,[],x);
if std(w./wk)>1e-10
  error("std(w./wk)(%g)>1e-10",std(w./wk));
endif
print_polynomial(w,"w",sprintf("%s_n_%2d_Chebyshev_1_w_coef.m",strf,n),"%15.8f");
% Check p
[f,w,p]=lagrange_interp(xk,fk,[],x);
if norm(f-polyval(p,x))>1e-9
  error("norm(f-polyval(p,x))(%g)>1e-9",norm(f-polyval(p,x)));
endif
print_polynomial(p,"p",sprintf("%s_n_%2d_Chebyshev_1_p_coef.m",strf,n),"%15.8f");

%
% Try scaling the interval with Chebyshev type 2 nodes
%
n=20;
a=2;
b=3.5;
xk=((a+b)+((b-a)*cos(pi*(0:n)'/n)))/2;
fk=1.2*fun(xk-3);
wk=[1/2; ones(n-1,1); 1/2].*(-1).^((0:n)');
x=linspace(a,b,101)';
f=lagrange_interp(xk,fk,wk,x);
if norm(f-(1.2*fun(x-3)))>0.1
  error("norm(f-fun(x)(%g)>0.1",norm(f-fun(x)));
endif

% Make plot
subplot(211)
plot(x,f,xk,fk,'o');
title(sprintf("Berrut and Trefethen : n=%d, scaled to [%g,%g]",n,a,b));
subplot(212)
plot(x,f-(1.2*fun(x-3)),xk,zeros(size(xk)),'o');
print(sprintf("%s_n_20_Chebyshev_2_scaled",strf),"-dpdflatex");
close

% Done
diary off
movefile lagrange_interp_test.diary.tmp lagrange_interp_test.diary;
