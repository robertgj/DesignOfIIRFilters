function [E,gradE,hessE]=...
            iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose)
% [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose)
%
% Inputs:
%   x - coefficient vector in the form:
%         [ k;                          ...
%           zR(1:U);     pR(1:V);       ...
%           abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%           abs(p(1:Qon2)); angle(p(1:Qon2)) ];
%         where k is the gain coefficient, zR and pR represent real
%         zeros  and poles and z and p represent conjugate zero and
%         pole pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Ad - desired pass-band amplitude response
%   Wa - pass-band amplitude weight vector
%   ws - angular frequencies of desired stop-band amplitude response 
%   Sd - desired stop-band amplitude response
%   Ws - stop-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response 
%   Wp - phase response weight vector
%   verbose -
%   
% Outputs:
%   E - the error value at x
%   gradE - gradient of the error value at x (NB: a column vector!)
%   hessE - Hessian of the error value at x
%
% !!! NOTE WELL !!! :
%
%   1. For convenience, iirE returns gradE as a column vector, unlike
%      iirA, iirP, iirT and Xerror which return gradA etc with gradient
%      along rows and frequency down columns.
%
%   2. The gradients are with respect to the filter coefficients, 
%      NOT the frequency.
%
%   3. Note the Hessian is defined as:
%        del2fdelx1delx1  del2fdelx1delx2  del2fdelx1delx3 ...
%        del2fdelx2delx1  del2fdelx2delx2  del2fdelx2delx3 ...
%        etc

% Copyright (C) 2017-2025 Robert G. Jenssen
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

if nargout>3 || (nargin~=18 && nargin~=19)
  print_usage ...
    ("[E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp)");
endif
if nargin==18
  verbose=false;
endif


N=1+U+V+M+Q;
if N~=length(x)
  error("Expected length(x)==(1+U+V+M+Q)!");
endif

if nargout==1
  if (isempty(wa))
    EA = 0;
  else
    EA = Xerror(@iirA,x,U,V,M,Q,R,wa,Ad,Wa);
  endif
  if (isempty(ws))
    ES = 0;
  else
    ES = Xerror(@iirA,x,U,V,M,Q,R,ws,Sd,Ws);
  endif
  if (isempty(wt))
    ET = 0;
  else
    ET = Xerror(@iirT,x,U,V,M,Q,R,wt,Td,Wt);
  endif
  if (isempty(wp))
    EP = 0;
  else
    EP = Xerror(@iirP,x,U,V,M,Q,R,wp,Pd,Wp);
  endif
  E = EA + ES + ET + EP;
elseif nargout==2
  if (isempty(wa))
    EA = 0;
    gradEA = zeros(1,N);
  else
    [EA,gradEA] = Xerror(@iirA,x,U,V,M,Q,R,wa,Ad,Wa);
  endif
  if (isempty(ws))
    ES = 0;
    gradES = zeros(1,N);
  else
    [ES,gradES] = Xerror(@iirA,x,U,V,M,Q,R,ws,Sd,Ws);
  endif
  if (isempty(wt))
    ET = 0;
    gradET = zeros(1,N);
  else
    [ET,gradET] = Xerror(@iirT,x,U,V,M,Q,R,wt,Td,Wt);
  endif
  if (isempty(wp))
    EP = 0;
    gradEP = zeros(1,N);
  else
    [EP,gradEP] = Xerror(@iirP,x,U,V,M,Q,R,wp,Pd,Wp);
  endif
  E = EA + ES + ET + EP;
  gradE = gradEA + gradES + gradET + gradEP;
  gradE = gradE(:);
