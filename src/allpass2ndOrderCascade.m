function [H,gradH]=allpass2ndOrderCascade(a,w)
% [H,gradH]=allpass2ndOrderCascade(a,w)
% Find the complex frequency response and gradient of a cascade of 2nd
% order allpass filters defined by a at the frequencies w. If
% length(a) is odd then a(1) is the coefficient of a first order
% allpass filter. The remaining coefficients of a are, in order, ai1
% and ai2. If m is the length of a and n2sections is the number of
% second order sections, then, if length(a) is odd:
%   H(z)=z^(-m)*a(z^-1)/a(z)
% where
%   a(z)=(1+a0*z^-1) * prod(i=1:n2sections){1 + ai1*z^-1 + ai2*z^-2}
%
% H is a length(w) column vector and gradH is length(w) by length(a) matrix.

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

% Sanity checks
if nargin !=2 
  print_usage("[H,gradH]=allpass2ndOrderCascade(a,w)");
endif
if isempty(a)
  error("a is empty");
endif
if isempty(w)
  H=[];
  gradH=[];
  return;
endif

% Initialise
w=w(:);
a=a(:);
a_is_odd=(mod(length(a),2) == 1);
n2sections=floor(length(a)/2);

% Find H
if a_is_odd
  a0=a(1);
  ai=reshape(a(2:end),2,n2sections);
  v1=[exp(j*w)];
  H=(1+a0.*v1)./(1+a0.*conj(v1));
else
  a0=[];
  ai=reshape(a,2,n2sections);
  H=ones(length(w),1);
endif
% v2 is length(w)-by-2, ai is 2-by-nsections
v2=[exp(j*w) exp(j*2*w)];
H=H.*prod(1+v2*ai,2)./prod(1+conj(v2)*ai,2);
H=H.*exp(-j*length(a)*w);
if nargout==1
  return;
endif

%
% Find gradH
%
ai1=ai(1,:);
ai2=ai(2,:);

% Build numerators of gradH
if a_is_odd
  a0num=ones(length(w),1);
else
  a0num=[];
endif
a1num=kron(ones(length(w),1),kron(1-ai2,[1 0]));
a2num=kron(kron(2*cos(w),ones(1,n2sections)) + ...
           kron(ones(length(w),1),ai1), [0 1]);
a012num=[a0num a1num+a2num];

% Build denominators of gradH
if a_is_odd
  a0denom=1+(a0*a0)+a0*2*cos(w);
else
  a0denom=[];
endif
a12denom=kron(kron(ones(length(w),1),1+(ai1.^2)+(ai2.^2)) + ...
              kron(cos(w),2*ai1.*(1+ai2)) + ...
              kron(cos(2*w),2*ai2), [1 1]);
a012denom=[a0denom a12denom];

% Build gradH
gradH=kron(2*j*sin(w).*H,ones(1,length(a)));
gradH=gradH.*a012num;
gradH=gradH./a012denom;

endfunction
