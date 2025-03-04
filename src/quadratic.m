function [tau iter]=quadratic(pf,x,d,fx,gxf,W,tol,maxiter,verbose)
% [tau iter]=quadratic(pf,x,d,fx,gxf,W,tol,maxiter,verbose)
% Quadratic interpolation for linesearch
% Inputs:
%  pf : function pointer to f
%  x : initial point
%  d : direction vector from x
%  fx : f(x)
%  gxf : gradient of f at x
%  W : Hessian approximation at x (unused)
%  tol : tolerance
%  maxiter : maximum number of iterations allowed
%  verbose : show working
% Outputs:
%  tau : step size to minimum
%  iter : Golden section iterations required to find tau

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

if nargin<6
  print_usage("[tau iter]=quadratic(@f,x,d,fx,gxf,W,tol,maxiter,verbose)");
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

iter=1;
a=feval(pf,x+d)-(d'*gxf)-fx;
if verbose && (a<=tol)
  warning("2nd deriv(%g)<=tol x=[%s] ", a, sprintf("%f ",x));
  tau=1;
else
  tau=-(d'*gxf)*0.5/a;
endif

% Fudge factor to avoid "over-shoot" with problems that are not quadratic
tau=tau/2;

endfunction;
