function [B,A]=svcasc2tf(a11,a12,a21,a22,b1,b2,c1,c2,dd)
% [B,A]=svcasc2tf(a11,a12,a21,a22,b1,b2,c1,c2,dd)
% Converts a cascade of second order sections to a 
% numerator/denominator transfer function H(z)= B(z)/A(z)

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

if nargin ~= 9
  print_usage("[B,A]=svcasc2tf(a11,a12,a21,a22,b1,b2,c1,c2,dd");
end

% Convert [a b c] to [p q] form
q1 = (c1.*b1) + (c2.*b2);
q2 = ((c1.*b2).*a12) + ((c2.*b1).*a21);
q2 = q2 - ((c1.*b1).*a22) - ((c2.*b2).*a11);
p1 = -(a11 + a22);
p2 = (a11.*a22) - (a12.*a21);

% Find B and A
B = 1;
A = 1;
for i=1:length(dd)
  if p2(i) == 0 && q2(i) == 0
    % First-order section
    B = conv(B,[dd(i), dd(i)*p1(i)+q1(i)]);
    A = conv(A,[1, p1(i)]);
  else
    % Second-order section
    B = conv(B,[dd(i), dd(i)*p1(i)+q1(i), dd(i)*p2(i)+q2(i)]);
    A = conv(A,[1, p1(i), p2(i)]);
  endif
end

endfunction
