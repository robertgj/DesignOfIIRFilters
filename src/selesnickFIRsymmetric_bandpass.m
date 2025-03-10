function [hM,fext,fiter,feasible]= ...
         selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,At, ...
                                        nf,max_iter,tol,verbose)
% [hM,fext,fiter,feasible]= ...
%   selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,At, ...
%                                  nf,max_iter,tol,verbose)
% Implement the Selesnick-Burrus modification to Hofstetter's algorithm for the
% design of an even-order, odd-length, linear-phase FIR filter with given
% pass-band and upper and lower stop-band ripples. The transition frequency
% derivative constraint of Selesnick and Burrus is meaningless with Lagrange
% interpolation of specified extremal amplitudes. This means that the Selesnick
% -Burrus exchange algorithm is modified to allow for M-1 extremal frequencies
% plus the two transition frequencies. The frequencies x=cos(2*pi*f) are assumed
% to be ordered 0<=f<=0.5 and 1>=x>=-1. 
%
% Inputs:
%   M - filter order is (2*M), filter length is (2*M)+1
%   deltasl - desired lower stop-band amplitude response ripple
%   deltap - desired pass-band amplitude response ripple
%   deltasu - desired upper stop-band amplitude response ripple
%   ftl - fixed lower transition band frequency
%   ftu - fixed upper transition band frequency
%   At - desired amplitude response at the transition band frequencies
%   nf - number of interpolation frequency points used to evaluate error
%   max_iter - maximum number of iterations
%   tol - tolerance on convergence
%   verbose - show intermediate results
%
% Outputs:
%   hM - M+1 distinct coefficients
%   fext - extremal frequencies
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints
%
% See: Section II.C of "Exchange Algorithms that Complement the Parks-McClellan
% Algorithm for Linear-Phase FIR Filter Design", Ivan W. Selesnick and
% C. Sidney Burrus, IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND
% DIGITAL SIGNAL PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp. 137-143

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

  if (nargin < 7) || (nargin > 11) || (nargout>4)
