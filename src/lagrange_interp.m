function [f,w,p]=lagrange_interp(xk,fk,wk,x,tol)
% [f,w,p]=lagrange_interp(xk,fk,wk,x,tol)
% Given the pairs <xk,fk>, return the values, f, of the Lagrange
% polynomial, p, at x. If wk is empty, the weights are calculated and
% returned in w. See: "Barycentric Lagrange Interpolation", J.-P. Berrut
% and L. N. Trefethen, SIAM Review, Vol. 46, No. 3, 2004, pp.501-517

% Copyright (C) 2019 Robert G. Jenssen
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

  if (nargin~=4 && nargin~=5) || nargout>3
    print_usage("[f,w,p]=lagrange_interp(xk,fk,wk,x,tol);");
  endif
  if nargin==4
    tol=2e-12;
  endif
  % Sanity checks
  if max(x)>max(xk) || min(x)<min(xk)
    error("Refusing to extrapolate");
  endif
  if any(size(xk)~=size(fk))
    error("any(size(xk)~=size(fk))");
  endif
  if all(size(xk)~=1)
    error("all(size(xk)~=1)");
  endif
  if max(size(xk))<2
    error("max(size(xk))<2)")
  endif
  if length(xk)~=length(unique(xk))
    error("length(xk)~=length(unique(xk))");
  endif
  if all(size(x)~=1)
    error("all(size(x)~=1)");
  endif
  if ~isempty(wk)
    if any(size(wk)~=size(xk))
      error("any(size(wk)~=size(xk))");
    endif
  endif

  % Linear interpolation between two points
  if any(size(xk)==2)
    a=(fk(2)-fk(1))/(xk(2)-xk(1));
    b=fk(1)-(a*xk(1));
    p=[a b];
    f=(a*x)+b;
  endif

  % All fk the same
  if all(fk==fk(1))
    f=fk(1)*ones(size(x));
    p=fk(1);
    w=[];
    warning("all(fk==fk(1))");
  endif
  
  % If necessary, calculate l=(x-xk(1))(x-xk(2)...(x-xk(end))
  if isempty(wk) || nargout==3
    l=1;
    for k=1:length(xk),
      l=conv(l,[1 -xk(k)]);
    endfor
  endif

  % If necessary, calculate the weights
  w=wk;
  if isempty(w)
    wxk=xk(:)-(xk(:)')+eye(length(xk));
    w=1./prod(wxk,1);
    if columns(xk)==1
      w=w';
    endif
  endif

  % Barycentric Lagrange interpolation (the fixed points are along rows)
  xdiff=x(:)-(xk(:)');
  [exact,kexact]=find(xdiff==0);
  kw=kron(w(:)',ones(length(x),1));
  kf=kron(fk(:)',ones(length(x),1));
  kwdx=kw./xdiff;
  f=sum((kwdx.*kf),2)./sum(kwdx,2);
  f(exact)=fk(kexact);

  % Calculate the interpolation polynomial if requested
  if nargout==3,
    p=zeros(1,length(xk));
    for k=1:length(xk),
      [quot,rem]=deconv(l,[1 -xk(k)]);
      if norm(rem)>tol
        warning("norm(rem)(%g)>%g",norm(rem),tol);
      endif
      p=p+(quot*w(k)*fk(k));
    endfor;
    if ~isempty(wk)
      nzfk=find(abs(fk)>1e-10);
      if isempty(nzfk)
        error("isempty(nzfk)");
      endif
      pk=polyval(p,xk(nzfk));
      tmp=fk(nzfk);
      p=p/mean(pk(:)./tmp(:));
    endif
  endif

endfunction
