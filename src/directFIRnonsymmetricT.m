function [T,gradT]=directFIRnonsymmetricT(w,h)
% [T,gradT]=directFIRnonsymmetricT(w,h)
% Inputs:
%   w - angular frequencies
%   h - coefficients of a nonsymmetric FIR filter polynomial, [h0 ... hN]
% Outputs:
%   T - a column vector of the group delay at w
%   gradT - the gradients of the group delay wrt h at w. The rows of gradT
%           are the gradients of T at each frequency in w. 
  
% Copyright (C) 2021-2025 Robert G. Jenssen
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

  if (nargout > 2) || (nargin ~= 2)
    print_usage("[T,gradT]=directFIRnonsymmetricT(w,h)");
  endif
  if isempty(h)
    error("h is empty");
  endif
  if isempty(w)
    T=[];
    gradT=[];
    return;
  endif

  w=w(:);
  h=h(:)';
  Nw=length(w);
  N=length(h)-1;

  [Asq,gradAsq]=directFIRnonsymmetricAsq(w,h);

  lmk=((0:N)')-(0:N);
  % coslmkw and khl are Nw ((N+1)-by-(N+1)) arrays placed left-to-right
  coslmkw=cos(kron(w',lmk));
  khl=kron(ones(1,Nw),kron(ones(1,N+1),h'));
  % khlcoslmkw is Nw (1-by-(N+1)) arrays placed left-to-right
  khlcoslmkw=sum(khl.*coslmkw,1);
  kkhk=kron(ones(1,Nw),(0:N).*h);
  T=kkhk.*khlcoslmkw;
  T=reshape(T,N+1,Nw);
  T=sum(T,1);
  T=(T')./Asq;
  if nargout==1
    return;
  endif

  klpk=kron(ones(1,Nw),((0:N)')+(0:N));
  kkhlcoslmkw=sum(klpk.*khl.*coslmkw,1);
  gradT=reshape(kkhlcoslmkw,N+1,Nw);
  gradT=gradT';
  kAsq=kron(ones(1,N+1),Asq);
  kT=kron(ones(1,N+1),T);
  gradT=(gradT-(kT.*gradAsq))./kAsq;

endfunction
