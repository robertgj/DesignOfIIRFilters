function [tau iter]=armijo_kim(pf,x,d,fx,gxf,W,tol,maxiter,verbose)
% [tau iter]=armijo_kim(@f,x,d,fx,gxf,W,tol,maxiter,verbose)

% Copyright (C) 2017 Robert G. Jenssen
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
  print_usage("[tau iter]=armijo_kim(@f,x,d,fx,gxf,W,tol,maxiter,verbose)");
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
iter=1;
sigma=1;
beta=0.5;
c1=0.01;
tau=sigma;
dgxf=d'*gxf;

% Look for tau satisfying the modified armijo rule
newf = feval(pf,x+(d*tau));
deltaf = (c1*tau*(dgxf+(d'*W*d)));
while newf > (fx+deltaf)
  if iter>=maxiter
    error("armijo_kim() iteration limit exceeded! Bailing out!");
  endif
  iter = iter+1;
  tau=tau*beta;
  newf = feval(pf,x+(d*tau));
  deltaf = (c1*tau*(dgxf+(d'*W*d)));
  if verbose && deltaf<100*eps
    warning("armijo_kim() deltaf<100*eps!");
  endif
endwhile

endfunction
