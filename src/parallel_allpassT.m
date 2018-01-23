function [T, gradT]=parallel_allpassT(w,ab,Va,Qa,Ra,Vb,Qb,Rb, ...
                                      polyphase,difference)
% [T, gradT]=parallel_allpassT(w,ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference)
% Calculate the phase response and gradient of the phase response
% of the parallel combination of two allpass filters.
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
%  difference - return the group-delay response for the difference of the
%               all-pass filters (difference has no effect on group delay)
% Outputs;
%  T - the group delay response of the parallel combination of allpass
%       filters a and b
%  gradT - the gradient of T with respect to the coefficients of a
%          and b

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

  if (nargin != 8) && (nargin != 9) && (nargin != 10)
    print_usage("[T, gradT] = ...\n\
      parallel_allpassT(w,ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference)");
  endif
  if nargin == 8
    polyphase = false;
    difference = false;
  elseif nargin == 9
    difference = false;
  endif
  if polyphase && (Ra != 2) && (Rb != 2)
    error("For polyphase combination Ra=2 and Rb=2 only!");
  endif
  if length(ab) != (Va+Qa+Vb+Qb)
    error("length(ab) != (Va+Qa+Vb+Qb)");
  endif
  if isempty(w)
    T=[];
    gradT=[];
    return;
  endif

  a = ab(1:(Va+Qa));
  [Ta,gradTa] = allpassT(w,a,Va,Qa,Ra);

  b = ab((Va+Qa+1):end);
  [Tb,gradTb] = allpassT(w,b,Vb,Qb,Rb);

  if polyphase
    Tb = Tb + ones(size(w));
  endif

  T = 0.5*(Ta+Tb);
  gradT = 0.5*[gradTa, gradTb];
endfunction
