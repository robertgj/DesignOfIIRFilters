function [Z,P,K,dBas,iter] = ...
           saramakiFBvNewton(n,m,fp,fs,dBap,maxiter,tol)
% [Z,P,K,dBas,iter] = ...
%   saramakiFBvNewton(n,m,fp,fs,dBap, maxiter,tol)
% Find the zeros, Z, poles, P, and gain, K, of an IIR low-pass filter
% with denominator order, n, numerator order, m>n, pass-band edge, fp,
% stop-band edge, fs, and pass-band peak-to-peak ripple, dBap. This
% implementation uses the Newton-Raphson method to find the poles of
% saramakiFBv in the transformed pass-band on the positive-v axis.
% See: "Design of Optimum Recursive Digital Filters with Zeros on the
% Unit Circle", T. Saramaki, IEEE Trans. ASSP, April 1983. (I use v
% instead of w to avoid confusion between w and omega).

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
  if nargout<3 || nargout>5 || nargin<5 || nargin>8
    print_usage("[Z,P,K,dBas,iter]=saramakiFBvNewton(n,m,fp,fs,dBap, ...\n\
                                        maxiter,tol,verbose)\n\
[Z,P,K,dBas,iter]=saramakiFBvNewton(n,m,fp,fs,dBap)");
  endif

  % Sanity checks
  if m==0
    error("m==0");
  endif
  if n>=m
    error("n>=m");
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
    tol=1e-5;
  endif 
  if nargin<8
    verbose=false;
  endif

  % Initialise
  wp=fp*2*pi;
  ws=fs*2*pi;
  deltap=1-(10^(-dBap/20));
  
  %
  % Frequency transformation
  %
  w1=ws;
  w2=pi;
  C=2/(cos(w1)-cos(w2));
  D=-C*(cos(w1)+cos(w2));
  zeta(1)=((2*C)+D-sqrt((((2*C)+D).^2)-4))/2;
  zeta(2)=((2*C*cos(wp))+D-sqrt((((2*C*cos(wp))+D).^2)-4))/2;
  nv=200;
  v=linspace(zeta(1),zeta(2),nv);
  v=v(:);

  %
  % Find initial filter
  %
  % Find Chebychev Type 1 filter
  [b0,a0]=cheby1(n,dBap,2*fp);
  nh=1000;
  [h0,w0]=freqz(b0,a0,nh);
  % Find the n+1 extrema of the pass-band response
  nfp=ceil(fp*nh/0.5)+1;
  nfe=sort([local_max(h0(1:nfp));local_max(-abs(h0(1:nfp)))]);
  dl=abs(h0(nfe)).^2;
  % Convert extrema frequencies to the v-plane
  v1v=(2*C*cos(w0(nfe)))+D;
  vl=(v1v-sqrt((v1v.^2)-4))/2;
  vl=vl(:);
  if any(vl<zeta(1))
    error("any(vl<zeta(1))");
  endif
  if any(vl>zeta(2))  
    error("any(vl>zeta(2))");
  endif
  % Find a polynomial that fits the extrema in the v-plane
  Deltap=2*deltap*(1-deltap);
  Deltapn=1-(Deltap/2)*(1+((-1).^(n:-1:0)));
  p0=polyfit(vl(:),Deltapn(:),n);
  zp0=qroots(p0);
  % !!! A hack to ensure the real roots of p0 are in [-1,zeta(1)) !!!
  zp0r=zp0(find(abs(imag(zp0))<tol));
  if any(zp0r>zeta(2))
    p0=(2-Deltap-p0);
  endif
  % Estimate Deltas
  x0FBv=(v.^(n-m)).*polyval(fliplr(p0),v)./polyval(p0,v);
  x0HH=(1+((x0FBv+(1./x0FBv))/2)/2);
  Deltas=(1-(Deltap/2))/mean(x0HH);
  % Convert the polynomial to second-order-sections
  non2=floor(n/2);
  [sos0,g0]=tf2sos(1,p0);
  x0B=sos0(1:non2,5:6)'(:)';
  if mod(n,2)
    x0B=[x0B,-sos0(end,5)];
  endif

  %
  % Newton-Raphson solution
  %
  % Find the poles that give FBv with n+1 extremal values 1 and Deltap
  mu=0.1;
  gamma=4/Deltas;
  xB=x0B;
  for iter=0:maxiter,
    if iter==maxiter,
      error("iter==maxiter")
    endif
    % Find F and gradient of F
    [xF,delFdelB]=saramakiFBv(xB,n,m,v);
    % Find (xF/gamma)>(1-Deltap)
    kl=local_max(1-Deltap-(xF/gamma));
    sl=kl(find((1-Deltap-(xF(kl)/gamma))>tol));
    % Find xF>1
    ku=local_max((xF/gamma)-1);
    su=ku(find(((xF(ku)/gamma)-1)>tol));
    
    % Newton-Raphson solution
    [xFs,xFk]=sort([sl(:);su(:)]);
    extrema=gamma*[ones(length(sl),1)-Deltap;ones(length(su),1)];
    extrema=extrema(xFk);
    xFext=xF(xFs);
    xdelFdelBext=delFdelB(xFs,:);
    A=[xdelFdelBext,-extrema];
    b=extrema-xFext;
    delx=A\b;
    delx=delx(:)';
    % Update B and Deltas
    xB=xB+(mu*delx(1:(end-1)));
    gamma=gamma+(mu*delx(end));
    Deltas=4/gamma;
    % Check pole radius
    rk=xB(2:2:(2*(non2)));
    if mod(n,2)
      Rk=xB(n);
    else
      Rk=[];
    endif
    if any([sqrt(abs(rk)),abs(Rk)]>=1)
      error("pole radius >= 1)");
    endif  
    % Loop condition
    if norm(mu*delx./[xB,gamma])<tol
      break;
    endif
  endfor

  %
  % Find the v-plane poles and zeros of the filter
  %
  % Poles of FBv are poles of HH
  vP=zeros(non2+mod(n,2),1);
  for k=1:non2
    discr=sqrt((xB((2*k)-1)^2)-(4*xB(2*k)));
    vP(k)=(-xB((2*k)-1)+discr)/2;
  endfor  
  if mod(n,2)
    vP(non2+1)=xB(n);
  endif
  % Zeros of FBv+1 are zeros of HH
  vA=1;
  for k=1:2:((2*non2)-1)
    vA=conv(vA,[1 xB(k) xB(k+1)]);
  endfor
  if mod(n,2)
    vA=conv(vA,[1 -xB(n)]);
  endif
  vAroots=qroots([zeros(1,m-n),fliplr(vA)]+[vA,zeros(1,m-n)]);
  if any(abs(abs(vAroots)-1)>tol)
    error("any(abs(abs(vAroots)-1)>tol)");
  endif
  if length(vAroots)~=m
    error("length(vAroots)~=m");
  endif
  mon2=floor(m/2);
  vZ=zeros(mon2,1);
  vZ=vAroots(find(imag(vAroots)>tol));
  if length(vZ)~=mon2
    error("length(vZ)~=mon2");
  endif
  if mod(m,2)
    vZz=vAroots(find(abs(imag(vAroots))<tol));
    if length(vZz)~=1
      error("length(vZz)~=1");
    endif
    vZ=[vZ;vZz];
  endif

  %
  % Translate from v-plane to z-plane
  %
  % Poles
  P=zeros(n,1);
  bP=-(vP+(1./vP)-D)/C;
  for k=1:non2
    P((2*k)-1)=(-bP(k)-sqrt((bP(k).^2)-4))/2;
    P(2*k)=conj(P((2*k)-1));
  endfor
  if mod(n,2)
    P(n)=(-bP(non2+1)-sqrt((bP(non2+1).^2)-4))/2;
  endif
  % Zeros
  Z=zeros(m,1);
  bZ=-(vZ+(1./vZ)-D)/C;
  for k=1:mon2
    Z((2*k)-1)=(-bZ(k)-sqrt((bZ(k).^2)-4))/2;
    Z(2*k)=conj(Z((2*k)-1));
  endfor
  if mod(m,2)
    Z(m)=(-bZ(mon2+1)-sqrt((bZ(mon2+1).^2)-4))/2;
  endif

  %
  % Calculate gain
  %
  ejwp=e^(j*wp);
  hK=prod(1-(Z/ejwp))/prod(1-(P/ejwp));
  K=sqrt((1-Deltap)/(abs(hK)^2));
  dBas=-10*log10(Deltas);
  
endfunction
