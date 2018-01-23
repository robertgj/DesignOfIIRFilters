function [d,p1,p2,q1,q2]=butter2pq(N,fc,pass)
 % [d,p1,p2,q1,q2]=butter2pq(N,fc[,pass])
% butter2pq finds the coefficients for the second order sections of an
% order N Butterworth digital filter with cutoff fc and sample rate,
% fs=1. Pass may be "high" for high pass response or, the default,
% "low" for low pass response. The filter is realised as a cascade of
% second order sections of the form:
%    H(z)= d +     (q1/z) + (q2/(z*z))
%              -----------------------
%              1 + (p1/z) + (p2/(z*z))

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

  if ((nargin ~= 3) && (nargin ~= 2)) || (nargout ~= 5)
    print_usage("[d,p1,p2,q1,q2]=butter2pq(N,fc[,pass])");
  endif
  if fc >= 0.5
    error("Expect fc < 0.5 (sampling frequency fs=1)");
  end
  if nargin == 2
    pass = "low";
  else
    if ~strcmp(pass(1:3),"low") && ~strcmp(pass(1:4),"high")
      error("Expect pass to be ""low"" or ""high"" not ""%s"" !",pass);
    endif
  endif

  % Warp the frequency scale
  wc = tan(pi*fc);

  %
  % Find the transfer function as a set of vectors d, p1, p2, q1, q2
  % each of length N/2, for N even, and (N+1)/2 for N odd. 
  % 

  % Get the Butterworth conjugate pole positions in the upper left s plane
  costheta = cos(pi*(((1:2:N-1)/(2*N))+0.5))';

  % Calculate some intermediate values for the low-pass filter
  %   H(z)=g(1+1/z)^2/(a0+a1/z+a2/(z^2))
  % and the high-pass filter
  %   H(z)=g(1-1/z)^2/(a0-a1/z+a2/(z^2))
  g=wc*wc;
  a0=1-(2*wc*costheta)+g;
  a1=2*(g-1);
  a2=1+(2*wc*costheta)+g;

  % Calculate the second order section coefficients
  if N>=2
    if strcmp(pass(1:3),"low")
      d = g./a0;
      p1 = a1./a0;
      p2 = a2./a0;
      q1 = d.*(2-p1);
      q2 = d.*(1-p2);
    else
      d = 1./a0;
      p1 = a1./a0;
      p2 = a2./a0;
      q1 = -(2+p1)./a0;
      q2 = (1-p2)./a0;
    endif
  else
    d=[];p1=[];p2=[];q1=[];q2=[];
  endif

  % Add the first order section
  if rem(N,2) == 1
    if strcmp(pass(1:3),"low")
      d = [d; wc/(wc+1)];
      p1 = [p1; (wc-1)/(wc+1)];
      q1 = [q1; 2*wc/((wc+1)^2)];
      if N==1
        p2 = 0;
        q2 = 0;
      else
        p2 = [p2; 0];
        q2 = [q2; 0];
      endif
    else
      d = [d; 1/(wc+1)];
      p1 = [p1; (wc-1)/(wc+1)];
      q1 = [q1; -2*wc/((wc+1)^2)];
      if N==1
        p2 = 0;
        q2 = 0;
      else
        p2 = [p2; 0];
        q2 = [q2; 0];
      endif
    endif
  endif

  
endfunction
