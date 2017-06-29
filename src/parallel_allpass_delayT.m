function [T,gradT,diagHessT]=parallel_allpass_delayT(w,a,V,Q,R,D,polyphase)
% [T,gradT,diagHessT]=parallel_allpass_delayT(w,a,V,Q,R,D,polyphase)
% Calculate the phase response and gradient of the group delay response
% of the parallel combination of an allpass filter and a pure delay.
%
% Inputs:
%  w - vector of angular frequencies at which to calculate the response
%  a - vector of V real pole radiuses, Q/2 complex pole radiuses and
%       Q/2 complex pole angles.
%  R - filter decimation factor
%  polyphase - return the response for the polyphase combination (R=2 only)
%
% Outputs;
%  T - the group delay response of the parallel combination of allpass
%       filter a and a pure delay
%  gradT - the gradient of T with respect to the coefficients of a
%  diagHessT - the diagonal of the Hessian of T with respect to the
%              coefficients of a

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

  if ((nargin != 6) && (nargin != 7)) || (nargout > 3)
    print_usage...
    ("[T,gradT,diagHessT]=parallel_allpass_delayT(w,a,V,Q,R,D,polyphase)");
  endif
  if nargin == 6
    polyphase = false;
  endif
  if polyphase && (R != 2)
    error("For polyphase combination R only!");
  endif
  if length(a) != (V+Q)
    error("length(a) != (V+Q)");
  endif
  if isempty(w)
    T=[];
    gradT=[];
    diagHessT=[];
    return;
  endif
  
  w=w(:);
  a=a(:);
  
  if nargout==1
    Ta = allpassT(w,a,V,Q,R);
  elseif nargout==2
    [Ta,gradTa] = allpassT(w,a,V,Q,R);
  else
    [Ta,gradTa,diagHessTa] = allpassT(w,a,V,Q,R);
  endif

  if polyphase
    Ta = Ta + ones(size(w));
  endif
  
  T = 0.5*(Ta+(D*R));
  if nargout==1
    return;
  endif
  
  gradT = 0.5*gradTa;
  if nargout==2
    return;
  endif

  diagHessT = 0.5*diagHessTa;

endfunction
