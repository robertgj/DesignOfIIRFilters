function [A,b,c,d]=tf2Abcd(N,D)
% [A,b,c,d]=tf2Abcd(N,D)
% Convert the transfer function H(z)=N(z)/D(z) to state-variable form
% D(z)=z^n+D(2)z^(n-1)+...+D(n-1)z+D(n)
% N(z)=N(1)z^n+...+N(n-1)z+N(n)
% x(k+1)=Ax(k)+bu(k), y(k)=cx(k)+du(k)

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

  N=N(:)'/D(1);
  D=D(:)'/D(1);

  nD=length(D);
  nN=length(N);
  if nD>nN
    N=[N zeros(1,nD-nN)];
    n=nD;
  elseif nN>nD
    D=[D zeros(1,nN-nD)];
    n=nN;
  else
    n=nN;
  endif
  
  A=[zeros(n-2,1) eye(n-2);-D(n:-1:2)];
  b=[zeros(n-2,1);1];
  c=N(n:-1:2)-(N(1)*D(n:-1:2));
  d=N(1);

endfunction

