function [min_z,min_p,K,iter] = ...
         surmaahoFAvLogNewton(nmin,fp,fs,allpass_p,tp,dBap, ...
                              dBas,mpa,mu,maxiter,tol,verbose)
% [min_z,min_p,K,iter]=surmaahoFAvLogNewton(nmin,m,fp,fs,allpass_p,tp,dBap)
% [min_z,min_p,K,iter]=surmaahoFAvLogNewton(nmin,m,fp,fs,allpass_p,tp,dBap, ...
%                                           dBas,mpa,mu,maxiter,tol,verbose)
% Find the minimum-phase poles and zeros of an initial low-pass filter with
% order, nmin, pass-band edge, fp, stop-band edge, fs, pass-band ripple, dBap,
% stop-band suppression, dBas, approximately flat delay, tp, fixed all-pass
% phase equaliser poles, allpass_p, of muliplicity, mpa (1 or 2), using the
% method of Surma-aho and Saramaki. If the filter has double all-pass poles
% then the final filter can be realised as the parallel sum of two all-pass
% filters. See:
% [1] "Design of Optimum Recursive Digital Filters with Zeros
%      on the Unit Circle", T. Saramaki, IEEE Trans. ASSP, April 1983.
% [2] "A Systematic Technique for Designing Approximately Linear Phase
%      Recursive Digital Filters", K. Surma-aho and T. Saramaki,
%      IEEE Trans. CAS-II, July 1999.

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
  if nargout<3 || nargout>4 || nargin<6 || nargin>12
    print_usage(["[min_z,min_p,K,iter]=surmaahoFAvLogNewton", ...
 "(nmin,fp,fs,allpass_p,tp,dBap)\n", ...
 "[min_z,min_p,K,iter]=surmaahoFAvLogNewton(nmin,fp,fs,allpass_p,tp,dBap, ...\n", ...
 "                                          dBas,mpa,mu,maxiter,tol,verbose)"]);
  endif

  % Sanity checks
  if 0>fp || fp>0.5
    error("0>fp || fp>0.5")
  endif
  if 0>fs || fs>0.5
    error("0>fs || fs>0.5")
  endif 
  if fp>fs
    error("fp>fs")
  endif
  if any(abs(allpass_p)>=1)
    error("any(abs(allpass_p)>=1)");
  endif
  if nargin<7
    dBas=[];
  endif
  if nargin<8
    mpa=1;
  elseif (mpa~=1) && (mpa~=2)
    error("(mpa expected to be 1 or 2(for parallel all-pass)");
  endif
  if nargin<9
    mu=0.5; % Newton-Raphson step-size factor
  endif
  if nargin<10
    maxiter=1000;
  endif
  if nargin<11
    tol=1e-6;
  endif 
  if nargin<12
    verbose=false;
  endif

  % Initialise
  allpass_p=allpass_p(:)';
  nall=length(allpass_p);
  n=nmin+(mpa*nall);
  nf=1000*floor(n/2);
  wp=2*pi*fp;
  ws=2*pi*fs;

  % Frequency transformation
  w1=0;
  w2=wp;
  C=2/(cos(w1)-cos(w2));
  D=-C*(cos(w1)+cos(w2));
  xi(1)=-0.5*(-(2*C*cos(ws))-D-sqrt(((-2*C*cos(ws)-D).^2)-4));
  xi(2)=-0.5*(2*C-D-sqrt(((2*C-D).^2)-4));

  % Initialise frequency points
  v=linspace(xi(1),xi(2),nf);
  v=v(:);
  if mod(n,2)
    v=v(1:(end-1));
  endif

  % Convert fixed zeros to v-plane
  fz1fz=C*(allpass_p+(1./allpass_p))+D;
  Gamma=(fz1fz-sqrt((fz1fz.^2)-4))/2;
  if any(abs(Gamma)>=1)
    Gamma=(fz1fz+sqrt((fz1fz.^2)-4))/2;
  endif
  if any(abs(Gamma)>=1)
    error("any(abs(Gamma)>=1)");
  endif
  
  % Solve for the roots, R, that minimise F
  R=linspace(xi(1),xi(2),2+floor(nmin/2));
  R=R(2:(end-1));
  R=R(:)';
  m1n=(-1)^n;
  Lambda=0;
  for iter=0:maxiter,
    if iter==maxiter,
      error("iter==maxiter")
    endif
   
    % Find fixed zeros response 
    vvG=kron(v,ones(size(Gamma)));
    GG=kron(ones(length(v),1),Gamma);
    onesvG=ones(size(vvG));
    oneMvG=onesvG-(GG.*vvG);
    vMG=vvG-GG;
    Ffixed=(prod(oneMvG./vMG,2));
    if abs(imag(Ffixed))>tol
      error("abs(imag(Ffixed))>tol");
    endif
    logFfixed=mpa*log(abs(real(Ffixed)));
                      
    % Find logF
    vv=kron(v,ones(size(R)));
    RR=kron(ones(length(v),1),R);
    onesv=ones(size(vv));
    oneMRv=onesv-(RR.*vv);
    vMR=vv-RR;
    logF=logFfixed+(2*sum(log(abs(oneMRv))-log(abs(vMR)),2));
    if mod(nmin,2)
      logF=logF+log(abs(1-(xi(2)*v)))-log(abs(v-xi(2)));
    endif
    
    % Find minima of logF
    ilogFmin=local_max(-logF);
    logFmin=logF(ilogFmin);
    if length(ilogFmin)~=(floor(nmin/2)+1)
      error("length(ilogFmin)(%d)~=(floor(nmin/2)+1)(%d)", ...
            length(ilogFmin),floor(nmin/2)+1);
    endif
    
    % Find gradient of logF at the minima
    onesv=onesv(ilogFmin,:);
    vv=vv(ilogFmin,:);
    oneMRv=oneMRv(ilogFmin,:);
    vMR=vMR(ilogFmin,:);
    gradlogFmin=2*(onesv-(vv.^2))./(oneMRv.*vMR);
    
    % Set up and solve linearised equations
    A=[gradlogFmin, -ones(length(ilogFmin),1)];
    b=[-logFmin+Lambda];
    x=A\b;

    % Update xi and Lambda
    del_R=x(1:(end-1))';
    R=R+(mu*del_R);
    if any(R<xi(1)) || any(R>xi(2)),
      error("any(R<xi(1)) || any(R>xi(2))")
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

  % Convert v-plane R to z-plane zero locations
  omega=acos((R+(1./R)-D)/(2*C));
  z=[];
  for k=1:floor(nmin/2),
    z=[z;exp(-j*omega(k)*[-1;1])];
  endfor
  if mod(nmin,2),
    z=[z;-1];
  endif
  min_z=sort(z);
  if mpa==2
    min_z=sort([min_z;allpass_p(:)]);
  endif
  
  % Numerator of F
  num_v=1;
  for k=1:floor(nmin/2),
    num_v=conv(num_v,[-R(k) 1]);
  endfor
  num_v=conv(num_v,num_v);
  if mod(nmin,2)
    num_v=conv(num_v,[-xi(2) 1]);
  endif
  for k=1:nall,
    num_v=conv(num_v,[-Gamma(k) 1]);
    if mpa==2
      num_v=conv(num_v,[-Gamma(k) 1]);
    endif
  endfor 
  % Denominator of F
  den_v=1;
  for k=1:floor(nmin/2),
    den_v=conv(den_v,[1 -R(k)]);
  endfor
  den_v=conv(den_v,den_v);
  if mod(nmin,2),
    den_v=conv(den_v,[1 -xi(2)]);
  endif
  for k=1:nall,
    den_v=conv(den_v,[1 -Gamma(k)]);
    if mpa==2
      den_v=conv(den_v,[1 -Gamma(k)]);
    endif
  endfor
  % Find beta
  den_v=den_v*m1n*(((2-Deltap)/Deltap)+sqrt((((2-Deltap)/Deltap)^2)-1));
  beta=roots(den_v+num_v);
  
  % Convert v-plane beta to z-plane pole locations
  z1z=((beta+(1./beta))-D)/C;
  min_p=(z1z-sqrt((z1z.^2)-4))/2;
  
  % Find scale factor of combined filter at fp
  ejwp=e^(j*wp);
  h=prod(1-(min_z/ejwp))*prod(1-(1./(ejwp*allpass_p)))/prod(1-(min_p/ejwp));
  K=((-1)^nall)*sqrt((1-Deltap)/(abs(h)^2));

endfunction
