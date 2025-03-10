function [hM,deltap,deltas,fext,fiter,feasible]= ...
      affineFIRsymmetric_lowpass(M,fp,fs,kappap,etap,kappas,etas,nf,maxiter,tol)
% [hM,deltap,deltas,fext,fiter,feasible]= ...
% affineFIRsymmetric_lowpass(M,fp,fs,kappap,etap,kappas,etas,nf,type,maxiter,tol)
% Implement Selesnick and Burrus' modification to the Parks and McClellan
% algorithm for the design of an even-order, odd-length, symmetric, 
% linear-phase, low-pass FIR filter with:
%       deltap=kappap*delta+etap
%       deltas=kappas*delta+etas
%
% Inputs:
%   M - Filter order is (2*M)
%   fp - pass-band edge frequency in [0,0.5]
%   fs - stop-band edge frequency in [0,0.5]
%   kappap -
%   etap -
%   kappas -
%   etas -
%   nf - number of frequency grid points in [0,0.5]
%   maxiter - maximum number of iterations
%   tol - tolerance on convergence
%
% Outputs:
%   hM - M+1 distinct coefficients [h(1),...,h(M+1)]
%   deltap - pass-band ripple value
%   deltas - stop-band ripple value
%   fext - extremal frequencies
%   fiter - number of iterations
%   feasible - true if the design satisfies the constraints
%
% See:
% [1] "Exchange Algorithms that Complement the Parks-McClellan Algorithm for
% Linear-Phase FIR Filter Design", Ivan W. Selesnick and C. Sidney Burrus,
% IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND DIGITAL SIGNAL
% PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp.137-143

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

  if (nargin < 7) || (nargin > 10) || (nargout>6)
    print_usage(["hM=affineFIRsymmetric(M,fp,fs,kappap,etap,kappas,etas)\n", ...
 "[hM,deltap,deltas,fext,fiter,feasible]= ...\n", ...
 "  affineFIRsymmetric(M,fp,fs,kappap,etap,kappas,etas,nf,maxiter,tol)"]);
  endif

  % Sanity checks
  if nargin<10
    tol=1e-10;
  endif
  if nargin<9
    maxiter=100;
  endif
  if nargin<8
    nf=10*M;
  endif
  if fp<0
    error("fp<0");
  endif
  if fs>=0.5
    error("fs>=0.5");
  endif
  if fp>fs
    error("fp>fs");
  endif
  if kappap<0
    error("kappap<0");
  endif
  if etap<0
    error("etap<0");
  endif
  if kappas<0
    error("kappas<0");
  endif
  if etas<0
    error("etas<0");
  endif
  if kappap+etap<=0
    error("kappap+etap<=0");
  endif
  if kappas+etas<=0
    error("kappas+etas<=0");
  endif
  if kappap+kappas<=0
    error("kappap+kappas<=0");
  endif
  
  % Initialise flags
  hM=[];
  deltap=inf;
  deltas=inf;
  fext=[];
  fiter=0;
  feasible=false;

  % Frequencies for amplitude response
  f=(0:nf)'*0.5/nf;
  w=2*pi*f;
  xM=cos(w.*(0:M));
  
  % Initial guess at extremal frequencies in the pass and stop bands
  np=floor(fp*M/(fp+0.5-fs));
  ns=M-np;
  if np==0
    fk=[fp];
  else
    fk=[(0:(np-1))'*fp/np;fp];
  endif
  if ns==0
    fk=[fk;fs];
  else
    fk=[fk;fs;(fs+((1:ns)'*(0.5-fs)/ns))];
  endif
  wk=2*pi*fk;
  wp=2*pi*fp;
  ws=2*pi*fs;

  % Loop with Selesnick and Burrus affine modification to Parks and McClellan 
  lastdeltawk=zeros(M+4,1);
  for fiter=1:maxiter

    % Calculate deltap, deltas and the coefficients of the cos(omega) polynomial
    np=max(find(wk<wp));
    ns=M-np;
    xkM=cos(wk.*(0:M));
    % See [1] Equation 4
    adelta=[[xkM, ...
             [flipud((-1).^((0:np)'));zeros(ns+1,1)], ...
             [zeros(np+1,1);(-1).^((1:(ns+1))')], ...
             zeros(M+2,1)]; ...
            zeros(2,M+1),eye(2),[-kappap;-kappas]]\ ...
           [ones(np+1,1);zeros(ns+1,1);etap;etas];
    a=adelta(1:(M+1));
    deltap=adelta(M+2);
    deltas=adelta(M+3);
    delta=adelta(M+4);

    % Correct for negative deltap or deltas
    if deltap<0 && deltas<0
      error("deltap<0 && deltas<0");
    elseif deltap<0
      fprintf(stderr,"Found deltap=%g\n",deltap);
      % See [1] Equations 5 and 6
      adelta=[xkM,[flipud((-1).^((0:np)'));zeros(ns+1,1)]] \...
             [ones(np+1,1);zeros(ns+1,1)];
      a=adelta(1:(M+1));
      deltap=adelta(M+2);
      deltas=0;
    elseif deltas<0
      fprintf(stderr,"Found deltas=%g\n",deltas);
      % See [1] Equation 7
      adelta=[xkM,[zeros(np+1,1);(-1).^((1:(ns+1))')]] \...
             [ones(np+1,1);zeros(ns+1,1)];
      a=adelta(1:(M+1));
      deltas=adelta(M+2); 
      deltap=0;
    endif

    % Find new extremal values
    A=xM*a;
    maxA=local_max(A);
    minA=local_max(-A);
    Sk=sort([maxA;minA]);
    wk=frefine(a,w(Sk));
    wk=unique([wk;wp;ws]);
   
    % If there are M+3 alternations then discard wk(1) or wk(end)
    if length(wk)==(M+3)
      if ~isempty(find(maxA==1))
        alpha=1;
      else
        alpha=-1;
      endif
      if ~isempty(find(maxA==length(A)))
        beta=1;
      else
        beta=-1;
      endif
      if (((A(1)-1)*alpha)-deltap) < ((A(end)*beta)-deltas)
        wk=wk(2:end);
      else
        wk=wk(1:(end-1));
      endif
    endif
    if length(wk)~=(M+2)
      error("length(wk)~=(M+2)")
    endif

    % Test convergence
    deltawk=[deltap;deltas;wk];
    deldeltawk=norm(deltawk-lastdeltawk);
    lastdeltawk=deltawk;
    if deldeltawk<tol
      hM=[a(end:-1:2)/2;a(1)];
      fext=wk/(2*pi);
      feasible=true;
      printf("Converged : fiter=%d, deltap=%g, deltas=%g, deldeltawk=%g\n", ...
             fiter,deltap,deltas,deldeltawk);
      break;
    endif
    if fiter==maxiter,
      error("No convergence after %d iterations",maxiter);
    endif
  endfor

endfunction
