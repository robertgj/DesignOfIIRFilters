function [z,p,K,dBas,iter] = ...
         saramakiFAvNewton(n,m,fp,fs,dBap,maxiter,tol)
% [z,p,K,dBas,iter] = ...
%   saramakiFAvNewton(n,m,fp,fs,dBap, maxiter,tol)
% Find the zeros, z, poles, p, and gain, K, of an IIR low-pass filter
% with denominator order, n, numerator order, m<=n, pass-band edge, fp,
% stop-band edge, fs, and pass-band peak-to-peak ripple, dBap. This
% implementation uses the Newton-Raphson method to find the poles of
% saramakiFAv in the transformed stop-band on the negative-v axis.
% See: "Design of Optimum Recursive Digital Filters with Zeros on the
% Unit Circle", T. Saramaki, IEEE Trans. ASSP, April 1983. (I use v
% instead of w to avoid confusion between w and omega).

% Copyright (C) 2018-2025 Robert G. Jenssen
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
  if nargout<3 || nargout>5 || nargin<5 || nargin>7
    print_usage("[z,p,K,dBas,iter]= ...\n\
  saramakiFAvNewton(n,m,fp,fs,dBap,maxiter,tol)");
  endif

  % Sanity checks
  if m==0
    error("m==0");
  endif
  if n<m
    error("n<m");
  endif
  if 0>fp || fp>0.5
    error("0>fp || fp>0.5")
  endif
  if 0>fs || fs>0.5
    error("0>fs || fs>0.5")
  endif 
  if fp>fs
    error("fp>fs")
  endif
  if nargin<6
    maxiter=1000;
  endif
  if nargin<7
    tol=1e-6;
  endif 

  % Initialise
  mon2=floor(m/2);
  nf=1000*mon2;
  wp=2*pi*fp;
  ws=2*pi*fs;
  deltap=1-10^(-dBap/20);
  Deltap=2*deltap*(1-deltap);

  % Frequency transformation
  w1=0;
  w2=wp;
  C=2/(cos(w1)-cos(w2));
  D=-C*(cos(w1)+cos(w2));
  zeta(1)=-0.5*(-(2*C*cos(ws))-D-sqrt(((-2*C*cos(ws)-D).^2)-4));
  zeta(2)=-0.5*(2*C-D-sqrt(((2*C-D).^2)-4));

  % Initialise frequency points
  v=linspace(zeta(1),zeta(2),nf);
  v=v(:);
  if mod(m,2)
    v=v(1:(end-1));
  endif

  % Solve for the roots, alpha, that minimise Fav
  alpha=linspace(zeta(1),zeta(2),2+mon2);
  alpha=alpha(2:(end-1));
  m1n=(-1)^n;
  lambda=0;
  for iter=0:maxiter,
    if iter==maxiter,
      error("iter==maxiter")
    endif

    [F,delFdelalpha]=saramakiFAv(alpha,n,m,v,zeta);
    if any((m1n*F)<=0)
      error("any((m1n*F)<=0)");
    endif
    iFmin=local_max(-m1n*F);
    m1n*F(iFmin);
    if length(iFmin)~=(mon2+1)
      error("length(iFmin)~=(mon2+1)");
    endif
    A=[m1n*delFdelalpha(iFmin,:), -ones(length(iFmin),1)];
    b=[-m1n*F(iFmin)+lambda];
    x=A\b;
    del_alpha=x(1:(end-1))';
    alpha=alpha+del_alpha;
    if any(alpha<zeta(1)) || any(alpha>zeta(2))
      error("any(alpha<zeta(1)) || any(alpha>zeta(2))")
    endif
    del_lambda=x(end);
    lambda=lambda+del_lambda;
    if abs(del_lambda/lambda)<tol,
      break;
    endif
  endfor
  
  % Convert v-plane alpha to z-plane zero locations
  omega=acos((alpha+(1./alpha)-D)/(2*C));
  z=[];
  for k=1:mon2;
    z=[z;exp(-j*omega(k)*[-1;1])];
  endfor
  if mod(m,2)
    z=[z;-1];
  endif

  % Find beta
  den_v=1;
  for k=1:mon2
    den_v=conv(den_v,[1 -alpha(k)]);
  endfor
  den_v=conv(den_v,den_v);
  if mod(m,2)
    den_v=conv(den_v,[1 -zeta(2)]);
  endif
  den_v=den_v*m1n*(((2-Deltap)/Deltap)+sqrt((((2-Deltap)/Deltap)^2)-1));
  num_v=1;
  for k=1:mon2
    num_v=conv(num_v,[-alpha(k) 1]);
  endfor
  num_v=conv(num_v,num_v);
  if mod(m,2)
    num_v=conv(num_v,[-zeta(2) 1]);
  endif
  beta=qroots([den_v zeros(1,n-m)]+[zeros(1,n-m) num_v]);
  
  % Convert v-plane beta to z-plane pole locations
  z1z=((beta+(1./beta))-D)/C;
  p=(z1z-sqrt((z1z.^2)-4))/2;
  
  % Find scale factor
  ejwp=e^(j*wp);
  h=prod(1-(z/ejwp))/prod(1-(p/ejwp));
  K=sqrt((1-Deltap)/(abs(h)^2));

  % Find stop-band ripple
  Deltas=1/(1+((Deltap/(1-Deltap))*((1/2)+((1/4)*(lambda+(1/lambda))))));
  dBas=-10*log10(Deltas);
  
endfunction
