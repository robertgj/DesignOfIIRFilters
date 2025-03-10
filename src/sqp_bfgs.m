function [x,fx,lm,iter,liter,feasible] = ...
         sqp_bfgs(x0,pfx,pgx,linesearchName,xlb,xub,dmax, ...
                  H0,hessianType,maxiter,ftol,ctol,verbose)
% [x,fx,lm,iter,liter,feasible]=sqp_bfgs(x0,pfx,pgx,linesearchName,...
%   xlb,xub,dmax,H0,hessianType,maxiter,ftol,ctol,verbose)
%
% Input arguments:
% x0 - initial point
% pfx - pointer to objective function taking argument x. Returns
%          [ function_value constraint_vector function_hessian_matrix ]
%        or, for line-search, just [ function_value ]
% pgx - pointer to constraint function taking argument x. Returns
%          [ fconstraint_vector constraint_gradient_matrix ]
%        or, for line-search, just [ constraint_vector ]
% linesearchName - linesearch function name (one of 
%                  [quadratic,armijo,goldstein, goldensection])
% xlb - lower bounds on x
% xub - upper bounds on x
% dmax - maximum allowed step change in x
% H0 - initial Hessian estimate
% hessianType - Hessian update type [exact,bfgs,diagonal,eye] 
%               If "eye" then the Hessian is initialised with the unit 
%               matrix and updated with the BFGS formula.
% maxiter - maximum iterations 
% ftol - tolerance on function value
% ctol - tolerance on constraints
% verbose - logging
%
% Outputs:
% x - minimum
% fx - function value at minimum
% lm - Lagrange multipliers at x
% iter - loop iteration count
% liter - linesearch function iteration count
% feasible - solution satisfies Karush-Kuhn-Tucker conditions
%
% Hessian approximation initialises the Hessian with "eye" and updates
% with the BFGS formula. Line search type "quadratic" finds the
% minimum of a quadratic approximation to the Lagrangian.
%
% The linesearchName function has arguments:
%  f - pointer to Lagrangian function
%  x - current coefficient value
%  d - step direction from x
%  fx - Lagrangian function value at x
%  gxf - gradient of Lagrangian function at x
%  W - Hessian approximation at x
%  maxiter - maximum linesearch iterations
%  ftol - tolerance on function value
%  ctol - tolerance on constraints
%  verbose - show results
%
% The linesearch Lagrangian function, sqp_Lfunction, takes a coefficient
% value, x, as an argument and returns the Lagrangian value.

% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Globals used by the linesearch function, sqp_exactL
global sqp_pfx sqp_pgx sqp_liter sqp_lm sqp_xub sqp_xlb

% Check input argument list
if (nargin ~= 13) && (nargout ~= 6)
  print_usage(strcat(["[x, fx, lm, iter, liter,feasible]= ...\n", ...
 "sqp_bfgs(x0,pfx,pgx,linesearchName,xlb,xub,dmax,H0,hessianType, ...\n", ...
 "maxiter,ftol,ctol,verbose)"]));
endif

% Sanity checks
if (ftol >= 0.5) || (ftol <= 0.0)
  error("expected 0 < ftol < 0.5!");
endif
if (ctol >= 0.5) || (ctol <= 0.0)
  error("expected 0 < ctol < 0.5!");
endif
if (~isempty(xlb) && (length(xlb) ~= length(x0)))
  error("length(xlb) ~= length(x0)!");
endif
if (length(xlb) == length(x0))
  if any(x0(:)<(xlb(:)-ftol))
    printf("x0=[");printf("%f ",x0);printf("]\n");
    printf("xlb=[");printf("%f ",xlb);printf("]\n");
    error("x0 < lower bound !");
  endif
endif
if (~isempty(xub) && (length(xub) ~= length(x0)))
  error("length(xub) ~= length(x0)!");
endif
if (length(xub) == length(x0))
  if any(x0(:)>(xub(:)+ftol))
    printf("x0=[ ");printf("%f ",x0);printf("]\n");
    printf("xub=[ ");printf("%f ",xub);printf("]\n");
    error("x0 > upper bound !");
  endif
endif

% Initialise
sqp_pfx=pfx;
sqp_pgx=pgx;
sqp_liter=0;
sqp_xub=xub(:);
sqp_xlb=xlb(:);
x=x0(:);
N=length(x);
iter=0;
feasible=false;
bestfx=inf;
bestx=x0;
min_delta=1e-8;
min_rcond_allowed=1e-7;
min_rcond_found=inf;

% Initialise function, gradient and Hessian (or approximation)
if iscell(H0) && ...
   length(H0)==2 && ...
   size(H0{1})==[length(x0),length(x0)] && ...
   size(H0{2})==[length(x0),length(x0)]
  W=H0{1};
  invW=H0{2};
  [fx,gxf]=feval(sqp_pfx, x);
  hxxf=eye(N,N);
