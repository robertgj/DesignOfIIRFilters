function [hM,rho,fext,fiter,feasible]= ...
         mcclellanFIRsymmetric(M,F,D,W,type,maxiter,tol)
% [hM,rho,fext,fiter,feasible]= ...
%   mcclellanFIRsymmetric(M,F,D,W,type,maxiter,tol)
% Implement Park and McClellans' algorithm for the design of an even-order,
% odd-length, symmetric, linear-phase FIR filter.
%
% Inputs:
%   M - Filter order is (2*M)
%   F - Grid frequencies in [0,0.5]
%   D - desired amplitude responses at each frequency in F
%   W - weight at each frequency in F
%   type - 'lowpass' or 'bandpass' determines extrema search type
%          (if type ends with '\', eg: "lowpass\\", then use left division)
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

  if (nargin < 4) || (nargin > 7) || (nargout>5)
    print_usage("hM=mcclellanFIRsymmetric(M,F,D,W)\n\
[hM,rho,fext,fiter,feasible]= ...\n\
  mcclellanFIRsymmetric(M,F,D,W,type,maxiter,tol)");
  endif

  % Sanity checks
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
  if ~ischar(type)
    error("~ischar(type)");
  endif
  if type(end)=="\\"
    opt_left_division=true;
  else
    opt_left_division=false;
  endif
  if opt_left_division
    fprintf(stderr,"Using left-division to find rho and coefficients\n");
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
    % If more than M+2 alternations discard the smallest absolute errors
    while length(Ek)>(M+2)
      % Search for bandpass extremal points
      if strcmpi(type(1:4),"band")
        alternation_fail_found=false;
        for m=1:(length(Ek)-1),
          if sign(E(Ek(m)))==sign(E(Ek(m+1)))
            [~,k]=min(abs(E(Ek([m,m+1]))));
            alternation_fail_found=true;
          endif
        endfor
        if alternation_fail_found==false
          [~,k]=min(abs(E(Ek)));
        endif 
      % Search for lowpass extremal points
      elseif strcmpi(type(1:3),"low")
        [~,k]=min(abs(E(Ek)));
      else
        error("Unknown search type %s",type);
      endif
      Ek(k)=[];
    endwhile
    if length(Ek)~=(M+2)
      error("length(Ek)~=(M+2)")
    endif

    % Check for alternation of errors
    Ekalt=E(Ek).*m1k;
    if any(Ekalt<-eps) && any(Ekalt>eps)
      warning("fiter=%d : any(Ekalt<-eps) && any(Ekalt>eps)",fiter)
    endif

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
      printf("Converged : rho=%g, delrhoxk=%g after %d iterations\n",
             rho,delrhoxk,fiter);
      break;
    endif
    if fiter==maxiter,
      error("No convergence after %d iterations",maxiter);
    endif
  endfor

endfunction
