function [tau iter]=goldensection(pf,x,d,fx,gxf,W,tol,maxiter,verbose)
% [tau iter]=goldensection(@f,x,d,fx,gxf,W,tol,maxiter,verbose)
% Golden section search for a minimum of function f
% Inputs:
%  pf : function pointer to f
%  x : initial point
%  d : direction vector from x
%  gxf : gradient of pf at x
%  W : approximation to Hessian (unused)
%  tol : tolerance
%  maxiter : maximum number of iterations allowed
%  verbose : show progress
% Outputs:
%  tau : step size to minimum
%  iter : Golden section iterations required to find tau

% Copyright (C) 2017,2018 Robert G. Jenssen
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

if nargin<6
  print_usage("[tau iter]=goldensection(@f,x,d,fx,gxf,W,tol,maxiter,verbose)");
endif
if nargin<7
  tol=1e-4;
endif
if nargin<8
  maxiter=100;
endif
if nargin<9
  verbose=false;
endif

% Initialise
q=(-1+sqrt(5))/2;
t=1-q;
iter=0;
tau=0;
dgxf=d'*gxf;

% Sanity checks
if norm(d)<=eps
  warning("goldensection(): norm(d)<=eps");
  return
endif
if dgxf>=tol
  warning("goldensection(): dgxf>=tol");
  tau=0.05;
  return;
endif

% Find first two points
alphak=0;
falphak=fx;
deltak=quadratic(pf,x,d,fx,gxf,[],tol,maxiter,verbose);
fdeltak=feval(pf,x+(deltak*d));

% Choose betak and gammak for golden section
[betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
[gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak);

% Echo
if verbose
  printf("\nInitial point:\n");
  printf("gxf= [ ");printf("%f ",gxf);printf("]\n");
  showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                   gammak,fgammak,deltak,fdeltak);
endif

% Find minimum with Golden Section search
do
  iter = iter+1;
  if iter>maxiter
    error("goldensection() iteration limit exceeded! Bailing out!");
  endif

  % Sanity checks
  if (alphak>=betak || betak>=gammak || gammak>=deltak)
    showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                     gammak,fgammak,deltak,fdeltak);
    error("alphak>=betak || betak>=gammak || gammak>=deltak");
  endif
  % Fudge to try and catch problems with non-quadratic functions
  nqiter=0;
  while (fbetak>falphak+tol) && (fbetak>fgammak+tol)
    nqiter=nqiter+1;
    if nqiter>3
      showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                       gammak,fgammak,deltak,fdeltak);
      error("Cannot cope with non-quadratic function");
    endif
    deltak=betak;
    fdeltak=fbetak;
    [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
    [gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak);
    warning("Reduced deltak for non-quadratic objective function!");
  endwhile
  % Fudge to try and catch problems with non-quadratic functions
  nqiter=0;
  while (fgammak>fbetak+tol) && (fgammak>fdeltak+tol)
    nqiter=nqiter+1;
    if nqiter>3
      showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                       gammak,fgammak,deltak,fdeltak);
      error("Cannot cope with non-quadratic function");
    endif
    deltak=gammak;
    fdeltak=fgammak;
    gammak=betak;
    fgammak=fbetak;
    [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
    warning("Reduced deltak for non-quadratic objective function!");
  endwhile
  if (fbetak>falphak+tol && fbetak>fdeltak+tol) || ...
        (fgammak>falphak+tol && fgammak>fdeltak+tol)
    showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                     gammak,fgammak,deltak,fdeltak);      
    error(strcat("fbetak>falphak+tol && fbetak>fdeltak+tol) || \n", ... 
                 "(fgammak>falphak+tol && fgammak>fdeltak+tol)"));
  endif

  % Select next endpoint
  if fbetak<fgammak
    if falphak>fbetak
      deltak=gammak;
      fdeltak=fgammak;
      gammak=betak;
      fgammak=fbetak;
      [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
    else
      deltak=betak;
      fdeltak=fbetak;
      [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
      [gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak);
    endif
  
  elseif fbetak>fgammak
    if fdeltak>fgammak
      alphak=betak;
      falphak=fbetak;
      betak=gammak;
      fbetak=fgammak;
      [gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak);
    else
      alphak=gammak;
      falphak=fgammak;
      [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
      [gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak);
    endif
  
  else
    alphak=betak;
    falphak=fbetak;
    deltak=gammak;
    fdeltak=fgammak;
    [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak);
    [gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak);
  endif

  % Echo
  if verbose
    printf("\nCurrent point:\n");
    showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                     gammak,fgammak,deltak,fdeltak);
  endif

  % Check termination
  fk=[falphak,fbetak,fgammak,fdeltak];
  err=max(fk)-min(fk);
until err<tol  

% Select tau
xk=[alphak,betak,gammak,deltak];
fk=[falphak,fbetak,fgammak,fdeltak];
[minfk,iminfk]=min(fk);
tau=xk(iminfk);

endfunction

function [betak,fbetak]=updateBetak(pf,x,d,t,alphak,deltak)
betak=alphak+t*(deltak-alphak);
fbetak=feval(pf,x+(d*betak));        
endfunction

function [gammak,fgammak]=updateGammak(pf,x,d,t,alphak,deltak)
gammak=deltak-t*(deltak-alphak);
fgammak=feval(pf,x+(d*gammak));        
endfunction

function showGoldenPoints(x,d,alphak,falphak,betak,fbetak, ...
                          gammak,fgammak,deltak,fdeltak)
printf("x= [ ");printf("%f ",x);printf("]\n");
printf("d= [ ");printf("%f ",d);printf("]\n");
printf("alphak= [ ");printf("%f ",alphak);
printf("] falphak = %f\n",falphak);
printf("betak=  [ ");printf("%f ",betak);
printf("] fbetak  = %f\n",fbetak);
printf("gammak= [ ");printf("%f ",gammak);
printf("] fgammak = %f\n",fgammak);
printf("deltak= [ ");printf("%f ",deltak);
printf("] fdeltak = %f\n",fdeltak);
endfunction
