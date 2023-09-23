function [hM,fext,fiter,feasible]= ...
         hofstetterFIRsymmetric(f0,A0,nf,max_iter,tol)
% [hM,fext,fiter,feasible]=hofstetterFIRsymmetric(f0,A0,nf,max_iter,tol)
% Implement Hofstetter's algorithm for the design of a linear-phase FIR
% filter with given pass-band and stop-band ripples.
%
% Inputs:
%   f0 - list of initial mini-max frequencies in [0,0.5]
%   A0 - desired amplitude responses at mini-maxfrequencies in f0
%   nf - number of interpolation frequency points used to evaluate error
%   max_iter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hM - M+1 distinct coefficients [h(1),...,h(M+1)]
%   fext- extremal frequencies
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints

% Copyright (C) 2019-2023 Robert G. Jenssen
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

  if (nargin < 2) || (nargin > 5) || (nargout>4)
    print_usage("hM=hofstetterFIRsymmetric(f0,A0)\n\
hM=hofstetterFIRsymmetric(f0,A0,nf)\n\
[hM,fext,fiter,feasible]=hofstetterFIRsymmetric(f0,A0,nf,max_iter,tol)");
  endif

  % Sanity checks
  if nargin<5
    tol=1e-8;
  endif
  if nargin<4
    max_iter=100;
  endif
  M=length(f0)-1;
  if nargin<3
    nf=100*M;
  endif
  if any(size(f0)~=size(A0))
    error("any(size(f0)~=size(A0))");
  endif

  % Initialise
  hM=[];
  fext=[];
  fiter=0;
  feasible=false;
  
  % Initial mini-max frequency-amplitude pairs
  f=f0(:)';
  A=A0(:)';
  % Convert the initial mini-max frequencies to the cos(omega) domain
  x=cos(2*pi*f);
  lastx=x;
  % Fixed interpolation frequencies in the cos(omega) domain
  xi=cos(pi*(0:nf)/nf);
  
  % Loop performing Hofstetter's algorithm
  for fiter=1:max_iter

    % Lagrange interpolation
    Ai=lagrange_interp(x,A,[],xi);
      
    % Choose new extremal values
    maxAi=local_max(Ai);
    minAi=local_max(-Ai);
    eindex=unique([maxAi(:);minAi(:)]);
    if length(eindex)~=(M+1)
      error("length(eindex)~=(M+1)");
    endif
    x=xi(eindex);

    % Test convergence
    delx=norm(x-lastx);
    lastx=x;
    if delx<tol
      hM=xfr2tf(M,x,A,tol);
      fext=acos(x)/(2*pi);
      feasible=true;
      printf("Convergence : delx=%g after %d iterations\n",delx,fiter);
      break;
    endif
    if fiter==max_iter,
      error("No convergence after %d iterations",max_iter);
    endif
    
  endfor

endfunction
