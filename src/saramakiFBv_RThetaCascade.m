function [F,delFdelbeta]=saramakiFBv_RThetaCascade(beta,n,m,v)
% [F,delFdelbeta]=saramakiFBv_RThetaCascade(beta,n,m,v)
%
% Calculate the value of Saramaki's F(B,w) function with m>n. This function
% represents the pass band response on the positive real axis of the w-plane.
% For n even, beta=[r(1),theta(1),...,r(floor(n/2)),theta(floor(n/2))]. For
% n odd, beta=[r(1),theta(1),...,r(floor(n/2)),theta(floor(n/2)),R].
% I use v instead of w to avoid confusion between w and omega. See Equation 28,
% Section V.B, of "Design of Optimum Recursive Digital Filters with Zeros on
% the Unit Circle", T. Saramaki, IEEE Trans. ASSP, April 1983.

% The numerators of the gradients in rk and thetak were found with the
% following maxima code:
%{
  A(r,th):=1-(2*r*cos(th)*v)+((r^2)*(v^2));
  B(r,th):=(v^2)-(2*r*cos(th)*v)+(r^2);
  ddr(r,th):=factor((diff(A(r,th),r)*B(r,th))-(diff(B(r,th),r)*A(r,th)));
  ddr(r,th);
  ddth(r,th):=factor((diff(A(r,th),th)*B(r,th))-(diff(B(r,th),th)*A(r,th)));
  ddth(r,th);
%}

% Copyright (C) 2018-2025 Robert G. Jenssen
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
  if (nargout>2) || nargin~=4
    print_usage("[F,delFdelbeta]=saramakiFBv_RThetaCascade(beta,n,m,v)")
  endif
  if n>=m
    error("n>=m");
  endif
  if length(beta)~=n
    error("length(beta)~=n");
  endif

  % Simple cases
  if nargout==0
    return;
  endif
  if length(v)==0
    F=[];
    return;
  endif
  if n==0
    F=v(:).^(-m);
    return;
  endif

  % Extract pole radii and angles from beta
  v=v(:);
  beta=beta(:)';
  non2=floor(n/2);
  rkr=1:2:((2*non2)-1);
  thkr=2:2:(2*non2);
  rk=beta(rkr);
  thk=beta(thkr);
  if mod(n,2)
    Rk=beta(n);
  else
    Rk=0;
  endif
  
  % F(beta,v)
  vmn=v.^(m-n);
  kv=kron(v,ones(1,non2));
  kv2=kron(v.^2,ones(1,non2));
  onesv=ones(size(kv));
  krk=kron(ones(length(v),1),rk);
  krk2=kron(ones(length(v),1),rk.^2);
  krkcosthkv=kron(v,rk.*cos(thk));
  Fnum=onesv-(2*krkcosthkv)+(krk2.*kv2);
  Fden=kv2-(2*krkcosthkv)+krk2;
  F=(v.^(n-m)).*prod(Fnum,2)./prod(Fden,2);
  if mod(n,2)
    F=((1-(Rk*v))./(v-Rk)).*F;
  endif

  if nargout==1
    return;
  endif

  % delFdelbeta
  kv2m1=kv2-ones(size(kv2));
  kcosthk=kron(ones(length(v),1),cos(thk));
  ksinthk=kron(ones(length(v),1),sin(thk));
  kF=kron(F,ones(1,non2));
  FnumFden=Fnum.*Fden;
  delFdelbeta=zeros(length(v),n);
  delFdelbeta(:,rkr)=...
    2*((krk.*(1+kv2))-(kcosthk.*(1+krk2).*kv)).*kv2m1.*kF./FnumFden;
  delFdelbeta(:,thkr)=2*krk.*(1-krk2).*kv.*kv2m1.*ksinthk.*kF./FnumFden;
  if mod(n,2)
    delFdelbeta(:,n)=((1-(v.^2)).*F)./((v-Rk).*(1-(Rk*v)));
  endif
  
endfunction
