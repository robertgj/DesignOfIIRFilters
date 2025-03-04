function [F,delFdelB]=saramakiFBv(B,n,m,v)
% [F,delFdelB]=saramakiFBv(B,n,m,v)
%
% Calculate the value of Saramaki's F(B,w) function with m>n. This function
% represents the pass band response on the positive real axis of the w-plane.
% For n even, B=[s(1),r(1),...,s(floor(n/2)),r(floor(n/2))]. For n odd,
% B=[s(1),r(1),...,s(floor(n/2)),r(floor(n/2)),R].  I use v instead of w
% to avoid confusion between w and omega. See Equation 28, Section V.B, of
% "Design of Optimum Recursive Digital Filters with Zeros on the Unit Circle",
% T. Saramaki, IEEE Trans. ASSP, April 1983.
  
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
  if (nargout>2)|| nargin~=4
    print_usage("[F,delFdelB]=saramakiFBv(B,n,m,v)")
  endif
  if n>=m
    error("n>=m");
  endif
  if length(B)~=n
    error("length(B)~=n");
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

  % F(B,v)
  v=v(:);
  B=B(:)';
  non2=floor(n/2);
  skr=1:2:((2*non2)-1);
  rkr=2:2:(2*non2);
  sk=B(skr);
  rk=B(rkr);
  if mod(n,2)
    Rk=B(n);
  endif
  
  vmn=v.^(m-n);
  vv=kron(v,ones(1,non2));
  vv2=kron(v.^2,ones(1,non2));
  onesv=ones(size(vv));
  ksk=kron(ones(length(v),1),sk);
  krk=kron(ones(length(v),1),rk);
  Fnum=onesv+(ksk.*vv)+(krk.*vv2);
  Fden=vv2+(ksk.*vv)+rk;
  F=(v.^(n-m)).*prod(Fnum,2)./prod(Fden,2);
  if mod(n,2)
    F=((1-(Rk*v))./(v-Rk)).*F;
  endif

  if nargout==1
    return;
  endif

  % delFdelB
  vv2m1=vv2-ones(size(vv2));
  Fk=kron(F,ones(1,non2));
  FnumFden=Fnum.*Fden;
  delFdelB=zeros(length(v),n);
  delFdelB(:,skr)=(vv.*vv2m1.*(onesv-rk).*Fk)./FnumFden;
  delFdelB(:,rkr)=(vv2m1.*(vv2+(sk.*vv)+onesv).*Fk)./FnumFden;
  if mod(n,2)
    delFdelB(:,n)=((1-(v.^2)).*F)./((v-Rk).*(1-(Rk*v)));
  endif
  
endfunction
