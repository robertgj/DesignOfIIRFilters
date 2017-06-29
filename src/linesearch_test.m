% Example of line search using golden section, armijo or Goldstein test
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("linesearch_test.diary");
unlink("linesearch_test.diary.tmp");
diary linesearch_test.diary.tmp

sqp_common;

global fiter

function [tau iter]=nosearch(x,d,fx,gxf,W,tol,maxiter,verbose)
  tau=1;
  iter=0;
endfunction

function doSQP(searchType)

  global fiter

  verbose=false;
  maxiter=1000;
  iter=0;
  fiter=0;
  tol=1e-4;

  tic();
  x=[30;-20;10];
  fx=f(x);
  gxf=gradxf(x);
  H=hessxxf(x);
  [W,invW]=updateWchol(H,1);
  do
    % Sanity check
    iter=iter+1;
    if isdefinite(W)!=1
      error("W not positive definite");
    elseif iter>=maxiter
      error("Iteration limit exceeded. Bailing out!");
      break;
    endif

    % Linesearch for step size at minimum
    d=-invW*gxf;
    [tau liter]=feval(str2func(searchType),@f,x,d,fx,gxf,W,tol,maxiter,false);

    % Step along d
    delta=tau*d;
    if verbose
      floatPrint("Step using tau =",tau);
      floatPrint("  x =",x);
      floatPrint("  d =",d);
    endif
    x=x+delta;
    lastfx=fx;
    fx=f(x);
    if fx>lastfx+tol
      warning("tau=%f,x=[ %s],fx=%f,\nlastx=[ %s],lastfx=%f", ...
              tau,sprintf("%f,",x),fx,sprintf("%f,",x-delta),lastfx),
      warning("fx-lastfx=%f at iter %d (fx increasing!)", fx-lastfx,iter);
    endif  

    % Update W
    lastgxf=gxf;
    gxf=gradxf(x);
    [W,invW]=updateWbfgs(delta,gxf-lastgxf,W,invW);

    % Test
    iter=iter+1;
    if iter>maxiter
      warning("Iteration limit exceeded. Bailing out!");
    endif

  until norm(delta)<tol && abs(fx-lastfx)<tol
  elapsedtime=toc();

  floatPrint("At x = ",x);
  printf("f(x) = %f, %f secs\n",fx, elapsedtime);
  printf("LINESEARCH %s %d iterations %d f(x) calls\n",searchType,iter,fiter);
  printf("LINESEARCH %s f(x)= %f",searchType,fx);
  printf(" x=[ ");printf("%f ",x);printf(" ]\n");
endfunction

searchTypes={"nosearch","armijo","armijo_kim", ...
             "goldstein","goldensection","quadratic"};

for k=1:length(searchTypes)
  printf("\nTesting %s linesearch:\n", searchTypes{k});
  try 
    doSQP(searchTypes{k});
  catch
    printf("%s linesearch failed: %s\n", searchTypes{k},lasterror.message);
  end_try_catch
endfor

diary off
movefile linesearch_test.diary.tmp linesearch_test.diary;
