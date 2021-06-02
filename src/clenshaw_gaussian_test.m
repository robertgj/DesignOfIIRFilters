% clenshaw_gaussian_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("clenshaw_gaussian_test.diary");
delete("clenshaw_gaussian_test.diary.tmp");
diary clenshaw_gaussian_test.diary.tmp

strf="clenshaw_gaussian_test";

function ak=clenshaw(pf,n,a,b)
  % ak=clenshaw(pf,m,a,b)
  % Calculate the first m coefficients of a Chebyshev approximation to pf
  % on the interval [a,b]
  % pf - point to function y=pf(x)
  % n - number of coefficients
  % a,b - approximate pf over the interval [a,b]

  % Sanity checks
  if nargin<2 || nargin==3 || nargin>4 || nargout>1 
    print_usage("ak=clenshaw(pf,m,a,b)");
  endif
  if ~is_function_handle(pf)
    error("pf is not a function handle");
  endif
  if ~isscalar(n)
    error("n is not a scalar");
  endif
  if nargin==2
    a=-1;
    b=1;
  endif
  if ~isscalar(a)
    error("a is not a scalar");
  endif
  if ~isscalar(b)
    error("b is not a scalar");
  endif
  if a>=b
    error("a>=b");
  endif

  bma=(b-a)/2;
  bpa=(b+a)/2;
  rk=(0:(n-1));
  xk=cos(pi*(rk+0.5)/n);
  f=pf((xk*bma)+bpa);
  ak=zeros(1,n);
  for l=0:(n-1),
    ak(l+1)=(2/n)*sum(f.*cos(pi*l*(rk+0.5)/n));
  endfor
endfunction  
  
function y=evaluate_clenshaw(x,ak,a,b)
  % y=clenshaw(x,ak,a,b)
  % Evaluate the Clenshaw recurrence of a Chebyshev approximation
  % on the interval [a,b]
  % x -
  % ak - coefficients
  % a,b - approximate over the interval [a,b]

  % Sanity checks
  if nargin<2 || nargin==3 || nargin>4 || nargout>1
    print_usage("y=evaluate_clenshaw(x,ak,a,b)");
  endif
  if ~isscalar(x)
    error("x is not a scalar");
  endif
  if nargin==2
    a=-1;
    b=1;
  endif
  if ~isscalar(a)
    error("a is not a scalar");
  endif
  if ~isscalar(b)
    error("b is not a scalar");
  endif
  if a>=b
    error("a>=b");
  endif

  y=2*(x-a-b)/(b-a);
  d=0;dd=0;sv=0;
  n=length(ak);
  for k=(n-1):-1:0,
    lastd=d;
    d=(2*y*d)-dd+ak(k+1);
    ddd=dd;
    dd=lastd;
  endfor
  
  y=(d-ddd)/2;
  
endfunction
  
function y=evaluate_fixed_point_clenshaw(x,ak_fixed_point,a,b,max_num,max_acc)
  % y=evaluate_fixed_point_clenshaw(x,ak_fixed_point,a,b,max_num,max_acc)
  % Evaluate the Clenshaw recurrence of a Chebyshev approximation
  % on the interval [a,b] with fixed point arithmetic
  % x - 
  % ak_fixed_point - fixed-point coefficients
  % a,b - approximate pf over the interval [a,b]
  % max_num - maximum of coefficients
  % max_acc - maximum of accumulator

  % Sanity checks
  if nargin<2 || nargin==3 || nargin>6 || nargout>1
    print_usage ...
      ("y=evaluate_fixed_point_clenshaw(x,ak_fixed_point,a,b,max_num,max_acc)");
  endif
  if ~isscalar(x)
    error("x is not a scalar");
  endif
  if nargin<3
    a=-1;
    b=1;
  endif
  if ~isscalar(a)
    error("a is not a scalar");
  endif
  if ~isscalar(b)
    error("b is not a scalar");
  endif
  if a>=b
    error("a>=b");
  endif
  if nargin<5
    max_num=128;
  endif
  if nargin<6
    max_acc=16*max_num;
  endif

  y=2*(x-a-b)/(b-a);
  d=0;dd=0;ddd=0;sv=0;
  n=length(ak_fixed_point);
  for k=(n-1):-1:0,
    lastd=d;
    acc=(2*y*d)-dd+ak_fixed_point(k+1);
    if abs(acc)>(max_acc/max_num)
      error("abs(acc)(%g) > max_acc/max_num(%g)",acc,max_acc/max_num);
    endif
    d=round(acc*max_acc)/max_acc;
    ddd=dd;
    dd=lastd;
  endfor
  
  y=round((d-ddd)*max_num/2)/max_num;
  
