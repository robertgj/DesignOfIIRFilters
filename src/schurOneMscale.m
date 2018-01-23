function [S1M,epsilon,p] = schurOneMscale(k,S)
% [S1M,epsilon,p] = schurOneMscale(k,S)
% Determine the sign coefficients, epsilon, and scaling factors, p,
% that scale the Schur lattice filter with coefficients, k, and Schur 
% orthogonal basis, S. The orthonormal Schur basis is returned in S1M. 
% Reference: "Digital Lattice and Ladder Filter Synthesis" A.H.Gray, Jr. 
% and J.D.Markel, IEEE Trans. Audio and Electroacoustics, Vol. 20, No. 6,
% Dec. 1973, pp.496

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

% Sanity check
if rows(S) ~= length(k)+1 || columns(S) ~= length(k)+1
  error("Expected S to be square matrix size length(k)+1");
endif 

% Select the sign coefficients
M=length(k);
epsilon=zeros(1,M);
[kl,l]=max(abs(k));
Qm=1;
for m=l-1:-1:1
  qm=(1+abs(k(m)))/(1-abs(k(m)));
  if Qm<(1/qm)
    epsilon(m)=sign(k(m));
    Qm=Qm*qm;
  else
    epsilon(m)=-sign(k(m));
    Qm=Qm/qm;
  endif
endfor

Qm=1;
for m=l:M
  qm=(1+abs(k(m)))/(1-abs(k(m)));
  if Qm<(1/qm)
    epsilon(m)=-sign(k(m));
    Qm=Qm*qm;
  else
    epsilon(m)=sign(k(m));
    Qm=Qm/qm;
  endif
endfor

% Scale the orthonormal Schur basis to the one-multiplier lattice
% orthogonal Schur basis
S1M=S;
p=zeros(1,M);
scale=1;
for m=M:-1:1
  scale=scale*sqrt((1+(epsilon(m)*k(m)))/(1-(epsilon(m)*k(m))));
  p(m)=scale;
  S1M(m,:)=S1M(m,:)*p(m);
endfor

endfunction
