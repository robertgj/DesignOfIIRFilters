function [P,gradP]=directFIRnonsymmetricP(w,h)
% [P,gradP]=directFIRnonsymmetricP(w,h)
% Inputs:
%   w - angular frequencies
%   h - coefficients of a nonsymmetric FIR filter polynomial, [h0 ... hN]
% Outputs:
%   P - a column vector of the phase at w
%   gradP - the gradients of the phase wrt h at wa. The rows of gradP
%           are the gradients of P at each frequency in w. 
  
% Copyright (C) 2021 Robert G. Jenssen
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
    print_usage("[P,gradP]=directFIRnonsymmetricP(w,h)");
  endif
  if isempty(h)
    error("h is empty");
  endif
  if isempty(w)
    P=[];
    gradP=[];
    return;
  endif

  w=w(:);
  h=h(:)';
  Nw=length(w);
  N=length(h)-1;

  kw=kron(w,0:N);
  coskw=cos(kw);
  sinkw=sin(kw);
  kh=kron(ones(Nw,1),h);
  P=-atan2(sum(kh.*sinkw,2),sum(kh.*coskw,2));
  P=unwrap(P);
  if nargout==1
    return;
  endif

  lmk=((0:N)')-(0:N);
  sinlmkw=sin(kron(w',lmk));
  khl=kron(ones(1,Nw),kron(h',ones(1,N+1)));
  khlsinlmkw=sum(khl.*sinlmkw,1);
  gradP=reshape(khlsinlmkw,N+1,Nw);
  gradP=gradP';
  Asq=directFIRnonsymmetricAsq(w,h);
  gradP=gradP./kron(Asq,ones(1,N+1));
  
endfunction