elseif nargout==3
  if isempty(wa)
    EA = 0;
    gradEA = zeros(1,N);
    hessEA = zeros(N,N);
  else
    [EA,gradEA,hessEA] = Xerror(@iirA,x,U,V,M,Q,R,wa,Ad,Wa);
  endif
  if isempty(ws)
    ES = 0;
    gradES = zeros(1,N);
    hessES = zeros(N,N);
  else
    [ES,gradES,hessES] = Xerror(@iirA,x,U,V,M,Q,R,ws,Sd,Ws);
  endif
  if (isempty(wt))
    ET = 0;
    gradET = zeros(1,N);
    hessET = zeros(N,N);
  else
    [ET,gradET,hessET] = Xerror(@iirT,x,U,V,M,Q,R,wt,Td,Wt);
  endif
  if isempty(wp)
    EP = 0;
    gradEP = zeros(1,N);
    hessEP = zeros(N,N);
  else
    [EP,gradEP,hessEP] = Xerror(@iirP,x,U,V,M,Q,R,wp,Pd,Wp);
  endif
  E = EA + ES + ET + EP;
  gradE = gradEA + gradES + gradET + gradEP;
  gradE = gradE(:);
  hessE = hessEA + hessES + hessET + hessEP;

  if ~issymmetric(hessE,100*eps)
    error("Expected hessE symmetric!");
  endif
  
  hessE=(hessE+hessE')/2;

endif

endfunction

function [ErrorX,gradErrorX,hessErrorX]=Xerror(hiirX,x,U,V,M,Q,R,wx,Xd,Wx,tol)
% [ErrorX gradErrorX hessErrorX] = Xerror(hiirX,x,U,V,M,Q,R,wx,Xd,Wx,tol)
%
% Calculate the error and gradient and Hessian of the response squared error
%
% Inputs:
%   hiirX - function handle for a function like
%             [X,gradX,hessX]=iirX(wx,x,U,V,M,Q,R[,tol]);
%   x - coefficient vector in the form:
%         [k; 
%          zR(1:U); pR(1:V); ...
%          abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%          abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where k is the gain coefficient, zR and pR represent real
%       zeros and poles and z and p represent conjugate zero and
%       pole pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   wx - normalised angular frequencies (wx in [0, pi), fs=1)
%   Xd - vector of desired values
%   Wx - vector of desired weights
%   tol - tolerance (optional, default is 1e-9)
% 
% Outputs:
%   ErrorX - total error for angular frequencies in wx at x
%   gradErrorX - gradient of ErrorX at x
%   hessErrorX - Hessian of ErrorX at x

  if (nargin~=10 && nargin~=11) || nargout>3 
    print_usage ...
      ("[ErrorX,gradErrorX,hessErrorX]=Xerror(hiirX,x,U,V,M,Q,R,wx,Xd,Wx,tol)");
  endif

  % Sanity checks
  if ~is_function_handle(hiirX)
    error("hiirX is not a function handle");
  endif
  if nargin==10
    tol=1e-9;
  endif
  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  x = x(:)';
  wx = wx(:);
  Xd = Xd(:);
  Wx = Wx(:);
  Nw = length(wx);
  if length(Xd) ~= Nw
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nw
    error("length(wx)~=length(Wx)");
  endif
  N=1+U+V+M+Q;
  if length(x) ~= N
    error("length(x) ~= 1+U+V+M+Q");
  endif

  % Response at wx
  if nargout==1
    X=hiirX(wx,x,U,V,M,Q,R,tol);
    gradX=zeros(Nw,N);
    hessX=zeros(Nw,N,N);
  elseif nargout==2
    [X,gradX]=hiirX(wx,x,U,V,M,Q,R,tol);
    hessX=zeros(Nw,N,N);
  elseif nargout==3
    [X,gradX,hessX]=hiirX(wx,x,U,V,M,Q,R,tol);
  endif

  % Response error, gradient of error and Hessian of error.
  % Wx is a weight vector over the frequencies.
  % Use trapezoidal integration.
  % Exchange order of integration and differentiation of the error.
  % X is Nw-by-1. gradX is Nw-by-N. hessX is Nw-by-N-by-N
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nw-1))+sqErrX(2:Nw)))/2;
  if nargout==1
    return;
  endif
  
  kErrX=kron(ErrX,ones(1,N));
  kErrXgradX=(kErrX(1:(Nw-1),:).*gradX(1:(Nw-1),:) + ...
              kErrX(2:end,:).*gradX(2:end,:))/2;
  kdwxErrXgradX=2*kron(dwx,ones(1,N)).*kErrXgradX;
  gradErrorX=sum(kdwxErrXgradX,1);
  if nargout==2
    return;
  endif

  % The derivative of integralof(2*Wx*(X-Xd)'*gradX) is
  % integralof(2*Wx*gradX'*gradX + 2*Wx*(X-Xd)'*hessX). 

  % Construct 1st term
  WxKgradX=kron(ones(1,N),Wx).*gradX;
  WgradXbyRow=permute(reshape(kron(WxKgradX',ones(1,N)),N,N,Nw),[3,1,2]);
  gradXbyCol=permute(reshape(kron(   gradX',ones(N,1)),N,N,Nw),[3,1,2]);

  % Construct 2nd term
  % Create an Nw-by-N-by-N array.
  % Each element of the k'th N-by-N subarray is ErrX(k).
  hkErrX=permute(reshape(kron(ErrX',ones(N,N)),N,N,Nw),[3,1,2]);

  % Integrand
  hXint=(WgradXbyRow.*gradXbyCol)+(hkErrX.*hessX);

  % Trapezoidal integration
  kdwx=permute(reshape(kron(dwx',ones(N,N)),N,N,Nw-1),[3,1,2]);
  hessErrorX=2*reshape(sum(kdwx.*(hXint(1:(Nw-1),:,:)+hXint(2:Nw,:,:))/2,1),N,N);

endfunction
