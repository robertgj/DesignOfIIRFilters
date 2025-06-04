function [A,b,c,d,dAdx,dbdx,dcdx,dddx]=tf2Abcd(N,D)
% [A,b,c,d,dAdx,dbdx,dcdx,dddx]=tf2Abcd(N,D)
% Convert the direct form transfer function, H(z)=N(z)/D(z), where:
%    D(z)=z^n+D(2)z^(n-1)+...+D(n-1)z+D(n)
%    N(z)=N(1)z^n+...+N(n-1)z+N(n)
%
% to the state-variable form:
%    x(k+1)=Ax(k)+bu(k)
%      y(k)=cx(k)+du(k)
%
% The dAdx etc are cell arrays of length length(N)+length(D)-1 corresponding
% to the gradients of A etc with respect to N(1),...,N(end),D(2),...,D(end)
% where I assume D(1)=1.
  
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

  if (nargin ~= 2) || ((nargout ~= 4) && (nargout ~=8))
    print_usage(["[A,b,c,d]=tf2Abcd(N,D)\n", ...
                 "[A,b,c,d,dAdx,dbdx,dcdx,dddx]=tf2Abcd(N,D)"]);
  endif
  if isempty(N)
    error("N is empty");
  endif
  if isempty(D)
    error("D is empty");
  endif
  
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
  
  if (length(N) == 1) && (length(D) == 1)
    A=[];
    b=[];
    c=[];
    d=N(1);
  else
    A=[zeros(n-2,1) eye(n-2);-D(n:-1:2)];
    b=[zeros(n-2,1);1];
    c=N(n:-1:2)-(N(1)*D(n:-1:2));
    d=N(1);
  endif

  if nargout == 4
    return;
  endif

  nND=nN+nD-1;
  dAdx=cell(1,nND);
  dbdx=cell(1,nND);
  dcdx=cell(1,nND);
  dddx=cell(1,nND);

  if (length(N) == 1) && (length(D) == 1)
    dAdx{1}=[];
    dbdx{1}=[];
    dcdx{1}=[];
    dddx{1}=1;
    return;
  endif
  
  for k=1:nN,
    dAdx{k}=zeros(size(A));
  endfor   
  for k=2:nD,
    dAdx{nN+k-1}=zeros(size(A));
    dAdx{nN+k-1}(n-1,n-k+1)=-1;
  endfor

  for k=1:nND,
    dbdx{k}=zeros(size(b));
  endfor

  dcdx{1}=-D(n:-1:2);
  for k=2:nN,
    dcdx{k}=zeros(size(c));
    dcdx{k}(n-k+1)=1;
  endfor
  for k=2:nD,
    dcdx{nN+k-1}=zeros(size(c));
    dcdx{nN+k-1}(n-k+1)=-N(1);
  endfor

  dddx{1}=1;
  for k=2:nND,
    dddx{k}=0;
  endfor
  
endfunction

