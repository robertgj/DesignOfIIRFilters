function [hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At,nf,max_iter,tol,verbose)
% [hM,fext,fiter,feasible]= ...
%  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At,nf,max_iter,tol,verbose)
% Implement the Selesnick-Burrus modification to Hofstetter's algorithm for the
% design of a linear-phase FIR filter with given pass-band and stop-band ripples.
%
% Inputs:
%   M - filter order is 2*M
%   deltap - desired pass-band amplitude response ripple
%   deltas - desired stop-band amplitude response ripple
%   ft - fixed transition band frequencies in [0,0.5]
%   At - desired amplitude response at ft
%   nf - number of interpolation frequency points used to evaluate error
%   max_iter - maximum number of iterations
%   tol - tolerance on convergence
%   verbose - show intermediate results
%
% Outputs:
%   hM - M+1 distinct coefficients [h(1),...,h(M+1)]
%   fext - extremal frequencies
%   fiter - number of iterations
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

  if (nargin < 5) || (nargin > 9) || (nargout>4)
    print_usage ...
      ("hM=selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At)\n\
hM=selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At,nf)\n\
[hM,fext,fiter,feasible]= ...\n\
selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At,nf,max_iter,tol,verbose)");
  endif

  %
  % Sanity checks
  %
  if nargin<9
    verbose=false;
  endif
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
  if ~isscalar(At)
    error("~isscalar(At)");
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
  if At>=(1+deltap)
    error("At>=(1+deltap)");
  endif
  if At<=-deltas
    error("At<=-deltas");
  endif

  %
  % Initialise
  %
  hM=[];
  fext=[];
  fiter=0;
  feasible=false;
  allow_extrap=true;
  
  % Fixed interpolation frequencies in the cos(omega) domain
  fi=0.5*(0:nf)'/nf;
  wi=2*pi*fi;
  xi=cos(wi);
  
  % Initial mini-max frequency-amplitude pairs, (x,A). Ensure ft is unique.
  np=floor(M*ft/0.5);
  if np<2
    warning("np<2, setting np=2");
    np=2;
  endif
  if np>=(M-1)
    warning("np>=(M-1)");
    return;
  endif
  del=0.5/(4*M);
  f=unique([linspace(0,ft-del,np),ft,linspace(ft+del,0.5,M-np)]');
  if length(f)~=(M+1)
    error("Initial length(f)(%d)~=(M+1)",length(f));
  endif
  % M+1 initial amplitudes
  A=[(1+fliplr(((-1).^(1:np))*deltap)), ...
     At, ...
     (((-1).^(1:(M-np)))*deltas)]';
  if length(A)~=(M+1)
    error("Initial length(A)(%d)~=(M+1)",length(f));
  endif

  % Frequencies
  w=2*pi*f;
  x=cos(w);
  wt=2*pi*ft;
  xt=cos(wt);

  %
  % Loop performing modified Hofstetter's algorithm
  %
  lastx=zeros(size(x));
  for fiter=1:max_iter

    % Lagrange interpolation
    Ai=lagrange_interp(x,A,[],xi,tol,allow_extrap);

    %
    % Choose new extremal values (maintaining frequency order when sorting)
    %
    [max_fi,max_Ai]=local_peak(fi,Ai);
    [min_fi,min_Ai]=local_peak(fi,-Ai);
    min_Ai=-min_Ai;
    fext=[max_fi;min_fi];
    [fext,ifi]=unique(fext);
    xext=cos(2*pi*fext);
    Aext=[max_Ai;min_Ai];
    Aext=Aext(ifi);

    % Sanity checks
    if fext(1)~=0.0
      error("0.0 should be an extrema!");
    endif
    if fext(end)~=0.5
      error("0.5 should be an extrema!");
    endif
    if ~isempty(find(fext==ft))
      error("ft should not be an extrema!");
    endif
    if length(fext)~=(length(max_fi)+length(min_fi))
      error("length(fext)~=(length(max_fi)+length(min_fi))");
    endif
    if verbose
      plot(fi,Ai,max_fi,max_Ai,"o",min_fi,min_Ai,"+",ft,At,"x");
    endif
    
    %
    % Selesnick-Burrus exchange for low-pass filters results in M extrema
    %
    
    % Insert xt,At to create reference set S, (x,A)
    pindex=max(find(xext>xt));
    sindex=min(find(xext<xt));
    if (pindex+1)~=sindex
      error("(pindex+1)~=sindex");
    endif
    x=[xext(1:pindex);xt;xext(sindex:end)];
    A=[(1+fliplr(((-1).^(0:(pindex-1)))*deltap)), ...
       At, ...
       (((-1).^(1:(length(xext(sindex:end)))))*deltas)]';
    
    % Exchange 
    L=length(Aext);
    if L==M
    elseif L==(M+1)
      if all(xt>xext(2:end))
        if verbose
          printf("L=%d,M=%d,no extrema 0<f<ft,removing extremal f=0\n",L,M);
        endif
        x=x(2:end);
        A=A(2:end);
      elseif all(xext(1:(end-1))>xt)
        if verbose
          printf("L=%d,M=%d,no extrema ft<f<0.5,removing extremal f=0.5\n",L,M);
        endif
        x=x(1:(end-1));
        A=A(1:(end-1));
      else
        if (abs(Aext(1)-Aext(2))*deltas) < (abs(Aext(end)-Aext(end-1))*deltap)
          if verbose
            printf("L=%d,M=%d,removing extremal f=0\n",L,M);
          endif
          x=x(2:end);
          A=A(2:end);
        else
          if verbose
            printf("L=%d,M=%d,removing extremal f=0.5\n",L,M);
          endif
          x=x(1:(end-1));
          A=A(1:(end-1));
        endif
      endif
    else
      error("L=%d,M=%d,pindex=%d,sindex=%d",L,M,pindex,sindex);
    endif

    %
    % Test convergence
    %
    delx=norm(x-lastx);
    lastx=x;
    if delx<tol
      hM=xfr2tf(M,x,A,tol);
      fext=acos(x)/(2*pi);
      feasible=true;
      if verbose
        printf("Converged : delx=%g after %d iterations\n",delx,fiter);
      endif
      break;
    endif
    if (feasible==false) && (fiter==max_iter),
      warning("No convergence after %d iterations",max_iter);
    endif
    
  endfor
  
endfunction
