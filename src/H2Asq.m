function [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdx,diagd2Hdx2)
% [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdx,diagd2Hdx2)
% A helper function that calculates the squared-magnitude response and
% gradients of a filter with the complex response, H, and gradients, dHdx,
% and diagonal of the Hessian of H, diagd2Hdx2, found by functions like
% schurOneMlattice2H.
% 
% Inputs:
%   H - complex frequency response over angular frequency, w
%   dHdx - gradient of complex frequency response wrt the coefficients, x
%   diagd2Hdx2 - diagonal of the Hessian of H wrt to x

% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq with respect to x
%   diagHessAsq - diagonal of the Hessian of Asq with respect to x

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

  %
  % Sanity checks
  %
  if ((nargout==2)&&(nargin<2)) || ((nargout==3)&&(nargin<3)) || (nargout>3)
    print_usage("[Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdx,diagd2Hdx2)");
  endif
  if (nargin == 2) && (length(H) ~= rows(dHdx))
    error("length(H) ~= rows(dHdx)");
  endif
  if (nargin == 3) && (length(H) ~= rows(diagd2Hdx2))
    error("length(H) ~= rows(diagd2Hdx2)");
  endif
  if (nargin == 3) && (columns(dHdx) ~= columns(diagd2Hdx2))
    error("columns(dHdx) ~= columns(diagd2Hdx2)");
  endif
  if length(H) == 0
    Asq=[]; gradAsq=[]; diagHessAsq=[];
    return;
  endif

  % Find Asq
  Asq=H.*conj(H);
  if nargout==1
    return;
  endif

  % Find gradAsq
  Nx=columns(dHdx);
  krH=kron(real(H),ones(1,Nx));
  kiH=kron(imag(H),ones(1,Nx));
  rdHdx=real(dHdx);
  idHdx=imag(dHdx);
  gradAsq=2*((kiH.*idHdx)+(krH.*rdHdx));
  if nargout==2
    return;
  endif

  % Find diagHessAsq
  diagHessAsq=2*((abs(dHdx).^2)+(krH.*real(diagd2Hdx2))+(kiH.*imag(diagd2Hdx2)));
  
endfunction
