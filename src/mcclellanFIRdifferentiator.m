function [hM,rho,fext,fiter,feasible]= ...
         mcclellanFIRdifferentiator(M,F,D,W,maxiter,tol)
% [hM,rho,fext,fiter,feasible]= ...
%   mcclellanFIRdifferentiator(M,F,D,W,maxiter,tol)
% Implement Park and McClellans' algorithm for the design of an even-order,
% odd-length, linear-phase FIR differentiator filter.
%
% Inputs:
%   M - Filter order is (2*M)
%   F - Grid frequencies in [0,0.5]
%   D - desired amplitude responses at each frequency in F
%   W - weight at each frequency in F
%   maxiter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hM - M+1 distinct coefficients [h(1),...,h(M+1)]
%   rho - stop-band ripple
%   fext - extremal frequencies
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints

% Copyright (C) 2019-2020 Robert G. Jenssen
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

  if (nargin < 4) || (nargin > 6) || (nargout>5)
    print_usage("hM=mcclellanFIRdifferentiator(M,F,D,W)\n\
[hM,rho,fext,fiter,feasible]= ...\n\
  mcclellanFIRdifferentiator(M,F,D,W,maxiter,tol)");
  endif

  % Sanity checks
  if nargin<6
    tol=1e-10;
  endif
  if nargin<5
    maxiter=100;
  endif
  if size(F)~=size(D)
    error("size(F)~=size(D)");
  endif
  if size(F)~=size(W)
    error("size(F)~=size(W)");
  endif
  if any(F<0)
    error("any(F<0)");
  endif
  if any(F>0.5)
    error("any(F>0.5)");
  endif
  
  % Initialise flags
  hM=[];
  rho=inf;
  fext=[];
  fiter=0;
  feasible=false;

  % Initial guess at M+2 extremal points in F
  gs=length(F);
  Ek=round(1:((gs-1)/(M+1)):gs)';
  if length(Ek)~=(M+2)
    error("length(Ek)~=(M+2)");
  endif
  m1k=(-1).^((0:(length(Ek)-1))');

  % Values at initial extremal points
  % (Frequency grid varies down rows, extrema vary across columns)
  F=F(:);
  D=D(:);
  W=W(:);
  w=2*pi*F;
  xM=sin(w.*(1:M));

  % Loop performing Parks and McClellan algorithm
  lastarho=zeros(M+1,1);
  for fiter=1:maxiter

    % Calculate rho and the coefficients of the cos(omega) polynomial
    arho=[xM(Ek,:),m1k./W(Ek)]\D(Ek);
    a=arho(1:M);
    rho=arho(M+1);
    A=xM*a;
    
    % Calculate weighted error
    E=W.*(D-A); 
    
    % Choose M+2 new extremal values
    maxE=local_max(E);
    minE=local_max(-E);
    Ek=sort([maxE;minE]);
    Ek=Ek(:);
    % If more than M+2 alternations discard the smallest absolute errors
    while length(Ek)>(M+2)
      if Ek(1)==1
        k=1;
      elseif Ek(end)==length(E)
        k=length(Ek);
      else
        [~,k]=min(abs(E(Ek)));
      endif
      Ek(k)=[];
    endwhile
    if length(Ek)~=(M+2)
      error("length(Ek)~=(M+2)")
    endif

    % Test convergence
    delarho=norm(arho-lastarho);
    lastarho=arho;
    if delarho<tol
      hM=a(end:-1:1)/2;
      fext=F(Ek);
      feasible=true;
      printf("Converged : rho=%g, delarho=%g after %d iterations\n",
             rho,delarho,fiter);
      break;
    endif
    if fiter==maxiter,
      error("No convergence after %d iterations",maxiter);
    endif
  endfor

endfunction
