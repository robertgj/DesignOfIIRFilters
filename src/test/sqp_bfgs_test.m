% Example of non-linear quasi-newton optimisation using BFGS update
% An optimum is at x=[-sqrt(2); 1; -0.527];

% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="sqp_bfgs_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

sqp_common;

global fiter;

function [tau,iter]=nosearch(pf,x,d,fx,gxf,W,tol,maxiter,verbose)
  tau=1;
  iter=0;
endfunction

% Initialise 
ftol=1e-3
ctol=ftol;
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
        if strcmpi(initType{1},"GI")
          [x,W,invW,iter,feasible] = ...
            goldfarb_idnani(x,@sqp_fx,@sqp_gx,ftol,maxiter,verbose);
          [W,invW]=updateWchol(W,1);
        elseif strcmpi(initType{1},"eye")
          W=invW=eye(N,N);
        else
          W=invW=[];
        endif
        
        % SQP loop
        tic();
        [x,fx,lm,iter,liter,feasible] = ...
            sqp_bfgs(x,@sqp_fx,@sqp_gx,linesearchType{1},lbx,ubx,inf, ...
                     {W,invW},hessianType{1},maxiter,ftol,ctol,verbose);
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
                 initType{1},elapsedTime,iter,fiter);
          printf("%s Hessian approximation, %d %s linesearch calls\n", ...
                 hessianType{1},liter,linesearchType{1});
        endif
        
        printf("SQP %s %s %s ",initType{1},hessianType{1},linesearchType{1}); 
        printf("[ ");printf("%f ",x);printf("] ");
        printf("%d %d %d %d\n",feasible,iter,fiter,liter);
        
      catch
        err=lasterror();
        printf("SQP %s %s %s :\n %s\n", ...
               initType{1}, hessianType{1}, linesearchType{1},err.message);
        for e=1:length(err.stack)
          printf("Called from %s at line %d\n", ...
                 err.stack(e).name, err.stack(e).line);
        endfor
        return;
      end_try_catch
    endfor
  endfor
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
