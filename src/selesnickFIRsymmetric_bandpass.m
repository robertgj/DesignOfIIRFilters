function [hM,fext,func_iter,feasible]= ...
  selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,at, ...
                                 nf,max_iter,tol)
% [hM,func_iter,feasible]= ...
%   selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,at, ...
%                                  nf,max_iter,tol)
% Implement the Selesnick-Burrus modification to Hofstetter's algorithm for the
% design of a linear-phase FIR filter with given pass-band and upper and lower
% stop-band ripples.
%
% Inputs:
%   M - filter order is 2*M
%   deltasl - desired lower stop-band amplitude response ripple
%   deltap - desired pass-band amplitude response ripple
%   deltasu - desired upper stop-band amplitude response ripple
%   ftl - fixed lower transition band frequency
%   ftu - fixed upper transition band frequency
%   at - desired amplitude response at the transition band frequencies
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
% See: Section II.C of "Exchange Algorithms that Complement the Parks-McClellan
% Algorithm for Linear-Phase FIR Filter Design", Ivan W. Selesnick and
% C. Sidney Burrus, IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND
% DIGITAL SIGNAL PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp. 137-143

% Copyright (C) 2020 Robert G. Jenssen
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

  if (nargin < 7) || (nargin > 10) || (nargout>4)
    print_usage ...
("hM=selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,at)\n\
[hM,fext,func_iter,feasible]= ...\n\
  selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,at, ...\n\
                                 nf,max_iter,tol)");
  endif

  % Sanity checks
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
  if at>=(1+deltap)
    error("atu>=(1+deltap)");
  endif
  if at<=-deltasl
    error("at<=-deltasl)");
  endif
  if at<=-deltasu
    error("at<=-deltasu)");
  endif
  
  % Initialise
  hM=[];
  fext=[];
  func_iter=0;
  feasible=false;
  allow_extrap=true;
  
  % Initial mini-max frequency-amplitude pairs (not including transition points)
  % Lower stop-band frequencies
  nasl=floor((M-2)*ftl/0.5);
  tmpfasl=linspace(0,ftl,nasl+1);
  fasl=tmpfasl(1:(end-1))(:);
  nasl=length(fasl);
  % Pass-band frequencies
  napon2=floor(((M-2)/2)*(ftu-ftl)/0.5);
  tmpfap=linspace(ftl,ftu,(2*napon2)+3);
  fap=tmpfap(2:(end-1))(:);
  nap=length(fap);
  % Upper stop-band frequencies
  nasu=M-2-nasl-nap;
  tmpfasu=linspace(ftu,0.5,nasu+1);
  fasu=tmpfasu(2:end)(:);
  % Frequencies
  f=[fasl;ftl;fap;ftu;fasu];
  % Amplitudes
  a=[flipud((-1).^((1:nasl)'))*deltasl; ...
     at; ...
     1+(((-1).^(1+((1:nap)')))*deltap); ...
     at; ...
     ((-1).^((1:nasu)'))*deltasu];

  % Convert the initial mini-max frequencies to the cos(omega) domain
  wtl=2*pi*ftl;
  xtl=cos(wtl);
  wtu=2*pi*ftu;
  xtu=cos(wtu);
  x=cos(2*pi*f);
  % Fixed interpolation frequencies in the cos(omega) domain
  wi=pi*(0:nf)'/nf;
  xi=cos(wi);
  
  % Loop performing modified Hofstetter's algorithm
  lastx=zeros(size(x));
  for func_iter=1:max_iter

    % Lagrange interpolation
    if 0
      % Add derivative constraint (In fact this is meaningless with
      % Lagrange interpolation of specified extremal amplitudes).
      [ai,w,p]=lagrange_interp(x,a,[],xi,tol,allow_extrap);
      daidwt=polyval(polyder(p),[xtl,xtu]);
      ai=ai+(daidwt(1)/daidwt(2));
    else
      ai=lagrange_interp(x,a,[],xi,tol,allow_extrap);
    endif
      
    % Choose new extremal values
    maxai=local_max(ai);
    minai=local_max(-ai);
    eindex=unique([1;maxai(:);minai(:);nf]);
    slindex=max(find(xi(eindex)>xtl));
    plindex=min(find(xi(eindex)<xtl));
    puindex=max(find(xi(eindex)>xtu));
    suindex=min(find(xi(eindex)<xtu));
    if mod(plindex,2)
      c=1;
    else
      c=0;
    endif
    a=[flipud((-1).^((1:slindex)'))*deltasl; ...
       at; ...
       1+(((-1).^(c+(plindex:puindex)'))*deltap); ...
       at; ...
       ((-1).^((1:length(eindex(suindex:end)))'))*deltasu];
    x=[xi(eindex(1:slindex)); ...
       xtl; ...
       xi(eindex(plindex:puindex)); ...
       xtu; ...
       xi(eindex(suindex:end))];

    % Selesnick-Burrus exchange for band-pass filters
    L=length(eindex);
    if (L==(M-1)) || (L==(M+1))
      [x,a]=selesnickFIRsymmetric_lowpass_exchange ...
              (x,a,ai,eindex,slindex,suindex,deltasl,deltasu);
    endif
    if (L==M) || (L==(M+1))
      d=[zeros(slindex,1);ones(puindex-plindex+1,1);zeros(L-suindex+1,1)];
      delta=[deltasl*ones(slindex,1); ...
             deltap*ones(puindex-plindex+1,1); ...
             deltasu*ones(L-suindex+1,1)];
      if isempty(find(maxai==eindex(1)))
        s=0;
      else
        s=1;
      endif
      E=(ai(eindex)-d)./delta;
      diffE=(-diff(E)).*((-1).^(s+(1:(L-1))'));
      [~,k]=min(diffE);
      if k==1 || k==L
        if k==1
          x=x(2:end);
          a=a(2:end);
        else
          x=x(1:(end-1));
          a=a(1:(end-1));
        endif
        [x,a]=selesnickFIRsymmetric_lowpass_exchange ...
                (x,a,ai,eindex,slindex,suindex,deltasl,deltasu);
      else
        x(k:(k+1))=[];
        a(k:(k+1))=[];
      endif
    endif
    if (L<M-2) || (L>M+1)
      fprintf(stderr,"eindex=[");printf("%d ",eindex(:));printf("]\n");
      fprintf(stderr,"slindex=%d,plindex=%d,puindex=%d,suindex=%d\n",
             slindex,plindex,puindex,suindex);
      error("L=%d,M=%d",L,M);
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
    if (feasible==false) && (func_iter==max_iter)
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
    hM=[a(M+1)/2;flipud(a(1:(M)))];
  endif
  
endfunction