elseif ismatrix(H0) && size(H0)==[length(x0),length(x0)]
  if rank(H0)~=length(x0)
    error("H0 is singular");
  endif
  W=H0;
  invW=inv(W);
  [fx,gxf]=feval(sqp_pfx, x);
  hxxf=eye(N,N);
elseif strcmpi(hessianType,"bfgs") || strcmpi(hessianType,"exact")
  [fx,gxf,hxxf]=feval(sqp_pfx, x);
  [W,invW]=updateWchol(hxxf,1);
elseif strcmpi(hessianType,"diagonal")
  [fx,gxf,hxxf]=feval(sqp_pfx, x);
  W=diag(diag(hxxf));
  invW=inv(W);
elseif strcmpi(hessianType,"eye")
  [fx,gxf]=feval(sqp_pfx, x);
  hxxf=eye(N,N);
  W=hxxf;
  invW=W;
else
  error("Unknown hessian update type");
endif

% Linesearch
psearch=str2func(linesearchName);
if verbose
  printf("x0 = [ "); printf("%f ",x0); printf("]\n");
  printf("Hessian approximation=%s linesearch=%s\n", ...
           hessianType,linesearchName);
endif

% Initialise constraints  
[gx,gxg]=feval(sqp_pgx, x);
gx=[ gx; x-sqp_xlb; sqp_xub-x; ];
gxg=[ gxg, eye(N,N), -eye(N,N) ];
sqp_lm=zeros(length(gx),1);

