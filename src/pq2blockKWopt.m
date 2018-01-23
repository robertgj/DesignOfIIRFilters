function [a11,a12,a21,a22,b1,b2,c1,c2]=pq2blockKWopt(dd,p1,p2,q1,q2,delta)
% [a11,a12,a21,a22,b1,b2,c1,c2]=pq2blockKWopt(dd,p1,p2,q1,q2,delta)
% pq2blockKWopt scales by delta and block optimises the noise gain of
% a cascade of second order sections defined in d-p-q form. The last
% section may be first order, in which case it is optimised separately.
% Use the d-p-q form rather than a11,a12 etc so that it is not
% necessary to detect a first order transfer function implemented in a
% second-order section.
  
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

  % Check the input arguments
  if nargin ~= 6 || nargout ~= 8
    print_usage( ...
      "[a11,a12,a21,a22,b1,b2,c1,c2]=pq2blockKWopt(dd,p1,p2,q1,q2,delta)");
  end
  if size(dd) ~= size(q1)
    error("Expect size(dd) == size(q1)");
  endif
  if size(dd) ~= size(q2)
    error("Expect size(dd) == size(q2)");
  endif
  if size(dd) ~= size(p1)
    error("Expect size(dd) == size(p1)");
  endif
  if size(dd) ~= size(p2)
    error("Expect size(dd) == size(p2)");
  endif

  % Check if the last section is first order
  if (p2(end) == 0) && (q2(end) == 0)
    second_order_sections = length(dd)-1;
    last_section_is_first_order = true;
  else
    second_order_sections = length(dd);
    last_section_is_first_order = false;
  endif

  % Find the second-order direct-form sections
  [a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,"dir");
  
  % Find the A,B,C,D of the cascade. Quietly remove an unused state variable.
  [A,B,C,D]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd);

  % Sanity check for removal of an unused state variable
  if last_section_is_first_order && (rows(A) != (2*second_order_sections)+1)
    error("Expected (rows(A) == (2*second_order_sections)+1)!");
  endif

  % Find the K and W of the cascade
  [K,W]=KW(A,B,C,D);

  % Apply the optimising transform from the 2x2 blocks on the
  % diagonals of K and W to each second-order section 
  ngcasc=zeros(size(a11));
  for k=1:second_order_sections
    % Get the block optimising transformation
    l=(2*k)-1;
    [T,Kopt,Wopt]=optKW2(K(l:l+1,l:l+1),W(l:l+1,l:l+1),delta);
    
    % Transform the coefficients
    a=inv(T)*[a11(k),a12(k);a21(k),a22(k)]*T;
    b=inv(T)*[b1(k);b2(k)];
    c=[c1(k),c2(k)]*T;

    % Copy the block optimised second order sections
    a11(k)=a(1,1);
    a12(k)=a(1,2);
    a21(k)=a(2,1);
    a22(k)=a(2,2);
    b1(k)=b(1);
    b2(k)=b(2);
    c1(k)=c(1);
    c2(k)=c(2);
  end

  % Optimise the first order section (see pq2svcasc.m)
  if last_section_is_first_order
    [T,Kopt,Wopt]=optKW(K(end,end),W(end,end),delta);
    a11(end)=inv(T)*a22(end)*T;
    a12(end)=0;
    a21(end)=0;
    a22(end)=0;
    b1(end)=inv(T);
    b2(end)=0;
    c1(end)=c2(end)*T;
    c2(end)=0;
  endif

endfunction


