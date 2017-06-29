function Txy = crossWelch(x,y,m)
% Txy = crossWelch(x,y,m)
% crossWelch performs FFT analysis of the two 
% sequences x and y using the Welch method of power spectrum
% estimation. The x and y sequences of n points are divided into
% k sections of m points each (m must be a power of two) with 
% overlap noverlap=m/2. Using an m-point FFT, successive sections 
% are Hanning windowed, FFTed and accumulated.

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

% Make sure x and y are column vectors
x = x(:);		
y = y(:);

% Build the window
n = max(size(x));	                % Number of data points
noverlap = m/2;
k = fix((n-noverlap)/(m-noverlap));	% Number of windows
index = 1:m;
w = .5*(1 - cos(2*pi*(1:m)'/(m+1)));
w = w';	                                % Hanning window
KMU = k*norm(w)^2;                      % Normalizing scale factor
Pxx = zeros(1,m);                       % Dual sequence case.
Pxy = Pxx; 
for i=1:k
  dx = detrend(x(index))';
  dy = detrend(y(index))';

  xw = w.*dx;
  yw = w.*dy;

  index = index + (m - noverlap);
  Xx = fft(xw);
  Yy = fft(yw);
  Yy2 = abs(Yy).^2;
  Xx2 = abs(Xx).^2;
  Xy  = Yy .* conj(Xx);
  Pxx = Pxx + Xx2;
  Pxy = Pxy + Xy;
end

% Select first half and let 1st point (DC value) be replaced with 2nd point
select = [2 2:m/2];
Pxx = Pxx(select);
Pxy = Pxy(select);

% Done
Txy = Pxy./Pxx;

endfunction
