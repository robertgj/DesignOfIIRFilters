% Example of non-linear quasi-newton optimisation using BFGS update
% Copyright (C) 2017,2018 Robert G. Jenssen
% An optimum is at x=[-sqrt(2); 1; -0.527];

test_common;

unlink("sqp_bfgs_test.diary");
unlink("sqp_bfgs_test.diary.tmp");
diary sqp_bfgs_test.diary.tmp

format compact

sqp_common;

global fiter;

function [tau,iter]=nosearch(x,d,fx,gxf,tol,maxiter)
  tau=1;
  iter=0;
endfunction

% Initialise 
tol=1e-3
maxiter=400
verbose=true
iter=0;
fiter=0;

if verbose
  printf("Initial x = [ ");printf("%f ",xi);printf("]\n");
endif
N=length(xi);

% SQP loop
printf("SQP init hessian linesearch ");
printf("x feasible iter fiter liter\n");
for initType={"GI","eye","none"}
  for hessianType = {"exact","bfgs","diagonal","eye"}
    for linesearchType = ...
          {"nosearch","quadratic","armijo","armijo_kim", ...
           "goldstein","goldensection"}
      try
 
        % Find a feasible initial point and Hessian
        fiter=0;
        x=xi;
        if strcmpi(initType{},"GI")
          [x,W,invW,iter,feasible] = ...
            goldfarb_idnani(x,@sqp_fx,@sqp_gx,tol,maxiter,verbose);
          [W,invW]=updateWchol(W,1);
        elseif strcmpi(initType{},"eye")
          W=invW=eye(N,N);
        else
          W=invW=[];
        endif
        
        % SQP loop
        tic();
        [x,fx,lm,iter,liter,feasible] = ...
            sqp_bfgs(x,@sqp_fx,@sqp_gx,linesearchType{},lbx,ubx,inf, ...
                     {W,invW},hessianType{},tol,maxiter,verbose);
        elapsedTime=toc();
        if feasible == 0
	        error("infeasible\n");
	      endif
        % Print result
        if verbose
          [fx,gxf,hxxf]=sqp_fx(x);
          [gx,gxg]=sqp_gx(x);
          gx=[ x-lbx; ubx-x; gx ];
          gxg=[ eye(N,N), -eye(N,N), gxg ];
          gxL=gxf-gxg*lm;
          floatPrint("x = ",x); 
          floatPrint("f(x) = ",fx); 
          floatPrint("lm = ",lm); 
          floatPrint("g(x) = ",gx);
          floatPrint("lm'*g(x) = ",lm'*gx);
          floatPrint("gradxL = ",gxL); 
          printf("%s %f secs, %d iterations, %d f(x) calls\n", ...
                 initType{},elapsedTime,iter,fiter);
          printf("%s Hessian approximation, %d %s linesearch calls\n", ...
                 hessianType{},liter,linesearchType{});
        endif
        
        printf("SQP %s %s %s ",initType{},hessianType{},linesearchType{}); 
        printf("[ ");printf("%f ",x);printf("] ");
        printf("%d %d %d %d\n",feasible,iter,fiter,liter);
        
      catch
        printf("SQP %s %s %s :\n %s\n", ...
               initType{}, hessianType{}, linesearchType{},lasterror.message);
        err=lasterror();
        for e=1:length(err.stack)
          printf("Called from %s at line %d\n", ...
                 err.stack(e).name, err.stack(e).line);
        endfor
        return;
      end_try_catch
    endfor
  endfor
endfor

diary off
movefile sqp_bfgs_test.diary.tmp sqp_bfgs_test.diary;
