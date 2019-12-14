function [hM,rho,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W,maxiter,tol)
% [hM,rho,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W,maxiter,tol)
% Implement Park and McClellans' algorithm for the design of a linear-phase FIR
% filter with given pass-band and stop-band ripples.
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
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints

% Copyright (C) 2019 Robert G. Jenssen
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

if (nargin < 4) || (nargin > 6) || (nargout>4)
  print_usage("hM=mcclellanFIRsymmetric(M,F,D,W)\n\
[hM,rho,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W,maxiter,tol)");
endif

% Sanity checks
if nargin<6
  tol=1e-8;
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
allow_extrap=true;
last_rho=0;
feasible=false;

% Initial guess at M+2 extremal points in F
gs=length(F);
Ek=round(1:((gs-1)/(M+1)):gs);
if length(Ek)~=(M+2)
  error("length(Ek)~=(M+2)");
endif
m1k=(-1).^(0:(length(Ek)-1));

% Values at initial extremal points
% (Frequency grid varies down rows, extrema vary across columns)
x=cos(2*pi*F);
xk=x(Ek)';
Dk=D(Ek)';
Wk=W(Ek)';

% Loop performing Parks and McClellan algorithm
for fiter=1:maxiter

  % Calculate Lagrange interpolation weights
  axk=(((xk(:)')-xk(:))*2)+eye(length(xk));
  ak=1./prod(axk,1);

  % Calculate rho
  rho=sum(ak.*Dk)/sum(ak.*m1k./Wk);
  
  % Barycentric Lagrange interpolation at first M+1 extrema
  xk=xk(1:(M+1));
  ck=Dk-(m1k*rho./Wk);
  ck=ck(1:(M+1));
  dk=1./prod(axk(1:(M+1),1:(M+1)),1);
  A=lagrange_interp(xk,ck,dk,x,tol,allow_extrap);

  % Calculate weighted error
  E=W.*(D-A); 
  
  % Choose M+2 new extremal values
  maxE=local_max(E);
  minE=local_max(-E);
  Ek=sort([maxE;minE]);
  Ek=Ek(:)';
  % If more than M+2 alternations discard the smallest absolute errors
  while length(Ek)>(M+2)
    [~,k]=min(abs(E(Ek)));
    Ek(k)=[];
  endwhile
  if length(Ek)~=(M+2)
    error("length(Ek)~=(M+2)")
  endif
  
  % Check for alternation of errors
  Ekalt=E(Ek)'.*m1k;
  if any(Ekalt<0) && any(Ekalt>0)
    error("any(Ekalt<0) && any(Ekalt>0)")
  endif

  % Update values at extremal points
  xk=x(Ek)';
  Dk=D(Ek)';
  Wk=W(Ek)';
  
  % Test convergence
  del_rho=abs(rho-last_rho);
  last_rho=rho; 
  if del_rho<tol
    printf("rho=%g convergence (del_rho=%g) after %d iterations\n",
           rho,del_rho,fiter);
    feasible=true;
    break;
  endif
  if fiter==maxiter,
    error("No convergence after %d iterations",maxiter);
  endif
endfor

% Find equally spaced samples of the frequency response
Ek=unique([1,gs,Ek]);
xk=x(Ek)';
Ak=A(Ek)';
axk=(((xk(:)')-xk(:))*2)+eye(length(xk));
ak=1./prod(axk,1);
N=(2*M)+1;
AN=lagrange_interp(xk,Ak,ak,cos(pi*(0:N)/N));

% Find the distinct impulse response coefficients
h=ifft([AN;flipud(AN(2:(end-1)))]);
if norm(imag(h))>tol
  error("norm(imag(h))(%g)>tol".norm(imag(h)));
endif
hM=real(flipud(h(1:M+1)));
    
endfunction
