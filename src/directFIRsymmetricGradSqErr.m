function gradSqErr=directFIRsymmetricGradSqErr(w,_hM,_Ad,_Wa)
% gradSqErr=directFIRsymmetricGradSqErr(w,hM,Ad,Wa)
% Return the gradient of the squared-error of an order 2M direct form
% symmetric FIR filter. This is a helper function for calculating the
% gradient of the mean-squared-error of the filter with the Octave quad
% functions.
%
% Inputs:
%   w - angular frequencies in [0, pi] at which to evaluate the squared error
%   hM - distinct coefficients of an even order, symmetric FIR filter polynomial
%   Ad - desired amplitude response
%   Wa - amplitude weighting function
% The angular frequency 2*pi corresponds to the sample rate. Ad and Wa are
% assumed to be evenly spaced in angular frequency from 0 to pi inclusive.
  
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

  persistent hM Ad Wa M N
  persistent init_done=false;

  if nargin~=1 && nargin~=4
    print_usage("      directFIRsymmetricGradSqErr(w) \n\
      directFIRsymmetricGradSqErr(w,hM,Ad,Wa)");
  endif

  if nargin==4
    hM=_hM;
    if isempty(hM)
      error("hM is empty");
    endif
    M=length(hM)-1;
    Ad=_Ad(:);
    Wa=_Wa(:);
    if length(Ad)~=length(Wa)
      error("length(Ad)~=length(Wa)");
    endif
    if length(Ad)<2
      error("length(Ad)<2");
    endif
    N=length(Ad);
    init_done=true;
  endif

  if ~init_done
    error("directFIRsymmetricGradSqErr not initialised");
  endif

  if length(w)==0
    error("length(w)==0");
  endif

  n=1+round(w*(N-1)/pi);
  if any(n<1) || any(n>N)
    error("any(n<1) || any(n>N)")
  endif
  
  % Find A and gradA
  [A,gradA]=directFIRsymmetricA(w,hM);
  
  % Find gradSqErr
  gradSqErr=2*kron(Wa(n).*(A(:)-Ad(n)),ones(1,M+1)).*gradA/pi;

endfunction
