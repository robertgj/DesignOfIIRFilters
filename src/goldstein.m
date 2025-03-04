function [tau iter]=goldstein(pf,x,d,fx,gxf,W,tol,maxiter,verbose)
% [tau iter]=goldstein(@f,x,d,fx,gxf,W,tol,maxiter,verbose)

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
  print_usage("[tau iter]=goldstein(@f,x,d,fx,gxf,W,tol,maxiter,verbose)");
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
iter=0;
c1=0.1;
c2=1-c1;
R=2;
tau=1;
dgxf=d'*gxf;

newf = feval(pf,x+(tau*d));
delta1f = c1*tau*dgxf;
while newf > (fx+delta1f)
  iter=iter+1;
  if iter>maxiter
    error("goldstein() rule 1 iteration limit exceeded! Bailing out!");
  endif
  tau=tau/R;
  newf = feval(pf,x+(tau*d));
  delta1f = c1*tau*dgxf;
  if verbose && delta1f<tol
    warning("goldstein() rule 1: delta1f<tol!");
  endif 
endwhile

newf = feval(pf,x+(tau*d));
delta2f = c2*tau*dgxf;
while newf < (fx+delta2f)
  iter=iter+1;
  if iter>maxiter
    error("goldstein() rule 2 iteration limit exceeded! Bailing out!");
  endif
  tau=tau*R;
  newf = feval(pf,x+(tau*d));
  delta2f = c2*tau*dgxf;
  if verbose && delta2f<tol
    warning("goldstein() rule 2: delta2f<tol!");
  endif 
endwhile

endfunction
