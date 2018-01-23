function p=phi2p(phi)
% p=phi2p(phi)
% Given the band edges phi(k) find the frequency transformation 
% F(z)=p(z)/(z^(-M)p(z^(-1))). phi(1:M) is a vector of band edges 
% in [0,0.5) where 0.5 corresponds to Fs/2 and p(z)=Sum[k=0,M](p(k)z^(-k)).
% Reference: Figure 6.7.3 of "Digital Signal Processing" R.A. Roberts
% and C.T. Mullis Addison-Wesley ISBN 0-201-16350-0

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

% Initialisation
phi=phi*2*pi;
n=length(phi);
q=zeros(1,n+1);
p=zeros(1,n+1);
p(1)=1;
v=0.5;

% Loop
for k=1:n
  v=-v;
  phip=(phi(k)-pi)*v;
  for j=0:k
    Alpha=0;
    Beta=0;
    if j > 0
      Alpha=Alpha+p(j);
      Beta=Beta-p(1+k-j);
    endif
    if j < k
      Alpha=Alpha+p(j+1);
      Beta=Beta+p(k-j);
    endif
    q(j+1)=Alpha*cos(phip) + Beta*sin(phip);
  endfor
  p(1:(k+1))=q(1:(k+1));
endfor

p=p/p(1);

endfunction
