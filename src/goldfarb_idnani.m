function [x,W,invW,iter,feasible]=goldfarb_idnani(x0,pfx,pgx,tol,maxiter,verbose)
% function [x,W,invW,iter,feasible] = ...
%   goldfarb_idnani(x0,pfx,pgx,tol,maxiter,verbose)
% x0         initial point
% pfx        pointer to objective function taking argument x and returning
%               1. function value at x
%               2. function gradient at x
%               3. Hessian (or Hessian approximation) at x
% pgx        pointer to constraint function taking argument x and returning
%               1. constraint vector at x
%               2. matrix of columns of constraint gradients at x
% tol        a small number
% maxiter    maximum iterations
% 
% x          a feasible point satisfying the constraints
% W          updated Hessian approximation at x using the BFGS formula
% invW       inverse of updated W
% iter       loop iterations
% 
% Given an initial point find a feasible point subject to the constraints.
% Note that the feasible point is not necessarily a global optimum, but it
% can be used to start a search of points in the interior of the feasible
% region. If no feasible point is found x=NaN is returned.
%
% Reference: "A Strictly Stable Dual Method for Solving Strictly 
% Convex Quadratic Programs", D. Goldfarb and A. Idnani, Mathematical 
% Programming 27 (1983) pp. 1-33

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

if nargin ~= 6 || nargout ~= 5
  print_usage(...
    "[x,W,invW,iter,feasible]=goldfarb_idnani(x0,pfx,pgx,tol,maxiter,verbose)");
endif

% Step 0: Unconstrained minimum
feasible=false;
iter=0;
if verbose
  printf("Initial x0 = [ ");
  printf("%f ",x0);
  printf("]\n");
endif
x=x0;
[fx,gxf,hxxf]=feval(pfx,x);
[gx,B]=feval(pgx,x);

% Step 1: Choose constraints
[W invW]=updateWchol(hxxf,1);
L=chol(W)';
invL=inv(L);
Kx0=1:length(gx);
Kx=Kx0;
Ax=[];
q=0;
lm=[];
z=[];
r=[];
Bstar=[];
E=invW;
while 1

  iter=iter+1;
  if iter>=maxiter
    error("Too many iterations. Bailing out\n");
  endif
  if verbose
    printf("Active constraints are [ "); printf("%d ",Ax); printf("]\n");
  endif
  
  % Check termination condition.
  if ~isempty(setdiff(Kx0,[Kx,Ax]))
    error("Expected Kx0 == sort(union(Kx,Ax))!")
  endif
  V=find(gx(Kx)<-tol);
  if isempty(V)
    feasible=true;
    if verbose
      printf("All constraints satisfied. Feasible solution found.\n");
    endif
    break;
  endif

  % Check violated constraints
  [mingV,imingV]=min(gx(V));
  p=Kx(V(imingV));
  np=B(:,p);
  lmp=[lm;0];
  if verbose
    printf("Step 1: Trying constraint %d at g(%d) = [ ",p,p);
    printf("%f ",gx(p)); printf("]\n");
  endif
  
  isdef=isdefinite(W);
  if isdef == 0
    feasible=false;
    warning("W is positive semi-definite!");
    break;
  elseif isdef == -1
    error("W is not positive definite or semi-definite!");
  endif

  % Step 2: Check feasibility
  while 1
  
    % Step 2a: Determine step direction
    [r d]=updaterd(W,B(:,Ax),np);
    if verbose
      printf("Step 2a: step direction in primal space d = [ ");
      printf("%f ",d); printf("]\n");
    endif
    if q>0
      if verbose
        printf("Step 2a: step direction in dual space r = [ ");
        printf("%f ",r); printf("]\n");
      endif
    endif

    % Step 2b: Compute step length
  
    % i: Partial step length, t1
    if q==0 || all(r<=0)
      t1=inf;
    else
      irp=find(r>0);
      [t1,it1]=min((lmp(irp)./r(irp)));
      kAx=irp(it1);
      if verbose
        printf("Step 2b)i): partial step length t1 = %f\n",t1);
      endif
    endif
  
    % ii: Full step length, t2
    if norm(d)<min(tol,sqrt(eps))
      t2=inf;
    else
      t2=-gx(p)/(d'*np);
      if verbose
        printf("Step 2b)ii): full step length t2 = %f\n",t2);
      endif
    endif
  
    % iii: Step length, t
    t=min(t1,t2);
    if verbose
      printf("Step 2b)iii): selecting step length t = %f\n",t);
    endif
  
  
    % Step 2c: Determine new solution and take step
  
    % i: No step
    if isinf(t)
      x=nan;
      error("Step 2c)i): problem is infeasible!");
    endif
  
    % ii: Step in dual space
    if isinf(t2)
      % Drop constraint k from Ax
      if verbose
        printf("Step 2c)ii): step in dual space. Dropping constraint %d\n",
               Ax(kAx));
      endif
      lmp=lmp+t*[-r;1];
      Kx=[Kx Ax(kAx)];
      lmp(kAx)=[];
      Ax(kAx)=[];
      q=q-1;
      continue;
    endif
  
    % iii: Step in primal and dual space
    if verbose
      printf("Step 2c)iii): Step in primal and dual space.\n");
    endif
    delta=t*d;
    x=x+delta;
    lmp=lmp+t*[-r;1];
    lastgxf=gxf;
    [gx,B]=feval(pgx,x);
    [fx,gxf]=feval(pfx,x);
    if verbose
      printf("Next x = [ "); printf("%f ",x); printf("]\n");
      printf("f(x) =%f\n",fx);
    endif
    % Powells update to W and invW
    gamma=gxf-lastgxf;
    [W,invW]=updateWbfgs(delta,gamma,W,invW);
  
    % Update 
    if t==t2
      % Add constraint p to Ax
      if verbose
        printf("Adding constraint %d\n",p);
      endif
      lm=lmp;
      Ax=[Ax p];
      ipKx=find(Kx==p);
      Kx(ipKx)=[];
      q=q+1;
      break;
    elseif t==t1
      % Drop constraint k from Ax
      if verbose
        printf("Dropping constraint %d\n",Ax(kAx));
      endif
      Kx=[Kx Ax(kAx)];
      lmp(kAx)=[];
      Ax(kAx)=[];
      q=q-1;
      continue;
    endif

  endwhile % Step 2

endwhile % Step 1

endfunction

function [r d]=updaterd(W,B,np)
% function [r d]=updaterd(W,B,np)
% W    positive definite Hessian approximation
% B    matrix with columns of active constraint gradients
% np   new constraint gradient
% r    dual-space direction vector
% d    primal space direction vector
%
% Use the QR decomposition to update r and d. Addition of
% constraints can use Givens rotations for efficiency. 

  L=chol(W)';
  invL=inv(L);
  C=invL*B;
  [Q R]=qr(C);
  if rows(Q)==0
    Q=eye(size(L));
  endif

  JJ=(invL')*Q;
  v=JJ'*np;

  q=columns(B);
  R=R(1:q,:);
  invR=inv(R);
  JJ1=JJ(:,1:q);
  Bstar=invR*JJ1';

  n=columns(L);
  JJ2=JJ(:,(q+1):n); 
  E=JJ2*JJ2';

  r=invR*v(1:q);
  d=JJ2*v((q+1):n);

endfunction
