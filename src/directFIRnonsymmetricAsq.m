function [Asq,gradAsq]=directFIRnonsymmetricAsq(w,h)
% [Asq,gradAsq]=directFIRnonsymmetricAsq(w,h)
% Inputs:
%   w - angular frequencies
%   h - oefficients of a nonsymmetric FIR filter polynomial, [h0 ... hN]
% Outputs:
%   Asq - a column vector of the squared amplitudes at wa.
%   gradAsq - the gradients of the squared amplitude wrt h at wa. The rows
%             of gradAsq are the gradients of Asq at each frequency in wa. 
  
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
    print_usage("[Asq,gradAsq]=directFIRnonsymmetricAsq(w,h)");
  endif
  if isempty(h)
    error("h is empty");
  endif
  if isempty(w)
    Asq=[];
    gradAsq=[];
    return;
  endif

  w=w(:);
  h=h(:)';
  Nw=length(w);
  N=length(h)-1;

  % Create 2-D arrays of Nw ((N+1)-by-(N+1)) arrays placed left-to-right
  lmk=((0:N)')-(0:N);
  coslmkw=cos(kron(w',lmk));
  khl=kron(ones(1,Nw),kron(h',ones(1,N+1)));
  % Here khlcoslmkw is Nw (1-by-(N+1)) arrays placed left-to-right
  khlcoslmkw=sum(khl.*coslmkw,1);

  % khl is [h(1), ... , h(N+1), h(1), ... , h(N+1), ... , h(N+1)] 
  khl=kron(ones(1,Nw),h);
  Asq=khl.*khlcoslmkw;
  Asq=reshape(Asq,N+1,Nw);
  Asq=sum(Asq,1);
  Asq=Asq';

  % Reshape khl.*coslmkw to Nw-by-(N+1)
  gradAsq=reshape(khlcoslmkw,N+1,Nw);
  gradAsq=2*gradAsq';
  
endfunction
