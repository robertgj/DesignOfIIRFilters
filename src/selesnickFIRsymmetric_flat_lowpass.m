function [hA,hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_flat_lowpass(N,L,deltas,fs,nf,max_iter,tol)
% [hA,hM,fext,fiter,feasible]= ...
%   selesnickFIRsymmetric_flat_lowpass(N,L,deltas,fs,nf,max_iter,tol)
% Implement the Selesnick-Burrus maximally-flat lowpass filter design algorithm
% for specified deltas and initial fs.
%
% Inputs:
%   N - filter length, odd so filter order is even
%   L - order of maximally-flat-ness, even
%   deltas - desired stop-band amplitude ripple
%   fs - initial stop-band edge
%   nf - number of interpolation frequency points used to evaluate error
%   max_iter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hA - (N+1)/2 distinct coefficients of H [hA(1),...,hA((N+1)/2)]
%   hM - M+1 distinct coefficients of H2 [hM(1),...,hM(M+1)], where M=(N-1-L)/2
%   fext - extremal frequencies
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints
%
% See: Section II.B of "Exchange Algorithms for the Design of Linear Phase
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

  if (nargin < 3) || (nargin > 7) || (nargout>5)
    print_usage ...
("hA=selesnickFIRsymmetric_flat_lowpass(N,L,deltas)\n\
[hA,hM,fext,fiter,feasible]= ...\n\
  selesnickFIRsymmetric_flat_lowpass(N,L,deltas,fs,nf,max_iter,tol)");
  endif

  % Sanity checks
  if nargin<7
    tol=1e-8;
  endif
  if nargin<6
    max_iter=100;
  endif
  if nargin<5
    nf=100*N;
  endif
  if nargin<4
    fs=0.1;
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
  if mod(L,2)~=0
    error("mod(L,2)~=0");
  endif
  if ~isscalar(deltas)
    error("~isscalar(deltas)");
  endif
  if deltas<=0
    error("deltas<=0");
  endif
  if deltas>=1
    error("deltas>=1");
  endif
  if ~isscalar(fs)
    error("~isscalar(fs)");
  endif
  if fs<0
    error("fs<0");
  endif
  if fs>0.5
    error("fs>0.5");
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
  m1=(-1).^((1:(M+1))');
  m1L2=(-1)^(L/2);
  
  % Initial mini-max frequency-amplitude pairs
  fM=linspace(fs,0.5,M+1)(:);
  xM=cos(2*pi*fM);
  wM=m1L2*(sin(acos(xM)/2).^L);
  aM=((deltas*m1)-1)./wM;
  % Convert the initial mini-max frequencies to the cos(omega) domain
  % Fixed interpolation frequencies in the cos(omega) domain
  fi=linspace(0,0.5,nf)(:);
  xi=cos(2*pi*fi);
  wi=m1L2*(sin(acos(xi)/2).^L);
  
  % Loop
  lastxM=zeros(size(xM));
  for fiter=1:max_iter

    % Lagrange interpolation
    ai=lagrange_interp(xM,aM,[],xi,tol,allow_extrap);

    % Filter amplitude
    A=1+(ai.*wi);
    
    % Select frequencies of extremal values of A
    maxA=local_max(A);
    minA=local_max(-A);
    eindex=unique([maxA(:);minA(:);nf]);

    % Crude filter of numerical errors near x=1
    eindex(find(abs(1-A(eindex))<tol))=[];
    
    % Prune eindex
    if eindex(1)==1
      eindex(1)=[];
    endif
    if length(eindex)==(M+2) && eindex(end)==nf
      eindex(end)=[];
    endif
    if length(eindex)~=(M+1)
      error("fiter=%d,length(eindex)(%d)~=(M+1)(%d)",
            fiter,length(eindex),M+1);
    endif
    xM=xi(eindex);

    % Set new amplitudes
    wM=m1L2*(sin(acos(xM)/2).^L);
    aM=((deltas*m1)-1)./wM;

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
  for k=1:L,
    hL=conv(hL,[1;-1]/2);
  endfor
  hA=[zeros((N-1)/2,1);1;zeros((N-1)/2,1)]+conv(hL,[hM;hM((end-1):-1:1)]);
  hA=hA(1:((N+1)/2));
  
endfunction
