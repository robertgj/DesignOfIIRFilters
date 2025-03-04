function [a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,opt)
% [a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,opt)
% Given second order transfer functions of the form:
%    H(z)= d   +       (q1/z) + (q2/(z*z))
%                  _______________________
%                  1 + (p1/z) + (p2/(z*z))
% find the corresponding second order direct form state
% variable equations:
%   x(k+1) = A*x(k) + B*u(k)
%   y(k)   = C*x(k) + D*u(k)
% The opt string selects the type of the filter sections: 
%  "direct"  - direct form
%  "bomar3"  - Bomar type III
%  "minimum" - minimum noise
%
% See: "B. W. Bomar, "New second-order state-space structures for
% realizing low round off noise digital filters", IEEE Transactions
% on Acoustics, Speech and Signal Processing, Vol. 33, No. 1,
% February 1985, pp. 106-110
  
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

% First do some sanity checking
if nargin ~= 5
  print_usage("[a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,opt)");
endif
if size(p1) ~= size(p2)
  error("Expect size(p1) == size(p2)");
endif
if size(p1) ~= size(q1)
  error("Expect size(p1) == size(q1)");
endif
if size(p1) ~= size(q2)
  error("Expect size(p1) == size(q2)");
endif
if length(opt) < 3
  error("Expect opt to be ""direct"", ""bomar3"" or ""minimum"" ");
endif

% Calculate the coefficients of the second order sections
%   x(k+1) = A*x(k) + B*u(k)
%   y(k)   = C*x(k) + D*u(k)
if opt(1:3) == "dir"
  % Find the second order section direct form equations:
  a11 = zeros(size(p1));
  a12 = ones(size(p1));
  a21 = -p2;
  a22 = -p1;
  b1  = zeros(size(p1));
  b2  = ones(size(p1));
  c1  = q2;
  c2  = q1;
elseif opt(1:3) == "bom"
  % Find Bomar's Type III sections from Bomar's Eqn 23:
  a11 = -p1/2;
  a12 = sqrt(1+((p1.*p1/4).*(p2-3)./(1+p2)));
  a21 = ((p1.*p1/4)-p2)./a12;
  a22 = a11;
  b1 = zeros(size(p1));
  b2 = sqrt((1-p2).*(((1+p2).*(1+p2))-(p1.*p1)));
  b2 = b2./sqrt(((1+p2).*(1+(p1.*p1/4)))-(p1.*p1));
  c1 = (q2+(a11.*q1))./(a12.*b2);
  c2 = q1./b2;
elseif opt(1:3) == "min"
  % Find the minimum noise second order sections from Bomar's Eqn 17:
  v1 = q2./q1;
  v2 = sqrt((v1.*v1)-(p1.*v1)+p2);
  v3 = v1-v2;
  v4 = v1+v2;
  v5 = p2-1;
  v6 = p2+1;
  v7 = v5.*((v6.*v6)-(p1.*p1));
  v8 = (p1.*p1/4)-p2; 
  b1 = sqrt(v7./((2*p1.*v3) - (v6.*(1+(v3.*v3)))));
  b2 = sqrt(v7./((2*p1.*v4) - (v6.*(1+(v4.*v4)))));
  a11 = -p1/2;
  a22 = a11;
  a21 = sqrt((((b2.*b2)+v5).*v8)./((b1.*b1)+v5));
  a12 = v8./a21;
  c1 = q1./(2*b1);
  c2 = q1./(2*b2);
else
  error("Expected opt=""direct"", ""bomar3"", or ""minimum""");
end

endfunction
