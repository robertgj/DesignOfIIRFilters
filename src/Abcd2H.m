function [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx] = ...
  Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
% H=Abcd2H(w,A,B,C,D)
% [H,dHdw] = Abcd2H(w,A,B,C,D)
% [H,dHdw,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
% [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
% [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
% [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] =
%   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
% [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx] = 
%   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
% [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx] = 
%   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
% [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx] = ...
%   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx,d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)
%
% Find the complex response and partial derivatives of a state variable
% filter with respect to a vector of coefficients. The vector x represents
% internal coefficients of the filter. For example, for a one-multiplier
% Schur lattice filter, x may represent the concatenated vector [k,c] where
% k represents the lattice multipliers and c represents the tap coefficients.
% The outputs of this function are intermediate results in the calculation
% of the squared-magnitude and group-delay responses and partial derivatives
% of the coefficients of the original filter. The state variable filter A,B,C
% and D matrixes are assumed to be linear in the x coefficients so that the
% second derivatives d2Adx2,etc are all zero.
%
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,C,D - state variable description of the filter with coefficients x
%  dAdx,dBdx,dCdx,dDdx - cell arrays of the gradients of A,B,C and D wrt x
%  d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx - cell arrays of the 2nd derivatives of
%                                    A,B,C and D wrt coefficients x and y
%
% Outputs:
%  H - complex vector of the response over w
%  dHdw - complex vector derivative of H wrt w
%  dHdx - complex matrix of the gradients of H wrt x coefficients and w
%  d2Hdwdx - complex matrix of the mixed second derivatives of H
%  diagd2Hdx2 - complex matrix of the diagonal of the matrix of second
%               derivatives of H wrt x coefficients
%  diagd3Hdwdx2 - complex matrix of the diagonal of the matrix of second
%                 derivatives of H wrt x coefficients and w
%  d2Hdydx - the Hessian matrix of the response wrt x and y coefficients
%  d3Hdwdydx - complex matrix of the second derivatives of H wrt x, y and w
%
% In the following, confusingly, Nx is the number of filter coefficients
% (eg: k and c or alpha, beta, gamma and delta) and Nk is the number of states.
%
% !!! d2Hdydx has not been tested with d2Adydx etc. !!!
%
% For each output other than d2Hdydx, the rows correspond to frequency
% vector, w, of length Nw and the columns correspond to the coefficient
% vector, x, of length Nx. d2Hdydx is returned as a matrix of size (Nw,Nx,Nx).
  
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

warning("Using m-file version of function Abcd2H()!");
  
% Sanity checks
if (nargin>14) ...
   || (nargout>8) ...
   || ((nargout<=2) && (nargin<5)) ...
   || ((nargout>2) && (nargout<=6) && (nargin~=9) && (nargin~=13)) ...
   || ((nargout>=7) && ((nargin~=9) && (nargin~=13)))
   print_usage("H=Abcd2H(w,A,B,C,D); \n\
[H,dHdw] = Abcd2H(w,A,B,C,D); \n\
[H,dHdw,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx); \n\
[H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx); \n\
[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx); \n\
[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...\n\
  Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx); \n\
[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx] = ...\n\
  Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx, ...\n\
         d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx); \n\
[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx] = ...\n\
  Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx, ...\n\
         d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx)");
endif
if nargin==5
  dAdx=[];dBdx=[];dCdx=[];dDdx=[];
endif
if nargin<=9
  d2Adydx=[];d2Bdydx=[];d2Cdydx=[];d2Ddydx=[];
endif
if isempty(A)
  error("A is empty");
endif
if (rows(A) ~= columns(A))
  error("rows(A) ~= columns(A)");
endif
if (rows(A) ~= rows(B))
  error("rows(A) ~= rows(B)");
endif
if (rows(A) ~= columns(C))
  error("rows(A) ~= columns(C)");
endif

% Initialise
w=w(:);
Nw=length(w);    % Number of frequencies
Nk=rows(A);      % Number of states
Nx=length(dAdx); % Number of coefficients
if nargout>=1
  H=zeros(Nw,1);
endif
if nargout>=2
  dHdw=zeros(Nw,1);
endif
if nargout>=3
  dHdx=zeros(Nw,Nx);
endif
if nargout>=4
  d2Hdwdx=zeros(Nw,Nx);
endif
if nargout>=5
  diagd2Hdx2=zeros(Nw,Nx);
endif
if nargout>=6
  diagd3Hdwdx2=zeros(Nw,Nx);
endif
if nargout>=7
  d2Hdydx=zeros(Nw,Nx,Nx);
endif
if nargout>=8
  d3Hdwdydx=zeros(Nw,Nx,Nx);
endif

% Loop over w calculating the complex response
for l=1:Nw,
  % Find the resolvent
  R=inv((exp(j*w(l))*eye(Nk))-A);
  
  % Find H
  CR=C*R;
  CRB=CR*B;
  H(l)=CRB+D;
  if nargout==1
    continue;
  endif

  % Find dHdw
  CRR=CR*R;
  CRRB=CRR*B;
  jexpjw=j*exp(j*w(l));
  dHdw(l)=-jexpjw.*CRRB;
  if nargout==2
    continue;
  endif

  % Find dHdx
  RB=R*B;
  for m=1:Nx
    dHdx(l,m)=(dCdx{m}*RB)+(CR*dAdx{m}*RB)+(CR*dBdx{m})+dDdx{m};
  endfor
  if nargout==3
    continue;
  endif

  % Find d2Hdwdx
  RRB=R*RB;
  for m=1:Nx
    d2Hdwdx(l,m)=-jexpjw*((CRR*dAdx{m}*RB) + ...
                          (CR*dAdx{m}*RRB) + ...
                          (CRR*dBdx{m})    + ...
                          (dCdx{m}*RRB));
  endfor
  if nargout==4
    continue;
  endif

  % Find diagd2Hdx2 (diagonal of the the Hessian of H wrt x)
  for m=1:Nx
    diagd2Hdx2(l,m) = (2*dCdx{m}*R*dAdx{m}*RB)    + ...
                      (2*dCdx{m}*R*dBdx{m})       + ...
                      (2*CR*dAdx{m}*R*dAdx{m}*RB) + ...
                      (2*CR*dAdx{m}*R*dBdx{m});
    if nargin==13
      diagd2Hdx2(l,m) = diagd2Hdx2(l,m)      + ...
                        (CR*d2Adydx{m,m}*RB) + ...
                        (CR*d2Bdydx{m,m})    + ...
                        (d2Cdydx{m,m}*RB)    + ...
                        (d2Ddydx{m,m});
    endif
  endfor
  if nargout==5
    continue;
  endif

  % Find diagd3Hdwdx2 (diagonal of the the partial derivatives of H wrt w,x)
  RR=R*R;
  for m=1:Nx
     diagd3Hdwdx2(l,m)=-2*jexpjw*( (CRR*dAdx{m}*R*dAdx{m}*RB) + ...
                                   (CR*dAdx{m}*RR*dAdx{m}*RB) + ...
                                   (CR*dAdx{m}*R*dAdx{m}*RRB) + ...
                                   (dCdx{m}*RR*dAdx{m}*RB)    + ...
                                   (dCdx{m}*R*dAdx{m}*RRB)    + ...
                                   (CRR*dAdx{m}*R*dBdx{m})    + ...
                                   (CR*dAdx{m}*RR*dBdx{m})    + ...
                                   (dCdx{m}*RR*dBdx{m})         );
     if nargin==13
       diagd3Hdwdx2(l,m)= ...
          diagd3Hdwdx2(l,m) - (jexpjw*( (CR*d2Adydx{m,m}*RRB) + ...
                                        (CRR*d2Adydx{m,m}*RB) + ...
                                        (CRR*d2Bdydx{m,m})    + ...
                                        (d2Cdydx{m,m}*RRB)      ));
     endif
  endfor
  if nargout==6
    continue;
  endif

  % Find d2Hdydx (second partial derivatives of H wrt x and y)
  for m=1:Nx
    for n=m:Nx
      d2Hdydx(l,m,n)=(dCdx{n}*R*dAdx{m}*RB)    + ...
                     (dCdx{n}*R*dBdx{m})       + ...
                     (dCdx{m}*R*dAdx{n}*RB)    + ...
                     (CR*dAdx{m}*R*dAdx{n}*RB) + ...
                     (CR*dAdx{n}*R*dAdx{m}*RB) + ...
                     (CR*dAdx{n}*R*dBdx{m})    + ...
                     (dCdx{m}*R*dBdx{n})       + ...
                     (CR*dAdx{m}*R*dBdx{n});
      if nargin==13
        d2Hdydx(l,m,n)=d2Hdydx(l,m,n)       + ...
                       (d2Cdydx{m,n}*RB)    + ...
                       (CR*d2Adydx{m,n}*RB) + ...
                       (CR*d2Bdydx{m,n})    + ...
                       (d2Ddydx{m,n});
      endif
      d2Hdydx(l,n,m)=d2Hdydx(l,m,n);
    endfor
  endfor
  if nargout==7
    continue;
  endif

  % Find d3Hdwdydx (second partial derivatives of H wrt x, y and w)
  for m=1:Nx
    for n=m:Nx
      d3Hdwdydx(l,m,n)=-jexpjw*( (dCdx{m}*RR*dAdx{n}*RB)    + ...
                                 (dCdx{m}*R*dAdx{n}*RRB)    + ...
                                 (dCdx{m}*RR*dBdx{n})       + ...
                                 (dCdx{n}*RR*dAdx{m}*RB)    + ...
                                 (dCdx{n}*R*dAdx{m}*RRB)    + ...
                                 (CRR*dAdx{n}*R*dAdx{m}*RB) + ...
                                 (CR*dAdx{n}*RR*dAdx{m}*RB) + ...
                                 (CR*dAdx{n}*R*dAdx{m}*RRB) + ...
                                 (CRR*dAdx{m}*R*dAdx{n}*RB) + ...
                                 (CR*dAdx{m}*RR*dAdx{n}*RB) + ...
                                 (CR*dAdx{m}*R*dAdx{n}*RRB) + ...
                                 (CRR*dAdx{m}*R*dBdx{n})    + ...
                                 (CR*dAdx{m}*RR*dBdx{n})    + ...
                                 (dCdx{n}*RR*dBdx{m})       + ...
                                 (CRR*dAdx{n}*R*dBdx{m})    + ...
                                 (CR*dAdx{n}*RR*dBdx{m})      );
      if nargin==13
        d3Hdwdydx(l,m,n)= d3Hdwdydx(l,m,n)  ...
                          + (-jexpjw*( (d2Cdydx{m,n}*RRB)    + ...
                                       (CRR*d2Adydx{m,n}*RB) + ...
                                       (CR*d2Adydx{m,n}*RRB) + ...
                                       (CRR*d2Bdydx{m,n})      ));
      endif
      d3Hdwdydx(l,n,m)=d3Hdwdydx(l,m,n);
    endfor
  endfor

endfor

endfunction
