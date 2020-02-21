function [hM,a,haM]=herrmannFIRsymmetric_flat_lowpass(M,K,atype)
% [hM,a,haM]=herrmannFIRsymmetric_flat_lowpass(M,K,atype)
% Herrmann's closed-form design of a symmetric, linear-phase,
% maximally-flat FIR low-pass filter.
%
% Inputs:
%   M - the filter length is 2M+1
%   K - order of flatness at omega=pi
%   atype - method of calculation of the a coefficients (Herrmann Eqn 5)
%           "finitedifference","rajagopal","forward","backward". The default is
%           to use the finite difference method. "rajagopal" refers to Rajagopal
%           Eqn 23. "forward" and "backward" refer to implementation of
%           Rajagopal Eqn 23 with forwards or backwards recursion.
% Outputs:
%   hM - M+1 distinct FIR coefficients, Rajagopal Eqn 17
%   a - the M+1 a coefficients of powers of x=((1-cos(omega))/2)
%   haM - M+1 distinct FIR coefficients, Herrmann Eqn 5 (equal to hM)
%
% See:
%  [1] "Design of Maximally-Flat FIR Filters Using the Bernstein Polynomial",
%      L. R. Rajagopal and S. C. Dutta Roy, IEEE Transactions on Circuits and
%      Systems, Vol. CAS-34, No. 12, December 1987, pp. 1587-1590
%  [2] "On the Approximation Digital Filter Design", O. Herrmann, IEEE
%      Transactions on Circuit Theory, May 1971, pp. 411-413
  
% Copyright (C) 2020 Robert G. Jenssen
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

  if (nargin<2) || (nargin>3) || (nargout>3)
    print_usage("[hM,a,haM]=herrmannFIRsymmetric_flat_lowpass(M,K,atype);");
  endif

  % Sanity checks
  if nargin==2
    atype="finitedifference";
  endif
  if M<=0
    error("M<=0");
  endif
  if K>M
    error("K>M");
  endif
  L=M-K+1;
  
  % Calculate hM with Rajagopal's equation 17
  pz2=cell(1,1+M);
  pz2{1+0}=1;
  for k=1:M,
    pz2{1+k}=conv(pz2{1+k-1},[1 2 1]/4);
  endfor
  mz2=cell(1,1+M-K);
  mz2{1+0}=1;
  for k=1:(M-K),
    mz2{1+k}=conv(mz2{1+k-1},[1 -2 1]/4);
  endfor
  h=zeros(1,(2*M)+1);
  for k=0:(M-K)
    h=h+(((-1).^(k))*conv(mz2{1+k},pz2{1+M-k})*bincoeff(M,k));
  endfor
  hM=h(1:(M+1));

  if nargout==1
    return;
  endif

  % Calculate the filter a coefficients
  if strncmp(atype,"finitedifference",6)
    fd=zeros(M+1,M+1);
    fd(:,1+0)=[ones(L,1);zeros(K,1)];
    for q=1:M,
      for p=0:M-q,
        fd(1+p,1+q)=fd(1+p+1,1+q-1)-fd(1+p,1+q-1);
      endfor
    endfor
    a=(bincoeff(M,0:M).*fd(1,:));
  elseif strncmp(atype,"rajagopal",6);
    a=zeros(1,M+1);
    a(1+0)=1;
    for k=L:M,
      a(1+k)=((-1)^(k-L+1))*(L/k)*prod((L+1):M)/(factorial(k-L)*factorial(M-k));
    endfor
  elseif strncmp(atype,"forwards",6);
    a=zeros(1,M+1);
    a(1+0)=1;
    a(1+L)=-prod((L+1):M)/factorial(M-L);
    for k=(L+1):M,
      a(1+k)=-a(1+k-1)*(k-1)*(M-k+1)/(k*(k-L));
    endfor
  elseif strncmp(atype,"backwards",6);
    a=zeros(1,M+1);
    a(1+0)=1;
    a(M+1)=((-1)^(M-L+1))*prod(L:(M-1))/factorial(M-L);
    for k=(M-1):-1:L,
      a(1+k)=-a(1+k+1)*((k+1)*(k+1-L))/((M-k)*k);
    endfor
  else
    error("Unknown atype : %s",atype);
  endif

  if nargout==2
    return;
  endif
  
  % Calculate haM with Herrmann's equation 5
  wM=pi*(0:M)'/M;
  x=(1-cos(wM))/2;
  xx=x.^(0:M);
  Ha=xx*a(1:(M+1))';
  ha=ifft([Ha;Ha((end-1):-1:2)]);
  haM=flipud(real([ha(1:M);ha(M+1)/2]));
  haM=haM(:)';

endfunction
