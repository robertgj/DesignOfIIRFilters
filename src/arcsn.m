function [asn,err]=arcsn(z,k,tol)
% [asn,err]=arcsn(z,k,tol)
% Compute arcsn with Carlsons algorithm for computing the RF function.
% See [1, Algorithm 1] and [2,Equation 2.2]
% [1] "Computing elliptic integrals by duplication",
% B.C.Carlson, Numerische Mathematik, 33:1-16, 1979
% [2] "POWER SERIES FOR INVERSE JACOBIAN ELLIPTIC FUNCTIONS", B.C.Carlson,
% MATHEMATICS OF COMPUTATION, Vol. 77, No. 263, July 2008, pp. 1615–1621

% Copyright (C) 2019-2025 Robert G. Jenssen
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
  if ((nargin ~= 2) && (nargin~=3)) || (nargout>2)
    print_usage("[asn,err]=arcsn(z,k,tol)");
  endif
  if ~isscalar(z),
    error("~isscalar(z)");
  endif
  if ~isscalar(k),
    error("~isscalar(k)");
  endif

  if nargin==2
    [asn,err]=carlson_RF(1,1-(z^2),1-((k^2)*(z^2)));
  else
    [asn,err]=carlson_RF(1,1-(z^2),1-((k^2)*(z^2)),tol);
  endif
  asn=z*asn;

endfunction
