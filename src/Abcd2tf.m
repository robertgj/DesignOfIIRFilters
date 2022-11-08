function [N,D,B]=Abcd2tf(A,b,c,d)
% [N,D,B]=Abcd2tf(A,b,c,d)
% Use Leverriers algorithm to find the transfer function
% H(z)=N(z)/D(z) from the state variable description A,b,c,d
% Note that D(z) is the characteristic equation of A and that
% B is a length (n+1) cell array of nxn matrixes in which B(k,:,:)
% is the k'th matrix coefficient of the resolvent (zI-A)^(-1)
%
% Reference: Appendix 8A, p. 333 of 
% "Digital Signal Processing" R.A. Roberts
% and C.T. Mullis Addison-Wesley ISBN 0-201-16350-0

% Copyright (C) 2017-2022 Robert G. Jenssen
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
  if (nargin ~= 4) || (nargout<2) || (nargout>3)
    print_usage("[N,D,B]=Abcd2tf(A,b,c,d)");
  endif
  if isempty(A)
    error("A is empty");
  endif
  if rows(A) ~= columns(A)
    error("Expect A square");
  endif
  if columns(b) ~= 1 || rows(A) ~= rows(b) 
    error("Expect b rows(A)x1 column vector");
  endif
  if columns(c) ~= columns(A) || rows(c) ~= 1 
    error("Expect c 1xcolumns(A) row vector");
  endif
  if columns(d) ~= 1 || rows(d) ~= 1 
    error("Expect d a scalar");
  endif
  
  % Loop columns(A)+1 times to find the characteristic polynomial, D, of A
  Abcd2tf_loop(A,b,c);
  if nargout<3
    [N,D]=arrayfun(@Abcd2tf_loop,zeros(1,columns(A)+1));
  else
    [N,D,B]=arrayfun(@Abcd2tf_loop,zeros(1,columns(A)+1),"UniformOutput",false);
    N=cell2mat(N);
    D=cell2mat(D);
  endif
  
  % Complete the numerator
  N=(d*D)+N;

endfunction

function [N,D,B]=Abcd2tf_loop(_A,_b,_c)
  persistent A b c n k BB
  persistent init_done=false
  if nargin==3
    A=_A;
    b=_b;
    c=_c;
    n=rows(A);
    k=0;
    BB=eye(n);
    init_done=true;
    return;
  elseif ~init_done
    error("Not initialised!");
  endif
  if k==0
    N=0;
    D=1;
  else
    N=c*BB*b;
    D=-trace(A*BB/k);
    BB=(A*BB)+(D*eye(n));
  endif
  k=k+1;
  B=BB;
endfunction