endfunction

function y=gaussian_function(x)
  y=exp(-2*x.*x);
endfunction

num_coef=8;
a=-1;
b=1;
ak=clenshaw(@gaussian_function,num_coef,a,b);

bits=8;
bits_acc=10;
max_num=2^(bits-1);
max_acc=2^(bits_acc-1);
ak_fixed_point=round(ak*max_num)/max_num;

k=-1000:1000;
x=k/1000;
yexact=gaussian_function(x);

yapprox=zeros(size(x));
yapprox=zeros(size(x));
yapprox_fixed_point=zeros(size(x));
for l=1:length(x),
  yapprox(l)=evaluate_clenshaw(x(l),ak,a,b);
  yapprox_fixed_point(l)= ...
    evaluate_fixed_point_clenshaw(x(l),ak_fixed_point,a,b,max_num,max_acc);
endfor

%{
% Simple search for minimal fixed-point error 
ak_fixed_point_std=std(yexact-yapprox_fixed_point);
printf("ak_fixed_point_std=%10.8f\n",ak_fixed_point_std);
new_ak_fixed_point=ak_fixed_point;
new_ak_fixed_point_std=ak_fixed_point_std;
for k=1:2:num_coef,
  akm_fixed_point=new_ak_fixed_point;
  for m=-2:2,
    akm_fixed_point(k)=ak_fixed_point(k)+(m/max_num);
    for l=1:length(x),
      yapprox_fixed_point(l)= ...
        evaluate_fixed_point_clenshaw(x(l),akm_fixed_point,a,b,max_num,max_acc);
    endfor
    akm_fixed_point_std=std(yexact-yapprox_fixed_point);
    if akm_fixed_point_std<new_ak_fixed_point_std
      new_ak_fixed_point(k)=akm_fixed_point(k);
      new_ak_fixed_point_std=akm_fixed_point_std;
      printf("Found std=%10.8f,k=%d,m=%d\n",new_ak_fixed_point_std,k,m);
    endif
  endfor
endfor
ak_fixed_point=new_ak_fixed_point;
for l=1:length(x),
  yapprox_fixed_point(l)= ...
    evaluate_fixed_point_clenshaw(x(l),ak_fixed_point,a,b,max_num,max_acc);
endfor
%}

% Plot
subplot(211),plot(x,yapprox);
title("Chebyshev polynomial approximation to a Gaussian function");
ylabel("Amplitude");
grid("on");
subplot(212),plot(x,yexact-yapprox);
ylabel("Error");
xlabel("x");
grid("on");
print(strcat(strf,"_approx"),"-dpdflatex");
close;

subplot(211),plot(x,yapprox_fixed_point);
title("Chebyshev polynomial approximation to a Gaussian function with \
fixed point arithmetic");
ylabel("Amplitude");
grid("on");
subplot(212),plot(x,yexact-yapprox_fixed_point);
ylabel("Error");
xlabel("x");
grid("on");
print(strcat(strf,"_approx_fixed_point"),"-dpdflatex");
close;

% Save bits for use in tex documentation
fname=strcat(strf,"_bits.tab");
fid=fopen(fname,"wt");
fprintf(fid,"%d",bits);
fclose(fid);
fname=strcat(strf,"_bits_acc.tab");
fid=fopen(fname,"wt");
fprintf(fid,"%d",bits_acc);
fclose(fid);

% Save coefficients
print_polynomial(ak, "ak=", ...
                 strcat(strf,"_ak_coef.m"),"%13.10f");
print_polynomial(ak_fixed_point*max_num, "ak_fixed_point=", ...
                 strcat(strf,"_ak_fixed_point_coef.m"),"%4.1d");

save clenshaw_gaussian_test.mat ...
    num_coef a b ak bits bits_acc max_num max_acc ak_fixed_point ...
    k x yexact yapprox yapprox_fixed_point

% Done
diary off
movefile clenshaw_gaussian_test.diary.tmp clenshaw_gaussian_test.diary;
