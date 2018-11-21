function [z,p,K,iter] = ...
         saramakiFAvLogNewton(n,m,fp,fs,dBap,dBas,mu,maxiter,tol,verbose)
% [z,p,K]=saramakiFAvLogNewton(n,m,fp,fs,dBap)
% [z,p,K]=saramakiFAvLogNewton(n,m,fp,fs,dBap,dBas)
% [z,p,K,iter]=saramakiFAvLogNewton(n,m,fp,fs,dBap,dBas,mu,maxiter,tol,verbose)
%
% Find the zeros, z, poles, p, and gain, K, of an IIR low-pass filter
% with denominator order, n, numerator order, m, pass-band edge, fp,
% stop-band edge, fs, with pass-band peak-to-peak ripple, dBap, or
% if it is specified, stop-band ripple, dBas. This implementation uses
% the Newton-Raphson method with update scaling factor, mu, to find the
% poles of saramakiFAv in the transformed stop-band on the negative-v
% axis. See: "Design of Optimum Recursive Digital Filters with Zeros
% on the Unit Circle", T. Saramaki, IEEE Trans. ASSP, April 1983.
% (I use v instead of w to avoid confusion between w and omega).

% Copyright (C) 2018 Robert G. Jenssen
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
  if nargout<3 || nargout>4 || nargin<5 || nargin>10
    print_usage("[z,p,K]=saramakiFAvLogNewton(n,m,fp,fs,dBap) \n\
[z,p,K]=saramakiFAvLogNewton(n,m,fp,fs,dBap,dBas) \n\
[z,p,K,iter]=saramakiFAvLogNewton(n,m,fp,fs,dBap,dBas,mu,maxiter,tol,verbose)");
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
    dBas=[];
  endif
  if nargin<7
    mu=0.5; % Newton-Raphson step-size factor
  endif
  if nargin<8
    maxiter=1000;
  endif
  if nargin<9
    tol=1e-12;
  endif 
  if nargin<10
    verbose=false;
  endif

  % Initialise
  nf=1000*floor(m/2);
  wp=2*pi*fp;
  ws=2*pi*fs;

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
  alpha=linspace(zeta(1),zeta(2),2+floor(m/2));
  alpha=alpha(2:(end-1));
  alpha=alpha(:)';
  m1n=(-1)^n;
  Lambda=0;
  for iter=0:maxiter,
    if iter==maxiter,
      error("iter==maxiter")
    endif

    % Find logm1nF
    vv=kron(v,ones(size(alpha)));
    aa=kron(ones(length(v),1),alpha);
    onesv=ones(size(vv));
    oneMav=onesv-(aa.*vv);
    vMa=vv-aa;
    logm1nF=(-(n-m)*log(abs(v)))+(2*sum(log(abs(oneMav))-log(abs(vMa)),2));
    if mod(m,2)
      logm1nF=logm1nF+log(abs(1-(zeta(2)*v)))-log(abs(v-zeta(2)));
    endif
    
    % Find minima of logm1nF
    ilogm1nFmin=local_max(-logm1nF);
    logm1nFmin=logm1nF(ilogm1nFmin);
    if length(logm1nFmin)~=(floor(m/2)+1),
      error("length(logm1nFmin)~=(floor(m/2)+1)");
    endif

    % Find gradient of logm1nF at the minima
    onesv=onesv(ilogm1nFmin,:);
    vv=vv(ilogm1nFmin,:);
    oneMav=oneMav(ilogm1nFmin,:);
    vMa=vMa(ilogm1nFmin,:);
    gradlogm1nFmin=2*(onesv-(vv.^2))./(oneMav.*vMa);
    
    % Set up and solve linearised equations
    A=[gradlogm1nFmin, -ones(length(ilogm1nFmin),1)];
    b=[-logm1nFmin+Lambda];
    x=A\b;

    % Update alpha and Lambda
    del_alpha=x(1:(end-1))';
    alpha=alpha+(mu*del_alpha);
    if any(alpha<zeta(1)) || any(alpha>zeta(2)),
      error("any(alpha<zeta(1)) || any(alpha>zeta(2))")
    endif
    del_Lambda=x(end);
    Lambda=Lambda+(mu*del_Lambda);

    % Check loop condition
    if abs(del_Lambda/Lambda)<tol,
      break;
    endif
  endfor    

  % Find Deltap and Deltas
  lambda=exp(Lambda);
  if isempty(dBas)
    deltap=1-(10^(-dBap/20));
    Deltap=2*deltap*(1-deltap);
    Deltas=1/(1+((Deltap/(1-Deltap))*((1/2)+((1/4)*(lambda+(1/lambda))))));
  else
    Deltas=10^(-dBas/10);
    Deltap=1/(1+((Deltas/(1-Deltas))*((1/2)+((1/4)*(lambda+(1/lambda))))));
    deltap=1-sqrt(1-Deltap);
  endif

  % Convert v-plane alpha to z-plane zero locations
  omega=acos((alpha+(1./alpha)-D)/(2*C));
  z=[];
  for k=1:floor(m/2),
    z=[z;exp(-j*omega(k)*[-1;1])];
  endfor
  if mod(m,2),
    z=[z;-1];
  endif

  % Find beta
  den_v=1;
  for k=1:floor(m/2),
    den_v=conv(den_v,[1 -alpha(k)]);
  endfor
  den_v=conv(den_v,den_v);
  if mod(m,2),
    den_v=conv(den_v,[1 -zeta(2)]);
  endif
  den_v=den_v*m1n*(((2-Deltap)/Deltap)+sqrt((((2-Deltap)/Deltap)^2)-1));
  num_v=1;
  for k=1:floor(m/2),
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
  
  % Find scale factor at fp
  ejwp=e^(j*wp);
  h=prod(1-(z/ejwp))/prod(1-(p/ejwp));
  K=sqrt((1-Deltap)/(abs(h)^2));

endfunction
