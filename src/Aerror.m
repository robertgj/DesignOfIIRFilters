function [ErrorA, gradErrorA, hessErrorA] = Aerror(x,U,V,M,Q,R,wa,Ad,Wa)
% [ErrorA gradErrorA hessErrorA] = Aerror(x,U,V,M,Q,R,wa,Ad,Wa)
%
% Calculate the squared response amplitude error and gradient and 
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
%   wa - normalised angular frequencies (wa in [0, pi), fs=1)
%   Ad - vector of desired amplitude values
%   Wa - vector of desired weights ([], single value or vector)
% The lengths of the wa, Ad and Wa vectors are assumed equal and the
% wa angular frequencies are assumed to be equally spaced (allowing
% for simple rectangular integration).  
% 
% Outputs:
%   ErrorA - total error in amplitude for angular frequencies in wa at x
%   gradErrorA - gradient of ErrorA at x
%   hessErrorA - Hessian of ErrorA at x
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

if nargin~=9 || nargout>3 
  print_usage("[ErrorA,gradErrorA,hessErrorA]=Aerror(x,U,V,M,Q,R,wa,Ad,Wa)");
endif

% Make row vectors with a single column, 
% since by default, sum() adds over first dimension
x = x(:);
wa = wa(:);
Ad = Ad(:);
Wa = Wa(:);

% Sanity checks
La = length(wa);
if length(Ad) ~= La
  error("length(wa)~=length(Ad)");
endif
if length(Wa) ~= La
  error("length(wa)~=length(Wa)");
endif
N=1+U+V+M+Q;
if length(x) ~= N
  error("length(x) ~= 1+U+V+M+Q");
endif

% Amplitude response at wa
if nargout==1
  A=iirA(wa,x,U,V,M,Q,R);
  gradA=zeros(La,N);
  hessA=zeros(length(Ad),N,N);
elseif nargout==2
  [A,gradA]=iirA(wa,x,U,V,M,Q,R);
  hessA=zeros(La,N,N);
elseif nargout==3
  [A,gradA,hessA]=iirA(wa,x,U,V,M,Q,R);
endif

% Amplitude response error, gradient of error and Hessian of error.
% Wa is a weight vector over the frequencies.
% Use trapezoidal integration.
% Exchange order of integration and differentiation of the error.
% A is La-by-1. gradA is La-by-N. hessA is La-by-N-by-N
dwa = diff(wa);
ErrA=Wa.*(A-Ad);
sqErrA=ErrA.*(A-Ad);
ErrorA=sum(dwa.*(sqErrA(1:(La-1))+sqErrA(2:La)))/2;
if nargout>=2
  kErrA=kron(ErrA,ones(1,N));
  kErrAgradA=(kErrA(1:(La-1),:).*gradA(1:(La-1),:) + ...
              kErrA(2:end,:).*gradA(2:end,:))/2;
  kdwaErrAgradA=2*kron(dwa,ones(1,N)).*kErrAgradA;
  gradErrorA=sum(kdwaErrAgradA,1);
endif
if nargout==3
  % The derivative of integralof(2*Wa*(A-Ad)'*gradA) is
  % integralof(2*Wa*gradA'*gradA + 2*Wa*(A-Ad)'*hessA). 

  % Construct 1st term
  WaKgradA=kron(ones(1,N),Wa).*gradA;
  WgradAbyRow=permute(reshape(kron(WaKgradA',ones(1,N)),N,N,La),[3,1,2]);
  gradAbyCol=permute(reshape(kron(   gradA',ones(N,1)),N,N,La),[3,1,2]);

  % Construct 2nd term
  % Create an La-by-N-by-N array.
  % Each element of the k'th N-by-N subarray is ErrA(k).
  hkErrA=permute(reshape(kron(ErrA',ones(N,N)),N,N,La),[3,1,2]);

  % Integrand
  hAint=(WgradAbyRow.*gradAbyCol)+(hkErrA.*hessA);

  % Trapezoidal integration
  kdwa=permute(reshape(kron(dwa',ones(N,N)),N,N,La-1),[3,1,2]);
  hessErrorA=2*reshape(sum(kdwa.*(hAint(1:(La-1),:,:)+hAint(2:La,:,:))/2,1),N,N);
endif

endfunction
