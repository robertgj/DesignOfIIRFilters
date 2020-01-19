function [hM,fext,func_iter,feasible]= ...
  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at,nf,max_iter,tol)
% [hM,fext,func_iter,feasible]= ...
%   selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at,nf,max_iter,tol)
% Implement the Selesnick-Burrus modification to Hofstetter's algorithm for the
% design of a linear-phase FIR filter with given pass-band and stop-band ripples.
%
% Inputs:
%   M - filter order is 2*M
%   deltap - desired pass-band amplitude response ripple
%   deltas - desired stop-band amplitude response ripple
%   ft - fixed transition band frequencies in [0,0.5]
%   at - desired amplitude response at ft
%   nf - number of interpolation frequency points used to evaluate error
%   max_iter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hM - M+1 distinct coefficients [h(1),...,h(M+1)]
%   fext - extremal frequencies
%   func_iter - number of iterations
%   feasible - true if the design satisfies the constraints
%
% See: Section II.B of "Exchange Algorithms that Complement the Parks-McClellan
% Algorithm for Linear-Phase FIR Filter Design", Ivan W. Selesnick and
% C. Sidney Burrus, IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND
% DIGITAL SIGNAL PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp. 137-143

% Copyright (C) 2019,2020 Robert G. Jenssen
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

  if (nargin < 5) || (nargin > 8) || (nargout>4)
    print_usage ...
      ("hM=selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at)\n\
hM=selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at,nf)\n\
[hM,fext,func_iter,feasible]= ...\n\
  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at,nf,max_iter,tol)");
  endif

  % Sanity checks
  if nargin<8
    tol=1e-8;
  endif
  if nargin<7
    max_iter=100;
  endif
  if nargin<6
    nf=100*M;
  endif
  if ~isscalar(M)
    error("~isscalar(M)");
  endif
  if ~isscalar(deltap)
    error("~isscalar(deltap)");
  endif
  if ~isscalar(deltas)
    error("~isscalar(deltas)");
  endif
  if ~isscalar(ft)
    error("~isscalar(ft)");
  endif
  if ~isscalar(at)
    error("~isscalar(at)");
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
  if deltap<=0
    error("deltap<=0");
  endif
  if deltap>=1
    error("deltap>=1");
  endif
  if deltas<=0
    error("deltas<=0");
  endif
  if deltas>=1
    error("deltas>=1");
  endif
  if ft<0
    error("ft<0");
  endif
  if ft>0.5
    error("ft>0.5");
  endif
  if at>=(1+deltap)
    error("at>=(1+deltap)");
  endif
  if at<=-deltas
    error("at<=-deltas");
  endif
  
  % Initialise
  hM=[];
  fext=[];
  func_iter=0;
  feasible=false;
  allow_extrap=true;
  
  % Initial mini-max frequency-amplitude pairs
  np=floor(M*ft/0.5)+1;
  ns=M-np;
  if mod(np,2)
    c=1;
  else
    c=0;
  endif
  a=[(1+((((-1).^(c+(1:np))'))*deltap)); ...
     at; ...
     ((-1).^(c+((np+1):M)'))*deltas];
  f=[(0:(np-1))/(2*(M+1)),ft,((np+2):(M+1))/(2*(M+1))]';
  % Convert the initial mini-max frequencies to the cos(omega) domain
  xt=cos(2*pi*ft);
  x=cos(2*pi*f);
  % Fixed interpolation frequencies in the cos(omega) domain
  xi=cos(pi*(0:nf)'/nf);
  
  % Loop performing modified Hofstetter's algorithm
  lastx=zeros(size(x));
  for func_iter=1:max_iter

    % Lagrange interpolation
    ai=lagrange_interp(x,a,[],xi,tol,allow_extrap);
      
    % Choose new extremal values
    maxai=local_max(ai);
    minai=local_max(-ai);
    eindex=unique([maxai(:);minai(:)]);
    
    % Insert xt,at (recall f=0 -> x=1, f=0.5 -> x=-1)
    pindex=max(find(xi(eindex)>xt));
    sindex=min(find(xi(eindex)<xt));
    if mod(pindex,2)
      c=1;
    else
      c=0;
    endif
    a=[(1+(((-1).^(c+(1:pindex)'))*deltap)); ...
       at; ...
       ((-1).^(c+((pindex+1):length(eindex))'))*deltas];
    x=[xi(eindex(1:pindex));xt;xi(eindex((pindex+1):end))];

    % Selesnick-Burrus exchange
    if length(x)==M+1
    elseif length(x)==(M+2)
      [x,a]=selesnickFIRsymmetric_lowpass_exchange ...
              (x,a,ai,eindex,pindex,sindex,deltap,deltas);
    else
      error("length(x)=%d,M=%d,pindex=%d,sindex=%d",length(x),M,pindex,sindex);
    endif

    % Test convergence
    delx=norm(x-lastx);
    lastx=x;
    if delx<tol
      printf("Convergence : delx=%g after %d iterations\n",delx,func_iter);
      fext=acos(x)/(2*pi);
      printf("%d extremal frequencies : ",length(fext));
      printf(" %g",fext(:)');printf("\n");
      feasible=true;
      break;
    endif
    if (feasible==false) && (func_iter==max_iter),
      warning("No convergence after %d iterations",max_iter);
    endif
    
  endfor

  if feasible
    % Find equally spaced samples of the frequency response
    A=lagrange_interp(x,a,[],cos(pi*(0:M)/M),tol,allow_extrap);
    % Find the distinct impulse response coefficients
    a=ifft([A;flipud(A(2:(end-1)))]);
    if norm(imag(a))>tol
      error("norm(imag(a))(%g)>tol",norm(imag(a)));
    endif
    a=real(a(:));
    hM=[a(M+1)/2;flipud(a(1:M))];
  endif
  
endfunction