print_usage(["[hM,fext,fiter,feasible]=selesnickFIRsymmetric_bandpass ...\n", ...
 "(M,deltasl,deltap,deltasu,ftl,ftu,At,nf,max_iter,tol,verbose)"]);
  endif

  % Sanity checks
  if nargin<11
    verbose=false;
  endif 
  if nargin<10
    tol=1e-8;
  endif
  if nargin<9
    max_iter=100;
  endif
  if nargin<8
    nf=100*M;
  endif
  if ~isscalar(M)
    error("~isscalar(M)");
  endif
  if ~isscalar(deltasl)
    error("~isscalar(deltasl)");
  endif
  if ~isscalar(deltap)
    error("~isscalar(deltap)");
  endif
  if ~isscalar(deltasu)
    error("~isscalar(deltasu)");
  endif
  if ~isscalar(ftl)
    error("~isscalar(ftl)");
  endif
  if ~isscalar(ftu)
    error("~isscalar(ftu)");
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
  if deltasl<=0
    error("deltasl<0");
  endif
  if deltasl>=1
    error("deltasl>=1");
  endif
  if deltap<=0
    error("deltap<0");
  endif
  if deltap>=1
    error("deltap>=1");
  endif
  if deltasu<=0
    error("deltasu<0");
  endif
  if deltasu>=1
    error("deltasu>=1");
  endif
  if ftl<0
    error("ftl<0");
  endif
  if ftl>0.5
    error("ftl>0.5");
  endif
  if ftu<0
    error("ftu<0");
  endif
  if ftu>0.5
    error("ftu>0.5");
  endif
  if ftl>=ftu
    error("ftl>=ftu");
  endif
  if At>=(1+deltap)
    error("At>=(1+deltap)");
  endif
  if At<=-deltasl
    error("At<=-deltasl)");
  endif
  if At<=-deltasu
    error("At<=-deltasu)");
  endif

  %
  % Initialise
  %
  hM=[];
  fext=[];
  fiter=0;
  feasible=false;
  allow_extrap=true;
  
  % Fixed interpolation frequencies
  fi=0.5*(0:nf)'/nf;
  xi=cos(2*pi*fi);

  % M initial frequency-amplitude pairs
  % Lower stop-band frequencies
  nasl=ceil((M-1)*ftl/0.5);
  tmpfasl=linspace(0,ftl,nasl+1);
  fasl=tmpfasl(1:(end-1));
  nasl=length(fasl);
  % Odd number of pass-band frequencies
  napon2=floor(((M-1)/2)*(ftu-ftl)/0.5);
  tmpfap=linspace(ftl,ftu,(2*napon2)+3);
  fap=tmpfap(2:(end-1));
  nap=length(fap);
  % Upper stop-band frequencies
  nasu=M-1-nasl-nap;
  tmpfasu=linspace(ftu,0.5,nasu+1);
  fasu=tmpfasu(2:end);
  f=unique([fasl,ftl,fap,ftu,fasu]');
  if length(f)~=M+1
    error("length(f)(%d)~=M+1",length(f));
  endif
  % M+1 initial amplitudes
  A=[fliplr((-1).^(1:nasl))*deltasl, ...
     At, ...
     1+(((-1).^(1+(1:nap)))*deltap), ...
     At, ...
     ((-1).^(1:nasu))*deltasu]';

  % Frequencies
  w=2*pi*f;
  x=cos(w);
  wtl=2*pi*ftl;
  xtl=cos(wtl);
  wtu=2*pi*ftu;
  xtu=cos(wtu);

  %
  % Loop performing modified Hofstetter's algorithm
  %
  lastx=zeros(size(x));
  for fiter=1:max_iter,

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
    if ~isempty(find(fext==ftl))
      error("ftl should not be an extrema!");
    endif
    if ~isempty(find(fext==ftu))
      error("ftu should not be an extrema!");
    endif
    if length(fext)~=(length(max_fi)+length(min_fi))
      error("length(fext)~=(length(max_fi)+length(min_fi))");
    endif
    if length(fext)>=(M+2)
      error("length(fext)(%d)>=(M+2)",length(fext));
    endif
    if length(fext)<(M-1)
      error("length(fext)(%d)<(M-1)",length(fext));
    endif
    if verbose
      plot(fi,Ai,max_fi,max_Ai,"o",min_fi,min_Ai,"+",[ftl,ftu],[At,At],"x");
    endif
    
    %
    % Selesnick-Burrus exchange for band-pass filters results in M-1 extrema
    %
    
    % Find indexes either side of xtl and xtu
    slindex=max(find(xext>xtl));
    plindex=min(find(xext<xtl));
    if (slindex+1)~=plindex
      error("(slindex+1)~=plindex");
    endif
    puindex=max(find(xext>xtu));
    suindex=min(find(xext<xtu));
    if (puindex+1)~=suindex
      error("(puindex+1)~=suindex");
    endif

    % Insert xtl,At and xtu,At
    A=[fliplr((-1).^(1:slindex))*deltasl, ...
       At, ...
       1+(((-1).^(0:(puindex-plindex)))*deltap), ...
       At, ...
       ((-1).^(1:length(xext(suindex:end))))*deltasu]';
    x=[xext(1:slindex); ...
       xtl; ...
       xext(plindex:puindex); ...
       xtu; ...
       xext(suindex:end)];
    
    %
    % Selesnick-Burrus exchange for band-pass filters results in M-1 extrema
    %

    % Remove one extremal frequency
    L=length(xext);
    if verbose
      printf("fiter=%d,L=%d,M=%d,exchange\n",fiter,L,M);
    endif
    if (L==M)
      if verbose
        printf("Removing one extremal at f=0 or f=0.5\n");
      endif
      [x,A]=selesnickFIRsymmetric_bandpass_exchange ...
              (x,A,xext,Aext,xtl,xtu,deltasl,deltasu,verbose);
    endif

    % Remove two extremal frequencies
    if (L==M+1)
      if verbose
        printf("Removing two extremals at f=0 or f=0.5 or elsewhere\n");
      endif
      % Calculate error
      d=[zeros(slindex,1); ...
         ones(puindex-plindex+1,1); ...
         zeros(length(Aext)-suindex+1,1)];
      delta=[deltasl*ones(slindex,1); ...
             deltap*ones(puindex-plindex+1,1); ...
             deltasu*ones(length(Aext)-suindex+1,1)];
      % Check if first extremal is a maximum
      if fext(ifi(1))==max_fi(1)
        s=1;
      else
        s=0;
      endif
      E=(Aext-d)./delta;
      % Find minimum error
      diffE=(-diff(E)).*((-1).^(s+(1:(L-1))'));
      [~,k]=min(diffE);
      % Exchange removes two minimum error extremals
      if k==1 || k==L
        if k==1
          if verbose
            printf("k=%d,removing f(1)=%g,A=%g\n",k,acos(x(1))*0.5/pi,A(1));
          endif
          x=x(2:end);
          A=A(2:end);
        else
          if verbose
            printf("k=%d,removing f(end)=%g,A=%g\n", ...
                   k,acos(x(end))*0.5/pi,A(end));
          endif
          x=x(1:(end-1));
          A=A(1:(end-1));
        endif
        if verbose
          printf("k=%d,removing extremal at f=0 or f=0.5\n",k);
        endif
        [x,A]=selesnickFIRsymmetric_bandpass_exchange ...
                (x,A,xext,Aext,xtl,xtu,deltasl,deltasu,verbose);
      else
        if verbose
          printf("Removing f(%d)=%g,A=%g and f(%d)=%g,A=%g\n", ...
                 k,acos(x(k))*0.5/pi,A(k),k+1,acos(x(k+1))*0.5/pi,A(k+1));
        endif
        x(k:(k+1))=[];
        A(k:(k+1))=[];
      endif
    endif
    if length(x)~=(M+1)
      error("After exchange length(x)(%d)~=(M+1)",length(x));
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
      printf("Converged : delx=%g after %d iterations\n",delx,fiter);
      break;
    endif
    if (feasible==false) && (fiter==max_iter)
      warning("No convergence after %d iterations",max_iter);
    endif
    
  endfor

endfunction

function [x,A]=selesnickFIRsymmetric_bandpass_exchange ...
                 (x,A,xext,Aext,xtl,xtu,deltasl,deltasu,verbose)
  if nargin~=9 || nargout~=2
    print_usage(["[x,A]=selesnickFIRsymmetric_bandpass_exchange ...\n", ...
 "  (x,A,xext,Aext,xtl,xtu,deltasl,deltasu,verbose)"]);
  endif
  if x(1)==1 && all(xtl>xext(2:end))
    if verbose
      printf("No extrema 0<f<ftl,removing extremal f=0\n");
    endif
    x=x(2:end);
    A=A(2:end);
  elseif x(end)==-1 && all(xext(1:(end-1))>xtu)
    if verbose
      printf("No extrema ft<f<0.5,removing extremal f=0.5\n");
    endif
    x=x(1:(end-1));
    A=A(1:(end-1));
  else
    if (abs(Aext(1)-Aext(2))*deltasu) < (abs(Aext(end)-Aext(end-1))*deltasl)
      if verbose
        printf("Removing extremal f=0\n");
      endif
      x=x(2:end);
      A=A(2:end);
    else
      if verbose
        printf("Removing extremal f=0.5\n");
      endif
      x=x(1:(end-1));
      A=A(1:(end-1));
    endif
  endif
endfunction
    
