function [Azp,gradAzp,diagHessAzp]=...
           johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1)
% [Azp,gradAzp,diagHessAzp]= ...
%   johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1)
% Calculate the zero-phase magnitude response and gradients of a Johansson
% and Saramaki cascaded all-pass filter. The all-pass filters are implemented
% as Schur one-multiplier lattice filters. 
%
% Inputs:
%   wa - column vector of angular frequencies
%   fM - distinct FIR filter coefficients [fM_0, ... fM_M]
%   k0,k1 - one-multiplier allpass section multiplier coefficients
%   epsilon0,epsilon1 - one-multiplier allpass section signs (+1 or -1)
%
% Outputs:
%   Azp - the zero-phase magnitude response at wa
%   gradAzp - the gradients of Azp with respect to fM, k0 and k1
%   diagHessAzp - diagonal of the Hessian of Azp with respect to fM, k0 and k1

% Copyright (C) 2019-2025 Robert G. Jenssen
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

  %
  % Sanity checks
  %
  if (nargin ~= 6) || (nargout > 3) 
    print_usage(["[Azp,gradAzp,diagHessAzp] = ...\n", ...
 "       johanssonOneMlatticeAzp(wa,k0,epsilon0,k1,epsilon1)"]);
  endif
  if length(k0) ~= length(epsilon0)
    error("length(k0) ~= length(epsilon0)");
  endif
  if length(k1) ~= length(epsilon1)
    error("length(k1) ~= length(epsilon1)");
  endif
  if length(wa) == 0
    Azp=[];
    gradAsq=[];
    return;
  endif

  wa=wa(:);
  fM=fM(:)';
  k0=k0(:)';
  epsilon0=epsilon0(:)';
  k1=k1(:)';
  epsilon1=epsilon1(:)';
  
  Mon2=length(fM)-1;
  oneswa=ones(size(wa));
  kMon2=kron(oneswa,Mon2:-1:1);
  kfM=kron(oneswa,fM(1:Mon2));

  if nargout==1 
    P0=schurOneMAPlatticeP(wa,k0,epsilon0);
    P1=schurOneMAPlatticeP(wa,k1,epsilon1);
  elseif nargout==2 
    [P0,gradP0]=schurOneMAPlatticeP(wa,k0,epsilon0);
    [P1,gradP1]=schurOneMAPlatticeP(wa,k1,epsilon1);
  elseif nargout==3
    [P0,gradP0,diagHessP0]=schurOneMAPlatticeP(wa,k0,epsilon0);
    [P1,gradP1,diagHessP1]=schurOneMAPlatticeP(wa,k1,epsilon1);
  endif

  kMon2P1P0=kMon2.*kron(P1-P0,ones(1,Mon2));
  coskOmegaT=cos(kMon2P1P0);
  sinkOmegaT=sin(kMon2P1P0);

  if nargout>=1 
    Azp=fM(Mon2+1)+2*sum(kfM.*coskOmegaT,2);
  endif
  if nargout>=2  
    SsinkOmegaT=sum(kfM.*kMon2.*sinkOmegaT,2);
    k0SsinkOmegaT=kron(SsinkOmegaT,ones(size(k0)));
    k1SsinkOmegaT=kron(SsinkOmegaT,ones(size(k1)));
    gradAzp= [[2*coskOmegaT,oneswa], ...
               (2*gradP0.*k0SsinkOmegaT), ...
              -(2*gradP1.*k1SsinkOmegaT)];
  endif
  if nargout==3
    ScoskM2kOmegaT=sum(kfM.*kMon2.*kMon2.*coskOmegaT,2);
    k0ScoskM2kOmegaT=kron(ScoskM2kOmegaT,ones(size(k0)));
    k1ScoskM2kOmegaT=kron(ScoskM2kOmegaT,ones(size(k1)));
    diagHessAzp= ...
      [ [zeros(length(wa),length(fM))], ...
        ((2*diagHessP0.*k0SsinkOmegaT)-(2*gradP0.*gradP0.*k0ScoskM2kOmegaT)), ...
       -((2*diagHessP1.*k1SsinkOmegaT)+(2*gradP1.*gradP1.*k1ScoskM2kOmegaT))];
  endif
   
endfunction
