function [d,p1,p2,q1,q2]=sos2pq(sos,g)
% [d,p1,p2,q1,q2]=sos2pq(sos,g)
% sos2pq converts the second order sections found by tf2sos() to the pq
% format used by pq2svcasc to describe a cascade of second order sections:
%    Hsection(z)= d +    (q1/z) + (q2/(z*z))
%                      -----------------------
%                      1 + (p1/z) + (p2/(z*z))

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
  if ((nargin ~= 1) && (nargin ~= 2)) || (nargout ~= 5)
    print_usage("[d,p1,p2,q1,q2]=sos2pq(sos,g)");
  endif
  
  % Check inputs
  if nargin == 1
    g=1;
  endif
  if ~isscalar(g)
    error("g is not scalar");
  endif
  if sos(:,4) ~= ones(rows(sos),1);
    error("p0 ~= 1");
  endif
  if columns(sos) ~= 6
    error("columns(sos) ~= 6");
  endif

  % Extract d,p and q
  nsect=rows(sos);
  gnsect=g^(1/nsect);
  d=zeros(nsect,1);
  q1=zeros(nsect,1);
  q2=zeros(nsect,1);
  p1=zeros(nsect,1);
  p2=zeros(nsect,1);
  for k=1:nsect
    [b,r]=deconv(sos(k,1:3)*gnsect,sos(k,4:6));
    if length(b) ~= 1
      error("length(b) ~= 1");
    endif
    if length(r) ~= 3
      error("length(r) ~= 3");
    endif
    if r(1) ~= 0
      error("r(1) ~= 0");
    endif
    d(k)=b;
    q1(k)=r(2);
    q2(k)=r(3);
    p1(k)=sos(k,5);
    p2(k)=sos(k,6);    
  endfor
  
endfunction
