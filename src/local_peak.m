function [xpeak,ypeak,ipeak] = local_peak(x,y)
% [xpeak,ypeak,ipeak] = local_peak(x,y)
%
% Find the peaks of a quadratic fit to the local maxima of y
% Input:
%   x,y - vectors of abscissae and ordinates of data points
% Outputs:
%   xpeak - array of abscissae of peaks of quadratic fit to local maxima
%   ypeak - array of ordinates of peaks of quadratic fit to local maxima
%   ipeak - array of index to left of peak

% Copyright (C) 2017-2025 Robert G. Jenssen
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

% Sanity checks
if ((nargin ~= 1) && (nargin ~= 2)) || ((nargout ~= 2) && (nargout ~=3))
  print_usage("[xpeak,ypeak,ipeak] = local_peak(x,y)");
endif
if isvector(x) == false
  error("Data must be a vector");
endif
if length(x) < 3
  error("Data vectors must have a length of at least 3");
endif
s = size(x);
if nargin == 1
  y=x;
  x=1:length(y);
else
  if (s(1) ~= rows(y)) || (s(2) ~= columns(y))
    error("x and y data vectors must have the same shape");
  endif
endif

% Find vector indexes nearest to the local maxima
idx = local_max(y);
%  idx = unique([idx(:);1;length(y)]);
if isempty(idx)
  xpeak=x(1);
  ypeak=y(1);
  ipeak=1;
  return;
endif

% Force shape to single column
x = x(:);
y = y(:);
idx = idx(:);

% Use quadratic fit to find the coordinates of the peaks
for n=1:length(idx)
  % Find vector of indexes
  if idx(n) == 1 || idx(n) == length(x)
    % Endpoints
    xpeak(n) = x(idx(n));
    ypeak(n) = y(idx(n));
    ipeak(n) = idx(n);
  else
    % Do quadratic fit for index
    vexp = (0:2);
    vidx = (idx(n)-1):(idx(n)+1);
    cbai = (kron(vidx(:),ones(1,3)).^kron(vexp,ones(3,1))) \ y(vidx);
    ipeak(n) = -0.5*cbai(2)/cbai(3);
    % Do quadratic fit for x and y
    cbax = (kron(x(vidx),ones(1,3)).^kron(vexp,ones(3,1))) \ y(vidx);
    xpeak(n) = -0.5*cbax(2)/cbax(3);
    ypeak(n) = (xpeak(n).^vexp)*cbax;
  endif
endfor

% Force shape to single column
xpeak = xpeak(:);
ypeak = ypeak(:);
ipeak= ipeak(:);

% ipeak indexes are to the left of the peak
ipeak = round(idx - ((ipeak-idx)<0));

% Reorganise to match input
if s(1) == 1
  xpeak = xpeak';
  ypeak = ypeak';
  ipeak= ipeak';
endif

endfunction
