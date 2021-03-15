function [hM,rho,fext,fiter,feasible]= ...
         mcclellanFIRsymmetric(M,F,D,W,type,maxiter,tol,verbose)
% [hM,rho,fext,fiter,feasible]= ...
%   mcclellanFIRsymmetric(M,F,D,W,type,maxiter,tol,verbose)
% Implement Park and McClellans' algorithm for the design of an even-order,
% odd-length, symmetric, linear-phase FIR filter.
%
% Inputs:
%   M - Filter order is (2*M)
%   F - Grid frequencies in [0,0.5]
%   D - desired amplitude responses at each frequency in F
%   W - weight at each frequency in F
%   type - 'left' means use the left division algorithm to find rho
%   maxiter - maximum number of iterations
%   tol - tolerance on convergence
%   verbose -
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

  if (nargin < 4) || (nargin > 8) || (nargout>5)
    print_usage("[hM,rho,fext,fiter,feasible]= ...\n\
mcclellanFIRsymmetric(M,F,D,W,type,maxiter,tol,verbose)");
  endif

  % Sanity checks
  if nargin<8
    verbose=false;
  endif
  if ~isbool(verbose)
    error("verbose is not a boolean!");
  endif
  if nargin<7
    tol=1e-10;
  endif
  if nargin<6
    maxiter=100;
  endif
  if nargin<5
    type="lowpass";
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
  if (length(type)>=4) && ischar(type) && strcmpi("left",type(1:4))
    opt_left_division=true;
    fprintf(stderr,"Using left-division to find rho and coefficients\n");
  else
    opt_left_division=false;
  endif
  
  % Initialise flags
  hM=[];
  rho=inf;
  fext=[];
  fiter=0;
  feasible=false;
  allow_extrap=true;

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
  x=cos(w);
  xk=x(Ek);
  Dk=D(Ek);
  Wk=W(Ek);
  if opt_left_division
    xM=cos(w.*(0:M));
  endif
  
  % Loop performing Parks and McClellan algorithm
  lastrhoxk=zeros(M+3,1);
  for fiter=1:maxiter

    if opt_left_division
      % Calculate rho and the coefficients of the cos(omega) polynomial
      arho=[xM(Ek,:),m1k./Wk]\Dk;
      a=arho(1:(M+1));
      rho=arho(M+2);
      A=xM*a;
    else
      % Calculate Lagrange interpolation weights
      axk=(((xk(:)')-xk(:))*2)+eye(length(xk));
      ak=1./prod(axk,2);
      % Calculate rho
      rho=sum(ak.*Dk)/sum(ak.*m1k./Wk);
      % Barycentric Lagrange interpolation at first M+1 extrema
      xk=xk(1:(M+1));
      ck=Dk-(m1k*rho./Wk);
      ck=ck(1:(M+1));
      dk=1./prod(axk(1:(M+1),1:(M+1)),2);
      A=lagrange_interp(xk,ck,dk,x,tol,allow_extrap);
    endif
    
    % Calculate weighted error
    E=W.*(D-A); 
    
    % Choose M+2 new extremal values
    maxE=local_max(E);
    minE=local_max(-E);
    Ek=sort([maxE;minE]);
    Ek=Ek(:);
    if length(Ek)<(M+2)
      error("length(Ek)<(M+2)")
    endif
    % If more than M+2 alternations discard the smallest absolute errors
    while length(Ek)>(M+2)
      [~,k]=min(abs(E(Ek)));
      if verbose
        printf("Discarding extrema at F(%d)=%g,D=%g,A=%g\n", ...
               k,acos(x(Ek(k)))/(2*pi),D(Ek(k)),A(Ek(k)));
      endif
      Ek(k)=[];
    endwhile

    % Update values at extremal points
    xk=x(Ek);
    Ak=A(Ek);
    Dk=D(Ek);
    Wk=W(Ek);

    % Test convergence
    delrhoxk=norm([rho;xk]-lastrhoxk);
    lastrhoxk=[rho;xk];
    if delrhoxk<tol
      if opt_left_division
        hM=[a(end:-1:2)/2;a(1)];
      else
        hM=xfr2tf(M,xk,Ak,tol);
      endif
      fext=acos(xk)/(2*pi);
      feasible=true;
      if verbose
        printf("Converged : rho=%g, delrhoxk=%g after %d iterations\n",
               rho,delrhoxk,fiter);
      endif
      break;
    endif

    if fiter==maxiter,
      if verbose
        warning("No convergence after %d iterations",maxiter);
      endif
    endif

  endfor

endfunction
