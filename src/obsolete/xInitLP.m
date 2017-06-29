function [x0,U,V,M,Q]=xInitLP(makeOdd,Q0,R,fap,dbap,dbas,tol)
%% function [x0,U,V,M,Q]=xInitLP(makeOdd,Q0,R,fap,dbap,dbas,tol)
%% Create an initial guess for the low-pass filter definition.
%% Inputs:
%%  makeOdd - boolean, make odd order polynomials
%%  Q0 - number of poles (Q0/2 conjugate pairs)
%%  R - poles are for z^R (R is decimation factor)
%%  fap - low-pass band edge (1 corresponds to sampling rate)
%%  dbap - pass-band ripple in dB
%%  dbas - stop-band attenutation in dB
%%  tol - a small number
%% Outputs:
%%  x0 - output coefficients
%%  U - number of real zeros
%%  V - number of real poles
%%  M - number of conjugate zeros
%%  Q - number of conjugate poles
%% The poles and zeros are listed as:
%%  [K,R0(1:U),Rp(1:V),abs(z(1:Mon2)),angle(z(1:Mon2)), ...
%%                     abs(p(1:Qon2)),angle(p(1:Qon2))]';

  %% Sanity checks
  if nargin<6 || nargout<5
    usage("[x0,U,V,M,Q]=xInitLP(makeOdd,Q0,R,fap,dbap,dbas,tol)");
  endif
  if nargin==6
    tol=1e-3;
  endif
  Q=Q0;
  if rem(Q,2)==1
    error("Expect Q even!");
  endif
  if R*fap>=0.5
    error("Expect R*fap<0.5!");
  endif

  %% Start with an elliptic approximation
  [b,a]=ellip(Q,dbap,dbas,fap*R*2);

  %% Zeros
  if R>1
   %% Prefilter
    xP=R-1;
    bZ=sinc(fap*(-xP:xP))'.*hamming(2*xP+1);
    bR=[kron(b(1:(length(b)-1)), [1, zeros(1,R-1)]), b(length(b))];
    bR=conv(bR,bZ);
  else
    bR=b;  
  endif
  rbR=roots(bR);
  irbRig0=find(imag(rbR)>tol);
  rbR=rbR(irbRig0);
  rbR=rbR(:);
  if R>1
    rbR=[rbR;0.8*exp(1.9*pi*i/R)];
  endif
  M=length(rbR)*2;

  %% Poles
  ra=roots(a);
  iraIg0=find(imag(ra)>tol);
  ra=ra(iraIg0);
  ra=ra(:);
  if R>1
    xQ=floor(R/2);
    Q=Q+xQ*2;
    ra=[ra;0.3+0.3*j*ones(xQ,1)];
  endif

  %% Gain 
  %% For odd order
  Rp=0.5;
  Rz=-1;
  if makeOdd
    U=V=1;
    x0=[1;Rz;Rp;abs(rbR);angle(rbR);abs(ra);angle(ra)];
  else
    U=2;
    V=0;
    x0=[1;-0.9;-2;abs(rbR);angle(rbR);abs(ra);angle(ra)];
  endif
  L=512;
  w=2*pi*fap*(0:(L-1))/L;
  A=iirA(w,x0,U,V,M,Q,R);
  A0=max(A);
  x0(1)=1/A0;

endfunction
