function [hA,hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_flat_bandpass(N,L,deltasl,deltasu,fp,ft,nf,max_iter,tol)
% [hA,hM,fext,fiter,feasible]= ...
% selesnickFIRsymmetric_flat_bandpass(N,L,deltasl,deltasu,fp,ft,nf,max_iter,tol)
% Implement the Selesnick-Burrus maximally-flat band-pass filter design algorithm
% for specified deltasl, deltasu, fp and ft
%
% Inputs:
%   N - filter length, odd so filter order is even
%   L - order of maximally-flat-ness, a multiple of 4
%   deltasl - desired lower stop-band amplitude peak ripple
%   deltasu - desired upper stop-band amplitude peak ripple
%   fp - pass-band centre frequency
%   ft - initial pass-band half-width
%   nf - number of interpolation frequency points used to evaluate error
%   max_iter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hA - (N+1)/2 distinct coefficients of H [hA(1),...,hA((N+1)/2)]
%   hM - M+1 distinct coefficients of HM [hM(1),...,hM(M+1)], where M=(N-1-L)/2
%   fext - extremal frequencies
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints
%
% See: Section III of "Exchange Algorithms for the Design of Linear Phase
% FIR Filters and Differentiators Having Flat Monotonic Passbands and
% Equiripple Stopband", Ivan W. Selesnick and C. Sidney Burrus, IEEE
% TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND
% DIGITAL SIGNAL PROCESSING, VOL. 43, NO. 9, SEPTEMBER 1996, pp. 671-675

% Copyright (C) 2020-2025 Robert G. Jenssen
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

  if (nargin < 6) || (nargin > 9) || (nargout>5)
    print_usage ...
("hA=selesnickFIRsymmetric_flat_bandpass(N,L,deltasl,deltasu,fp,ft)\n\
[hA,hM,fext,fiter,feasible]= ...\n\
selesnickFIRsymmetric_flat_bandpass(N,L,deltasl,deltasu,fp,ft,nf,max_iter,tol)");
  endif

  % Sanity checks
  if nargin<9
    tol=1e-8;
  endif
  if nargin<8
    max_iter=100;
  endif
  if nargin<7
    nf=100*N;
  endif
  if ~isscalar(N)
    error("~isscalar(N)");
  endif
  if mod(N,2)~=1
    error("mod(N,2)~=1");
  endif
  if ~isscalar(L)
    error("~isscalar(L)");
  endif
  if mod(L,4)~=0
    error("mod(L,4)~=0");
  endif
  if ~isscalar(deltasl)
    error("~isscalar(deltasl)");
  endif
  if deltasl<=0
    error("deltasl<=0");
  endif
  if deltasl>=1
    error("deltasl>=1");
  endif 
  if ~isscalar(deltasu)
    error("~isscalar(deltasu)");
  endif
  if deltasu<=0
    error("deltasu<=0");
  endif
  if deltasu>=1
    error("deltasu>=1");
  endif
  if ~isscalar(fp)
    error("~isscalar(fp)");
  endif
  if fp<0
    error("fp<0");
  endif
  if fp>0.5
    error("fp>0.5");
  endif
  if ~isscalar(ft)
    error("~isscalar(ft)");
  endif
  if fp-ft<0
    error("fp-ft<0");
  endif
  if fp+ft>0.5
    error("fp+ft>0.5");
  endif
  if ~isscalar(nf)
    error("~isscalar(nf)");
  endif
  if ~isscalar(max_iter)
    error("~isscalar(max_iter)");
  endif
  if ~isscalar(tol)
    error("~isscalar(tol)");
  endif
  
  % Initialise
  M=(N-L-1)/2;
  hA=[];
  hM=[];
  fext=[];
  fiter=0;
  feasible=false;
  allow_extrap=true;
  m1L2=(-1)^(L/2);
  
  % Initial mini-max frequency-amplitude pairs
  nsl=round((M+1)*(fp-ft)/(0.5-(2*ft)));
  if nsl==0
    nsl=1;
  elseif nsl==(M+1)
    nsl=M;
  endif
  nsu=M+1-nsl;
  if nsl==1
    fMl=fp-ft;
  else
    fMl=linspace(0,fp-ft,nsl)(:);
  endif
  if nsu==1
    fMu=fp+ft;
  else
    fMu=linspace(fp+ft,0.5,nsu)(:);
  endif
  fM=[fMl;fMu];
  xM=cos(2*pi*fM);
  xp=cos(2*pi*fp);
  xa=cos(2*pi*(fp-ft));
  xb=cos(2*pi*(fp+ft));
  wM=m1L2*(((xp-xM)/2).^(L/2));
  m1sl=(-1).^((1:nsl)');
  m1su=(-1).^((1:nsu)');
  aM=([flipud(m1sl*deltasl);m1su*deltasu]-1)./wM;
  
  % Fixed interpolation frequencies in the cos(omega) domain
  fi=linspace(0,0.5,nf)(:);
  xi=cos(2*pi*fi);
  wi=m1L2*(((xp-xi)/2).^(L/2));
  
  % Loop
  lastxM=zeros(size(xM));
  for fiter=1:max_iter

    % Lagrange interpolation
    ai=lagrange_interp(xM,aM,[],xi,tol,allow_extrap);

    % Calculate filter amplitude response
    A=1+(ai.*wi);
    
    % Select M+2 frequencies of extremal values of A
    maxA=local_max(A);
    minA=local_max(-A);
    eindex=unique([maxA(:);minA(:)]);

    % Prune eindex
    if length(eindex)==(M+3)
      if abs(A(eindex(end))-A(eindex(end-1))) < abs(A(eindex(1))-A(eindex(2)))
        eindex(end)=[];
      else
        eindex(1)=[];
      endif
    endif
    if length(eindex)~=(M+2)
      error("fiter=%d,length(eindex)(%d)~=(M+2)(%d)", ...
            fiter,length(eindex),M+2);
    endif
    
    % Remove xp
    [~,np]=min(abs(xi(eindex)-xp));
    eindex(np)=[];
    nsl=sum(xi(eindex)>xp);
    nsu=sum(xi(eindex)<xp);
    xM=xi(eindex);
    
    % Set new amplitudes
    wM=m1L2*(((xp-xM)/2).^(L/2));
    m1sl=(-1).^((1:nsl)');
    m1su=(-1).^((1:nsu)');
    aM=([flipud(m1sl*deltasl);m1su*deltasu]-1)./wM;

    % Test convergence
    delxM=norm(xM-lastxM);
    lastxM=xM;
    if delxM<tol
      hM=xfr2tf(M,xM,aM,tol);
      fext=acos(xM)/(2*pi);
      feasible=true;
      printf("Converged : delxM=%g after %d iterations\n",delxM,fiter);
      break;
    endif
    if (feasible==false) && (fiter==max_iter),
      warning("No convergence after %d iterations",max_iter);
    endif
    
  endfor

  % Construct the overall impulse response
  hL=1;
  for k=1:(L/2),
    hL=conv(hL,[1;-2*cos(2*pi*fp);1]/4);
  endfor
  hA=[zeros((N-1)/2,1);1;zeros((N-1)/2,1)]+conv(hL,[hM;hM((end-1):-1:1)]);
  hA=hA(1:((N+1)/2));

endfunction
