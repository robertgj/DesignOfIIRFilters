function [ErrorT, gradErrorT, hessErrorT] = Terror(x,U,V,M,Q,R,wt,Td,Wt)
% [ErrorT gradErrorT hessErrorT] = Terror(x,U,V,M,Q,R,wt,Td,Wt)
%
% Calculate the squared response group delay error and gradient and 
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
%   wt - normalised angular frequencies (wt in [0, pi), fs=1)
%   Td - vector of desired group delay values
%   Wt - vector of desired weights ([], single value or vector)
% The lengths of the wt, Td and Wt vectors are assumed equal and the
% wt angular frequencies are assumed to be equally spaced (allowing
% for simple rectangular integration).  
% 
% Outputs:
%   ErrorT - total error in group delay for angular frequencies in wt at x
%   gradErrorT - gradient of ErrorT at x
%   hessErrorT - Hessian of ErrorT at x
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
% References:
%   [1] A.G.Deczky, "Synthesis of recusive digital filters using the
%       minimum p-error criterion" IEEE Trans. Audio Electroacoust.,
%       Vol. AU-20, pp. 257-263, October 1972
%   [2] M.A.Richards, "Applications of Deczkys Program for Recursive
%       Filter Design to the Design of Recursive Decimators" IEEE 
%       Trans. ASSP-30 No. 5, pp. 811-814, October 1982

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

if nargin!=9 || nargout>3 
  print_usage("[ErrorT,gradErrorT,hessErrorT]=Terror(x,U,V,M,Q,R,wt,Td,Wt)");
endif

% Make row vectors with a single column, 
% since by default, sum() adds over first dimension
x = x(:);
wt = wt(:);
Td = Td(:);
Wt = Wt(:);

% Sanity checks
Lt = length(wt);
if length(Td) != Lt
  error("length(wt)!=length(Td)");
endif
if length(Wt) != Lt
  error("length(wt)!=length(Wt)");
endif
N=1+U+V+M+Q;
if length(x) != N
  error("length(x) != 1+U+V+M+Q");
endif

% Group delay response at wt
if nargout==1
  T=iirT(wt,x,U,V,M,Q,R);
  gradT=zeros(Lt,N);
  hessT=zeros(length(Td),N,N);
elseif nargout==2
  [T,gradT]=iirT(wt,x,U,V,M,Q,R);
  hessT=zeros(Lt,N,N);
elseif nargout==3
  [T,gradT,hessT]=iirT(wt,x,U,V,M,Q,R);
endif

% Delay response error, gradient of error and Hessian of error.
% Wt is a weight vector over the frequencies.
% Use trapezoidal integration.
% Exchange order of integration and differentiation of the error.
% T is Lt-by-1. gradT is Lt-by-N. hessT is Lt-by-N-by-N
dwt = diff(wt);
ErrT=Wt.*(T-Td);
sqErrT=ErrT.*(T-Td);
ErrorT=sum(dwt.*(sqErrT(1:(Lt-1))+sqErrT(2:Lt)))/2;
if nargout>=2
  kErrT=kron(ErrT,ones(1,N));
  kErrTgradT=(kErrT(1:(Lt-1),:).*gradT(1:(Lt-1),:) + ...
              kErrT(2:end,:).*gradT(2:end,:))/2;
  kdwtErrTgradT=2*kron(dwt,ones(1,N)).*kErrTgradT;
  gradErrorT=sum(kdwtErrTgradT,1);
endif
if nargout==3
  % The derivative of integralof(2*Wt*(T-Td)'*gradT) is
  % integralof(2*Wt*gradT'*gradT + 2*Wt*(T-Td)'*hessT). 

  % Construct 1st term
  WtKgradT=kron(ones(1,N),Wt).*gradT;
  WgradTbyRow=permute(reshape(kron(WtKgradT',ones(1,N)),N,N,Lt),[3,1,2]);
  gradTbyCol=permute(reshape(kron(   gradT',ones(N,1)),N,N,Lt),[3,1,2]);

  % Construct 2nd term
  % Create an Lt-by-N-by-N array.
  % Each element of the k'th N-by-N subarray is ErrT(k).
  hkErrT=permute(reshape(kron(ErrT',ones(N,N)),N,N,Lt),[3,1,2]);

  % Integrand
  hTint=(WgradTbyRow.*gradTbyCol)+(hkErrT.*hessT);

  % Trapezoidal integration
  kdwt=permute(reshape(kron(dwt',ones(N,N)),N,N,Lt-1),[3,1,2]);
  hessErrorT=2*reshape(sum(kdwt.*(hTint(1:(Lt-1),:,:)+hTint(2:Lt,:,:))/2,1),N,N);
endif

endfunction
