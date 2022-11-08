function [hA,hAM,dk,err,fext,fiter,feasible]= ...
  mcclellanFIRantisymmetric_linear_differentiator(N,L,deltas,nf,maxiter,tol)
% [hA,hAM,dk,err,fext,fiter,feasible]= ...
%   mcclellanFIRantisymmetric_linear_differentiator(N,L,deltas,maxiter,tol)
% Implement Selesnick and Burrus' modification to the Parks and McClellan
% algorithm for the design of an even- or odd-order, odd- or even-length,
% anti-symmetric, linear-phase, low-pass, maximally-linear FIR differentiator
% filters. My attempts to use Lagrange interpolation to calculate AM failed.
%
% Inputs:
%   N - Filter order
%   L - Degree of linearity
%   deltas - stop-band ripple
%   nf - number of frequency grid points in [0,0.5]
%   maxiter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hA - coefficients of the anti-symmetric FIR differentiator filter
%   hAM - coefficients of the stop-band FIR filter
%   dk - factors of 1-cos(omega) in the maximally linear pass-band
%   err - maximum stop-band error compared to deltas
%   fext - extremal frequencies in the stop-band
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints
%
% This function closely follows the chebdiff.m MATLAB function of Selesnick
% for even length filters and adds the case of odd length filters. See
% Section IV of "Exchange Algorithms for the Design of Linear Phase
% FIR Filters and Differentiators Having Flat Monotonic Passbands and
% Equiripple Stopband", Ivan W. Selesnick and C. Sidney Burrus, IEEE
% TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND DIGITAL SIGNAL
% PROCESSING, VOL. 43, NO. 9, SEPTEMBER 1996, pp. 671-675

% Copyright (C) 2020-2022 Robert G. Jenssen
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

  if (nargin < 3) || (nargin > 6) || (nargout>7)
    print_usage("hA=mcclellanFIRsymmetric_linear_differentiator(N,L,deltas)\n\
[hA,hAM,dk,err,fext,fiter,feasible]= ...\n\
  mcclellanFIRsymmetric_linear_differentiator(N,L,deltas,nf,maxiter,tol)");
  endif

  % Sanity checks
  if nargin<6
    tol=1e-8;
  endif
  if nargin<5
    maxiter=100;
  endif
  if nargin<4
    nf=100*N;
  endif
  if N<=L
    error("N<=L");
  endif
  if mod(L,2)~=0
    error("Expect L even!");
  endif
  if deltas<=0
    error("deltas<=0");
  endif
  if deltas>=1
    error("deltas>=1");
  endif
  
  % Initialise outputs
  hA=[];
  hAM=[];
  dk=[];
  err=inf;
  fext=[];
  fiter=0;
  feasible=false;
  
  % Construct the monotonic pass-band weighting function
  L2m1=(L/2)-1;
  fas=0.5*L/N;
  Cz=[-1;2;-1]/2;
  F=((1:nf)'/nf)/2; 
  if mod(N,2)
    % N odd length
    M=(N-L-1)/2;
    % fk are the initial stop-band extremal frequencies excluding 0.5
    nas=floor(nf*L/(L+(2*(M-1))))+1;
    fk=nas+round((0:(M-1))'*(nf-nas)/M);
    S=sin(2*pi*F);
    Sz=[-1;0;1]/2;
    dk=[1,cumprod(1:L2m1)./cumprod((2*(1:L2m1))+1)]';
  else
    % N even length
    M=(N-L)/2;
    % fk are the initial stop-band extremal frequencies including 0.5
    nas=floor(nf*L/(L+(2*(M-1))))+1;
    fk=nas+round((0:(M-1))'*(nf-nas)/(M-1));
    S=sin(pi*F);
    Sz=[-1;1]/2;
    dk=[2,cumprod((1:2:((2*L2m1)-1))./(4*(1:L2m1))).*(2./(3:2:((2*L2m1)+1)))]';
  endif
  cosFM=cos(2*pi*F.*(0:(M-1)));
  Ck=(1-cos(2*pi*F)).^(1:L2m1);
  CL2=(1-cos(2*pi*F)).^(L/2);
  sumdkCk=dk(1)+(sum(kron(ones(size(F)),dk(2:end)').*Ck,2));

  % Stop-band extremal amplitudes
  Ad=deltas*((-1).^((1:M)'));

  % Options to select matrix left-division or Lagrange interpolation
  opt_left_division=true;
  if opt_left_division==false
    opt_allow_extrap=true;
    fprintf(stderr,"Using Lagrange interpolation!\n");
  endif
  
  % Loop performing Remez exchange algorithm with stop-band extrema
  for fiter=1:maxiter

    % Desired hM filter amplitude response
    AMd=[[(Ad./S(fk))-sumdkCk(fk)]./CL2(fk)];

    % Find hM filter response
    if opt_left_division
      % Solve for the aM stop-band filter coefficients
      aM=cosFM(fk,:)\AMd;
      AM=cosFM*aM;
    else
      % Barycentric Lagrange interpolation
      AM=lagrange_interp(cosFM(fk,2),AMd,[],cosFM(:,2),tol,opt_allow_extrap);
    endif
    
    % Calculate the over-all differentiator filter response
    A=S.*(sumdkCk+(AM.*CL2));

    % Find M stop-band extremal points (exclude 0.5 if N odd)
    Amax=local_max(A);
    Amin=local_max(-A);
    fk=unique([Amax;Amin]);
    if mod(N,2)
      fk=fk((length(fk)-M):(length(fk)-1));
    else
      fk=fk((length(fk)-M+1):length(fk));
    endif
    if length(fk)~=M
      error("length(fk)~=M");
    endif

    % Check for convergence
    err=abs(max(abs(A(fk)))-deltas);
    if err<tol
      fext=F(fk);
      feasible=true;
      fprintf(stderr,"Converged after %d iterations : err=%g\n",fiter,err);
      break;
    endif
    if fiter==maxiter
      warning("Failed to converge after %d iterations: err=%g",fiter,err);
    endif

  endfor

  % Construct the AM filter impulse response
  if opt_left_division
    hAM=[aM(M:-1:2)/2;aM(1);aM(2:M)/2];
  else
    hAM=xfr2tf(M-1,cosFM(fk,2),AM(fk),tol);
    hAM=[hAM;hAM((M-1):-1:1)];
  endif

  % Construct the overall filter impulse response
  hA=hAM;
  for k=(L/2):-1:1,
    hA=conv(hA,Cz);
    hA((length(hA)+1)/2)=hA((length(hA)+1)/2)+dk(k);
  endfor
  hA=conv(hA,Sz);

endfunction
