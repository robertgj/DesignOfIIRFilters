function [Asq, gradAsq,diagHessAsq]=parallel_allpass_delayAsq(w,a,V,Q,R,D, ...
                                                              polyphase)
% [Asq, gradAsq,diagHessAsq]=parallel_allpass_delayAsq(w,a,V,Q,R,D,polyphase)
% Calculate the squared-magnitude response and gradient of the
% squared-magnitude response of the parallel combination of an
% allpass filter and a pure delay.
%
% Inputs:
%  w - vector of angular frequencies at which to calculate the response
%  a - vector of V real pole radiuses, Q/2 complex pole radiuses and
%       Q/2 complex pole angles
%  R - decimation factor
%  D - pure delay in samples
%  polyphase - return the response for the polyphase combination(R=2 only)
%
% Outputs;
%  Asq - the squared-magnitude response of the parallel combination of
%        the allpass filter, a, and a delay
%  gradAsq - the gradient of Asq with respect to the coefficients of
%            the allpass filter, a
%  diagHessAsq - the diagonal of the Hessian of Asq with respect to the
%                coefficients of the allpass filter, a

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

 if (nargin != 6) && (nargin != 7)
    print_usage...
("[Asq,gradAsq,diagHessAsq]=parallel_allpass_delayAsq(w,a,V,Q,R,D,polyphase)");
  endif
  if nargin == 6
    polyphase = false;
  endif
  if polyphase && (R != 2)
    error("For polyphase combination R=2 only!");
  endif
  if length(a) != (V+Q)
    error("length(a) != (V+Q)");
  endif
  if isempty(w)
    Asq=[];
    gradAsq=[];
    diagHessAsq=[];
    return;
  endif
  
  w=w(:);
  a=a(:);

  if nargout==1
    Pa = allpassP(w,a,V,Q,R);
  elseif nargout==2
    [Pa,gradPa] = allpassP(w,a,V,Q,R);
  else
    [Pa,gradPa,diagHessPa] = allpassP(w,a,V,Q,R);
  endif

  if polyphase
    Pa = Pa - w;
  endif

  Asq = (ones(length(w),1)+cos(Pa+(D*R*w)))/2;
  if nargout==1
    return;
  endif

  ksinPaDRw=kron(sin(Pa+(D*R*w)),ones(1,length(a)));
  gradAsq = -0.5*ksinPaDRw.*gradPa;
  if nargout==2
    return;
  endif

  diagHessAsq = -0.5*ksinPaDRw.*diagHessPa ...
                -0.5*kron(cos(Pa+(D*R*w)),ones(1,length(a))).*(gradPa.^2);
  
endfunction