% Sequential Quadratic Programming (SQP) loop
while 1

  iter=iter+1;
  
  % Find the active constraints
  %
  % The obvious thing to put here is "Ax=find(gx<ctol);" However,
  % when the trajectory approaches an optimum from outside the 
  % constrained area (or starts on the boundary) the gradient
  % of the Lagrangian, and hence d, may be very small at the 
  % boundary. For these cases we may end up with a negative
  % multiplier but make no move to reduce it to zero. Such a
  % multiplier component implies that the global unconstrained 
  % minimum lies within the corresponding constraint and that
  % constraint should be dropped.
  Ax=find((sqp_lm>-ctol).*(gx<ctol));
  if verbose
    printf("At x = [ ");printf("%f ",x);
    printf("] active constraints are [ ");printf("%d ",Ax);printf("]\n");
  endif
  
  % Solve for the Lagrange multipliers at the active constraints 
  if isempty(Ax)
    sqp_lm=zeros(length(gx),1);
  else
    gxginvWgxg=gxg(:,Ax)'*invW*gxg(:,Ax);
    rcondgxginvWgxg=rcond(gxginvWgxg);
    if min_rcond_allowed > rcondgxginvWgxg;
      disp("diag(invW)=");disp(diag(invW));
      disp("gxg(all,Ax)=");disp(gxg(:,Ax));
      disp("gxginvWgxg=");disp(gxginvWgxg);
      error("rcond(gxginvWgxg)(%g)<%g",rcondgxginvWgxg,min_rcond_allowed);
    endif
    if min_rcond_found > rcondgxginvWgxg
      min_rcond_found=rcondgxginvWgxg;
    endif
    invgxginvWgxg=invSVD(gxginvWgxg);
    lmA=-invgxginvWgxg*(gx(Ax)-(gxg(:,Ax)'*invW*gxf)); 
    sqp_lm=zeros(length(gx),1);
    sqp_lm(Ax)=lmA;
  endif

  % Find the Lagrangian and gradient
  L=fx-gx'*sqp_lm;
  gxL=gxf-gxg*sqp_lm;

  % Find the step direction
  d=-invW*gxL;
  if any(isnan(d))
    error("isnan(d) found!");
  endif

  % Make sure step-size is less than dmax
  if norm(d)>dmax
    d=dmax*d/norm(d);
    if verbose
      printf("Adjusted d = [ "); printf("%f ",d); printf("]\n");
    endif
  endif
  
  % Make sure the step size fits within the constraints
  while (any((x+d)<(sqp_xlb-ctol)) || any((x+d)>(sqp_xub+ctol)))
    d=d/2;
    if (norm(d)<(ftol^2))
      lm=sqp_lm;
      liter=sqp_liter;  
      error("Searching for d within constraints but norm(d)<ftol^2!");
      return
    endif
  endwhile

  % Find step size that minimises the objective
  if verbose
    printf("Starting line search:\n");
    printf("x = [ "); printf("%f ",x); printf("]\n");
    printf("d = [ "); printf("%f ",d); printf("]\n");
    printf("norm(d) = %f\n",norm(d));
    printf("fx = %f\n",fx);
    printf("gx' = [ ");printf("%f ",gx');printf("]\n");
    printf("gxf' = [ ");printf("%f ",gxf');printf("]\n");
    printf("sqp_lm' = [ "); printf("%f ",sqp_lm'); printf("]\n");
    printf("gxL = [ ");printf("%f ",gxL);printf("]\n");
    printf("L = %f\n",L);
  endif
  [tau,liter]=feval(psearch,@sqp_Lfunction,x,d,L,gxL,W,ftol,maxiter,verbose);
  if verbose
    printf("Found tau=%f using %s search(%d) of Lagrangian\n", ...
           tau,linesearchName,liter);
  endif

  % Update delta
  delta=tau*d;
  if verbose
    if norm(delta)<min_delta
      warning("sqp_bfgs: norm(delta)(%g)<%g",norm(delta),min_delta);
    endif
  endif

  % Update x
  x=x+delta;

  % Update Hessian approximation and gradient of Lagrangian
  if strcmpi(hessianType,"exact")
    [fx,gxf,hxxf]=feval(sqp_pfx,x);
    [gx,gxg]=feval(sqp_pgx,x);
    gx=[ gx; x-sqp_xlb; sqp_xub-x; ];
    gxg=[ gxg, eye(N,N), -eye(N,N) ];
    gxL=gxf-gxg*sqp_lm;
    W=hxxf;
    invW=inv(W); 
  elseif strcmpi(hessianType,"diagonal") % only use diagonal of Hessian
    [fx,gxf,hxxf]=feval(sqp_pfx,x);
    [gx,gxg]=feval(sqp_pgx,x);
    gx=[ gx; x-sqp_xlb; sqp_xub-x; ];
    gxg=[ gxg, eye(N,N), -eye(N,N) ];
    gxL=gxf-gxg*sqp_lm;
    W=diag(diag(hxxf));
    invW=inv(W);
  elseif strcmpi(hessianType,"bfgs") || ...
         strcmpi(hessianType,"eye")      % use BFGS approximation
    [fx,gxf]=feval(sqp_pfx,x);
    hxxf=eye(N,N);
    [gx,gxg]=feval(sqp_pgx,x);
    gx=[ gx; x-sqp_xlb; sqp_xub-x; ];
    gxg=[ gxg, eye(N,N), -eye(N,N) ];
    oldgxL=gxL;
    gxL=gxf-gxg*sqp_lm;
    gamma=gxL-oldgxL;
    [W,invW]=updateWbfgs(delta,gamma,W,invW,min_delta,verbose);
  else
    error("Expect Hessian update \"eye\",\"exact\",\"diagonal\" or \"bfgs\"");
  endif

  % Track best result
  if fx<bestfx
    bestx=x;
    bestfx=fx;
  endif

  % Sanity check
  if any(isinf(fx)) || any(isinf(gxf)) || ...
     any(isinf(hxxf)) || any(isinf(gx)) || ...
     any(isinf(gxg)) || any(isinf(W)) ||any(isinf(W)) 
    error("found inf value!");
  elseif any(isnan(fx)) || any(isnan(gxf)) || ...
         any(isnan(hxxf)) || any(isnan(gx)) || ...
         any(isnan(gxg)) || any(isnan(W)) ||any(isnan(W)) 
    error("found nan value!");
  endif
  % Check for positive definite W
  if verbose
    P=isdefinite(W,ftol);
    if P==-1
      warning("W is not positive (semi-)definite!");
    endif
  endif

  % Test for optimality with Karush-Kuhn-Tucker conditions
  if verbose
    printf("Test KKT at x = [ ");printf("%f ",x);printf("]\n");
    printf("delta = [ ");printf("%f ",delta);printf("]\n"); 
    printf("fx = %f\n",fx);
    printf("gx' = [ ");printf("%f ",gx');printf("]\n");
    printf("gxL = [ ");printf("%f ",gxL);printf("]\n");
    printf("sqp_lm' = [ ");printf("%f ",sqp_lm');printf("]\n");
    printf("sqp_lm'*gx = %f\n",sqp_lm'*gx);
    printf("min_rcond_found = %g\n",min_rcond_found);
  endif
  if (norm(gxL)<ftol) && (min(sqp_lm)>-ftol) && (abs(sqp_lm'*gx)<ftol)
    feasible=true;
    if verbose
      printf("Solution satisfying KKT conditions found\n");
      printf("%d iterations %s Hessian update %d %s linesearch calls\n", ...
             iter,hessianType,sqp_liter,linesearchName);
    endif
    break;
  elseif iter>=maxiter
    x=bestx;
    fx=bestfx;
    error("Iteration limit(%d) exceeded. Bailing out!\n",maxiter);
    break;
  endif

endwhile

% Done
lm=sqp_lm;
liter=sqp_liter;  

endfunction

function Lxtd=sqp_Lfunction(xtd)
  global sqp_pfx sqp_pgx sqp_liter sqp_lm sqp_xub sqp_xlb
  sqp_liter=sqp_liter+1;
  fx=feval(sqp_pfx,xtd);
  gx=feval(sqp_pgx,xtd);
  gx=[ gx; xtd-sqp_xlb; sqp_xub-xtd ];
  Lxtd=fx - (gx'*sqp_lm);
endfunction
