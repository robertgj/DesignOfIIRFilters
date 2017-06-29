function [k,khat] = complementaryFIRdecomp(h,g,tol)
% [k,khat]=complementaryFIRdecomp(h,g[,tol])
% Find the FIR lattice coefficients, k and khat, for the power complementary
% FIR filters h and g.
%
% Note that the Octave (Matlab?) convention is
%   D(z)=d(1)+d(2)*z^(-1)+d(3)*z^(-2)+...+d(N)*z^(-N+1)
%  
% See: "Passive Cascaded-Lattice Structures for Low-Sensitivity FIR
% Filter Design, with Applications to Filter Banks",
% P. P. Vaidyanathan, IEEE Transactions on Circuits and Systems,
% Vol. 33, No. 11, pp 1045-1064, November 1986.
% 
  
% Copyright (C) 2017 Robert G. Jenssen
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

  warning("Using Octave m-file version of function complementaryFIRdecomp()!");

  % Sanity checks
  if ((nargin ~= 2) && (nargin ~= 3)) || (nargout ~=2)
    print_usage("[k,khat]=complementaryFIRdecomp(h,g[,tol])");
  endif
  if length(h) ~= length(g)
    error("Expected length(h) == length(g)!");
  endif
  if nargin == 2
    tol = 10*eps;
  endif
  if abs((h(:)'*h(:))+(g(:)'*g(:))-1) > tol
    error("Expected abs((h'*h)+(g'*g)-1) (%g*eps) < tol", ...
          abs((h(:)'*h(:))+(g(:)'*g(:))-1)/eps);
  endif
  
  hm=h(:);
  gm=g(:);
  N=length(hm);
  k=[];
  khat=[];
  m=1;
  
  for l=1:N
    
    % No order reduction step
    if (hm(end) == 0) && (gm(end) == 0)
      warning("l=%d,m=%d : hm(end) == gm(end) == 0",l,m);
      hm(end)=[];
      gm(end)=[];
      continue;
    endif

    % General case using Equation 23
    tmp=sqrt((hm(1)^2)+(gm(1)^2));
    k(m)=hm(1)/tmp;
    khat(m)=gm(1)/tmp;
    
    % New polynomials
    hmtmp=(hm*k(m))+(gm*khat(m));
    gm=-(hm*khat(m))+(gm*k(m));
    hm=hmtmp;

    % Sanity checks  
    if l < N
      if abs(hm(end)) > tol
        error("Expected m=%d : abs(hm(end)) (=%g*eps) <= tol", m,hm(end)/eps);
      endif
      if abs(gm(1)) > tol
        error("Expected m=%d : abs(gm(1)) (=%g*eps) <= tol", m,gm(1)/eps);
      endif
    endif
    if abs((hm'*hm)+(gm'*gm)-1) > tol
      error("Expected m=%d : abs((hm'*hm)+(gm'*gm) -1) == 0 (%g*eps)", ...
            m,abs((hm'*hm)+(gm'*gm)-1)/eps);
    endif

    % Order reduction
    m=m+1;
    hm(end)=[];    
    gm(1)=[];

  endfor;

  k=flipud(k(:));
  khat=flipud(khat(:));
  
endfunction
