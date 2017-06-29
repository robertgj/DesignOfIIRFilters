function showZPplot(x,U,V,M,Q,R,title_str)
  % showZPplot(x,U,V,M,Q,R,title_str)

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

  % Sanity checks
  if nargin!=7
    print_usage("showZPplot(x,U,V,M,Q,R,title_str)")
  endif
  if length(x) != (1+U+V+M+Q)
    error("length(x) != (1+U+V+M+Q)");
  endif
  if rem(M,2) != 0
    error("Expected M(%d) even!",M);
  endif
  if rem(Q,2) != 0
    error("Expected Q(%d) even!",Q);
  endif
  
  if (U+M) == 0
    Z=[];
  else
    Z=zeros(U+M,1);
    % Real zeros
    Z(1:U)=x(2:(U+1));
    % Complex zeros
    for k=1:(M/2)
      Z(U+k)      =x(1+V+U+k)*exp( j*x(k+1+V+U+(M/2)));
      Z(U+(M/2)+k)=x(1+V+U+k)*exp(-j*x(k+1+V+U+(M/2)));
    endfor
  endif

  if (V+Q) == 0
    P=[];
  else
    P=zeros(R*(V+Q),1);
    % Real poles
    for k=1:V
      for l=0:(R-1)
        P(((k-1)*R)+l+1)=(x(1+U+k)^(1/R))*exp(j*2*pi*l/R);
      endfor
    endfor
    % Complex poles
    for k=1:(Q/2)
      for l=0:(R-1)
        P((R*(V+k-1))+l+1)      =(x(k+1+U+V+M)^(1/R))* ...
                                 exp(j*((2*pi*l)+x(k+1+U+V+M+(Q/2)))/R);
        P((R*(V+(Q/2)+k-1))+l+1)=(x(k+1+U+V+M)^(1/R))* ...
                                 exp(j*((2*pi*l)-x(k+1+U+V+M+(Q/2)))/R);
      endfor
    endfor
  endif

  subplot(111);
  zplane(Z,P);
  title(title_str);

endfunction

