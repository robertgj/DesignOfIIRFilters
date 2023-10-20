function Esq = schurOneMlatticePipelinedEsq ...
                 (k,epsilon,c,kk,ck,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Esq=schurOneMlatticePipelinedEsq ...
%       (k,epsilon,c,kk,ck,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% Inputs:
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   c - numerator all-pass filter tap coefficients
%   kk - k(2n-1)*k(2n) 
%   ck - c(2n)*k(2n) (c(1)=c_0, c(2n)=c_{2n-1})
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Asqd - desired pass-band magnitude-squared response
%   Wa - pass-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response 
%   Wp - phase weight vector
%   
% Outputs:
%   Esq - the squared error value at x

% Copyright (C) 2023 Robert G. Jenssen
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

  if nargout>1 || ((nargin~=8)&&(nargin~=11)&&(nargin~=14))
    print_usage("Esq = ...\n\
schurOneMlatticePipelinedEsq(k,epsilon,c,kk,ck,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif

  Nk=length(k);
  Nc=length(c);
  Nkk=length(kk);
  Nck=length(ck);
  if Nc ~= (Nk+1)
    error("Expected length(k)+1==length(c)!");
  endif
  if nargin==8
    wt=[];
    wp=[];
  elseif nargin==11
    wp=[];    
  endif
  
  if isempty(wa)
    EsqAsq = 0;
  else
    EsqAsq=schurOneMlatticePipelinedXError(@schurOneMlatticePipelinedAsq,...
                                           k,epsilon,c,kk,ck,wa,Asqd,Wa);
  endif
  if isempty(wt)
    EsqT = 0;
  else
    EsqT = schurOneMlatticePipelinedXError(@schurOneMlatticePipelinedT,...
                                           k,epsilon,c,kk,ck,wt,Td,Wt);
  endif
  if isempty(wp)
    EsqP = 0;
  else
    EsqP = schurOneMlatticePipelinedXError(@schurOneMlatticePipelinedP,...
                                           k,epsilon,c,kk,ck,wp,Pd,Wp);
  endif
  Esq = EsqAsq + EsqT + EsqP;
  
endfunction

function ErrorX = ...
  schurOneMlatticePipelinedXError(pfX,k,epsilon,c,kk,ck,wx,Xd,Wx)

  if nargin~=9 || nargout>1
    print_usage("ErrorX = ...\n\
      schurOneMlatticePipelinedXError(pfX,k,epsilon,c,kk,ck,wx,Xd,Wx)");
  endif

  % Make row vectors with a single column, 
  % since by default, sum() adds over first dimension
  k=k(:);
  epsilon=epsilon(:);
  c=c(:);
  kk=kk(:);
  ck=ck(:);
  wx=wx(:);
  Xd=Xd(:);
  Wx=Wx(:);

  % Sanity checks
  Nx = length(wx);
  if length(Xd) ~= Nx
    error("length(wx)~=length(Xd)");
  endif
  if length(Wx) ~= Nx
    error("length(wx)~=length(Wx)");
  endif
  Nk=length(k);
  Nc=length(c);
  if Nc ~= Nk+1
    error("Nc ~= Nk+1");
  endif
  Nkk=length(kk);
  Nck=length(ck);
  
  % X response at wx
  X=pfX(wx,k,epsilon,c,kk,ck);

  % Sanity check
  Xnf=find(any(~isfinite(X)));
  X(Xnf)=Xd(Xnf);

  % X response error with trapezoidal integration.
  dwx = diff(wx);
  ErrX=Wx.*(X-Xd);
  sqErrX=ErrX.*(X-Xd);
  ErrorX=sum(dwx.*(sqErrX(1:(Nx-1))+sqErrX(2:Nx)))/2;

endfunction
