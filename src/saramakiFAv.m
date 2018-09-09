function [F,delFdelalpha]=saramakiFAv(v,n,m,alpha,zeta)
% [F,delFdelalpha]=saramakiFAv(v,n,m,alpha,zeta)
%
% Calculate the value of Saramaki's F(A,w) function. This function represents
% the stop band response on the negative real axis of the w-plane. See
% Equation 18, Section V.A, of "Design of Optimum Recursive Digital Filters
% with Zeros on the Unit Circle", T. Saramaki, IEEE Trans. ASSP, April 1983.
%
% I use v instead of w to avoid confusion between w and omega.
  
% Copyright (C) 2018 Robert G. Jenssen
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

  % Sanity checks
  if (nargout>2)|| nargin~=5
    print_usage("[F,delFdelalpha]=saramakiFAv(v,n,m,alpha,zeta)")
  endif
  if n<m
    error("n<m");
  endif
  if length(alpha)~=floor(m/2)
    error("length(alpha)~=floor(m/2)")
  endif
  if length(zeta)~=2
    error("length(zeta)~=2");
  endif
  if zeta(1)>0
    error("zeta(1)>0");
  endif
  if zeta(2)>0
    error("zeta(2)>0");
  endif
  if zeta(1)>=zeta(2)
    error("zeta(1)>=zeta(2)");
  endif
  if any(v>zeta(2))
    error("v>zeta(2)");
  endif
  if any(v<zeta(1))
    error("v<zeta(1)");
  endif
  if any(v>zeta(2))
    error("v>zeta(2)");
  endif
  if any(alpha<=zeta(1))
    error("alpha<=zeta(1)");
  endif
  if any(alpha>=zeta(2))
    error("alpha>=zeta(2)");
  endif

  % Simple cases
  if nargout==0
    return;
  endif
  if length(v)==0
    F=[];
    return;
  endif
  if m==0
    F=v.^(-n);
    return;
  endif

  % F(A,v)
  v=v(:);
  alpha=alpha(:)';
  vv=kron(v,ones(size(alpha)));
  aa=kron(ones(length(v),1),alpha);
  onesv=ones(size(vv));
  oneMav=onesv-(aa.*vv);
  vMa=vv-aa;
  F=(prod(oneMav./vMa,2).^2)./(v.^(n-m));
  if mod(m,2)
    F=((1-zeta(2)*v)./(v-zeta(2))).*F;
  endif

  if nargout==1
    return;
  endif

  % delFdelalpha
  delFdelalpha=2*kron(F.*(1-(v.^2)),ones(size(alpha)))./(oneMav.*vMa);
  
endfunction
