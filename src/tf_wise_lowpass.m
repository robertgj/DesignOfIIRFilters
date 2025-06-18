function [N0,D0R]=tf_wise_lowpass(nN,R,fap,fas,Was,tp)
% [N0,D0R]=schurOneMPAlattice_wise_lowpass(nN,R,fap,fas,Was,tp)
% Design a lowpass filter with denominator coefficients in z^-R using the
% method of Tarczynski et al. 
% Inputs:
%  m - filter order
%  R - denominator coefficients in z^-R
%  fap,fas - low-pass filter amplitude pass-band and stop-band frequencies
%  Was - amplitude stop-band weight (pass-band weight is 1)
%  tp - nominal pass-band delay
% Output:
%  N0 - numerator polynomial
%  D0R - denominator polynomial
  
% Copyright (C) 2025 Robert G. Jenssen
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

  if ((nargin~=5) && (nargin~=6)) || (nargout~=2)
    print_usage("[N0,D0R]=schurOneMlattice_wise_lowpass(nN,R,fap,fas,Was,tp)");
  endif

  nD=floor(nN/R);
  
  % Frequency points
  n=1000;
  f=0.5*(0:(n-1))'/n;
  w=2*pi*f;
  nap=ceil(fap*n/0.5)+1;
  nas=floor(fas*n/0.5)+1;

  % Frequency vectors
  Hd=[ones(nap,1); zeros(n-nap,1)];
  Wa=[ones(nap,1); zeros(nas-nap-1,1); Was*ones(n-nas+1,1)];
  if nargin == 6
    Hd=Hd.*exp(-j*w*tp);
  endif
  maxiter=10000;
  tol=1e-6;
  WISEJ([],nN,nD,R,w,Hd,Wa);
  NDi=[0.1;zeros(nN+nD,1)];
  WISEJ([],nN,nD,R,w,Hd,Wa);
  [ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NDi);  
                           
  % Create the initial polynomials
  ND0=ND0(:);
  N0=ND0(1:(nN+1));
  D0R=[1;kron(ND0((nN+2):end),[zeros(R-1,1);1])];
endfunction
