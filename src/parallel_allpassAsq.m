function [Asq, gradAsq]=parallel_allpassAsq(w,ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase)
% [Asq, gradAsq]=parallel_allpassAsq(w,ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase)
% Calculate the squared-magnitude response and gradient of the
% squared-magnitude response of the parallel combination of two
% allpass filters.
%
% Inputs:
%  w - vector of angular frequencies at which to calculate the response
%  ab - vector of Va real pole radiuses, Qa/2 complex pole radiuses and
%       Qa/2 complex pole angles, Vb real pole radiuses, Qb/2 complex
%       pole radiuses and Qb/2 complex pole angles.
%  Ra - filter a is in terms of z^Ra
%  Rb - filter b is in terms of z^Rb
%  polyphase - return the response for the polyphase combination
%              (Ra=Rb=2 only)
%
% Outputs;
%  Asq - the squared-magnitude response of the parallel combination of
%       allpass filters a and b
%  gradAsq - the gradient of Asq with respect to the coefficients of
%           filters a and b

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

  if (nargin != 8) && (nargin != 9)
    print_usage("[Asq,gradAsq] = ...\n\
      parallel_allpassAsq(w,ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase)");
  endif
  if nargin == 8
    polyphase = false;
  endif
  if polyphase && (Ra != 2) && (Rb != 2)
    error("For polyphase combination Ra=2 and Rb=2 only!");
  endif
  if length(ab) != (Va+Qa+Vb+Qb)
    error("length(ab) != (Va+Qa+Vb+Qb)");
  endif
  if isempty(w)
    Asq=[];
    gradAsq=[];
    return;
  endif

  a = ab(1:(Va+Qa));
  [Pa,gradPa] = allpassP(w,a,Va,Qa,Ra);

  b = ab((Va+Qa+1):end);
  [Pb,gradPb] = allpassP(w,b,Vb,Qb,Rb);

  if polyphase
    Pb = Pb - w(:);
  endif
  
  Asq = 0.5*(ones(length(w),1)+cos(Pa-Pb));
  gradAsq = -0.5*kron(sin(Pa-Pb),ones(1,length(ab))).*[gradPa, -gradPb];

endfunction
