function [ErrorP, gradErrorP, hessErrorP] = Perror(x,U,V,M,Q,R,wp,Pd,Wp)
% [ErrorP gradErrorP hessErrorP] = Perror(x,U,V,M,Q,R,wp,Pd,Wp)
%
% Calculate the squared response phase error and gradient and 
% Hessian of that squared error.
%
% Inputs:
%   x - coefficient vector in the form:
%         [k; 
%          zR(1:U); pR(1:V); ...
%          abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%          abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where k is the gain coefficient, zR and pR represent real
%       zeros and poles and z and p represent conjugate zero and
%       pole pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   wp - normalised angular frequencies (wp in [0, pi), fs=1)
%   Pd - vector of desired phase values
%   Wp - vector of desired weights ([], single value or vector)
% The lengths of the wp, Pd and Wp vectors are assumed equal and the
% wa angular frequencies are assumed to be equally spaced (allowing
% for simple rectangular integration).  
% 
% Outputs:
%   ErrorP - total error in amplitude for angular frequencies in wp at x
%   gradErrorP - gradient of ErrorP at x
%   hessErrorP - Hessian of ErrorP at x
%
% !!! NOTE WELL !!! :
%
%   1. Results are returned with frequency varying in dimension 1.
%
%   2. The gradients are with respect to the filter coefficients, 
%      NOT the frequency.
%
%   3. Note the Hessian is defined as:
%        del2fdelx1delx1  del2fdelx1delx2  del2fdelx1delx3 ...
%        del2fdelx2delx1  del2fdelx2delx2  del2fdelx2delx3 ...
%        etc
%

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

if nargin!=9 || nargout>3 
  print_usage("[ErrorP,gradErrorP,hessErrorP]=Perror(x,U,V,M,Q,R,wp,Pd,Wp)");
endif

% Make row vectors with a single column, 
% since by default, sum() adds over first dimension
x = x(:);
wp = wp(:);
Pd = Pd(:);
Wp = Wp(:);

% Sanity checks
Lp = length(wp);
if length(Pd) != Lp
  error("length(wp)!=length(Pd)");
endif
if length(Wp) != Lp
  error("length(wp)!=length(Wp)");
endif
N=1+U+V+M+Q;
if length(x) != N
  error("length(x) != 1+U+V+M+Q");
endif

% Phase response at wp
if nargout==1
  P=iirP(wp,x,U,V,M,Q,R);
  gradP=zeros(Lp,N);
  hessP=zeros(Lp,N,N);
elseif nargout==2
  [P,gradP]=iirP(wp,x,U,V,M,Q,R);
  hessP=zeros(Lp,N,N);
elseif nargout==3
  [P,gradP]=iirP(wp,x,U,V,M,Q,R);
  warning("Using diagonal-only approximation to hessP!");
  hessP=iirP_hessP_DiagonalApprox(wp,x,U,V,M,Q,R);
endif

% Phase response error, gradient of error and Hessian of error.
% Wp is a weight vector over the frequencies.
% Use trapezoidal integration.
% Exchange order of integration and differentiation of the error.
% P is Lp-by-1. gradP is Lp-by-N. hessP is Lp-by-N-by-N

dwp = diff(wp);
ErrP=Wp.*(P-Pd);
sqErrP=ErrP.*(P-Pd);
ErrorP=sum(dwp.*(sqErrP(1:(Lp-1))+sqErrP(2:Lp)))/2;
if nargout>=2
  kErrP=kron(ErrP,ones(1,N));
  kErrPgradP=(kErrP(1:(Lp-1),:).*gradP(1:(Lp-1),:) + ...
              kErrP(2:end,:).*gradP(2:end,:))/2;
  kdwpErrPgradP=2*kron(dwp,ones(1,N)).*kErrPgradP;
  gradErrorP=sum(kdwpErrPgradP,1);
endif
if nargout==3
  % The derivative of integralof(2*Wp*(P-Pd)'*gradP) is
  % integralof(2*Wp*gradP'*gradP + 2*Wp*(P-Pd)'*hessP). 

  % Construct 1st term
  WpKgradP=kron(ones(1,N),Wp).*gradP;
  WgradPbyRow=permute(reshape(kron(WpKgradP',ones(1,N)),N,N,Lp),[3,1,2]);
  gradPbyCol=permute(reshape(kron(   gradP',ones(N,1)),N,N,Lp),[3,1,2]);

  % Construct 2nd term
  % Create an Lp-by-N-by-N array.
  % Each element of the k'th N-by-N subarray is ErrP(k).
  hkErrP=permute(reshape(kron(ErrP',ones(N,N)),N,N,Lp),[3,1,2]);

  % Integrand
  hPint=(WgradPbyRow.*gradPbyCol)+(hkErrP.*hessP);

  % Trapezoidal integration
  kdwp=permute(reshape(kron(dwp',ones(N,N)),N,N,Lp-1),[3,1,2]);
  hessErrorP=2*reshape(sum(kdwp.*(hPint(1:(Lp-1),:,:)+hPint(2:Lp,:,:))/2,1),N,N);
endif

endfunction
